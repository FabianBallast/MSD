#include <Arduino.h>
#include <Feedforward.h>

Feedforward::Feedforward(float a1, float a2, float a3, float a4, float a5, float b2, float b3, float b4, float b5) : 
_a1(a1), _a2(a2), _a3(a3), _a4(a4), _a5(a5), _b2(-1*b2), _b3(-1*b3), _b4(-1*b4), _b5(-1*b5)
{}

float Feedforward::controlValue(float reference)
{
    float newVal = _b2 * control2 + _b3 * control3 + _b4 * control4 + _b5 * control5 + _a1 * reference + _a2 * reference2 + _a3 * reference3 + _a4 * reference4 + _a5 * reference5;

    control5 = control4;
    control4 = control3;
    control3 = control2;
    control2 = newVal;

    reference5 = reference4;
    reference4 = reference3;
    reference3 = reference2;
    reference2 = reference;

    return newVal;
}