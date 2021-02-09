#ifndef Chirp_h
#define Chirp_h

#include <PinLayout.h>
#include <Arduino.h>
#include <Motor.h>

/// \mainpage File to manage a chirp voltage signal.

class Chirp
{
private:
    // Pointer to motor.
    Motor* _motor;
    const float pi = 3.14159;
    float frequency;
    long double percentage;
    long double prevPer = 0;
    long double endTime;
    long double startTime;
    long double time;
    float volVal;

    bool chirpDone = false;

    // Array for logarithmic spacing of freqeuncies between two decades. Multiply current freq with ratio.
    double ratio[30];
    const uint8_t _stepsPerDecade;

    long mapf(float x, float in_min, float in_max, long out_min, long out_max);

public:

    /// Create a chirp object.
    Chirp(Motor* motor, uint8_t stepsPerDecade);
    
    /// Initialize chirp and motor.
    void init();

    /// Create a chirp signal from frequency 0 to frequency 1 with amplitude.
    /// \param[in] freq0 Starting frequency in Hz.
    /// \param[in] freq1 Final frequency in Hz.
    /// \param[in] voltAmp Amplitude of voltage in V.
    void chirpSignal(float freq0, float freq1, float voltAmp);

    /// Create a sine wave with set frequency and amplitude.
    /// \param[in] frequency Freqeuncy in Hz.
    /// \param[in] voltAmp Amplitude of voltage in V.
    void sineWave(float frequency, float voltAmp);

    /// Return true if done with chirp sequence. 
    /// \returns Boolean; true if done lese false.
    bool doneChirp();
};








#endif