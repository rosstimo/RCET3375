# RCET 3375 How-To Resources

These guides contain procedures and setup information that apply across multiple labs and projects. Lab assignments should link here instead of repeating the same instructions.

## PIC-AS project work

- [Starting a PIC-AS Project](PIC-AS-Project-Setup.md) - MPLAB X, `pic-as`, PICkit 3, include files versus separate source modules, `GLOBAL`/`EXTRN`, project structure, configuration bits, PSECT placement, build/program checks, and Git/GitHub workflow.
- [PIC16F883 Computed GOTO and PCLATH](../Notes/PIC16F883-Computed-GOTO-and-PCLATH.md) - program-counter addressing, computed tables, `CALL`/`GOTO` paging, cross-module calls, `PAGESEL`, and `fcall`.
- [PIC16F883 4 MHz Crystal Oscillator](PIC16F883-4MHz-Crystal-Oscillator.md) - crystal connection, oscillator mode, load-capacitor selection, schematic requirements, and verification.
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md) - required source formatting, naming, file layout, banking, and PSECT conventions.

## Course-wide standards

- [RCET 3375 Lab Standard](../LAB_STANDARD.md) - one repository per assignment, repository structure, lab-book expectations, SFR documentation, loading calculations, evidence, demonstrations, and mastery structure.

When a later assignment says to create a new PIC-AS project, begin with these resources unless that assignment explicitly overrides something.
