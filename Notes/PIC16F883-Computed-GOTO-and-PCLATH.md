# PIC16F883 Computed GOTO and PCLATH

This note explains why `PCLATH` exists, when it matters, and why interrupt-context discussions should not introduce it before computed program-counter changes are understood.

The PIC16F883 data sheet is the device-specific authority. Microchip Application Note AN556, *Implementing a Table Read*, provides additional worked examples for the classic PIC16 mid-range architecture.

## Start with the Program Counter

The PIC16F883 executes instructions from program memory using the Program Counter (PC).

The architectural PC is wider than the directly accessible `PCL` register:

- `PCL` contains the low 8 bits of the PC and is readable/writable.
- The high PC bits are not directly writable.
- `PCLATH` is a holding register used to supply high PC bits in specific situations.

The important point is that **`PCLATH` is not the Program Counter**. It is a latch that contributes high address bits when certain operations change the PC.

See PIC16F883 data sheet Section 2.3.1, *Modifying PCL*.

## Ordinary sequential execution

During ordinary sequential execution, the PC simply advances to the next instruction. Code that stays in a simple loop does not need to manipulate `PCLATH` merely because the PC exists.

That is why introducing `PCLATH` during a first interrupt exercise can create more confusion than understanding. Students first need to see an operation where the high PC bits actually matter.

## CALL and GOTO

A `CALL` or `GOTO` instruction does not contain the complete PIC16F883 program-memory address.

The PIC16F883 Program Counter is 13 bits wide. For `CALL` and `GOTO`:

- the instruction supplies the low 11 destination bits;
- `PCLATH<4:3>` supplies the upper program-counter bits.

This makes the directly encoded destination a **2K-word program-memory page**. If the target is on another page, the appropriate `PCLATH` page bits must be selected before the `CALL` or `GOTO`.

This is a different use of `PCLATH` from a computed `GOTO`. A write to `PCL` uses `PCLATH<4:0>`, while `CALL` and `GOTO` use only `PCLATH<4:3>`.

For PIC Assembler code, use the assembler-supported page-selection mechanism rather than hand-maintaining the page bits:

```assembly
    PAGESEL SomeRoutine
    call    SomeRoutine
    PAGESEL $
```

`PAGESEL SomeRoutine` generates the instructions needed to select the page containing the target. After `return`, execution resumes at the correct caller address because the hardware stack stores the complete return PC. However, `PCLATH` is not restored by the stack. `PAGESEL # PIC16F883 Computed GOTO and PCLATH

This note explains why `PCLATH` exists, when it matters, and why interrupt-context discussions should not introduce it before computed program-counter changes are understood.

The PIC16F883 data sheet is the device-specific authority. Microchip Application Note AN556, *Implementing a Table Read*, provides additional worked examples for the classic PIC16 mid-range architecture.

## Start with the Program Counter

The PIC16F883 executes instructions from program memory using the Program Counter (PC).

The architectural PC is wider than the directly accessible `PCL` register:

- `PCL` contains the low 8 bits of the PC and is readable/writable.
- The high PC bits are not directly writable.
- `PCLATH` is a holding register used to supply high PC bits in specific situations.

The important point is that **`PCLATH` is not the Program Counter**. It is a latch that contributes high address bits when certain operations change the PC.

See PIC16F883 data sheet Section 2.3.1, *Modifying PCL*.

## Ordinary sequential execution

During ordinary sequential execution, the PC simply advances to the next instruction. Code that stays in a simple loop does not need to manipulate `PCLATH` merely because the PC exists.

That is why introducing `PCLATH` during a first interrupt exercise can create more confusion than understanding. Students first need to see an operation where the high PC bits actually matter.

 selects the page containing the caller again so later `CALL` and `GOTO` instructions have the expected page state.

Microchip's PIC Assembler User's Guide for Embedded Engineers, Section 5.2, **Psect Concatenation and Paging**, shows this exact `PAGESEL target` / `call target` / `PAGESEL # PIC16F883 Computed GOTO and PCLATH

This note explains why `PCLATH` exists, when it matters, and why interrupt-context discussions should not introduce it before computed program-counter changes are understood.

The PIC16F883 data sheet is the device-specific authority. Microchip Application Note AN556, *Implementing a Table Read*, provides additional worked examples for the classic PIC16 mid-range architecture.

## Start with the Program Counter

The PIC16F883 executes instructions from program memory using the Program Counter (PC).

The architectural PC is wider than the directly accessible `PCL` register:

