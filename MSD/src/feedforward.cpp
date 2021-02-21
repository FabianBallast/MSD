#include <file.h>

#ifdef feedforward

#include <Arduino.h>
#include <Motor.h>
#include <Feedforward.h>
#include <Prefilter.h>

Motor motor = Motor();
Feedforward controller = Feedforward(0.291704805454171, -0.542724290021949, -0.039266681816450, 0.542724290021949, -0.252438123637721, 
                                      -2.913958014690934, 3.184181741768074, -1.546428651109603, 0.281639260128032);
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
        reference = pref.stepFilter(time / 1000000.0, tStart);
        conVal = controller.controlValue(reference);
        motor.setVoltage(conVal);
        Serial.print(reference);
        Serial.print(',');
        Serial.println(motor.getPosition());
        // Serial.println(conVal);
        last += 5000;
    }
} 

#endif