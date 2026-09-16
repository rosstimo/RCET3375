# RCET 3375 Lab 05 - Interrupt Service Routines

PIC16F883 | pic-as | External Interrupts | PORTB Interrupt-on-Change | Context Saving | Stack Depth | Event-Driven Design

## Purpose

Use the PIC16F883 interrupt system to observe how asynchronous hardware events temporarily change program execution, how multiple interrupt sources share one interrupt vector, and why interrupt service routines must preserve processor context.

The lab begins with one interrupt source and an observable main program, adds a second source, expands PORTB interrupt-on-change to multiple pins, and then recreates the inherited priority-interrupt behavior with deliberately nested interrupt execution. Mastery reproduces the same visible behavior without nested interrupts or long blocking delays inside an ISR.

You should be able to explain what the processor was doing before an interrupt, what caused execution to change, how the source is identified and serviced, what context must be preserved, and how execution safely resumes.

## Standards and references

- [RCET 3375 Lab Standard](../LAB_STANDARD.md)
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md)
- [RCET Flowchart Guide](https://github.com/rosstimo/RCET3371/blob/main/Guides/Flowcharts/RCET-Flowchart-Guide.md)
- [PIC16F882/883/884/886/887 Data Sheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf), especially:
  - Section 2.3.2 - Stack
  - Section 3.4.3 - Interrupt-on-Change
  - Section 14.3 - Interrupts
  - Section 14.4 and Example 14-1 - Context Saving During Interrupts
- [PICmicro Mid-Range MCU Family Reference Manual](https://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf), Section 8 - Interrupts
- previous RCET3375 lab-book documentation and source for PIC I/O, software delays, subroutines, the DLG7137 display, and stack use

The PIC16F883 data sheet is the authority for device-specific behavior. Use Section 14.4 and Example 14-1 as the starting point for context save/restore code.

## Equipment and materials

- MPLAB X IDE and pic-as toolchain
- PICkit programmer/debugger
- PIC16F883 circuit
- 4 MHz crystal oscillator circuit
- momentary pushbuttons/switches as required
- LEDs and current-limiting resistors
- DLG7137 display used in previous labs
- 4-channel oscilloscope
- logic analyzer, optional
- breadboard, jumpers, and interface components as required
- lab book

## Lab-book documentation

Follow the lab standard and reference earlier complete documentation rather than copying unchanged work.

For this assignment also include:

- a register map for assigned port pins;
- register maps for any GPRs intentionally used as named state/status storage;
- datasheets for relevant external components in the lab-book references;
- the GitHub URL for your assignment repository in the lab-book references.

For every interrupt source used, document the enable bit, flag bit, required configuration, what causes the request to be set, what is required to clear it, and the related SFR settings.

When multiple interrupt sources are enabled, each service path must leave its source in a non-requesting state before the common ISR exit.

---

# Part 1 - External Interrupt and Interrupted Main Execution

### Goal

Configure `RB0/INT` for a falling-edge interrupt. Each valid interrupt increments PORTC while main continuously toggles a PORTA monitoring pin.

Use a single-sequence oscilloscope capture to observe the interrupt request, interruption of main-line execution, and the resulting count change.

### Required behavior

- Configure `RB0/INT` for a falling-edge external interrupt.
- Choose any suitable unused PORTA digital output as the main-loop monitoring pin. Document the choice.
- Main toggles the selected PORTA pin continuously and as quickly as the program structure reasonably allows.
- Each external interrupt increments PORTC by one.
- Display PORTC on LEDs as a binary count.
- Do not poll `RB0/INT` from main.
- Use the W/STATUS save/restore sequence in PIC16F883 data sheet Section 14.4, Example 14-1 as the starting point for processor context handling.

Mechanical switch bounce is not automatically a failure. If one physical press creates several valid falling edges, observe and document the result.

### Before Lab

Prepare or reference:

- pushbutton, PORTC LED, and PORTA monitoring-point schematic;
- loading/electrical-limit analysis;
- new SFR maps and relevant bits;
- port-pin assignment map;
- external-interrupt setup sequence;
- context save/restore plan based on data sheet Example 14-1;
- main/interrupt flowchart;
- source code;
- predicted oscilloscope behavior.

### In the Lab

1. Verify the PORTA monitoring signal.
2. Verify the initial PORTC count.
3. Press the `RB0/INT` button and confirm that PORTC increments.
4. Observe whether switch bounce creates additional interrupt events.
5. Configure a single-sequence oscilloscope acquisition triggered on the falling edge of `RB0/INT`.
6. Capture:
   - **CH1:** `RB0/INT` button signal;
   - **CH2:** PORTA main-loop monitoring pin;
   - **CH3:** `RC0`, the count LSB.
7. Identify where main execution is interrupted and where the count changes.
8. Save and explain the capture in the lab book.

### Evidence

Include or reference:

- schematic and loading analysis;
- interrupt SFR documentation;
- port-pin assignment map;
- main/ISR flowchart;
- final source;
- context save/restore explanation;
- required oscilloscope capture;
- explanation of what the capture demonstrates;
- switch-bounce observations;
- troubleshooting record.

### Demonstrate

Show the main-loop monitoring signal, PORTC count, and repeatable external interrupt.

Be prepared to explain what sets the interrupt request, why main does not poll the button, what the W/STATUS save/restore sequence preserves, and what the scope capture shows about main execution during the ISR.

### Complete When

Part 1 is complete when the external interrupt changes the count correctly, main resumes after every interrupt, and the three-channel capture has been explained.

---

# Part 2 - Two Interrupt Sources and One Interrupt Vector

### Goal

Add `RB4` interrupt-on-change while retaining `RB0/INT`. RB4 IOC increments PORTC; falling-edge `RB0/INT` clears PORTC.

The emphasis is source determination, per-source service, and one common ISR exit path.

### Required behavior

- Retain the PORTA main-loop monitoring signal chosen in Part 1.
- Retain PORTC LEDs as the binary count.
- Configure **RB4** as the IOC input.
- An RB4 change event increments PORTC.
- A falling-edge `RB0/INT` event clears PORTC to zero.
- Main polls neither source.
- Both sources enter through the same interrupt vector.
- Save context once, determine the source, service it, and restore context once at the common exit before `RETFIE`.
- Each service path must resolve and clear its own interrupt condition before leaving for the common exit.
- Correctly resolve the PORTB mismatch/change condition before clearing the IOC flag.

### Before Lab

Prepare or reference:

- updated schematic with `RB0/INT` and `RB4` IOC inputs;
- IOC SFR documentation;
- updated port-pin assignment map;
- flowchart showing one vector, source determination, two service paths, and one exit;
- context save/common-exit structure;
- source code;
- predicted behavior when events occur close together.

### In the Lab

1. Verify that RB4 IOC increments PORTC.
2. Generate several RB4 changes and confirm that the count accumulates.
3. Trigger `RB0/INT` and confirm that PORTC clears.
4. Test events occurring close together.
5. Keep these four signals connected to the oscilloscope:
   - **CH1:** `RB0/INT`;
   - **CH2:** PORTA main-loop monitoring pin;
   - **CH3:** `RC0`;
   - **CH4:** RB4 IOC input.
6. Capture an RB4 IOC event in single-sequence mode and explain the request, main-line interruption, and count change.
7. Set the PORTC count so `RC0` is HIGH, then capture an `RB0/INT` event in single-sequence mode and explain the request, main-line interruption, and clear-to-zero result.
8. If useful, capture a close-event sequence with both sources occurring near one another and compare it with your predicted behavior.

### Evidence

Include or reference:

- updated schematic/loading analysis;
- external INT and IOC SFR documentation;
- updated pin-assignment/register map;
- complete ISR flowchart;
- final source;
- four-channel capture of an RB4 IOC event;
- four-channel capture of an `RB0/INT` clear event;
- proof that RB4 IOC increments and `RB0/INT` clears PORTC;
- explanation of the IOC service/clear sequence;
- close-event test results;
- troubleshooting record.

### Demonstrate

The instructor may generate either source repeatedly and in different sequences.

Be prepared to explain why both sources enter through one vector, how software identifies the source, why PORTB must be read while servicing IOC, and why context is restored only at the common exit.

### Complete When

Part 2 is complete when RB4 IOC reliably increments PORTC, `RB0/INT` reliably clears it, both sources share one correctly structured ISR, both interrupt paths have been captured and explained, and main resumes correctly.

---

# Part 3 - Determine Which PORTB Pin Changed

### Goal

Use interrupt-on-change on all eight PORTB pins and determine in software which pin changed.

Display the detected pin number in binary on three PORTA LEDs.

### Required behavior

- Disable the dedicated external interrupt for this part.
- Enable IOC for `RB0` through `RB7` using `IOCB`.
- Establish the initial PORTB comparison state before enabling IOC.
- Treat the IOC flag as notification that a PORTB change occurred, not as identification of a particular pin.
- Determine which PORTB bit changed from the current and previous port states or an equivalent method.
- Display the pin number on three PORTA outputs:
  - `000` = RB0
  - `001` = RB1
  - ...
  - `111` = RB7
- Define a deterministic rule for the case where more than one changed bit is present when the ISR evaluates the event.
- Correctly update the PORTB state used for comparison.
- Correctly service and clear IOC before leaving the handler.

### Before Lab

Prepare or reference:

- PORTB input and PORTA LED schematic;
- IOC configuration documentation;
- pin-assignment map;
- source-determination algorithm;
- flowchart;
- deterministic multi-change rule;
- source code;
- register-style map for any named state/status storage used by the design;
- the effect of the PICkit/ICSP connection on RB6 and RB7 while those pins are used as IOC inputs.

### In the Lab

1. Verify RB0 through RB7 individually.
2. Confirm the correct three-bit pin number for every input.
3. Test repeated changes on the same pin.
4. Test different pins in sequence.
5. Create at least one condition where more than one change may be present and verify the documented rule.
6. Confirm that the ISR does not become stuck servicing an uncleared IOC condition.
7. Record any effect of bounce or closely spaced input changes on source determination.
8. Verify RB6 and RB7 with the PICkit/ICSP connection in the configuration you intend to use during normal operation.

### Evidence

Include or reference:

- schematic/loading analysis;
- IOC documentation;
- pin/state register maps;
- source-determination flowchart;
- final source;
- results for all eight pins;
- multi-change test and rule;
- any relevant RB6/RB7 ICSP observations;
- troubleshooting record.

### Demonstrate

The instructor may change any PORTB input and ask you to identify the corresponding value on PORTA.

Be prepared to explain the difference between detecting that an IOC occurred and determining which pin changed.

### Complete When

Part 3 is complete when all eight PORTB IOC inputs work, software identifies the changed pin, and PORTA displays the correct pin number.

---

# Part 4 - Priority Interrupts, Nested Execution, and Stack Depth

### Goal

Create `1 / 6 / 7` priority-interrupt behavior using the **DLG7137 display on PORTC** from the earlier I/O labs.

This part intentionally allows the higher-priority 7 behavior to interrupt the lower-priority 6 behavior so you can investigate nested interrupt execution, subroutine calls, context preservation, and worst-case hardware stack depth.

### Required visible behavior

Reuse the existing DLG7137/PORTC interface. Reference the earlier lab-book schematic and display encoding unless something changes.

- The display on PORTC must precisly display **1**, **6**, or **7** at any time to reflect the current state of the system.
- Main displays **1** continuously.
- Falling-edge `RB0/INT` initiates the **6** behavior.
- IOC on **RB1** initiates the **7** behavior.
- 6 displays for two seconds. 
- 7 displays for two seconds and has absolute priority over 6.
- 7 may interrupt 6 at any time while 6 is active.
- While 7 is active, no lower-priority behavior may interrupt it.
- When 7 finishes, execution returns to the state that was active when 7 began.
  - If 7 interrupted 6, 6 resumes and completes its remaining time before returning to 1.
  - If 7 interrupted the normal 1 state, the display returns to 1.
- 7 may interrupt the same 6 behavior multiple times. Each time, 6 resumes its remaining time after 7 finishes.

### Delay and subroutine requirement

Implement the long delays with callable subroutines using `CALL`/`RETURN`.

Use nested delay/subroutine calls as appropriate. Normal subroutine calls are intentionally part of the stack-depth problem in this part.

### Required stack analysis

Before demonstration, determine the **worst-case hardware stack depth** of the final design.

Account for every return address that can be active in the worst case, including:

- call depth before the first interrupt;
- the 6 interrupt return address;
- calls made while executing the 6 behavior;
- the nested 7 interrupt return address;
- calls made while executing the 7 behavior;
- repeated 7 interruptions of 6 as allowed by the design.

Show the worst-case stack as a drawing or table. Do not submit only a final number.

Treat the hardware return stack and software context storage as separate analyses. The hardware stack contains return addresses; the W/STATUS save area is in data memory.

Your context-save method must also remain correct when 7 interrupts 6. Use the device-data-sheet W/STATUS method as the starting point and adapt the design as necessary for nested execution.

### Before Lab

Prepare or reference:

- earlier DLG7137/PORTC schematic, encoding, and component datasheet;
- RB0 external-interrupt and RB1 IOC wiring;
- interrupt/IOC SFR documentation;
- pin-assignment map;
- nested-interrupt flowchart;
- nested context-save strategy;
- delay-subroutine structure;
- worst-case hardware stack analysis;
- source code.

### In the Lab

1. Verify that main displays `1`.
2. Trigger `RB0/INT` and verify the approximately two-second `6` behavior followed by a return to `1`.
3. Trigger RB1 IOC while `1` is active. Verify `1 -> 7 -> 1`.
4. Trigger 7 while 6 is active. Verify `6 -> 7 -> 6 -> 1`, with 6 completing the time that remained when it was interrupted.
5. Trigger 7 repeatedly at different points during one active 6 behavior. Each 7 must complete without interruption, then return to the interrupted 6 until 6 eventually completes and returns to 1.
6. Attempt to trigger 6 while 7 is active and verify that 6 does not interrupt 7.
7. Compare observed execution with the stack-depth analysis.
8. The instructor will intentionally exercise the design near its worst-case nesting condition and may attempt to expose stack or context problems.
9. Record and explain any failure observed.

### Evidence

Include or reference:

- schematic/loading analysis;
- interrupt SFR documentation;
- pin-assignment map;
- nested-interrupt flowchart;
- final source;
- delay-subroutine structure;
- worst-case stack table/drawing;
- context-save approach used for nested execution;
- observed `1 -> 7 -> 1` behavior;
- observed `6 -> 7 -> 6 -> 1` behavior, including repeated 7 interruptions of one 6;
- instructor stress-test results;
- troubleshooting record.

### Demonstrate

The instructor will vary the order and timing of the two interrupt inputs and may repeatedly trigger 7 during an active 6.

Be prepared to explain:

- why 7 always has priority;
- how 7 returns to the state it interrupted;
- why 6 always returns to 1 after completing its active time;
- what the hardware stack contains;
- how every `CALL` changes worst-case stack depth;
- what happens if the eight-level hardware stack is exceeded;
- how context is preserved across the nested interrupt;
- why this architecture becomes harder to reason about as nesting grows.

### Complete When

Part 4 is complete when 7 can interrupt 6 at any point and repeatedly without itself being interrupted, 7 always returns to the state it interrupted, 6 resumes its remaining time and ultimately returns to 1, and the demonstrated execution agrees with the documented worst-case stack analysis.

---

# Mastery - Same Priority Behavior Without Nested Interrupts

**Optional. Complete Parts 1-4 first.**

### Goal

Recreate the externally visible Part 4 priority behavior without allowing one ISR to interrupt another and without remaining inside an ISR for the long display delay.

Use short ISRs to record events/state. Perform the longer behavior from main.

### Required behavior

Preserve the same visible state rules as Part 4:

- normal state displays `1`;
- external INT requests the `6` behavior;
- RB1 IOC requests the `7` behavior;
- 6 runs for two seconds;
- 7 has absolute priority and can take over from 6 at any point;
- while 7 is active, no lower-priority behavior may replace it;
- after 7 finishes, the system returns to the state that was active when 7 began;
- if 7 interrupted 6, the remaining 6 time resumes;
- if 7 interrupted 1, the system returns to 1;
- one 6 behavior may be interrupted by 7 multiple times and must still complete its remaining active time before returning to 1;
- no ISR contains the approximately two-second blocking delay;
- no ISR deliberately re-enables interrupts to create nested interrupt execution.

### Before Lab

Prepare:

- revised architecture/flowchart;
- source code;
- register-style map defining the state/status storage used by the design;
- expected state sequences for `1 -> 7 -> 1`, `1 -> 6 -> 1`, and `1 -> 6 -> 7 -> 6 -> 1`.

### In the Lab

Demonstrate the same visible state behavior used in Part 4:

1. `1 -> 6 -> 1`;
2. `1 -> 7 -> 1`;
3. `1 -> 6 -> 7 -> 6 -> 1`;
4. repeated 7 events interrupting one active 6 at different points, with 6 eventually completing and returning to 1;
5. an attempted 6 event while 7 is active must not interrupt the active 7 behavior.

### Evidence

Include or reference:

- revised architecture/flowchart;
- final source;
- state/status register map;
- explanation of what each ISR does and deliberately does not do;
- explanation of how the interrupted state and remaining 6 time are represented without nested ISR execution;
- comparison of Part 4 and Mastery interrupt duration, stack use, and program structure;
- demonstration that the visible priority/state behavior is preserved.

### Demonstrate

Be prepared to explain why the Mastery version produces the same 1/6/7 behavior without nested ISR execution, and why it is easier to reason about with respect to interrupt duration, stack depth, processor context, and program state.

### Complete When

Mastery is complete when it reproduces the Part 4 state rules using short non-nested ISRs and explicit state/status management in main: 7 always has priority and returns to the state it interrupted, while 6 may be interrupted repeatedly by 7 but eventually completes its remaining time and returns to 1.
