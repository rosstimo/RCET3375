# RCET PIC-AS Style Guide

**Course Standard for PIC-AS Assembly Projects**  
**Target device family:** PIC mid-range, with emphasis on PIC16F883 labs  
**Toolchain:** MPLAB X IDE + `pic-as`

---

## 1. Purpose

This style guide defines the **required formatting and naming conventions** for RCET PIC-AS assembly projects.

Its goals are to make code:

- easier to read,
- easier to debug,
- easier to grade,
- easier to compare against datasheets and manual examples,
- more consistent across all students and labs.

This guide separates two things:

1. **PIC-AS syntax rules** required by the assembler.
2. **RCET style rules** chosen for consistency and readability.

If the assembler allows several valid forms, this guide tells you which form to use in class.

---

## 2. Core Rule

When several choices are valid, use the form that is:

1. easiest to read,
2. easiest to recognize quickly,
3. easiest to maintain,
4. least likely to cause errors.

Do not invent a new formatting style for every project.

---

## 3. Required File Conventions

### 3.1 Source File Extension

Use:

- `.S` for assembly source files that use preprocessing
- `.inc` for include fragments or macro/header-style support files

### 3.2 Why `.S` is Preferred

Use `.S` for student projects because it supports:

- `#include`
- `#define`
- conditional compilation like `#ifdef`
- C-style comments such as `//` and `/* ... */`

Even though plain `.s` may assemble, `.S` is the standard course choice because it avoids confusion later.

### 3.3 Include File Rule

Use:

```assembly
#include <xc.inc>
```

Do **not** copy random device header files into each project unless specifically instructed.

---

## 4. Standard File Layout

Arrange each source file in this order unless the assignment requires something different.

```text
1. Header comment block
2. PROCESSOR directive
3. RADIX directive
4. Include statements
5. CONFIG statements
6. EQU definitions / constants / variables
7. Reset vector PSECT
8. ISR vector PSECT (if used)
9. Main code PSECT
10. Subroutines
11. END directive
```

### 4.1 Recommended Template

```assembly
;=====================================================
; Name:        Tim Rossiter
; Course:      RCET xxxx
; Semester:    Fall 2026
; Assignment:  Lab xx
; Device:      PIC16F883
; Toolchain:   MPLAB X + pic-as
;=====================================================

PROCESSOR 16F883
RADIX dec

#include <xc.inc>

CONFIG "FOSC = XT"
CONFIG "WDTE = OFF"
CONFIG "PWRTE = OFF"
CONFIG "MCLRE = ON"
CONFIG "LVP = OFF"

count_reg       EQU 0x20
w_temp          EQU 0x70
status_temp     EQU 0x71
pclath_temp     EQU 0x72

PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto Setup

PSECT isrVect,class=CODE,delta=2
InterruptVector:
    goto IsrHandler

PSECT code,class=CODE,delta=2

Setup:
    goto MainLoop

MainLoop:
    goto MainLoop

IsrHandler:
    retfie

END
```

---

## 5. Case and Naming Rules

This is the main RCET naming standard.

### 5.1 Mnemonics

Write instruction mnemonics in **lowercase**.

Examples:

```assembly
movlw 0x55
movwf PORTB
goto MainLoop
bcf RP0
```

Why:

- mnemonics are easier to distinguish from register names,
- lowercase instructions improve visual scanning,
- it keeps executable code visually different from assembler structure.

### 5.2 Assembler Directives

Write assembler directives in **UPPERCASE**.

Examples:

```assembly
PROCESSOR 16F883
RADIX dec
CONFIG "WDTE = OFF"
PSECT code,class=CODE,delta=2
END
```

Why:

- directives are structural, not executable,
- they should stand out from instructions.

### 5.3 Register Names and Bit Names

Use Microchip names exactly as provided by the include files.

Examples:

```assembly
PORTB
TRISB
ANSEL
ANSELH
INTCON
STATUS
OPTION_REG
```

Bit names from the include files must also be used exactly as supplied, but note an important PIC-AS detail:

```assembly
bcf     RP0
bsf     GIE
btfss   T0IF
btfsc   RB0
```

With `#include <xc.inc>` on PIC16F883-class projects, symbols like `RP0`, `GIE`, `T0IF`, and `RB0` are defined as bit-helper macros that already expand to the required register and bit position. That means this form is preferred:

```assembly
bcf     RP0
```

not this older-looking form:

```assembly
bcf     STATUS, RP0
```

If you do not use the helper macro, then use an actual bit number:

```assembly
bcf     STATUS, 5
```

Do not rename Microchip registers into personal versions like:

```text
port_b
tris_b
intCon
optionReg
```

### 5.4 Major Labels

