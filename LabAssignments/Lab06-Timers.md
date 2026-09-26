<a id="top"></a>

# RCET 3375 Lab 06 - Timers and Event-Driven State

[RCET3375 course home](../README.md)

PIC16F883 | pic-as | Hardware Timers | Interrupt Timing | Packed State | PORTB IOC | Traffic Control

## Contents

- [Purpose](#purpose)
- [Standards and references](#standards-references)
- [Equipment and materials](#equipment-materials)
- [Part 1 - 20 ms timer proof of life](#part-1)
- [Part 2 - Timed intersection state machine](#part-2)
- [Part 3 - Interrupt-driven intersection state machine](#part-3)
- [Part 4 - Complete intersection RUN/DEBUG](#part-4)
- [Part 5 - Mastery](#part-5)
- [Submission and checkoff](#submission)

<a id="purpose"></a>
## Purpose

Build a traffic-signal controller that uses timed phases and car-detection inputs to decide when traffic should continue in the current direction and when the intersection should change directions.

Normal operation uses a **5-second green interval** and a **1-second yellow transition**. Later in the lab, car-detection sensors allow the controller to respond to traffic activity instead of changing directions blindly at the end of every green interval.

You will use hardware timers to create the required timing and explore the idea of a **state machine** to keep track of what the intersection is doing and what has happened during the current timing interval.

Part 1 begins with a smaller timer exercise so you can measure timer-interrupt behavior directly before applying timers to the intersection.

[Back to top](#top) · [Course home](../README.md)

<a id="standards-references"></a>
## Standards and references

- [RCET 3375 Lab Standard](../LAB_STANDARD.md)
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md)
- [RCET 3373 PIC16F883 Timers](https://github.com/rosstimo/RCET3373/blob/main/Topics/timers.md)
- [RCET Flowchart Guide](https://github.com/rosstimo/RCET3371/blob/main/Guides/Flowcharts/RCET-Flowchart-Guide.md)
- [PIC16F882/883/884/886/887 Data Sheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf)
- [PICmicro Mid-Range MCU Family Reference Manual](https://ww1.microchip.com/downloads/en/DeviceDoc/33023A.pdf)
- previous RCET3375 lab-book documentation and source for interrupts, context saving, digital I/O, masking, and measurement

The PIC16F883 data sheet and the Family Reference Manual are the authority for timer operation, interrupt flags/enables, PORTB interrupt-on-change behavior, register settings, reset states, and electrical limits.

[Back to top](#top) · [Course home](../README.md)

<a id="equipment-materials"></a>
## Equipment and materials

- MPLAB X IDE and pic-as toolchain
- PICkit programmer/debugger
- PIC16F883 circuit
- 4 MHz crystal oscillator circuit
- six LEDs for the two traffic signals
- current-limiting resistors
- two digital car-detection inputs for Parts 3-4
- oscilloscope
- frequency counter or logic analyzer, optional
- breadboard, jumpers, and interface components as required
- lab book

[Back to top](#top) · [Course home](../README.md)

<a id="part-1"></a>
## Part 1 - 20 ms Timer Proof of Life

### Goal

Configure one PIC16F883 hardware timer to generate a periodic interrupt every **20 ms nominal**.

Use two diagnostic PORTA outputs to measure both the timer interrupt and the effect of the interrupt on main-loop execution.

For the course 4 MHz oscillator:

```text
FOSC = 4 MHz
FCY  = FOSC / 4 = 1 MHz
TCY  = 1 us
```


### Required diagnostic signals

Choose two available digital PORTA outputs and document them.

**Timer diagnostic pulse**

For every timer interrupt:

1. service the timer as required by your design;
2. drive the timer diagnostic output HIGH;
3. drive it LOW on the immediately following instruction.

The pulse should be as short as practical. The two output instructions should be adjacent, equivalent to:

```text
BSF PORTA,x
BCF PORTA,x
```

This produces one short diagnostic pulse every 20 ms.

**Main-loop diagnostic**

In main, continuously toggle the second PORTA diagnostic bit with no intentional delay.

The main-loop signal should make it easy to see where normal execution is interrupted and where it resumes.

### Timer-period boundary

Define **exactly** what marks the beginning of a new timer period for your chosen timer.

Place the rising edge of the timer diagnostic pulse as close as practical to that period boundary.

Then determine exactly how far the diagnostic rising edge leads or lags the timer-period boundary.

Do not assume the GPIO edge and the hardware timer event occur at the same instant.

### Required behavior

- 20 ms periodic timer interrupt.
- One very short PORTA diagnostic pulse per timer interrupt.
- A second PORTA diagnostic bit toggling continuously in main.
- Correct interrupt context save/restore.
- Correct timer flag service and reload/configuration behavior.
- No software-delay loop used to generate the timer period.
- Main resumes normally after every timer interrupt.

### Before Lab

Prepare:

- timer choice and reason;
- complete timer calculation;
- timer and interrupt SFR documentation;
- timer-period boundary definition;
- predicted timer diagnostic period;
- predicted instruction-cycle offset from the timer-period boundary to the diagnostic rising edge;
- selected PORTA diagnostic pins;
- main/ISR flowchart;
- source code.

### In the Lab

1. Verify the main-loop diagnostic signal before enabling the timer interrupt.
2. Enable the timer and verify one timer diagnostic pulse every 20 ms.
3. Display both PORTA diagnostic signals on the oscilloscope.
4. Observe where timer interrupt service disturbs the otherwise continuous main-loop diagnostic activity.
5. Measure the timer diagnostic pulse spacing.
6. Compare measured timing with the predicted 20 ms period.
7. Compare the observed diagnostic rising edge with your calculated timer-period boundary.
8. Explain the instruction path that creates the measured lead or lag.

The shortest diagnostic pulse may be difficult to trigger on or display cleanly. If measurement limitations require you to temporarily widen the pulse, change the test conditions, or use another instrument configuration, document:

- what was difficult to measure;
- what you changed;
- why the change was justified;
- whether the change affects the timing quantity being evaluated.

The final timing conclusion must still refer to the actual program behavior.

### Evidence

Include or reference:

- complete timer calculation;
- timer SFR documentation;
- main/ISR flowchart;
- final source;
- scope capture showing the short timer diagnostic pulse;
- scope capture showing main execution interrupted by timer service;
- measured 20 ms period;
- predicted versus measured timing;
- instruction-cycle calculation for diagnostic rising-edge lead/lag;
- measurement difficulties and any justified test modifications;
- troubleshooting record.

### Demonstrate

Show both diagnostic signals simultaneously.

Be prepared to trace execution from the timer event through interrupt entry, context save, timer service, diagnostic pulse, context restore, and return to main.

### Complete When

Part 1 is complete when the timer produces an accurately measured 20 ms periodic interrupt, both diagnostic signals clearly show timer and main execution, and you can account for the timer diagnostic rising-edge offset in instruction cycles and microseconds.

[Back to top](#top) · [Course home](../README.md)


<a id="part-2"></a>
## Part 2 - Intersection State Machine Logic

### Goal

Build and demonstrate the traffic-light state machine **without using a hardware timer**.

Use the dedicated external interrupt `INT` as a manual state-advance event. Each valid external interrupt increments a 4-bit `STATE_COUNT` field in `intersection_state`.

Use PORTB interrupt-on-change to latch car-detection events. Main evaluates the packed state and decides whether the current traffic direction remains selected or begins a transition register.

On every iteration of main, display the contents of `intersection_state` on PORTC so state byte can be observed on LEDs.

The purpose of this part is to make the state-machine logic observable as events occur and the state changes. Timing and actual traffic-light outputs are added later.

**Hint:** Much of this code will be reused in later parts. Consider how to structure your source so the state-machine logic is clear, encapsilated and reusable.

### Required state register

Use one GPR named `intersection_state`.

Choose and document its GPR address.

Use this register map:

| Bit | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name | SC3 | SC2 | SC1 | SC0 | TRANSITION | EW_DETECTED | NS_DETECTED | DIRECTION |

The upper nibble is a 4-bit `STATE_COUNT` field. 
The lower nibble contains the intersection flags.

| Field | Meaning |
| --- | --- |
| `STATE_COUNT[3:0]` | current manual state-machine count |
| `DIRECTION` | 0 = N/S direction; 1 = E/W direction |
| `NS_DETECTED` | a low-to-high N/S car-detection event has been latched |
| `EW_DETECTED` | a low-to-high E/W car-detection event has been latched |
| `TRANSITION` | 0 = selected direction is green; 1 = selected direction is yellow |

### Initial state

Begin with:

- `STATE_COUNT = 0`;
- `DIRECTION = 0` for N/S;
- `TRANSITION = 0`;
- both car-detection flags clear.

Main must copy this initial `intersection_state` value to PORTC.

### External state-advance interrupt

Use the dedicated external interrupt as the state-advance input.

Each valid external interrupt must increment only `STATE_COUNT` in bits 7:4 of `intersection_state`.

 `STATE_COUNT` must be incremented as part of a read-modify-write operation on the packed state byte. The lower four state flags must remain unchanged by the increment.

Document the external-interrupt configuration and the masks/operations used to:

- extract `STATE_COUNT`;
- position it for incrementing;
- increment it;
- place the updated value back into bits 7:4;
- preserve bits 3:0 in `intersection_state`;

### PORTB car detection

Use PORTB interrupt-on-change for two car-detection inputs:

- N/S car detection;
A **low-to-high** change on the N/S sensor sets `NS_DETECTED`.
- E/W car detection;
A **low-to-high** change on the E/W sensor sets `EW_DETECTED`.

Once set, a car-detection flag remains set until the state machine clears it. Repeated detections in the same direction do not count additional cars. The corresponding flag simply remains set.

### PORTC state display

On every iteration of main:

1. copy the complete `intersection_state` byte to PORTC;
2. then evaluate `STATE_COUNT` and the state flags;
3. update `intersection_state` only when the current state requires an action.

PORTC is therefore a direct live display of the packed state byte.

### State-count decisions

Main must examine `STATE_COUNT` and decide what action or test is required.

The required decision points are:

| STATE_COUNT | Required behavior |
| ---: | --- |
| 0 | do nothing |
| 1 | do nothing |
| 2 | do nothing |
| 3 | evaluate `DIRECTION`, `NS_DETECTED`, `EW_DETECTED`, and `TRANSITION` to decide whether to remain in the current direction or begin a transition |
| 4 | finish an active transition |

 Students must check the state count and decide what action or test, if any, is required for each value their program can encounter.

### Direction decision at STATE_COUNT = 3

At `STATE_COUNT = 3`, use the all four state flags to decide whether the selected traffic direction changes.

Develop the decision logic based on the following rules:

For N/S green:

| N/S detected | E/W detected | Action |
| ---: | ---: | --- |
| 1 | 0 | remain N/S |
| 0 | 1 | begin transition |
| 1 | 1 | begin transition |
| 0 | 0 | begin transition |

For E/W green:

| N/S detected | E/W detected | Action |
| ---: | ---: | --- |
| 0 | 1 | remain E/W |
| 1 | 0 | begin transition |
| 1 | 1 | begin transition |
| 0 | 0 | begin transition |

If the decision is **do not change direction** reset to a fresh state in the same direction.

- clear `STATE_COUNT`;
- clear `NS_DETECTED`;
- clear `EW_DETECTED`;

If the decision is **change direction**:

- set `TRANSITION`;

If `TRANSITION` is set do nothing.

Develop, simplify the logic, and document your complete truth table and simplification process.

Use the following truth table headers and show if the action taken will be **same direction**, **change direction**, or **do nothing**:

| T | D | NS | EW | Action |
| --- | --- | --- | --- | --- |
|   0 | 0 | 0 | 0 |  ... |

### Transition completion at STATE_COUNT = 4

When `STATE_COUNT = 4` complete the transistion to the new direction and reset to a freash state.

- toggle `DIRECTION`;
- clear `TRANSITION`;
- clear `NS_DETECTED`;
- clear `EW_DETECTED`;
- clear `STATE_COUNT`.

### Shared-state warning

The external-interrupt service, PORTB IOC service, and main loop all use `intersection_state`.

Because several parts of the program can modify different fields within the same byte, the packed state byte **can be corrupted** if updates interfere with one another.

Your implementation must prevent state corruption. Determine and document your own solution.

### Before Lab

Prepare or reference:

- external-interrupt input circuit and configuration;
- two PORTB car-detection inputs and loading/electrical analysis;
- external-interrupt and PORTB IOC SFR documentation;
- `intersection_state` register map;
- masks and packed-field operations for `STATE_COUNT` and the flags;
- complete state-machine flowchart that accounts for every `STATE_COUNT` value your program can encounter;
- source structure showing the read-modify-write operations on the packed state byte;
- source code, flowcharts.

### In the Lab

1. Verify the initial packed state with `STATE_COUNT = 0` and confirm that main copies `intersection_state` to PORTC.
2. Trigger the external interrupt and verify that only `STATE_COUNT` changes.
3. Advance through counts 0-F and confirm that main takes no state action other than displaying the current packed state on PORTC.
4. Verify a low-to-high N/S car-detection event sets `NS_DETECTED`.
5. Verify a low-to-high E/W car-detection event sets `EW_DETECTED`.
6. Verify high-to-low sensor changes do not set the detection flags.
7. Implement and test the `STATE_COUNT = 3` logic. Test and document all 16 combinations of the four state flags.
8. Implement and test the `STATE_COUNT = 4` transition completion logic.
9.  Repeat several complete manual state-machine cycles while observing the packed state on PORTC.
10.  Stress the design with external-interrupt and IOC events occurring close together and verify the packed state remains valid.

### Evidence

Include or reference:

- external-interrupt and car-detection schematics;
- loading/electrical analysis;
- interrupt and IOC SFR documentation;
- `intersection_state` register map;
- masks and packed-field operations;
- complete state-machine flowchart;
- evidence that main copies `intersection_state` directly to PORTC on every iteration;
- final source;
- evidence that the external interrupt increments only `STATE_COUNT`;
- evidence that only low-to-high car-detection events latch the corresponding flags;
- results for all count-3 car/direction decision cases;
- evidence of both remain-in-direction and transition paths;
- evidence that count 4 completes the transition correctly;
- evidence that packed state remains valid when interrupt events occur close together;
- troubleshooting record.

### Demonstrate

The instructor may generate external state-advance events and car-detection events in arbitrary sequences while observing `intersection_state` on PORTC.

Be prepared to explain:

- what each field in `intersection_state` represents;
- why the external interrupt changes only `STATE_COUNT`;
- how a low-to-high car-detection event is latched;
- what main checks at `STATE_COUNT = 3`;
- how `DIRECTION` and the car flags determine whether the intersection stays green or begins a transition;
- why `DIRECTION` does not toggle until `STATE_COUNT = 4`;
- why counts 0, 1, and 2 have no state action;
- why main copies the complete state byte to PORTC each iteration;
- how you prevent packed-state corruption.

### Complete When

Part 2 is complete when external interrupts advance the state count, PORTB IOC correctly latches low-to-high car detections, main displays the complete packed state on PORTC each iteration, the required direction/car decision occurs at count 3, and count 4 completes the transition correctly.

[Back to top](#top) · [Course home](../README.md)

<a id="part-3"></a>
## Part 3 - State Machine Intersection Timing

### Goal

Use the packed state byte stored in the `intersection_state` register to track and control the intersection timing. The `STATE_COUNNT` will now be incremented by a timer ISR. Choose a **single** timer duration interval and 0-F `STATE_COUNT` sequence that allows for both 5 second and 1 second intervals to be represented. PORTA will display the actual traffic light signals with the correct color LEDs. PORTC will display the real time state byte. **Car detection will be ignored in this section.** This section focuses on state driven timing.

**Hint:** Much of this code will be reused in later parts. Consider how to structure your source so the state-machine logic is clear, encapsilated and reusable.

The selected direction remains green for 5 seconds. The transition lasts 1 second.

### Required timing

Normal operation alternates:

```text
N/S green, E/W red       5 seconds
N/S yellow, E/W red      1 second
N/S red, E/W green       5 seconds
N/S red, E/W yellow      1 second
repeat
```

### Timer-driven STATE_COUNT

Reuse the packed `intersection_state` register and state-field definitions from Part 2.

In Part 3:

- the dedicated external interrupt is no longer used to advance `STATE_COUNT`;
- PORTB car-detection logic is not used;
- `NS_DETECTED` and `EW_DETECTED` remain clear;
- one selected hardware timer generates the periodic interrupt that advances `STATE_COUNT`.

Each timer interrupt increments only `STATE_COUNT` in bits 7:4 of `intersection_state`.

The lower four state flags must be preserved during the packed read-modify-write operation.

The timer ISR should service the timer, increment `STATE_COUNT`, and return. It does not decide which traffic lights should be on.

### Select one timing interval

Choose **one hardware timer** and **one periodic interrupt interval** for all normal intersection timing in this part.

Using that one timer interval, determine the `STATE_COUNT` value that represents:

- 5 seconds of green;
- 1 second of yellow.

Both durations must be represented by some multiple of timer interrupts and both required count values must fit within the 4-bit `STATE_COUNT` range of 0 through F.

You do not need to use the entire 0-F range.

Document:

- the timer selected;
- the timer configuration;
- the timer interrupt-period calculation;
- the selected periodic interval;
- the number of timer interrupts required for 5 seconds;
- the number of timer interrupts required for 1 second.

### STATE_COUNT map

Map out **every `STATE_COUNT` value from 0 through the highest count used by your design** before implementing the timed state machine.

For each count value, document what it represents and what main should do when:



| STATE_COUNT | Elapsed time | Required behavior |
| ---: | ---: | --- |
| 0 | ... | ... | ... |
| 1 | ... | ... | ... |
| ... | ... | ... | ... |

Include every count value in the range you selected, even when the required behavior is **do nothing**. Refer to section [State-count decisions](#state-count-decisions) in Part 2 for guidance.

The map should make the 5-second green boundary and 1-second yellow boundary unambiguous and should match the state-machine logic implemented in main.

### Timed state-machine rules

Use the same state flag logic developed in Part 2 to determine whether the intersection remains in the current direction or begins a transition. For this section the car-detection flags should remain clear and/or ignored.

### PORTA traffic-light outputs

Use PORTA to drive six LEDs representing:

- N/S red;
- N/S yellow;
- N/S green;
- E/W red;
- E/W yellow;
- E/W green.

Choose and document the PORTA bit assignment for each LED.

Main must decode `DIRECTION` and `TRANSITION` into the correct traffic-light outputs.

The four legal normal output states are:

| DIRECTION | TRANSITION | N/S lights | E/W lights |
| ---: | ---: | --- | --- |
| 0 | 0 | Green | Red |
| 0 | 1 | Yellow | Red |
| 1 | 0 | Red | Green |
| 1 | 1 | Red | Yellow |

Document the exact PORTA binary/hex patterns for each state.

The current traffic-light pattern must be updated on every iteration of main based on the current `DIRECTION` and `TRANSITION` values.

### PORTC state display

PORTC must continue to display the complete packed `intersection_state` byte on every iteration of main.

### Shared-state behavior

The timer ISR and main both access `intersection_state`.

Reuse or adapt the state-protection method developed in Part 2 so timer-driven `STATE_COUNT` updates and main-loop flag changes do not corrupt the packed state byte.

Document any changes required when the manual external-interrupt state advance from Part 2 is replaced by periodic timer interrupts.

### Before Lab

Prepare or reference:

- selected hardware timer and reason for the choice;
- complete timer interrupt-period calculation and configuration;
- calculated `STATE_COUNT` values for the 5-second and 1-second intervals;
- complete `STATE_COUNT` map for every value from 0 through the highest count used;
- timer and interrupt SFR documentation;
- `intersection_state` register map from Part 2;
- packed-field masks and read-modify-write operations used to increment and clear `STATE_COUNT`;
- PORTA traffic-light schematic and loading/electrical analysis;
- PORTA bit assignments and the binary/hex value for all four legal traffic-light states;
- updated ISR flowchart;
- complete timed state-machine flowchart;
- source code.

### In the Lab

1. Disable the Part 2 external-interrupt state advance and car-detection behavior.
2. Verify both car-detection flags remain clear.
3. Verify the selected timer generates the periodic interrupt interval you calculated.
4. Observe `STATE_COUNT` increment on PORTC and verify the lower four state bits remain unchanged by the timer ISR.
5. Step through the complete `STATE_COUNT` range used by your design and verify each value behaves as documented in your state-count map.
6. Verify N/S begins green with E/W red.
7. Measure the N/S green interval and verify it lasts 5 seconds.
8. Verify the state changes to N/S yellow, `TRANSITION` sets, and `STATE_COUNT` restarts for the yellow interval.
9. Measure the N/S yellow interval and verify it lasts 1 second.
10. Verify the yellow interval completes by toggling `DIRECTION`, clearing `TRANSITION`, clearing `STATE_COUNT`, and beginning E/W green.
11. Repeat the same checks for the E/W green and yellow states.
12. Observe several complete cycles while comparing the PORTA traffic-light outputs with the packed state shown on PORTC.
13. Verify no state produces conflicting green outputs.
14. Compare the measured 5-second and 1-second intervals with your calculated values and document any timing error.
15. Verify the packed state remains valid when a timer interrupt occurs near a main-loop state update.

### Evidence

Include or reference:

- timer selection, configuration, and interrupt-period calculation;
- calculated timer counts for 5 seconds and 1 second;
- complete `STATE_COUNT` map covering every count value used by the design;
- timer/interrupt SFR documentation;
- packed `intersection_state` register map and masks;
- updated timer ISR and timed state-machine flowcharts;
- PORTA traffic-light schematic, loading analysis, bit map, and four legal output values;
- final source;
- evidence that timer interrupts increment only `STATE_COUNT`;
- evidence that both car-detection flags remain clear;
- evidence that PORTC displays the complete packed state during operation;
- measured 5-second green interval;
- measured 1-second yellow interval;
- comparison of predicted and measured timing;
- evidence of correct N/S and E/W green/yellow sequencing;
- evidence that no invalid traffic-light state occurs;
- troubleshooting record.

### Demonstrate

Show the intersection operating continuously while PORTC displays the packed state in real time.

Be prepared to explain:

- why one timer interval can represent both required durations;
- how you selected the timer interval and the two required `STATE_COUNT` values;
- what every value in your selected `STATE_COUNT` range means and why some values require action while others do not;
- why the timer ISR increments `STATE_COUNT` but does not make the traffic-light decision;
- how `DIRECTION` and `TRANSITION` determine the PORTA output pattern;
- why `STATE_COUNT` is cleared at each timing boundary;
- why `DIRECTION` changes only after the 1-second yellow transition completes;
- why the car-detection flags remain unused in Part 3;
- how shared access to `intersection_state` is kept valid.

### Complete When

Part 3 is complete when one hardware timer and one periodic interrupt interval drive the packed `STATE_COUNT`, every count value in the selected range is mapped and behaves as documented, the intersection repeatedly produces accurate 5-second green and 1-second yellow intervals in both directions, PORTA displays only the four legal traffic-light states, PORTC displays the real-time packed state, and the state byte remains valid during timer and main-loop updates.

[Back to top](#top) · [Course home](../README.md)

<a id="part-4"></a>
## Part 4 - Complete Intersection

### Goal

Combine the **state-machine and car-detection logic from Part 2** with the **timer-driven sequencing and traffic-light outputs from Part 3** to create the complete working intersection.

Do not redesign those sections from scratch. Reuse the working logic, packed `intersection_state`, timer configuration, car-detection behavior, PORTA traffic-light outputs, PORTC state display, and shared-state protection already developed and documented.

Add one new feature: use an otherwise unused PORTB input as a **RUN/DEBUG mode selector**.

- **RUN mode:** the selected hardware timer advances `STATE_COUNT`.
- **DEBUG mode:** the dedicated external interrupt `INT` advances `STATE_COUNT` manually.

The state machine itself must behave the same in either mode. Only the source of the state-count increment changes.

### RUN / DEBUG mode selection

Choose and document one unused PORTB pin for the mode selector.

The mode-selector input is not a car sensor and must not alter either car-detection flag.

You may choose and document which logic level represents RUN and which represents DEBUG.

The required behavior is:

| Mode | Timer may advance STATE_COUNT | INT may advance STATE_COUNT |
| --- | --- | --- |
| RUN | Yes | No |
| DEBUG | No | Yes |

Changing the mode-selector input must **not** increment `STATE_COUNT` by itself.

When changing between modes:

- retain the current `intersection_state`;
- retain the current traffic-light state;
- retain any latched car-detection flags;
- ensure only the selected state-advance source can change `STATE_COUNT`;
- prevent stale or pending interrupt conditions from causing an unintended increment.

How you enable, disable, ignore, or service the unselected interrupt source is part of your design. Document the method you use.

### Complete intersection behavior

The completed Part 4 program must combine the behavior already established in the previous parts:

- use the Part 2 packed state byte and car-detection decision logic;
- use PORTB IOC to latch the N/S and E/W car-detection events as developed in Part 2;
- use the Part 3 timer configuration and count values for the 5-second green and 1-second yellow intervals;
- use the Part 3 PORTA traffic-light output decoding;
- continue displaying the complete `intersection_state` byte on PORTC on every main-loop iteration;
- preserve the shared packed state correctly when interrupts and main modify different fields.

In **RUN mode**, the intersection operates continuously using the timer.

In **DEBUG mode**, the same state machine is stepped manually with `INT`, allowing individual state-count changes, car detections, and state decisions to be observed and tested.

The Part 2 car-detection decision rules apply at the end of the green interval. The Part 3 timing and traffic-light behavior apply to the complete intersection. Refer to those parts rather than creating a second implementation of the same logic.

### Before Lab

Prepare or reference:

- the completed Part 2 state-machine logic, truth table, car-detection inputs, and packed-state operations;
- the completed Part 3 timer configuration, timing calculations, PORTA traffic-light map, and timed state-machine flow;
- selected PORTB RUN/DEBUG input and its logic definition;
- any new SFR/pin documentation required for the mode selector;
- an updated ISR/main flowchart showing how the selected mode determines whether the timer or `INT` may advance `STATE_COUNT`;
- the method used to prevent the unselected interrupt source or a mode change from creating an unintended state increment;
- final integrated source code.

Do not recreate documentation from Parts 2 or 3 when it has not changed. Reference it.

### In the Lab

1. Verify the RUN/DEBUG selector and confirm changing modes does not itself change `STATE_COUNT`.
2. In DEBUG mode, verify timer interrupts do not advance `STATE_COUNT`.
3. In DEBUG mode, use `INT` to step through the state machine while observing `intersection_state` on PORTC.
4. Use DEBUG mode to verify car detections and the Part 2 end-of-green decision cases with the actual PORTA traffic-light outputs.
5. Verify a manual transition completes correctly and the next direction begins in the correct green state.
6. Switch to RUN mode without resetting the program and verify `INT` no longer advances `STATE_COUNT`.
7. In RUN mode, verify the timer advances the same state machine automatically.
8. Verify the 5-second green and 1-second yellow timing from Part 3 with car detection active.
9. Exercise N/S-only, E/W-only, both, and no-car detection cases during normal timed operation and verify the Part 2 decision logic is preserved.
10. Change between RUN and DEBUG at several points in the state sequence and verify no mode change creates a false count, loses a latched car detection, corrupts the packed state, or creates an invalid traffic-light output.
11. Stress the complete design with timer, `INT`, and car-detection events occurring near one another.
12. Verify PORTC continues to show the packed state and PORTA continues to show the corresponding traffic-light state.

### Evidence

Include or reference:

- Part 2 state-machine/car-detection documentation;
- Part 3 timer, timing, and traffic-light documentation;
- RUN/DEBUG selector pin assignment and logic definition;
- updated integrated flowchart;
- final source;
- evidence that only `INT` advances `STATE_COUNT` in DEBUG mode;
- evidence that only the timer advances `STATE_COUNT` in RUN mode;
- evidence that changing modes does not itself increment the state count;
- evidence that car-detection state is retained correctly through normal operation and mode changes;
- results showing the Part 2 car-decision behavior works with the Part 3 traffic-light outputs;
- measured RUN-mode 5-second green and 1-second yellow intervals;
- evidence that PORTC state and PORTA traffic outputs remain consistent;
- mode-change and close-event stress-test results;
- troubleshooting record.

### Demonstrate

Demonstrate the complete intersection in both modes.

In **DEBUG mode**, step the intersection manually with `INT` and use car-detection events to show how the packed state drives the decision logic.

Without resetting the processor, switch to **RUN mode** and show the same state machine operating automatically from the timer.

Be prepared to explain:

- how Parts 2 and 3 were integrated without duplicating their logic;
- how the RUN/DEBUG input selects the state-advance source;
- why the unselected source cannot advance `STATE_COUNT`;
- how mode changes avoid false state increments;
- how car detections affect the end-of-green decision;
- how PORTA traffic-light outputs relate to the packed state displayed on PORTC;
- how shared-state corruption is prevented.

### Complete When

Part 4 is complete when the full car-responsive traffic intersection operates correctly in RUN mode, the same state machine can be stepped manually in DEBUG mode, only the selected source advances `STATE_COUNT`, mode changes do not disturb the current state, and the Part 2 decision behavior and Part 3 timing/output behavior remain correct when combined.

[Back to top](#top) · [Course home](../README.md)

<a id="part-5"></a>
## Part 5 - Mastery: Train-Crossing Override

**Optional. Complete Parts 1-4 first.**

**Bonus:** Completing this Mastery challenge earns **+5 percentage points on this lab assignment**, equivalent to offsetting one day of the course's 5%-per-day late penalty.

### Goal

Add a train-crossing override to the completed Part 4 intersection.

When a train is detected:

- both traffic directions immediately leave normal operation;
- both directions continuously alternate between yellow and red every 0.5 seconds;
- flashing continues for as long as the train is present.

When the train is no longer detected:

- normal intersection operation resumes;
- the direction that was active before the train event resumes green;
- that direction receives a fresh 5-second interval;
- car-detection state starts fresh.

### Design freedom

The required **behavior** is fixed, but the implementation is yours.

You may choose:

- interrupt-driven or polled train detection;
- timer-based or inline-delay flashing;
- additional GPR state or some other indicator for the train present override;
- how you preserve the pre-train direction;
- how you handle the transition from normal operation to the train override;
- how you handle the transition from the train override back to normal operation;
- how you determine that the train is no longer present.

The Part 4 implementation must continue to work correctly before and after the override.

Document and justify the design choices you make. Your justification should address:

- responsiveness to train detection;
- effect on normal Part 4 timing and interrupts;
- simplicity and readability;
- timing accuracy of the 0.5-second flashing;
- how normal state is safely preserved/restored.

### Required behavior

- Train detection causes an immediate override of normal traffic operation.
- Both directions display yellow together for 0.5 seconds.
- Both directions display red together for 0.5 seconds.
- Yellow/red flashing repeats continuously while the train remains present.
- No normal green indication is allowed while the train override is active.
- The previously active traffic direction is preserved.
- When the train clears, that direction resumes **green** for a fresh 5 seconds.
- Both car-detection flags begin fresh after normal operation resumes.
- The original Part 4 car-detection behavior still works after recovery.

### Before Lab

Prepare:

- train-detection hardware and input assignment;
- train-override flowchart;
- selected train-detection method;
- selected 0.5-second timing method;
- explanation of how the previous direction is preserved;
- explanation of how Part 4 state is restored;
- source code.

### In the Lab

1. Verify train detection.
2. Trigger the train during N/S green.
3. Verify immediate entry into the yellow/red flashing override.
4. Measure the 0.5-second flashing intervals.
5. Keep the train present through several yellow/red cycles.
6. Clear the train condition.
7. Verify N/S resumes green for a fresh 5 seconds with fresh car-detection state.
8. Repeat from E/W green.
9. Trigger the train during a normal yellow transition and verify your documented recovery behavior preserves the direction that was active before the transition completed.
10. Verify normal Part 4 car-detection logic operates correctly after the override ends.

### Evidence

Include or reference:

- train-detection schematic and input documentation;
- train-override flowchart;
- final source;
- design-choice justification;
- measured 0.5-second flashing intervals;
- evidence that flashing continues while the train remains present;
- evidence that the previous direction resumes for a fresh 5 seconds;
- evidence that car-detection state is fresh after recovery;
- evidence that Part 4 behavior still works;
- troubleshooting record.

### Demonstrate

The instructor may introduce and remove the train condition at arbitrary points in normal operation.

Be prepared to explain why you selected your train-detection and timing methods and how your design prevents the Mastery feature from breaking the Part 4 intersection.

### Complete When

Mastery is complete when the train override meets the required visible behavior, your implementation choices are documented and justified, normal operation resumes correctly, and the original Part 4 behavior remains intact.

[Back to top](#top) · [Course home](../README.md)

<a id="submission"></a>
## Submission and Checkoff

Use one Git repository for this assignment, following the [RCET3375 Lab Standard](../LAB_STANDARD.md).

Your final repository must contain enough information to reopen, rebuild, inspect, and verify the assignment, including:

- complete MPLAB project source;
- schematic source/export as applicable;
- required measurement evidence;
- readable lab-book PDF;
- final flowcharts;
- completed register maps and state tables;
- documentation needed to understand the final design.

Push the repository to GitHub before final checkoff.

A part is not complete until the required behavior works, the evidence is present, and you can explain the state, timing, interrupt, packed-field, and measurement behavior.

[Back to top](#top) · [Course home](../README.md)
