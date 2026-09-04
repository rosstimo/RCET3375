# Lab 03 - Delays

## Purpose

Measure PIC16F883 instruction timing, use instruction-cycle calculations to create precise software delays, extend those delays with nested loops, and then refactor the working delay into reusable subroutines.

The lab progresses from measurement to prediction, implementation, verification, and reusable program structure.

## Standards and references

- [RCET 3375 Lab Standard](../LAB_STANDARD.md)
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md)
- [PIC16F883 Data Sheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf)
- [PICmicro Mid-Range MCU Family Reference Manual](https://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf)
- DLG7137 datasheet

## Equipment and materials

- MPLAB X IDE and pic-as toolchain
- PICkit programmer/debugger
- PIC16F883 circuit from Lab 02
- 4 MHz crystal oscillator circuit
- DLG7137 display
- Oscilloscope
- Frequency counter
- Logic analyzer, optional
- Digital multimeter
- Lab book

---

# Part 1 - Measure Instruction Timing

### Goal

Use the PORTB counter program from Lab 02 to measure the execution time of PIC16F883 instructions.

Use the RB0 output waveform to:

- measure pulse width (PW), pulse space (PS), period, and frequency;
- relate the measured waveform to the instructions executing in the program loop;
- determine the actual instruction-cycle time, $T_{CY}$;
- calculate the actual oscillator frequency;
- verify the effect of adding and removing `NOP` instructions.

The purpose of this part is to connect assembly instructions to real, measurable time.

### Before Lab

Start with the working PORTB counter program from Lab 02.

Do not recreate unchanged code, flowcharts, schematics, SFR documentation, or other work from the previous assignment. Reference the previous work where needed.

Review the instructions executed repeatedly in the main program loop.

For each instruction in the repeating path:

1. identify how many instruction cycles it requires;
2. determine how many instruction cycles occur between changes of RB0.

The PIC instruction clock is related to the oscillator by:

$$
T_{OSC}=\frac{1}{F_{OSC}}
$$

and

$$
T_{CY}=4T_{OSC}
$$

Therefore:

$$
F_{OSC}=\frac{4}{T_{CY}}
$$

The circuit uses a nominal 4 MHz crystal. Calculate the expected instruction-cycle time before making measurements.

Determine the expected number of instruction cycles for:

- RB0 PW;
- RB0 PS;
- one complete RB0 period.

Record your predictions before measuring the circuit.

### In the Lab

#### 1. Measure the Lab 02 counter

Build and program the PIC16F883 using your working Lab 02 PORTB counter program.

Connect the oscilloscope to **RB0**, the least significant bit of the counter output.

Measure and record:

- PW;
- PS;
- period;
- frequency.

Capture an oscilloscope image showing enough of the waveform to verify the measurements.

Compare PW and PS and explain why RB0 changes state at the observed rate based on the binary count and the instructions in the main loop.

#### 2. Determine the instruction-cycle time

Use the measured waveform and the instruction-cycle analysis of the main loop to calculate the actual instruction-cycle time.

If $N$ instruction cycles occur during one measured interval:

$$
T_{CY}=\frac{t_{measured}}{N}
$$

If you use the complete waveform period, account for all instruction cycles executed during the entire period.

Do not assume $T_{CY}=1\ \mu s$ for this measurement. Determine $T_{CY}$ from the actual waveform.

#### 3. Determine the oscillator frequency

Calculate the actual oscillator frequency from the measured instruction-cycle time:

$$
F_{OSC}=\frac{4}{T_{CY}}
$$

Compare the result with the nominal 4 MHz crystal frequency.

Calculate the percent difference:

$$
\%\ difference=
\frac{|F_{measured}-F_{nominal}|}{F_{nominal}}
\times100\%
$$

Explain possible reasons why the measured oscillator frequency is not exactly 4.000000 MHz.

#### 4. Add and remove `NOP`

Add one `NOP` instruction to the repeating execution path of the main loop.

Before programming the PIC, predict the resulting change in PW, PS, period, and frequency.

Build and program the modified code, then measure RB0 again.

Compare the measured timing change with the instruction-cycle time determined earlier.

Remove the `NOP`, program the PIC again, and verify that the waveform returns to its previous timing.

### Evidence

Include or reference:

- the Lab 02 PORTB counter source and flowchart;
- the instruction-cycle analysis of the repeating loop;
- predicted PW, PS, period, and frequency;
- oscilloscope capture of the original RB0 waveform;
- measured PW, PS, period, and frequency;
- calculated $T_{CY}$;
- calculated oscillator frequency;
- comparison with the nominal 4 MHz oscillator frequency;
- **modified source code showing the added `NOP`**;
- predicted and measured timing change caused by the `NOP`;
- verification after the `NOP` is removed;
- explanation of any difference between predicted and measured values.

A waveform screenshot by itself is not sufficient. State what you expected, what you measured, and what the measurement demonstrates.

### Demonstrate

Show the instructor the operating Lab 02 counter and RB0 waveform.

Be prepared to:

- identify PW, PS, period, and frequency;
- trace the instructions executed between RB0 transitions;
- state the instruction-cycle count for the measured interval;
- calculate $T_{CY}$ from the waveform;
- calculate $F_{OSC}$ from $T_{CY}$;
- explain the relationship between $F_{OSC}$, $T_{OSC}$, and $T_{CY}$;
- predict the effect of adding or removing a `NOP`;
- demonstrate the measured timing change caused by the `NOP`.

### Complete When

Part 1 is complete when:

- RB0 timing has been measured and documented;
- the measured waveform has been related correctly to the instructions in the main loop;
- the actual instruction-cycle time has been calculated from measured data;
- the oscillator frequency has been derived from the measured instruction-cycle time;
- the timing effect of adding and removing a `NOP` has been predicted and verified;
- the required evidence has been recorded;
- the instructor checkoff is complete.

---

# Part 2 - Create a Precise Short Delay

### Goal

Create a new PIC16F883 project that toggles RB0 using `XORWF`, then add a calculated software delay to produce a 10 kHz square wave.

Use a nominal instruction-cycle time of:

$$
T_{CY}=1\ \mu s
$$

for all initial predictions and design calculations.

After measuring the circuit, use the actual instruction-cycle time determined in Part 1 to calculate the expected real timing and compare it with the measured results.

### Before Lab

Create a **new MPLAB X project** for this part.

Use the project structure, PIC configuration, oscillator configuration, and assembly conventions established in Lab 02. Reference earlier documentation where nothing has changed.

Begin with this repeating output loop:

```assembly
MainLoop:
    MOVLW 0x01      ; 1 TCY 
    XORWF PORTB,1   ; 1 TCY
    GOTO  MainLoop  ; 2 TCY
```

Determine what waveform this program should produce on RB0.

For your initial prediction, use:

$$
T_{CY}=1\ \mu s
$$

Predict:

- PW;
- PS;
- period;
- frequency;
- duty cycle.

Show how the instruction-cycle count of the repeating loop produces these values.

### In the Lab

#### 1. Verify the `XORWF` toggle loop

Build and program the new project using the unmodified loop.

Measure RB0 using the oscilloscope and frequency counter.

Record:

- PW;
- PS;
- period;
- frequency;
- duty cycle.

Compare the measured values with the prediction based on $T_{CY}=1\ \mu s$.

Then use the actual instruction-cycle time measured in Part 1 to calculate the expected PW, PS, period, frequency, and duty cycle for the actual processor.

Compare:

1. the nominal prediction using $1\ \mu s/TCY$;
2. the expected result using the measured $T_{CY}$;
3. the oscilloscope measurement;
4. the frequency-counter measurement.

Explain why `XORWF PORTB,1` causes RB0 to alternate between HIGH and LOW.

#### 2. Determine the required timing

Modify the program so RB0 produces:

- **10 kHz frequency**;
- **50% duty cycle**.

A 10 kHz square wave has a period of:

$$
T=\frac{1}{10\,000}=100\ \mu s
$$

For a 50% duty-cycle square wave:

$$
PW=PS=\frac{T}{2}=50\ \mu s
$$

Use the nominal value:

$$
T_{CY}=1\ \mu s
$$

to design the delay.

Determine the number of instruction cycles required between successive RB0 transitions.

Account for every instruction executed between transitions. Do not treat the delay loop as if it were the only code consuming time.

#### 3. Create a software delay loop

Use an 8-bit counter and `DECFSZ` to add the required delay.

Use the following example to analyze how a software delay loop works:

```assembly
count    EQU 0x20                   ;use data memory address 0x20 as an 8-bit loop counter  

MainLoop:
    MOVLW 0x01                      ;1 TCY code not part of delay
    XORWF PORTB,1                   ;1 TCY code not part of delay

    MOVLW 0x09                      ;1 TCY delay overhead
    MOVWF count                     ;1 TCY delay overhead
DelayLoop:                     
    DECFSZ count,1                  ;1(2) 1 TCY if not zero, 2 TCY if zero
    GOTO DelayLoop                  ;2 TCY

    GOTO   MainLoop                 ;2 TCY code not part of delay
```

Work from the inside of the delay loop outward.

For a starting count of $N$:

$$
T_{loop}=N(1+2)-1
$$

which simplifies to:

$$
T_{loop}=3N-1
$$

instruction cycles.

Then include the delay-overhead instructions:

$$
T_{delay}=N(1+2)-1+1+1
$$

which simplifies to:

$$
T_{delay}=3N+1
$$

instruction cycles.

For the example value $N=9$:

$$
T_{delay}=3(9)+1=28
$$

instruction cycles.

Using the nominal instruction-cycle time:

$$
T_{CY}=1\ \mu s
$$

the nominal delay is:

$$
t_{delay}=28\ \mu s
$$

The delay calculation does not yet describe the complete PW or PS. The other instructions in `MainLoop` also consume time.

For the example above:

$$
PW=(3N+1)+1+1+2
$$

which simplifies to:

$$
PW=3N+5
$$

instruction cycles.

Because the same execution path occurs between every toggle, the same calculation applies to PS.

#### 4. Determine the counter value

Use:

$$
PW=PS=50\ \mu s
$$

and:

$$
T_{CY}=1\ \mu s
$$

to determine the required number of instruction cycles between RB0 transitions.

Then determine:

- instruction cycles consumed outside the delay;
- instruction cycles required from the delay;
- the required counter value;
- whether any `NOP` instructions are needed to achieve the desired timing.

The delay counter must be calculated. Do not select the counter value by trial and error.

Before programming the modified code, record:

- desired PW and PS;
- required instruction cycles between transitions;
- instruction cycles consumed outside the delay;
- required delay cycles;
- selected counter value;
- any `NOP` instructions used;
- predicted PW, PS, period, frequency, and duty cycle.

All initial predictions must use $T_{CY}=1\ \mu s$.

Show the modified source code containing the delay.

#### 5. Build and measure the calculated delay

Build and program the PIC16F883 using the calculated delay.

Measure RB0 using both the oscilloscope and frequency counter.

Record:

- PW;
- PS;
- period;
- frequency;
- duty cycle.

First compare the measurements with the nominal prediction based on $T_{CY}=1\ \mu s$.

Then use the actual $T_{CY}$ measured in Part 1 to calculate what PW, PS, period, frequency, and duty cycle the program should produce on the actual processor.

If the timing differs from the nominal prediction but agrees with the result calculated from measured $T_{CY}$, explain why.

If the timing does not agree with either calculation, use the instruction-cycle analysis to determine the cause before changing the program.

Do not tune the delay by repeatedly changing values until the measurement looks correct.

### Evidence

Include:

- timing calculation for the original `XORWF` loop using $T_{CY}=1\ \mu s$;
- oscilloscope and frequency-counter measurements of the original `XORWF` loop;
- expected timing of the original loop using the measured $T_{CY}$ from Part 1;
- calculation of the required 10 kHz waveform;
- derivation of the delay-loop timing;
- calculation of the required counter value;
- calculations for any `NOP` instructions used;
- **modified source code showing the completed delay**;
- predicted PW, PS, period, frequency, and duty cycle using $1\ \mu s/TCY$;
- expected PW, PS, period, frequency, and duty cycle using measured $T_{CY}$;
- oscilloscope measurements;
- frequency-counter measurements;
- comparison of predicted, expected, and measured values;
- explanation of any differences.

Previous unchanged schematics, register documentation, configuration information, code, and flowcharts may be referenced rather than recreated.

Use a comparison table similar to:

| Quantity | Predicted at 1 us/TCY | Expected Using Measured TCY | Oscilloscope | Frequency Counter |
| --- | ---: | ---: | ---: | ---: |
| PW |  |  |  |  |
| PS |  |  |  |  |
| Period |  |  |  |  |
| Frequency |  |  |  |  |
| Duty cycle |  |  |  |  |

### Demonstrate

Demonstrate the 10 kHz RB0 output using the oscilloscope and frequency counter.

Be prepared to:

- explain how the original `XORWF` toggle loop operates;
- calculate the timing of the original loop using $1\ \mu s/TCY$;
- identify PW, PS, period, frequency, and duty cycle;
- explain how the required 10 kHz timing was determined;
- explain how `DECFSZ` affects the timing of the final loop iteration;
- derive the delay-loop timing equation;
- show how the counter value was calculated;
- identify every instruction executed between RB0 transitions;
- explain any `NOP` instructions used for timing adjustment;
- calculate the expected real timing using measured $T_{CY}$ from Part 1;
- compare the nominal prediction, expected real timing, oscilloscope measurement, and frequency-counter measurement.

### Complete When

Part 2 is complete when:

- the new project operates correctly;
- the original `XORWF` toggle loop has been predicted and measured;
- a single software delay loop has been calculated and added;
- the program is designed to produce 10 kHz with 50% duty cycle using the nominal $1\ \mu s$ instruction-cycle time;
- PW, PS, period, frequency, and duty cycle have been measured;
- the measured results have been compared with both the nominal prediction and expected values calculated from measured $T_{CY}$;
- the modified source code and required evidence are recorded;
- the instructor checkoff is complete.

---

# Part 3 - Create and Verify a Long Delay

### Goal

Use nested software delay loops to create a much longer time interval than can be produced conveniently with a single 8-bit loop.

Design a program that alternates the DLG7137 display between `5` and `0` with a nominal pulse width and pulse space of:

$$
PW=PS=0.500000\ s
$$

The timing calculation must be accurate to within one nominal instruction cycle:

$$
\pm 1\ \mu s
$$

Then determine whether the available measurement equipment can verify that level of timing accuracy.

### Before Lab

Continue using:

$$
T_{CY}=1\ \mu s
$$

for initial design calculations.

Determine the longest delay that can be produced using the single 8-bit loop method from Part 2 and explain why that method is not practical for creating a 0.5 s delay.

Design an **inline nested delay loop** capable of producing the required interval.

Do not use:

- subroutines;
- timer peripherals;
- interrupts.

Account for every instruction executed between changes of the display value, including:

- initialization of each counter;
- inner-loop execution;
- outer-loop execution;
- skipped instructions;
- branch instructions;
- instructions used to change the displayed value;
- any `NOP` instructions used for final timing adjustment.

Use a nominal instruction-cycle time of $1\ \mu s$ to predict PW, PS, period, frequency, and duty cycle.

The calculated PW and PS should each be within one instruction cycle of 0.500000 s.

Previous unchanged code, flowcharts, schematics, SFR documentation, and other material may be referenced rather than recreated.

### Measurement precision and resolution

Every measurement has a limit to the amount of detail the instrument can distinguish.

When recording a timing measurement:

- record the measured value;
- record the displayed measurement resolution;
- consider whether that resolution is sufficient to support the conclusion you are making.

A measurement should not be reported with more meaningful precision than the instrument and measurement conditions can support.

Use both the oscilloscope and frequency counter during this part. Determine which instrument and measurement method provide enough resolution for the measurements you need to make.

### In the Lab

#### 1. Build the nested delay

Implement the calculated nested delay.

The DLG7137 must alternate continuously between:

```text
5
0
5
0
...
```

with a nominal 0.5 s interval between changes.

Show the modified source code containing the nested delay.

#### 2. Measure with the oscilloscope

Use a PIC output signal that changes state at the same interval as the displayed value so the timing can be measured electrically.

Measure:

- PW;
- PS;
- period;
- frequency.

Record the oscilloscope measurement and the resolution of the displayed measurement.

Compare the measurement with the predicted result.

Determine whether the measurement supports the statement:

> The timing is 0.500000 s +/- 1 us.

Be prepared to explain the answer.

#### 3. Measure with the frequency counter

Measure the same signal using the frequency counter.

Measure and record:

- PW;
- PS;
- period;
- frequency.

Record the displayed resolution for each measurement.

Compare the frequency-counter measurements with:

- the nominal prediction using $T_{CY}=1\ \mu s$;
- the oscilloscope measurements;
- the expected result using measured $T_{CY}$ from Part 1.

Determine whether the measurement provides enough resolution to evaluate timing differences of approximately $1\ \mu s$.

#### 4. Change the program by one instruction cycle

Add exactly one `NOP` to the execution path between output transitions.

Before programming the PIC, predict the resulting change in:

- PW;
- PS;
- period;
- frequency.

Do not change any counter values.

Program the modified code and measure the timing again.

Determine whether the expected one-instruction-cycle change can be observed.

Record:

- the original measurement;
- the measurement with one additional `NOP`;
- the expected difference;
- the measured difference;
- the resolution of the instrument used.

Then remove the `NOP`, program the PIC again, and determine whether the measurement returns to its previous value.

### Evidence

Include:

- calculation showing why a single 8-bit loop is insufficient for the required delay;
- complete nested-loop timing calculation;
- selected counter values;
- calculations for any timing-adjustment `NOP` instructions;
- modified source code showing the nested delay;
- predicted PW, PS, period, frequency, and duty cycle using $1\ \mu s/TCY$;
- expected timing using measured $T_{CY}$ from Part 1;
- oscilloscope measurements and displayed measurement resolution;
- frequency-counter measurements and displayed measurement resolution;
- code showing the added `NOP`;
- predicted timing change caused by the `NOP`;
- measurements before and after adding the `NOP`;
- measurement after removing the `NOP`;
- explanation of which measurement method provides sufficient resolution to verify a $1\ \mu s$ timing change.

Use a comparison table similar to:

| Quantity | Predicted at 1 us/TCY | Expected Using Measured TCY | Oscilloscope | Frequency Counter |
| --- | ---: | ---: | ---: | ---: |
| PW |  |  |  |  |
| PS |  |  |  |  |
| Period |  |  |  |  |
| Frequency |  |  |  |  |
| Duty cycle |  |  |  |  |

For the one-`NOP` experiment, include:

| Measurement | Before NOP | With NOP | Difference | Instrument Resolution |
| --- | ---: | ---: | ---: | ---: |
| PW |  |  |  |  |

### Demonstrate

Demonstrate the alternating `5` and `0` display and the corresponding timing signal.

Be prepared to:

- explain why nested loops are required;
- explain the timing calculation from the innermost loop outward;
- show that the nominal design is within one instruction cycle of the requested 0.5 s interval;
- measure PW using the oscilloscope;
- state the resolution of that measurement;
- explain whether the oscilloscope measurement alone can verify +/- 1 us timing accuracy;
- measure PW using the frequency counter;
- compare the two measurement methods;
- predict the effect of adding one `NOP`;
- add or remove a `NOP` when instructed;
- demonstrate whether the resulting $1\ \mu s$ timing change can be measured.

A numerical measurement is not sufficient by itself. You must be able to explain whether the instrument resolution supports the precision you claim.

### Complete When

Part 3 is complete when:

- the nested inline delay operates correctly;
- the DLG7137 alternates between `5` and `0`;
- the nominal delay has been calculated to within one instruction cycle of 0.5 s;
- PW, PS, period, and frequency have been measured;
- the resolution of the measurements has been evaluated;
- calculated timing has been compared with measurements from both instruments;
- a one-`NOP` timing change has been predicted and experimentally investigated;
- the modified source code and required evidence have been recorded;
- the instructor checkoff is complete.

---

# Part 4 - Delay Subroutines and the Hardware Stack

### Goal

Refactor the working inline delay from Part 3 into reusable subroutines.

Use `CALL` and `RETURN`, including a nested subroutine call, and verify how the new program structure affects execution timing and the hardware return stack.

### Before Lab

Review the subroutine, Program Counter, and hardware stack concepts covered in theory.

Modify the Part 3 program so it contains:

- a main program that alternates the DLG7137 between `5` and `0`;
- a reusable long-delay subroutine;
- a shorter delay subroutine called from within the long-delay subroutine;
- appropriate `CALL` and `RETURN` instructions.

Create an updated flowchart showing the subroutine calls and return paths.

Recalculate the timing of the program.

Include the execution time of:

- `CALL`;
- `RETURN`;
- delay-loop instructions;
- counter initialization;
- display changes;
- branches;
- any timing-adjustment `NOP` instructions.

Use:

$$
T_{CY}=1\ \mu s
$$

for the initial prediction.

The nominal design should continue to produce:

$$
PW=PS=0.500000\ s
$$

to within one instruction cycle.

### In the Lab

#### 1. Implement the subroutines

Build and program the refactored code.

Verify that the DLG7137 continuously alternates:

```text
5
0
5
0
...
```

#### 2. Verify the timing

Measure:

- PW;
- PS;
- period;
- frequency;
- duty cycle.

Use the oscilloscope and frequency counter.

Compare the measurements with:

- the nominal prediction using $1\ \mu s/TCY$;
- the expected timing using measured $T_{CY}$ from Part 1.

Explain any timing difference between the Part 3 inline implementation and the Part 4 subroutine implementation.

#### 3. Trace the nested calls

Using the actual source code, trace one complete sequence:

```text
Main
  -> CALL long delay
      -> CALL short delay
      <- RETURN
  <- RETURN
Main continues
```

Identify:

- where each `CALL` transfers execution;
- what return address must be stored;
- the order in which return addresses are placed on the hardware stack;
- the order in which `RETURN` uses those addresses;
- where execution resumes after each `RETURN`.

### Evidence

Include or reference:

- Part 3 source and calculations;
- updated flowchart;
- modified source showing the subroutines;
- updated timing calculation including `CALL` and `RETURN`;
- trace of the nested calls and return addresses;
- predicted timing using $1\ \mu s/TCY$;
- expected timing using measured $T_{CY}$;
- oscilloscope measurements;
- frequency-counter measurements;
- comparison with the Part 3 timing.

Previous unchanged documentation may be referenced rather than recreated.

### Demonstrate

Demonstrate the working subroutine-based program.

Be prepared to:

- identify each subroutine;
- explain what `CALL` and `RETURN` do;
- trace the nested calls through the Program Counter and hardware return stack;
- state the stack depth of the PIC16F883;
- explain what happens if the available stack depth is exceeded;
- show where `CALL` and `RETURN` appear in the timing calculation;
- compare the timing of the inline and subroutine implementations;
- verify the resulting timing with the oscilloscope and frequency counter.

The instructor may point to a `CALL` in the source and ask where execution resumes after the corresponding `RETURN`.

### Complete When

Part 4 is complete when:

- the delay operates using nested subroutine calls;
- the timing has been recalculated and measured;
- `CALL` and `RETURN` timing is accounted for;
- the nested return sequence can be traced correctly;
- the modified source, flowchart, calculations, and measurement evidence are complete;
- the instructor checkoff is complete.

---

# Part 5 - Mastery: Compare Assembly and C Timing

### Goal

Recreate the Lab 02 PORTB counter in C, verify that it performs the same hardware function as the assembly version, and compare the measured RB0 timing of the two implementations.

Do not assume that C will be faster or slower. Measure the result, inspect the instructions generated by XC8, and explain the timing from the code that actually executes on the PIC16F883.

### Before Lab

Create a new PIC16F883 C project using [Starting an XC8 C Project](../HowTo/XC8-C-Project-Setup.md).

Use the same hardware, 4 MHz oscillator, PORTB connections, and configuration-bit choices used for the assembly counter.

Record the exact:

- MPLAB X version;
- XC8 compiler version;
- optimization level or other build settings that may affect generated code.

Do not add a software delay.

Use this as the starting application code:

```c
#include <xc.h>

void main(void)
{
    ANSEL = 0x00;
    ANSELH = 0x00;

    PORTB = 0x00;
    TRISB = 0x00;

    while (1)
    {
        PORTB++;
    }
}
```

Use the MPLAB X Configuration Bits window to generate the required C configuration statements for the actual lab hardware.

Before programming the PIC, explain what each setup statement does and predict the PORTB output sequence.

### In the Lab

#### 1. Verify the C counter

Build and program the C project.

Verify that PORTB continuously counts in binary in the same functional manner as the Lab 02 assembly counter.

Measure RB0 with the oscilloscope and record:

- HIGH pulse width (PW);
- LOW pulse width (PS);
- period;
- frequency;
- duty cycle.

Measure frequency with the frequency counter as well.

Use the same measurement point and, as closely as practical, the same instrument settings used for the assembly measurement.

#### 2. Compare C with assembly

Compare the C measurements with the assembly measurements from Lab 02 and Part 1.

| Quantity | Assembly | C | Difference |
| --- | ---: | ---: | ---: |
| PW |  |  |  |
| PS |  |  |  |
| Period |  |  |  |
| Frequency |  |  |  |
| Duty cycle |  |  |  |

State whether the two programs produce the same observable PORTB counting behavior and whether they produce the same RB0 timing.

#### 3. Inspect the compiler-generated instructions

Use the MPLAB X listing, disassembly, or other compiler-generated output to determine which PIC instructions execute repeatedly for:

```c
PORTB++;
```

and the surrounding `while (1)` loop.

Record the repeating instruction sequence that controls RB0 timing.

For that path:

1. identify each instruction;
2. determine its instruction-cycle count;
3. determine the number of instruction cycles between RB0 transitions;
4. calculate expected PW, PS, period, and frequency using the measured $T_{CY}$ from Part 1;
5. compare the calculation with the measured C waveform.

Do not assume that one line of C corresponds to one machine instruction.

#### 4. Explain the result

If the C and assembly timing are different, identify the specific generated instructions or build choices that account for the difference.

If the timing is the same or nearly the same, explain why the compiler-generated execution path produces the same timing as the hand-written assembly version.

Base the explanation on generated instructions and measured data, not a general statement such as "C is slower" or "assembly is faster."

Consider whether the result was affected by:

- the instruction sequence generated by XC8;
- branch timing;
- compiler optimization;
- compiler version;
- debug versus production build configuration;
- initialization code versus the repeating steady-state loop;
- measurement uncertainty or instrument resolution.

### Evidence

Include or reference:

- the Lab 02 assembly counter source;
- the C project and `main.c`;
- configuration-bit choices;
- MPLAB X and XC8 versions;
- compiler optimization/build settings;
- oscilloscope capture of the C RB0 waveform;
- C PW, PS, period, frequency, and duty-cycle measurements;
- frequency-counter measurement;
- the assembly-versus-C comparison table;
- the compiler-generated repeating instruction sequence;
- instruction-cycle analysis of the generated C loop;
- calculated C timing using measured $T_{CY}$;
- explanation of why the C timing does or does not differ from the assembly timing.

### Demonstrate

Demonstrate the C PORTB counter and RB0 waveform.

Be prepared to:

- explain the PORTB setup statements;
- explain what `PORTB++` does;
- show that the C and assembly programs perform the same intended hardware function;
- measure RB0 PW, PS, period, frequency, and duty cycle;
- show the compiler-generated instructions for the repeating C loop;
- trace the instructions executed between RB0 transitions;
- calculate the expected timing from those instructions;
- explain any timing difference using measured evidence.

The instructor may change the compiler optimization setting and ask you to rebuild, inspect the generated instructions again, and predict whether the timing should change before measuring it.

### Complete When

Part 5 is complete when:

- the XC8 C project operates correctly;
- PORTB continuously counts in binary;
- RB0 timing has been measured;
- the C measurements have been compared with the assembly measurements;
- the compiler-generated repeating instruction sequence has been identified;
- expected timing has been calculated from the generated instructions and measured $T_{CY}$;
- any timing difference has been explained from evidence rather than assumption;
- the required source, measurements, calculations, and comparison are documented;
- the instructor checkoff is complete.
