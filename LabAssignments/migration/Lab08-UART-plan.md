# Lab 08 - UART Migration Plan

Status: initial curriculum analysis only. This is not student-facing lab instruction.

## Legacy source

- Inherited assignment: `../old/Lab09-UART.pdf`
- Renumbered Markdown recreation: `../Lab08-UART.md`
- New sequence position: Lab 08, after ADC

## Essence of the lab

Students should learn asynchronous serial communication as both an electrical signal and a software interface. They should be able to calculate/configure baud rate, identify start/data/stop framing on an oscilloscope or decoder, transmit and receive bytes on the PIC16F883, and design a small protocol that lets a host computer and embedded device exchange meaningful commands and data.

The strongest inherited idea is the integration of UART, servo control, and ADC acquisition. That turns serial communication into a real system interface rather than a terminal-only exercise.

## Builds on

- timer/clock calculations
- ADC acquisition and 10-bit data handling
- servo subsystem
- interrupts and event flags
- host-side programming experience from RCET2265/3371

## Prepares for

- structured device protocols
- I2C packet/address reasoning
- telemetry and command interfaces for capstone work
- PID setpoint and diagnostic communication

## Keep from the inherited lab

- oscilloscope capture and serial decode
- correlation of waveform bits to software bytes
- proving baud rate from the actual signal
- bidirectional communication
- servo command from the host
- ADC data returned to the host with full precision
- simultaneous command and measurement behavior
- simple framing/handshake concept rather than transmitting unstructured bytes

## Reduce or remove

- Visual Basic as a required host language; VB has been retired from the current programming sequence
- dependence on the old Qy@ board code
- unclear use of an "USB to RS232" adapter until the actual electrical interface and voltage levels are verified
- arbitrary protocol characters preserved only because the old lab used them
- a temperature/humidity add-on if sensor conversion work becomes more important than UART itself
- screenshots as evidence without signal/protocol interpretation

## Create or clarify

- TTL/CMOS UART versus RS-232 electrical levels and what adapter is actually being used
- asynchronous frame structure: idle, start bit, data bits, optional parity, stop bit
- baud-rate generator calculation and error
- PIC16F883 EUSART transmit and receive registers/flags
- receive overrun and framing errors
- polling versus interrupt-driven receive behavior
- buffering and what happens if bytes arrive faster than main code handles them
- an explicit packet/protocol definition with command, payload, and response behavior
- byte order for the 10-bit ADC result
- timeout/resynchronization behavior for malformed or incomplete commands

## Proposed new lab architecture

### Part 1 - See a UART frame

Transmit one or more known bytes from a host or PIC and capture the waveform. Label idle, start, data, and stop bits; account for bit order; calculate bit time; and prove the configured baud rate from measurement.

### Part 2 - PIC transmit and receive

Configure the PIC EUSART directly and implement a small loopback/echo or command-response program. Exercise both TX and RX status flags and intentionally inspect at least one error condition.

### Part 3 - Host command controls the embedded system

Use a current host language, preferably C# or Python depending alignment with RCET3371, to send a defined command that changes servo position. The command format should be documented rather than embedded as unexplained magic bytes.

### Part 4 - Bidirectional integrated protocol

Add an ADC sample request/response while servo commands continue to work. Return the complete 10-bit conversion result and a derived engineering value. Require the system to remain responsive to both directions of traffic.

### Part 5 - Mastery

A bounded mastery extension could add checksums, a command parser with multiple message types, receive buffering, or a second sensor. Pick one concrete protocol feature when finalizing the lab.

## Assembly and embedded C strategy

Embedded C should probably be the primary implementation language by this point, but the peripheral must remain visible.

Recommended approach:

- require baud calculations and direct EUSART SFR documentation;
- use direct `TXREG`, `RCREG`, status/control register access in XC8 rather than a library that hides the peripheral;
- discuss or inspect the generated assembly for critical status/interrupt handling when useful;
- preserve enough low-level reasoning that students can troubleshoot a UART that is electrically active but configured incorrectly.

The host application is a good place to reinforce C# or Python without making GUI design the point of the lab.

## Hardware and software reuse

Reuse the servo module from Lab 07 and the ADC acquisition path. Establish one known-good USB-to-UART interface for the course and document its logic levels. The UART driver/protocol code should be reusable later for PID diagnostics and capstone projects.

## Meaningful evidence

- baud-rate calculation and expected error
- UART-related SFR maps and references
- captured TX and RX frames with labeled bits
- measured bit time/baud rate
- host/PIC protocol specification
- proof of servo command behavior
- full 10-bit ADC request/response evidence
- error/edge-case test such as malformed command, overrun, or framing condition
- troubleshooting record

## Questions to resolve during redesign

- Which exact USB-UART adapter and logic level will be standardized?
- Should C# or Python be the default host implementation for Fall 2026 alignment with RCET3371?
- Do we want interrupt-driven receive to be required or introduced as the independent/integration step?
- Is the temperature sensor still useful enough to retain, or does it distract from the serial-protocol objective?
