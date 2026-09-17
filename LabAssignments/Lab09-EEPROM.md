# RCET 3375 Lab 09 - EEPROM

> Legacy source: RCET 3375 Experiment 10, `LabAssignments/old/Lab10-EEPROM.pdf`.
>
> This initial draft is a Markdown recreation of the inherited assignment. The lab number has been updated to match the Fall 2026 sequence. Curriculum changes are intentionally deferred to the companion migration plan.

## Goals

The student will be able to:

- Write and troubleshoot a program that saves data in the EEPROM and the recalls the data and displays it on a dot-matrix display.

## Tasks

> Include flow charts for each step.

This lab requires the Start, Stop, and Record to be separate push buttons that are not part of the keypad.

1. Write a program that waits for a start recording switch to be pressed and blinks a "S" at one second intervals while it waits. Once the record button is pressed, any time a key is pressed on the keypad the dot-matrix equivalent is recorded into EEPROM. It should record up to 10 values or stop recording when the stop button is pressed. The program should keep track of how many buttons were pressed.
2. Restart the chip by removing power and reapplying it. Once cycled, press the play button and the dot-matrix should display the values recorded for 1 second each. When finished displaying the values the display should blink "S" for start. Recording can happen many times not just once.

Demonstrate to the instructor before signing check off.
