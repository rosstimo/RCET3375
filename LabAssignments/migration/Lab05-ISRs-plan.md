# Lab 05 - Interrupt Service Routines Migration Plan

Status: initial curriculum analysis only. This is not student-facing lab instruction.

## Legacy source

- Inherited assignment: `../old/Lab06-ISRs.pdf`
- Renumbered Markdown recreation: `../Lab05-ISRs.md`
- New sequence position: Lab 05, following Lab 04 - Funky Muzak

## Essence of the lab

Students should leave this lab able to explain and implement interrupt-driven execution on the PIC16F883: what event causes an interrupt, how the processor reaches the interrupt vector, how software determines the source, what an ISR should and should not do, how flags and enables interact, and how execution safely returns to the interrupted program.

The most valuable idea is the contrast between a processor that repeatedly polls for work and a processor that continues useful main-line execution until hardware requests service.

## Builds on

- PIC16F883 I/O configuration and SFR documentation
- program flow and subroutines
- software timing and instruction-cycle awareness
- input scanning from earlier labs
- reusable source organization and flowcharts

## Prepares for

- Timer interrupts in Lab 06
- ADC interrupt/event handling
- UART receive/transmit events
- I2C/MSSP events
- event-driven embedded-system architecture

## Keep from the inherited lab

- polling versus interrupts as the conceptual entry point
- external events visibly changing system behavior
- requirement that the main program continue doing something observable
- multiple interrupt sources
- explicit attention to stack behavior and nested calls
- instructor attempts to break the design rather than only observing the happy path

## Reduce or remove

- long blocking two-second delays inside an ISR as the normal pattern; this teaches an ISR habit that later labs should undo
- dependence on the dot-matrix display if it adds wiring effort without improving interrupt understanding
- treating the PIC16F883 as though it has multiple hardware interrupt vectors or native interrupt priority
- requiring nested interrupts for ordinary completion unless the learning payoff justifies the extra complexity
- repeated documentation that can be referenced from previous lab-book pages

## Create or clarify

- exact PIC16F883 interrupt vector behavior and single-vector architecture
- interrupt enable hierarchy, source flags, and source identification
- explicit difference between an interrupt source, enable bit, flag bit, and global enable
- ISR latency and observable response time
- ISR design rule: do the minimum necessary work, capture/clear the event, and return
- handling events in main code using flags/state set by the ISR
- what context must be preserved in pic-as and what the toolchain may generate in XC8
- stack-depth limits and what actually causes stack trouble on this device
- deterministic handling when more than one flag is set
- switch bounce as an event-quality issue, without letting debounce dominate the interrupt lesson

## Proposed new lab architecture

### Part 1 - External interrupt proof of life

Configure the external interrupt and make each valid interrupt produce a simple observable state change, such as incrementing an output value. Students identify every required SFR/bit and demonstrate that main-line code is not polling the input.

### Part 2 - Main work plus asynchronous event

Run an obvious continuous main task while an interrupt captures an external event. The ISR should update state or set a flag and return quickly. Main code performs any longer visible action. Measure or otherwise demonstrate that the main task resumes correctly.

### Part 3 - Multiple interrupt sources

Add a second interrupt-capable source appropriate to the PIC16F883, likely PORTB interrupt-on-change rather than pretending RB1 is a second external INT pin. Require deterministic source identification, flag handling, and behavior when events occur close together.

### Part 4 - Event-driven integration

Integrate interrupts with a useful subsystem already developed earlier in the course. Candidate applications include asynchronous note/input events, a small event counter, or another bounded system where the main loop has useful work independent of the interrupts. The emphasis should be architecture and troubleshooting rather than more wiring.

### Part 5 - Mastery: controlled nesting / stack investigation

Preserve the inherited stack-overflow idea as an optional investigation. Students may deliberately re-enable interrupts under controlled conditions, observe nested service, determine the failure mode, and explain why unrestricted nesting is dangerous on this processor. This should not establish nested ISRs as the normal design pattern.

## Assembly and embedded C strategy

Assembly should remain primary for the first portions because the vector, `RETFIE`, flag handling, banked SFR access, context, and stack behavior are the concepts being taught. A later comparison with an XC8 interrupt function could be useful after students can explain what the compiler is arranging for them.

Do not let the C syntax replace the hardware model. If C is included here, require students to inspect the generated assembly/listing or map enough compiler behavior back to the same vector, flags, and registers.

## Hardware and software reuse

Prefer the existing PIC minimum system and previously used buttons/switches. Avoid introducing a new display subsystem solely for this lab. Reuse prior source organization and create a reusable interrupt setup/service structure that can carry directly into the timer lab.

## Meaningful evidence

- interrupt-related SFR maps and references
- flowchart showing main-line work and ISR interaction
- source with vector and flag handling visible
- measurement or observation of interrupt response/latency when practical
- proof that the event is handled without polling in main code
- test where two events occur close together
- troubleshooting record for missed/repeated interrupts

## Questions to resolve during redesign

- Which exact two hardware interrupt sources give the cleanest progression on the PIC16F883 with the existing lab hardware?
- What observable main task gives the clearest proof that interrupt service is asynchronous without adding busy work?
- Should the first XC8 interrupt example appear here or in the timer lab, where the C transition may be more natural?
- Is switch bounce intentionally exposed, mitigated in hardware, or handled as a short side investigation?
