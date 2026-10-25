<a id="top"></a>

# RCET 3375 Lab 10 - I2C Communication

[RCET3375 course home](https://github.com/rosstimo/RCET3375) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

PIC16F883 | pic-as | MSSP / I2C | UART | Multi-device communication

> Working draft. Parts are being developed and released individually.

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

Configure the PIC16F883 as an I2C master and slave, verify bus operation with oscilloscope measurements, and use UART and I2C to communicate with multiple devices.

**Repository setup:** Use one Git repository for Lab 10. Add the [student lab `.gitignore` template](https://github.com/rosstimo/RCET3375/blob/main/HowTo/Student-Lab-Repository.gitignore) before staging project files. Follow the [Lab Standard](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md).

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="references"></a>
## Standards and references

- [RCET 3375 Lab Standard](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md): lab book, SFR maps, schematics, measurements and submission.
- [RCET PIC-AS Style Guide](https://github.com/rosstimo/RCET3375/blob/main/Notes/RCET_PIC-AS_Style_Guide.md) and [PIC-AS project setup](https://github.com/rosstimo/RCET3375/blob/main/HowTo/PIC-AS-Project-Setup.md).
- [PIC16F882/883/884/886/887 data sheet](https://ww1.microchip.com/downloads/en/DeviceDoc/40001291H.pdf): MSSP and I2C register operation, pin functions and electrical limits.
- [PIC16F88X silicon errata](https://ww1.microchip.com/downloads/aemDocuments/documents/MCU08/ProductDocuments/Errata/PIC16F88X-Family-Si-Errata-Data-Sheet-Clarifications-DS80000302.pdf): MSSP limitations and device revisions.
- [PICmicro Mid-Range MCU Family Reference Manual (DS33023A)](https://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf), especially [Section 17: MSSP](https://ww1.microchip.com/downloads/en/DeviceDoc/31017a.pdf): I2C master/slave operation, timing diagrams, bus connections and initialization; Appendix A introduces the I2C bus.
- [AN735: Using the PICmicro MSSP Module for Master I2C Communications](https://ww1.microchip.com/downloads/en/AppNotes/00735a.pdf) ([application note and source-code downloads](https://www.microchip.com/en-us/application-notes/an735)): master setup and operations, with assembly code examples.
- [AN734: Using the PICmicro for Slave I2C Communication (original)](https://ww1.microchip.com/downloads/en/appnotes/00734a.pdf): ISR-based slave implementation with assembly source in Appendix A.
- [AN734: Slave I2C Communication (revised)](https://ww1.microchip.com/downloads/aemDocuments/documents/MCU08/ApplicationNotes/ApplicationNotes/00000734C.pdf) ([application note and source-code downloads](https://www.microchip.com/en-us/application-notes/an734)): master/slave assembly and C examples with slave flowcharts in Appendix A; targets newer PIC hardware.
- [TB3252: Using the MSSP in I2C Master Mode](https://www.microchip.com/en-us/application-notes/tb3252): bus timing, pull-up selection, and polling-based master C examples for newer PIC devices.
- [AN736: An I2C Network Protocol for Environmental Monitoring](https://www.microchip.com/en-us/application-notes/an736): example of an application-level protocol built on I2C.
- [I2C-bus specification (NXP)](https://www.nxp.com/docs/en/user-guide/UM10204.pdf): bus timing, addressing and pull-up calculations.
- [Lab 08 - UART](https://github.com/rosstimo/RCET3375/blob/main/LabAssignments/Lab08-UART.md): UART packets, host GUI, ADC and servo integration.
- Manufacturer's data sheet for the supplied I2C sensor module.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="equipment"></a>
## Equipment and materials

- Two PIC16F883 circuits with power supplies, programmer and MPLAB X/pic-as
- Oscilloscope with I2C decoding, digital multimeter, pull-up resistors and breadboard components
- Supplied I2C sensor breakout module and an appropriate sensor/input source
- Computer with the Lab 08 UART host application and serial interface
- Additional ADC sensor and servo components for Part 4; additional parts for optional Mastery

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-1"></a>
## Part 1 - I2C Master and Bus Timing

### Goal

Configure one PIC as an I2C master. Use a timer to produce repeatable address transactions without a slave connected, and investigate the electrical signals.

### Before Lab

Prepare the master MSSP and timer register documentation, a circuit schematic, pull-up/loading calculations, and a short natural-language flowchart for a reusable one-byte master write transaction.

### In the Lab

Transmit an address/R-W byte at an interval suitable for scope capture. Detect the expected NACK and complete the transaction with STOP. Configure I2C decoding and measure SDA/SCL timing. Investigate why the bus requires pull-up resistors.

### Evidence

Provide the circuit and calculations, firmware/flowchart, and labeled scope captures identifying START, all address bits, R/W, NACK and STOP. Include timing and rise-time measurements.

### Demonstrate

Show periodic NACK transactions and explain the decoded waveform, measured timing and open-drain bus operation.

### Complete When

The master recognizes the absent slave and reliably generates a complete, measurable transaction.

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
