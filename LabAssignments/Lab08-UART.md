# RCET 3375 Lab 08 - Asynchronous Serial Communications

> Legacy source: RCET 3375 Experiment 9, `LabAssignments/old/Lab09-UART.pdf`.
>
> This initial draft is a Markdown recreation of the inherited assignment. The lab number has been updated to match the Fall 2026 sequence. Curriculum changes are intentionally deferred to the companion migration plan.

## Goals

The student will be able to:

- Develop the Firmware send and receive asynchronous serial communications from the PIC.

## Tasks

> Include flow charts for each step.

1. Using the serial decode function of your oscill0scope and the Qy@ board code Developed in the VB class. Use an USB to RS232 adapter to measure the receive line of the receive pin of the adapter. Record the waveform and diagram all the bits of the transmission. Explain the correlation between the waveform and your software. Prove you desired Baud Rate using the transmitted signal.
2. Write a program in VB that sends serial to your PIC and controls a servo for 20 (5-25) different positions. Your serial should be set at 9600 baud rate. Hand Shaking between VB and the PIC is required. VB must send a $ followed by the servo data. Verify this with the instructor.
3. Adding to the program above, write the firmware for the PIC to take an ADC sample from your potentiometer, and transmits it to the VB program with 10 bit precision. You must use the A/D interrupt flag. Display the 0 - 1023 count in one label, and the Voltage value in a second label. Step 2 and 3 must work together simultaneously. Hand Shaking between VB and the PIC is required. In this step you must send a $, servo data, and a third Byte of your choice to initiate the ADC to sample. The pic must return a special character followed by the high byte and the low byte of the ADC. - Verify this with the instructor.
4. Measure the serial waveforms from the program above with your Oscope. Include both TX and RX waveforms in your book and explain all the parts of the signal.
5. Replace the potentiometer with a temperature probe provided by the Instructor. Convert the voltage value on the VB form to display the temperature calculated from the probe value.
6. EXTRA CREDIT - Add a second ADC Channel for the Relative Humidity Sensor. Develop the control characters and data bytes to select either temperature, humidity or both (alternating) in VB and display the requested data.
7. Include a screen capture of your completed VB Form showing the Transmitted Value(s).
