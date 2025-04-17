# PhD Dissertation of Nicolas Riveras Muñoz at the University of Tübingen

## To compile the .pdf file in local:

```bash
pdflatex Dissertation.tex
biber Dissertation
pdflatex Dissertation.tex
pdflatex Dissertation.tex
```

## Clean temporary files

```bash
find . -type f \
  \( -name '*.aux' -o -name '*.log' -o -name '*.out' -o -name '*.toc' \
   -o -name '*.nav' -o -name '*.snm' -o -name '*.synctex.gz' \
   -o -name '*.fdb_latexmk' -o -name '*.fls' -o -name '*.vrb' \) \
  -delete

```

## Fast render

The `img_sd` folder contain low resolution version of all the images in order to render it with the free tier of [overleaf](https://www.overleaf.com/) restricted to 20 seconds of rendering time.

To reduce images:
```bash
sips -Z 640 *.jpg
sips -Z 640 *.png
```
