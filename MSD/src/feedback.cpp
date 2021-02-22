#include <file.h>

#ifdef feedback

#include <Arduino.h>
#include <Motor.h>
#include <Feedback.h>
#include <Prefilter.h>

Motor motor = Motor();
Feedback controller = Feedback(1.883954850884436, -1.819150507119370, -0.391304347826087);
unsigned long before = 0;
unsigned long after = 0;
float reference = 360;
float pos = 0;
float error = 0;
float conVal = 0;

Prefilter pref = Prefilter(1.0, 2200, 10000);

unsigned long time = 0;
unsigned long last = 0;
float tStart = 0;

void setup() {
  Serial.begin(2000000);//115200);
  // motor.init();
  motor.init();
  // motor.setVoltage(0);
  tStart = micros() / 1000000;

}

void loop() {

    time = micros();

    if(time - last > 5000)
    {
        // reference = pref.triangular(time / 1000000.0, tStart);
        // reference = 360;
        reference = pref.stepFilter(time / 1000000.0, tStart);
        // Serial.println(reference);
        pos = motor.getPosition();
        error = reference - pos;
        conVal = controller.controlValue(error);
        // conVal = error / 100.0;
        motor.setVoltage(conVal);
        // Serial.print(100*conVal);
        Serial.print(reference);
        Serial.print(',');
        Serial.println(motor.getPosition());
        // Serial.println(conVal);
        last += 5000;
    }
} 

#endif