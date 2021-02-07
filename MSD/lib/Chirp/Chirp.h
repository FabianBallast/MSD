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

    // Array for logarithmic spacing of freqeuncies between two decades. Multiply current freq with ratio.
    const float ratio[5] = {1, 1.177827941, 3.16227766/1.177827941, 5.623413252/3.16227766, 10/5.623413252};

    long mapf(float x, float in_min, float in_max, long out_min, long out_max);

public:

    /// Create a chirp object.
    Chirp(Motor* motor);
    
    /// Initialize chirp and motor.
    void init();

    /// Create a chirp signal from frequency 0 to frequency 1 with amplitude.
    /// \param[in] freq0 Starting freqeuncy in Hz.
    /// \param[in] freq1 Final frequency in Hz.
    /// \param[in] voltAmp Amplitude of voltage in V.
    void chirpSignal(uint16_t freq0, uint16_t freq1, float voltAmp);
};








#endif