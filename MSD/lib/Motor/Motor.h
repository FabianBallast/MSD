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
        const uint8_t _ticksPerRotation = 48;
        const float _posRat = 360.0 / _ticksPerRotation / _gearRatio;

        bool dir = true;
        const float maxVoltage = 7.5;

        static void encoderA();
        static void encoderB();
};

#endif