Use **PascalCase** for major code labels.

Examples:

```assembly
Setup:
MainLoop:
CheckInputs:
UpdateDisplay:
DelayRoutine:
IsrHandler:
```

These labels usually mark:

- reset entry points,
- setup sections,
- main loop sections,
- subroutines,
- ISR entry points.

### 5.5 Local or Small Internal Labels

Use **camelCase** for smaller internal labels.

Examples:

```assembly
waitForPress:
scanNextColumn:
foundKey:
noKeyPressed:
```

These labels usually mark:

- short loop bodies,
- local branches,
- helper decision points.

### 5.6 Variables in RAM

Use **lower_snake_case** for writable variables.

Examples:

```assembly
key_code        EQU 0x20
delay_count     EQU 0x21
outer_count     EQU 0x22
note_index      EQU 0x23
```

Why:

- user variables should not look like SFR names,
- writable data should be visually distinct from constants and labels.

### 5.7 Constants and Fixed Meanings

Use **UPPER_SNAKE_CASE** for constants and symbolic values.

Examples:

```assembly
KEY_NONE        EQU 0xFF
DISPLAY_0       EQU 0x3F
DISPLAY_5       EQU 0x6D
DELAY_1KHZ      EQU 83
MAX_COUNT       EQU 255
```

Use this style for:

- fixed values,
- masks,
- symbolic states,
- lookup constants,
- compile-time settings.

### 5.8 Macros

Use **UPPER_SNAKE_CASE** for macro names.

Example:

```assembly
SAVE_CONTEXT    MACRO
    movwf   w_temp
    swapf   STATUS,w
    movwf   status_temp
    ENDM
```

### 5.9 Required Label Rule

**Every label must end with a colon.**

Correct:

```assembly
MainLoop:
```

Incorrect:

```assembly
MainLoop
```

---

## 6. Literal and Number Rules

Human beings love making numbers confusing. Do not help.

### 6.1 Required Default

Every source file must include:

```assembly
RADIX dec
```

This makes decimal the explicit default and avoids hidden assumptions.

### 6.2 Course Policy for Literal Use

Use the following rule:

- **decimal** for counts, delays, loop values, and human quantities
- **hex** for masks, register setup values, display bit patterns, and datasheet-facing constants
- **binary** only when the actual bit pattern is the important idea
- **character literals** for ASCII values

### 6.3 Approved Literal Forms

#### Decimal

```assembly
movlw 25
movlw 100
movlw 255
```

#### Hexadecimal

Preferred form:

```assembly
movlw 0x0F
movlw 0x80
movlw 0x55
```

Also valid:

```assembly
movlw 0FFh
movlw 07Fh
```

If using the `h` suffix, include a leading digit.

Correct:

```assembly
0FFh
```

Incorrect:

```assembly
FFh
```

#### Binary

```assembly
movlw 10110011B
```

Use uppercase `B`.

#### ASCII Character Literal

```assembly
movlw 'A'
movlw '0'
```

### 6.4 Literal Style Rule

For RCET work, prefer:

- decimal literals with no suffix,
- hex literals in `0x...` form,
- binary literals in `...B` form.

Do not switch styles randomly within one project.

---

## 7. Comment Rules

### 7.1 Default Comment Style

Use semicolon comments for normal assembly comments.

```assembly
; configure PORTB as digital output
; RB0 is the timing probe pin
movwf PORTB      ; update output pattern
```

### 7.2 Use Comments for Intent, Not Obvious Translation

Good comment:

```assembly
; force all PORTB pins to digital before enabling outputs
```

Weak comment:

```assembly
incf count_reg,f     ; increment count_reg
```

A comment should explain:

- **why** something is done,
- **what hardware effect** is intended,
- **what assumption** is important,
- **what trap** is being avoided.

### 7.3 Comment Levels

Use three common levels.

#### Section comments

```assembly
;-----------------------------------------------------
; Device setup
;-----------------------------------------------------
```

#### Intent comments

```assembly
; disable analog functions before using PORTA as digital I/O
```

#### Inline comments

```assembly
bcf RP0      ; return to Bank 0
```

### 7.4 C-Style Comments

If the file is preprocessed as `.S`, the following are also valid:

```assembly
// single-line comment

/* multi-line
   comment */
```

However, semicolon comments remain the preferred default for normal assembly code.

### 7.5 Do Not Use Semicolon Comments Inside Preprocessor Directives

Bad example:

```assembly
#define DELAY 25 ; wrong place for this comment
```

Use C-style comments instead if needed in preprocessor lines.

---

## 8. Whitespace and Alignment Rules

### 8.1 Indentation

Use 4 spaces for instruction lines.

Example:

