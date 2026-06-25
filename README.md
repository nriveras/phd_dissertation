# PhD Dissertation of Nicolas Riveras Muñoz at the University of Tübingen

The build is fully reproducible: a pinned **Docker** image (TeX Live 2025 + the
matching `biber`, plus ImageMagick) provides the exact toolchain, and a
**Makefile** drives every task. You do **not** need LaTeX installed locally.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running.

## One-time setup

Build the pinned image (downloads a few GB the first time, then it's cached):

```bash
make image
```

## Compile the PDF

```bash
make render
```

This produces `Dissertation.pdf` and copies it to the final filename
**`Dissertation Nicolas Riveras Munoz.pdf`**.

## Fast / low-resolution render ("SD")

For a much smaller PDF (e.g. to fit Overleaf's free-tier 20-second render limit),
shrink the figures on the fly. Images are downscaled so their longest side is at
most the given pixel size, used for that build only, then discarded:

```bash
make sd            # default: 1600 px on the long side
make sd RES=1200   # custom resolution
```

This produces **`Dissertation Nicolas Riveras Munoz (SD).pdf`**. The temporary
downscaled images live in `build/sd/` and are deleted automatically afterwards,
so the original full-resolution images in `img/` are never touched.

## Clean temporary files

```bash
make clean       # remove LaTeX aux/temp files (keeps the PDFs)
make clean-all   # also remove build/ and the generated PDFs
```

## Running without Docker (native fallback)

If you already have TeX Live and ImageMagick installed locally, append
`USE_DOCKER=0` to run the same targets against your local tools:

```bash
make render USE_DOCKER=0
make sd USE_DOCKER=0
```
