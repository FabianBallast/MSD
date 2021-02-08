#include <Arduino.h>
#include <Motor.h>

Motor motor = Motor();
// Test2
void setup() {
  Serial.begin(9600);
  motor.init();
  motor.setVoltage(3.0);
}

void loop() {

  delay(1000);
  motor.reverse();
  Serial.println(motor.getPosition());
} //test
