# Lab 10 - I2C Migration Plan

Status: initial curriculum analysis only. This is not student-facing lab instruction.

## Legacy source

- Inherited assignment: `../old/Lab11-I2C.pdf`
- Renumbered Markdown recreation: `../Lab10-I2C.md`
- New sequence position: Lab 10, after EEPROM

## Essence of the lab

Students should learn how a synchronous shared serial bus works at both the electrical and protocol levels. They should be able to configure the PIC16F883 MSSP for I2C, understand addressing, START/STOP conditions, ACK/NACK behavior, clock/data timing, and use a simple application protocol to move meaningful data between devices.

The inherited two-PIC system is valuable because it forces students to understand both ends of the transaction instead of relying only on an opaque commercial peripheral.

## Builds on

- ADC acquisition and scaling
- servo control
- interrupt/event handling
- UART protocol/framing concepts
- persistent/reusable embedded-C modules

## Prepares for

- external sensors and peripherals
- multi-device embedded systems
- capstone communication buses
- debugging bus timing and protocol failures

## Keep from the inherited lab

- one PIC acting as I2C master and another as slave
- real address-based transactions
- multiple application values crossing the bus
- ADC inputs on the master controlling outputs on the slave
- oscilloscope/protocol-decode inspection of SDA and SCL
- requirement that students explain each visible portion of a transaction

## Reduce or remove

- the inherited 5-bit-data/3-bit-servo-selection packet unless that packing decision serves a clear learning objective
- three servos and three potentiometers if the wiring burden overwhelms the bus lesson
- implementation requirements that force complexity before students have proved a single valid I2C transaction
- any library abstraction that hides START, address, ACK, data, and STOP behavior

## Create or clarify

- open-drain/open-collector bus behavior
- pull-up resistor purpose and current/rise-time considerations
- 7-bit slave addressing and the R/W bit
- START, repeated START, STOP, ACK, and NACK
- MSSP master and slave register roles on the PIC16F883
- clock-rate calculation
- collision, overflow, and bus-error conditions relevant to the device
- transaction timing as seen on the oscilloscope
- packet/application protocol separate from the I2C transport itself
- what should happen when the slave does not acknowledge or data is invalid

## Proposed new lab architecture

### Part 1 - See and explain an I2C transaction

Configure one PIC as master and generate a simple write transaction to a known slave address. Capture SDA/SCL and label START, address, R/W, ACK/NACK, data, and STOP. If a second PIC is not yet configured, a deliberate NACK can still make the bus behavior visible.

### Part 2 - PIC-to-PIC single-byte communication

Configure the second PIC as a slave and reliably transmit one byte from master to slave. Make the received value observable with a simple output. Verify both successful ACK behavior and a failure case.

### Part 3 - Application data transfer

Add one ADC input on the master and one servo/output channel on the slave. Define a small explicit data representation and transfer the command over I2C. Reuse the ADC and servo modules rather than rebuilding them inside this lab.

### Part 4 - Multi-channel or bidirectional integration

Expand to multiple channels or add a read transaction so the slave returns status/data to the master. This is where packing, command IDs, or multiple registers can be introduced if they help teach protocol design rather than just save bytes.

### Part 5 - Mastery

A bounded extension could add a second slave address, repeated START/readback, bus recovery, or an external I2C sensor. Choose one concrete challenge when finalizing the lab.

## Assembly and embedded C strategy

Embedded C should be the primary implementation language here, but students should configure the MSSP through documented SFRs rather than a high-level framework.

Recommended approach:

- require complete register/bit documentation for both master and slave roles;
- use direct XC8 register access and small reusable I2C functions;
- keep bus transactions explicit enough that code can be matched to captured waveforms;
- use assembly only where it materially helps explain timing or generated interrupt behavior, not to make the whole two-device system harder than necessary.

## Hardware and software reuse

Reuse one ADC channel and one servo channel first. If the final version retains three channels, add them only after the communication layer is already proven.

Use the same two PIC16F883 minimum systems if practical. Standardize pull-up values and connection topology so students can focus on electrical reasoning and communication rather than guessing the bus hardware.

## Meaningful evidence

- MSSP/I2C SFR maps for master and slave
- pull-up/loading calculation or justification
- clock-rate calculation
- captured SDA/SCL transaction with labeled fields
- proof of ACK/NACK interpretation
- source-to-waveform correlation
- application protocol definition
- successful ADC-to-remote-output transfer
- at least one intentionally tested failure/edge case
- troubleshooting record

## Questions to resolve during redesign

- Do two PIC16F883 devices remain the best teaching platform, or should one later part use a real I2C sensor/peripheral?
- How many servo/ADC channels add meaningful protocol work before the hardware becomes busy work?
- Should the application protocol use command/register semantics rather than the inherited packed 5+3-bit byte?
- What standard pull-up value and bus speed fit the actual breadboard wiring and course hardware?
