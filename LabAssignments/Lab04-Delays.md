# Delays (Software Timing, Cycle Math, and Verification)
---
## Equipment / Materials
- MPLAB X IDE + pic-as toolchain
- Programmer/debugger (PICkit or equivalent)
- Oscilloscope
- Frequency counter
- Logic analyzer (Optional)
- Breadboard
- Lab notebook
- Reference: [PIC16F883 datasheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf)
- Reference: [PICmicro Mid-Range MCU Family Reference Manual](https://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf)
- 
- Reference: DLG7137 datasheet

### Parts List (example)
|Part                |Qty       | |Part                   |Qty       |
|--------------------|----------|-|-----------------------|----------|
|PIC16F883           |1         | |DLG7137 Display        |1         |
|Capacitors          |as needed | |4Mhz Crystal Oscillator|1         |

---

## Core Objectives (All Parts)
By the end of this experiment, you will be able to:
1. Create real-time delays using instruction loops (software delay).
2. Predict delay time using instruction timing math (cycle-accurate method).
3. Measure real delay time using a hardware instrument (scope/LA/counter).
4. Convert inline delay code into a reusable subroutine.
5. Explain how CALL/RETURN use the Program Counter (PC) and the stack.

---

## Background / Theory
Microcontroller systems often need real-time timing control (example: traffic lights).
There are two common delay methods:
- **Hardware delay**: load a timer/counter peripheral and wait for it to expire (efficient CPU use).
- **Software delay**: execute a loop that wastes time (inefficient CPU use, but simple and common).

This experiment focuses on **software delay** using:
- **Simple Inline Delays**: use NOP instruction to waste time.
- **Simple loop**: fine time resolution, shorter maximum delay (limited by an 8-bit counter).
- **Nested loops**: longer delay times, coarser increments.
- **Nested + fine loop (+ optional NOPs)**: longer delays with fine trimming.



### Instruction timing model (Family Manual Section 5.4)
You must compute time using:
- Oscillator frequency ($F_{OSC}$)
- Instruction cycle time ($T_{CY}$)

For midrange PIC devices, a useful starting model is:
- $T_{OSC} = 1 / F_{OSC}$ (oscillator period or Q state)
- $T_{CY} = 4 * T_{OSC}$  (instruction cycle time)
- Most instructions take 1 instruction cycle, but some take 2, and “skip” instructions behave differently.

You will verify timing by toggling a pin around the code you want to time.

---

# Part 1 – Timing Measurement Method and Calculation Process

## Part 1 Objectives
- Measure the device clock (or a derived timing reference).
- Compute $T_{CY}$ and use it to predict simple inline delays.
- Measure and verify predicted vs actual delay times.
- Demonstrate the ability to accurately predict and measure PIC assembly instruction timing.
- Demonstrate the ability to write simple PIC assembly code to achieve  specific and predictable timing accurate to within one instruction cycle.

## Theory of Operation / Procedure

1. Determine the oscillator frequency used by the program (document how you determined it).
2. Convert that to $T_{CY}$.
3. Write a simple pic-as program that toggles a RB0 pin continuously.
   ```assembly
    MainLoop:
        MOVLW 0x01      ; 1 TCY 
        XORWF PORTB,1   ; 1 TCY
        GOTO  MainLoop  ; 2 TCY
   ```
   1. Predict the pulse width time on RB0 in microseconds.
   2. Measure the pulse width on RB0 using an oscilloscope.
   3. Compare the predicted and measured times.
4. Next add a NOP instruction to your main loop.
   1. Predict the new pulse width time.
   2. Measure the new pulse width on RB0.
   3. Compare the predicted and measured times.
5. Next calculate the number of instruction cycles needed to produce a 50kHz square wave on RB0.
   1. Modify your program adding NOP instructions to produce the 50kHz frequency.
   2. Measure and verify the frequency on RB0.
   3. Be sure the duty cycle is 50%.

## Calculations
- Show all your calculations:
  - Oscillator frequency used
  - Instruction cycle time ($T_{CY}$)
  - Predicted pulse width without NOP
  - Predicted pulse width with one NOP
  - Number of NOPs needed to achieve 50kHz square wave

## Measurements
- Screenshot showing the pulse width on RB0 without NOP.
- Screenshot showing the pulse width on RB0 with one NOP.
- Screenshot showing the 50kHz square wave on RB0.
- Record measured time and your calculated time.

## Figures / Tables
- Include:
  - Schematic (your measurement pin wiring)
  - Flowchart (must appear immediately before the program listing)
  - Code listing
  - Oscilloscope screenshots for each measurement

## Summary / Analysis
- Explain any discrepancies (example: measurement error, oscilloscope probe loading, etc).
- Explain how you determined the oscillator frequency used by your program.
- What is the relationship between oscillator frequency and instruction cycle time?
- Explain how you calculated $T_{CY}$ from the oscillator frequency.
- Explain how you calculated the number of NOPs needed to achieve 50kHz.


---

# Part 2 – Inline Delays Using Loops

## Part 2 Objectives
- Write an inline delay using a loop to create a 50µs delay.
- Write an inline delay using a nested loop to create a 0.5 s delay.
- Use **inline delay loops only** do not use timer peripherals, interrupts, or subroutines.
- Achieve timing accuracy to **±1 µs**
- measure and verify the timing accuracy using an oscilloscope and frequency counter. 
- Describe when and why you would use an oscilloscope vs a frequency counter for timing measurements. 
- Describe measurement errors. Specifically how sample rate and resolution affect accuracy of timing measurements. 
- Verify that you can achieve the timing measurement accuracy within ±1 µs. 

## Theory of Operation / Procedure
1. Write a pic-as program that includes a delay loop to create a delay of 50µs. 
2. Use the delay loop to alternately toggle RB0 every 50µs. Producing a 10kHz square wave on RB0.
3. Measure and verify the timing accuracy of your 10kHz square wave on RB0 using an oscilloscope and frequency counter.
4. Demonstrate for your instructor that your timing accuracy is within ±1 µs.
5. Next, write a pic-as program that includes nested delay loops to create a delay of 0.5 seconds. 
6. Then expand that program to alternately display “5” and “0” on the DLG7137 display with approximately 0.5 second intervals using only inline delay loops.
7. Measure and verify the timing accuracy of your 0.5 second intervals using an oscilloscope and frequency counter.
8. Demonstrate for your instructor that your timing accuracy is within ±1 µs.
9. Describe when and why you would use an oscilloscope vs a frequency counter for timing measurements.
10. Describe measurement errors. Specifically how sample rate and resolution affect accuracy of timing measurements.

## Calculations
Delay loop code example:
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
### Example calculation for DelayLoop with $count=9$:
Work from inside to outside.
1. First calculate the instruction cycles in DelayLoop time:
   - DelayLoop: $count(1 + 2) - 1$
2. Then add the delay overhead instructions:
   - Total Delay = $count(1 + 2) - 1 + 1 + 1$ 
3. Simplify:
   - Total Delay = $3(count) + 1$ instruction cycles
   - For $count = 9$   
     - Total Delay = $3(9) + 1 = 28$ instruction cycles
     - Total Delay = $28$ instruction cycles
4. Finally convert to time:
   - Total Delay $= 28 * T_{CY}$
   - At 4 MHz: $T_{OSC} = 250ns,  T_{CY} = 1 µs$
   - Total Delay Time: $28 * 1 µs = 28 µs$
5. The `DECFSZ` instruction decrements first then tests the bit. 
   - Max loop $count=0$ means 256 iterations
     - Calculate the maximum delay time:
       - Total Delay = $3(256) + 1 = 769$ instruction cycles
       - Total Delay Time = $769 * T_{CY} = 769 µs$ at 4 MHz
   - Min loop $count=1$ means 1 iteration
     - Calculate the minimum delay time:
       - Total Delay = $3(1) + 1 = 4$ instruction cycles
       - Total Delay Time = $4 * T_{CY} = 4 µs$ at 4 MHz
   - Since Total Delay = $3·count + 1$, increasing count by 1 increases delay by 3 instruction cycles. 
      - So:
        - Cycles per count = 3
        - Time per count = $3 · T_{CY}$
        - Time per count = $3 * 1 µs = 3 µs$ at 4 MHz
        - Delta: 3µs per increment of count
6. Account for the other instructions in MainLoop that are not part of the delay so we can accurately predict the timing of RB0.
   - $PW = (3(count) + 1) + 1 + 1 + 2$
   - Simplify:
     - $PW = 3(count) + 5$ instruction cycles

## Measurements
- Measure and verify the timing accuracy of your 10kHz square wave on RB0 using an oscilloscope and frequency counter.
- Measure and verify the timing accuracy of your 0.5 second intervals using an oscilloscope and frequency counter.
- Timing measurements for both parts must be within ±1 µs of calculated values. 
- Describe when and why you would use an oscilloscope vs a frequency counter for timing measurements. 
- Describe measurement errors. Specifically how sample rate and resolution affect accuracy of timing measurements.


## Figures / Tables
Include:
- Complete Schematic(s)
- Loading calculations
- Flowchart must appear alongside code
- Code listing
- Oscilloscope screenshots
- Images of frequency counter measurements

## Summary / Analysis
- Compare your calculated vs measured timing for both the 10kHz square wave and the 0.5 second delay.
- Explain any discrepancies (example: calculation error, measurement error, oscilloscope probe loading, sample rate resolution, etc).

## Demonstration to Instructor
You must demonstrate:
- Demonstrate your 10kHz square wave works correctly using the oscilloscope and frequency counter.
- Demonstrate your 0.5 s delay works correctly using the oscilloscope and frequency counter.
  - The display alternates 5 and 0 with 0.5 s timing.
- Be prepared to explain how your delay loop works and how you calculated timing.
---

# Part 3 – Delay Subroutine + PC/Stack Explanation

## Part 3 Objectives

* Create one subroutine for the main 0.5 second delay, and a second, shorter delay subroutine that is called from within the 0.5 second delay routine (i.e., demonstrate nested subroutine calls).
* Use CALL and RETURN to manage program flow between main and your delay subroutines.
* Measure and compare the timing accuracy of your new subroutine-based delays, as in Part 2.
* Explain, in detail:
  - How CALL and RETURN instructions interact with the Program Counter (PC) and the hardware stack.
  - How the stack pointer operates during nested subroutine calls, including what happens if the stack limit is exceeded (stack overflow).
  - Why understanding the stack’s depth and limitations is critical when using subroutines on the PIC microcontroller.

## Theory of Operation / Procedure
When a subroutine is called:
1. Explain the advantages and any disadvantages of using subroutines 
2. Describe how the CALL instruction affects the Program Counter (PC) and the stack.
3. Describe how the RETURN instruction affects the Program Counter (PC) and the stack.
4. Describe how nested subroutine calls affect the stack. 
  1. Is there a limit to how deep you can nest subroutine calls? 
  2. What happens if you exceed that limit?
5. Refactor your Part 2 code to implement the delay loops as subroutines.
  1. Create one subroutine for the main 0.5 second delay.
  2. Create a second, shorter delay subroutine that is called from within the 0.5 second delay routine (nested subroutine calls).
  3. Each delay subroutine should be reusable (i.e., can be called from multiple places in the code if needed).

## Calculations
- Update your timing math to include the overhead of CALL and RETURN instructions.
- Clearly show where the CALL/RETURN time is included in your total delay calculations.
- Predict the timing for the shorter delay subroutine within ±1 µs accuracy.
- Predict the new timing for the 0.5 second delay within ±1 µs accuracy.

## Measurements
- Scope/LA screenshots for each 0.5 s interval (5 and 0), measured again.
- Compare Part 2 vs Part 3 results.

## Figures / Tables
- Include:
  - Updated Schematic(s)
  - Updated Flowchart(s)
  - Updated Code listing(s)
  - Oscilloscope screenshots for each measurement 
  - Images of frequency counter measurements

## Summary / Analysis
- Compare your calculated vs measured timing for both the shorter delay subroutine and the 0.5 second delay subroutine.
- Explain any discrepancies (example: calculation error, measurement error, oscilloscope probe loading, sample rate resolution, etc).
- Explain how CALL and RETURN instructions interact with the Program Counter (PC) and the hardware stack.
- Explain how the stack pointer operates during nested subroutine calls.
---

## Demonstration to Instructor
You must demonstrate:
- Demonstrate your shorter delay subroutine works correctly using the oscilloscope and frequency counter.
- Demonstrate your 0.5 s delay subroutine works correctly using the oscilloscope and frequency counter.
  - The display alternates 5 and 0 with 0.5 s timing.

- Be prepared to explain:
  - how your delay loop works
  - how you calculated timing
  - what CALL/RETURN do to PC/stack in Part 3

---

