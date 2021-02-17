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
    currTime = micros();
    if(currTime - prevTime > 1000)
    {
      endPos = getPosition(); 
      speed = (endPos - startPos) * 1000000 / (currTime - prevTime);
      // Serial.print("T,");
      // Serial.print(currTime - prevTime);
      // Serial.print(",V,");
      // Serial.print(speed);
      // Serial.print(",P,");
      // Serial.println(endPos);
      prevTime = currTime;
      startPos = endPos;
    }

    return speed;
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
    // _pwm = vol/maxVoltage * 255;
    if(vol < 0.01) {
      _pwm = 0;
    }
    else if(vol < 1.875){

      if(abs(getSpeed()) < 5) {
        _pwm = 80;
        // Serial.println("Max");
      }
      else{
        _pwm = (1.2 + 1.2/1.875 * vol)/maxVoltage * 255;
      }
    }
    else if(vol < 3.75){
      _pwm = (2.4 + (vol - 1.875) /1.875 )/maxVoltage * 255;
    }
    else if(vol < 5.625){
      _pwm = ((vol-3.75) / 1.875 * 1.4 + 3.4) / maxVoltage * 255;
    } 
    else{
      _pwm = ((vol-5.625) / 1.875 * 2.7 + 4.8) / maxVoltage * 255;
    }
    // uint8_t pwm = vol / maxVoltage * (255 - 0) + 0; //60
    analogWrite(PWM, _pwm);
    setDirection(sign(voltage));
    // delayMicroseconds(resolution);
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
  switch (switchState)
  {
  case 0:
    if(encALast)
    {
      switchState++;
    }

    if(forw) {
      encALast = true;
      count++;
    }
    else {
      encALast = true;
      count--;
    }
    break;

  case 1:
    if(encALast){
      switchState--;

      if(forw) {
        count--;
      }
      else {
        count++;
      }
    }
    else
    {
      switchState++; 

      if(forw) {
        encALast = true;
        count++;
      }
      else {
        encALast = true;
        count--;
      }
    }

    break;

  case 2:

    if(encALast){
      switchState = 0;

      if(forw) {
        count++;
      }
      else {
        count--;
      }
    }
    else
    {
      switchState = 0; 
    
      if(forw) {
        encALast = true;
        count-= 4;
      }
      else {
        encALast = true;
        count+= 4;
      }

      forw = !forw;
    }
  break;
  
  default:
    break;
  }

  // Serial.println(count * 360.0/48.0/20.0);
  // // Serial.println("A");
  // Serial.print("A,");
  // Serial.print(digitalRead(encA));
  // Serial.print(",B,");
  // Serial.println(digitalRead(encB));
  // if(encALast) {
  //   // Serial.print(digitalRead(encA));
  //   // Serial.print("A");
  //   // Serial.println(digitalRead(encB));
  //   Serial.println("S");
  //   forw = !forw;
  // }
  // else if (forw) {
  //   encALast = true;
  //   count++;
  // }
  // else {
  //   encALast = true;
  //   count--;
  // }
 
}

void Motor::encoderB()
{
  switch (switchState)
  {
  case 0:
    if(!encALast)
    {
      switchState++;
    }

    if(forw) {
      encALast = false;
      count++;
    }
    else {
      encALast = false;
      count--;
    }
    break;

  case 1:
    if(!encALast){
      switchState--;

      if(forw) {
        count--;
      }
      else {
        count++;
      }
    }
    else
    {
      switchState++; 

      if(forw) {
        encALast = false;
        count++;
      }
      else {
        encALast = false;
        count--;
      }
    }

    break;

  case 2:

    if(!encALast){
      switchState = 0;

      if(forw) {
        count++;
      }
      else {
        count--;
      }
    }
    else
    {
      switchState = 0; 
      
      if(forw) {
        encALast = false;
        count-= 4;
      }
      else {
        encALast = false;
        count+= 4;
      }

      forw = !forw;
    }
  break;
  
  default:
    break;
  }

  // Serial.println(count * 360.0/48.0/20.0);
  // Serial.print("A,");
  // Serial.print(digitalRead(encA));
  // Serial.print(",B,");
  // Serial.println(digitalRead(encB));
  // // Serial.println("B");
  // if(!encALast) { 
  //   // Serial.print(digitalRead(encA));
  //   // Serial.print("B");
  //   // Serial.println(digitalRead(encB));
  //   Serial.println("S");
  //   forw = !forw;
  // }
  // else if(forw) {
  //   encALast = false;
  //   count++;
  // }
  // else {
  //   encALast = false;
  //   count--;
  // }
}

int8_t Motor::sign(float number)
{
  return (number >= 0) ? 1 : -1; // If number > 0 then 1 else -1
}