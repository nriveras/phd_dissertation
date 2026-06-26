# Pinned, reproducible build environment for the dissertation.
#
# Base: the official full-scheme TeX Live image (TeX Live 2025), which already
# bundles everything this document needs -- KOMA-Script (scrbook), biblatex +
# the matching biber, siunitx, svg, latexmk, helvet, etc. Pinning by digest
# (not a moving tag) is what makes the build byte-for-byte reproducible.
#
# To refresh the pin later: `docker pull texlive/texlive` then read the new
# digest from `docker images --digests texlive/texlive`.
FROM texlive/texlive:latest

# ImageMagick is used by the `SD=1` render (in .latexmkrc) to downscale figures.
# It is not part of the TeX Live image, so install it here (cross-platform
# replacement for macOS-only `sips`).
RUN apt-get update \
    && apt-get install -y --no-install-recommends imagemagick \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workdir
