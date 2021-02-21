#ifndef Feedback_h
#define Feedback_h

#include <Arduino.h>

/// \mainpage File to manage a feedback controller.

class Feedback
{
private:
    // Pointer to motor.
    const float _a1;
    const float _a2;
    const float _b2; 

    float errorPrev = 0;
    float controlPrev = 0;

public:

    /// Create a feedback object.
    Feedback(float a1, float a2, float b2);
    
    float controlValue(float error);
};








#endif