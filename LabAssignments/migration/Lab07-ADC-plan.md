# Lab 07 - ADC Migration Plan

Status: initial curriculum analysis only. This is not student-facing lab instruction.

## Legacy source

- Inherited assignment: `../old/Lab08-ADC.pdf`
- Renumbered Markdown recreation: `../Lab07-ADC.md`
- New sequence position: Lab 07, after timers

## Essence of the lab

Students should learn how an analog voltage becomes a digital number and how that number can be used by firmware to control a physical output. The lab should make the entire chain visible: analog source -> ADC input configuration -> acquisition/conversion -> result registers -> scaling/interpretation -> application output.

The servo is useful because it gives a physical consequence to the conversion result and reuses the timer work from the previous lab.

## Builds on

- timer-derived periodic behavior from Lab 06
- interrupts/event handling from Lab 05
- PIC I/O and SFR research
- measurement and prediction habits

## Prepares for

- sensor acquisition in UART and I2C systems
- persistent storage of measured/configuration values
- closed-loop control and PID
- general embedded-C data handling

## Keep from the inherited lab

- simple potentiometer-to-ADC proof of life
- visible representation of the conversion result
- servo position controlled from the ADC reading
- reuse of a timer for servo timing
- instructor verification of physical behavior

## Reduce or remove

- restricting the core learning to only the eight most-significant bits unless that truncation is being used deliberately to teach resolution tradeoffs
- arbitrary 15-position/100 us stepping if it obscures the relationship between ADC range and output range
- any servo-calibration effort that becomes the dominant task
- background prose that states servo timing values as universal without checking the actual device used in lab

## Create or clarify

- analog-capable pin configuration and the digital/analog selection registers
- ADC clock selection and conversion timing
- acquisition time and source-impedance considerations
- voltage references and expected count calculation
- 10-bit ADC result organization, justification, and use of `ADRESH:ADRESL`
- polling versus ADC interrupt completion where useful
- numeric mapping from ADC counts to an application range
- DMM measurement of input voltage and comparison with predicted ADC result
- timer-based servo pulse generation without blocking the processor

## Proposed new lab architecture

### Part 1 - ADC proof of life

Read a potentiometer or other known analog source. Predict the ADC count from a measured input voltage, perform the conversion, and expose the result in a simple observable way such as PORT output, debugger watch, or another low-overhead representation. Require several input points rather than only proving one reading works.

### Part 2 - Full-resolution conversion and interpretation

Use the full 10-bit result. Compare expected count, measured count, reconstructed voltage, and error. Explicitly exercise result-register formatting and conversion math.

### Part 3 - ADC-to-servo mapping

Reuse the timer framework from Lab 06 to generate the servo control signal while the ADC selects position. Map the ADC range into a bounded pulse-width range. Keep servo timing and ADC acquisition independent enough that neither requires a blocking delay.

### Part 4 - Integrated acquisition/application behavior

Add a second requirement that forces students to treat the ADC as part of a running system rather than a one-shot conversion. Candidate directions include a second channel, periodic sampling, simple filtering, threshold/event behavior, or another bounded integration task.

### Part 5 - Mastery

A suitable mastery task could investigate oversampling/averaging, measured noise, external versus supply reference behavior, or calibration. Pick one concrete investigation when finalizing the lab.

## Assembly and embedded C strategy

This lab is a natural place for embedded C to become more prominent.

Recommended progression:

- make students configure and explain the ADC registers directly, regardless of language;
- use a small pic-as example or prior theory work to keep the hardware model visible;
- implement the larger acquisition/mapping application in XC8 C using direct SFR access rather than a framework that hides the ADC;
- require students to relate the C operations to the same registers, flags, and result bytes documented in the lab book.

## Hardware and software reuse

Reuse the timer subsystem from Lab 06 for servo timing. Keep the same PIC minimum system. Prefer a simple potentiometer and one known servo model so the electrical and timing requirements can be documented once and reused later.

If the servo subsystem will reappear in I2C and PID, this lab should create the reusable servo-control module rather than a one-off implementation.

## Meaningful evidence

- ADC-related SFR maps and datasheet references
- measured analog input voltage
- expected 10-bit count calculation
- actual conversion result at several points
- count/voltage error comparison
- acquisition/conversion timing rationale
- servo pulse-width measurement at low, center, and high commands
- proof that timer-driven servo output remains stable while ADC work occurs
- troubleshooting notes for saturation, wrong pin mode, reference/configuration, or timing problems

## Questions to resolve during redesign

- What exact potentiometer/source impedance should be standardized for predictable acquisition-time analysis?
- Which servo model will be used, and what pulse-width limits are safe for that hardware?
- Should ADC conversion completion first be polled and then converted to interrupt-driven operation, or is one method enough here?
- What is the cleanest first required embedded-C deliverable without repeating the same assignment twice in two languages?
