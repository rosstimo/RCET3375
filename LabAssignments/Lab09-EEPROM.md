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

Extend the Part 3 lock to set its own PIN on first use and allow the user to change it from the keypad. Save the PIN in EEPROM so it works after a power cycle.

### First-time PIN setup

When Part 4 starts for the first time without a configured PIN, keep the simulated solenoid output OFF and require the user to:

1. Enter a new four-digit PIN followed by `#`.
2. Enter the same new PIN followed by `#` to confirm it.
3. If the entries match, save and verify the PIN in EEPROM before starting normal locked operation. If they do not match, restart the new-PIN entry.

Do not write a PIN to EEPROM until both entries match. After successful setup, a reset or power cycle must start in normal locked operation without asking for a new PIN.

### Change the PIN

Keep the Part 3 keypad rules, one-second solenoid output, display feedback, and buzzer feedback for all 16 keys. Use the keypad's **`C` key** to start a PIN change. No additional button is needed.

1. Press `C` during normal locked operation.
2. Enter the **current PIN** (four digits followed by `#`). If it is incorrect, exit change mode without modifying EEPROM or activating the solenoid.
3. Enter a **new PIN** (four digits followed by `#`).
4. Enter the **new PIN again** (four digits followed by `#`) to confirm it.
5. If the new entries match, save and verify the new PIN in EEPROM. Otherwise, exit change mode and keep the existing PIN.

Use `*` to cancel a PIN change before saving. During first-time setup, `*` clears the current entry but cannot exit setup. Apply the Part 3 rules for short entries and a fifth digit in every PIN-entry step.

The current PIN is used only to authorize the change. Entering it in change mode must not activate the solenoid. Choose one-character display feedback so the user can tell which PIN is being requested and whether saving succeeded or failed.

### EEPROM storage and recovery

Use the Part 2 EEPROM routines without changing their interfaces. Write only after two matching new-PIN entries, not after each key press. Wait for each non-blocking write to finish and be verified before starting the next byte.

Reserve an EEPROM status byte to distinguish **not yet configured**, **valid PIN**, and **interrupted or invalid update**. The four PIN digits alone cannot establish whether Part 4 has completed its first-time setup, particularly if they were manually programmed during Part 3.

When saving a PIN, mark the record as being updated before writing the four digits. Write and verify each digit, then mark the record valid **last**. The simulated solenoid must remain OFF during setup and saving.

If an update fails or is interrupted, start locked and do not accept the partial PIN. An invalid or interrupted record must not trigger first-time setup on the next reset; it requires deliberate EEPROM reinitialization with the programmer.

### Before Lab

Update the Part 3 state diagram for first-time setup, change mode, current-PIN authentication, new PIN entry, confirmation, saving, and errors. Prepare flowcharts for the new behavior and document the EEPROM storage layout and write order. Explain how the display identifies each entry step.

### In the Lab

1. Prepare the EEPROM status byte for an unused Part 4 device. Power up and verify that two matching new PIN entries are required before normal operation. Test mismatched entries and `*` cancellation during setup.
2. Finish setup, reset the PIC, and confirm that setup is skipped. Verify that the saved PIN unlocks using the Part 3 rules.
3. Press `C` and enter an incorrect current PIN. Verify that the lock remains inactive and the stored PIN does not change.
4. Test `*` cancellation and mismatched new-PIN confirmation. Verify that the original PIN still works.
5. Change the PIN successfully, then verify that the old PIN fails and the new PIN unlocks. Remove and restore power and repeat.
6. Use the debugger or programmer to test an interrupted/invalid EEPROM record. Verify that the lock remains inactive and does not enter first-time setup. Explain the EEPROM write and verification sequence.

### Evidence

Include updated flowcharts and state diagram, the EEPROM storage layout and write order, final source code, and a table of first-time setup and PIN-change tests. Document successful saving, failed authentication, cancellation, mismatched confirmation, power-cycle persistence, and invalid-record behavior.

### Demonstrate

Set a PIN on first startup, then reset and unlock with it. Change the PIN using `C`, the current PIN, and two matching new entries. Demonstrate a rejected current PIN, mismatched confirmation, cancellation, and successful use of the new PIN after a power cycle. Show that an invalid EEPROM record leaves the lock inactive.

### Complete When

First-time setup requires two matching PIN entries, PIN changes require the current PIN and two matching new entries, and saved PINs survive power removal. Failed or canceled changes preserve the existing PIN, and invalid storage cannot unlock the output or start unauthenticated setup.

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
