# RCET 3375 Fall 2026 Self-Paced Lab Standard

RCET3375 is self-paced. Current F26 material is organized as lab assignments, not lesson plans or day-by-day schedules.

The goal of the lab standard is consistency. Students should encounter the same assignment grammar, documentation expectations, repository structure, and evidence pattern throughout the course even as the technical topics become more advanced.

## Lab structure

Each current lab should use this progression unless the topic gives a clear reason not to:

1. **Part 1 - Fundamentals / proof of life**: establish the tool, device, peripheral, or concept in the simplest useful form. High scaffolding is appropriate.
2. **Part 2 - Guided application**: use the new concept in a practical circuit/program while still providing substantial direction.
3. **Part 3 - Application**: give a clearly specified engineering problem and require students to determine more of the implementation.
4. **Part 4 - Independent modification / integration**: require a bounded change, extension, or integration using concepts already exercised. Part 4 introduces independence, not necessarily large complexity. Early labs should use tightly bounded changes; later labs may require broader design decisions.
5. **Part 5 - Mastery**: optional enrichment after Parts 1-4 are complete. It must be a specific technical challenge or investigation with clear success criteria, not a vague list of possible extensions.

Part 5 is not required for ordinary full credit.

Difficulty should progress both **within each lab** and **across the semester**. Early PIC labs may still provide considerable guidance in Parts 3 and 4. Later labs should expect increasingly independent design and troubleshooting.

## Repeated part structure

When practical, each required part should use the following headings:

```text
## Part N - Descriptive Name

### Goal
### Before Lab
### In the Lab
### Evidence
### Demonstrate
### Complete When
```

The headings describe a student workflow rather than a traditional lab-report format.

### Goal

State what the student will make, measure, or demonstrate. Keep it concrete.

### Before Lab

Place design work here whenever practical:

- datasheet/manual research;
- SFR/register documentation;
- calculations;
- schematic preparation;
- flowcharts;
- expected values/timing;
- program preparation;
- safety/loading analysis.

### In the Lab

Bench time should prioritize:

- construction and wiring;
- programming/flash/debug cycle;
- measurement;
- comparison against prediction;
- troubleshooting;
- integration;
- demonstration;
- documentation of observed behavior.

Students should not plan to begin a substantial design from scratch during scheduled bench time.

### Evidence

Require the exact artifacts needed to demonstrate the engineering path. Prefer the chain:

```text
prediction/calculation
-> implementation
-> measurement
-> comparison
-> explanation/troubleshooting
```

A screenshot by itself is not evidence of understanding unless the student states what was expected and what the screenshot demonstrates.

### Demonstrate

Specify both what must operate and what the student must be able to explain. A working circuit without an explanation is not sufficient evidence of understanding.

### Complete When

Give the part a clear endpoint tied to required evidence and instructor checkoff.

---

# Assignment repository standard

Use **one Git repository per assignment**.

Do not place the entire semester in one repository. A separate repository limits the damage if a student corrupts a repository, rewrites history, deletes files, creates nested repositories, or otherwise cannot repair the Git state independently.

## Repository naming

Use a descriptive course/assignment name, for example:

```text
RCET3375-LabXX-Assignment-Name
```

Lab numbers may change as the sequence is revised; the descriptive topic name should remain meaningful.

## Example repository structure

Use only the directories that apply to the assignment.

```text
RCET3375-LabXX-Assignment-Name/
├── README.md
├── .gitignore
├── source/
│   ├── pic/
│   │   └── ProjectName.X/
│   ├── csharp/
│   └── other/
├── schematics/
│   ├── ProjectName.kicad_pro
│   ├── ProjectName.kicad_sch
│   └── exports/
│       └── ProjectName-schematic.pdf
├── documentation/
├── evidence/
│   ├── oscilloscope/
│   ├── logic-analyzer/
│   └── photos/
└── lab-book/
    └── LabXX-Lab-Book.pdf
```

Development projects remain intact inside their normal project directory structure. Do not remove source files from MPLAB X, C#, or other native project structures merely to simplify the repository tree.

