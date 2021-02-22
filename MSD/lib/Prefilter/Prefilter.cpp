#include <Arduino.h>
#include <Prefilter.h>

Prefilter::Prefilter(float tRest, float vmax, float amax)
{

    _tRest = tRest;
    _vmax = vmax;
    _amax = amax;

    t3 = vmax / amax;
    t1 = sqrt(360/amax);
    float sFS = 1440.0 - vmax*vmax/amax;
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

float Prefilter::triangular(float t, float tStart)
{
    switch (state)
    {
    case 0:
        if(t > tf + tStart)
        {
            state++;
            // Serial.println(t3);
            // Serial.println(t2);
            tf += tStart ;
        }
        return 0;
        break;

    case 1:
        if(t > t3 + tf)
        {
            state++;
            sCurr = 0.5 * _amax * t3*t3;
            tf += t3;
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
        if(t > t3 + tf)
        {
            state = 5;
            sCurr = 1440;
            tf += t3;
            return sCurr;
        }
        return sCurr - 0.5 * _amax * (t-tf)*(t-tf) + _amax * t3*(t - tf);
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
        if(t > tf + t3)
        {
            state++;
            sCurr -= 0.5 * _amax * t3*t3;
            tf += t3;
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
        if(t > tf + t3)
        {
            state = 1;
            sCurr = 0;
            tf += t3;
            return sCurr;
        }
        return sCurr + 0.5 * _amax * (t-tf)*(t-tf) - _amax*t3*(t - tf);
        break;

    default:
        return 0; 
        break;
    }
}

float Prefilter::sysID(float t, float tStart){
    switch (state)
    {
    case 0:
        if(t > tf + tStart + 1)
        {
            state++;
            // Serial.println(t3);
            // Serial.println(t2);
            tf += tStart +1;
        }
        return 0;
        break;

    case 1:
        if(t > 2 + tf)
        {
            state++;
            sCurr = 360;
            tf += 2;
            return sCurr;
        }
        return 360;
        break;

    case 2:
        if(t > 2 + tf)
        {
            state++;
            sCurr = 0;
            tf += 2;
            return sCurr;
        }
        return 0;
        break;

    case 3:
        if(t > 2 + tf)
        {
            state++;
            sCurr = -360;
            tf += 2;
            return sCurr;
        }
        return -360;
        break;

    case 4:
        if(t > tf + 2)
        {
            state++;
            tf += 2;
        }
        return 0;
        break;

    case 5:
        if(t > tf + 2)
        {
            state = 14;
            sCurr = 360;
            tf += 2;
            return sCurr;
        }
        return 360;
        break;

    case 14:
        if(t > tf + 2)
        {
            state = 6;
            sCurr = 0;
            tf += 2;
            return sCurr;
        }
        return 0;
        break; 

    case 6:
        if(t > tf + 2)
        {
            state= 15;
            sCurr = -360;
            tf += 2;
            return sCurr;
        }
        return -360;
        break;

    case 15:
        if(t > tf + 2)
        {
            state = 7;
            sCurr = 0;
            tf += 2;
            return sCurr;
        }
        return 0;
        break; 

    case 7:
        if(t > tf + 2)
        {
            state= 16;
            sCurr = 360;
            tf += 2;
            return sCurr;
        }
        return 360;
        break;

    case 16:
        if(t > tf + 2)
        {
            state = 8;
            sCurr = 0;
            tf += 2;
            return sCurr;
        }
        return 0;
        break; 

    case 8:
        if(t > tf + 2)
        {
            state++;
            sCurr = -360;
            tf += 2;
            return sCurr;
        }
        return -360;
        break;

    case 9:
        if(t > tf + 2)
        {
            state++;
            sCurr = 0;
            tf += 2;
            return sCurr;
        }
        return 0;
        break; 
    
    case 10:
        if(t > tf + 4)
        {
            state++;
            sCurr = 360;
            tf += 4;
            return sCurr;
        }
        return -360.0 + 180.0 * (t - tf);
        break;

    case 11:
        if(t > tf + 2)
        {
            state++;
            sCurr = 0;
            tf += 2;
            return sCurr;
        }
        return 0;
        break;    
        
    
     case 12:
        if(t > tf + 4)
        {
            state++;
            sCurr = 360;
            tf += 4;
            return sCurr;
        }
        return -360.0 + 180.0 * (t - tf);
        break;
    
     case 13:
        if(t > tf + 2)
        {
            state = 18;
            sCurr = 0;
            tf += 2;
            return sCurr;
        }
        return 0;
        break; 

    default:
        return 0; 
        break;
    }
}