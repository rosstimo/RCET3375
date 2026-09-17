# Lab 06 - Timers Migration Plan

Status: initial curriculum analysis only. This is not student-facing lab instruction.

## Legacy source

- Inherited assignment: `../old/Lab07-Timers.pdf`
- Renumbered Markdown recreation: `../Lab06-Timers.md`
- New sequence position: Lab 06, following the interrupt lab

## Essence of the lab

Students should learn to turn a hardware timer into a reliable time base for an embedded system. The important transition is from blocking software delays to event-driven timing where the processor can continue doing useful work between timer events.

The intersection controller is valuable because it naturally requires timed states, asynchronous inputs, and deterministic transitions. It should be used to teach timer configuration plus state-machine design, not merely as a large coding exercise.

## Builds on

- interrupt configuration and ISR discipline from Lab 05
- software delay timing from Lab 03
- input handling and output control
- flowcharts and program decomposition

## Prepares for

- periodic sampling for ADC work
- servo timing
- communication timeouts and scheduling
- PID/control-loop sample timing
- general nonblocking embedded-system design

## Keep from the inherited lab

- Timer2 as a concrete peripheral to configure and reason about
- intersection-control application
- 5-second green and 1-second yellow timing requirements
- two independent traffic-demand inputs
- requirement that a short 20 ms sensor event not be missed
- use of interrupts together with timers

## Reduce or remove

- the unexplained requirement that the timer interrupt exactly 240 times per cycle; retain a count only if students derive why that count is correct from the selected timer interval
- wiring complexity that does not contribute to timer/state-machine understanding
- any implementation that simply replaces one blocking delay with a long ISR
- vague statements such as timers replacing delays without showing the architectural consequence

## Create or clarify

- Timer2 block behavior on the PIC16F883
- oscillator/instruction clock relationship to timer timing
- prescaler, `PR2`, postscaler, timer flag, and interrupt enable calculations
- difference between timer period, interrupt period, and application-level state duration
- how to create a periodic system tick and count ticks without blocking
- state-machine representation for traffic-light states
- event latching so a 20 ms request is not lost between state transitions
- safe light-state transitions that never allow conflicting green indications
- measurement of the actual timer-derived interval

## Proposed new lab architecture

### Part 1 - Timer2 proof of life

Configure Timer2 to produce a calculated periodic interrupt. Toggle or pulse a test output in a controlled way so the timer interval can be measured with the oscilloscope or frequency counter. Require nominal calculation, measured timing, and comparison.

### Part 2 - Replace a software delay with a hardware time base

Use the timer tick to perform a familiar timed behavior while main code continues executing an observable independent task. This makes the architectural difference between blocking delay loops and timer-driven scheduling visible.

### Part 3 - Timed intersection state machine

Implement the normal N/S and E/W sequence using timer-derived state durations. The design should be explicitly state-based rather than a chain of long delay calls.

### Part 4 - Demand-responsive intersection

Add the two vehicle sensors. A short demand pulse must be captured and remembered until the state machine can act on it. Require behavior for no traffic, both directions requesting, one direction requesting, and requests arriving during an active state.

### Part 5 - Mastery

Possible bounded extensions include pedestrian-request timing, minimum/maximum green constraints, fault-safe output checking, or a second timing source. Choose one specific challenge when the lab is finalized rather than offering a vague menu.

## Assembly and embedded C strategy

This is a strong candidate for the first deliberate assembly-to-C bridge.

Recommended approach:

- configure and prove Timer2 directly in pic-as first so students see every register and timing calculation;
- then implement an equivalent small timer-driven behavior in XC8 C using direct register access;
- inspect the generated assembly enough to connect the C ISR and register operations to the hardware model;
- allow the larger intersection application to use whichever language best matches the course plan, with a preference toward beginning meaningful embedded C here if readiness is good.

Do not hide Timer2 behind a high-level timing library.

## Hardware and software reuse

Reuse the same PIC minimum system and simple LEDs/switches already familiar to students. The timer initialization and system-tick pattern should become reusable source for later ADC/servo, communications, and control labs.

## Meaningful evidence

- timer calculations from oscillator frequency through interrupt interval
- complete Timer2-related SFR documentation
- measured timer-derived waveform
- predicted versus measured error
- state diagram/flowchart for the intersection controller
- proof that the main loop remains responsive while timing occurs
- test evidence for a 20 ms sensor event
- truth table or explicit safety analysis preventing conflicting greens
- troubleshooting notes for timing or missed-event problems

## Questions to resolve during redesign

- What timer interrupt interval gives useful measurement resolution while keeping the application math understandable?
- Should the intersection application be the first required XC8 C program or should C appear as a smaller comparison within this lab?
- What hardware representation of the two traffic directions is simplest and least distracting?
- Should vehicle requests use interrupt-on-change, main-loop sampling against the timer tick, or a deliberate comparison of both?
