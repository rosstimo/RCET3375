# Lab 09 - EEPROM Migration Plan

Status: initial curriculum analysis only. This is not student-facing lab instruction.

## Legacy source

- Inherited assignment: `../old/Lab10-EEPROM.pdf`
- Renumbered Markdown recreation: `../Lab09-EEPROM.md`
- New sequence position: Lab 09, after UART

## Essence of the lab

Students should learn what nonvolatile data storage means on a microcontroller and how EEPROM differs from ordinary RAM. They should be able to write and read EEPROM correctly, account for the device-specific write sequence and timing, preserve data through a power cycle, and design a small persistent data format rather than treating EEPROM as magic memory.

The inherited record/playback idea is useful because power-cycling makes persistence impossible to fake.

## Builds on

- keypad/input handling from earlier labs
- timing and interrupts
- UART for diagnostics if useful
- structured program state and data representation

## Prepares for

- persistent configuration/calibration data
- logged measurements
- I2C EEPROM or other external nonvolatile memories
- capstone systems that must retain state across power cycles

## Keep from the inherited lab

- record a sequence of user-entered values
- power-cycle the PIC before playback
- remember how many values are valid
- support repeated record/playback cycles rather than one hard-coded demonstration
- explicit instructor test of retained data

## Reduce or remove

- separate Start/Stop/Record push buttons if they add hardware clutter without teaching persistence
- dot-matrix display dependence if an already-developed output path can prove the same behavior more clearly
- long one-second display delays if they block useful system behavior
- arbitrary limit of ten values unless the storage layout and bounds are explicitly derived from it

## Create or clarify

- PIC16F883 data EEPROM address range and relevant SFRs
- read sequence versus protected write sequence
- `EECON2` unlock sequence and why it exists
- write-complete timing/flag behavior
- interrupt handling around the critical write sequence
- EEPROM endurance and why repeated writes should be intentional
- reset/power-cycle behavior
- representation of record length, payload, and unused locations
- bounds checking and what happens when storage is full
- difference between program memory, RAM, and data EEPROM

## Proposed new lab architecture

### Part 1 - Single-byte persistence proof of life

Write a known byte to a chosen EEPROM address, remove power, restart, and prove the byte survived. Require students to document the complete write sequence and distinguish every EEPROM-related register involved.

### Part 2 - Read/write subroutines or functions

Create reusable EEPROM read and write interfaces. Exercise multiple addresses and data values, including a check that avoids writing when the stored value already matches if that behavior is pedagogically useful.

### Part 3 - Persistent sequence recorder

Record a bounded sequence of user inputs and preserve both the data and the number of valid entries. On restart, play or report the sequence using already-developed hardware/software. Reusing the Muzak keypad/note system is a strong possibility because the saved sequence could be audibly replayed after power cycling.

### Part 4 - Persistent configuration/integration

Store a useful configuration value such as servo calibration, selected operating mode, or another parameter from a prior subsystem. Demonstrate that normal application behavior changes based on the retained value after reset.

### Part 5 - Mastery

A suitable mastery investigation could add a checksum, version byte, wear-aware update strategy, ring buffer, or simple log. Choose one concrete feature when the lab is finalized.

## Assembly and embedded C strategy

The protected EEPROM write sequence is worth seeing at the instruction/register level even if the larger application is written in C.

Recommended approach:

- explicitly document and possibly implement the low-level write/read routine in pic-as or inspect the compiler output closely enough to understand the unlock sequence;
- use XC8 C for the larger record/playback/configuration application if embedded C is established by this point;
- avoid a library call that hides the registers, critical sequence, write-complete behavior, and endurance considerations.

## Hardware and software reuse

Prefer no new hardware. Reuse the keypad, speaker, UART, LEDs, or servo system already verified in earlier labs. The focus should stay on persistence and data organization.

A particularly coherent reuse path would be to store and replay a short keypad/note sequence from Lab 04, because the old lab already has a sequence-recording concept and the new version would visibly prove nonvolatile storage without a new display circuit.

## Meaningful evidence

- EEPROM SFR maps and official references
- documented write and read sequence
- address map showing what is stored where
- before/after power-cycle proof
- multiple-value record/playback evidence
- write-complete handling
- explanation of endurance and why unnecessary writes matter
- bounds/full-storage behavior
- troubleshooting notes

## Questions to resolve during redesign

- Is reusing the Muzak keypad/tone system the cleanest persistent-sequence application, or does it bring too much old code into the lab?
- Should students implement one low-level EEPROM operation in assembly before using C wrappers?
- What metadata should be required: length only, sentinel, checksum, or a small structured header?
- Do we want an endurance experiment, or is discussion plus a wear-aware design rule sufficient?
