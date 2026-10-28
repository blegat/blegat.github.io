# Papers and talks

Public LaTeX sources live in `paper/<name>/` and `talks/<name>/`.
Shared macros, bibliography, and figures live in `latex/`.
The allowlist in `documents.json` identifies each main file and its PDF URL.
Posters are included under `talks/`. The thesis sources came from
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
The build ignores user latexmk configuration and needs no Drive mount.

The `documents` CI job compiles the PDFs and uploads them as an artifact.
The website job downloads that artifact into `__site` after Franklin runs,
then deploys the combined site to `gh-pages` on main/master pushes.
Pull requests build without deploying. The separate Pluto exporter continues
to own `slides/`. Franklin ignores the LaTeX source directories.

## Missing materials

The 2020 CDC slides require figures from the external
`HybridCoSimulationStabilityAnalysis` project, including `no_delay_orbit`,
`delay_orbit`, `hybrid_system`, `hpcmap`, and `example_lemma2`.
Their source is retained and explicitly marked unavailable in the manifest.
Once the figures are restored, update its graphic paths and remove the
`unavailable` field to enable its build and restore its link in `talks.md`.

The following old Drive links had no matching source in `Drive/perso`.
Their broken links were removed from the website; the event entries remain.
Restore links when the corresponding sources or original PDFs are found:

- 2023: KU Leuven (November), Julia and Optimization Days, JuMP-dev,
  SIAM Optimization, SIAM Dynamical Systems.
- 2022: INFORMS Computing Society (symmetry reduction).
- 2021: POEMA, JuMP-dev, EUROPT.
- 2020: INFORMS (SumOfSquares).
- 2019: JuliaCon, EUROPT, Julia Nantes.
- 2018: CDC, UAntwerpen, NCAG poster, ADHS poster.

The February 2023 “Real roots” talk is a different event from the linked
November 2023 KU Leuven talk, so its slides were not substituted.
Existing Google Slides presentation links are retained.
