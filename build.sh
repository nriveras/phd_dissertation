#!/usr/bin/env sh
# =============================================================================
#  Build the dissertation inside the pinned Docker container.
# =============================================================================
#  The ONLY thing a fresh machine needs is Docker. TeX Live 2025, biber,
#  latexmk and ImageMagick all live inside the image -- nothing else to install.
#
#  Usage:
#     ./build.sh                full-resolution PDF
#                               -> "build/Dissertation Nicolas Riveras Munoz.pdf"
#     ./build.sh sd             low-res PDF (figures shrunk to 1600 px)
#                               -> "build/Dissertation Nicolas Riveras Munoz (SD).pdf"
#     ./build.sh sd 1200        low-res at a custom resolution
#     ./build.sh clean          remove aux/temp files (keep the PDFs)
#     ./build.sh clean-all      also remove the generated PDFs
#     ./build.sh image          force a rebuild of the Docker image
#     ./build.sh shell          open a shell inside the container (debugging)
#
#  The actual build logic lives in .latexmkrc; this script is just the launcher
#  that runs `latexmk` inside the container. Set DOCKER=podman to use Podman.
# =============================================================================

set -eu

IMAGE=phd-dissertation:texlive2025
DOCKER=${DOCKER:-docker}
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)   # repo root (build context)

# Build the image automatically the first time; cached on every run after that.
ensure_image() {
    if ! $DOCKER image inspect "$IMAGE" >/dev/null 2>&1; then
        echo ">> building Docker image $IMAGE (first run only, downloads a few GB) ..."
        $DOCKER build -t "$IMAGE" "$HERE"
    fi
}

# Run a command inside the container.
#   -v  mount the project          -w  work there
#   -u  run as the calling user, so generated files aren't owned by root
#   -e HOME=/tmp  gives TeX a writable home AND keeps the build scratch on the
#                 container's own filesystem, off the slow bind mount (see
#                 .latexmkrc -- this is what avoids the "Input/output error").
run() {
    $DOCKER run --rm \
        -v "$HERE":/workdir -w /workdir \
        -u "$(id -u):$(id -g)" \
        -e HOME=/tmp \
        "$@"
}

cmd=${1:-render}
case "$cmd" in
    render)
        ensure_image
        run "$IMAGE" latexmk
        ;;
    sd)
        ensure_image
        if [ "${2:-}" ]; then
            run -e SD=1 -e "RES=$2" "$IMAGE" latexmk
        else
            run -e SD=1 "$IMAGE" latexmk
        fi
        ;;
    clean)
        ensure_image
        run "$IMAGE" latexmk -c
        ;;
    clean-all)
        ensure_image
        run "$IMAGE" latexmk -C
        ;;
    image)
        $DOCKER build -t "$IMAGE" "$HERE"
        ;;
    shell)
        ensure_image
        run -it "$IMAGE" bash
        ;;
    *)
        echo "usage: $0 [render|sd [RES]|clean|clean-all|image|shell]" >&2
        exit 2
        ;;
esac
