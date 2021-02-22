#include <file.h>

#ifdef feedforward

#include <Arduino.h>
#include <Motor.h>
#include <Feedforward.h>
#include <Prefilter.h>

Motor motor = Motor();
Feedforward controller = Feedforward(0.490763514363140, -0.925564579400007, -0.055218791365095, 0.925564579400007, -0.435544722998045, 
                                      -3.272727272727273, 4.016528925619836, -2.190833959429002, 0.448125128065023);
unsigned long before = 0;
unsigned long after = 0;
float reference = 360;
float pos = 0;
float error = 0;
float conVal = 0;

Prefilter pref = Prefilter(1.0, 2000, 10000);

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


    if(time - last > 2000)
    {   
        reference = pref.triangular(time / 1000000.0, tStart);
        // reference = pref.stepFilter(time / 1000000.0, tStart);
        conVal = controller.controlValue(reference);
        // conVal = reference / 50.0;
        motor.setVoltage(conVal);
        Serial.print(reference);
        // Serial.print(conVal);
        Serial.print(',');
        Serial.println(motor.getPosition());
        // Serial.println(conVal);
        // Serial.println(conVal);
        last += 2000;
    }
} 

#endif