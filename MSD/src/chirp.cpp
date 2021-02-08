#include <file.h>

#ifdef chirpFile

#include <Arduino.h>
#include <Motor.h>
#include <Chirp.h>

Motor motor = Motor();
Chirp chirp = Chirp(&motor, 10);

void setup() {
  Serial.begin(115200);
  chirp.init();
}

void loop() {

    chirp.chirpSignal(0.1, 10, 5);
//   delay(1000);
//   motor.reverse();
//   Serial.println(motor.getPosition());
} 

#endif