<a id="top"></a>

# RCET 3375 Lab 09 - EEPROM

[RCET3375 course home](https://github.com/rosstimo/RCET3375) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

PIC16F883 | pic-as | Data EEPROM | Nonvolatile Storage | Embedded Applications

## Contents

- [Purpose](#purpose)
- [Standards and references](#references)
- [Equipment and materials](#equipment)
- [Part 1 - EEPROM Persistence Proof of Life](#part-1)
- [Part 2 - Reusable EEPROM Read/Write Routines and Timed Selection](#part-2)
- [Part 3 - Four-Digit Electronic Lock](#part-3)
- [Part 4 - Authenticated PIN Change](#part-4)
- [Part 5 - Mastery: EEPROM Servo Calibration](#part-5)
- [Submission and checkoff](#submission)

<a id="purpose"></a>
## Purpose

Investigate the PIC16F883 data EEPROM: read and write stored data, verify retention across power cycles, measure operation timing, and apply reliable nonvolatile storage in embedded systems.

**Repository setup:** Create one Git repository for Lab 09. Add the [student lab `.gitignore` template](https://github.com/rosstimo/RCET3375/blob/main/HowTo/Student-Lab-Repository.gitignore) before staging project files. Keep the complete development projects and follow the [Lab Standard's repository rules](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md#assignment-repository-standard).

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="references"></a>
## Standards and references

- [RCET 3375 Lab Standard](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md): lab-book, SFR, circuit, measurement, and submission requirements.
- [RCET PIC-AS Style Guide](https://github.com/rosstimo/RCET3375/blob/main/Notes/RCET_PIC-AS_Style_Guide.md) and [PIC-AS project setup](https://github.com/rosstimo/RCET3375/blob/main/HowTo/PIC-AS-Project-Setup.md).
- [PIC16F882/883/884/886/887 Data Sheet (DS40001291H)](https://ww1.microchip.com/downloads/en/DeviceDoc/40001291H.pdf):
  - [Section 10.1, pages 113–115](https://ww1.microchip.com/downloads/en/DeviceDoc/40001291H.pdf#page=114): EEPROM read/write operations and control registers.
  - [Section 10.3.1, page 119](https://ww1.microchip.com/downloads/en/DeviceDoc/40001291H.pdf#page=119): endurance and refresh.
  - [Section 17.5, page 246](https://ww1.microchip.com/downloads/en/DeviceDoc/40001291H.pdf#page=246): EEPROM endurance, retention, and write-time specifications.
- [DLG7137 display data sheet](https://www.mouser.com/catalog/specsheets/00034177_0.pdf): display pinout and timing.
- [Lab 02 - PIC I/O](https://github.com/rosstimo/RCET3375/blob/main/LabAssignments/Lab02-PIC.md): previously developed display and input interfaces.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="equipment"></a>
## Equipment and materials

- PIC16F883 circuit with 4 MHz crystal and suitable power supply
- PICkit 3 or equivalent, MPLAB X, and pic-as
- DLG7137 single-character display
- oscilloscope, logic analyzer, frequency counter, and digital multimeter as needed
- lab book, breadboard, and various components as needed

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-1"></a>
## Part 1 - EEPROM Persistence Proof of Life

### Goal

Select `A` or `B` in RAM, deliberately save it to data EEPROM address `0x00`, and continuously display the stored EEPROM value. Measure read/write timing and verify retention after a power cycle.

### Required program behavior

- **Buttons:** Use two active-LOW buttons with internal weak pull-ups: the **Select button** (RB0) and **Write button** (RB1). Debounce both pressing and releasing each button in software.
- **Normal display:** When the **Write button is released**, continuously read EEPROM address `0x00` in the main loop and display the stored `A`, `B`, or `?` for any other value.
- **Choose a value:** While the **Write button is held**, display the pending RAM selection, initially `A`. Each valid **Select button press** toggles the selection between `A` and `B`. Pressing the **Select button** while the **Write button is released** leaves the selection unchanged.
- **Save a value:** A valid **Write button press** enters selection mode. On its **debounced release**, save the pending RAM value to EEPROM **once**, wait for the EEPROM operation to finish, and resume displaying the stored value.
- **Write discipline:** An EEPROM write may start **only after a complete, debounced Write button press-and-release cycle**. Do not write at startup, during normal main-loop reading, when the Select button is pressed, or repeatedly while the Write button is held. Contact bounce on either button must not produce an extra write.
- **Timing diagnostics:** RA1 is HIGH only during each EEPROM read, and RA2 is HIGH only during the EEPROM write operation, including the wait for completion. Keep both LOW otherwise. Exclude display-update time from the read diagnostic and preserve the uninterrupted EEPROM write-unlock sequence.

### Before Lab

Prepare or reference:

- the PIC16F883 EEPROM SFR maps and read/write procedure, including the protected write sequence, write-complete indication, and interrupt precautions ([data sheet, Section 10.1](https://ww1.microchip.com/downloads/en/DeviceDoc/40001291H.pdf#page=114));
- the circuit schematic and electrical-loading checks for both buttons, display, and diagnostics;
- flowcharts for the main loop, Select button handling, Write button handling, software debouncing, EEPROM read/write, and display update;
- predicted display and diagnostic behavior for unrecognized EEPROM data, selection without saving, saving on Write button release, contact bounce, and power cycling.

**EEPROM durability:** From [Section 17.5](https://ww1.microchip.com/downloads/en/DeviceDoc/40001291H.pdf#page=246), document the minimum and typical byte endurance for both temperature ranges (D120/D120A), typical and maximum write time (D122), characteristic data retention (D123), and total EEPROM writes before refresh (D124). Explain endurance, retention, and refresh using [Section 10.3.1](https://ww1.microchip.com/downloads/en/DeviceDoc/40001291H.pdf#page=119).

**Endurance calculation:** Suppose a programming error repeatedly writes **the same EEPROM address**, starting another write as soon as the previous one finishes. Estimate the time to consume the minimum specified byte-endurance budget using the typical and maximum write times for **both temperature ranges**.

The calculation is:

```math
T_{\mathrm{budget}} = N_{\mathrm{writes}}\,t_{\mathrm{write}}
```

**Worked example (−40°C to +85°C, typical write time):**

Multiply the minimum byte endurance by the typical time per write to find the elapsed time, then convert seconds to minutes.

```math
\begin{aligned}
T_{\mathrm{budget}}
&=100{,}000\ \mathrm{writes}\times 5\ \frac{\mathrm{ms}}{\mathrm{write}}\\
&=500{,}000\ \mathrm{ms}\\
&=\frac{500{,}000}{1000}\ \mathrm{s}\\
&=500\ \mathrm{s}\\
&=8\ \mathrm{min}\ 20\ \mathrm{s}
\end{aligned}
```

**Complete the remaining three combinations** using the maximum write time and the extended-temperature endurance value. Show all substitutions, arithmetic, conversions, and units. State which software overhead you ignored, and explain why the endurance specification is a planning limit rather than an exact failure point.

**A mistaken EEPROM write inside the main loop could use up the specified endurance budget in minutes and permanently damage that address. Verify that your code cannot write repeatedly before leaving it running. Do not perform a destructive endurance test.**

### In the Lab

1. Build the two-button and DLG7137 circuit with RA1 and RA2 available for oscilloscope measurements.
2. Connect all four oscilloscope channels:

   | Channel | Signal |
   | --- | --- |
   | **CH1** | Select button |
   | **CH2** | Write button |
   | **CH3** | EEPROM read diagnostic (RA1) |
   | **CH4** | EEPROM write diagnostic (RA2) |

3. Verify continuous EEPROM reading with the **Write button released**. Press and hold the **Write button** to display the RAM selection, then use the **Select button** to toggle between `A` and `B`. Confirm that **CH4 stays LOW** throughout selection.
4. **Trigger on both falling and rising edges of the Select button (CH1)**. Verify that its press and release do not produce an EEPROM write, whether or not the Write button is held.
5. **Trigger on both falling and rising edges of the Write button (CH2)**. Verify that the falling edge (press) starts selection mode **without writing**, and that only a valid debounced rising edge (release) leads to **one CH4 write pulse**. Include sufficient post-trigger time for software debouncing and EEPROM programming.
6. Record labeled four-channel captures showing these edge-trigger tests, including continuous CH3 activity, contact bounce, and the CH4 response. Use sufficient pre-trigger time to show selection before the Write button release; use a separate expanded acquisition to measure the short read pulses when needed.
7. Measure and label **both EEPROM read and write pulse widths** in the scope captures. Compare write duration against the data sheet and account for diagnostic/software overhead.
8. Test long holds, repeated Select button presses, and physical press/release bounce. Verify that each complete Write button press-and-release produces exactly one write and the Select button alone cannot write.
9. Save `A`, remove all power, and restore it without touching either button or reprogramming. Verify the stored character appears. Repeat for `B`.
10. Inspect the EEPROM registers and write-complete indication in the debugger. Make oscilloscope timing measurements during uninterrupted program execution.

### Evidence

Include the schematic and calculations, EEPROM SFR documentation, flowcharts, final source, datasheet endurance/retention/refresh specifications, and the complete endurance calculations.

Provide **labeled oscilloscope captures with measured read and write durations**. Document **both edges of both buttons**, identifying which triggers produce no write and which produces exactly one write following debouncing. Show the continuous read activity, any observed contact bounce, and the before/after power-cycle results for both stored values.

### Demonstrate

Using the oscilloscope, **trigger on the rising and falling edges of the Select button and the Write button**. For each edge, explain what the firmware does and point out the write diagnostic: **only the debounced release of the Write button starts a write**. Show the stored-value display update, read/write timing measurements, and retention after a full power cycle. Explain how a continuous write bug could permanently wear out EEPROM.

### Complete When

The display reflects EEPROM in normal operation, the Select button changes RAM only while the Write button is held, and one write occurs on a valid Write button release. Read and write durations are measured and documented, all four button-edge tests pass, and both stored values survive complete power removal.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-2"></a>
## Part 2 - Reusable EEPROM Read/Write Routines and Timed Selection

### Goal

Extend Part 1 with reusable EEPROM routines, a non-blocking write, and a separate verification routine. Replace hold-to-select with a timed selection mode.

### I/O assignments

| Pin | Direction | Function |
| --- | --- | --- |
| **RA0** | Output | Selection-mode LED, HIGH during selection |
| **RA1** | Output | Main-loop diagnostic pulse, once per iteration |
| **RA2** | Output | EEPROM error LED, HIGH when `EEPROM_ERROR` is set |
| **RB0** | Input | Select button, active LOW with internal pull-up |
| **RB1** | Input | Write button, active LOW with internal pull-up |

Keep the DLG7137 connections on PORTC from Part 1.

### EEPROM routines

Use three RAM general-purpose registers (GPRs):

| GPR | Purpose |
| --- | --- |
| `ee_address` | EEPROM byte address for read or write |
| `ee_data` | Byte returned by a read or written during a write |
| `ee_status` | `EEPROM_READ`, `EEPROM_WRITE`, and `EEPROM_ERROR` status flags |

Define the three status flag bit positions with `EQU`.

The EEPROM subroutines must use only these three RAM GPRs and work without modification in other programs. The calling application may use additional RAM GPRs.

You may choose whether to use polling or the EEPROM write-complete interrupt to determine when a write finishes. If using the interrupt, the ISR should call `EEPROMVerifyWrite` once per completed write. You may use internal helper subroutines for EEPROM read/write, but call them only from the EEPROM routines and document the maximum stack depth.

Use these routine labels for external calls:

- **`EEPROMRead:`** Load `ee_address` before the call. Set the `EEPROM_READ` status flag on entry, place the EEPROM byte in `ee_data`, and clear the `EEPROM_READ` status flag before returning.
- **`EEPROMWrite:`** Load `ee_address` and `ee_data` before the call. If `EEPROM_WRITE` or `EEIF` is set, return immediately without changing `ee_status`. Otherwise, compare the stored byte at `ee_address` with the requested value in `ee_data` without overwriting `ee_data`. If the values match, return without writing. Preserve any existing `EEPROM_ERROR` status flag. Otherwise, set the `EEPROM_WRITE` status flag, start the protected write sequence, and return without waiting for the write to finish. Keep the unlock sequence uninterrupted and follow the interrupt precautions from Part 1. Before returning, restore `GIE` to its previous state, enabling interrupts only if they were enabled on entry. You may use a bit in `ee_status` to save the previous `GIE` state; clear that bit after restoring `GIE`.
- **`EEPROMVerifyWrite:`** Call after the hardware write finishes. Compare the byte at `ee_address` with the expected value still in `ee_data`. Do not overwrite `ee_data` during the comparison. If they match, clear `ee_status`. If they differ, clear the `EEPROM_WRITE` status flag and set the `EEPROM_ERROR` status flag. Clear `EEIF` and `WREN` before returning.

Neither `EEPROMWrite` nor `EEPROMVerifyWrite` should automatically retry a write on failure.


### Button service

- Service the Select and Write buttons by polling or interrupts. Keep the Part 1 button debouncing and accept one action per press.

- **Do not** start another EEPROM operation or change `ee_address` or `ee_data` while a write is awaiting verification.

- **Ignore** button events while either the `EEPROM_READ` or `EEPROM_WRITE` status flags are set. The `EEPROM_ERROR` status flag does not block the buttons.


### Timed selection

- **Normal operation:** RA0 is OFF. Display the character stored at EEPROM address `0x00`.
- **First Select button (RB0) press:** Enter selection mode, select `A`, display `A`, turn RA0 ON, and start an approximately one-second timeout.
- **Additional Select button presses:** Toggle the pending value between `A` and `B`, update the display, and restart the one-second timeout.
- **Timeout:** About one second after the last Select button press, exit selection mode, turn RA0 OFF, and resume the EEPROM stored-value display. A timeout **does not** start an EEPROM write.
- **Write button (RB1):** A debounced press before the timeout exits selection mode, stops the selection timer, turns RA0 OFF, and calls `EEPROMWrite` to save the pending character to address `0x00`. Ignore Write button presses outside selection mode.

**Optional address-testing tip:** In the application, define `current_address` with `EQU` as a RAM GPR and initialize it to `0x00`. Use its value when loading `ee_address` for display reads and saved writes. Changing this one value makes it easier to test other EEPROM addresses. This is optional and is not part of the reusable EEPROM routines.

### Main-loop behavior

Repeat these steps in `MainLoop`:

1. **Pulse RA1:** Set and immediately clear the main-loop diagnostic pin.
2. **Check write completion:** If polling, check `EEIF` while the `EEPROM_WRITE` status flag is set and call `EEPROMVerifyWrite` when the write finishes. If using the EEPROM write-complete interrupt, the ISR calls `EEPROMVerifyWrite` instead.
3. **Update RA2:** Set the error LED to match the `EEPROM_ERROR` status flag on every iteration.
4. **Service timeout, then buttons:** Check the selection timeout before accepting button presses. Poll the buttons or process button events supplied by interrupts.
5. **Update the DLG7137 display:** Show the pending character while in selection mode. Otherwise, read EEPROM address `0x00` and display `A`, `B`, or `?` for any other stored value. While the `EEPROM_WRITE` status flag is set, keep displaying the last character without reading EEPROM.
6. Repeat.

### Before Lab

Document the three GPR assignments, status flag bit positions, inputs and outputs of each EEPROM routine, and how `GIE` is saved and restored during the protected write sequence. Prepare a state diagram for selection, timeout, writing, verification, and errors. Include the one-second timing plan and an address/value test table.

Document the RA0 and RA2 LED connections and loading, and the RA1 diagnostic pin. Explain why EEPROM reads do not consume write endurance and why checking for an unchanged value reduces wear.

### In the Lab

1. Refactor the Part 1 EEPROM code into the three named routines. Test several byte values at different EEPROM addresses and check them again after removing and restoring power.
2. Check the `EEPROM_READ` status flag on entry to and exit from `EEPROMRead`. Confirm the returned byte is in `ee_data`.
3. Confirm `EEPROMWrite` returns with the `EEPROM_WRITE` status flag set before hardware programming finishes. Use RA1 on the oscilloscope to show main continuing to run during the write.
4. Handle `EEIF` and call `EEPROMVerifyWrite` once per completed write. Confirm that successful verification clears `ee_status`. Test that buttons are ignored while the `EEPROM_READ` or `EEPROM_WRITE` status flag is set.
5. Test verification failure by deliberately programming a different byte from the expected value retained in `ee_data`. Confirm that `EEPROM_ERROR` is set and the RA2 LED turns on. Restore the code, make a successful changed-value write, and confirm the error clears. **Do not try to cause an actual EEPROM failure or run an endurance test.**
6. Try saving the value already stored. Confirm no EEPROM write starts and any previous `EEPROM_ERROR` status flag remains unchanged.
7. Measure the selection timeout. Check that the first Select press shows `A`, later presses toggle `A`/`B` and restart the timer, and timeout exits without writing. Confirm that Write is ignored outside selection mode, but exits selection mode immediately when accepted. Verify that the selection timer does not affect a pending write and that `EEPROM_ERROR` alone does not block the buttons.
8. Capture RA1 during normal operation and an EEPROM write. Check that RA2 follows the `EEPROM_ERROR` status flag on every main-loop iteration.

### Evidence

Include the final source code, flowcharts for `EEPROMRead`, `EEPROMWrite`, and `EEPROMVerifyWrite`, the schematic and loading calculations, selection state diagram, and address/value test results, including power-cycle checks.

Provide labeled oscilloscope captures of the selection timeout and RA1 pulses during EEPROM programming. Record debugger observations of `WR`, `EEIF`, and `ee_status` for a completed write, a skipped unchanged-value write, and a controlled verification failure followed by recovery.

### Demonstrate

Demonstrate timed selection, including toggling, timeout, and saving a value. Use the oscilloscope to show that main continues running during EEPROM programming.

Use the debugger to show that an unchanged value does not start another write. Demonstrate a verification failure, the RA2 error indication, and recovery following a successful write. Explain how `ee_status`, `ee_address`, and `ee_data` are used during writing and verification.

### Complete When

All three EEPROM routines work as specified; main continues running during writes; verification and error indication work without retries; timed selection, button restrictions, and the required measurements pass.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-3"></a>
## Part 3 - Four-Digit Electronic Lock

### Goal

Extend Part 2 into a keypad-controlled electronic lock. Enter a four-digit PIN followed by `#` to activate a simulated solenoid output for one second. The PIN is read from data EEPROM.

**Safety:** Do not connect a solenoid directly to a PIC output. A real inductive load requires an appropriate driver and transient protection. Keep the simulated output inactive during reset and startup as well as normal locked operation.

### Initial PIN setup

Before running Part 3, manually program a four-digit PIN into **four consecutive data EEPROM addresses**, with one decimal digit (0–9) in each address. Choose the addresses and verify the stored digits. This is a one-time setup. PIN changes are not part of Part 3, and the PIN must not appear anywhere in the program source.

### Reuse from previous labs

Use `EEPROMRead` from Part 2 without changing its interface. PIN entry and display handling belong to the application, not the EEPROM routines.

Bring back the keypad scanner and DLG7137 display from Lab 02. A PIN-entry routine can work much like `ParseRx` from the UART lab: recognize one key-press event at a time, collect digits in RAM, and track how many digits have been entered.

### Keypad behavior

| Key | Action |
| --- | --- |
| `0`–`9` | Add one digit to the PIN entry in RAM |
| `*` | Cancel the entry and clear the collected digits |
| `#` | Submit the entry for comparison with the stored PIN |
| `A`–`D` | No PIN-entry action |

- Accept one digit per debounced physical key press, not one per keypad scan.
- Accept **exactly four digits followed by `#`**.
- A `#` press with fewer than four digits rejects and clears the entry. Reject an entry if a fifth digit is pressed; do not accept its first four digits as a valid PIN.
- After a correct entry, drive the simulated solenoid output HIGH for approximately one second, then LOW. An incorrect or incomplete entry must not activate it.
- Clear the collected entry after `#`, after `*`, and after reset. A user can then begin another attempt.
- Provide useful one-character progress/status feedback on the DLG7137 display. Choose the characters and document their meanings in the lab book.

### Stored PIN and startup

Use `EEPROMRead` to retrieve the four stored PIN digits.

On startup or reset, keep the solenoid output OFF until the correct PIN is entered.

### Keypress feedback

Use an **active buzzer** that produces its own tone when powered. Sound the buzzer for **100–250 ms** on every debounced press of any of the **16 keypad keys**. This is button-press feedback only; it does not indicate whether the PIN is correct or incorrect.

### Before Lab

Prepare or reference the keypad scanner, display wiring, and debouncing from Lab 02, including electrical precautions for simultaneous key presses. Document the buzzer and simulated-solenoid output wiring, loading calculations, and reset-safe output behavior.

Draw a state diagram covering startup, locked operation, PIN entry, cancel, comparison, and the one-second output. Prepare flowcharts for keypad entry and PIN comparison, including `*`, `#`, incorrect-length entries, and a fifth digit. Document how `EEPROMRead` is used to retrieve the stored PIN.

### In the Lab

1. Bring the keypad and display into the project. Verify that each debounced press produces one key event.
2. Verify that the lock reads the PIN already stored in EEPROM and that the PIN digits do not appear in the source code.
3. Enter a correct PIN and confirm that the solenoid output activates **only after `#`**. Measure its one-second HIGH pulse.
4. Test an incorrect PIN, `#` after fewer than four digits, a fifth digit, and `*` during entry. None may unlock. Verify that a new entry works after each rejected or canceled attempt.
5. Verify the buzzer responds to all 16 keys. Measure its 100–250 ms pulse and confirm the same feedback occurs for correct and incorrect PIN entries.
6. Power-cycle the PIC and confirm that the solenoid output stays inactive until the saved PIN is entered again.

### Evidence

Include the schematic and loading calculations, keypad-entry and comparison flowcharts, state diagram, final code, and a table of the PIN-entry tests. Show that the PIN is read from EEPROM and is not hard-coded in the program.

Provide labeled measurements of the buzzer pulse and one-second solenoid-output pulse. Record the power-cycle test results.

### Demonstrate

Enter a correct PIN followed by `#` and show the one-second output on the oscilloscope. Demonstrate an incorrect PIN, incomplete entry, fifth digit, and `*` cancellation without unlocking. Demonstrate the same button-press beep on all 16 keys, then power-cycle the PIC and unlock again using the saved PIN.

### Complete When

The lock accepts exactly four digits followed by `#`, `*` cancels entry, and the PIN is read from EEPROM without appearing in the program source. The simulated solenoid activates for one second only after a correct PIN is submitted. All 16 keys produce a 100–250 ms beep regardless of PIN verification, and reset leaves the lock inactive.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-4"></a>
## Part 4 - Authenticated PIN Change

### Goal

Extend the Part 3 lock so the user can set a PIN on first use and change it with the keypad. Store the PIN and its validity in EEPROM.

### PIN storage and startup

Use **five consecutive EEPROM addresses**: four for the PIN digits (0–9) and one for a validity marker. Choose and document the addresses.

- Marker = `0xC4`: the stored PIN is valid.
- Any other marker value: the PIN is invalid.

Before the first Part 4 run, use the programmer to set the marker to an invalid value, such as `0xFF`.

### Service modes

At startup, the stored PIN-valid marker determines whether the lock begins in invalid PIN mode or normal locked mode.

The keypad must be serviced in all modes and must not be blocked for more than 20 ms, except during the one-second solenoid activation and when a new PIN is written to EEPROM. The buzzer must sound for 100–250 ms on every debounced key press in all modes. Holding a key must produce only one key press; another press is accepted only after the key is released and pressed again.

Each PIN entry accepts only digits `0`–`9`, followed by `#` after exactly four digits. Use the DLG7137 to show whether the current or new PIN is being requested and whether saving succeeds or fails. Choose and document the display characters.

#### Invalid PIN mode

The solenoid never activates in invalid PIN mode.

1. Enter a new four-digit PIN followed by `#`.
2. Enter the same four digits followed by `#`.

Matching entries are saved as the new PIN. After a successful save, the lock enters normal locked mode. A mismatch, incomplete entry, unexpected key, or `*` clears the entry and restarts invalid PIN mode without saving.

#### Normal locked mode

1. Enter the current four-digit PIN followed by `#` to unlock.
2. To change the PIN, press `C` followed by `#`.

A correct PIN activates the simulated solenoid for approximately one second. The lock remains in normal locked mode. An incorrect or incomplete entry, unexpected key, or `*` clears the entry and restarts normal locked mode. If `C` is not the first key or is not followed by `#`, return to normal locked mode.

#### PIN change mode

The solenoid never activates in PIN change mode.

1. Enter the current four-digit PIN followed by `#`.
2. Enter a new four-digit PIN followed by `#`.
3. Enter the new PIN again followed by `#`.

If the current PIN is correct and the two new entries match, save the new PIN and return to normal locked mode. An incorrect current PIN, mismatched new PINs, incomplete entry, unexpected key, or `*` cancels the change and returns to normal locked mode with the old PIN unchanged.

While saving a new PIN, the lock ignores keypad input and keeps the solenoid OFF. EEPROM write failures use the PIN-error behavior described below.

### Reusable PIN-matching routines

Consider two application subroutines. Both can use indirect addressing with `FSR` and `INDF` for PIN digits held in RAM.

- **`CurrentPINMatch:`** Collect the keypad sequence `dddd#`, where each `d` is a digit from `0` to `9`. Consider four consecutive GPR locations with a pointer or index. Store each digit and advance the pointer. The fifth key press must be `#`; do not store it or advance the pointer. `*` or any unexpected key aborts. After `#`, use `EEPROMRead` to compare the four entered digits with the stored PIN. Report whether they match. Use this routine for normal unlocking and for authenticating a PIN change; the calling code decides whether to activate the solenoid.
- **`NewPINMatch:`** Collect the keypad sequence `dddd#dddd#`. Consider eight consecutive GPR locations, four for each new PIN entry. Store each digit from `0` to `9` and advance the pointer. The fifth and tenth key presses must be `#`; do not store them or advance the pointer. `*` or any unexpected key aborts. After the final `#`, compare the two groups of four digits in RAM and report whether they match. This routine does not write EEPROM.

Shared helper routines may be useful. Use RAM GPRs as needed to track key entry,  state, pointer or index values, match flags, and other working data. Document the GPR assignments and how each routine uses them in the lab book.

### EEPROM PIN write sequence (`PINWrite:`)

Create an application subroutine named **`PINWrite:`** to manage the six EEPROM write steps below. Use the Part 2 `EEPROMWrite` and `EEPROMVerifyWrite` routines without changing their interfaces.

Start `PINWrite` only after `NewPINMatch` succeeds and, for a change in normal locked mode, `CurrentPINMatch` has authenticated the current PIN. Set a RAM `PIN_UPDATE` flag before the first write. While it is set, keep the solenoid OFF and suspend normal lock operation. `PINWrite` handles EEPROM write completion and verification.

| Step | EEPROM location | Value to write |
| --- | --- | --- |
| 1 | PIN-valid marker | `0x00` (invalid) |
| 2 | PIN digit 1 | First new digit |
| 3 | PIN digit 2 | Second new digit |
| 4 | PIN digit 3 | Third new digit |
| 5 | PIN digit 4 | Fourth new digit |
| 6 | PIN-valid marker | `0xC4` (valid) |

**Complete and verify each step before starting the next.** Check `EEPROM_ERROR` after verification. `EEPROMWrite` may skip a byte that already contains the requested value; confirm that the byte is correct before advancing.

During `PINWrite`, intentionally block all other CPU work. Wait for each EEPROM write to finish, verify it, and continue to the next step. Do not resume normal operation until the sequence completes or stops with an error.

- **Success:** After step 6 is verified, clear `PIN_UPDATE` and return to normal locked operation with the new PIN.
- **Write or verification error:** Stop the sequence. Do not write any remaining bytes. Keep the solenoid OFF, activate a PIN-error indicator on an available PORTA output, and display an error character. Do not accept another PIN attempt until power is cycled.
- **Power interruption:** On the next startup, check the marker normally. If it is invalid, require two matching PIN entries before trying `PINWrite` again.

### Before Lab

Update the Part 3 state diagram to show invalid PIN mode, normal locked mode, PIN change mode, `PINWrite`, success, and error handling. Include the `CurrentPINMatch` and `NewPINMatch` flows. Draw a flowchart for `PINWrite` showing all six EEPROM steps and the verification/error decisions. Document the five EEPROM addresses, `PIN_UPDATE`, display characters, and the PORTA error indicator with its loading calculation.

### In the Lab

1. Program an invalid PIN marker. Verify that first-run setup requires two matching PIN entries. Test `*`, incomplete entries, mismatched confirmation, and long key holds without EEPROM writes or repeated key presses.
2. Complete setup, reset the PIC, and unlock using the stored PIN. Measure the keypad servicing interval during normal operation and verify that it does not exceed 20 ms.
3. Verify that `C` alone does not enter PIN change mode. Press `C` followed by `#` and test an incorrect current PIN, cancellation, and mismatched new-PIN confirmation. Verify that the stored PIN remains unchanged.
4. Change the PIN successfully. Use the debugger to confirm the six `PINWrite` steps occur in order, with each step verified before the next. Confirm the old PIN fails and the new PIN works after a power cycle.
5. While `PIN_UPDATE` is set, verify that keypad presses cannot unlock or cancel the EEPROM PIN write sequence.
6. Interrupt the sequence after the marker becomes invalid. Power-cycle and verify that first-run setup is required. Simulate a verification error and demonstrate the PORTA and display error indicators, inactive solenoid, and required power cycle before another attempt.

### Evidence

Include the three-mode state diagram, PIN-matching and `PINWrite` flowcharts, five-address EEPROM map, final source, and test results. Provide oscilloscope captures of keypad scanning during normal operation, during the one-second solenoid activation, and during EEPROM PIN writing. Label the normal keypad servicing interval and the time scanning is blocked in each case. Document the power-cycle, cancellation, incorrect PIN, confirmation, held-key, and error tests.

### Demonstrate

Demonstrate all three service modes and their keypad functions: first-run PIN setup, correct and incorrect PIN entries, new PIN confirmation and mismatch, `*` cancellation, and `C` followed by `#` to enter PIN change mode. Show that incomplete or unexpected entries are rejected, holding a key produces only one press, and all 16 keys produce buzzer feedback. Demonstrate normal unlocking, a successful PIN change, and operation after a power cycle.

Show that canceled or rejected entries do not write EEPROM. Demonstrate an interrupted PIN write returning to invalid PIN mode and the error indicators after a failed verification. Use the oscilloscope to show normal keypad scanning and measure how long scanning stops during solenoid activation and EEPROM PIN writing.

### Complete When

The EEPROM PIN-valid marker selects normal locked mode or invalid PIN mode. Invalid PIN mode requires two matching new PIN entries. Normal locked mode accepts the stored PIN, and PIN change mode requires the current PIN followed by two matching new PIN entries. `PINWrite` follows the six-step EEPROM sequence, verifies each step, and blocks lock operations while writing. A failed write stops the sequence and keeps the solenoid OFF until reset. A valid saved PIN survives power removal.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-5"></a>
## Part 5 - Mastery: EEPROM Servo Calibration

> **Under revision:** This part is still being edited. Refresh the page and check with the instructor before continuing.

Extend your **Lab 08 Part 4 PIC firmware and GUI** using the EEPROM routines from this lab. Keep the ID, ADC/LM34, communication, logging, and 20 ms servo timing.

### Requirements

- Store each servo's **minimum, maximum, and startup pulse widths** in EEPROM as three 16-bit values in microseconds. Document the EEPROM address map. Valid ranges are **minimum: 250–750 µs**, **maximum: 2250–2500 µs**, and **startup: minimum–maximum**, inclusive.
- On reset, load and validate the EEPROM settings. Start at the saved startup pulse width. If the settings are invalid, keep that servo output LOW until valid settings are written and the PIC is reset.
- Accept servo commands only within the saved limits. Keep the last accepted pulse width when rejecting a command. The host sends the same absolute CCP match values as Lab 08; the PIC uses the stored pulse-width limits for validation.
- Extend the GUI to read and update each servo's three calibration values. Map its 0°–180° slider to the active minimum–maximum pulse widths. Do not send Lab 08's automatic centered servo command when connecting. Saved calibration changes take effect after reset.
- Keep EEPROM writes nonblocking. Complete and verify each write before reusing the EEPROM address/data registers for another operation.

### UART packets

Keep the Lab 08 packet framing. Add the servo channel byte, even when using only one servo. Use channel `01` for the required servo; the eight-servo version uses channels `01`–`08`.

```text
Servo command (S):   24 53 03 CH MATCH_H MATCH_L      (no reply if valid)
Calibration update:  24 50 04 CH SETTING PW_H PW_L    (no reply if valid)
Calibration read:    24 43 01 CH
Calibration reply:   24 43 07 CH MIN_H MIN_L MAX_H MAX_L START_H START_L
EEPROM read:         24 52 01 ADDR                   -> 24 52 02 ADDR DATA
EEPROM write:        24 57 02 ADDR DATA              (no reply on success)
EEPROM write error:  24 45 02 04 ADDR
Invalid servo:       24 45 02 03 CH
Invalid calibration: 24 45 03 05 CH SETTING
```

`SETTING` is `00` for minimum, `01` for maximum, and `02` for startup. Pulse widths in calibration packets are 16-bit microsecond values, high byte first. The calibration read reply returns all three **stored** values for the requested channel. Reject minimum/maximum values outside their ranges; accept a startup update only when it falls between the stored minimum and maximum. A complete, valid set is required at reset before the servo output is enabled.

`R` and `W` work with **any data EEPROM byte address** (`00`–`FF`). Direct `W` writes the supplied byte without checking its value or any calibration limits. Both EEPROM write commands still verify the completed write; a failed byte sends the same write-error packet with its EEPROM address. Successful writes have no reply. Preserve the existing Lab 08 ID, ADC, and receive-error packets.

### Verify

Demonstrate EEPROM reads/writes at multiple addresses, calibration updates and full readback for a servo channel, saved calibration after a power cycle, startup pulse width, servo limit rejection, and a controlled write-verification error. Capture the UART packets and servo timing. Submit the updated PIC/GUI source, EEPROM map, and test evidence.

**Extra credit:** One servo completes Mastery (**+5 percentage points**). Implement all **eight 2.5 ms servo time slots** from Lab 08 Part 5, with independent channel commands and EEPROM settings, for **double Mastery credit (+10 percentage points total)**.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="submission"></a>
## Submission and Checkoff

Create a GitHub repository for this assignment and push the complete work before instructor checkoff. Use the [Lab Standard](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md) for the lab-book and submission rules.

Submit Parts 1–4 and any attempted Mastery work, the PIC source and native project, editable schematic and export, flowcharts, SFR documentation, measurements, and the readable lab-book PDF. Verify that a fresh clone contains what is needed to rebuild your project.

Instructor checkoff covers the working circuit and explanations listed in each required part.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)
