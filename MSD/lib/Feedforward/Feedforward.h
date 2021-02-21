#ifndef Feedforward_h
#define Feedforward_h

#include <Arduino.h>

/// \mainpage File to manage a feedback controller.

class Feedforward
{
private:
    // Pointer to motor.
    const float _a1;
    const float _a2;
    const float _a3;
    const float _a4;
    const float _a5;
    const float _b2;
    const float _b3; 
    const float _b4;
    const float _b5; 

    float reference2 = 0;
    float control2 = 0;
    float reference3 = 0;
    float control3 = 0;
    float reference4 = 0;
    float control4 = 0;
    float reference5 = 0;
    float control5 = 0;

public:

    /// Create a feedback object.
    Feedforward(float a1, float a2, float a3, float a4, float a5, float b2, float b3, float b4, float b5);
    
    float controlValue(float reference);
};








#endif