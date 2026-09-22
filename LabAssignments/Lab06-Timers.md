<a id="top"></a>

# RCET 3375 Lab 06 - Timers and Event-Driven Timing

[RCET3375 course home](../README.md)

PIC16F883 | pic-as | Timer2 | Periodic Interrupts | System Tick | State Machines | Event Latching

## Contents

- [Purpose](#purpose)
- [Standards and references](#standards-references)
- [Equipment and materials](#equipment-materials)
- [Lab-book documentation](#lab-book-documentation)
- [Part 1 - Timer2 20 ms proof of life](#part-1)
- [Part 2 - Nonblocking hardware time base](#part-2)
- [Part 3 - Timed intersection state machine](#part-3)
- [Part 4 - Demand-responsive intersection](#part-4)
- [Mastery - XC8 C timer bridge](#mastery)
- [Submission and checkoff](#submission)

<a id="purpose"></a>
## Purpose

Build a reliable hardware time base with Timer2, measure it, and use it to control an embedded system without blocking software delays.

This lab continues directly from Lab 05. The PIC still receives asynchronous events through interrupts, but now one interrupt source is periodic. Timer2 provides a 20 ms system tick while the main program remains free to perform other work.

The final required application is a two-direction intersection controller. Timing is handled as explicit states and elapsed timer ticks. Vehicle inputs are captured as events so that a short request is not lost while the program is busy with another state.

The important architectural change is:

```text
software delay
-> CPU waits

hardware timer + short ISR + state
-> time advances while the CPU continues useful work
```

Parts 1-4 use **pic-as assembly**. Do not replace Timer2 with a delay library or a long software-delay loop.

[Back to top](#top) · [Course home](../README.md)

<a id="standards-references"></a>
## Standards and references

- [RCET 3375 Lab Standard](../LAB_STANDARD.md)
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md)
- [RCET 3373 PIC16F883 Timers](https://github.com/rosstimo/RCET3373/blob/main/Topics/timers.md), especially the Timer2 period/postscaler and troubleshooting sections
- [RCET Flowchart Guide](https://github.com/rosstimo/RCET3371/blob/main/Guides/Flowcharts/RCET-Flowchart-Guide.md)
- [PIC16F882/883/884/886/887 Data Sheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf)
- [PICmicro Mid-Range MCU Family Reference Manual](https://ww1.microchip.com/downloads/en/DeviceDoc/33023A.pdf)
- previous RCET3375 lab-book documentation and source for interrupts, context saving, digital I/O, subroutines, and measurement

The PIC16F883 data sheet is the authority for Timer2 register behavior, interrupt flags/enables, reset states, and electrical limits.

For the course 4 MHz oscillator:

```text
FOSC = 4 MHz
FCY  = FOSC / 4 = 1 MHz
TCY  = 1 us
```

For Timer2:

```text
match period = (PR2 + 1) × TCY × prescale

interrupt period = match period × postscale
```

You must derive the Timer2 settings used in this lab. Do not copy unexplained register values.

[Back to top](#top) · [Course home](../README.md)

<a id="equipment-materials"></a>
## Equipment and materials

- MPLAB X IDE and pic-as toolchain
- PICkit programmer/debugger
- PIC16F883 circuit
- 4 MHz crystal oscillator circuit
- six LEDs for the two traffic signals
- current-limiting resistors
- two digital input switches or equivalent logic-level traffic-sensor inputs
- oscilloscope
- frequency counter, optional
- logic analyzer, optional
- a way to produce and verify a 20 ms logic-level sensor pulse for Part 4
- breadboard, jumpers, and interface components as required
- lab book

Use safe logic levels for any external pulse source. Verify its voltage range and common reference before connecting it to the PIC.

[Back to top](#top) · [Course home](../README.md)

<a id="lab-book-documentation"></a>
## Lab-book documentation

Follow the [RCET3375 Lab Standard](../LAB_STANDARD.md). Reference earlier complete documentation instead of copying unchanged material.

For this assignment also include:

- Timer2 clock-chain calculation from the 4 MHz oscillator through `TMR2IF`;
- complete documentation for every newly used Timer2/interrupt SFR and relevant bit;
- the selected prescaler, `PR2`, postscaler, and expected interrupt period;
- register-style maps for named GPR state such as tick counts, current state, and latched requests;
- a complete traffic-light output map;
- a complete sensor-input map;
- the intersection state diagram or flowchart;
- a safety table showing the allowed light combinations;
- predicted and measured timing;
- evidence that a verified 20 ms sensor event is captured;
- the GitHub URL for the assignment repository.

Keep hardware return-stack analysis, software state variables, and interrupt context-storage variables conceptually separate.

[Back to top](#top) · [Course home](../README.md)

<a id="part-1"></a>
## Part 1 - Timer2 20 ms Proof of Life

### Goal

Configure Timer2 to request an interrupt every **20.000 ms nominal** using the 4 MHz oscillator. Toggle a digital output once per Timer2 interrupt so the interval can be measured.

A toggle occurs every interrupt, so the output's complete HIGH/LOW waveform cycle is twice the interrupt interval.

### Required behavior

- Use Timer2 with the internal clock derived from `FOSC/4`.
- Select a valid Timer2 prescaler, `PR2`, and postscaler combination that produces a nominal 20 ms interrupt period.
- Enable the Timer2 peripheral interrupt through the correct source, peripheral, and global interrupt gates.
- Use the common interrupt vector and the context-save/restore discipline established in Lab 05.
- Clear `TMR2IF` correctly.
- Toggle one documented digital output exactly once for each Timer2 interrupt.
- Do not repeatedly rewrite unchanged Timer2 configuration from the main loop.
- Do not use a software delay to create the 20 ms interval.

### Before Lab

Prepare:

- the complete Timer2 timing calculation;
- Timer2-related SFR documentation;
- interrupt enable/flag path;
- selected timing-test output pin;
- source code;
- predicted interrupt frequency;
- predicted toggle-output frequency and period.

Your calculation must show the reasoning chain:

```text
FOSC
-> FCY / TCY
-> Timer2 prescaler
-> PR2 + 1 count states
-> Timer2 match period
-> postscaler
-> TMR2IF period
-> observable output toggle
```

### In the Lab

1. Program the PIC and verify that Timer2 interrupts continuously.
2. Measure the timing-test output with the oscilloscope.
3. Record the measured waveform period and frequency.
4. Convert the measured toggle waveform back to the underlying interrupt interval.
5. Compare predicted and measured values.
6. If they disagree, troubleshoot the clock, `PR2`, prescaler, postscaler, enable path, and any unintended timer-register writes before changing the design.

### Evidence

Include or reference:

- Timer2 calculation;
- Timer2 SFR documentation;
- final source;
- oscilloscope or frequency-counter measurement;
- predicted versus measured comparison;
- explanation of why the visible toggle waveform period is twice the interrupt period;
- troubleshooting record.

### Demonstrate

Show the Timer2-derived waveform and explain the complete path from the 4 MHz oscillator to the observed output edge.

Be prepared to identify the difference between:

- the Timer2 match event;
- the postscaled `TMR2IF` event;
- ISR entry;
- the later GPIO transition.

### Complete When

Part 1 is complete when the measured output agrees with the calculated 20 ms interrupt design within the expected oscillator/instrument uncertainty and you can explain every stage of the timing chain.

[Back to top](#top) · [Course home](../README.md)

<a id="part-2"></a>
## Part 2 - Nonblocking Hardware Time Base

### Goal

Use the 20 ms Timer2 interrupt as a reusable system tick while the main program continues performing an independent task.

### Required behavior

- Retain the 20 ms Timer2 configuration from Part 1.
- Keep the Timer2 ISR short.
- Use timer ticks to create a visible **1 second** timed event.
- Do not wait inside the ISR for one second.
- Do not call a long software-delay routine from the ISR or main.
- While the 1-second behavior runs, main must continuously perform an independent observable task.

One acceptable structure is:

```text
Timer2 ISR:
    service Timer2
    update a tick count or set a tick event
    return

Main:
    continue independent work
    when enough timer ticks have elapsed:
        update the 1-second output
```

For the independent task, continuously toggle a monitoring output or continuously read an input and mirror its state to another output. Document what you chose.

### Before Lab

Prepare:

- the tick-count design for converting 20 ms events into 1 second;
- GPR/state map;
- main/ISR flowchart;
- source code;
- predicted behavior of both the timed output and the independent main-loop activity.

### In the Lab

1. Verify the 20 ms interrupt still operates.
2. Verify the 1-second timer-derived behavior.
3. Verify the independent main-loop activity continues between Timer2 interrupts.
4. Observe both signals on the oscilloscope.
5. Confirm that the program remains responsive rather than disappearing into a blocking delay.

### Evidence

Include or reference:

- tick-count calculation;
- source and flowchart;
- measured 1-second behavior;
- oscilloscope evidence that main continues running while timer-based timing occurs;
- explanation of where elapsed time is represented in software;
- comparison with the blocking delay architecture from Lab 03.

### Demonstrate

Show both the timer-derived 1-second behavior and the independent main-loop activity.

Be prepared to explain why Timer2 allows the processor to keep doing useful work between timing events.

### Complete When

Part 2 is complete when the 1-second behavior is derived from Timer2 ticks, no long blocking delay is used, and the independent main activity remains observable.

[Back to top](#top) · [Course home](../README.md)

<a id="part-3"></a>
## Part 3 - Timed Intersection State Machine

### Goal

Control a two-direction traffic signal with explicit timed states using the Timer2 system tick.

Use six LEDs:

- North/South red, yellow, green;
- East/West red, yellow, green.

Vehicle sensors are **not** used in this part.

### Required states

Implement four normal states:

| State | North/South | East/West | Duration |
| --- | --- | --- | ---: |
| NS Green | Green | Red | 5 s |
| NS Yellow | Yellow | Red | 1 s |
| EW Green | Red | Green | 5 s |
| EW Yellow | Red | Yellow | 1 s |

Then repeat.

No state may display conflicting green indications.

### Required behavior

- Use the 20 ms Timer2 system tick.
- Represent the active traffic state explicitly in software.
- Represent elapsed state time with timer-derived ticks.
- State transitions occur from elapsed-time logic, not long delay calls.
- The ISR must not contain the 5-second or 1-second state wait.
- Main performs the state-machine decisions and output updates.
- The four states repeat continuously in the required order.
- Red, yellow, and green outputs must always agree with the documented state.

At 20 ms per tick, derive the tick counts required for the 5-second and 1-second states.

### Before Lab

Prepare:

- six-LED schematic and loading analysis;
- PORT output map;
- state diagram or flowchart;
- state/output safety table;
- tick-count calculations;
- GPR/state map;
- source code;
- expected measured state durations.

### In the Lab

1. Verify each output independently before running the complete sequence.
2. Run the state machine continuously.
3. Measure at least one 5-second green interval.
4. Measure at least one 1-second yellow interval.
5. Verify the complete NS/EW sequence.
6. Attempt to identify any transient or invalid output combination during state changes.
7. Compare measured durations with the 20 ms tick design.

### Evidence

Include or reference:

- schematic/loading analysis;
- output map;
- state diagram/flowchart;
- safety table;
- timing calculations;
- final source;
- measured 5-second and 1-second intervals;
- explanation of how the state and elapsed time are represented;
- troubleshooting record.

### Demonstrate

Show several complete cycles.

Be prepared to explain:

- why the design is a state machine rather than a sequence of delay calls;
- where the state duration comes from;
- why the processor is still available between timing events;
- how the design prevents conflicting green outputs.

### Complete When

Part 3 is complete when the four-state intersection sequence runs continuously with correct safe outputs and measured durations agree with the design within one 20 ms system tick plus normal measurement uncertainty.

[Back to top](#top) · [Course home](../README.md)

<a id="part-4"></a>
## Part 4 - Demand-Responsive Intersection

### Goal

Add two asynchronous traffic-demand inputs while preserving the timed state machine and safe traffic-light behavior.

Use:

- one sensor input for North/South demand;
- one sensor input for East/West demand.

Use interrupt-on-change for the two sensor inputs so a short request does not depend on main-loop polling timing.

### Event-latching requirement

A sensor activation must be remembered in software until the state machine has acted on it.

A verified **20 ms active sensor pulse must not be lost**.

The IOC service path should do only the work needed to resolve the PORTB change condition, identify active request input(s), latch request state, clear the interrupt condition correctly, and return.

Do not place long traffic-control logic or timed waits inside the IOC ISR.

### Decision rules

Traffic direction decisions are made at the end of each 5-second green interval.

- If **neither direction** has demand, alternate directions.
- If **both directions** have demand, alternate directions.
- If **only one direction** has demand, that direction receives the next 5-second green interval.
- If the selected direction is already green, begin another 5-second interval without inserting an unnecessary yellow transition.
- If the selected direction is the opposite direction, complete the 1-second yellow state before changing which direction is green.
- Once a yellow transition begins, finish that transition. New requests are latched for a later decision.
- A request for the direction receiving a new 5-second green interval may be cleared when that service interval begins.
- If that sensor remains physically active, the current input level must still be considered at the next decision point.

The traffic-light safety rules from Part 3 always take priority over traffic demand.

### Before Lab

Prepare:

- updated schematic with both sensor inputs;
- IOC SFR documentation;
- input map and output map;
- request-latch GPR map;
- updated main/ISR flowchart;
- state-transition decision logic;
- test table covering all required demand conditions;
- a method for producing and measuring a 20 ms sensor pulse;
- source code.

Your test table must include at least:

| Test | NS demand | EW demand | Expected scheduling behavior |
| --- | --- | --- | --- |
| A | none | none | alternate |
| B | active | active | alternate |
| C | active only | none | select/continue NS |
| D | none | active only | select/continue EW |
| E | request arrives for opposite direction during green | varies | finish current 5 s interval, then transition |
| F | request arrives during yellow | varies | latch request; finish committed yellow transition |
| G | 20 ms request pulse | one direction | request is captured and later acted on |

### In the Lab

1. Verify each sensor independently.
2. Verify IOC request latching before integrating the complete traffic logic.
3. Run the no-demand case.
4. Run the both-demand case.
5. Run NS-only demand for multiple decision intervals.
6. Run EW-only demand for multiple decision intervals.
7. Inject an opposite-direction request during an active green interval.
8. Inject a request during yellow.
9. Apply a measured 20 ms request pulse and prove that it is captured.
10. Verify that no test creates conflicting green indications.
11. Stress the design with closely spaced sensor and Timer2 events.

### Evidence

Include or reference:

- updated schematic/loading analysis;
- IOC and Timer2 SFR documentation;
- input/output maps;
- request/state GPR map;
- final flowchart;
- final source;
- completed demand test table with observed results;
- oscilloscope evidence of the 20 ms sensor pulse;
- evidence showing that the short pulse produced a latched request;
- timing measurements;
- safety verification;
- troubleshooting record.

### Demonstrate

The instructor may vary the timing and order of the two sensor inputs.

Be prepared to explain:

- how Timer2 and IOC share the common interrupt vector;
- how the ISR determines which source needs service;
- why a 20 ms request is not dependent on polling alignment;
- what information is latched and when it is cleared;
- why the state machine makes scheduling decisions outside the ISR;
- what happens when a request arrives during green or yellow;
- how the design guarantees safe output combinations.

### Complete When

Part 4 is complete when the controller passes the demand test table, captures a verified 20 ms request, keeps Timer2 timing active, and never produces a conflicting traffic-light state.

[Back to top](#top) · [Course home](../README.md)

<a id="mastery"></a>
## Mastery - XC8 C Timer Bridge

**Optional. Complete Parts 1-4 first.**

**Bonus:** Completing this Mastery challenge earns **+5 percentage points on this lab assignment**, equivalent to offsetting one day of the course's 5%-per-day late penalty.

### Goal

Recreate the Part 1 and Part 2 Timer2 time-base behavior in **XC8 C** using direct register access.

The goal is not to hide Timer2 behind a library. It is to connect the same hardware model to a second language.

### Required behavior

- Use the same PIC16F883, 4 MHz oscillator, Timer2 interval, and measured outputs as Parts 1 and 2.
- Configure Timer2 with direct SFR access.
- Use an interrupt service routine.
- Do not use a high-level delay/timer library to create the system tick.
- Produce the same nominal 20 ms interrupt interval.
- Produce the same 1-second derived behavior.
- Keep independent main-loop activity observable.

### Evidence

Include:

- XC8 C source;
- register-setting comparison between pic-as and XC8 C;
- measured timing comparison;
- a small generated-assembly excerpt showing where at least one Timer2 SFR operation and ISR-related operation appear;
- a short explanation of what changed because of language syntax and what did not change because the hardware is the same.

### Demonstrate

Show that the XC8 C version produces the same measured timer behavior as the assembly version.

Be prepared to trace one Timer2 configuration setting from the data sheet to the assembly source, the C source, and the generated assembly.

### Complete When

Mastery is complete when the XC8 C implementation reproduces the same hardware timing behavior and you can explain the assembly/C correspondence without treating the compiler as a black box.

[Back to top](#top) · [Course home](../README.md)

<a id="submission"></a>
## Submission and Checkoff

Use one Git repository for this assignment, following the [RCET3375 Lab Standard](../LAB_STANDARD.md).

Your final repository must contain enough information to reopen, rebuild, inspect, and verify the assignment, including:

- complete MPLAB project source;
- schematic source/export as applicable;
- required evidence;
- readable lab-book PDF;
- final flowchart/state diagram;
- measurement captures;
- documentation needed to understand the final design.

Push the repository to GitHub before final checkoff.

A part is not complete until the required behavior works, the evidence is present, and you can explain the design decisions and measurements.

[Back to top](#top) · [Course home](../README.md)
