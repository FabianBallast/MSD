#include <Arduino.h>

#define DIR1 10
#define DIR2 11
#define PWM 9

void setup() {
  pinMode(DIR1, OUTPUT);
  pinMode(DIR2, OUTPUT);
  pinMode(PWM, OUTPUT);

  digitalWrite(DIR1, HIGH);
  digitalWrite(DIR2, LOW);
}

void loop() {

 analogWrite(PWM, 100); 
}