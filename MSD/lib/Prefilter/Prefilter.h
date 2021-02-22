#ifndef Prefilter_h
#define Prefilter_h

#include <Arduino.h>

/// \mainpage File to manage the prefilter.

class Prefilter
{
private:
    
    uint8_t state = 0;
    float _tRest = 0;
    float _amax;
    float _vmax;

    float t1 = 0;
    float t2 = 0;
    float t3 = 0;
    float t4 = 0;
    float tf = 0;

    float sCurr = 0;

public:

    /// Create a prefilter object.
    Prefilter(float tRest, float vmax, float amax);
    
    float stepFilter(float t, float tStart);
    float triangular(float t, float tStart);
    float sysID(float t, float tStart);
};








#endif