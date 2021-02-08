#include <Arduino.h>
#include <Motor.h>
#include <PinLayout.h>
#include <Chirp.h>

Chirp::Chirp(Motor* motor, uint8_t stepsPerDecade) : _stepsPerDecade(stepsPerDecade)
{
    _motor = motor;
    
    for(int i = 0; i <= stepsPerDecade - 1; i++)
    {
      ratio[i] = pow(10.0, (i)/float(stepsPerDecade - 1));
    }

    
}

void Chirp::init()
{
    _motor->init();
    TCCR1B = (TCCR1B & 0b11111000) | 1;//set timer 1B (pin 9) to 31250khz
}

void Chirp::chirpSignal(float freq0, float freq1, float voltAmp) // 10  -> 1000
{
  frequency = freq0;
  uint8_t decades = log10(round(freq1 / freq0));
  startTime = micros();
  endTime = startTime + 1000000 / freq0;

  for(int i = 0; i < decades; i++) // Twee keer: 10 -> 100 & 100 -> 1000
  {
    for(int j = 0; j < _stepsPerDecade - 1;) // [1, 1.29, 1.67 ...]
    {
      time = micros();
      percentage = (time - startTime) / (endTime - startTime);
      volVal = voltAmp * sin(((time-startTime)/1000000 * frequency) * 2 * pi);

      _motor->setVoltage(volVal);

      if(time >= endTime)
      {
        j++;
        frequency = freq0 * pow(10, i) * ratio[j];
        startTime = endTime; //micros();
        endTime = startTime + 1000000 / frequency;
      }

    }
  }

  
}

void Chirp::sineWave(float frequency, float voltAmp)
{
  time = micros() % 1000000; // Take modulus.
  percentage = time / 1000000;
  volVal = voltAmp * sin(frequency * percentage * 2 * pi);

  _motor->setVoltage(volVal);

}

long Chirp::mapf(float x, float in_min, float in_max, long out_min, long out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}