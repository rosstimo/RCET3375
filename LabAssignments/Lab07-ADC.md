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
- [Part 3 - 6-bit lookup table and CCP Compare](#part-3)
- [Part 4 - Full 10-bit calculated mapping](#part-4)
- [Part 5 - Mastery: three-servo CCP scheduler](#part-5)

<a id="purpose"></a>
## Purpose

Build a measured analog-to-digital conversion path on the PIC16F883, then use the converted value to control a physical output.

The first part makes the ADC itself visible. You will vary a potentiometer from 0 V to VDD, observe the complete 10-bit conversion result through `ADRESH:ADRESL`, measure how long the conversion takes, and compare the measured analog voltage with the value represented by the ADC result.

Later parts reuse the timer work from Lab 06, introduce the CCP Compare module, compare lookup-table and calculated mapping methods, and then extend the same timing model to multiple servos.

[Back to top](#top) · [Course home](../README.md)

<a id="standards-references"></a>
## Standards and references

- [RCET 3375 Lab Standard](../LAB_STANDARD.md)
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md)
- [RCET 3373 PIC16F883 ADC and Sensor Conditioning](https://github.com/rosstimo/RCET3373/blob/main/Topics/pic16f883-adc.md)
- [RCET 3373 Lookup Tables and Dynamic Timing](https://github.com/rosstimo/RCET3373/blob/main/Topics/lookup-tables-dynamic-timing.md)
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
- servo motor for Parts 2 through 4; three servos and three potentiometers for optional Part 5 Mastery
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
## Part 3 - 6-Bit Lookup Table and CCP Compare

### Goal

Improve the 100 us command resolution from Part 2 by using:

- the upper 6 bits of the ADC result;
- a 64-entry lookup table;
- Timer1 as a 1 us timebase;
- CCP1 Compare to schedule the servo falling edge.

The servo waveform remains the same basic signal used in Part 2:

- nominal 20 ms frame period;
- 500 us minimum HIGH pulse width;
- 2.5 ms maximum HIGH pulse width.

The important changes are the mapping method and the way the falling edge is timed.

### CCP Compare at a high level

The PIC16F883 CCP module can operate in **Capture**, **Compare**, or **PWM** mode. This lab uses **Compare** mode.

In Compare mode, the hardware continuously compares the 16-bit value in `CCPR1H:CCPR1L` with the 16-bit Timer1 count in `TMR1H:TMR1L`.

Conceptually:

```text
Timer1 count ----+
                 | compare
CCPR1 value -----+
                 |
                 +--> equal --> CCP1 compare event
```

For this lab, configure CCP1 so a match creates a CCP interrupt. The servo signal itself may remain on an ordinary GPIO output.

The timing sequence is:

1. Timer1 overflow begins a new 20 ms frame.
2. Drive the servo output HIGH.
3. Load `CCPR1H:CCPR1L` with the timer value at which the pulse should end.
4. Timer1 continues counting in hardware while the CPU is free to do other work.
5. When `TMR1H:TMR1L == CCPR1H:CCPR1L`, the CCP module sets `CCP1IF`.
6. The CCP interrupt drives the servo output LOW.

CCP Compare does not replace Timer1. Timer1 provides the timebase; CCP watches that timebase for a programmed match.

For the register-level details, use the PIC16F883 data sheet sections for Timer1 and the Capture/Compare/PWM module. In your lab book, document at minimum `T1CON`, `TMR1H:TMR1L`, `CCP1CON`, `CCPR1H:CCPR1L`, `PIR1.CCP1IF`, and `PIE1.CCP1IE`.

### Reduce the ADC result to 6 bits

Use the upper 6 bits of the 10-bit ADC conversion as the command index.

```text
index = ADC >> 4
```

This produces:

```text
ADC codes 0 through 1023
        |
        v
6-bit index 0 through 63
        |
        v
64 possible servo commands
```

Using the upper bits keeps the mapping monotonic and gives every 6-bit index a contiguous range of ADC codes.

### Map 64 commands across the servo range

There are 64 command values but only 63 intervals between the first and last command.

Therefore the ideal pulse-width spacing is:

```text
step = (2500 us - 500 us) / 63
     = 2000 us / 63
     = 31.746... us
```

For lookup-table entry `n`:

```text
pulse width = 500 us + round(n x 2000 us / 63)
```

The first entry should produce approximately 500 us and the last entry should produce approximately 2500 us.

A straightforward PIC implementation may use two 64-entry `RETLW` tables, one for the low byte and one for the high byte of the 16-bit CCP match value. Other correct lookup-table structures are acceptable if they preserve all 64 commands and the required endpoints.

This table is intentionally large enough to make the memory cost visible. Part 4 will replace it with a calculation.

### Worked mapping example

Assume:

- Timer1 ticks once every 1 us;
- Timer1 is loaded with `0xB1E0` at the beginning of a 20 ms frame;
- ADC result = 512.

First reduce the 10-bit ADC value to 6 bits:

```text
index = 512 >> 4
      = 32
```

Then calculate the ideal table value:

```text
pulse width = 500 us + round(32 x 2000 us / 63)

            = 500 us + round(1015.87 us)

            = 1516 us
```

Because Timer1 began the frame at `0xB1E0`, the absolute CCP match value is:

```text
CCP match = 0xB1E0 + 1516
          = 0xB7CC
```

So the table entry for index 32 would contain the bytes needed to load `CCPR1H:CCPR1L = 0xB7CC`.

Your own timer preload may differ. Use the value produced by your actual Timer1 design.

### Required behavior

- The ADC command uses 6-bit resolution, giving 64 command values.
- The lookup table spans approximately 500 us through 2500 us.
- Timer1 maintains the 20 ms frame.
- CCP Compare schedules the servo falling edge.
- The CPU does not wait in a software timing loop for the falling edge.
- ADC acquisition and lookup work for the next frame occurs after the active servo pulse is complete.
- The servo waveform is verified on the oscilloscope before connecting the servo.

### Before Lab

Prepare or reference:

- Part 2 servo electrical analysis;
- Timer1 configuration and 1 us tick calculation;
- CCP1 Compare SFR documentation;
- the 10-bit to 6-bit ADC reduction;
- the 64-command pulse-width calculation;
- one complete worked mapping example;
- lookup-table structure and program-memory estimate;
- main-loop and ISR flowcharts;
- source code.

### In the Lab

1. Verify Timer1 produces the intended frame timing.
2. Configure CCP1 Compare and verify a repeatable compare interrupt.
3. Generate the servo waveform with the servo disconnected.
4. Test the first, center, and last lookup-table entries.
5. Test several intermediate entries distributed across the table.
6. Verify adjacent table entries differ by approximately 31.75 us.
7. Obtain instructor waveform checkoff.
8. Connect the servo and sweep through the 64 command values.
9. Compare the electrical command resolution with the mechanical servo response.

### Evidence

Include or reference:

- Timer1 and CCP1 SFR documentation;
- Timer1 tick and frame-period calculations;
- 6-bit ADC mapping calculation;
- worked mapping example;
- lookup table and program-memory estimate;
- final source code;
- oscilloscope captures showing the 20 ms frame and CCP-controlled falling edge;
- measured pulse widths at the endpoints, center, and several intermediate commands;
- comparison with Part 2 resolution;
- troubleshooting record.

### Demonstrate

Be prepared to explain:

- why the upper 6 ADC bits create 64 commands;
- why 64 command values contain 63 intervals;
- how the lookup table converts an ADC index into a timer deadline;
- what Timer1 does;
- what CCP Compare does;
- why the CPU does not need to wait for the falling edge;
- why a 64-entry table is manageable but a much larger table may become unattractive.

### Complete When

Part 3 is complete when the 6-bit ADC command selects all 64 lookup-table entries, CCP Compare produces the scheduled falling edge, the waveform spans approximately 500 us through 2500 us inside a stable 20 ms frame, and the measured resolution is substantially finer than Part 2.

[Back to top](#top) · [Course home](../README.md)


<a id="part-4"></a>
## Part 4 - Full 10-Bit Calculated Mapping

### Goal

Use all 10 ADC bits to command the servo without creating a 1024-entry lookup table.

Keep the Timer1 and CCP Compare architecture from Part 3. Change only the ADC-to-deadline mapping method.

### Why replace the lookup table?

A 6-bit command requires 64 entries.

A full 10-bit command has:

```text
2^10 = 1024 possible ADC codes
```

If every 10-bit ADC code had its own stored 16-bit compare value, the table would become very large. Instead, calculate the compare value from the ADC result.

The ideal pulse-width equation is:

```text
pulse width = 500 us + (ADC x 2000 us / 1023)
```

The ideal change per ADC count is approximately:

```text
2000 us / 1023 = 1.955 us per count
```

### Integer mapping used in this lab

A convenient PIC-friendly approximation is:

```text
pulse width = 500 us + 2 x ADC - floor(3 x ADC / 64)
```

This works because:

```text
2 - 3/64 = 1.953125
```

which is very close to the ideal slope:

```text
2000 / 1023 = 1.955034...
```

The calculation can be implemented with shifts, additions, and subtraction rather than a general multiply or divide routine.

Check the endpoints:

```text
ADC = 0
pulse = 500 us

ADC = 1023
pulse = 500 + 2046 - floor(3069 / 64)
      = 500 + 2046 - 47
      = 2499 us
```

The 1 us high-end difference is an acceptable consequence of this simple integer approximation.

### Worked mapping example

Assume:

- Timer1 ticks once every 1 us;
- Timer1 begins each frame at `0xB1E0`;
- ADC result = 512.

Using the integer mapping:

```text
pulse width = 500 + 2(512) - floor(3(512) / 64)

            = 500 + 1024 - floor(1536 / 64)

            = 500 + 1024 - 24

            = 1500 us
```

The corresponding absolute CCP match is:

```text
CCP match = 0xB1E0 + 1500
          = 0xB7BC
```

For comparison, the ideal linear equation gives:

```text
500 + (512 x 2000 / 1023)
= 1500.98 us
```

The integer result is therefore about 1 us below the ideal value for this example.

### Program structure

Keep the interrupt work short.

A simple structure is:

```text
Timer1 overflow interrupt:
    reload Timer1
    servo HIGH
    load the already-calculated CCP match
    mark servo busy

CCP1 compare interrupt:
    servo LOW
    clear servo busy

main:
    wait until the active pulse is finished
    acquire ADC
    calculate the next CCP match
    wait for the next frame
```

The next ADC result must not change the compare value currently controlling an active pulse.

### Required behavior

- Use the complete 10-bit ADC result.
- Produce approximately 1024 command values.
- Use the calculated mapping rather than a full-resolution lookup table.
- Maintain the 500 us through approximately 2500 us command range.
- Maintain the nominal 20 ms frame.
- Use CCP Compare for the falling-edge event.
- Perform ADC acquisition and mapping outside the active servo pulse.

### Before Lab

Prepare or reference:

- Part 3 Timer1/CCP design;
- ideal 10-bit mapping equation;
- integer approximation and explanation;
- one complete worked mapping example;
- endpoint calculations for ADC 0 and ADC 1023;
- predicted pulse-width change per ADC count;
- main-loop and ISR flowcharts;
- source code.

### In the Lab

1. Replace the Part 3 lookup-table mapping with the full 10-bit calculation.
2. Verify the 500 us endpoint.
3. Verify the high endpoint is approximately 2499 us.
4. Verify the center command.
5. Measure several additional commands distributed across the ADC range.
6. Measure nearby ADC commands and determine the smallest electrical change you can resolve reliably.
7. Verify the 20 ms frame remains stable.
8. Connect the servo after waveform verification and compare electrical resolution with mechanical response.

### Evidence

Include or reference:

- ideal mapping equation;
- integer approximation and derivation;
- worked mapping example;
- endpoint calculations;
- final source code;
- oscilloscope evidence for low, center, and high commands;
- measured pulse-width error at several ADC values;
- comparison of Part 3 lookup-table memory cost with Part 4 calculation cost;
- measured smallest useful electrical command step;
- troubleshooting record.

### Demonstrate

Be prepared to explain:

- why the lookup table was reasonable at 6 bits but unattractive at 10 bits;
- how the integer equation approximates the ideal linear mapping;
- how the calculated pulse width becomes an absolute CCP match value;
- what work occurs in main;
- what work occurs in each interrupt;
- the difference between ADC resolution, timer resolution, electrical pulse-width resolution, and mechanical servo resolution.

### Complete When

Part 4 is complete when all 10 ADC bits are used, the calculated mapping produces the expected servo pulse range, CCP Compare controls the falling edge, the 20 ms frame remains stable, and measured timing agrees with the predicted integer mapping.

[Back to top](#top) · [Course home](../README.md)


<a id="part-5"></a>
## Part 5 - Mastery: Three-Servo CCP Scheduler

Part 5 is optional Mastery. Complete Parts 1 through 4 before beginning this section.

### Goal

Extend the Part 4 design to control **three servos**, each with an independent full 10-bit ADC command, while sharing one Timer1 timebase and one CCP Compare module.

Use three analog inputs and three servo output pins.

### Timing model

At the beginning of every 20 ms frame:

1. drive all three servo outputs HIGH;
2. each servo already has a calculated falling-edge deadline;
3. load CCP1 with the earliest deadline;
4. when CCP1 interrupts, drive every servo LOW whose deadline must be serviced now;
5. if another servo remains HIGH, load CCP1 with the earliest remaining deadline;
6. after all three servos are LOW, acquire and calculate the commands for the next frame.

All three rising edges occur together. The falling edges occur independently.

### Closely spaced deadlines

Timer1 may have 1 us resolution, but software cannot necessarily service two independent CCP interrupts only a few microseconds apart.

Do not stop Timer1 or read the live 16-bit Timer1 count inside the CCP scheduler merely to determine whether another event is too close.

Instead, keep the saved compare value that caused the current interrupt:

```text
current_match
```

Define a minimum software service window:

```text
service_limit = current_match + service_margin
```

Any active servo with:

```text
servo_match <= service_limit
```

is driven LOW during the current interrupt.

Then load CCP1 with the earliest remaining deadline.

This intentionally combines events that are too close together for the complete interrupt path to service reliably as separate events.

### Determine the service margin

Do not assume the Timer1 tick is the minimum safe spacing between independent servo edges.

Estimate the required margin from:

- interrupt entry latency;
- context save;
- compare-event handling;
- output update;
- loading a new 16-bit CCP value;
- context restore;
- `RETFIE`;
- latency before the next interrupt can be serviced.

Begin with a conservative margin, verify it on the oscilloscope, then reduce it until you can state a measured minimum reliable spacing.

### Required behavior

- Three independent 10-bit ADC commands control three servo outputs.
- All three outputs rise together at the frame boundary.
- One Timer1 establishes the frame timebase.
- One CCP Compare module schedules falling-edge events.
- Events inside the measured service margin are handled together.
- Widely separated deadlines are handled as separate CCP events.
- Mapping calculations occur after the three active pulses are finished.
- Changing one command does not corrupt another servo's pulse.

### Before Lab

Prepare or reference:

- Part 4 mapping and Timer1/CCP design;
- three ADC input channels;
- three servo output pins;
- servo power and loading analysis for three servos;
- per-servo 16-bit deadline storage;
- active-servo bit mask or equivalent state representation;
- algorithm for selecting the earliest active deadline;
- initial service-margin estimate from instruction timing;
- main-loop and ISR flowcharts;
- source code.

### In the Lab

Begin with the servos disconnected.

Verify these cases on the oscilloscope:

1. three widely separated pulse widths;
2. two identical pulse widths;
3. three identical pulse widths;
4. two deadlines closer than the current service margin;
5. two deadlines just farther apart than the current service margin;
6. commands changing independently from frame to frame.

Reduce the service margin only after the scheduler works reliably.

After waveform verification and instructor checkoff, connect the three servos using an appropriate external supply and common ground.

### Evidence

Include or reference:

- three-servo schematic and loading analysis;
- per-servo ADC and deadline data structure;
- service-margin timing estimate;
- final source code;
- scope capture with three simultaneous rising edges and three separated falling edges;
- capture showing two equal or near-equal deadlines handled together;
- minimum reliable independently scheduled event spacing;
- comparison of Timer1 tick resolution, Part 4 single-servo command resolution, and Part 5 scheduler resolution;
- independent three-servo demonstration;
- troubleshooting record.

### Demonstrate

Be prepared to explain:

- how three ADC values become three full-resolution deadlines;
- why all three rising edges can occur together;
- how the earliest falling-edge deadline is selected;
- why deadlines inside the service window are handled together;
- why Timer1 is not stopped to read the current time;
- why the multi-servo timing resolution is limited by more than the Timer1 tick.

### Complete When

Mastery is complete when three servos operate from independent full 10-bit ADC commands, one Timer1 and one CCP Compare module schedule all three waveforms, close deadlines are handled according to a measured service-margin policy, and the electrical timing has been verified before the servos are connected.

[Back to top](#top) · [Course home](../README.md)
