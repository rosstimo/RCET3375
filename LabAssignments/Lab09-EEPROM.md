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
- [Part 5 - Mastery: Servo Calibration and Safe Start](#part-5)
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

> **Under revision:** This part is still being edited. Refresh the page and check with the instructor before continuing.

### Goal

Extend the Part 3 lock to set a PIN on first use and allow the user to change it with the keypad. Store the PIN and its validity in EEPROM.

### EEPROM PIN storage

Use five consecutive EEPROM locations: four for the decimal PIN digits and a fifth for the **PIN-valid marker**. Choose and document the addresses.

- A marker value of **`0xC4`** means the stored PIN is valid.
- **Any other value** means the PIN is invalid. The solenoid must not activate while the marker is invalid.
- Before the first Part 4 power-up, initialize the marker to a value other than `0xC4` (for example, `0xFF`) using the programmer. The four digits manually programmed for Part 3 do not count as an initialized Part 4 PIN.

On every startup or reset, read the marker first. If it is `0xC4`, start in normal locked operation using the stored PIN. Otherwise, enter **first-run PIN setup**. Keep the solenoid output OFF during setup and EEPROM updates.

### First-run PIN setup

When the PIN marker is invalid:

1. Enter a new four-digit PIN followed by `#`.
2. Enter the same PIN again followed by `#`.
3. If the entries match, save the PIN using the EEPROM update sequence below. If they differ, clear the entries and start again.

Do not start an EEPROM update for an incomplete, canceled, or mismatched entry. Discard the entered digits and remain in setup with the marker invalid. After a successful save, enter normal locked operation. If an update is interrupted after the marker becomes invalid, the next power-up returns to setup.

### Change the PIN

Keep the Part 3 lock, display, keypad debouncing, and 100–250 ms buzzer feedback on all 16 keys. Use **`C` on the keypad** to start a PIN change; no separate button is needed.

1. Press `C` during normal locked operation.
2. Enter the **current PIN** (four digits followed by `#`). An incorrect PIN exits change mode without writing EEPROM.
3. Enter a **new PIN** (four digits followed by `#`).
4. Enter the **new PIN again** (four digits followed by `#`). If the entries do not match, exit change mode without writing EEPROM.
5. With the current PIN verified and both new entries matching, run the EEPROM update sequence.

Use `*` to cancel a PIN change **before the EEPROM update starts**. In first-run setup, `*` clears the current entry but does not exit setup. Apply the Part 3 rules for incomplete entries and a fifth digit throughout. Entering the current PIN in change mode must not activate the solenoid. Once the update starts, keypad input cannot cancel or interrupt it.

Use the DLG7137 to distinguish normal entry, current-PIN entry, new PIN, confirmation, and the result of saving. Document the chosen characters.

### EEPROM update sequence

Use the three EEPROM routines from Part 2 without changing their interfaces. Do not write EEPROM for individual keypad presses. Start the update only after the required PIN entries have been verified.

Set a RAM `PIN_UPDATE` flag **before the first EEPROM write**. While it is set, ignore all keypad actions, keep the simulated solenoid OFF, and suspend normal lock operation. Continue servicing EEPROM write completion, `EEPROMVerifyWrite`, and the status display. Keep interrupts available as required by the EEPROM routines; do not disable them for the entire update.

Perform these **six EEPROM writes in order**:

1. **Invalidate:** Write a value other than `0xC4` (for example, `0x00`) to the fifth EEPROM location. Confirm that the stored marker is invalid before writing any PIN digits.
2. **Save:** Write PIN digits 1, 2, 3, and 4 to their EEPROM locations, one byte at a time, verifying each completed write.
3. **Validate:** Write `0xC4` to the marker location **last**. Verify it before clearing `PIN_UPDATE` and returning to normal locked operation.

Start each write only after the preceding one is complete and verified. Check `EEPROM_ERROR` after verification. If a write or verification fails, **stop the sequence immediately**. Do not write any remaining digits or the valid marker.

For an error after the marker has been invalidated, leave the marker invalid, keep the simulated solenoid OFF, set a **PIN-error output on an available PORTA pin**, and display an error character on the DLG7137. Stop normal operation and require a **power cycle before another PIN setup attempt**. The same error indication and power-cycle requirement apply if the initial invalidation write fails.

A power loss during the update stops the sequence. On the next startup, an invalid marker enters first-run setup, requiring two new matching PIN entries. The RAM `PIN_UPDATE` flag prevents other application actions during the approximately 30 ms update; the EEPROM marker determines whether the PIN is valid after reset. If EEPROM cannot complete a PIN update, it cannot save a new valid PIN.

**First-write failure:** If the invalidation write fails and the old marker remains `0xC4`, no PIN digits have been changed. Show the PIN error and keep the solenoid OFF until power is cycled. The next startup can use the unchanged old PIN. No additional recovery mechanism is required for this case.

### Before Lab

Update the Part 3 state diagram for startup marker checking, first-run setup, authenticated PIN change, confirmation, the `PIN_UPDATE` flag, and error handling. Prepare flowcharts showing when EEPROM writing may start, the six writes in order, and the checks between writes. Document the five EEPROM addresses, the `0xC4` marker, the selected PORTA error pin and its loading, and the display feedback.

### In the Lab

1. Initialize the fifth EEPROM location to a value other than `0xC4`. Power up and verify that the lock requires two matching PIN entries before normal operation. Check mismatched entries, incomplete entries, and `*`.
2. Complete first-run setup, reset the PIC, and verify that the saved PIN unlocks without repeating setup.
3. Press `C`, submit an incorrect current PIN, and verify that no EEPROM update or solenoid activation occurs.
4. Test cancellation and mismatched confirmation during a PIN change. Confirm that the old PIN still works.
5. Change the PIN successfully. Use the debugger to verify the marker is invalidated first, the four digits are saved next, and `0xC4` is written last. Verify the old PIN fails and the new PIN works after a power cycle.
6. While `PIN_UPDATE` is set, press keypad keys and verify they cannot unlock, cancel, or restart the update. Check that EEPROM completion and verification continue.
7. Interrupt an update after the marker has been invalidated. Power-cycle and confirm that first-run setup is required. Simulate a write-verification error after invalidation and verify that the update stops, the PORTA error output activates, the display shows an error, and the solenoid stays OFF. Verify that another setup attempt requires a power cycle.

### Evidence

Include the updated state diagram and flowcharts, EEPROM address map, final source code, and a table of startup and PIN-change test results. Show debugger evidence of `PIN_UPDATE`, the six EEPROM writes in order, and their verification. Document canceled entries before writing, blocked keypad actions during writing, successful PIN changes, power-cycle recovery after interruption, and the PORTA/display error indicators.

### Demonstrate

Program an invalid marker and show first-run setup. Set a PIN, reset, and unlock with it. Use `C` to change the PIN, including current-PIN authentication and two matching new entries. Demonstrate incorrect authentication and mismatched confirmation without EEPROM writes. Show the six-write sequence with `PIN_UPDATE` blocking keypad actions, the error indication and required power cycle after a write failure, and first-run setup after an interrupted update.

### Complete When

An invalid EEPROM marker starts first-run PIN setup; `0xC4` allows normal PIN operation. Changing the PIN requires the current PIN and matching new entries. No EEPROM update begins for incomplete or canceled PIN entries. During the six-write update, `PIN_UPDATE` prevents other lock actions. Errors stop the update and keep the solenoid inactive, with PORTA and display error indications and a required power cycle before another attempt.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-5"></a>
## Part 5 - Mastery: Servo Calibration and Safe Start

> **Under revision:** This part is still being edited. Refresh the page and check with the instructor before continuing.

**Optional Mastery:** Extend the working **single-servo** UART/CCP application from Lab 08 Part 4. Preserve its normal measurement and communication behavior while adding persistent calibration and an explicit safe startup state. This is a separate application from the electronic lock.

- Save minimum and maximum permitted pulse widths and a neutral/safe command to EEPROM. Reject invalid calibration data rather than silently using it.
- Change calibration in RAM while testing; only an explicit **Save** action commits it to EEPROM.
- On reset, load calibration but keep the actuator **disarmed** until an explicit arming action. Do not resume the previous commanded position/throttle automatically.
- Map an abstract position/throttle request to the saved pulse-width limits on the PIC. Preserve the timing of the existing 20 ms servo signal.
- Resolve the Lab 08 GUI's initial centered commands so startup commands do not accidentally arm this application.
- Demonstrate a power-cycle recovery and explain whether signal LOW, a neutral pulse, or a separate hardware enable is actually safe **for the tested controller**.

A LOW pulse line is **not** a universal motor-off guarantee. Use a simulated or otherwise safe test load, and verify the actual servo/ESC behavior before allowing motor power.

Submit the updated calibration/arming flowchart, EEPROM layout, code, evidence of saved settings, scope timing, and safe-start test results. Successful Mastery earns the lab's standard optional +5 percentage points.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="submission"></a>
## Submission and Checkoff

Create a GitHub repository for this assignment and push the complete work before instructor checkoff. Use the [Lab Standard](https://github.com/rosstimo/RCET3375/blob/main/LAB_STANDARD.md) for the lab-book and submission rules.

Suggested repository structure:

```text
RCET3375-Lab09-EEPROM/
├── README.md
├── .gitignore
├── source/
│   └── pic/
│       └── Lab09-EEPROM.X/
├── schematics/
├── documentation/
├── evidence/
│   └── oscilloscope/
└── lab-book/
    └── Lab09-Lab-Book.pdf
```

Submit Parts 1–4 and any attempted Mastery work, the PIC source and native project, editable schematic and export, flowcharts, SFR documentation, measurements, and the readable lab-book PDF. Verify that a fresh clone contains what is needed to rebuild your project.

Instructor checkoff covers the working circuit and explanations listed in each required part.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)
