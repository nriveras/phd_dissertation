# =============================================================================
#  latexmk configuration for the dissertation  (ported from the old Makefile)
# =============================================================================
#  latexmk drives pdflatex <-> biber until references/citations settle, then
#  copies the result to its final deliverable name. Everything the old Makefile
#  did now lives here, so a build is a plain `latexmk` invocation -- the same
#  command natively or inside the pinned Docker image (see README).
#
#  Render modes:
#     latexmk                  -> full-resolution PDF
#                                 "build/Dissertation Nicolas Riveras Munoz.pdf"
#     SD=1 latexmk             -> low-res PDF (figures shrunk to 1600 px)
#                                 "build/Dissertation Nicolas Riveras Munoz (SD).pdf"
#     SD=1 RES=1200 latexmk    -> low-res at a custom resolution
#
#  Cleaning (latexmk's own flags -- no separate target needed):
#     latexmk -c               -> remove aux/temp files (keep the PDFs)
#     latexmk -C               -> also remove the scratch dir + every PDF made
# =============================================================================

use File::Path     qw(make_path remove_tree);
use File::Basename qw(dirname);

$pdf_mode   = 1;     # build the PDF with pdflatex
$bibtex_use = 2;     # run biber and treat the generated .bbl as a dependency

my $DOC      = 'dissertation';
my $OUT_FULL = 'build/Dissertation Nicolas Riveras Munoz.pdf';
my $OUT_SD   = 'build/Dissertation Nicolas Riveras Munoz (SD).pdf';

# The deliverables land in build/ (kept out of git -- see .gitignore). The dir
# may not exist on a fresh clone / CI checkout, so create it before the copy.
make_path('build');

# --- Scratch build directory (deliberately OUTSIDE the project tree) ---------
# A build rewrites the ~95 MB PDF several times plus all the .aux/.bcf churn.
# When that heavy, repeated write traffic lands in the project directory it
# intermittently dies with "pdflatex: Dissertation: Input/output error" -- on the
# Docker bind mount (osxfs/VirtioFS), and, as testing showed, on the local disk
# too (a file watcher/indexer racing the writes). The cure is the same in both
# places: do the churny build under /tmp and copy only the single final PDF back
# into the project (one write, which is reliable). Inside the Docker image /tmp
# is already $HOME on the container's own filesystem, so this works there too.
# Override the base with BUILD_DIR if /tmp is unsuitable (keep it space-free).
(my $tmp = $ENV{TMPDIR} || '/tmp') =~ s{/$}{};
my $scratch = $ENV{BUILD_DIR} || "$tmp/dissertation-build";
my $build   = $ENV{SD} ? "$scratch/sd" : "$scratch/full";
$aux_dir = $build;
$out_dir = $build;

# pdflatex's -output-directory does NOT create nested aux subdirectories, so the
# per-chapter \include's would fail to write e.g. tex/Manuscript-1.aux on the
# first pass -- and with no .aux/.bcf, latexmk can't detect biber (it falls back
# to plain bibtex and errors out). Mirror the source's subdirectories (tex/).
make_path($build);
make_path("$build/$_") for do { my %d = map { dirname($_) => 1 } glob('*/*.tex'); keys %d };

# Non-interactive engine flags (kept identical to the old Makefile): stop on the
# first error instead of dropping into pdflatex's interactive prompt. %S is the
# source file; the SD branch swaps it to %P so it can inject TeX code.
$pdflatex = 'pdflatex -interaction=nonstopmode -halt-on-error %O %S';

my $deliverable = $OUT_FULL;

# --- Low-resolution ("SD") mode ---------------------------------------------
# This rc file is plain Perl evaluated when latexmk starts, so the one-off figure
# downscale happens right here, before the compile. Figures are shrunk into
# $build/img and \GraphicsRoot is pointed there, so they resolve from $build/img/
# with no per-file edits. The originals in img/ are never touched.
if ($ENV{SD}) {
    my $res = $ENV{RES} || 1600;
    make_path("$build/img");

    # glob() splits the string into three patterns; matched names keep any
    # spaces, and system()'s list form passes each as one argument. The trailing
    # `>` only shrinks images larger than ${res}px on the long side.
    my @imgs = glob('img/*.png img/*.jpg img/*.jpeg');
    system('magick', 'mogrify', '-path', "$build/img",
           '-resize', "${res}x${res}>", @imgs) == 0
        or die "SD: figure downscale (magick mogrify) failed\n";

    $deliverable = $OUT_SD;
    # %P expands to "<pre_tex_code>\input{source}". Unlike a bare $pre_tex_code
    # (which latexmk ignores), referencing %P is what actually injects the code;
    # the engine flags above are preserved.
    $pre_tex_code = "\\def\\GraphicsRoot{$build/}";
    $pdflatex     = 'pdflatex -interaction=nonstopmode -halt-on-error %O %P';
}

# --- Copy the finished PDF to its deliverable name --------------------------
# $success_cmd runs only after a *successful* compile (never on failure), in
# normal batch mode as well as -pvc -- verified against latexmk 4.86a. This is
# the single write back into the project directory.
$success_cmd = "cp \"$build/$DOC.pdf\" \"$deliverable\" && echo \">> wrote: $deliverable\"";

# --- Cleaning ---------------------------------------------------------------
# Extra extensions for `latexmk -c`/`-C` beyond latexmk's built-in list.
$clean_ext = 'bbl run.xml bcf nav snm vrb brf idx ilg ind glo gls glg';

# latexmk -C empties the scratch dir, but not the space-named deliverable PDFs
# (their names aren't derived from the jobname). Remove those, and the scratch
# tree itself, here. $cleanup_mode is set by latexmk: 1 = -C, 2 = -c, 0 = normal.
END {
    if (defined $cleanup_mode && $cleanup_mode == 1) {
        unlink $OUT_FULL, $OUT_SD;
        remove_tree($scratch, { safe => 1 });
    }
}
