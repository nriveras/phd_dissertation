#!/bin/bash
# Compile the dissertation only on demand
cd "$(dirname "$0")"

echo "Starting compilation process..."
find . -type f \( -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" \
  -o -name "*.lof" -o -name "*.lot" -o -name "*.blg" -o -name "*.nav" \
  -o -name "*.snm" -o -name "*.vrb" -o -name "*.dvi" -o -name "*.fls" \
  -o -name "*.fdb_latexmk" -o -name "*.xdv" -o -name "*.synctex.gz" \
  -o -name "*.synctex\(busy\)" -o -name "*.bcf" -o -name "*.run.xml" \
  -o -name "*.idx" -o -name "*.ilg" -o -name "*.ind" -o -name "*.brf" \
  -o -name ".DS_Store" -o -name "*.bbl-SAVE-ERROR" \) -delete

pdflatex Dissertation.tex
biber Dissertation
pdflatex Dissertation.tex
pdflatex Dissertation.tex

find . -type f \( -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" \
  -o -name "*.lof" -o -name "*.lot" -o -name "*.blg" -o -name "*.nav" \
  -o -name "*.snm" -o -name "*.vrb" -o -name "*.dvi" -o -name "*.fls" \
  -o -name "*.fdb_latexmk" -o -name "*.xdv" -o -name "*.synctex.gz" \
  -o -name "*.synctex\(busy\)" -o -name "*.bcf" -o -name "*.run.xml" \
  -o -name "*.idx" -o -name "*.ilg" -o -name "*.ind" -o -name "*.brf" \
  -o -name ".DS_Store" -o -name "*.bbl-SAVE-ERROR" \) -delete
echo "Compilation complete!"
