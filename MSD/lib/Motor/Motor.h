#ifndef Motor_h
#define Motor_h

#include <PinLayout.h>
#include <Arduino.h>

/// \mainpage Library to control the motor. 
///
/// This library can be used to control the motor. Set input voltage, get its position or speed.

/// \class Motor Motor.h <Motor.h> 
/// \brief Support for control of the motor. 
/// 
/// This defines the entire object used to control the motor.  

volatile static int32_t count = 0;
volatile static bool forw = true;
volatile static bool encALast = true;
volatile static uint8_t switchState = 0;
// volatile static unsigned long prevTime = 0;
// volatile static unsigned long currTime = 0;
// volatile static float speed = 0; 


class Motor
{   
    public:
        /// Create a motor object.
        Motor();

        /// Initialize all the pins.
        void init();

        /// Return the position of the motor in degrees.
        /// \returns Float with position of shaft in degrees.
        float getPosition();

        /// Return the speed of the motor in rad/s.
        /// \returns Float with speed of shaft in rad/s.
        float getSpeed();

        /// Reset the position back to zero.
        void resetPosition();

        /// Set the voltage over the motor. Min is 0 V, max is 7.5 V.
        /// \param[in] voltage Voltage across the motor.
        void setVoltage(float voltage);

        /// Reverse the direction of the motor.
        void reverse();

    
    private:
        const uint8_t _gearRatio = 20;
        const uint8_t _ticksPerRotation = 52;
        const float _posRat = 360.0 / _ticksPerRotation / _gearRatio;

        bool dir = true;
        const float maxVoltage = 7.5;
        const int8_t resolution = 1;

        float speed=  0;
        unsigned long currTime = 0;
        unsigned long prevTime = 0;
        float startPos;
        float endPos;

        uint8_t _pwm;


        int8_t prevSign = 1;

        static void encoderA();
        static void encoderB();

        /// Set the direction of the motor depending on the sign of the voltage.
        /// \param[in] sign Sign of the voltage. >0 = 1, <0 = -1.
        void setDirection(int8_t sign);

        /// Returnt the sign of the voltage.
        int8_t sign(float number);
};

#endif