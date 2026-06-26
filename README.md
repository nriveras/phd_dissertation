# PhD Dissertation of Nicolas Riveras Muñoz at the University of Tübingen

The build runs entirely **inside a pinned Docker container** (TeX Live 2025 +
biber + latexmk + ImageMagick). The only thing a fresh machine needs is Docker —
nothing else to install. A small launcher script, `build.sh`, wraps the Docker
command so you never have to type it by hand.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running.

That's it. (The image is built automatically the first time you run `build.sh`.)

## Compile the PDF

```bash
./build.sh
```

The first run builds the Docker image (downloads a few GB, then it's cached);
every run after that is fast. It produces the deliverable
**`build/Dissertation Nicolas Riveras Munoz.pdf`**.

## Fast / low-resolution render ("SD")

For a much smaller PDF (e.g. to fit Overleaf's free-tier render limit), figures
are downscaled so their longest side is at most the given pixel size — used for
that build only, and the originals in `img/` are never touched:

```bash
./build.sh sd          # default: 1600 px on the long side
./build.sh sd 1200     # custom resolution
```

Produces **`build/Dissertation Nicolas Riveras Munoz (SD).pdf`**.

## Clean up

```bash
./build.sh clean       # remove aux/temp files (keeps the PDFs)
./build.sh clean-all   # also remove the generated PDFs
```

## Other commands

```bash
./build.sh image       # force a rebuild of the Docker image (after editing the Dockerfile)
./build.sh shell       # open a shell inside the container, for debugging
```

> Using Podman instead of Docker? Run any command with `DOCKER=podman`, e.g.
> `DOCKER=podman ./build.sh`.

## Continuous integration

Every push and pull request builds the full-resolution PDF on GitHub Actions
using this same Docker image, so a broken build is caught automatically. The
workflow (`.github/workflows/latex.yml`) uploads the rendered PDF as a
downloadable **build artifact** — open the run under the repo's *Actions* tab
and grab it from the *Artifacts* section. You can also trigger it by hand
(*Actions → Build dissertation → Run workflow*).

## Project layout

```
tex/            chapter sources (abstract, introduction, manuscript-1 ... )
img/            figures (referenced as img/… ; never modified by the SD build)
bibliography/   references.bib  (the single biblatex database)
build/          rendered PDFs land here (git-ignored)
dissertation.tex   master file that \include's everything in tex/
dissertation.sty   custom class/style and metadata commands
.latexmkrc      the build logic (pdflatex ↔ biber loop, SD downscale, copy-out)
build.sh        Docker launcher
Dockerfile      pinned TeX Live 2025 environment
```

---

## How it works (and why it's built this way)

- **`build.sh`** is just the launcher. It builds the image if needed and runs
  `latexmk` inside the container with the right flags (`-u` so output files are
  owned by you, not root; `-e HOME=/tmp` for a writable TeX home).
- **`.latexmkrc`** holds the actual build logic: the `pdflatex` ↔ `biber` loop,
  the `SD` figure downscale, and copying the finished PDF to its deliverable name.
- **The build happens under `/tmp` inside the container, not on the mounted
  project folder.** A build rewrites the ~95 MB PDF several times, and that heavy
  write traffic on the Docker bind mount intermittently fails with
  `pdflatex: Dissertation: Input/output error`. Doing the churn on the
  container's own filesystem and copying back only the single final PDF avoids it.

### Running without Docker (optional)

If you happen to have TeX Live + ImageMagick installed locally, the same
`.latexmkrc` works directly — no container needed:

```bash
latexmk                  # full-resolution PDF
SD=1 latexmk             # low-res render (SD=1 RES=1200 for a custom size)
latexmk -c               # clean aux (-C also removes the PDFs)
```

Natively the build scratch goes to your system temp dir (overridable with
`BUILD_DIR=…`) for the same reason it uses `/tmp` in Docker — the project folder
itself can trigger the same intermittent I/O error under heavy writes.
