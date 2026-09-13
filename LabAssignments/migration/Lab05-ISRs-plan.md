# Lab 05 - Interrupt Service Routines Migration Plan

Status: current redesign implemented as a working student-facing draft in `../Lab05-ISRs.md`.

## Legacy source

- Inherited assignment: `../old/Lab06-ISRs.pdf`
- New sequence position: Lab 05, following Lab 04 - Funky Muzak
- Working redesigned draft: `../Lab05-ISRs.md`

## Essence of the lab

Students should leave this lab able to explain and implement interrupt-driven execution on the PIC16F883: what event causes an interrupt, how the processor reaches the interrupt vector, how software determines the source, what context must be preserved, how flags are serviced, how execution safely returns, and how nested interrupt/subroutine execution affects the hardware stack.

The progression is deliberately experiential: simple external interrupt, multiple sources, shared IOC source identification, controlled nested execution, then the same priority behavior redesigned without nested interrupts or long blocking work inside an ISR.

## Builds on

- PIC16F883 I/O configuration and SFR documentation
- program flow and subroutines
- software timing and instruction-cycle awareness
- nested software delay work
- input scanning and priority handling from earlier labs
- DLG7137/PORTC display work from Lab 02 and later labs
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
- observable main-line work
- multiple interrupt sources
- the original 1/6/7 priority behavior
- intentional nested interrupt behavior
- stack behavior and nested calls
- instructor attempts to break the design rather than only observing the happy path

## Replace or improve

- Replace the inherited early display exercises with LEDs and oscilloscope measurements that expose interrupt execution directly.
- Use the PIC16F883 single interrupt vector and software source determination.
- Use `RB0/INT` as the dedicated external interrupt and PORTB IOC for additional sources.
- Make context saving explicit from Part 1 onward.
- Make IOC servicing and source identification explicit.
- Retain nested interrupts in Part 4 as an experiment, not the recommended architecture.
- Turn the inherited stack-overflow hint into required worst-case stack-depth analysis.
- Use Mastery to reproduce the same behavior with short non-nested ISRs and explicit state/status storage.

## Current lab architecture

### Part 1 - External interrupt and observable main execution

- `RB0/INT`, falling-edge momentary input.
- Student chooses a suitable unused PORTA digital output as the main-loop monitoring pin and documents the choice.
- Every external interrupt increments PORTC.
- PORTC is displayed on LEDs.
- Required single-sequence capture:
  - CH1: `RB0/INT`;
  - CH2: selected PORTA monitoring pin;
  - CH3: `RC0`.
- Context save/restore starts from PIC16F883 data sheet Section 14.4, Example 14-1.
- Switch bounce remains visible and is documented rather than automatically hidden.

### Part 2 - Two interrupt sources, one vector

- Keep `RB0/INT` as the external source.
- Use **RB4** as the single IOC source. RB4 was chosen as a middle PORTB bit while avoiding RB6/RB7 ICSP pins and reserving RB1 for the later priority exercise.
- RB4 IOC increments PORTC.
- `RB0/INT` clears PORTC.
- Main retains the PORTA monitoring signal selected in Part 1.
- Required four-channel capture:
  - CH1: `RB0/INT`;
  - CH2: PORTA monitoring pin;
  - CH3: `RC0`;
  - CH4: RB4 IOC input.
- ISR structure remains source determination -> source handler -> common restore/`RETFIE`.
- Each handler services and clears its own source.
- IOC handling must include the correct PORTB read/service sequence before clearing the IOC flag.

### Part 3 - Determine which PORTB pin changed

- Disable the dedicated external interrupt for this part.
- Enable IOC on RB0 through RB7 using `IOCB`.
- The common IOC flag only reports that a change occurred; software determines which bit changed.
- Use three PORTA outputs to display the pin number in binary (`000` = RB0 through `111` = RB7).
- Require previous/current PORTB state tracking or an equivalent source-determination method.
- Require deterministic behavior if multiple changed bits are present.

### Part 4 - Priority interrupts and stack-depth investigation

Reuse the **DLG7137 display connected to PORTC** from Lab 02. The earlier lab already establishes the hardware and display use, so Lab 05 should reference the earlier schematic/encoding rather than duplicate it unless the circuit changes.

Required visible behavior:

- main displays `1`;
- falling-edge `RB0/INT` initiates `6`;
- RB1 IOC initiates `7`;
- 6 displays for about two seconds;
- 7 displays for about two seconds;
- 7 can interrupt 6;
- after 7 finishes, 6 resumes and completes its remaining time;
- 6 cannot interrupt 7;
- 7 may interrupt 6 repeatedly;
- main returns to 1 after interrupt work completes.

Part 4 intentionally uses nested interrupt execution. Do not steer students away from `CALL`/`RETURN`. Require callable delay subroutines so ordinary subroutine calls contribute to stack depth.

Before demonstration, students determine worst-case hardware stack depth and show occupied stack levels as a table or drawing.

