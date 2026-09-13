# RCET 3375 Lab 05 - Interrupt Service Routines

PIC16F883 | pic-as | External Interrupts | PORTB Interrupt-on-Change | Context Saving | Stack Depth | Event-Driven Design

## Purpose

Use the PIC16F883 interrupt system to observe how asynchronous hardware events temporarily change program execution, how multiple interrupt sources share one interrupt vector, and why interrupt service routines must preserve processor context.

The lab begins with one interrupt source and an observable main program, then adds a second interrupt source, expands PORTB interrupt-on-change to multiple pins, and finally recreates the inherited priority-interrupt behavior with deliberately nested interrupt execution. Mastery asks you to produce the same visible behavior without nested interrupts or long blocking delays inside an ISR.

The goal is not only to make the interrupt code work. You should be able to explain what the processor was doing before the interrupt, what hardware caused execution to change, what software must preserve, how the source is identified and serviced, and how execution returns safely to the interrupted code.

## Standards and references

- [RCET 3375 Lab Standard](../LAB_STANDARD.md)
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md)
- [RCET Flowchart Guide](https://github.com/rosstimo/RCET3371/blob/main/Guides/Flowcharts/RCET-Flowchart-Guide.md)
- [PIC16F883 Data Sheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf)
- [PICmicro Mid-Range MCU Family Reference Manual](https://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf)
- Previous RCET3375 lab-book documentation and source for PIC I/O, software delays, subroutines, and stack use

## Equipment and materials

- MPLAB X IDE and pic-as toolchain
- PICkit programmer/debugger
- PIC16F883 circuit
- 4 MHz crystal oscillator circuit
- Momentary pushbuttons/switches as required
- LEDs and current-limiting resistors
- Existing PORTC-connected digit display used in previous labs
- Oscilloscope with at least three channels available for the required Part 1 measurement
- Breadboard, jumpers, and interface components as required
- Lab book

## Interrupt design expectations

The PIC16F883 uses a single interrupt vector. When more than one interrupt source is enabled, your software must determine which source or sources require service.

For each interrupt source used in this lab, document:

- the interrupt enable bit;
- the interrupt flag bit;
- any edge or change configuration required;
- the global/peripheral enable relationship where applicable;
- the condition required to clear the interrupt request correctly;
- any related PORT, TRIS, ANSEL, OPTION, INTCON, IOC, or other SFR settings.

Context saving must be deliberate. Record what processor state your ISR must preserve and explain why the interrupted main code must resume with the correct state.

When multiple interrupt handlers are used, each handler must service its own source and clear its own interrupt condition before transferring to the common ISR exit path.

---

# Part 1 - External Interrupt and Interrupted Main Execution

### Goal

Configure the `RB0/INT` external interrupt for a falling-edge event from a momentary pushbutton. Each valid interrupt increments PORTC while the main program continuously toggles a PORTA monitoring pin.

Use an oscilloscope single-sequence capture to observe the interrupt request, the temporary interruption of main-line execution, and the resulting PORTC count change.

### Required behavior

- Configure `RB0/INT` for a falling-edge external interrupt.
- Main continuously toggles one designated PORTA pin as fast as the program structure reasonably allows. Use a PORTA pin that does not conflict with later parts and document the choice.
- Each external interrupt increments PORTC by one.
- Connect LEDs to PORTC so the count is visible in binary.
- Do not poll the external interrupt input in main code.
- Save the required processor context on interrupt entry and restore it before `RETFIE`.

Mechanical switch bounce is not automatically a failure in this part. If one physical press produces multiple valid falling edges and therefore multiple counts, observe and document what happened.

### Before Lab

Prepare or reference:

- schematic for the pushbutton, PORTC LEDs, and PORTA monitoring point;
- loading and electrical-limit analysis;
- all newly encountered SFR maps and relevant bits;
- external interrupt setup sequence;
- context-save/context-restore plan;
- top-level main/interrupt flowchart;
- source code;
- prediction of what the three oscilloscope channels should show when an interrupt occurs.

### In the Lab

1. Verify that main continuously toggles the selected PORTA monitoring pin.
2. Verify that PORTC begins at the intended initial count.
3. Press the `RB0/INT` button and confirm that the PORTC count increments.
4. Observe whether switch bounce causes additional interrupt events.
5. Configure a single-sequence oscilloscope acquisition triggered on the falling edge of the interrupt input.
6. Capture:
   - **CH1:** `RB0/INT` button signal;
   - **CH2:** PORTA main-loop monitoring pin;
   - **CH3:** `RC0`, the least-significant bit of the PORTC count.
7. Use the capture to identify where main-line execution is temporarily interrupted and where the count changes.
8. Save a readable capture and annotate or explain the important timing relationships in the lab book.

### Evidence

Include or reference:

- schematic and loading analysis;
- interrupt-related SFR documentation;
- flowchart showing main execution and ISR entry/exit;
- final source code;
- context-save/context-restore explanation;
- single-sequence oscilloscope capture with CH1, CH2, and CH3 identified;
- explanation of what the capture proves about interrupt execution;
- notes on any observed switch bounce;
- troubleshooting record.

### Demonstrate

Demonstrate the running main-loop signal, the PORTC interrupt count, and a repeatable external interrupt.

Be prepared to explain:

- what causes the interrupt request;
- why main does not need to poll the button;
- what processor state is preserved by your code;
- what changes on PORTA while the ISR is executing;
- why one physical button press may result in more than one interrupt.

### Complete When

Part 1 is complete when the external interrupt reliably changes the PORTC count, main resumes correctly after every interrupt, and the required three-channel single-sequence measurement has been captured and explained.

---

# Part 2 - Two Interrupt Sources and One Interrupt Vector

### Goal

Add a single PORTB interrupt-on-change source while retaining the external interrupt. Use the PORTB interrupt-on-change event to increment the PORTC count and use the external `RB0/INT` event to clear PORTC.

The emphasis is now on sharing one interrupt vector, determining which source caused the request, servicing the correct source, and returning through one common ISR exit path.

### Required behavior

- Retain the continuously toggling PORTA main-loop monitoring pin.
- Retain PORTC LEDs as the visible binary count.
- Configure one PORTB interrupt-on-change input in addition to `RB0/INT`.
- A valid PORTB interrupt-on-change event increments PORTC.
- A falling-edge `RB0/INT` external interrupt clears PORTC to zero.
- Main must not poll either interrupt source.
- Both sources enter through the same interrupt vector.
- The ISR must save context once, determine which source requires service, transfer to the appropriate handler, and use one common exit path to restore context and execute `RETFIE`.
- Each handler must clear its own interrupt condition immediately before leaving the handler for the common exit path.
- The PORTB interrupt-on-change handler must perform the required PORTB read/service sequence before clearing the PORTB interrupt-on-change flag.

### Before Lab

Prepare or reference:

- updated schematic showing both interrupt inputs;
- all newly encountered IOC-related SFR documentation;
- flowchart showing one interrupt vector and two handler paths;
- context-save/common-exit structure;
- planned handling of the PORTB mismatch/change condition;
- source code;
- predicted behavior when the two interrupt events occur close together.

### In the Lab

1. Verify that the PORTB interrupt-on-change source increments PORTC.
2. Generate several IOC events and confirm that the binary count accumulates.
3. Trigger `RB0/INT` and confirm that PORTC clears to zero.
4. Repeat the test with interrupt events occurring close together.
5. Observe the main-loop PORTA signal while each interrupt source is serviced.
6. Capture oscilloscope evidence that makes the two interrupt sources and their effect on main execution understandable. Use additional captures if all useful signals cannot be shown clearly at once.
7. Verify that the system returns to correct main-line execution after either interrupt source.

### Evidence

Include or reference:

- updated schematic and loading analysis;
- IOC and external-interrupt SFR documentation;
- complete ISR flowchart including source determination and common exit;
- final source code;
- oscilloscope evidence for both interrupt sources;
- proof that IOC increments and external INT clears PORTC;
- explanation of how the IOC condition is correctly serviced and cleared;
- close-event test results;
- troubleshooting record.

### Demonstrate

The instructor may generate either interrupt source repeatedly and in different sequences.

Be prepared to explain:

- why both sources enter through one vector;
- how your software determines which source needs service;
- why the PORTB input must be read as part of servicing interrupt-on-change;
- why each handler is responsible for clearing its own interrupt condition;
- why context restoration occurs only at the common exit.

### Complete When

Part 2 is complete when the IOC event reliably increments PORTC, the external interrupt reliably clears PORTC, both sources share one correctly structured ISR, and main resumes correctly after every event.

---

# Part 3 - Determine Which PORTB Pin Changed

### Goal

Enable PORTB interrupt-on-change on all applicable PORTB pins and add the software step required to determine which pin changed.

Display the detected PORTB pin number in binary on three PORTA outputs connected to LEDs.

### Required behavior

- Configure all PORTB interrupt-on-change inputs required for this part.
- A PORTB interrupt-on-change request indicates that one or more enabled PORTB inputs changed.
- The ISR must determine which PORTB pin changed rather than treating the common IOC flag as though it identifies a specific pin.
- Use three PORTA output pins and LEDs to display the identified PORTB pin number in binary.
- `000` represents RB0, `001` represents RB1, through `111` representing RB7.
- Document a deterministic rule for the case where more than one PORTB bit is detected as changed before the ISR finishes source determination.
- Correctly update whatever previous/current PORTB state information your algorithm requires.
- Correctly service and clear the IOC condition before leaving the handler.

### Before Lab

Prepare or reference:

- PORTB input and PORTA LED schematic;
- IOC enable/mask documentation;
- algorithm for comparing current PORTB state with the previously known state;
- flowchart for determining which pin changed;
- deterministic multi-change rule;
- source code;
- any newly required SFR or GPR documentation.

### In the Lab

1. Verify each PORTB input individually.
2. Confirm that the three PORTA LEDs display the correct binary pin number for RB0 through RB7.
3. Test repeated changes on the same input.
4. Test changes on different inputs in sequence.
5. Create at least one condition where more than one PORTB bit may be observed as changed and verify that your documented rule is followed.
6. Confirm that the ISR does not become stuck repeatedly servicing an uncleared IOC condition.
7. Document any cases where switch bounce or closely spaced input changes make source determination more difficult.

### Evidence

Include or reference:

- schematic and loading analysis;
- IOC configuration documentation;
- source-determination flowchart;
- final source code;
- explanation of how previous and current PORTB states are used;
- results for all eight PORTB inputs;
- multi-change test and deterministic selection rule;
- troubleshooting record.

### Demonstrate

The instructor may change any PORTB input and ask you to identify the corresponding binary value on PORTA.

Be prepared to explain the difference between:

- knowing that a PORTB change interrupt occurred; and
- determining which PORTB pin actually changed.

### Complete When

Part 3 is complete when all required PORTB IOC inputs work, the changed pin is identified in software, and the correct pin number is displayed in binary on the three PORTA LEDs.

---

# Part 4 - Priority Interrupts, Nested Execution, and Stack Depth

### Goal

Recreate the inherited priority-interrupt behavior using the same PORTC-connected digit display used in previous labs.

This part intentionally allows one interrupt to interrupt another so you can investigate nested interrupt execution, nested subroutine calls, software context preservation, and worst-case hardware stack depth.

### Required visible behavior

Use the existing digit display connected to PORTC.

- Main displays **1** continuously.
- A falling-edge `RB0/INT` external interrupt initiates the **6** behavior.
- A PORTB interrupt-on-change event on **RB1** initiates the **7** behavior.
- The 6 behavior displays **6** for approximately two seconds.
- The 7 behavior displays **7** for approximately two seconds.
- While the 6 behavior is active, the 7 interrupt must be able to interrupt it.
- When the 7 behavior completes, execution must return to the interrupted 6 behavior and finish the remaining 6 time.
- The 6 interrupt must not interrupt an active 7 behavior.
- The 7 behavior must be able to interrupt the 6 behavior repeatedly.
- When all interrupt work is complete, execution returns to main and the display again shows **1**.

### Delay and subroutine requirement

Implement the long delays using callable delay subroutines and `CALL`/`RETURN`.

Use nested delay-loop/subroutine structure as needed rather than flattening the entire delay into main ISR code. The purpose is to make normal subroutine stack use part of the stack-depth analysis.

### Required stack analysis

Before demonstrating the final program, determine the **worst-case hardware stack depth** your design can reach.

Your analysis must account for every return address that can be active in the worst case, including:

- the call depth of code executing before the first interrupt;
- the interrupt return address for the 6 interrupt;
- any `CALL`s made while servicing/displaying/delaying the 6 behavior;
- the nested interrupt return address when 7 interrupts 6;
- any `CALL`s made while servicing/displaying/delaying the 7 behavior;
- repeated 7 interrupts if your design permits them before prior stack entries have unwound.

Show the worst-case stack as a drawing or table that makes each occupied stack level understandable. Do not merely state a number.

Also document how software-saved context is protected when an interrupt occurs while another interrupt context is already active. Hardware return-stack depth and software context storage are related problems, but they are not the same thing.

### Before Lab

Prepare or reference:

- existing PORTC digit-display schematic and encoding;
- RB0 external interrupt and RB1 IOC input wiring;
- interrupt and IOC SFR documentation;
- complete nested-interrupt flowchart;
- context-save strategy for nested execution;
- delay-subroutine structure;
- worst-case hardware stack-depth analysis;
- source code.

### In the Lab

1. Verify that main continuously displays `1`.
2. Trigger the external interrupt and verify the approximately two-second `6` behavior.
3. Trigger RB1 IOC and verify the approximately two-second `7` behavior.
4. Trigger 7 while 6 is active. Verify the visible sequence `6 -> 7 -> 6` before returning to `1`.
5. Trigger 7 repeatedly while 6 is active and verify that execution still unwinds correctly.
6. Attempt to trigger 6 while 7 is active and verify that 6 does not interrupt 7.
7. Compare observed behavior with the stack-depth analysis.
8. The instructor will intentionally exercise the design near its worst-case nesting condition and may attempt to expose a stack-overflow or context-corruption problem.
9. Record any failure mode and relate it to the actual execution/stack/context path that caused it.

### Evidence

Include or reference:

- schematic and loading analysis;
- interrupt-related SFR documentation;
- nested-interrupt flowchart;
- final source code;
- delay-subroutine structure using `CALL`/`RETURN`;
- worst-case hardware stack-depth table or drawing;
- software context-storage analysis;
- observed `1`, `6`, `7`, and nested `6 -> 7 -> 6` behavior;
- instructor stress-test results;
- explanation of any stack or context failure observed;
- troubleshooting record.

### Demonstrate

The instructor will test the order and timing of the two interrupt inputs and may repeatedly trigger the higher-priority 7 event during the 6 behavior.

Be prepared to explain:

- how 7 is allowed to interrupt 6;
- why 6 cannot interrupt 7;
- where interrupt return addresses are stored;
- where your saved processor context is stored;
- how every `CALL` affects worst-case stack depth;
- what happens if the hardware stack capacity is exceeded;
- why this architecture becomes difficult to reason about as nesting grows.

### Complete When

Part 4 is complete when the required priority behavior works, nested 7 events can interrupt and return to the 6 behavior correctly, and the demonstrated execution agrees with a documented worst-case stack/context analysis.

---

# Mastery - Same Priority Behavior Without Nested Interrupts

### Goal

Recreate the externally visible Part 4 behavior without allowing one ISR to interrupt another and without remaining inside an ISR for the long display delay.

Use short interrupt service routines to capture events and update state/status information. Perform the longer behavior from main using state and status flags.

### Required behavior

The visible behavior must remain equivalent to Part 4:

- main displays `1`;
- the external interrupt requests the `6` behavior;
- RB1 IOC requests the `7` behavior;
- `7` has priority over `6`;
- a 7 request during an active 6 behavior causes the display to show `7` and then resume the remaining 6 behavior;
- the system eventually returns to displaying `1`;
- no ISR contains the approximately two-second blocking delay;
- no ISR deliberately re-enables interrupts to create nested interrupt execution.

The main program should make decisions from explicit state/status information rather than depending on being trapped inside an interrupt routine.

### Evidence

Include or reference:

- revised architecture/flowchart;
- final source code;
- definition of the state/status flags or registers used;
- explanation of what each ISR does and what it deliberately does not do;
- comparison of Part 4 and Mastery interrupt duration, stack use, and program structure;
- demonstration that the visible priority behavior is preserved.

### Demonstrate

Demonstrate the same event sequence used to test Part 4, including a 7 request during an active 6 behavior.

Be prepared to explain why the Mastery version is easier to reason about with respect to interrupt duration, stack depth, and processor context.

### Complete When

Mastery is complete when the Part 4 priority behavior has been reproduced using short non-nested ISRs and explicit state/status management in main.
