# PhD Dissertation of Nicolas Riveras Muñoz at the University of Tübingen

## To compile the .pdf file in local:

```bash
pdflatex Dissertation.tex
biber Dissertation
pdflatex Dissertation.tex
pdflatex Dissertation.tex
```
or 

```bash
/Users/nico/Desktop/Projects/PhD/Dissertation/phd_dissertation/compile.sh
```

## Clean temporary files

```bash
find . -type f \( -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" \
  -o -name "*.lof" -o -name "*.lot" -o -name "*.blg" -o -name "*.nav" \
  -o -name "*.snm" -o -name "*.vrb" -o -name "*.dvi" -o -name "*.fls" \
  -o -name "*.fdb_latexmk" -o -name "*.xdv" -o -name "*.synctex.gz" \
  -o -name "*.synctex\(busy\)" -o -name "*.bcf" -o -name "*.run.xml" \
  -o -name "*.idx" -o -name "*.ilg" -o -name "*.ind" -o -name "*.brf" \
  -o -name ".DS_Store" -o -name "*.bbl-SAVE-ERROR" \) -delete
```

## Fast render

The `img_sd` folder contain low resolution version of all the images in order to render it with the free tier of [overleaf](https://www.overleaf.com/) restricted to 20 seconds of rendering time.

To reduce images:
```bash
sips -Z 640 *.jpg
sips -Z 640 *.png
```

## ToDo

+ when there are two parentheses in a row, is it necessary to add space between them? -> it has to be an space between them, but it seems like latex include it anyways when rendering.
