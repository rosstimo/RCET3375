<a id="top"></a>

# RCET 3375 Lab 10 - I2C Communication

[RCET3375 course home](https://github.com/rosstimo/RCET3375) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

PIC16F883 | pic-as | MSSP / I2C | UART | Multi-device communication

> **Release status:** Part 1 is the current assignment. Parts 2–5 are draft outlines; their requirements may change before they are assigned.

## Contents

- [Purpose](#purpose)
- [Standards and references](#references)
- [Equipment and materials](#equipment)
- [Part 1 - I2C Master and Bus Timing](#part-1)
- [Part 2 - Sensor Communication and Reusable Master Routines](#part-2)
- [Part 3 - Reusable PIC I2C Slave Routines](#part-3)
- [Part 4 - UART-to-I2C System Integration](#part-4)
- [Part 5 - Mastery: Three-Axis Servo Control](#part-5)
- [Submission and checkoff](#submission)

<a id="purpose"></a>
## Purpose

Use the PIC16F883 MSSP peripheral for I2C communication. Begin with an address-only master transaction and measurements of the two-wire bus. Later parts add an external sensor, a second PIC operating as a slave, and UART integration.

**Repository setup:** Create one Git repository for Lab 10. Add the [student lab ``.gitignore` template](https://github.com/rosstimo/RCET3375/blob/main/HowTo/Student-Lab-Repository.gitignore) before staging project files. Keep complete MPLAB X projects and follow the [Lab Standard's repository rules](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md#assignment-repository-standard).

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="references"></a>
## Standards and references

- [RCET 3375 Lab Standard](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md): lab book, SFR maps, schematics, electrical checks, measurements, and submission.
- [RCET PIC-AS Style Guide](https://github.com/rosstimo/RCET3375/blob/main/Notes/RCET_PIC-AS_Style_Guide.md) and [PIC-AS project setup](https://github.com/rosstimo/RCET3375/blob/main/HowTo/PIC-AS-Project-Setup.md).
- [PIC16F882/883/884/886/887 data sheet (DS40001291H)](https://ww1.microchip.com/downloads/en/DeviceDoc/40001291H.pdf): PIC16F883 pinout, MSSP/I2C master registers (Section 13), Timer1 (Section 6), and electrical limits.
- [PIC16F88X silicon errata](https://ww1.microchip.com/downloads/aemDocuments/documents/MCU08/ProductDocuments/Errata/PIC16F88X-Family-Si-Errata-Data-Sheet-Clarifications-DS80000302.pdf): device-revision limitations and MSSP clarifications.
- [PICmicro Mid-Range MCU Family Reference Manual (DS33023A)](https://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf), especially [Section 17: MSSP](https://ww1.microchip.com/downloads/en/DeviceDoc/31017a.pdf): I2C timing, START/STOP sequences, electrical connections, and master/slave operation.
- [AN735: Using the PICmicro MSSP Module for Master I2C Communications](https://ww1.microchip.com/downloads/en/AppNotes/00735a.pdf) ([application note and source-code downloads](https://www.microchip.com/en-us/application-notes/an735)): master setup and transmission examples.
- [AN734: Using the PICmicro for Slave I2C Communication (original)](https://ww1.microchip.com/downloads/en/appnotes/00734a.pdf): interrupt-driven slave assembly example in Appendix A for later parts.
- [AN734: Slave I2C Communication (revised)](https://ww1.microchip.com/downloads/aemDocuments/documents/MCU08/ApplicationNotes/ApplicationNotes/00000734C.pdf) ([application note and source-code downloads](https://www.microchip.com/en-us/application-notes/an734)): flowcharts and code examples for newer PIC hardware; adapt register details to the PIC16F883.
- [TB3252: Using the MSSP in I2C Master Mode](https://www.microchip.com/en-us/application-notes/tb3252): master operation and pull-up considerations on newer devices.
- [AN736: An I2C Network Protocol for Environmental Monitoring](https://www.microchip.com/en-us/application-notes/an736): application-level communication example for later parts.
- [I2C-bus specification (NXP UM10204)](https://www.nxp.com/docs/en/user-guide/UM10204.pdf): Standard-mode electrical timing, pull-up calculations, and waveform definitions.
- [Lab 08 - UART](https://github.com/rosstimo/RCET3375/blob/main/LabAssignments/Lab08-UART.md): UART packets, host GUI, ADC, and servo integration in later parts.
- Manufacturer's data sheet for the supplied I2C sensor module (later parts).

Use the PIC16F883 data sheet for device-specific register settings and limits. The application notes and family manual provide implementation examples.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="equipment"></a>
## Equipment and materials

**Part 1:** One PIC16F883 minimum circuit with a 4 MHz crystal, 5 V supply, PICkit 3 (or equivalent), MPLAB X/pic-as, two 4.7 kΩ I2C pull-up resistors, breadboard components, multimeter, and an oscilloscope with I2C decoding. Provide scope access to RC3/SCL, RC4/SDA, and RA0.

**Later parts:** A second PIC16F883 circuit, supplied I2C sensor breakout and input source, Lab 08 UART host application and serial adapter, ADC sensor and servo components, and optional Mastery hardware.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-1"></a>
## Part 1 - I2C Master and Bus Timing

### Goal

Use one PIC16F883 as a 100 kHz I2C master. Send a periodic address-only write transaction with no slave connected. Detect the expected NACK, generate STOP, and measure the bus waveforms.

### Required behavior

- Use a **4 MHz crystal** and a **5 V** PIC16F883 circuit. Connect **RC3/SCL (pin 14)** and **RC4/SDA (pin 15)** to 5 V through **separate 4.7 kΩ pull-up resistors**. Leave the I2C bus without a slave for this part. Configure the pins for MSSP open-drain operation.
- Configure the MSSP for **7-bit I2C master mode at 100 kHz**. Address **`0x20`** with **R/W = 0**. The address and R/W bit form the transmitted byte **`0x40`** (`0100 0000` binary).
- For every probe, generate **START**, send the address/R-W byte, read the **ACK/NACK** result, and generate **STOP**. With no slave, the ninth clock pulse must show a NACK (SDA HIGH).
- Use **Timer1 with the internal instruction clock and a 1:8 prescaler**, polling its overflow flag to start a new probe about every **524 ms**. No Timer1 interrupt is needed.
- Use **RA0 (pin 2)** as a NACK indicator. Clear RA0 at the beginning of each probe; make it HIGH if the slave does not acknowledge. Leave it LOW for ACK. Complete the transaction with STOP in either case.

### Before Lab

Prepare the following in the lab book before constructing the circuit:

- A schematic with the PIC power, reset, oscillator, programming connections, separate SDA/SCL pull-ups, and RA0 diagnostic connection. Account for every used pin and component as required by the [Lab Standard](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md).
- PIC16F883 SFR documentation for MSSP master setup, START/STOP control, address transmission, completion and ACK status, Timer1 overflow, and the I/O configuration used here. Include the relevant register maps and the values you plan to use.
- Natural-language flowcharts for the main loop and **AddressProbe** subroutine. Show the timer trigger, START, address transmission, NACK decision, STOP, and return.
- Predicted SCL clock period and frequency, Timer1 probe interval, bus LOW current, and SDA/SCL rise time. Use a stated bus-capacitance estimate and compare the expected timing with Standard-mode limits.

**MSSP timing example:** For a 4 MHz oscillator and 100 kHz I2C clock, find the master baud-rate value using the data sheet equation.

```math
\begin{aligned}
f_{\mathrm{SCL}} &= \frac{F_{\mathrm{OSC}}}{4(\mathrm{SSPADD}+1)}\\
\mathrm{SSPADD} &= \frac{F_{\mathrm{OSC}}}{4f_{\mathrm{SCL}}}-1\\
&=\frac{4{,}000{,}000\ \mathrm{Hz}}{4(100{,}000\ \mathrm{Hz})}-1\\
&=10-1=9\\
T_{\mathrm{SCL}} &= \frac{1}{100{,}000\ \mathrm{Hz}}
=10\ \mu\mathrm{s}
\end{aligned}
```

**Timer1 interval example:** With the internal instruction clock, a 1:8 prescaler, and no preload, calculate the period of one 16-bit Timer1 rollover.

```math
\begin{aligned}
f_{\mathrm{instruction}} &= \frac{4{,}000{,}000\ \mathrm{Hz}}{4}
=1{,}000{,}000\ \mathrm{Hz}\\
T_{\mathrm{instruction}} &= \frac{1}{1{,}000{,}000\ \mathrm{Hz}}
=1\ \mu\mathrm{s}\\
T_{\mathrm{tick}} &= 8(1\ \mu\mathrm{s})=8\ \mu\mathrm{s}\\
T_{\mathrm{overflow}} &= 65{,}536(8\ \mu\mathrm{s})\\
&=524{,}288\ \mu\mathrm{s}
=524.288\ \mathrm{ms}
\end{aligned}
```

**Pull-up example:** Estimate the current in one 4.7 kΩ pull-up when its bus line is LOW. For the example, assume a 5 V supply and a 0.4 V LOW level. Compare with the applicable device sink-current limit.

```math
\begin{aligned}
I_{\mathrm{pullup}} &= \frac{V_{\mathrm{DD}}-V_{\mathrm{OL}}}{R_{\mathrm{P}}}\\
&=\frac{5.0\ \mathrm{V}-0.4\ \mathrm{V}}{4{,}700\ \Omega}\\
&=\frac{4.6\ \mathrm{V}}{4{,}700\ \Omega}\\
&=0.000979\ \mathrm{A}\approx 0.98\ \mathrm{mA}
\end{aligned}
```

Estimate the rise time between 30% and 70% of the supply using the I2C-bus RC approximation. The **100 pF** bus capacitance below is an example assumption, not a measured value.

```math
\begin{aligned}
t_{\mathrm{r}} &\approx 0.8473R_{\mathrm{P}}C_{\mathrm{bus}}\\
&\approx 0.8473(4{,}700\ \Omega)(100\times10^{-12}\ \mathrm{F})\\
&=3.98231\times10^{-7}\ \mathrm{s}\\
&\approx 398\ \mathrm{ns}
\end{aligned}
```

Standard-mode I2C specifies a **maximum 1000 ns rise time**. Use your actual resistor values and a justified capacitance estimate for the prelab prediction. Check the bus electrical limits and compare the rise-time prediction with what you measure. A bus with no slave still has wiring, pin, and probe capacitance.

### Required setup

```text
MSSP:
    Set up I2C master operation at 100 kHz
    Enable the peripheral for SDA and SCL

Timer1:
    Use the internal instruction clock with an eight-to-one prescaler
    Clear the timer and its overflow indication, then start it

I/O:
    Set RA0 as a digital output for the NACK indicator
    Configure the other used pins for their required functions

Startup:
    Initialize the NACK indicator LOW
```

### Program structure

```text
Main:
    Wait for a Timer1 overflow
    Clear the overflow indication
    Call AddressProbe
    Repeat

AddressProbe:
    Clear the NACK indicator
    Generate a START condition and wait until it completes
    Send the slave address with the write bit and wait until the byte is sent
    Check the acknowledge result
    If the result is NACK, turn on the NACK indicator
    Generate a STOP condition and wait until it completes
    Return
```

### In the Lab

1. Build the circuit from the checked schematic. Verify 5 V supply, common ground, SDA/SCL connections, and both pull-ups before programming the PIC. No other I2C device should be connected.
2. Compile, program, and run the master firmware. Probe **CH1 = SCL**, **CH2 = SDA**, and **CH3 = RA0**. Configure the oscilloscope's I2C decoder for **7-bit addressing** and trigger on START. If the decoder displays raw 8-bit address/R-W values, identify the distinction in your evidence.
3. Capture one complete transaction. Label START, the **seven address bits**, R/W, all **nine SCL pulses**, the HIGH SDA level during NACK, and STOP. Verify that RA0 indicates NACK and the next transaction starts after the Timer1 interval.
4. Zoom into the clocks and measure **SCL frequency/period, HIGH and LOW durations, and SDA and SCL rise times**. Measure rise time from **30% to 70%** of the signal swing. Record bus HIGH and LOW voltage levels. Compare timing and levels with your calculations and the device and I2C specifications.
5. Measure the interval between consecutive START conditions and explain any difference from the calculated Timer1 rollover period.
6. With power off, remove **one pull-up resistor at a time**, restore power, and observe the affected line. Record what changes, including any unreliable or missing HIGH level or failed transaction. Restore both resistors with power off and confirm the normal NACK transaction returns. Do not treat a seemingly working floating line as a valid I2C connection.

### Evidence

Include the schematic and component/loading checks, complete MSSP/Timer1/I/O SFR documentation, flowcharts, final pic-as source, and the calculation steps and predictions.

Provide labeled scope captures showing:

- A complete decoded address-only transaction (START, address `0x20`, R/W = 0, ninth-bit NACK, STOP) with RA0.
- Expanded SCL/SDA timing with measured frequency, clock HIGH/LOW times, rise times, and voltage levels.
- Consecutive transactions with a measured START-to-START interval.
- The pull-up removal observations and the restored normal waveform.

For each measurement, record the predicted value, measured value, and an explanation of any significant difference. Include the I2C decoder setting so that `0x20` (7-bit address) and `0x40` (address/R-W byte) are not confused.

### Demonstrate

Show the periodic START/address/NACK/STOP sequence with the oscilloscope decoder and explain the nine clock pulses. Demonstrate RA0's NACK indication, compare the measured bus clock and probe interval with your calculations, and explain how the pull-up resistors produce HIGH levels on an open-drain bus.

### Complete When

A PIC16F883 master repeatedly sends the specified address with no slave, detects NACK, and completes STOP. The waveforms, electrical calculations, timing comparisons, pull-up observations, source code, and lab-book evidence are complete and ready for instructor checkoff.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-2"></a>
## Part 2 - Sensor Communication and Reusable Master Routines

### Goal

Communicate with the supplied I2C sensor and control transactions through a minimal UART host GUI. Complete reusable I2C master routines with error handling.

### Before Lab

Document the sensor's address and register protocol, proposed structured UART request/result/error packets, master routine flowcharts, and expected bus transactions. Plan the parallel pull-up resistor experiment.

### In the Lab

Read and write the sensor as supported by its data sheet, including multi-byte and repeated-START transactions where needed. Display results and transactions in the GUI. Abort failed I2C operations and return their status to the host. Add pull-up resistors in parallel, calculate equivalent resistance and LOW-state current, and measure SDA/SCL rise time and LOW voltage. Account for pull-ups already installed on breakout boards.

### Evidence

Provide the UART packet definitions, working master routines, sensor transactions and labeled I2C captures, an error test, and pull-up resistance/current/rise-time calculations compared with measurements.

### Demonstrate

Show working sensor communications and error reporting. Explain how additional breakout-board pull-ups and bus capacitance affect electrical timing and loading.

### Complete When

The GUI can command and read the sensor through a reusable master I2C interface, and the pull-up investigation is documented.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-3"></a>
## Part 3 - Reusable PIC I2C Slave Routines

### Goal

Configure a second PIC16F883 as an interrupt-driven I2C slave. Read PORTB, write available PORTC outputs, and report slave status using reusable communication routines.

### Before Lab

Document slave MSSP setup, addressing, interrupt behavior, clock stretching, errors and recovery. Define the minimal slave command/status interface and flowcharts. Investigate general call, masked addresses, and effects on every connected slave.

### In the Lab

Use the Part 2 master and GUI to read the slave's PORTB inputs and write its PORTC outputs. Reserve RC3 and RC4 for I2C. Use PORTA diagnostic signals as needed. Handle master reads/writes, ACK/NACK, overflow, collision and communication recovery. Make slave errors available through a status read. Examine safe broadcast/general-call behavior.

### Evidence

Provide the slave interface and firmware/flowcharts, working PORTB/PORTC transactions, a slave-status/error test and labeled oscilloscope diagnostics.

### Demonstrate

Read changing PORTB inputs, update PORTC outputs, read error status, and show the slave recovers after a communication fault. Explain general-call and group-address precautions.

### Complete When

The slave's reusable interrupt routines reliably support master reads, writes, status and error handling.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-4"></a>
## Part 4 - UART-to-I2C System Integration

### Goal

Finish the host GUI and multi-device communication system. The master communicates with both the external sensor and the PIC slave; the PIC slave provides an ADC channel and one servo.

### Before Lab

Prepare the complete UART and PIC-slave application packet definitions, integration flowcharts, system schematic, log layouts and failure-test plan. Reuse the ADC and servo behavior from Lab 08 Part 4.

### In the Lab

Integrate sensor polling, slave ADC measurements, servo commands, GUI controls, device status, and error handling. Record sensor readings with year/month/day/hour/minute/second timestamps in files rotated hourly. Keep a separate timestamped UART/I2C error log with new files every 24 hours. Log each serial disconnect and verified reconnect once per transition. Verify recovery and servo timing during ongoing communication.

### Evidence

Provide the final firmware and GUI, packet definitions, schematics, scope captures, sensor and error log samples, file-rotation evidence, and disconnect/reconnect tests.

### Demonstrate

Show both sensors, servo control, live GUI operation, logged data and errors, and recovery from deliberately interrupted I2C and UART communication.

### Complete When

The complete system runs with both slaves, correctly reports errors, preserves servo timing and meets the logging and reconnection requirements.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-5"></a>
## Part 5 - Mastery: Three-Axis Servo Control

### Goal

Extend the system with three independent servos and a three-axis I2C compass or IMU.

### Before Lab

Select and document the sensor, axis-to-servo mapping, limits, scheduler changes and verification plan.

### In the Lab

Acquire all three axes and command the corresponding servos while maintaining the required servo period, communication and error handling.

### Evidence

Provide the updated schematic, packet/axis mapping, firmware and GUI changes, motion and timing captures, and error tests.

### Demonstrate

Show independent response of all three servos to the three measurements without interrupting the other system functions.

### Complete When

All three channels operate correctly and the multi-device system remains functional. Mastery earns the extra credit described in the [Lab Standard](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md).

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="submission"></a>
## Submission and Checkoff

Maintain one Git repository for the assignment. Submit working projects, schematic files, source, flowcharts, measured evidence and lab-book PDF according to the [Lab Standard](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md). Parts 1-4 are required; Part 5 is optional Mastery.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)