## Git rules

- One assignment = one repository.
- Never nest Git repositories.
- Do not run `git init` inside a repository that already exists.
- Commit files required to reopen and rebuild the project.
- Ignore generated build products and private machine-specific IDE state.
- Commit editable KiCad source and a portable schematic export.
- Make meaningful commits during the work rather than one final bulk commit.
- Push the assignment repository to GitHub before completion.
- A fresh clone should contain enough information to reopen and rebuild the assignment.

The GitHub repository URL serves as the digital location for the assignment work.

At final submission, scan the relevant physical lab-book pages into **one readable, correctly oriented PDF** under `lab-book/`.

---

# Lab-book engineering-reference standard

The physical lab book is the primary engineering record. Students may use their lab books during RCET3373 theory assessments, so documentation should be organized for later retrieval rather than written only to satisfy a submission requirement.

## SFR documentation

Document every Special Function Register encountered during an experiment.

The first time an SFR is used, record:

- register name and purpose;
- address or addresses;
- bank or banks;
- complete 8-bit register map;
- every bit name and function;
- reserved/unimplemented bits;
- reset/default state when relevant;
- value/configuration used;
- explanation of relevant settings;
- datasheet page/section/register reference.

If the SFR was already completely documented, reference the earlier lab-book page instead of copying it again.

If later work uses previously undocumented bits or a materially different configuration, document the new use and reference the original entry.

## Electrical loading and component verification

Before applying power, account for **every IC pin and every component used in the circuit**.

Show calculations where a numeric loading calculation applies. Where a numeric calculation is not meaningful, document the applicable electrical requirement and explain why the connection satisfies it.

Check, as applicable:

- source/sink current;
- input current and voltage limits;
- per-pin, per-port, and total-device limits;
- logic-level compatibility;
- pull-up/pull-down current;
- resistor current and dissipation;
- capacitor ratings;
- oscillator/crystal requirements;
- programmer/ICSP connections;
- alternate pin functions;
- multiple-signal current paths;
- all connected external-device specifications.

Suggested table:

| Device / pin / component | Operating condition | Calculated/expected value | Datasheet limit/requirement | Margin | Pass? | Source |
| --- | --- | ---: | ---: | ---: | --- | --- |

The circuit is not ready to build until the analysis shows that all used pins/components operate within specification.

---

# Official documentation

Each lab must identify relevant IDs from `REFERENCE_INDEX.md` or provide direct official-document links when students need them immediately.

Device-specific register bits, addresses, reset states, vector locations, electrical limits, instruction behavior, and peripheral details must be checked against the PIC16F883 datasheet. Family-manual/application-note material supports explanation but does not override the device datasheet.

Course examples and legacy labs are teaching material, not the final technical authority.

---

# Required visual/example planning

Every lab should contain or link to explicit visual/example placeholders, even if the final visual has not been created yet.

Use identifiers such as:

```text
SCHEMATIC LAB02-P1-01
Purpose: PIC16F883 minimum system and RB0 measurement connection.
Must show: VDD/VSS, MCLR, oscillator, ICSP/programmer, RB0 test point, common ground.
Source basis: PIC16F883 datasheet + Microchip 8-bit design recommendations.
Status: placeholder; do not generate yet.
```

Other useful prefixes:

- `SCREEN` - MPLAB/instrument screenshots to capture later;
- `VISUAL` - bit maps, timing diagrams, flow diagrams, comparison tables;
- `CODE` - starter/reference source;
- `PHOTO` - bench setup/component-placement photo to capture later.

---

# Question-bank role

RCET3375 questions should concentrate on readiness and troubleshooting rather than duplicate the entire RCET3373 theory bank.

Good lab-bank question types include:

- prelab datasheet lookup;
- choose the next troubleshooting step;
- interpret a waveform or register setup;
- predict what a wiring/configuration error would cause;
- calculation gate before bench work;
- short oral/checkoff prompts;
- code-review questions tied to lab source.

Generated/salvaged questions stay `reviewed: false` until instructor review.
