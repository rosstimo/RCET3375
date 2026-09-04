# Starting an XC8 C Project

Use this guide when an RCET 3375 assignment requires a PIC16F883 project written in C with MPLAB XC8.

## Official resources

- [MPLAB X IDE](https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide)
- [Create a Standalone Project in MPLAB X IDE](https://developerhelp.microchip.com/xwiki/bin/view/software-tools/ides/x/projects/creating/project/)
- [MPLAB XC8 Compiler](https://www.microchip.com/en-us/tools-resources/develop/mplab-xc-compilers/xc8)
- [MPLAB XC8 C Compiler User's Guide for PIC MCU](https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/UserGuides/MPLAB_XC8_C_Compiler_Users_Guide_for_PIC_50002737.pdf)
- [PIC16F883 Data Sheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf)
- [RCET 3375 Lab Standard](../LAB_STANDARD.md)

## 1. Create the project

In MPLAB X, create a new **Microchip Embedded -> Standalone Project**.

Select:

- Device: `PIC16F883`
- Hardware tool: the PICkit used with the assignment circuit
- Compiler: the installed MPLAB XC8 compiler

Create the complete MPLAB X project under the assignment repository in the location required by the lab standard. Do not create another Git repository inside the MPLAB X project.

Record the exact XC8 compiler version used. When execution timing is part of the assignment, also record the optimization level and any other build settings that can affect generated code.

## 2. Add a C source file

Add a C source file such as:

```text
main.c
```

Include the device definitions with:

```c
#include <xc.h>
```

The device SFR names supplied by XC8, such as `PORTB`, `TRISB`, `ANSEL`, and `ANSELH`, can then be used directly in the C source.

## 3. Configuration bits

Use the PIC16F883 data sheet and the MPLAB X Configuration Bits window to select settings for the actual assignment hardware.

Generate the C configuration source and place the required `#pragma config` statements in the project.

Do not blindly copy a configuration block from another project. Be able to explain what each selected setting controls and why it matches the circuit.

For assignments that compare C with an earlier assembly program, use the same oscillator and other hardware-relevant configuration choices unless the assignment explicitly says otherwise.

## 4. Configure digital I/O

The PIC16F883 powers up with some pins capable of analog operation. Configure the pins for the function required by the assignment before using them as ordinary digital I/O.

For a simple PORTB digital-output exercise, a starting setup is:

```c
ANSEL = 0x00;
ANSELH = 0x00;
PORTB = 0x00;
TRISB = 0x00;
```

Use the data sheet to explain what each SFR does rather than treating this block as magic boilerplate.

## 5. Build and program

1. Build the project and resolve errors and warnings.
2. Confirm the selected device, compiler, and PICkit.
3. Program the PIC16F883.
4. Verify the hardware behavior required by the assignment.
5. Commit the working project and push it to GitHub.
6. Confirm `git status` is clean.

## 6. When timing matters

One C statement does not necessarily correspond to one PIC instruction.

When an assignment asks you to explain timing:

- inspect the compiler-generated listing or disassembly;
- identify the repeating machine-instruction path;
- determine the instruction-cycle count of that path;
- calculate the expected timing;
- compare the calculation with the measured waveform.

Do not explain a timing result only by saying that C is slower or assembly is faster. Base the explanation on the instructions the compiler actually generated, the compiler/build settings, and the measurements.