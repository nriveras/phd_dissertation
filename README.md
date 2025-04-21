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

## ToDo
### Feedback from CG
Reviewed file is available in </Users/nico/Desktop/Projects/PhD/Dissertation/Defense process/Dissertation_Riveras_Muñoz_20250403_cg.pdf>

+ Make the text labels in your figures (y/y-axis, tick labels etc.) bigger!! There is a possibility that the reviewers are a bit pissed when they use the printed version of your thesis and they probably can`t read the labels. And you know they are not the youngest ;)
+ For all parts of the "results & discussion" section, the discussion part could be extended. Sometimes there are no references at all...
And you already discussed a lot in your papers, so maybe try to extract parts of the discussion there and include it in your thesis. I also recommended some references, maybe they are useful.

### Feedback from Prof. Scholten

1: In the summary and also in the text, there was a lack of clear statements about what new insights were gained through your work and where the results lead to new/different understanding and conclusions than before. The degree of innovation and the originality of the results should be emphasized more clearly, as these are an important evaluation criterion.

2: Upper and lower case are still a little mixed up. I know that this is a big challenge for non-native speakers. Perhaps the outline, chapter headings and figure and tab labels should be checked more carefully here.