- `PCL` contains the low 8 bits of the PC and is readable/writable.
- The high PC bits are not directly writable.
- `PCLATH` is a holding register used to supply high PC bits in specific situations.

The important point is that **`PCLATH` is not the Program Counter**. It is a latch that contributes high address bits when certain operations change the PC.

See PIC16F883 data sheet Section 2.3.1, *Modifying PCL*.

## Ordinary sequential execution

During ordinary sequential execution, the PC simply advances to the next instruction. Code that stays in a simple loop does not need to manipulate `PCLATH` merely because the PC exists.

That is why introducing `PCLATH` during a first interrupt exercise can create more confusion than understanding. Students first need to see an operation where the high PC bits actually matter.

 pattern.

### Calls to routines in separate source modules

A separate `.S` source module is assembled independently and then placed by the linker. The caller should therefore not assume that a routine defined in another module will land on the same program-memory page.

For example:

```assembly
; main.S
EXTRN   ConvertValue

    PAGESEL ConvertValue
    call    ConvertValue
    PAGESEL $
```

```assembly
; conversion.S
GLOBAL  ConvertValue

ConvertValue:
    ; routine body
    return
```

The source-file organization, `GLOBAL`/`EXTRN` interface, and difference between include files and separate source modules are covered in [Starting a PIC-AS Project](../HowTo/PIC-AS-Project-Setup.md). This topic owns only the program-counter and paging behavior.

### `fcall` as the page-independent alternative

PIC Assembler also provides the `fcall` pseudo-instruction:

```assembly
    fcall   SomeRoutine
```

On baseline and mid-range PIC devices, `fcall` expands to a normal `call` plus whatever page-selection instructions are required for the final linked address. It also restores the previous page selection as needed.

Microchip recommends `fcall` where practical because it makes the source less dependent on final routine placement. In this course, the explicit `PAGESEL` / `call` / `PAGESEL # PIC16F883 Computed GOTO and PCLATH

This note explains why `PCLATH` exists, when it matters, and why interrupt-context discussions should not introduce it before computed program-counter changes are understood.

The PIC16F883 data sheet is the device-specific authority. Microchip Application Note AN556, *Implementing a Table Read*, provides additional worked examples for the classic PIC16 mid-range architecture.

## Start with the Program Counter

The PIC16F883 executes instructions from program memory using the Program Counter (PC).

The architectural PC is wider than the directly accessible `PCL` register:

- `PCL` contains the low 8 bits of the PC and is readable/writable.
- The high PC bits are not directly writable.
- `PCLATH` is a holding register used to supply high PC bits in specific situations.

The important point is that **`PCLATH` is not the Program Counter**. It is a latch that contributes high address bits when certain operations change the PC.

See PIC16F883 data sheet Section 2.3.1, *Modifying PCL*.

## Ordinary sequential execution

During ordinary sequential execution, the PC simply advances to the next instruction. Code that stays in a simple loop does not need to manipulate `PCLATH` merely because the PC exists.

That is why introducing `PCLATH` during a first interrupt exercise can create more confusion than understanding. Students first need to see an operation where the high PC bits actually matter.

 form is useful when learning the hardware mechanism; `fcall` is the cleaner choice once that mechanism is understood.

See MPLAB XC8 PIC Assembler User's Guide, Section 4.1.7, **Long Jumps and Calls**.

The important lesson is that a normal `CALL` or `GOTO` is **not** the same mechanism as writing to `PCL`.

## What makes a computed GOTO different

A computed `GOTO` changes the PC by writing a calculated value to `PCL`.

A common table-read pattern is:

```assembly
Table:
    ADDWF   PCL,F
    RETLW   'A'
    RETLW   'B'
    RETLW   'C'
```

If `W = 0`, execution reaches the first `RETLW`.
If `W = 1`, the write to `PCL` skips to the second `RETLW`.
If `W = 2`, it skips to the third.

This is called a computed `GOTO` because the destination is calculated at run time rather than encoded as a fixed `GOTO` target.

When an instruction writes to `PCL`, the high PC bits are loaded from `PCLATH`. That is where `PCLATH` becomes essential.

## Problem 1: the table is not in the expected 256-word block

Suppose the table is located in program memory where the high PC bits are not zero, but `PCLATH` still contains zero.

The low eight bits calculated by `ADDWF PCL,F` may be correct, while the high bits loaded from `PCLATH` are wrong. Execution can jump to the same low-byte address in the wrong part of program memory.

A computed table therefore needs the appropriate high address loaded into `PCLATH` before writing to `PCL`.

A typical pattern is conceptually:

```assembly
    MOVLW   HIGH Table
    MOVWF   PCLATH
    MOVF    index,W
    CALL    Table

