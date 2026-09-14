# RCET 3375 Lab Assignment Migration Workflow

This directory contains planning material for migrating inherited RCET3375 laboratory assignments into the current standardized Markdown format.

The migration documents are instructor/planning material. Student-facing lab instructions remain in `LabAssignments/`.

## Durable source of truth

GitHub is the durable source of truth for this work.

Chat history, assistant memory, prior conversation summaries, and other product-specific context may help during a working session, but the project must not depend on them for continuity. Any decision, observation, unresolved question, workflow rule, or curriculum change that matters to future work should be recorded in the repository when practical.

When a working conversation produces something that should still matter in a later session, prefer to update the appropriate GitHub document during that same session rather than relying on the conversation to preserve it.

Use the repository to preserve:

- current student-facing requirements;
- future-version changes being developed on lab branches;
- lab-specific curriculum reasoning and unresolved questions;
- course-wide migration and formatting rules;
- observations from live teaching that should influence future revisions; and
- the status of decisions that have been accepted, deferred, or still need review.

Assistant behavior, memory availability, model choice, or product policy should not determine whether the project remains internally consistent.

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
7. **Keep the lab branch as the working version until it is ready to merge.** The branch may continue evolving even when an earlier version of that lab is already live on `main`.

## Live-teaching observation workflow

Observations made while students are using the live assignments are valuable design evidence and should be captured even when they are incomplete or informal.

Do not require the instructor to classify an observation before recording it. `notes.md` may be used as an inbox for raw observations such as:

- a requirement students repeatedly misinterpret;
- an instruction that produces unnecessary questions;
- a measurement or hardware setup that is awkward in practice;
- an assignment part that is too easy, too difficult, or consumes unexpected time;
- documentation that students consistently omit;
- evidence/checkoff requirements that do not reveal the intended understanding;
- wording or layout that creates visual or mental clutter; or
- a pattern seen across several labs.

During review, classify each observation as either:

- **lab-specific**, in which case it belongs in that lab's plan and/or student-facing branch; or
- **course-wide**, in which case it belongs in this migration workflow, the evolving standard, and any affected lab branches.

Once an observation has been acted on or moved to its durable home, remove or mark it resolved in the inbox so the same issue is not repeatedly rediscovered.

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

## Applying global changes

The lab-specific branches are working copies of the next version of each assignment.

When the overall assignment format, documentation standard, terminology, evidence pattern, or another course-wide rule changes, update the affected existing lab branches as soon as practical. Do not wait until the end of the semester to propagate a known global improvement across the working versions.

This applies even when the Fall 2026 version of a lab is already live on `main`. In that case, leave the released F26 version stable and apply the improvement to the lab branch as part of its Spring 2027 working version.

The end-of-semester pass should therefore be primarily a review, reconciliation, testing, and merge process rather than the first time global changes are copied across the lab sequence.

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

## Semester rollout and branch workflow

The stability boundary is the released material on `main`, not the lab-specific working branches.

Each lab-assignment migration branch may continue to be updated at any time. A branch is the working version of that lab until it is reviewed and merged.

### Fall 2026 labs already live

If the Fall 2026 version of a lab has already been merged to `main` and released to students, leave that live version stable except for corrections that current students actually need, such as factual errors, safety problems, broken instructions, or other material issues.

Continue improving that lab on its existing lab-assignment branch. Once the F26 version is live, further branch work is naturally treated as the planned Spring 2027 version.

There is no need to stop improving the branch or create a separate S27 branch merely because the current semester version has already been released.

### Fall 2026 labs not yet live

If a lab has not yet been released during Fall 2026, its existing lab-assignment branch may continue to evolve and may still be reviewed and merged for F26 when ready.

It may adopt improvements discovered during the migration of earlier labs before it goes live.

### Spring 2027 rollout

During Fall 2026, continue updating the existing lab-assignment branches as migration work reveals better curriculum, clearer wording, improved documentation requirements, or a better standardized format.

After the Fall 2026 semester concludes and before Spring 2027 begins:

1. review the accumulated work on all lab-assignment branches;
2. reconcile course-wide formatting and documentation expectations across the full lab sequence;
3. update the active lab standard as needed for S27;
4. verify links, numbering, references, hardware assumptions, and cross-lab consistency;
5. test or otherwise validate the assignments where practical; and
6. merge the reviewed lab branches into `main` for the Spring 2027 rollout.

This allows the course to improve continuously during F26 without changing live assignments underneath current students, while still producing one coherent S27 lab sequence rather than a collection of piecemeal edits.

## Where decisions belong

Use the narrowest durable home for each decision:

- **Student-facing lab file on a lab branch:** the developing requirements for that assignment.
- **Student-facing lab file on `main`:** the currently released version students should follow.
- **Lab-specific migration plan:** curriculum reasoning, inherited-material analysis, and unresolved questions for one lab.
- **This migration workflow:** rules and decisions that apply across legacy-lab migrations or future standardized assignments.
- **`../../LAB_STANDARD.md`:** the active course-wide lab standard for the version currently released on `main`.
- **`notes.md`:** temporary capture of ideas and live-teaching observations that have not yet been classified or resolved.

Once a note has a durable home, it can be removed from `notes.md` rather than leaving multiple competing sources of truth.
