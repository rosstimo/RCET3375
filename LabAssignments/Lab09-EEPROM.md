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

> **Under revision:** This part is still being edited. Refresh the page and check with the instructor before continuing.

### Goal

Extend Part 1 with a three-register EEPROM interface, a non-blocking write operation, and a separate write-verification routine. Replace hold-to-select with a timed selection mode.

### EEPROM routine interface

Reserve these three RAM general-purpose registers (GPRs) as the shared EEPROM interface:

| GPR | Purpose |
| --- | --- |
| `ee_address` | EEPROM byte address supplied by the caller (`0x00`–`0xFF` on the PIC16F883). |
| `ee_data` | Data returned by a read, or the requested byte to write and later verify. |
| `ee_status` | Contains the `EEPROM_READ`, `EEPROM_WRITE`, and `EEPROM_ERROR` status flags. Define their bit positions with `EQU` and document them. `EEPROM_ERROR` remains set after failed verification until a later write verifies successfully. |

Use these PascalCase subroutine labels as defined by the [PIC-AS Style Guide](https://github.com/rosstimo/RCET3375/blob/main/Notes/RCET_PIC-AS_Style_Guide.md). The three named status flags are UPPER_SNAKE_CASE symbolic bit positions in `ee_status`.

Implement these routines:

- **`ReadEeprom:`** The caller loads `ee_address` before calling `ReadEeprom`. Set the `EEPROM_READ` status flag on entry; read the requested EEPROM address into `ee_data`; clear the `EEPROM_READ` status flag before returning.
- **`WriteEeprom:`** The caller loads `ee_address` and `ee_data` before calling `WriteEeprom`. First compare against the stored byte, without changing the requested value in `ee_data`. If it already matches, return **without starting a write**. Otherwise clear any stale `EEIF`, set the `EEPROM_WRITE` status flag, start the protected EEPROM write sequence, and **return immediately**. Do not wait for programming to finish inside this routine.
- **`VerifyEepromWrite:`** Call `VerifyEepromWrite` **after hardware reports write completion**. Read the address in `ee_address` and compare the stored byte against the expected value still held in `ee_data`. Do not overwrite that expected value before comparing. On a match, **clear `ee_status`, including any previous `EEPROM_ERROR` status flag**. On a mismatch, **clear the `EEPROM_WRITE` status flag and set the `EEPROM_ERROR` status flag**. Return without starting another write.

**No automatic retries:** Neither `WriteEeprom` nor `VerifyEepromWrite` may retry a write. The application must be able to detect an error without silently rewriting EEPROM.

### Non-blocking write operation

After `WriteEeprom` returns, the main loop must continue useful work such as refreshing outputs and maintaining timing. **Do not wait in a loop for `EEIF`**. While the `EEPROM_READ` or `EEPROM_WRITE` status flag is set, **ignore both buttons**; do not launch another EEPROM operation or change `ee_address`/`ee_data` while a write awaits verification. The `EEPROM_ERROR` status flag alone does not block buttons.

Detect completion by **polling `EEIF` in the ordinary main-loop pass** or by using the EEPROM write-complete interrupt. `EEIF` is set by hardware on completion and must be cleared in software. Once completion is detected, clear the hardware write-enable setting as appropriate and call `VerifyEepromWrite`. Keep the `EEPROM_WRITE` status flag set until verification resolves the operation. Preserve the uninterrupted write-unlock sequence and its interrupt precautions. Normal continuous EEPROM reading can resume after the pending write has been verified.

### Main-loop diagnostic and error indication

For Part 2, reassign the Part 1 diagnostic pins:

| Pin | Required behavior |
| --- | --- |
| **RA0** | Selection-mode LED: ON only during timed selection. |
| **RA1** | Main-loop diagnostic: **set HIGH at the beginning of every main-loop iteration and clear LOW at the end**, before the next iteration. This continues while EEPROM writing is in progress. |
| **RA2** | EEPROM error output with an **LED**: HIGH exactly when the `EEPROM_ERROR` status flag is set; LOW otherwise. |

**Only main controls RA1 and RA2.** Do not set or clear diagnostic/output pins inside EEPROM subroutines. On **every main-loop iteration**, update RA2 directly from the `EEPROM_ERROR` status flag, regardless of selection mode or whether a write is underway. A failed verification lights the error LED; a later **successfully verified write clears the `EEPROM_ERROR` status flag**, so main turns the LED off. Skipping an unchanged-value write does not clear a previous error.

Check the `EEPROM_READ` and `EEPROM_WRITE` status flags before processing the Select or Write buttons: **if either status flag is set, ignore button input for that iteration**. The `EEPROM_ERROR` status flag does not prevent button handling, allowing a later intentional write to recover from a verification error.

### Timed selection behavior

- **Select button (RB0):** A debounced press enters selection mode, toggles the pending `A`/`B` value, and turns on the **RA0 selection-mode LED (pin 2)**. Each additional Select press toggles the value and restarts an approximately **one-second timeout**.
- **Timeout:** About one second after the last Select press, exit selection mode, turn off RA0, and resume continuously reading EEPROM address `0x00` for the DLG7137 display. **Do not write on timeout.**
- **Write button (RB1):** A debounced press within the selection window requests a save, provided the `EEPROM_READ` and `EEPROM_WRITE` status flags are both clear. Ignore presses outside that window or while either busy status flag is set. If the byte differs, start the non-blocking write. Keep the pending address/data intact and do not let a timeout interrupt the pending write and verification.
- **Completion:** On successful verification, clear `ee_status` (including the `EEPROM_ERROR` status flag), exit selection mode, turn off RA0, and display the stored value. On a mismatch, set the `EEPROM_ERROR` status flag so main lights RA2; do not retry automatically. An unchanged-value save exits selection mode without a hardware write.

Preserve software debouncing and the display behavior developed in Part 1.

### Before Lab

Document the three GPR assignments, the bit positions of the `EEPROM_READ`, `EEPROM_WRITE`, and `EEPROM_ERROR` status flags, and each routine's inputs, outputs, and status flag changes. Document the RA0 and RA2 LED connections and loading, and the RA1 main-loop diagnostic. Prepare a state diagram showing selection, timeout, write in progress, verification, button gating, and error handling. Include the one-second timing plan, a table of address/value tests, and an explanation of what main continues doing while EEPROM writes.

Explain why EEPROM reads do not consume write endurance and why skipping identical writes improves endurance.

### In the Lab

1. Refactor Part 1 to use `ee_address`, `ee_data`, and `ee_status` for the EEPROM interface. Confirm the `EEPROM_READ` status flag is set during `ReadEeprom` and cleared on return, with the result in `ee_data`.
2. Read and write several different bytes at several valid EEPROM addresses. Check their contents again after removing and restoring power.
3. Implement the non-blocking `WriteEeprom` routine. Confirm that it returns to main with the `EEPROM_WRITE` status flag set while the hardware operation is still underway. Continue main-loop iterations, updating the diagnostic and error LED, but ignore button input while the `EEPROM_READ` or `EEPROM_WRITE` status flag is set.
4. Detect completion through `EEIF` polling in main or the EEPROM interrupt. Call `VerifyEepromWrite` exactly once for each completed write. Confirm a successful comparison clears `ee_status`.
5. Test the `EEPROM_ERROR` status flag **without trying to cause a physical EEPROM failure**: for one controlled test, deliberately program a different byte than the expected byte kept in `ee_data`. Verify that the comparison sets the `EEPROM_ERROR` status flag and main lights the RA2 LED. Restore the normal code, then perform a changed-value write that verifies successfully; confirm the `EEPROM_ERROR` status flag clears and the LED turns off. Do not start a retry or perform an endurance stress test.
6. Verify that saving an already stored value produces **no EEPROM write**, using the EEPROM hardware flags/registers or debugger. This skipped write must not clear an existing `EEPROM_ERROR` status flag.
7. Implement and measure timed selection. Verify each Select press restarts the one-second window; timeout causes no write; Write outside the window is ignored; and a permitted save completes verification before returning to display mode.
8. Use the scope to show **RA1 pulsing once per main-loop iteration**, including while the `EEPROM_WRITE` status flag is set. Show the RA0 selection LED and verify **RA2 always follows the `EEPROM_ERROR` status flag**, both after a controlled mismatch and after a successful write. Demonstrate that button presses are ignored while the `EEPROM_READ` or `EEPROM_WRITE` status flag is set, but not when only the `EEPROM_ERROR` status flag is set. Explain how the shared address/data registers are protected until verification finishes.

### Evidence

Include the GPR/flag calling contracts, state diagrams and flowcharts, test address/value table, final source, and labeled measurements. Show a main-loop RA1 pulse on every iteration, including during a pending write; RA2 matching the `EEPROM_ERROR` status flag on each iteration; the read-status transitions; a write returning before `EEIF`; a successful write clearing an earlier `EEPROM_ERROR` status flag; a controlled verification mismatch setting the `EEPROM_ERROR` status flag; an unchanged-value request without a hardware write; and selection timeout without a write.

### Demonstrate

Show independent EEPROM addresses, RA1 main-loop pulses continuing through a non-blocking write, and RA2 reflecting the last write-verification error status. Demonstrate both a failed verification and a later successful write that clears the error LED, with no automatic retries. Show that the `EEPROM_READ` and `EEPROM_WRITE` status flags block button handling but the `EEPROM_ERROR` status flag does not. Demonstrate the one-second selection window, timeout without writing, and skipped writes for unchanged data.

### Complete When

The three-GPR interface works at variable EEPROM addresses; `ReadEeprom` returns data and clears the `EEPROM_READ` status flag; `WriteEeprom` returns before completion with the `EEPROM_WRITE` status flag set; main detects completion and calls `VerifyEepromWrite`; successful verification clears `ee_status` and a mismatch sets the `EEPROM_ERROR` status flag without retry; RA1 pulses each main-loop iteration; the RA2 error LED always follows the `EEPROM_ERROR` status flag; the `EEPROM_READ` and `EEPROM_WRITE` status flags suppress button handling while the `EEPROM_ERROR` status flag does not; unchanged values are not rewritten; and timed selection behaves reliably.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-3"></a>
## Part 3 - Four-Digit Electronic Lock

> **Under revision:** This part is still being edited. Refresh the page and check with the instructor before continuing.

### Goal

Reuse the keypad and display to build a lock that recognizes a four-digit PIN stored in EEPROM. A correct PIN energizes a **simulated solenoid output** for one second; all other conditions keep the output inactive.

**Safety:** Do not connect a solenoid directly to a PIC output. A real inductive load requires an appropriate driver and transient protection. Hold the simulated output inactive through reset and startup, not only during normal locked operation.

### PIN storage and startup

Store the **four decimal digits separately** so leading zeros are retained. Use this preliminary memory layout:

| Data EEPROM address | Meaning |
| --- | --- |
| `0x10` through `0x13` | Four PIN digits, in order, each a value from 0 through 9 |
| `0x14` | Validity marker: `0xA5` means the PIN record was committed |

Only accept a PIN record when its marker is valid **and all four digits are in range**. On erased or invalid EEPROM, fail locked. A one-time commissioning method for entering the **initial** PIN is required before the lock can be used; it must be a deliberate operation, not an automatic overwrite on every reset.

> **Instructor review needed:** choose and verify the initial-PIN commissioning method before publishing this part.

### Required behavior

- Use only keypad digits `0`–`9` for PIN entry, accepting **one digit per physical key press**, not one digit per scan.
- Maintain the entered digits and progress in RAM. A reset discards an incomplete entry.
- Compare a completed four-digit entry with the stored PIN; do not accept shorter entries or drop leading zeros.
- After a correct entry, drive the simulated solenoid output HIGH for **one second**, then LOW.
- Incorrect entries must never activate the output. Allow the user to retry.
- On startup/reset, the output must remain inactive until a **new correct PIN** is entered. Do not store an unlocked state in EEPROM.
- Provide useful one-character entry/status feedback on the existing DLG7137 display. Choose symbols and describe them in your lab book. The display holds only **one character at a time**.

### Before Lab

Prepare or reference the keypad schematic and scan logic from Lab 02, including electrical precautions for simultaneous keys. Document the simulated-output wiring and its reset-safe pull-down/driver behavior. Draw an EEPROM address map, a state diagram covering startup, locked, PIN entry, success, and failed entry, and a flowchart of the PIN comparison. Describe the initial-PIN provisioning method.

### In the Lab

1. Bring the keypad and display back into the working Part 2 project. Confirm the input scanner produces distinct key events.
2. Provision a known four-digit PIN deliberately and verify its stored digits and validity marker.
3. Test correct, incorrect, too-short, and leading-zero PIN entries as applicable.
4. Measure the simulated unlock pulse. Its HIGH duration must be **one second**.
5. Power-cycle the PIC, confirm the output remains inactive at startup, and enter the saved PIN again.
6. Deliberately test an invalid PIN record. It must not authorize an unlock.

### Evidence

Include the PIN address map, state diagram/flowcharts, code, PIN test table, oscilloscope capture or timed measurement of the unlock output, and observations of startup and invalid-record behavior.

### Demonstrate

Enter incorrect and correct PINs, show the one-second output, and prove that the code survives power removal while the **unlocked state does not**.

### Complete When

The lock accepts exactly four decimal digits, uses persistent EEPROM data, activates its simulated output only for a correct PIN, and starts locked after every reset.

[Back to top](#top) · [Lab assignments](https://github.com/rosstimo/RCET3375/tree/main/LabAssignments)

<a id="part-4"></a>
## Part 4 - Authenticated PIN Change

> **Under revision:** This part is still being edited. Refresh the page and check with the instructor before continuing.

### Goal

Extend the Part 3 lock so a user can change the PIN only after entering the current PIN, and the new PIN remains effective after a power cycle.

### Required behavior

Use a momentary **Change PIN** button to enter change mode. The keypad is used to enter the current PIN, the new PIN, and confirmation of the new PIN.

1. Require the current four-digit PIN. Incorrect authentication exits change mode without changing EEPROM.
2. After authentication, collect a new four-digit PIN and then collect it again for confirmation.
3. If confirmation fails or the user cancels before committing, keep the existing PIN.
4. If the entries match, save the new PIN deliberately. Do not write to EEPROM on each digit press.
5. Verify the saved record and report success or failure on the display.
6. After a power cycle, the new PIN must unlock and the old PIN must not.

### Interrupted-update recovery

An EEPROM write completes one byte at a time. A power failure during a four-digit update must **not** accidentally authorize a partial new PIN.

A simple draft approach is to **invalidate the record marker first**, write and verify the four digit bytes, then write the valid marker **last**. If an update is interrupted, treat the record as invalid and keep the lock inactive until it is explicitly reprovisioned. Do not silently revert to an accessible factory default.

> **Instructor review needed:** confirm whether this fail-locked, re-provision-on-interruption policy is preferable to a more complex two-record recovery that preserves the old PIN.

### Before Lab

Update the keypad/lock state diagram with change mode, authentication, new entry, confirmation, write, verify, cancellation, and errors. Draw the order of EEPROM changes and predict the consequences of interruption at each step. Document how the user knows which PIN-entry phase is active using the single-character display.

### In the Lab

1. Verify change mode rejects an incorrect current PIN.
2. Verify mismatched confirmation and cancellation leave the original PIN active.
3. Change the PIN successfully and verify both the new and old codes.
4. Power-cycle the PIC and repeat verification.
5. Deliberately invalidate the stored record under controlled test conditions. Verify the simulated solenoid stays inactive, including after a reset.
6. Explain the endurance tradeoff of writing one record only when a deliberate, authenticated change occurs.

### Evidence

Include updated flowcharts/state diagrams, EEPROM transaction order, code, results for correct/incorrect current PIN, mismatched confirmation, successful update, power-cycle verification, and invalid-record recovery.

### Demonstrate

Change the PIN in front of the instructor. Show that incorrect current-PIN or confirmation attempts leave the existing code in place. Demonstrate that the new PIN survives power removal and the system remains locked on invalid storage.

### Complete When

PIN changes require the old code and matching new entries, persist correctly, and never cause an unexpected unlock after reset or invalid storage.

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
