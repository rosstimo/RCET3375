# RCET Social Media Extra Credit Handouts

Final shareable PDFs plus editable source for the student and instructor handouts.

## Folders

- `Original/`: original PDFs for comparison; the build script leaves these untouched.
- `LaTeX/`: `.tex` sources and their compiled PDFs.
- `Typst/`: `.typ` sources and their compiled PDFs.

## Regenerate all PDFs

```bash
./build-pdfs.sh
```

The script builds every `.typ` file directly in `Typst/` and every `.tex` file
directly in `LaTeX/`. It saves each PDF beside its source, replacing the previous
compiled copy only after that source builds successfully. It works from any
working directory when invoked by its path. Temporary build files are cleaned
up automatically; no preview images are generated.

The script stops on a build error and prints the compiler diagnostics. PDFs
successfully rebuilt earlier in the run remain updated.

Requirements: `typst`, `latexmk`, and `pdflatex` on your PATH, with the TeX Live
packages used by the LaTeX sources: `geometry`, `fontenc`, `tgtermes`, `tgheros`,
`xcolor`, `enumitem`, `tabularx`, `array`, `hyperref`, `tcolorbox`, `microtype`,
and `ragged2e`.

The delivered original PDFs were built from LaTeX. The Typst sources use no
external Typst packages.

If `Liberation Sans` or `Liberation Mono` are not installed, replace those font names near the top of each Typst file with fonts available on your system.

## Account information

The final account/page names reflect the list supplied by Karli Snyder, Digital and Social Media Manager for the Idaho State University College of Technology.
