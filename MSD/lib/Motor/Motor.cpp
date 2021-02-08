#include <Arduino.h>
#include <Motor.h>
#include <PinLayout.h>

Motor::Motor()
{
}

void Motor::init()
{
    // Set driver pins to OUTPUT.
    pinMode(dir1, OUTPUT);
    pinMode(dir2, OUTPUT);
    pinMode(PWM, OUTPUT);

    // Encoder pins as input with interrupts.
    pinMode(encA, INPUT_PULLUP);
    pinMode(encB, INPUT_PULLUP);

    attachInterrupt(digitalPinToInterrupt(encA), encoderA, CHANGE);
    attachInterrupt(digitalPinToInterrupt(encB), encoderB, CHANGE);

    // Start with this direction.
    digitalWrite(dir1, HIGH);
    digitalWrite(dir2, LOW);
    }

float Motor::getPosition()
{
    return _posRat * count;
}

float Motor::getSpeed()
{
    return 0.0f;
}

void Motor::resetPosition()
{
    count = 0;
}

void Motor::setDirection(int8_t sign)
{
  if(sign != prevSign)
  {
    prevSign = sign;
    reverse();
  }
}

void Motor::setVoltage(float voltage)
{
    float vol = min(maxVoltage, abs(voltage));
    uint8_t pwm = vol / maxVoltage * 255;
    analogWrite(PWM, pwm);
    Serial.print("PWM,");
    Serial.print(pwm);
    setDirection(sign(voltage));
    Serial.print(",Sign,");
    Serial.println(100* prevSign);
}

void Motor::reverse()
{
    if(dir)
    {
        digitalWrite(dir1, LOW);
        digitalWrite(dir2, HIGH); 
        dir = !dir;
    }
    else
    {
        digitalWrite(dir1, HIGH);
        digitalWrite(dir2, LOW); 
        dir = !dir;
    }
}

void Motor::encoderA()
{
  if(encALast) 
    forw = !forw;
  else 
    encALast = true;
  
  if(forw) 
    count++;
  else 
    count--;
}

void Motor::encoderB()
{
  if(!encALast) 
    forw = !forw;
  else 
    encALast = false;
  
  if(forw) 
    count++;
  else 
    count--;
} 

int8_t Motor::sign(float number)
{
  return (number >= 0) ? 1 : -1; // If number > 0 then 1 else -1
}