Context saving for nesting must begin with the device-data-sheet method and be adapted as needed. The lab should not enumerate every application register that might be corrupted by nesting. In particular, do **not** explicitly warn students to save delay counters or other GPRs. That is an intended opportunity for discovery during stress testing and troubleshooting.

### Mastery - Same priority behavior without nested interrupts

Recreate the externally visible Part 4 behavior while:

- not deliberately nesting interrupts;
- not remaining inside an ISR for the two-second display delay;
- keeping handlers short;
- recording requests in explicit state/status storage;
- allowing main to perform longer behavior;
- preserving 7-over-6 priority and resuming the remaining 6 behavior after 7 completes.

This closes the lab by comparing the deliberately difficult nested design with a state-driven alternative.

## Context-saving source strategy

### Primary student starting point

Use PIC16F883 data sheet Section 14.4 and **Example 14-1, Saving STATUS and W Registers in RAM**. It is device-family-specific and uses the common RAM area available on the PIC16F882/883/884/886/887.

The student-facing lab should point to that example rather than reproducing a large context-save template.

### Mid-Range Family Reference Manual

Section 8 is useful supplemental background. It includes:

- interrupt architecture and latency;
- Section 8.5 context saving;
- a generic interrupt source-dispatch ISR template;
- design tips about corrupted registers and uncleared flags.

The manual is much older and some examples target devices such as the PIC16C77. Device-specific details must therefore defer to the PIC16F883 data sheet.

### Other Microchip supplemental material

Useful instructor/supporting references found during this migration:

- **AN566, Using the PORTB Interrupt on Change as an External Interrupt**: useful historical/conceptual discussion of IOC as additional external interrupt sources, but written for older PIC16C devices. Its RB7:RB4-only description does not match the PIC16F883's individually enabled IOCB<7:0>, so it should not be a primary student reference for this lab.
- **TB3061, Interrupt-on-Change Operation for Mid-Range Microcontrollers**: useful discussion of classic mid-range IOC mismatch-latch/read timing and the possibility of missing a change when a port read/write occurs at the wrong time. Relevant as deeper instructor/reference material, but not necessary in the basic lab instructions.
- **AN556, Implementing a Table Read**: the appropriate supplemental source for computed `GOTO`, PCL, and PCLATH behavior. This belongs with program-counter/table-read instruction rather than inside the ISR lab.

## PCLATH teaching boundary

The context-saving example in the PIC16F883 data sheet contains a note about PCLATH when computed `GOTO`s are used.

Do not turn that note into an additional Lab 05 requirement before students have a detailed explanation of computed `GOTO`s and the failure modes caused by incorrect high PC bits or 256-word PCL boundary crossings.

A separate course reference now exists at:

`../../Notes/PIC16F883-Computed-GOTO-and-PCLATH.md`

It explains:

- PCL versus PCLATH;
- ordinary `CALL`/`GOTO` page selection;
- computed `GOTO` using a write to PCL;
- wrong-page failures;
- 0xFF -> 0x00 PCL boundary failures;
- the relationship between PCLATH, the hardware stack, and interrupt context.

The ISR lab itself should not mention PCLATH unless later teaching explicitly establishes that prerequisite.

## Documentation notes applied to Lab 05

The student-facing draft now applies the evolving migration standard by requiring:

- register-style maps for assigned port pins;
- register-style maps for named GPR state/status storage;
- relevant component datasheets in lab-book references;
- the student's GitHub assignment URL in lab-book references;
- reuse/reference of unchanged prior lab-book material rather than duplication;
- shorter, less repetitive wording where practical.

These are also course-wide migration rules and should be propagated to the other working lab branches.

## Assembly and embedded C strategy

Assembly remains primary because vectoring, `RETFIE`, flag handling, banked SFR access, context saving, interrupt nesting, subroutine calls, and stack behavior are the concepts being exposed directly.

An XC8 comparison may be added later, but it should not replace the hardware/software model established here.

## Meaningful evidence

- interrupt-related SFR maps and official references;
- port/state register maps;
- flowcharts showing main/ISR interaction and source determination;
- source with vector, handler, flag, and context handling visible;
- oscilloscope evidence of interrupt effects on main execution;
- proof that prohibited polling is not used;
- IOC source-identification evidence;
- Part 4 worst-case stack-depth analysis;
- instructor stress-test results;
- Mastery comparison between nested and state-driven architectures;
- troubleshooting record for bounce, missed/repeated events, stack problems, or context corruption.

## Resolved draft questions

- **PORTA monitoring pin:** student choice in Parts 1 and 2; no prescribed pin.
- **Part 2 IOC pin:** RB4.
- **PORTC display:** DLG7137 from Lab 02, reused on PORTC and referenced rather than re-documented unless changed.
- **Starter context code:** PIC16F883 data sheet Section 14.4 / Example 14-1 is the starting point.
- **PCLATH:** taught separately with computed `GOTO`; not introduced as a Lab 05 requirement.
- **Additional GPR preservation during nested execution:** intentionally not called out in student instructions; left as a discovery/troubleshooting opportunity.
