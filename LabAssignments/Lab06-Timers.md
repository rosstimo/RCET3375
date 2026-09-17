# RCET 3375 Lab 06 - Timers - Intersection Control

> Legacy source: RCET 3375 Experiment 7, `LabAssignments/old/Lab07-Timers.pdf`.
>
> This initial draft is a Markdown recreation of the inherited assignment. The lab number has been updated to match the Fall 2026 sequence. Curriculum changes are intentionally deferred to the companion migration plan.

## Goals

The student will be able to:

- Develop the Firmware to accurately monitor and control an intersection utilizing timers.

## Background Information

In the last experiment, interrupts were employed to notify the CPU of an external device or process needing service. In this lab you will be using timers and interrupts together. Timers replace delays that waste time, and stop the processor from performing other task. Depending on the timer, they will count from 00 to FF, or 0000 to FFFF. When the timer goes from FF to 00 it will overflow and cause an interrupt.

## Tasks

> Use timer 2, the timer should interrupt 240 times to complete the cycle.

1. Draw the flowchart, write a program and interface to the PIC, to control a street light for two directions. North/South (N/S) and East/West (E/W).

   If there are cars in both directions or no cars in either direction the lights will give equal time to both directions. Equal time should be 5 seconds green, 1 second yellow, then switch directions and repeat.

   If there are cars in only one direction, the lights will allow that direction to go (in 5 second intervals) until the cars in that direction have all gone or until a car comes in the other direction. Any car must be sensed even if it is only on the sensor for 20 milliseconds.

   Connect one set of lights, red, yellow, and greet, to an output port and a switch as a car sensor to an input port for each direction. Breadboard the lights, switches, and any other circuitry onto the Breadboard.

   Include input and output bit-maps, and a complete schematic in your documentation.

2. Demonstrate the finished product to the instructor.
