# RCET 3375 Lab Assignment Migration Workflow

This directory contains planning material for migrating inherited RCET3375 laboratory assignments into the current standardized Markdown format.

The migration documents are instructor/planning material. Student-facing lab instructions remain in `LabAssignments/`.

## Purpose

The migration work has two related goals:

1. preserve the useful technical intent of inherited assignments while removing obsolete hardware assumptions, unnecessary busy work, and unclear instructions; and
2. develop a consistent lab-assignment format that can be applied across the course without changing expectations underneath students who are already completing live assignments.

The target format should remain consistent with `../../LAB_STANDARD.md` while the course is in active use. New decisions discovered during migration should be recorded here first when applying them immediately to already-live assignments would create unnecessary churn.

## Migration sequence

For each inherited PDF lab:

1. **Preserve the source.** Keep the inherited PDF available for historical reference.
2. **Create a Markdown recreation.** Reproduce the inherited assignment faithfully enough that its original requirements, sequence, and intent can be inspected without redesigning it at the same time.
3. **Create a migration plan.** Identify:
   - the essence of what students should learn;
   - what should be kept;
   - what should be removed or reduced;
   - what should be created or clarified;
   - connections to prior and later labs;
   - hardware/software that can be reused;
   - useful measurements and evidence;
   - opportunities to introduce or reinforce embedded C without displacing the hardware model;
   - unresolved design questions.
4. **Create the redesigned student-facing draft.** Use the current RCET3375 lab structure and documentation expectations.
5. **Review for consistency.** Compare the draft against earlier migrated labs and the current lab standard so students encounter the same assignment grammar and documentation pattern.
6. **Resolve migration notes.** Move durable course-wide decisions into this workflow or the appropriate future lab standard. Keep lab-specific decisions in that lab's migration plan.
7. **Merge only when the assignment is ready for its intended semester.** Do not mix unfinished migration planning into student-facing instructions.

## Standardized student-facing structure

Use the progression defined by `../../LAB_STANDARD.md` unless the technical topic gives a clear reason to vary it.

When practical, each required part should use:

```text
## Part N - Descriptive Name

### Goal
### Before Lab
### In the Lab
### Evidence
### Demonstrate
### Complete When
```

Keep the layout and wording pattern consistent with prior migrated lab assignments. Consistency is useful, but it should not create unnecessary text. Prefer the shortest instruction that clearly communicates the requirement, expected engineering work, evidence, and completion condition.

## Lab-book register documentation

The lab book is intended to become a usable engineering reference, not merely a record that an assignment was completed.

In addition to the SFR documentation required by `../../LAB_STANDARD.md`, require register-style maps when students assign meaning to ordinary registers or port bits.

Examples include:

- PORT pin assignments used as named inputs, outputs, indicators, or control signals;
- general-purpose registers used for status flags;
- general-purpose registers used for state tracking;
- counters, indexes, timing values, or other persistent program data whose bit or byte meaning matters to the design.

Document these in a format comparable to the SFR register maps in the PIC16F883 datasheet. The map should make the register or port assignment understandable later without reopening the source code.

Reference earlier lab-book documentation instead of copying an unchanged map again.

## Lab-book references

The references for each assignment should make the student's engineering record independently traceable.

Include or reference, as applicable:

- the PIC16F883 datasheet and relevant Microchip documentation;
- datasheets for every relevant external component used in the assignment;
- other official manuals or application notes used for design decisions;
- prior lab-book pages or prior course work reused by the design; and
- the student's Git repository URL for the assignment.

The repository URL connects the physical lab-book record to the source code, schematics, digital evidence, and other assignment artifacts.

## Instruction-writing rule

Reduce wordiness whenever possible.

Lab instructions should be detailed enough that requirements are unambiguous, but repeated explanation, repeated evidence lists, and prose that does not change what the student must design, measure, document, or demonstrate should be removed.

The goal is lower visual and mental clutter without hiding engineering expectations.

## Semester rollout and change control

### Fall 2026 live material

Once a Fall 2026 lab assignment has been merged into `main` and released to students, treat its requirements and standardized format as live course material.

Do not make broad formatting, documentation, or curriculum changes to an already-live assignment merely because the migration standard has continued to improve. Make immediate changes only when needed to correct a factual error, safety problem, broken instruction, or other issue that materially affects current students.

### Spring 2027 target

Further improvements discovered after a lab is live should be treated as planned Spring 2027 rollout changes.

This includes, when applicable:

- refinements to the standardized part structure;
- expanded register-map expectations;
- reference/documentation requirements;
- Git-repository reference requirements;
- wording and layout cleanup;
- improved evidence/checkoff structure; and
- other course-wide consistency changes found while later labs are migrated.

Accumulate these decisions during the Fall 2026 migration work, then apply them coherently across the lab sequence for the Spring 2027 rollout rather than changing individual live assignments piecemeal.

### Labs not yet released

A lab that has not yet been released to students may adopt the current migration target immediately. This allows later Fall 2026 labs to benefit from lessons learned during migration without retroactively changing assignments students have already begun or completed.

## Where decisions belong

Use the narrowest durable home for each decision:

- **Student-facing lab file:** requirements that apply to that assignment.
- **Lab-specific migration plan:** curriculum reasoning, inherited-material analysis, and unresolved questions for one lab.
- **This migration workflow:** rules and decisions that apply across legacy-lab migrations or future standardized assignments.
- **`../../LAB_STANDARD.md`:** the active student-facing/course-wide lab standard for the semester in which it is released.
- **`notes.md`:** temporary capture of ideas that have not yet been classified or resolved.

Once a note has a durable home, it can be removed from `notes.md` rather than leaving multiple competing sources of truth.
