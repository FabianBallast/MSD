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
    // TCCR1B = (TCCR1B & 0b11111000) | 1;//set timer 1B (pin 9) to 31250khz
}

void Chirp::chirpSignal(float freq0, float freq1, float voltAmp) // 10  -> 1000
{
  frequency = freq0;
  uint8_t decades = log10(round(freq1 / freq0));
  Serial.println(decades);
  startTime = micros();
  endTime = startTime + 1000000 / freq0;
  long double printTime = 0;


  for(int i = 0; i < decades; i++) // Twee keer: 10 -> 100 & 100 -> 1000
  {
    for(int j = 0; j < _stepsPerDecade;) // [1, 1.29, 1.67 ...]
    {
      time = micros();
      volVal = voltAmp * sin(((time-startTime) * frequency) * 2 * pi /1000000);
      // end1 = micros(); 

      _motor->setVoltage(volVal);

      // end2 = micros();

      if(time - printTime >= 10000){ // Print every 10.000 microseconds (10 ms)
        // start3 = micros();
        // Serial.print("VOL,");
        //Serial.print(volVal);
        Serial.print(volVal);
        Serial.print(",");
        Serial.println(_motor->getPosition());
        // Serial.print(_motor->getPosition());
        // Serial.print(",");
        // Serial.println((uint32_t) (time - printTime));
        // Serial.print(",");
        // Serial.print((uint32_t) (end1 - time));
        // Serial.print(",");
        // // Serial.print((uint32_t) (end2 - end1));
        // end3 = micros();
        // Serial.println((uint32_t) (end3 - start3));
        printTime += 10000;
      }
      

      if(time >= endTime)
      {
        j++; 

        if(i < decades - 1 && j == _stepsPerDecade - 1)
        {
          i++;
          j = 0;
        }
        else if(i == decades -1 && j == _stepsPerDecade)
        {
          chirpDone = true;
          Serial.println("Done");
          _motor->setVoltage(0);
        }

        frequency = freq0 * pow(10, i) * ratio[j];
        startTime = endTime; //micros();
        endTime = startTime + 1000000 / frequency;
      }

    }
  }

  

  
}

void Chirp::sineWave(float frequency, float voltAmp)
{
  volVal = voltAmp * sin(frequency / 1000000 * micros() * 2 * pi);
  _motor->setVoltage(volVal);

}

long Chirp::mapf(float x, float in_min, float in_max, long out_min, long out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

bool Chirp::doneChirp()
{
  return chirpDone;
}