```assembly
MainLoop:
    movlw   0x01
    xorwf   PORTB,f
    goto    MainLoop
```

### 8.2 Label Position

Labels begin in column 1.

Correct:

```assembly
MainLoop:
    goto MainLoop
```

Incorrect:

```assembly
    MainLoop:
    goto MainLoop
```

### 8.3 Operand Alignment

Align operands within a code block when practical.

Preferred:

```assembly
    movlw   0x01
    movwf   PORTB
    bcf     RP0
    goto    MainLoop
```

### 8.4 Blank Lines

Use blank lines to separate:

- setup sections,
- vector sections,
- main loop sections,
- subroutines,
- major logical stages.

Do not leave random blank lines everywhere.

---

## 9. Configuration Bit Rules

### 9.1 One CONFIG Per Line

Use one configuration statement per line.

```assembly
CONFIG "FOSC = XT"
CONFIG "WDTE = OFF"
CONFIG "LVP = OFF"
```

### 9.2 Keep CONFIG Block Near the Top

Place configuration bits:

- after `#include <xc.inc>`
- before variable definitions and code

### 9.3 Use Quoted Setting-Value Pairs

Use the quoted form shown in Microchip examples.

---

## 10. Banking Rules

### 10.1 Always Bank Explicitly

Before accessing banked registers or variables, use an explicit bank-selection step.

Typical form:

```assembly
    BANKSEL TRISB
    clrf    BANKMASK(TRISB)
```

### 10.2 Do Not Hide Banking Assumptions

Bad style:

```assembly
    clrf TRISB
```

if the required bank is not clearly selected just before that access.

### 10.3 Never Put `BANKSEL` Immediately After a Skip Instruction

Avoid this:

```assembly
    btfsc   PORTB,0
    BANKSEL TRISB
```

Reason:

- `BANKSEL` may expand to more than one instruction,
- skip instructions can break the intended sequence.

---

## 11. PSECT Rules

Use named PSECT blocks that make program structure obvious.

Recommended names:

```assembly
PSECT resetVect,class=CODE,delta=2
PSECT isrVect,class=CODE,delta=2
PSECT code,class=CODE,delta=2
```

### 11.1 House Rule

Use meaningful PSECT names and keep reset, ISR, and main code clearly separated.

### 11.2 Reset Vector Rule

The reset vector should contain a single obvious transfer to setup or main code.

Example:

```assembly
PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto Setup
```

### 11.3 ISR Vector Rule

If interrupts are used, the interrupt vector should clearly branch to one ISR handler entry point.

---

## 12. Subroutine Style Rules

### 12.1 Subroutine Names

Use PascalCase for subroutine entry labels.

Examples:

```assembly
Delay50us:
ScanKeypad:
UpdateDisplay:
LoadNoteValue:
```

### 12.2 Entry and Exit Rule

Each subroutine should have:

- one clear entry label,
- one obvious return path,
- comments if the routine uses special assumptions.

### 12.3 Document Inputs and Outputs

For non-trivial routines, add a short comment block.

Example:

```assembly
;-----------------------------------------------------
; Delay50us
; Input:  none
; Output: none
; Uses:   delay_count
;-----------------------------------------------------
Delay50us:
    return
```

---

## 13. ISR Style Rules

### 13.1 ISR Naming

Use:

```assembly
IsrHandler:
```

or another clear PascalCase routine name.

### 13.2 Save and Restore Context Clearly

If the ISR saves context manually, the save and restore sections must be easy to identify.

Example:

```assembly
IsrHandler:
    movwf   w_temp
    swapf   STATUS,w
    movwf   status_temp
    movf    PCLATH,w
    movwf   pclath_temp

    ; ISR body

LeaveIsr:
    movf    pclath_temp,w
    movwf   PCLATH
    swapf   status_temp,w
    movwf   STATUS
    swapf   w_temp,f
    swapf   w_temp,w
    retfie
```

### 13.3 ISR Rule

The ISR must not look like a random copy-paste blob. Group it visibly.

---

## 14. Good and Bad Examples

### 14.1 Good Example

```assembly
PROCESSOR 16F883
RADIX dec

#include <xc.inc>

CONFIG "FOSC = XT"
CONFIG "WDTE = OFF"
CONFIG "LVP = OFF"

count_reg       EQU 0x20

PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto Setup

PSECT code,class=CODE,delta=2

Setup:
    BANKSEL ANSEL
    clrf    BANKMASK(ANSEL)
    clrf    BANKMASK(ANSELH)

    BANKSEL TRISB
    clrf    BANKMASK(TRISB)

    BANKSEL PORTB
    clrf    BANKMASK(PORTB)

    goto    MainLoop

MainLoop:
    incf    count_reg,f
    movf    count_reg,w
    movwf   PORTB
    goto    MainLoop

END
```

