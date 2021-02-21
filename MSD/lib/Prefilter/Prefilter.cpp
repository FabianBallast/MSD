#include <Arduino.h>
#include <Prefilter.h>

Prefilter::Prefilter(float tRest, float vmax, float amax)
{

    _tRest = tRest;
    _vmax = vmax;
    _amax = amax;

    // t1 = vmax / amax;
    t1 = sqrt(360/amax);
    float sFS = 360 - vmax*vmax/amax;
    t2 = sFS / vmax;
}

float Prefilter::stepFilter(float t, float tStart)
{
    switch (state)
    {
    case 0:
        if(t > _tRest + tf + tStart)
        {
            state++;
            Serial.println(t1);
            Serial.println(t2);
            tf += tStart + _tRest;
        }
        return 0;
        break;
    
    case 1:
        if(t > t1 + tf)
        {
            state = 3;
            sCurr = 0.5 * _amax * t1*t1;
            tf += t1;
            return sCurr;
        }
        return 0.5 * _amax * (t - tf)*(t - tf);
        break;

    case 2:
        if(t > t2 + tf)
        {
            state++;
            sCurr += _vmax * t2;
            tf += t2;
            return sCurr;
        }
        return sCurr + _vmax*(t - tf);
        break;

    case 3:
        if(t > t1 + tf)
        {
            state++;
            sCurr = 360;
            tf += t1;
            return sCurr;
        }
        return sCurr - 0.5 * _amax * (t-tf)*(t-tf) + _amax * t1*(t - tf);
        break;

    case 4:
        if(t > tf + _tRest)
        {
            state++;
            tf += _tRest;
        }
        return sCurr;
        break;

    case 5:
        if(t > tf + t1)
        {
            state = 7;
            sCurr -= 0.5 * _amax * t1*t1;
            tf += t1;
            return sCurr;
        }
        return sCurr - 0.5 * _amax * (t-tf)*(t-tf);
        break;

    case 6:
        if(t > tf + t2)
        {
            state++;
            sCurr -= _vmax * t2;
            tf += t2;
            return sCurr;
        }
        return sCurr - _vmax*(t - tf);
        break;

    case 7:
        if(t > tf + t1)
        {
            state = 0;
            sCurr = 0;
            tf += t1;
            return sCurr;
        }
        return sCurr + 0.5 * _amax * (t-tf)*(t-tf) - _amax*t1*(t - tf);
        break;

    default:
        return 0; 
        break;
    }


}