<a id="top"></a>

# RCET 3375 Lab 07 - ADC and Servo Control

[RCET3375 course home](../README.md)

PIC16F883 | pic-as | ADC | Acquisition Time | TAD | Result Justification | Measurement | Servo Control

## Contents

- [Purpose](#purpose)
- [Standards and references](#standards-references)
- [Equipment and materials](#equipment-materials)
- [Part 1 - ADC proof of life](#part-1)

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
- servo motor, used in later parts
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
