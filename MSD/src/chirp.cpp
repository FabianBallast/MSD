#include <file.h>

#ifdef chirpFile

#include <Arduino.h>
#include <Motor.h>
#include <Chirp.h>

Motor motor = Motor();
Chirp chirp = Chirp(&motor, 10);

unsigned long before = 0;
unsigned long after = 0;

void setup() {
  Serial.begin(2000000);//115200);
  // motor.init();
  chirp.init();
  // motor.setVoltage(0);
}

void loop() {
    // chirp.sineWave(0.1, 7.5);
    
    while(!chirp.doneChirp())
    {
      Serial.println("Start");
      chirp.chirpSignal(0.01, 100, 7.5, 100);
    }
//   delay(1000);
//   motor.reverse();
//   Serial.println(motor.getPosition());
} 

#endif