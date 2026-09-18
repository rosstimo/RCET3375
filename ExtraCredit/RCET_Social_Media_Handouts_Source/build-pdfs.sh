#!/usr/bin/env bash
# Rebuild all handout PDFs without modifying Original/.
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
shopt -s nullglob
typst_sources=("$project_dir"/Typst/*.typ)
latex_sources=("$project_dir"/LaTeX/*.tex)

if (( ${#typst_sources[@]} + ${#latex_sources[@]} == 0 )); then
  echo "No .typ or .tex sources found in Typst/ or LaTeX/." >&2
  exit 1
fi

if (( ${#typst_sources[@]} > 0 )) && ! command -v typst >/dev/null 2>&1; then
  echo "Missing required compiler: typst" >&2
  exit 1
fi
if (( ${#latex_sources[@]} > 0 )); then
  for tool in latexmk pdflatex; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "Missing required compiler: $tool" >&2
      exit 1
    fi
  done
fi

build_dir=$(mktemp -d "${TMPDIR:-/tmp}/rcet-pdfs.XXXXXX")
trap 'rm -rf -- "$build_dir"' EXIT
count=0

for source in "${typst_sources[@]}"; do
  name=$(basename -- "$source" .typ)
  echo "Building Typst/$name.pdf"
  typst compile "$source" "$build_dir/$name.pdf"
  cp -- "$build_dir/$name.pdf" "${source%.typ}.pdf"
  count=$((count + 1))
done

for source in "${latex_sources[@]}"; do
  name=$(basename -- "$source" .tex)
  echo "Building LaTeX/$name.pdf"
  # Run beside the source so relative image and input paths resolve correctly.
  # latexmk repeats pdflatex as needed for references and links.
  if ! (
    cd -- "$(dirname -- "$source")"
    latexmk -pdf -interaction=nonstopmode -halt-on-error \
      -outdir="$build_dir/latex" "./$name.tex"
  ) > "$build_dir/latex-build.log" 2>&1; then
    cat -- "$build_dir/latex-build.log" >&2
    exit 1
  fi
  cp -- "$build_dir/latex/$name.pdf" "${source%.tex}.pdf"
  count=$((count + 1))
done

echo "Built $count PDFs beside their sources. Original/ was not modified."
