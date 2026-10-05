# Starting a PIC-AS Project

Use this guide whenever an RCET 3375 assignment requires a new PIC-AS project unless the assignment explicitly says otherwise.

## Course toolchain

- MPLAB X IDE: **v6.20**
- PIC Assembler: **pic-as v3.10**
- Programmer/debugger: **PICkit 3**
- Target device for current labs: **PIC16F883**

Official resources:

- [RCET Microchip Documentation Guide](https://github.com/rosstimo/pic_projects/blob/main/References/Microchip-Documentation-Guide.md) - shared RCET index of official Microchip documentation.
- [MPLAB X IDE](https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide)
- [MPLAB ecosystem archive](https://www.microchip.com/en-us/tools-resources/archives/mplab-ecosystem)
- [MPLAB X IDE User's Guide](https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/UserGuides/MPLAB_X_IDE_Users_Guide_50002027.pdf)
- [MPLAB XC8 PIC Assembler User's Guide](https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/UserGuides/MPLAB-XC8-PIC-Assembler-Users-Guide-DS50002974.pdf)
- [PIC Assembler User's Guide for Embedded Engineers](https://ww1.microchip.com/downloads/en/DeviceDoc/50002994B.pdf)
- [PICkit 3 User's Guide](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/UserGuides/52116A.pdf)
- [PIC16F883 datasheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf)
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

## 4. Organize larger projects with include files and source modules

As a project grows, do not put every definition and every routine into one large source file. PIC Assembler supports two different ways to divide source material. They solve different problems.

### Include files are textual source

An include directive such as:

```assembly
#include <xc.inc>
#include "project-definitions.inc"
```

causes the included text to become part of the source module being preprocessed and assembled.

The included file does **not** become a separately assembled module and does not produce its own object file.

Use an include file for material that should be shared as source text, such as:

- constants and symbolic definitions;
- macros;
- shared declarations;
- small common definitions that several modules must see.

The `.inc` extension is a useful convention, but the important action is the include directive itself.

An uppercase `.S` source file is passed through the preprocessor, which is why `#include` works in the course assembly files. See the [PIC Assembler User's Guide for Embedded Engineers](https://ww1.microchip.com/downloads/en/DeviceDoc/50002994B.pdf), Section 3.3, **Include Files**.

### Separate `.S` files are separate source modules

When two `.S` files are both added to **Source Files** in the MPLAB X project, they are not pasted together.

Conceptually:

```text
main.S              helper.S
  |                    |
assembler            assembler
  |                    |
main.o              helper.o
   \                  /
          linker
            |
            v
       final program
```

Each source module is preprocessed and assembled independently. The linker combines the resulting object files.

This means each source module should contain the setup it needs to assemble on its own, normally including:

```assembly
PROCESSOR 16F883
RADIX dec

#include <xc.inc>
```

Configuration bits, reset vectors, interrupt vectors, and the main application entry point should normally have one clear owner rather than being repeated in every module.

Use a separate source module when executable code or data has its own job, such as:

- a lookup-table module;
- a numeric conversion or mapping routine;
- a reusable driver;
- a larger group of related subroutines.

Section 5, **Multiple Source Files, Paging and Linear Memory Example**, in the [PIC Assembler User's Guide for Embedded Engineers](https://ww1.microchip.com/downloads/en/DeviceDoc/50002994B.pdf) demonstrates this model with two independently assembled source files.

### Add an existing source module to MPLAB X

Copy the source file into the MPLAB X project directory, then add it under **Source Files** in the Projects window using **Add Existing Item**.

See the [MPLAB X IDE User's Guide](https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/UserGuides/MPLAB_X_IDE_Users_Guide_50002027.pdf), **Add Existing Files to a Project**.

A simple project may look like:

```text
MyProject.X/
├── main.S
├── helper.S
└── nbproject/
```

Do not use `#include "helper.S"` merely to make the routine available. That would turn the helper into pasted source instead of a separate module.

### Share symbols across modules with `GLOBAL` and `EXTRN`

A symbol defined in one source module is not automatically visible to another module.

The module that owns a routine or object exports its symbol with `GLOBAL`:

```assembly
GLOBAL  ConvertValue

ConvertValue:
    ; routine body
    return
```

The module that uses that symbol declares it with `EXTRN`:

```assembly
EXTRN   ConvertValue
```

The same mechanism can be used for shared RAM symbols when one module owns the address and another module needs to access it.

For this course, use the following convention:

- `GLOBAL` means **this module provides this symbol**;
- `EXTRN` means **this module uses a symbol provided elsewhere**.

PIC Assembler also permits `GLOBAL` to reference a global symbol defined in another module, but using `EXTRN` for imports makes the direction of ownership easier to read.

See the [MPLAB XC8 PIC Assembler User's Guide](https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/UserGuides/MPLAB-XC8-PIC-Assembler-Users-Guide-DS50002974.pdf), Section 6.1.9, **Assembler Directives**.

### Calling a routine in another module

The linker decides where separately assembled code is finally placed in program memory. On the PIC16F883, that means a routine in another source module cannot be assumed to occupy the same program-memory page as the caller.

Program-memory paging and the correct use of `PAGESEL`, `fcall`, and `PCLATH` are a separate processor-addressing topic. Read [PIC16F883 Computed GOTO and PCLATH](../Notes/PIC16F883-Computed-GOTO-and-PCLATH.md) before making cross-module calls.

The project-organization rule is simple: **separate source files create linker-visible module boundaries; include files do not.**

## 5. Configuration bits

Use the PIC16F883 datasheet and MPLAB X Configuration Bits window to determine the settings required by the actual hardware.

Generate the configuration source, then place the required `CONFIG` statements in the assembly source.

For every configuration setting used, know:

- what it controls;
- the selected value;
- why that value matches the circuit.

Do not copy a configuration block without checking it against the current hardware.

## 6. PSECT placement

A named PSECT is not automatically placed at a required device vector address.

Determine the PIC16F883 reset and interrupt vector addresses from the datasheet. Configure the PIC Assembler linker options in MPLAB X so the named vector PSECTs are linked at the correct locations.

Verify the linked addresses using generated map/listing information.

Record the custom linker options somewhere you can reuse them when creating the next project.

## 7. PICkit 3 setup

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

## 8. Build and verify

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
