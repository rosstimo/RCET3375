# RCET Social Media Extra Credit Handouts

Editable source for the student and instructor social-media handouts.

## Publishing source

The files in `Typst/` are the canonical publishing sources. The files in `LaTeX/` are retained as alternate editable versions but are not used by the automated publisher.

The GitHub Actions workflow at `.github/workflows/publish-extra-credit-pdfs.yml` compiles the Typst sources whenever they change. Pull requests receive short-lived workflow artifacts for review. After the change reaches `main`, the workflow replaces the PDF assets on the fixed `extra-credit-handouts` release.

Stable published URLs:

- Student handout: https://github.com/rosstimo/RCET3375/releases/download/extra-credit-handouts/RCET_Lab_Video_Extra_Credit_Student.pdf
- Instructor guide: https://github.com/rosstimo/RCET3375/releases/download/extra-credit-handouts/RCET_Student_Social_Media_Instructor_Guide.pdf

These release-asset URLs remain the same across rebuilds as long as the release tag and filenames remain unchanged.

## Local builds

Run:

```bash
./build-pdfs.sh
```

The script builds every `.typ` file directly in `Typst/` and every `.tex` file directly in `LaTeX/`. It saves each PDF beside its source, replacing the previous compiled copy only after that source builds successfully. PDFs are ignored by Git in `ExtraCredit/`.

The script stops on a build error and prints compiler diagnostics. Temporary build files are cleaned up automatically.

Requirements for a full local build are `typst`, `latexmk`, and `pdflatex`, plus the TeX Live packages used by the LaTeX sources: `geometry`, `fontenc`, `tgtermes`, `tgheros`, `xcolor`, `enumitem`, `tabularx`, `array`, `hyperref`, `tcolorbox`, `microtype`, and `ragged2e`.

The automated publisher uses Typst 0.15.1 and installs Liberation Sans/Mono on the runner so the generated output is reproducible.

## Account information

The final account/page names reflect the list supplied by Karli Snyder, Digital and Social Media Manager for the Idaho State University College of Technology.
