# Migration Notes

These observations have been classified and applied. Course-wide items are preserved in `README.md`; Lab 05-specific decisions are preserved in `Lab05-ISRs-plan.md` and the student-facing draft.

- [x] Require register-style maps for port pin assignments and named GPR state/status storage.
- [x] Keep layout/format consistent with the lab migration standard.
- [x] Preserve released F26 material on `main` while continuing next-version work on lab branches for S27.
- [x] Include relevant component datasheets in student lab-book references.
- [x] Include the student's assignment GitHub URL in lab-book references.
- [x] Reduce unnecessary wording and repeated requirements where practical.
- [x] Parts 1-2 use a student-selected suitable PORTA monitoring pin.
- [x] Part 2 uses RB4 as the prescribed IOC source.
- [x] Part 4 explicitly reuses the DLG7137/PORTC interface from Lab 02.
- [x] Context saving starts from PIC16F883 data sheet Section 14.4 / Example 14-1.
- [x] PCLATH/computed-`GOTO` teaching is kept outside the ISR lab and documented in `../../Notes/PIC16F883-Computed-GOTO-and-PCLATH.md`.
- [x] Do not explicitly warn students to preserve delay counters or other application GPRs during nested execution; allow that failure mode to emerge through testing/troubleshooting.
