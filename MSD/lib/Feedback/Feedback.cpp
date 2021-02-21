#include <Arduino.h>
#include <Feedback.h>

Feedback::Feedback(float a1, float a2, float b2) : _a1(a1), _a2(a2), _b2(-1*b2)
{}

float Feedback::controlValue(float error)
{
    float newVal = _b2 * controlPrev + _a1 * error + _a2 * errorPrev;
    errorPrev = error;
    controlPrev = newVal;
    return newVal;
}