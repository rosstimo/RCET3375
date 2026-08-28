# Lab 02 - PIC16F883 I/O Familiarization

> Lab numbering may change as the Fall 2026 sequence is refined.

## Purpose

Set up a working PIC16F883 development environment, establish a reusable PIC-AS project workflow, and build progressively more complex digital I/O applications.

This is the first PIC assembly lab, so Parts 1 and 2 are intentionally more guided. Parts 3 and 4 require more independent design and debugging.

## Standards and reusable resources

Use these throughout the assignment:

- [RCET 3375 Lab Standard](../LAB_STANDARD.md) - repository structure, one-repository-per-assignment rule, lab-book expectations, SFR documentation, electrical loading, evidence, and checkoff standards.
- [Starting a PIC-AS Project](../HowTo/PIC-AS-Project-Setup.md) - MPLAB X, `pic-as 3.10`, PICkit 3, CONFIG bits, PSECT placement, starter source, build/program checks, and Git/GitHub workflow.
- [PIC16F883 4 MHz Crystal Oscillator](../HowTo/PIC16F883-4MHz-Crystal-Oscillator.md) - oscillator connection, capacitor selection, schematic, and verification.
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md) - required assembly style and source organization.
- [PIC16F883 Data Sheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf) - primary authority for device-specific behavior.

## Equipment and components

- Computer with MPLAB X IDE 6.20 and `pic-as 3.10`
- PICkit 3
- PIC16F883
- 4 MHz crystal and required capacitors
- Oscilloscope
- Logic analyzer, optional
- Digital multimeter
- DLG7137 display
- 8-position DIP-switch assembly
- 4 x 4 matrix keypad
- Resistors and other interface components as required
- Lab book

---

# Part 1 - First PIC-AS Project

## Goal

Create a known-good PIC16F883 project that can be used as the starting point for later PIC assignments.

## Before Lab

Follow [Starting a PIC-AS Project](../HowTo/PIC-AS-Project-Setup.md) and the [RCET 3375 Lab Standard](../LAB_STANDARD.md).

Prepare:

- one Git repository for this assignment;
- the required repository directory structure;
- MPLAB X IDE 6.20;
- `pic-as 3.10`;
- a standalone PIC16F883 project under `source/pic/`;
- PICkit 3 project configuration;
- deliberate CONFIG-bit settings;
- reset and interrupt PSECT placement at the correct addresses;
- a course-standard `main.S` starter file.

Also follow [PIC16F883 4 MHz Crystal Oscillator](../HowTo/PIC16F883-4MHz-Crystal-Oscillator.md) to design the external oscillator and select the load capacitors from the actual crystal specification.

Document all SFRs, configuration decisions, IC pins, and component-loading checks required by the lab standard.

## In the Lab

1. Inspect power, reset, oscillator, and PICkit connections before applying power.
2. Verify MPLAB X recognizes the PICkit 3 and target device.
3. Build the starter project without assembler or linker errors.
4. Program the PIC16F883.
5. Verify the 4 MHz oscillator is operating.
6. Verify the reset and interrupt PSECT locations from build output.
7. Commit the known-good project and push it to GitHub.
8. Verify `git status` is clean.

## Evidence

- repository and GitHub location;
- correct project structure;
- configuration-bit record;
- PICkit 3 connection information;
- PSECT/vector verification;
- oscillator calculation and schematic;
- oscillator measurement;
- working `main.S` starter;
- successful build/program evidence;
- meaningful Git history.

## Demonstrate

Show that the project opens, builds, programs the PIC, uses the correct vector locations, runs from the 4 MHz crystal, and is committed/pushed correctly.

## Complete When

Part 1 is complete when the complete development workflow is working and documented.

---

# Part 2 - PORTB Output Counter

## Goal

Configure PORTB as a digital output and continuously increment it. Connect the SFR configuration and assembly program to observable hardware behavior.

## Before Lab

Use the datasheet to determine all configuration required for PORTB digital output.

Prepare:

- complete SFR records or earlier lab-book page references;
- updated schematic;
- loading calculations for every connected pin/component;
- program flowchart;
- PIC-AS source;
- a prediction of the PORTB output sequence and RB0 behavior.

## In the Lab

1. Build and program the PIC.
2. Verify that PORTB continuously increments.
3. Observe enough PORTB lines to confirm binary counting.
4. Capture RB0 with the oscilloscope.
5. Measure HIGH pulse width, LOW pulse width, period, and frequency.
6. Compare the measurements with your prediction.

## Program-memory evidence

For a short meaningful sequence, record:

| Program memory location | Mnemonic | Operand | 14-bit opcode | Meaning |
| --- | --- | --- | --- | --- |

Do not transcribe the whole program. Be prepared to explain Program Counter behavior during reset, sequential execution, branching, and the loop.

## Evidence

- schematic;
- SFR documentation;
- loading calculations;
- flowchart and final source;
- short program-memory table;
- RB0 waveform and measurements;
- prediction-versus-measurement comparison;
- troubleshooting notes.

## Demonstrate

Show continuous PORTB counting and explain the SFR setup, program flow, measured RB0 behavior, and loading verification.

## Complete When

Part 2 is complete when the counter works and the required evidence has been checked.

---

# Part 3 - DIP-Switch Priority Display

## Goal

Read eight digital inputs on PORTB, determine the highest active switch, and display its number on the DLG7137 using PORTC.

