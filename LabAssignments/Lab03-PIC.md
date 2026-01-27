# **PIC16F883 I/O Familiarization**
---
## **Equipment/Materials**
- MPLAB X IDE
- Oscilloscope
- logic analyzer (Optional)
- Lab notebook
- Reference: PIC16F883 datasheet
- DLG7137 datasheet
- 4 x 4 matrix keypad datasheet

|Part                |Qty       | |Part                   |Qty       |
|--------------------|----------|-|-----------------------|----------|
|PIC16F883           |1         | |DLG7137 Display        |1         |
|DIP Switches        |1         | |4 x 4 matrix keypad    |1         |
|Resistors           |as needed | |4Mhz Crystal Oscillator|1         |
|Capacitors          |as needed | |Diodes                 |as needed |

---

## **Core Objectives (All Parts)**
1. Locate and interpret relevant information in the PIC16F883 datasheet.
2. Configure PIC digital I/O correctly (inputs and outputs) and explain the purpose of key SFR settings.
3. Represent relevant SFRs using accurate bit maps tied to observed hardware behavior.
4. Write clear, well-commented PIC-AS assembly code.
5. Create clear, easy-to-follow flowcharts that match the program logic.
6. Use an oscilloscope (or logic analyzer) to verify I/O behavior, timing, and signal integrity.
7. Perform basic current/voltage loading calculations to verify I/O operation stays within safe limits.

---

## **Background/Theory**
- Review PIC16F883 Device Overview and Memory Organization.
- Review PIC16F883 Instruction Set.
- Review PIC16F883 Electrical Specifications and Absolute Maximum Ratings.
- Review PIC16F883 digital I/O.
- Review SFRs (Special Function Registers) related to PORTB and PORTC.
- Key terms: Data Bus, Address Bus, Program Counter, Reset Vector, ISR Vector, Program Memory, Data Memory, PSECT, Compiler Directive, Mnemonic, Operand, Opcode, SFR, General Purpose Register, Matrix/Key Scanning, Debounce, Priority Encoding.

---

## **Part 1 – PORTB SFR Familiarization & Output Counter**

### **Part 1 Objectives (PORTB Output Counter)**
1. Verify toolchain + hardware by incrementing PORTB outputs continuously.
2. Capture and measure RB0 timing for one full output cycle using an oscilloscope.
3. Explain Program Counter behavior during reset, branching, and looping (as used in your program).
4. Document program memory usage using a memory table (Program Memory Location, Mnemonic, Operand, Opcode, Comments).

### Theory of Operation
- Configure all PORTB pins as digital outputs.
- Increment PORTB in a loop to verify output and toolchain.

### Calculations
- Current/voltage loading calculations for PORTB outputs.

### Measurements
- Oscilloscope capture of RB0 for one full output cycle.
- Timing of RB0 PW and PS should be clear and measurable in your scope capture.

### Results/Analysis
- Document step-by-step SFR configuration and observed hardware behavior.
  
### Figures/Tables
- Schematic of PIC16F883 external 4MHz crystal oscillator, capacitors, and power connections.
- Tables: PORTB-related SFRs and their bit maps.
- Complete code listing with comments.
- Complete flowchart of program logic.
- Memory table for assembly/machine code. (This is only for part 1)

Example:

|Program Memory Location|Mnemonic|Operand|14 bit Opcode|Comments|
|----|-----|------|--------------|------------------------------|
|0005|MOVLW|0XA3  |11000010100011|Move literal into register W|
|0006|MOVWF|0X20  |00000010100000|Move register w into register location 20|
|0007|INCF |0X20,1|00001010100001|Increment register location 20, store result back in same location|


### Demonstration
- Show continuous PORTB incrementing on your oscilloscope.
- Be prepared to explain SFR/bit settings and their effects.

---

## **Part 2 – DIP Switch Priority Display**

### **Part 2 Objectives (DIP Switch Priority + Display)**
1.  Implement priority-encoding logic in software for 8 digital inputs.
2.  Interface the display (DLG7137) using PORTC and demonstrate correct mapping/output behavior.

### Theory of Operation
- Write a program that uses 8 DIP switches connected to PORTB as digital inputs.
- Display the numerical digit corresponding PORTB bit number on the DLG7137 display (connected to PORTC).
- If no switch is pressed, display a "$" character.
- Highest-numbered switch pressed takes priority. 
- RB7 is switch 7 (highest priority), RB0 is switch 0 (lowest priority).
- Program runs in an endless loop, continuously checking PORTB inputs and updating the display.

### Calculations
- Loading calculations for all components used and all port pins connected to display and switches.

### Measurements
- Verify correct display output for all switch combinations.

### Results/Analysis
- Stable output, correct priority, no flicker or erratic behavior.
  
### Figures/Tables
- Complete code listing with comments.
- Complete flowchart of program logic.
- Complete schematic showing DIP switches on PORTB, display on PORTC.
- SFR bit map tables for PORTC configuration.

### Demonstration
- Demonstrate correct mapping and priority logic to your instructor.


---

## **Part 3 – Keypad Input Display**

### **Part 3 Objectives (Keypad Scan + Debounce)**
1.  Scan a 4x4 matrix keypad, implement debounce, and define behavior for multiple simultaneous key presses.

### Theory of Operation
- Scan keypad, display pressed key value.

### Calculations
-  Loading calculations for all port pins connected to display and keypad.

### Measurements
- Verify correct key recognition and display update.
- Verify that multiple keys pressed at the same time are handled correctly.

### Results/Analysis
- Debounce method or justification.

### Figures/Tables
- Complete code listing with comments.
- Complete flowchart of program logic.
- Complete schematic showing keypad connections to PORTB and display on PORTC.
- Bit map table for PORTB configuration.

### Demonstration
- Demonstrate working keypad input and display. 
- Be prepared to explain scanning and debounce methods.
- Explain how multiple simultaneous key presses are handled.
- Oscilloscope capture of key scanning.

---


