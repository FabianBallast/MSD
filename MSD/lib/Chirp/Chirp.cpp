#include <Arduino.h>
#include <Motor.h>
#include <PinLayout.h>
#include <Chirp.h>

Chirp::Chirp(Motor* motor)
{
    _motor = motor;
    
}

void Chirp::init()
{
    _motor->init();
}

void Chirp::chirpSignal(uint16_t freq0, uint16_t freq1, float voltAmp)
{

}

long Chirp::mapf(float x, float in_min, float in_max, long out_min, long out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}