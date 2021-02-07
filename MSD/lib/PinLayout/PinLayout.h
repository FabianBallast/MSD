#ifndef PinLayout_h
#define PinLayout_h

/// \mainpage File to manage the pins for all files.
///
/// In short, the Arduino requires 8 connections:
///
///         - Two connections for the output of the encoders. Must be with interrupts!
///         - Two connections to change the direction of the motor.
///         - One with PWM to control the voltage (and thus speed).
///         - One with 5V for the encoders.
///         - Two with GND for the encoders and the L298N (motor driver) for common ground.
///
/// The motor has 6 wires:
///         - Yellow: Connect to driver terminal to drive motor.
///         - Red: Connect to 5V (Arduino)
///         - Green: Output of Encoder 1.
///         - White: Output of Encoder 2.
///         - Black: Connect to GND (Arduino).
///         - Brown: Connect to driver terminal to drive motor.


// Only two pins with interrupts on UNO. Do not change!
// The white and green wires from the motor.
#define encA 2
#define encB 3 

// Two for the direction of the motor. Can be any digital pin.
// Connect to IN1 and IN2 on driver.
#define dir1 10
#define dir2 11

// One for PWM signal. On UNO, either 3, 5, 6, 9, 10 or 11 (3 must be interrupt!).
// Connect to ENA on driver.
// Keep this on 9 for the chirp signal.
#define PWM 9

#endif