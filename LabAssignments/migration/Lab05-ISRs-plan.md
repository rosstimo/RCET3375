# Lab 05 - Interrupt Service Routines Migration Plan

Status: current redesign implemented as a working student-facing draft in `../Lab05-ISRs.md`.

## Legacy source

- Inherited assignment: `../old/Lab06-ISRs.pdf`
- New sequence position: Lab 05, following Lab 04 - Funky Muzak
- Working redesigned draft: `../Lab05-ISRs.md`

## Essence of the lab

Students should leave this lab able to explain and implement interrupt-driven execution on the PIC16F883: what event causes an interrupt, how the processor reaches the interrupt vector, how software determines the source, what context must be preserved, how interrupt flags are serviced, how execution safely returns, and how nested interrupt/subroutine execution affects the hardware stack.

The lab deliberately progresses from a simple external interrupt to multiple sources, shared-source identification, controlled nested interrupt execution, and finally a redesign that produces the same behavior without nested interrupts or long blocking work inside an ISR.

## Builds on

- PIC16F883 I/O configuration and SFR documentation
- program flow and subroutines
- software timing and instruction-cycle awareness
- nested software delay work
- input scanning and priority handling from earlier labs
- reusable source organization and flowcharts

## Prepares for

- Timer interrupts in Lab 06
- ADC interrupt/event handling
- UART receive/transmit events
- I2C/MSSP events
- state-driven and event-driven embedded-system architecture

## Keep from the inherited lab

- polling versus interrupts as the conceptual entry point
- external events visibly changing system behavior
- requirement that the main program continue doing something observable
- multiple interrupt sources
- the original 1/6/7 priority behavior
- explicit nested interrupt behavior
- explicit attention to stack behavior and nested calls
- instructor attempts to break the design rather than only observing the happy path

## Replace or improve

- Replace the inherited dot-matrix-specific early exercises with LEDs and oscilloscope measurements that expose interrupt execution directly.
- Use the PIC16F883's actual single interrupt vector and software source determination.
- Use `RB0/INT` as the dedicated external interrupt and PORTB interrupt-on-change for the second source.
- Make context saving an explicit requirement from Part 1 onward.
- Make PORTB IOC servicing and source identification explicit rather than treating each PORTB pin as an independent vector.
- Retain nested interrupts in Part 4 intentionally as an experiment rather than presenting them as the preferred architecture.
- Turn the inherited stack-overflow hint into a required worst-case stack-depth analysis.
- Use Mastery to recreate the same behavior with short non-nested ISRs and explicit state/status flags.

## Current lab architecture

### Part 1 - External interrupt and observable main execution

- `RB0/INT`, falling-edge momentary input.
- Main continuously toggles a PORTA monitoring pin.
- Every external interrupt increments PORTC.
- PORTC is displayed on LEDs.
- Required single-sequence oscilloscope capture:
  - CH1: `RB0/INT` request signal;
  - CH2: PORTA main-loop monitoring pin;
  - CH3: `RC0`, the count LSB.
- Use the capture to see the external request, interruption of main execution, and ISR result.
- Emphasize context saving and restoration.
- Switch bounce may remain visible and should be documented rather than automatically hidden.

### Part 2 - Two interrupt sources, one vector

- Add one PORTB interrupt-on-change source.
- PORTB IOC increments PORTC.
- `RB0/INT` clears PORTC.
- Main continues to provide the PORTA heartbeat/monitoring signal.
- ISR structure:
  - save context;
  - determine interrupt source;
  - transfer to the appropriate handler;
  - each handler services and clears its own source;
  - transfer to one common exit path;
  - restore context;
  - `RETFIE`.
- PORTB IOC handling must include the correct PORTB read/service sequence before clearing the IOC flag.

### Part 3 - Determine which PORTB pin changed

- Enable PORTB interrupt-on-change for the applicable PORTB pins.
- The common IOC request only says that a change occurred, so software must determine which bit changed.
- Use three PORTA pins and LEDs to display the changed PORTB pin number in binary:
  - `000` = RB0;
  - through `111` = RB7.
- Require previous/current PORTB state tracking or equivalent source-determination logic.
- Require a deterministic rule if more than one changed bit is present when software evaluates the event.

### Part 4 - Priority interrupts and stack-depth investigation

Reuse the existing PORTC-connected digit display from previous labs.

Required visible behavior:

- main displays `1`;
- falling-edge `RB0/INT` initiates the `6` behavior;
- PORTB IOC on RB1 initiates the `7` behavior;
- 6 displays for approximately two seconds;
- 7 displays for approximately two seconds;
- 7 can interrupt 6;
- when 7 completes, 6 resumes and completes its remaining time;
- 6 cannot interrupt 7;
- 7 may interrupt 6 repeatedly;
- after interrupt work completes, main again displays 1.

Part 4 intentionally uses nested interrupt execution. Do not steer students away from `CALL`/`RETURN`. Require the delay implementation to use callable subroutines, with nested delay/subroutine calls as appropriate, so ordinary subroutine calls contribute to hardware stack use.

Before demonstration, students must determine their worst-case hardware stack depth. The analysis must include active subroutine calls, interrupt return addresses, nested interrupt entry, and calls made while the nested interrupt is active. Require a drawing or table showing the occupied stack levels, not only a final depth number.

Also distinguish hardware return-stack use from software context storage. A nested interrupt must not destroy context that belongs to the interrupted ISR.

The instructor should deliberately stress the design near the predicted worst-case nesting condition and attempt to expose stack or context failure.

### Mastery - Same priority behavior without nested interrupts

Recreate the externally visible Part 4 behavior while:

- not deliberately nesting interrupts;
- not remaining inside an ISR for the approximately two-second display delay;
- keeping interrupt handlers short;
- recording requests in state/status flags or registers;
- allowing main to perform the longer behavior;
- preserving 7-over-6 priority and resuming the remaining 6 behavior after 7 completes.

This is the architectural comparison that closes the lab. Students first experience why nesting and blocking ISR work becomes difficult, then reproduce the same system behavior with explicit program state.

## Assembly and embedded C strategy

Assembly remains primary for this lab because the vector, `RETFIE`, flag handling, banked SFR access, context saving, interrupt nesting, subroutine calls, and stack behavior are the concepts being taught.

An XC8 comparison may be added later, but it should not replace the hardware/software model being established here.

## Meaningful evidence

- interrupt-related SFR maps and official references;
- flowcharts showing main/ISR interaction and source determination;
- source with vector, handler, flag, and context handling visible;
- oscilloscope evidence of interrupt effect on main execution;
- proof that interrupt inputs are not polled from main where prohibited;
- PORTB IOC source-identification evidence;
- Part 4 worst-case hardware stack-depth analysis;
- separate software context-storage analysis for nested execution;
- instructor stress-test results;
- Mastery comparison between nested ISR architecture and state-driven architecture;
- troubleshooting record for bounce, missed/repeated events, stack problems, or context corruption.

## Remaining draft questions

- Choose and standardize the exact PORTA main-loop monitoring pin used in Parts 1 and 2 after verifying it against the existing lab hardware configuration.
- Decide whether Part 2 should prescribe a specific IOC pin or allow the student to choose one before Part 3 expands to the full PORTB set.
- Verify the exact existing PORTC digit-display hardware/encoding to reference in Part 4 rather than duplicating prior documentation.
- Decide how much starter ISR/context-save code, if any, should be supplied versus developed from theory-class material.