## Functional requirements

- RB0 = switch 0
- RB7 = switch 7
- no active switch -> display `$`
- one active switch -> display that switch number
- multiple active switches -> display the **largest active switch number**
- RB7 has highest priority; RB0 has lowest priority
- operation is continuous

## Before Lab

Prepare:

- PORTB input and PORTC output SFR documentation;
- complete DIP-switch/display schematic;
- loading calculations for all pins and components;
- behavior table;
- priority-selection flowchart;
- PIC-AS source.

## In the Lab

1. Verify every individual switch.
2. Verify the no-switch condition.
3. Test multiple-switch combinations.
4. Confirm that the largest active switch always wins.
5. Troubleshoot unstable inputs, incorrect characters, or priority errors.

## Evidence

- schematic;
- SFR documentation/references;
- loading calculations;
- behavior table;
- flowchart and final source;
- single- and multiple-switch test results;
- troubleshooting notes.

## Demonstrate

The instructor may select arbitrary switch combinations. Demonstrate correct priority and explain the input, display, and software-selection behavior.

## Complete When

Part 3 is complete when the display behaves correctly for individual and multiple active switches.

---

# Part 4 - Matrix Keypad Scanning

## Goal

Interface a 4 x 4 matrix keypad, scan the keypad, identify the pressed key, and display its assigned value on the DLG7137.

## Key values and priority

Use these assigned values unless instructed otherwise:

| Key | Value |
| --- | ---: |
| 0-9 | 0x0-0x9 |
| A-D | 0xA-0xD |
| * | 0xE |
| # | 0xF |

If multiple keys are pressed, the **largest assigned key value must have priority**. Design the scan order and key-selection logic so this behavior is deterministic.

## Before Lab

Determine:

- the keypad row/column arrangement;
- PIC pin assignments;
- which lines are driven and which are read during each scan step;
- the scan order needed to preserve largest-value priority;
- all required SFR configuration.

Prepare:

- complete keypad/display schematic;
- loading calculations for all connected pins/components;
- scan-state table;
- flowchart;
- PIC-AS source.

> **Warning:** Depending on how the keypad lines are driven, pressing two keys at the same time may electrically connect a PIC output driving HIGH to another output driving LOW. This can create excessive current or a short-circuit condition. Analyze the possible current paths before testing multiple simultaneous key presses. You may need external protection components. Any protection method used must appear in the schematic and loading calculations.

## In the Lab

1. Verify all 16 keys individually.
2. Confirm the correct assigned value is displayed.
3. Observe at least one complete scan sequence with an oscilloscope or logic analyzer.
4. Compare the measured scan with your scan-state table.
5. Measure the scan period.
6. Test multiple simultaneous key presses only after the possible current paths have been analyzed and any required protection is in place.
7. Confirm the largest assigned key value has priority.
8. Document troubleshooting changes.

## Evidence

- keypad/display schematic;
- SFR documentation/references;
- loading and multiple-key current-path analysis;
- scan-state table;
- flowchart and final source;
- verification of all 16 keys;
- scan waveform/capture and measured scan period;
- multiple-key priority results;
- troubleshooting notes.

## Demonstrate

Demonstrate keypad scanning, all assigned key values, and largest-value priority. Explain the scan sequence and the multiple-key electrical concern.

## Complete When

Part 4 is complete when all keys scan correctly, the measured scan matches the intended sequence, and multiple-key behavior is both electrically acceptable and logically deterministic.

---

# Part 5 - Mastery: Key Bounce and Repeated Scans

**Optional. Complete Parts 1-4 first.**

## Goal

Determine whether the keypad needs software debounce or other key-event handling, explain why, and design a solution based on measured behavior.

Two different effects may matter:

1. **Mechanical contact bounce** during press or release can make one physical action produce several electrical transitions.
2. **A held key is detected on many consecutive keypad scans.** Even with no contact bounce, software may incorrectly treat those repeated scans as many separate key presses if the application expects one event per physical press.

## Investigation

Use the oscilloscope or logic analyzer and the Part 4 program to answer:

- Can contact bounce be observed on the keypad?
- How long does the unstable interval last?
- How long is one complete keypad scan?
- How many scans occur while a key is held for a normal human button press?
- Does the Part 4 display application actually care if the same held key is recognized repeatedly?
- Would repeated recognition matter in an application that counts key presses, enters digits, changes state, or triggers one action per press?

## Design

Decide whether debounce and/or key-event handling is needed for the current application or for likely future applications.

If it is needed, describe how the software would distinguish:

- a new key press;
- contact bounce;
- the same key remaining held across multiple scans;
- key release;
- a different key becoming the highest-priority pressed key.

Your proposed method must preserve the Part 4 rule that the **largest assigned key value wins when multiple keys are pressed**.

Create a flowchart or state diagram detailed enough that the method could be implemented in PIC assembly.

## Evidence

- measured key-press/release capture;
- measured or estimated bounce duration;
- Part 4 scan period;
- estimate of repeated scans during a held key press;
- written conclusion on whether debounce/event handling is needed and why;
- flowchart/state diagram for the proposed software solution;
- explanation of how largest-value priority is preserved.

## Demonstrate

Explain your measurements, conclusion, and proposed software behavior to the instructor.

## Complete When

Part 5 is complete when the debounce/repeated-scan decision is supported by measured evidence and the proposed software solution is specific enough to implement.
