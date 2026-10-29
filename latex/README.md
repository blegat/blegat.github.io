# Papers and talks

Public LaTeX sources live in `paper/<name>/` and `talks/<name>/`.
Shared macros, bibliography, and figures live in `latex/`.
The allowlist in `documents.json` identifies each main file and its PDF URL.
Posters are included under `talks/`.
SumOfSquares presentations are maintained and published separately in
[SumOfSquaresSlides](https://github.com/blegat/SumOfSquaresSlides).
The thesis sources came from
`Drive/thesis`; the other documents came from `Drive/perso`.

Run from the repository root:

```sh
python3 scripts/build_documents.py
python3 scripts/build_documents.py 2016_HSCC --jobs 2
```

Install latexmk, pdfLaTeX, the extra LaTeX fonts and science packages,
BibTeX/Biber, Ghostscript, and Pygments. The workflow contains the Ubuntu
package list. Build logs and auxiliary files go to `_build/`; the PDFs go
to `_documents/paper/` and `_documents/talks/`. These are ignored by Git.
Documents compile in copies under `_build/`, which keeps their sources clean
and supports both minted v2 and v3. The build ignores user latexmk
configuration and needs no Drive mount.

The `documents` CI job compiles the PDFs and uploads them as an artifact.
The website job downloads that artifact into `__site` after Franklin runs,
then deploys the combined site to `gh-pages` on main/master pushes.
Pull requests build without deploying. The separate Pluto exporter continues
to own `slides/`. Franklin ignores the LaTeX source directories.
