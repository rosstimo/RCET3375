# RCET 3375 Lab 07 - ADC Servo Control

> Legacy source: RCET 3375 Experiment 8, `LabAssignments/old/Lab08-ADC.pdf`.
>
> This initial draft is a Markdown recreation of the inherited assignment. The lab number has been updated to match the Fall 2026 sequence. Curriculum changes are intentionally deferred to the companion migration plan.

## Goals

The student will be able to:

- Develop the Firmware to accurately read and handle an ADC signal from the PIC.
- Develop the Firmware to control a servo motor using a Timer.

## Background Information

A servo uses a 20ms period as the input signal. Some can work down to 10 to 15ms, but the standard is 20ms. There are two types of servos; standard and continuous servos. Standard servos, for the most part, can rotate 180 degrees. If a range of 1 to 2ms is used then the servo should rotate 90 degrees. An on time of 1.5ms puts the servo in the center. To use 180 degrees a time of .5 to 2.5ms needs to be used. Some servos many very. A continuous servo uses the same signal but a 1ms on time turns CCW and 2ms turns CW. A 1.5ms pulse stops the rotation. Many other controls in the lab use the same signal to drive them; ESC and H bridge controllers.

## Tasks

1. Write a program that reads an A/D input and displays the 8 MSB out a port to 8 LED's. - Verify this with the instructor.
2. Using the program above, write a program that takes the A/D in and controls a servo with 15 different positions using the MSB. Increment in 100 us steps only. - Verify this with the instructor.

Include flow charts.
