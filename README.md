# PhD Dissertation of Nicolas Riveras Muñoz at the University of Tübingen

To compile the .pdf file in local:

```bash
pdflatex Dissertation
bibtex Dissertation
bibtex tex\Manuscript-1
bibtex tex\Manuscript-2
bibtex tex\Manuscript-3
bibtex tex\Manuscript-4
bibtex tex\Manuscript-5
pdflatex Dissertation
pdflatex Dissertation
```

## Fast render

The `img_sd` folder contain low resolution version of all the images in order to render it with the free tier of [overleaf](https://www.overleaf.com/) restricted to 20 seconds of rendering time.

To reduce images:
```bash
sips -Z 640 *.jpg
sips -Z 640 *.png
```
