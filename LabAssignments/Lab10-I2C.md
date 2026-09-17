# RCET 3375 Lab 10 - I2C Servo Control

> Legacy source: RCET 3375 Experiment 11, `LabAssignments/old/Lab11-I2C.pdf`.
>
> This initial draft is a Markdown recreation of the inherited assignment. The lab number has been updated to match the Fall 2026 sequence. Curriculum changes are intentionally deferred to the companion migration plan.

## Goals

The student will be able to:

- Write and troubleshoot programs to send and receive data on the I2C bus, and use that data to control 3 servos from 3 potentiometers.

## Tasks

> Include flow charts for each step.

1. Program the Pic16f883 so that it is in I2C slave mode with an address of 0x20. Have three servos that are controlled with the slave. Each servo should have independent control values. Every time an address byte is sent only one data packet will be sent with it. Each data byte will contain 5 bits of data and 3 bits of controlling of which servo was sent.
2. Program another 883 in Master mode so that it can talk to the other pic. The master pic should read in three different analog values from different potentiometers. Each potentiometer will control one of the servos on the slave.
3. Probe the data and clock lines with the oscilloscope. Use the I2C module in the scope to view the signals. Be able to identify and describe each section of the signal and what it is doing.
4. Document your final code for both IC's.

Demonstrate to the instructor before signing check off.
