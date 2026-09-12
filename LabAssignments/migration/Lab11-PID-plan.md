# Lab 11 - PID Migration Plan

Status: initial curriculum analysis only. This is not student-facing lab instruction.

## Legacy source

- Inherited assignment: `../old/Lab12-PID.pdf`
- Renumbered Markdown recreation: `../Lab11-PID.md`
- New sequence position: Lab 11, final inherited lab before capstone work

## Essence of the lab

Students should learn closed-loop control as a system, not merely paste a PID equation into code. They should be able to define a setpoint, measure process position, calculate error at a known sample interval, apply proportional/integral/derivative terms intentionally, command an actuator, and evaluate the physical response using measurable criteria.

This should be the semester's integration lab. Timer scheduling, ADC/sensor acquisition, servo output, UART diagnostics/setpoint commands, and embedded C all have a natural reason to come together here.

## Builds on

- timer-based periodic scheduling
- ADC/sensor acquisition
- servo output module
- UART command/telemetry interface
- structured embedded-C program organization
- measurement and troubleshooting practices from all prior labs

## Prepares for

- individual capstone projects
- feedback control systems
- data-driven tuning and system characterization
- integration of multiple embedded subsystems

## Keep from the inherited lab

- real physical plant with a ball whose position is controlled by a servo
- externally supplied target/setpoint
- measured position fed back into the controller
- PID as the control method
- physical demonstration rather than a simulation-only exercise

## Reduce or remove

- Visual Basic as a required host language
- vague success criteria such as working "to the instructor's expectation"
- jumping directly to full PID before students characterize the plant and understand proportional control
- treating servo position resolution as the main solution to control-quality problems
- any unidentified or incorrectly named sensor requirement until the actual hardware is confirmed

## Create or clarify

- identify the actual position sensor; the inherited document says "PIR sensor," which may not describe the intended distance sensor
- define the physical plant and safe operating limits
- fixed control-loop sample period derived from the timer subsystem
- setpoint, process variable, error, control output, and actuator saturation
- proportional, integral, and derivative terms separately before combining them
- integral windup and output limiting at an appropriate introductory level
- measurement noise and derivative sensitivity
- tuning method or structured tuning procedure
- objective performance measures such as rise time, settling time, overshoot, steady-state error, and disturbance recovery
- UART logging/telemetry for plotting response versus time

## Proposed new lab architecture

### Part 1 - Characterize the plant and sensor

Operate the servo manually/open-loop and determine the relationship between command, physical motion, and measured position. Verify the sensor range, scaling, noise, and safe mechanical limits. Establish the control-loop sample interval.

### Part 2 - Proportional control

Implement P-only control with a bounded output. Test multiple gains and document how gain affects rise time, oscillation, steady-state error, and stability. This should make the meaning of controller gain physically obvious before adding more terms.

### Part 3 - PI or PD extension

Add the next control term deliberately based on an observed limitation from Part 2. The exact sequence should match the behavior of the real apparatus. Require students to explain what changed and why.

### Part 4 - Full PID integration

Implement and tune the complete controller. Accept a setpoint from a host interface, report process data over UART, and demonstrate repeatable moves to multiple setpoints plus at least one disturbance-recovery test.

### Part 5 - Mastery

A bounded extension could compare tuning methods, implement anti-windup, add a simple digital filter, or quantify behavior under a changed load. Pick one concrete investigation when the lab is finalized.

## Assembly and embedded C strategy

This lab should be primarily embedded C. The learning target is control-system behavior and integration, not hand-coded arithmetic in assembly.

Students should still understand what the timer, ADC, UART, and output peripherals are doing because they developed those subsystems earlier. Reuse those modules rather than replacing them with high-level libraries.

A host application may be C# or Python depending the final RCET3371 alignment. It should provide setpoint entry and useful telemetry/plotting, not become a separate GUI-design project.

## Hardware and software reuse

This lab should deliberately reuse:

- timer/system tick from Lab 06
- sensor/ADC acquisition from Lab 07
- UART driver/protocol from Lab 08
- servo-control module from Lab 07

That reuse is part of the learning objective. By this point students should experience the benefit of modular code and verified subsystems instead of starting another monolithic program.

## Meaningful evidence

- plant/sensor characterization data
- control-loop sample-period calculation and measurement
- sensor scaling and calibration
- response plots/logs for selected controller gains
- comparison of P, intermediate, and PID behavior
- final gain values with rationale
- rise time, overshoot, settling time, and steady-state error or another agreed set of response metrics
- disturbance-recovery evidence
- output saturation/safety behavior
- source structure showing reused modules
- troubleshooting/tuning record

## Questions to resolve during redesign

- What sensor is actually used in the ball-position apparatus, and what are its electrical/response characteristics?
- Is the current physical ball/servo plant reliable enough for every student to characterize and tune repeatably?
- Should the host tool be C# or Python for the best cross-course alignment?
- Which PID tuning method is appropriate for the apparatus and course level?
- Is this still best as a required pre-capstone lab, or should some advanced PID features become mastery material to preserve capstone time?