### 14.2 Weak Example

```assembly
PROCESSOR 16F883
#include <xc.inc>
CONFIG "WDTE = OFF"
A EQU 0x20
PSECT code,class=CODE,delta=2
main:
    movlw 1
    movwf PORTB
    goto main
END
```

Problems:

- missing `RADIX dec`,
- weak symbol naming,
- label naming does not follow RCET style,
- poor structure,
- no visible setup section,
- no reset vector,
- poor readability.

---

## 15. RCET Course Checklist

Before submitting a PIC-AS assignment, verify the following.

### 15.1 Structure

- [ ] File uses `.S`
- [ ] `PROCESSOR` present if device-specific
- [ ] `RADIX dec` present
- [ ] `#include <xc.inc>` present
- [ ] CONFIG block near top
- [ ] Reset vector clearly defined
- [ ] ISR vector clearly defined if interrupts are used
- [ ] `END` directive present

### 15.2 Naming

- [ ] mnemonics are lowercase
- [ ] directives are uppercase
- [ ] Microchip register names are unchanged
- [ ] major labels use PascalCase
- [ ] local labels use camelCase
- [ ] RAM variables use lower_snake_case
- [ ] constants use UPPER_SNAKE_CASE
- [ ] every label ends with `:`

### 15.3 Readability

- [ ] indentation is consistent
- [ ] comments explain intent, not obvious translation
- [ ] sections are separated cleanly
- [ ] operands are aligned when practical
- [ ] no random formatting changes

### 15.4 Correctness

- [ ] bank selection is explicit where needed
- [ ] no `BANKSEL` placed immediately after skip instructions
- [ ] literals use a consistent style
- [ ] hex values are clearly written
- [ ] code matches schematic and lab behavior

---

## 16. Short Rationale Summary

This RCET style guide deliberately uses:

- **lowercase mnemonics** so executable instructions stand out from registers,
- **UPPERCASE directives** so assembler structure is easy to spot,
- **vendor register names unchanged** so code matches datasheets and Microchip headers,
- **PascalCase labels** for major control flow points,
- **lower_snake_case variables** for writable data,
- **UPPER_SNAKE_CASE constants** for fixed meanings,
- **`RADIX dec` always** so students do not guess what base is active.

The result is a consistent visual grammar:

- structure looks like structure,
- instructions look like instructions,
- hardware names look like hardware names,
- variables look like variables.

That is the whole point.

---

## 17. Standards Basis and Manual References

The following manual sections support the syntax decisions in this guide.

### MPLAB XC8 PIC Assembler User’s Guide

- **Section 4.2** Statement formats
- **Section 4.3** Characters
- **Section 4.4** Comments
- **Section 4.5** Constants
- **Section 4.6** Identifiers
- **Section 4.9** Assembler directives
- **Section 5.1** Preprocessor directives

### MPLAB XC8 PIC Assembler User’s Guide for Embedded Engineers

- **Section 3.1** Comments
- **Section 3.2** Configuration bits
- **Section 3.3** Include files
- **Section 3.4** Commonly used directives
- **Section 4.2** User-defined Psects for Mid-range and Baseline Devices
- **Section 4.3** Working with Data Banks
- **Section 7.1** Interrupt code (Mid-range)
- **Section 7.3** Manual context switch

### MPASM to MPLAB XC8 PIC Assembler Migration Guide

- **Section 2.1** File types
- **Section 3.1** Constants and radices
- **Section 3.2** Labels
- **Section 3.3** File register address masking
- **Section 3.4** Program flow and address masking
- **Section 4.4** `BANKSEL` directive
- **Section 4.9** `CONFIG` directive
- **Section 4.49** `PROCESSOR` directive
- **Section 4.50** `RADIX` directive

### PIC16F882/883/884/886/887 Data Sheet

Use the device datasheet for actual device behavior and register meaning, especially:

- **Section 2.0** Memory Organization
- **Section 3.0** I/O Ports
- **Section 9.0** ADC Module
- **Section 12.0** EUSART
- **Section 13.0** MSSP Module
- **Section 14.0** Special Features of the CPU
- **Section 15.0** Instruction Set Summary

### PICmicro Mid-Range MCU Family Reference Manual

Use the family reference manual for general architectural explanations and timing concepts, especially:

- **Section 4** Architecture
- **Section 5** CPU and ALU
- **Section 6** Memory Organization
- **Section 8** Interrupts
- **Section 9** I/O Ports
- **Section 29** Instruction Set

---

## 18. Final Rule

If a form is legal but ugly, confusing, inconsistent, or hard to grade, do not use it.

The assembler may tolerate chaos. This course does not.