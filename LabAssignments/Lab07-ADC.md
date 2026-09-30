<a id="top"></a>

# RCET 3375 Lab 07 - ADC and Servo Control

[RCET3375 course home](../README.md)

PIC16F883 | pic-as | ADC | Acquisition Time | TAD | Result Justification | Measurement | Servo Control

## Contents

- [Purpose](#purpose)
- [Standards and references](#standards-references)
- [Equipment and materials](#equipment-materials)
- [Part 1 - ADC proof of life](#part-1)
- [Part 2 - ADC-to-servo mapping](#part-2)
- [Part 3 - CCP compare servo control](#part-3)
- [Part 4 - Multi-servo event scheduler](#part-4)

<a id="purpose"></a>
## Purpose

Build a measured analog-to-digital conversion path on the PIC16F883, then use the converted value to control a physical output.

The first part makes the ADC itself visible. You will vary a potentiometer from 0 V to VDD, observe the complete 10-bit conversion result through `ADRESH:ADRESL`, measure how long the conversion takes, and compare the measured analog voltage with the value represented by the ADC result.

Later parts will reuse the timer work from Lab 06 to map the ADC result into servo-control timing.

[Back to top](#top) · [Course home](../README.md)

<a id="standards-references"></a>
## Standards and references

- [RCET 3375 Lab Standard](../LAB_STANDARD.md)
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md)
- [RCET 3373 PIC16F883 ADC and Sensor Conditioning](https://github.com/rosstimo/RCET3373/blob/main/Topics/pic16f883-adc.md)
- [PIC16F882/883/884/886/887 Data Sheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf)
- [PIC16F88X Family Silicon Errata and Data Sheet Clarifications](https://ww1.microchip.com/downloads/aemDocuments/documents/MCU08/ProductDocuments/Errata/PIC16F88X-Family-Si-Errata-Data-Sheet-Clarifications-DS80000302.pdf)
- previous RCET3375 lab-book documentation and source for digital I/O, timers, interrupts, masking, and measurement

Use the PIC16F883 data sheet as the device authority. The current errata corrects the acquisition-time example associated with Equation 9-1, so use the corrected equation when calculating acquisition time.

[Back to top](#top) · [Course home](../README.md)

<a id="equipment-materials"></a>
## Equipment and materials

- MPLAB X IDE and pic-as toolchain
- PICkit programmer/debugger
- PIC16F883 circuit
- 4 MHz crystal oscillator circuit
- potentiometer connected between VDD and VSS
- LEDs and current-limiting resistors for PORTB and PORTC result display
- one available digital diagnostic output
- digital multimeter
- oscilloscope
- servo motor for Part 2 and Part 3; additional servos and potentiometers as available for Part 4
- breadboard, jumpers, and interface components as required
- lab book

[Back to top](#top) · [Course home](../README.md)

<a id="part-1"></a>
## Part 1 - ADC Proof of Life

### Goal

Continuously convert a potentiometer voltage with the PIC16F883 ADC and make the complete ADC result observable.

Choose any available analog input channel. Use VDD and VSS as the ADC reference range unless your instructor approves another reference arrangement.

In the main loop:

1. allow the selected input to acquire for the calculated acquisition time;
2. start one ADC conversion;
3. indicate the hardware conversion interval on a diagnostic output;
4. wait for the conversion to complete;
5. copy `ADRESH` to PORTC;
6. copy `ADRESL` to PORTB;
7. repeat continuously.

Vary the potentiometer from approximately 0 V to VDD and observe how the two result registers change.

### ADC clock and conversion timing

Determine the ADC conversion clock from the actual 4 MHz oscillator and the PIC16F883 data-sheet requirements.

Document:

- the selected ADC clock source/divider;
- the resulting `TAD`;
- why that `TAD` is valid for the device;
- the number of `TAD` periods used by one conversion according to the data-sheet conversion timing figure;
- the predicted conversion time.

Do not use the diagnostic pulse as a substitute for the calculation. Predict the hardware conversion time first, then measure it.

### Conversion diagnostic signal

Choose one available digital output as an ADC conversion diagnostic.

For each conversion:

1. drive the diagnostic output HIGH immediately before starting the conversion;
2. set `GO/DONE`;
3. poll `GO/DONE` until the hardware clears it;
4. drive the diagnostic output LOW as soon as practical after completion.

Measure the HIGH pulse width with the oscilloscope.

The GPIO edges will not occur at exactly the same instants as the internal ADC conversion boundaries. Account for the relevant instruction-cycle and polling overhead when comparing the measured pulse width with the predicted conversion time.

### Acquisition time

Calculate the minimum required acquisition time for your actual analog source.

Your calculation must include the source resistance seen by the ADC input. For the potentiometer, determine the source resistance from the potentiometer circuit rather than using the total potentiometer resistance blindly.

Use the corrected acquisition-time relationship from the current PIC16F88X errata.

Explain:

- what is charging during acquisition;
- why source impedance affects the required acquisition time;
- why conversion should not begin immediately after selecting or reconnecting the analog input;
- where the acquisition delay occurs in your main-loop sequence.

The acquisition interval and conversion interval are different. Your program must provide both.

### Result justification

Run the ADC in both result formats:

- right justified;
- left justified.

For each format, document how the 10-bit result is arranged across `ADRESH` and `ADRESL`.

Because the program copies `ADRESH` to PORTC and `ADRESL` to PORTB, the LED displays should visibly change when the justification changes even though the analog input and 10-bit conversion value have not changed.

Explain which format is more convenient when:

- the full 10-bit value is needed;
- only the eight most-significant bits are needed.

### Voltage resolution and conversion result

Calculate the ideal ADC voltage resolution for your measured reference range.

Use the actual measured VDD as the positive reference value rather than assuming it is exactly 5.000 V.

Collect conversion data at several potentiometer settings spanning the usable range. Include values near:

- the low end;
- approximately one-quarter scale;
- approximately half scale;
- approximately three-quarter scale;
- the high end.

For each point, record:

| Measured VIN | ADC code | Voltage calculated from ADC code | Difference |
| ---: | ---: | ---: | ---: |
|  |  |  |  |

Use the full 10-bit result for the comparison.

Also use a measured voltage change across multiple ADC counts to estimate volts per count from your own data. Compare that measured estimate with the ideal resolution you calculated.

### Required behavior

- One selected analog input continuously converts the potentiometer voltage.
- The potentiometer can sweep the input from approximately 0 V to VDD.
- The program provides the calculated acquisition time before each conversion.
- The ADC uses a valid conversion clock.
- The diagnostic output shows the conversion interval.
- `ADRESH` is displayed on PORTC.
- `ADRESL` is displayed on PORTB.
- Both left- and right-justified result formats are demonstrated and explained.
- The measured input voltage and full 10-bit ADC result agree within a reasonable experimental error.

### Before Lab

Prepare or reference:

- selected analog input pin/channel;
- potentiometer schematic;
- electrical/loading analysis for the potentiometer, ADC input, LED displays, and diagnostic output;
- ADC-related SFR documentation, including `ANSEL/ANSELH`, `ADCON0`, `ADCON1`, `ADRESH`, and `ADRESL`;
- selected voltage references and expected input range;
- ADC clock selection and `TAD` calculation;
- predicted conversion time from the data-sheet `TAD` sequence;
- potentiometer source-resistance analysis;
- acquisition-time calculation using the corrected errata relationship;
- ideal volts-per-count resolution using the expected reference voltage;
- main-loop flowchart showing acquisition, conversion, result display, and repetition;
- source code.

### In the Lab

1. Measure VDD and record the actual ADC reference span.
2. Verify the potentiometer produces approximately 0 V through VDD at the selected analog input.
3. Verify the selected pin is configured as an analog input and the intended ADC channel is selected.
4. Begin with one result-justification mode and run continuous conversions.
5. Sweep the potentiometer and verify `ADRESH` on PORTC and `ADRESL` on PORTB change as expected.
6. Display the conversion diagnostic signal on the oscilloscope and measure its HIGH pulse width.
7. Compare the measured diagnostic pulse with the predicted conversion time and account for software/instruction overhead.
8. Change to the other result-justification mode without changing the analog input.
9. Repeat the sweep and document how the two port displays differ from the first format.
10. Collect the required measured-voltage/ADC-code data points across the input range.
11. Calculate voltage from each observed 10-bit ADC code and compare it with the DMM measurement.
12. Use your measured data to estimate volts per count and compare it with the ideal resolution.
13. If the ADC result is unstable or inaccurate, troubleshoot the analog pin configuration, channel selection, references, `TAD`, acquisition time, source impedance, result format, grounding, and wiring before changing the conversion math.

### Evidence

Include or reference:

- potentiometer/ADC schematic and loading analysis;
- ADC SFR documentation;
- measured VDD/reference range;
- ADC clock and `TAD` calculation;
- predicted conversion time;
- scope capture of the conversion diagnostic pulse;
- measured versus predicted conversion timing with instruction/polling overhead explained;
- potentiometer source-resistance analysis;
- acquisition-time calculation using the corrected errata equation;
- main-loop flowchart;
- final source;
- PORTB/PORTC observations for both left- and right-justified results;
- explanation of the bit placement in `ADRESH:ADRESL` for both formats;
- complete measured VIN / ADC code / reconstructed voltage comparison table;
- calculated ideal volts per count;
- measured estimate of volts per count and comparison with the ideal value;
- troubleshooting record.

### Demonstrate

With the oscilloscope and DMM connected, vary the potentiometer through its range and show continuous ADC conversion.

Be prepared to explain:

- the complete path from potentiometer voltage to `ADRESH:ADRESL`;
- why acquisition must occur before conversion;
- how the potentiometer's source resistance enters the acquisition-time calculation;
- how the selected ADC clock produces your value of `TAD`;
- how many `TAD` periods the conversion uses;
- why the diagnostic pulse does not exactly equal the ideal hardware conversion time;
- how right and left justification rearrange the same 10-bit result;
- how you converted the ADC code back into voltage;
- how your measured volts-per-count result compares with the predicted resolution.

### Complete When

Part 1 is complete when the potentiometer can sweep the ADC through its usable range, the full 10-bit result is observable on PORTB and PORTC in both justification modes, acquisition and conversion timing are calculated and measured, and the ADC-derived voltage agrees reasonably with independent DMM measurements.

[Back to top](#top) · [Course home](../README.md)


<a id="part-2"></a>
## Part 2 - ADC-to-Servo Mapping

### Goal

Use the ADC result from Part 1 to command a standard positional servo through **21 discrete positions**.

Generate a servo-control waveform on an available PORTA output with:

- a nominal **20 ms period**;
- a minimum HIGH pulse width of **500 us**;
- a maximum HIGH pulse width of **2.5 ms**;
- **100 us** pulse-width increments.

The inclusive range is:

```text
(2.5 ms - 0.5 ms) / 0.1 ms = 20 intervals
20 intervals + the starting position = 21 positions
```

Use the potentiometer from Part 1 to select the commanded position across its 0 V to VDD input range.

### Servo timing reference

![Servo timing reference from the inherited ADC lab](images/servo-timing.jpg)

The inherited figure illustrates the nominal relationship between a repeating servo pulse, pulse width, and mechanical position. Treat it as a timing illustration, not as an electrical specification for every servo.

For this assignment, use the required 20 ms period and 500 us through 2.5 ms pulse-width range. Verify the actual servo's supply, control-input, current, and safe mechanical limits before connecting it.

### 21-position command model

Represent the commanded position with an integer index from 0 through 20.

The required pulse width is:

```text
pulse width = 500 us + (position index x 100 us)
```

Therefore:

| Position index | Expected pulse width | Nominal expected position |
| ---: | ---: | ---: |
| 0 | 500 us | 0 deg |
| 1 | 600 us | 9 deg |
| 2 | 700 us | 18 deg |
| 3 | 800 us | 27 deg |
| 4 | 900 us | 36 deg |
| 5 | 1.0 ms | 45 deg |
| 6 | 1.1 ms | 54 deg |
| 7 | 1.2 ms | 63 deg |
| 8 | 1.3 ms | 72 deg |
| 9 | 1.4 ms | 81 deg |
| 10 | 1.5 ms | 90 deg |
| 11 | 1.6 ms | 99 deg |
| 12 | 1.7 ms | 108 deg |
| 13 | 1.8 ms | 117 deg |
| 14 | 1.9 ms | 126 deg |
| 15 | 2.0 ms | 135 deg |
| 16 | 2.1 ms | 144 deg |
| 17 | 2.2 ms | 153 deg |
| 18 | 2.3 ms | 162 deg |
| 19 | 2.4 ms | 171 deg |
| 20 | 2.5 ms | 180 deg |

The angle column is the nominal linear expectation for a 180-degree servo across the assignment pulse-width range. Actual servos vary. If the instructor specifies a different verified mechanical range for the servo used in lab, use that range for the expected-position comparison instead.

### ADC-to-position mapping

Develop a method that maps the full usable ADC input range into the 21 position indexes.

At minimum:

- approximately 0 V must select position 0;
- approximately VDD must select position 20;
- increasing ADC input must never command a lower position;
- all 21 positions must be reachable;
- the mapping must remain within indexes 0 through 20.

Document how ADC codes are divided among the 21 positions.

Create a mapping table before bench testing:

| Position index | ADC code range | Expected pulse width |
| ---: | --- | ---: |
| 0 | ... | 500 us |
| 1 | ... | 600 us |
| ... | ... | ... |
| 20 | ... | 2.5 ms |

Show the calculations or integer method used to convert the 10-bit ADC result into the position index. Do not simply tune thresholds experimentally until the servo appears to move correctly.

### 20 ms timer period

Configure one PIC16F883 hardware timer to establish the nominal **20 ms servo period**.

The 20 ms interval defines the start of each servo command frame.

Document:

- timer selected;
- timer clock source;
- prescaler/postscaler, when applicable;
- starting/reload value, when applicable;
- complete predicted period calculation;
- exactly what event marks the beginning of a new 20 ms frame;
- how the timer is serviced for the next frame.

Measure the actual frame period and compare it with the predicted value.

### Pulse-width generation

Develop a method that produces the selected HIGH pulse width on one available PORTA output.

Your method must generate all 21 required pulse widths from 500 us through 2.5 ms in 100 us steps while maintaining the nominal 20 ms frame period.

Document:

- how the output pulse begins;
- how its duration is determined from the position index;
- how the output pulse ends;
- the timing calculation for one 100 us step;
- the expected timing error or resolution imposed by your implementation.

The timer establishes the 20 ms frame period. The method used to create the variable HIGH time is part of the design problem.

### Waveform verification before connecting the servo

Do **not** connect the servo until the complete command waveform has been measured and checked by the instructor.

For each of the 21 commanded positions:

1. select the position with the potentiometer;
2. measure the waveform period;
3. measure the HIGH pulse width;
4. compare the measured pulse width with the expected value;
5. record the result.

Use a table such as:

| Index | ADC code / VIN | Expected pulse width | Measured pulse width | Measured period | Pulse-width error |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 0 |  | 500 us |  |  |  |
| 1 |  | 600 us |  |  |  |
| ... |  | ... |  |  |  |
| 20 |  | 2.5 ms |  |  |  |

**Instructor checkoff is required before connecting the servo.**

### Servo verification

After the waveform has been approved, connect the servo using a suitable supply and a common reference with the PIC circuit.

Do not power the servo from a PIC I/O pin. Verify the servo power requirements and account for its current demand before applying power.

Sweep the potentiometer through all 21 positions.

For every position:

- record the commanded index;
- record the measured pulse width;
- record the expected mechanical position;
- measure or otherwise document the actual servo position;
- compare the measured position with the expected position.

Use a table such as:

| Index | Pulse width | Expected position | Measured position | Difference |
| ---: | ---: | ---: | ---: | ---: |
| 0 | 500 us | 0 deg |  |  |
| 1 | 600 us | 9 deg |  |  |
| ... | ... | ... |  |  |
| 20 | 2.5 ms | 180 deg |  |  |

Do not force the servo against a mechanical stop. If the actual safe travel is smaller than the nominal 0-to-180-degree expectation, stop and document the usable range.

### Before Lab

Prepare or reference:

- Part 1 ADC configuration, acquisition calculations, and conversion-result handling;
- servo data sheet or other authoritative specifications for the actual servo used;
- servo power and control-input electrical analysis;
- selected PORTA servo-output pin and its configuration;
- selected hardware timer and complete 20 ms period calculation;
- pulse-width-generation method and 100 us timing calculation;
- 21-position pulse-width table;
- ADC-code-to-position mapping and calculations;
- waveform-generation flowchart;
- source code.

### In the Lab

1. Run the ADC portion and verify the potentiometer still covers the intended input range.
2. Verify the ADC mapping can select every position index from 0 through 20.
3. Run the servo output **without the servo connected**.
4. Measure the 20 ms frame period.
5. Measure and record the pulse width for all 21 positions.
6. Compare each measured pulse width with its expected value.
7. Correct timing or mapping errors before proceeding.
8. Obtain instructor waveform checkoff.
9. Verify the servo supply and common-ground arrangement.
10. Connect the servo.
11. Sweep through all 21 positions and record actual mechanical position.
12. Compare each actual position with the nominal expected position.
13. Document nonlinearity, endpoint limitations, deadband, jitter, or other observed servo behavior rather than hiding those differences by changing the recorded expected values.

### Evidence

Include or reference:

- servo specification source and electrical/loading analysis;
- timer SFR documentation and complete 20 ms calculation;
- pulse-width timing calculation showing 100 us resolution;
- ADC-to-position mapping method and complete 21-position mapping table;
- waveform-generation flowchart;
- source code;
- oscilloscope evidence of the 20 ms period;
- measured waveform table for all 21 pulse widths;
- predicted-versus-measured pulse-width error;
- instructor waveform checkoff;
- servo wiring/power documentation;
- measured servo-position table for all 21 commands;
- expected-versus-measured position comparison;
- troubleshooting record.

### Demonstrate

First demonstrate the electrical waveform without the servo connected.

Be prepared to select arbitrary potentiometer positions and explain:

- how the 10-bit ADC result becomes a position index from 0 through 20;
- how the position index becomes a pulse width from 500 us through 2.5 ms;
- how the timer establishes the 20 ms frame;
- how your pulse-width method achieves 100 us resolution;
- why there are 21 positions rather than 20;
- the difference between pulse-width accuracy and servo-position accuracy.

After instructor approval, demonstrate the connected servo moving through the commanded positions.

### Complete When

Part 2 is complete when all 21 ADC-selected command positions produce the correct measured pulse widths within the 20 ms frame, the waveform has passed instructor checkoff before servo connection, and the servo has been measured and compared with the expected position across the complete usable command range.

[Back to top](#top) · [Course home](../README.md)


<a id="part-3"></a>
## Part 3 - CCP Compare Servo Control

> **Design draft for instructor review:** This section replaces the coarse 100 us pulse-width stepping from Part 2 with Timer1 and CCP Compare. The intent is to introduce CCP as an event-timing peripheral, preserve much more of the 10-bit ADC command resolution, and separate time-critical waveform work from background work in main.

### Goal

Use Timer1 and a CCP Compare event to generate a higher-resolution servo command while maintaining the same basic waveform requirements from Part 2:

- nominal 20 ms frame period;
- 500 us minimum HIGH pulse width;
- 2.5 ms maximum HIGH pulse width.

Continue using the potentiometer and the full 10-bit ADC result as the command input.

At the course 4 MHz oscillator frequency, determine the Timer1 tick period and show whether it is fine enough to represent the ADC-derived command resolution.

### CCP as a scheduled event

Use Timer1 as the timebase and CCP Compare as a scheduled timing event.

The servo output does not need to be the hardware CCP output pin. The CCP may be used to create a precisely scheduled interrupt while the servo signal itself is generated on an available GPIO pin.

For each servo frame:

1. begin the frame;
2. drive the servo output HIGH;
3. establish the timer value corresponding to the actual rising edge;
4. schedule a CCP Compare event for the commanded pulse-width deadline;
5. when the compare event occurs, drive the servo output LOW;
6. leave the output LOW for the rest of the frame.

The compare deadline must be derived from the timer value associated with the actual rising edge, not from an assumed software execution time.

### ADC-to-pulse-width mapping

Map the usable 10-bit ADC range monotonically into the complete 500 us through 2.5 ms pulse-width range.

The ideal relationship is:

\`\`\`text
pulse width
    = 500 us
    + (ADC code / full-scale ADC code) x 2000 us
\`\`\`

Implement an integer approximation appropriate to the PIC16F883.

Document:

- the mapping equation;
- the integer method actually implemented;
- the number of distinct command values produced;
- the nominal pulse-width change per ADC count;
- endpoint error;
- worst-case rounding or quantization error.

The Part 3 command resolution must be substantially finer than the 100 us steps used in Part 2.

### Timing states

Use explicit state to distinguish time-critical servo work from background application work.

A useful model is:

| State | Servo condition | Background work |
| --- | --- | --- |
| \`MIN_PULSE\` | Servo HIGH; no legal pulse may end before 500 us | bounded work may be performed |
| \`SERVO_BUSY\` | A commanded falling edge may be due | no noncritical work |
| \`FRAME_IDLE\` | Servo LOW; current pulse is complete | ADC, scaling, and next-command preparation allowed |

The first 500 us of every valid pulse is guaranteed HIGH. No legal falling edge can occur in that interval.

After the commanded falling edge occurs, the servo output remains LOW until the next frame. This creates a much larger interval in which main may prepare the next command.

The state names are suggestions. Equivalent names are acceptable if the meaning is documented.

### Main and ISR responsibilities

Keep the time-critical waveform path short.

The interrupt path should be responsible for:

- recognizing the scheduled compare event;
- changing the servo output at the required time;
- updating the servo timing state;
- scheduling the next required timing event.

Main should be responsible for work that can wait:

- ADC acquisition and conversion;
- converting ADC results into a next pulse-width command;
- preparing data for the next frame;
- later application work such as communications.

Use separate storage for:

- the pulse width currently controlling the active frame;
- the pulse width being prepared for the next frame.

A new ADC result must not change the current pulse after that frame has started.

### Shared-state protection

The ADC-derived pulse width and Timer1/CCP compare values are multi-byte quantities.

Main and the ISR must not combine bytes from different updates.

Develop and document a method that guarantees a complete next command is transferred into the active command at a defined frame boundary.

Do not assume a multi-byte update is atomic.

### Background-work window

Use the oscilloscope and diagnostic outputs to identify where background work occurs relative to the servo waveform.

At minimum, demonstrate that:

- the servo falling edge is not delayed by ADC acquisition or conversion;
- no noncritical work occurs while the design is in the \`SERVO_BUSY\` state;
- ADC work and next-command calculations occur only in states where they cannot interfere with a scheduled servo edge.

The design may use the guaranteed first 500 us and the interval after the servo falls for background work.

### Verification

Measure at minimum:

- 500 us command;
- 2.5 ms command;
- center command;
- at least eight additional points distributed across the ADC range;
- at least one pair of nearby ADC commands that produces a pulse-width change much smaller than 100 us.

For each point, record:

| ADC code / VIN | Expected pulse width | Measured pulse width | Measured frame period | Error |
| ---: | ---: | ---: | ---: | ---: |
|  |  |  |  |  |

Also measure the smallest pulse-width change that your implementation and oscilloscope can distinguish reliably.

### Compare Part 2 and Part 3

Quantify the improvement.

| Characteristic | Part 2 | Part 3 |
| --- | ---: | ---: |
| Command values | 21 | ... |
| Nominal pulse-width resolution | 100 us | ... |
| Measured smallest useful step | ... | ... |
| Maximum pulse-width error | ... | ... |
| Frame-period error | ... | ... |

Discuss whether the servo itself visibly responds to every additional electrical command step.

### Before Lab

Prepare or reference:

- Part 2 servo electrical analysis and verified safe pulse-width range;
- Timer1 SFR documentation and timer-tick calculation;
- CCP Compare SFR documentation and compare-event behavior;
- selected servo-output pin;
- frame-period method and calculation;
- ADC-to-pulse-width integer mapping;
- predicted Part 3 pulse-width resolution;
- \`MIN_PULSE\`, \`SERVO_BUSY\`, and \`FRAME_IDLE\` state diagram;
- active-command and next-command data representation;
- shared-state protection method;
- main-loop and ISR flowcharts;
- source code.

### In the Lab

1. Verify the Part 2 servo and ADC circuit still operates correctly.
2. Configure Timer1 and verify its actual timing against the calculated timer tick.
3. Configure CCP Compare and prove that it generates a repeatable scheduled event.
4. Generate the servo waveform without the servo connected.
5. Verify the servo rising edge, CCP-scheduled falling edge, and 20 ms frame period.
6. Verify no legal pulse ends before 500 us.
7. Observe or instrument the timing states and confirm no noncritical work occurs during \`SERVO_BUSY\`.
8. Verify ADC acquisition and next-command calculations do not disturb the current servo pulse.
9. Collect the required timing measurements across the ADC range.
10. Demonstrate a pulse-width change substantially smaller than the Part 2 100 us step.
11. Reconnect the servo after waveform verification.
12. Compare the additional electrical command resolution with the actual mechanical response.

### Evidence

Include or reference:

- Timer1 and CCP SFR documentation;
- Timer1 tick calculation;
- CCP Compare timing calculation;
- ADC-to-pulse-width mapping calculation;
- predicted number of command values and pulse-width resolution;
- state diagram;
- main-loop and ISR flowcharts;
- active/next command data design;
- documented shared-state protection;
- final source;
- oscilloscope evidence of the frame and CCP-scheduled falling edge;
- diagnostic evidence showing when background work and \`SERVO_BUSY\` occur;
- verification table across the ADC range;
- measured example of a pulse-width change much smaller than 100 us;
- Part 2 versus Part 3 comparison;
- observations of servo deadband, jitter, backlash, or other mechanical limits;
- troubleshooting record.

### Demonstrate

Vary the potentiometer while displaying the servo-control waveform.

Be prepared to explain:

- how Timer1 establishes the timebase;
- what condition causes the CCP Compare event;
- how the ADC result becomes a pulse-width deadline;
- why the current command cannot change in the middle of a frame;
- what \`MIN_PULSE\`, \`SERVO_BUSY\`, and \`FRAME_IDLE\` mean;
- why background work is allowed in some states but not during the timing-critical state;
- the difference between timer resolution, ADC command resolution, and actual servo mechanical resolution.

### Complete When

Part 3 is complete when CCP Compare controls the servo falling-edge timing, the 20 ms frame remains stable, the full ADC range produces substantially finer command resolution than Part 2, background ADC work does not disturb the time-critical edge, and the electrical resolution improvement has been measured and compared with the physical servo response.

[Back to top](#top) · [Course home](../README.md)


<a id="part-4"></a>
## Part 4 - Multi-Servo Event Scheduler

> **Design draft for instructor review:** The current draft target is four independently commanded servo-output channels. The important requirement is the scheduler architecture, not the number four itself. The final channel count can be adjusted to match available lab hardware.

### Goal

Extend the Part 3 Timer1/CCP design so one shared timebase can control multiple independent servo pulse widths without returning to periodic polling.

At the start of every 20 ms frame:

- all servo outputs go HIGH together;
- each servo has an active pulse-width deadline between 500 us and 2.5 ms;
- CCP Compare is programmed for the earliest pending falling-edge event;
- each servo output goes LOW when its scheduled deadline is reached.

The design must preserve enough timing resolution for smooth servo motion while keeping the timing-critical interrupt path short and predictable.

### Required channels

The draft target is **four servo-output channels**.

Each channel must have:

- its own next command;
- its own active pulse width;
- an identifiable output bit;
- a falling-edge deadline within the legal 500 us through 2.5 ms range.

Commands may come from separate ADC channels when enough potentiometers are available. Fixed test values may be used during scheduler development, but the completed design must demonstrate independent command values rather than moving all channels together.

### Frame timing model

All servo pulses begin together.

Conceptually:

\`\`\`text
frame start
    |
    +--> Servo 0 HIGH -----------------------> LOW at PW0
    +--> Servo 1 HIGH -------------> LOW at PW1
    +--> Servo 2 HIGH --------------------------------> LOW at PW2
    +--> Servo 3 HIGH ------------------> LOW at PW3

    0 us       500 us                         2500 us              20 ms
\`\`\`

No legal servo pulse may end before 500 us.

No legal servo pulse may remain HIGH after 2.5 ms.

The remaining frame time is available for noncritical application work.

### Event schedule

Do not repeatedly scan every servo at a fixed polling interval.

Before the active timing window, prepare a schedule of the falling-edge events required for the next frame.

Example:

\`\`\`text
Servo 0 = 1832 us
Servo 1 = 741 us
Servo 2 = 1832 us
Servo 3 = 1226 us

prepared event schedule:

741 us   -> clear Servo 1
1226 us  -> clear Servo 3
1832 us  -> clear Servo 0 and Servo 2
\`\`\`

Servos with the same deadline should share one event.

During the frame, CCP Compare should always contain the deadline for the **next** pending event.

When the compare event occurs:

1. clear every servo output due at that event;
2. advance to the next prepared event;
3. load the next compare deadline;
4. when the final servo falls LOW, end the timing-critical state.

The ISR should consume an already-prepared schedule. It should not perform ADC scaling, sorting, or other expensive preparation while servo edges are pending.

### Timing states

Use state to protect the timing-critical portion of the frame.

A useful model is:

| State | Time/condition | Servo condition | Main may do |
| --- | --- | --- | --- |
| \`MIN_PULSE\` | frame start through 500 us | all servo outputs HIGH | bounded background work |
| \`SERVO_BUSY\` | 500 us until final scheduled falling edge | one or more servo outputs may still be HIGH | no noncritical work |
| \`FRAME_IDLE\` | after final falling edge until next frame | all servo outputs LOW | prepare the next frame |

The final falling edge may occur before 2.5 ms. When it does, the design may enter \`FRAME_IDLE\` immediately rather than waiting until the maximum legal pulse width.

The 2.5 ms limit is an upper bound, not a mandatory busy duration.

### Main responsibilities

Main prepares future work while the active scheduler is not timing a potentially imminent servo edge.

Main should perform tasks such as:

- acquire ADC channels;
- apply required acquisition delays;
- convert ADC results into next pulse-width commands;
- validate pulse-width limits;
- group and order falling-edge deadlines;
- construct the next event schedule;
- prepare masks or other data needed by the ISR;
- perform later application work such as communications when those features are added.

Main must not modify the active event schedule being consumed by the ISR.

### Active and next schedules

Maintain separate **active** and **next** scheduling data.

\`\`\`text
main
    ADC measurements
        |
        v
    next commands
        |
        v
    next event schedule

             frame boundary
                  |
                  v
          active event schedule
                  |
                  v
          CCP event execution
\`\`\`

At a defined frame boundary, transfer or swap the completed next schedule into the active schedule.

The changeover must not allow the ISR to see a partly constructed event table.

Document the method used to make that transfer safe.

### Servo busy signal

Provide a software state flag and, where practical, a diagnostic output that indicates the timing-critical interval.

The signal should assert when the scheduler enters the portion of the frame where servo falling edges may be due and clear when the final scheduled servo edge has completed.

Use the diagnostic signal with the oscilloscope to verify that ADC work, scaling, sorting, and other noncritical operations do not occur inside the protected interval.

### Event spacing and resolution

Timer1 may have much finer raw resolution than the software scheduler can safely service when two different falling-edge deadlines are extremely close together.

Determine the minimum event spacing your implementation can support reliably.

Your design must account for:

- interrupt latency;
- context save/restore;
- output update time;
- loading the next CCP compare value;
- any event-table indexing or pointer updates.

If two desired deadlines are closer together than the scheduler can safely service, develop a documented policy such as grouping or quantizing commands to the supported scheduler resolution.

Do not claim Timer1 tick resolution as the multi-servo output resolution unless the complete event scheduler can actually service deadlines at that spacing.

The resulting multi-servo resolution should remain substantially finer than the 100 us command spacing used in Part 2.

### Verification

Begin with servo loads disconnected.

Use independent test commands that force the scheduler to handle:

- all channels at 500 us;
- all channels at 2.5 ms;
- four different pulse widths;
- at least two channels with the same pulse width;
- two different deadlines near the minimum event spacing your implementation claims;
- commands that change significantly from one frame to the next.

For every channel verify:

- rising edges occur together at frame start;
- measured HIGH time matches the active command;
- no pulse is shorter than 500 us or longer than 2.5 ms;
- the nominal frame period remains 20 ms;
- changing one channel does not corrupt another channel's pulse.

### Scheduler-resolution experiment

Measure the minimum spacing between two different falling-edge events that the scheduler can support without missing, delaying, or corrupting the second event.

Record:

| Test spacing | Event 1 error | Event 2 error | Missed/late event? | Acceptable? |
| ---: | ---: | ---: | --- | --- |
|  |  |  |  |  |

Use the measurements to state the supported multi-servo pulse-width resolution.

Compare this measured value with:

- the Timer1 tick;
- the Part 3 single-servo resolution;
- the Part 2 100 us resolution.

### Servo demonstration

After the multi-channel waveform has passed instructor checkoff, connect the available servos using an appropriate external supply and common reference.

Do not power multiple servos from PIC I/O pins or assume the logic-board supply can provide their combined current.

Demonstrate independent commands. Moving one command input must not unintentionally change another servo's pulse width.

If fewer physical servos are available than scheduler channels, verify the remaining channels electrically unless the instructor specifies another arrangement.

### Before Lab

Prepare or reference:

- Part 3 Timer1/CCP design;
- selected servo output pins;
- electrical/loading and power analysis for the planned servo count;
- per-channel command and active pulse-width data;
- proposed event-table format;
- method for grouping equal deadlines;
- method for ordering deadlines;
- output masks or equivalent event actions;
- \`MIN_PULSE\`, \`SERVO_BUSY\`, and \`FRAME_IDLE\` state diagram;
- active/next schedule strategy;
- protected schedule-transfer method;
- predicted ISR execution time and initial minimum-event-spacing estimate;
- main-loop and ISR flowcharts;
- source code.

### In the Lab

1. Begin with all servo loads disconnected.
2. Verify all scheduled outputs rise together at the beginning of each frame.
3. Verify the scheduler handles the minimum and maximum legal pulse widths.
4. Verify four different deadlines are serviced in the correct order.
5. Verify one compare event can clear multiple servo outputs that share a deadline.
6. Observe the \`SERVO_BUSY\` diagnostic and verify noncritical work stays outside the protected timing window.
7. Verify the final falling edge releases the scheduler into \`FRAME_IDLE\` without waiting unnecessarily for 2.5 ms.
8. Change ADC commands while the current frame is active and verify the new schedule takes effect only at the defined frame boundary.
9. Measure the minimum safe spacing between distinct falling-edge events.
10. Compare the measured scheduler resolution with the Part 2 and Part 3 results.
11. Obtain instructor waveform checkoff.
12. Connect the available servos and demonstrate independent control.

### Evidence

Include or reference:

- complete multi-servo schematic and power/loading analysis;
- event-table data format;
- example unsorted commands and the resulting prepared event schedule;
- equal-deadline grouping method;
- active/next schedule design;
- protected schedule-transfer method;
- state diagram;
- main-loop and ISR flowcharts;
- ISR timing analysis;
- final source;
- oscilloscope capture showing simultaneous rising edges and different falling edges;
- oscilloscope capture showing two or more channels sharing a falling-edge event;
- \`SERVO_BUSY\` diagnostic evidence;
- minimum-event-spacing measurement table;
- measured supported multi-servo pulse-width resolution;
- comparison with Part 2 and Part 3 resolution;
- independent-servo demonstration results;
- troubleshooting record.

### Demonstrate

Show multiple servo-output channels on the oscilloscope.

Be prepared to explain:

- why all pulses can start together;
- why no falling edge is legal during the first 500 us;
- how the next CCP deadline is selected;
- how equal pulse widths are handled;
- why the ISR consumes a prepared event schedule instead of building one;
- what \`SERVO_BUSY\` protects;
- how the active and next schedules prevent mid-frame command corruption;
- what determines the actual multi-servo timing resolution;
- where ADC acquisition, calculations, and future communications fit into the 20 ms frame.

After waveform verification, demonstrate independent physical servo control with the available hardware.

### Complete When

Part 4 is complete when multiple servo channels share one Timer1/CCP event scheduler, all channels begin each frame together, each channel falls at its own scheduled pulse-width deadline, noncritical work is excluded from the protected timing window, the next frame is prepared safely outside the active schedule, and the supported multi-servo timing resolution has been measured and justified.

[Back to top](#top) · [Course home](../README.md)
