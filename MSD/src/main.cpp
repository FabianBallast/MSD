#include <Arduino.h>
#include <Motor.h>

Motor motor = Motor();

void setup() {
  Serial.begin(9600);
  motor.init();
  motor.setVoltage(3.0);
}

void loop() {

  delay(1000);
  motor.reverse();
  Serial.println(motor.getPosition());
}