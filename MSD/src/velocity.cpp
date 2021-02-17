#include <file.h>

#ifdef velocity

#include <Arduino.h>
#include <Motor.h>

Motor motor = Motor();
bool forwa = true;

int8_t direc = 1;
unsigned long prevTime = 0;
unsigned long currTime = 0;

void setup() {
  Serial.begin(115200);
  motor.init();

  prevTime = millis();
}

void loop() {

    for (uint16_t i = 0; i <= 10; )
    {
        currTime = millis();
        motor.setVoltage(i/10.0 * direc);
        
        if(currTime - prevTime > 5000)
        {
            prevTime = currTime;
            // Serial.print("Vol,");
            // Serial.print(i/10.0*direc);
            // Serial.print(",vel,");
            Serial.println(motor.getSpeed());

            if(i == 10)
            {
                direc = (direc == 1) ? -1 : 1;
            }
            i++;
        }
    }
   
    // if(forwa) {
    //     for (uint16_t i = 0; i <= 75; i++)
    //     {
    //         motor.setVoltage(i/10.0);
    //         delay(1000);
    //         Serial.print("Vol,");
    //         Serial.print(i/10.0);
    //         Serial.print(",vel,");
    //         Serial.println(motor.getSpeed());
    //     }

    //     // for (uint16_t i = 25; i >= 15; i--)
    //     // {
    //     //     motor.setVoltage(i/10.0);
    //     //     delay(1000);
    //     //     Serial.print("Vol,");
    //     //     Serial.print(i/10.0);
    //     //     Serial.print(",vel,");
    //     //     Serial.println(motor.getSpeed());
    //     // }

    //     motor.setVoltage(0);
    //     forwa = false;  
    //     for (uint16_t i = 0; i < 30; i++)
    //     {
    //         delay(100);
    //         motor.getSpeed();
    //     }
    // }
    // else {
    //     for (uint16_t i = 0; i <= 75; i++)
    //     {
    //         motor.setVoltage(i/-10.0);
    //         delay(1000);
    //         Serial.print("Vol,");
    //         Serial.print(i/-10.0);
    //         Serial.print(",vel,");
    //         Serial.println(motor.getSpeed());
    //     }

    //     // for (uint16_t i = 25; i >= 15; i--)
    //     // {
    //     //     motor.setVoltage(i/-10.0);
    //     //     delay(1000);
    //     //     Serial.print("Vol,");
    //     //     Serial.print(i/-10.0);
    //     //     Serial.print(",vel,");
    //     //     Serial.println(motor.getSpeed());
    //     // }

    //     forwa = true; 
    //     motor.setVoltage(0);
    //     for (uint16_t i = 0; i < 30; i++)
    //     {
    //         delay(100);
    //         motor.getSpeed();
    //     }
    // }
} 

#endif