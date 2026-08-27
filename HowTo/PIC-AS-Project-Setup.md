# Starting a PIC-AS Project

Use this guide whenever an RCET 3375 assignment requires a new PIC-AS project unless the assignment explicitly says otherwise.

## Course toolchain

- MPLAB X IDE: **v6.20**
- PIC Assembler: **pic-as v3.10**
- Programmer/debugger: **PICkit 3**
- Target device for current labs: **PIC16F883**

Official resources:

- MPLAB X IDE: https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide
- MPLAB archive: https://www.microchip.com/en-us/tools-resources/archives/mplab-ecosystem
- MPLAB X IDE User's Guide: https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/UserGuides/MPLAB_X_IDE_Users_Guide_50002027.pdf
- MPLAB XC8 PIC Assembler User's Guide: https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/UserGuides/MPLAB-XC8-PIC-Assembler-Users-Guide-DS50002974.pdf
- PIC Assembler User's Guide for Embedded Engineers: https://onlinedocs.microchip.com/oxy/GUID-205B1F42-0E06-45E1-8D34-E3D05C15710F-en-US-3/
- PICkit 3 User's Guide: https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/UserGuides/52116A.pdf
- PIC16F883 datasheet: https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md)
- [RCET 3375 Lab Standard](../LAB_STANDARD.md)

## 1. Create the assignment repository

Use one repository for one assignment. Follow the repository structure and Git requirements in the [RCET 3375 Lab Standard](../LAB_STANDARD.md).

Create the repository first, then place the MPLAB X project under:

```text
source/pic/
```

Do not create a second Git repository inside the MPLAB X project.

## 2. Create the MPLAB X project

Create a new standalone project and select:

- Device: `PIC16F883`
- Hardware tool: `PICkit 3`
- Toolchain: `pic-as 3.10`

Keep the complete MPLAB X project directory under `source/pic/`.

## 3. Create the assembly source

Use an uppercase `.S` source file and follow the [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md).

The starter file should contain the standard sections needed for the assignment, including:

- `PROCESSOR 16F883`
- `RADIX dec`
- `#include <xc.inc>`
- configuration-bit directives
- reset-vector PSECT
- interrupt-vector PSECT when used or required as a placeholder
- main-code PSECT
- setup code
- main loop
- subroutines as needed
- `END`

Keep a known-good starter version that can be copied into later assignment repositories.

## 4. Configuration bits

Use the PIC16F883 datasheet and MPLAB X Configuration Bits window to determine the settings required by the actual hardware.

Generate the configuration source, then place the required `CONFIG` statements in the assembly source.

For every configuration setting used, know:

- what it controls;
- the selected value;
- why that value matches the circuit.

Do not copy a configuration block without checking it against the current hardware.

## 5. PSECT placement

A named PSECT is not automatically placed at a required device vector address.

Determine the PIC16F883 reset and interrupt vector addresses from the datasheet. Configure the PIC Assembler linker options in MPLAB X so the named vector PSECTs are linked at the correct locations.

Verify the linked addresses using generated map/listing information.

Record the custom linker options somewhere you can reuse them when creating the next project.

## 6. PICkit 3 setup

Use the PICkit 3 User's Guide and PIC16F883 datasheet to identify the ICSP connections:

- MCLR/VPP
- VDD
- VSS
- PGC/ICSPCLK
- PGD/ICSPDAT

Determine how the target is powered before connecting the programmer.

In MPLAB X, verify that:

- PICkit 3 is selected for the project;
- the tool is detected;
- the target device is detected;
- the project can be programmed successfully.

## 7. Build and verify

Before adding assignment-specific code:

1. build the project without assembler or linker errors;
2. verify vector placement;
3. verify PICkit 3 communication;
4. program the target;
5. commit the known-good starter state;
6. push it to GitHub;
7. confirm `git status` is clean.

When troubleshooting a new project, first determine which area failed:

- source/build;
- linker/project configuration;
- programmer/ICSP connection;
- power/reset/oscillator hardware;
- application I/O.

Do not change several unrelated things at once.