Table:
    ADDWF   PCL,F
    RETLW   'A'
    RETLW   'B'
    RETLW   'C'
```

The exact placement of the table still matters, which leads to the next problem.

## Problem 2: crossing a 0xFF to 0x00 PCL boundary

`ADDWF PCL,F` performs an 8-bit addition to `PCL`. Imagine a table begins near the end of a 256-word block.

For example, assume the first table instruction is near an address whose low byte is `0xFE`:

```text
...FE    ADDWF PCL,F
...FF    RETLW value0
...00    RETLW value1   <- next 256-word block
...01    RETLW value2
```

An offset that should move execution across the `0xFF -> 0x00` boundary changes the low byte, but the carry does not automatically increment the high address held in `PCLATH`.

The result can be a branch into the wrong 256-word block.

This is why the PIC16F883 data sheet warns about computed tables crossing a PCL boundary and refers to AN556.

## Safe design approaches

For simple tables, the easiest approaches are:

1. place the complete computed-`GOTO` table so it cannot cross a 256-word PCL boundary; and
2. preload `PCLATH` with the table's high address before the computed jump.

For a table that must cross a boundary, the software must account for the carry into the high PC bits. AN556 shows a full 13-bit computed-`GOTO` method for this case.

## PCLATH and the hardware stack

The PIC16F883 hardware stack stores return PC addresses for `CALL`s and interrupts.

`RETURN`, `RETLW`, and `RETFIE` restore the PC from that hardware stack. `PCLATH` itself is not pushed or popped with the return address.

This distinction matters:

- **hardware stack:** stores return addresses;
- **PCLATH:** supplies high address bits when certain instructions change the PC;
- **data RAM:** stores software variables and any software-saved processor context.

These are separate mechanisms.

## Why the data sheet mentions PCLATH in the interrupt context example

PIC16F883 data sheet Section 14.4 states that the device normally does not require `PCLATH` to be saved during an interrupt. It adds a specific exception: if computed `GOTO`s are used in both the ISR and main code, `PCLATH` must be preserved.

That warning makes sense only after the computed-`GOTO` mechanism is understood:

1. main code may load `PCLATH` for its table;
2. an interrupt occurs;
3. the ISR changes `PCLATH` for a different computed table;
4. the ISR returns without restoring it;
5. main later writes to `PCL` expecting its original high address;
6. execution can jump to the wrong location.

For ordinary ISR code that does not modify `PCLATH` in this way, introducing extra PCLATH save/restore work adds complexity without helping the first interrupt lesson.

## References

- Microchip, *PIC16F882/883/884/886/887 Data Sheet*, DS40001291H: https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf
  - Section 2.3, PCL and PCLATH
  - Section 2.3.1, Modifying PCL
  - Section 2.3.2, Stack
  - Section 14.4, Context Saving During Interrupts
- Microchip, *PIC Assembler User's Guide for Embedded Engineers*, Section 5, **Multiple Source Files, Paging and Linear Memory Example**: https://onlinedocs.microchip.com/oxy/GUID-205B1F42-0E06-45E1-8D34-E3D05C15710F-en-US-3/GUID-79324E62-113F-4297-9BD9-D06E9565D522.html
- Microchip, same guide, Section 5.2, **Psect Concatenation and Paging**: https://onlinedocs.microchip.com/oxy/GUID-205B1F42-0E06-45E1-8D34-E3D05C15710F-en-US-3/GUID-5F31E8EE-6965-42C0-AFAC-9139CCA1B76C.html
- Microchip, *MPLAB XC8 PIC Assembler User's Guide*, Section 4.1.7, **Long Jumps and Calls** (`fcall`, `ljmp`): https://onlinedocs.microchip.com/oxy/GUID-4DC87671-9D8E-428A-ADFE-98D694F9F089-en-US-7/GUID-9057119A-E61B-4AEF-9FDE-14C5D8A15398.html
- Microchip, *PICmicro Mid-Range MCU Family Reference Manual*, DS33023A: https://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf
  - Section 6.2.4.1, Computed GOTO
  - Section 6.2.5, Stack
- Microchip AN556, *Implementing a Table Read*, DS00556E: https://ww1.microchip.com/downloads/en/AppNotes/00556e.pdf
