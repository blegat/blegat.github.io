## Writing

Read [this book](https://epubs.siam.org/doi/book/10.1137/1.9781611976106?__cf_chl_tk=.3AS0y0P4PM2X1PX.XHZLcNKMpqZsuHlcb5s12hMIQw-1770223359-1.0.1.1-kv4JoPugqm52PQ3p.35UT2VpFSER4eemhHTUuiuRaMw), available [in Zotero](https://www.zotero.org/groups/5839659/legatgroup/items/2AEY84HE/).

Don't use too long lines in your LaTeX file, use line breaks at the end of sentences.
LaTeX ignores these line breaks but when looking at Git diffs, it avoid the cases of ling lines that differ just by a few characters.

## Zotero

With overleaf, you can have automatic export using "Integrations" on the left -> Zotero.

If using LaTeX locally, the automatic export of Zotero into BibTeX isn't good.
Install this extension: https://retorque.re/zotero-better-bibtex/
Then, to export, right click on a library -> Export library -> in format, select "Better BibLaTeX" and check "Keep updated" and "Background export".
To avoid conflict with your colleagues, don't export the `file` fields since the path will differ.
For this, got in Edit -> Settings -> Better BibTeX. In Export -> Fields, write "file".
