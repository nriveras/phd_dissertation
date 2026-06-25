# =============================================================================
#  Dissertation build — reproducible via Docker (pinned TeX Live 2025)
# =============================================================================
#  Common usage:
#     make image            # build the pinned Docker image once
#     make render           # full-resolution PDF  -> "Dissertation Nicolas Riveras Munoz.pdf"
#     make sd               # low-res PDF (images shrunk to 1600 px on the long side)
#     make sd RES=1200      # low-res PDF at a custom resolution
#     make clean            # remove aux/temp files + the working Dissertation.pdf
#     make clean-all        # also remove build/ and the generated PDFs
#     make shell            # open a shell inside the container (debugging)
#
#  Run natively (you must have TeX Live + ImageMagick installed locally):
#     make render USE_DOCKER=0
# =============================================================================

DOC        := Dissertation
OUT_FULL   := Dissertation Nicolas Riveras Munoz.pdf
OUT_SD     := Dissertation Nicolas Riveras Munoz (SD).pdf
IMAGE      := phd-dissertation:texlive2025
RES        := 1600
USE_DOCKER := 1

# $(RUN) prefixes a command so it executes inside the pinned container.
# With USE_DOCKER=0 it collapses to nothing and the command runs natively.
#   -v  : mount the project into the container
#   -u  : run as the calling user so generated files aren't owned by root
#   -e HOME=/tmp : give TeX a writable HOME for its font cache
RUN := $(if $(filter 1,$(USE_DOCKER)),docker run --rm -v "$(CURDIR)":/workdir -w /workdir -u $(shell id -u):$(shell id -g) -e HOME=/tmp $(IMAGE),)

# latexmk drives pdflatex<->biber until references/citations settle, replacing
# the fragile manual "pdflatex; biber; pdflatex; pdflatex" sequence.
LATEXMK := latexmk -pdf -interaction=nonstopmode -halt-on-error

# Aux/temp files produced by a LaTeX build (kept identical to the old compile.sh).
TMP_FIND := find . -type f \( -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" \
	-o -name "*.lof" -o -name "*.lot" -o -name "*.blg" -o -name "*.nav" \
	-o -name "*.snm" -o -name "*.vrb" -o -name "*.dvi" -o -name "*.fls" \
	-o -name "*.fdb_latexmk" -o -name "*.xdv" -o -name "*.synctex.gz" \
	-o -name "*.synctex\(busy\)" -o -name "*.bcf" -o -name "*.run.xml" \
	-o -name "*.idx" -o -name "*.ilg" -o -name "*.ind" -o -name "*.brf" \
	-o -name ".DS_Store" -o -name "*.bbl-SAVE-ERROR" \) -delete

.DEFAULT_GOAL := render
.PHONY: render sd image shell clean clean-all

## Build the pinned Docker image (run once, or after editing the Dockerfile).
image:
	docker build -t $(IMAGE) .

## Full-resolution render.
render:
	$(RUN) $(LATEXMK) $(DOC).tex
	cp "$(DOC).pdf" "$(OUT_FULL)"
	@echo ">> wrote: $(OUT_FULL)"
	$(MAKE) clean

## Low-resolution ("SD") render. Downscales images, builds, and copies out the
## final PDF.
##
## All intermediate I/O (the 46 shrunk images, every .aux/.bcf/.bbl, and the
## working PDF) is written to /tmp INSIDE the container, not to the host bind
## mount. On Docker Desktop for Mac the bind mount (osxfs/VirtioFS) intermittently
## throws "Input/output error" under the heavy write traffic this target
## generates, which made `make sd` fail unpredictably mid-build. Keeping that
## traffic on the container's own filesystem and only copying the single final
## PDF back across the mount removes that flakiness. /tmp is already $HOME (see
## the RUN definition) and is wiped automatically when the --rm container exits,
## so there is nothing to clean up on the host. mogrify + latexmk must share one
## `docker run` because /tmp does not persist between containers.
##
## The build log is copied to build/$(DOC)-sd.log (even on failure) for debugging.
sd:
	@$(RUN) bash -c 'set -e; shopt -s nullglob; \
		mkdir -p /tmp/sd/img build; \
		magick mogrify -path /tmp/sd/img -resize "$(RES)x$(RES)>" img/*.png img/*.jpg img/*.jpeg; \
		rc=0; \
		$(LATEXMK) -usepretex="\def\GraphicsRoot{/tmp/sd/}" -auxdir=/tmp/sd -outdir=/tmp/sd $(DOC).tex || rc=$$?; \
		cp -f /tmp/sd/$(DOC).log "build/$(DOC)-sd.log" 2>/dev/null || true; \
		if [ $$rc -ne 0 ]; then echo ">> SD build failed (see build/$(DOC)-sd.log)"; exit $$rc; fi; \
		for i in 1 2 3; do cp /tmp/sd/$(DOC).pdf "$(OUT_SD)" && break || sleep 1; done'
	@echo ">> wrote: $(OUT_SD)"
	$(MAKE) clean

## Open an interactive shell in the container.
shell:
	docker run --rm -it -v "$(CURDIR)":/workdir -w /workdir -u $(shell id -u):$(shell id -g) -e HOME=/tmp $(IMAGE) bash

## Remove LaTeX aux/temp files and the regenerable working PDF ($(DOC).pdf).
## Keeps the final renamed deliverables (use clean-all to remove those too).
clean:
	$(TMP_FIND)
	-$(RUN) latexmk -c $(DOC).tex
	rm -f "$(DOC).pdf"

## Remove everything generated: aux/temp, build/, and the produced PDFs.
clean-all: clean
	rm -rf build
	rm -f "$(OUT_FULL)" "$(OUT_SD)"
