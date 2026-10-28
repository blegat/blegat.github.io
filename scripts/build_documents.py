#!/usr/bin/env python3
"""Build the explicitly listed public documents; publish PDFs only."""
import argparse
import concurrent.futures
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def build(document):
    target = ROOT / '_documents' / document['output']
    target.unlink(missing_ok=True)
    if document.get('unavailable'):
        print(f"SKIP {document['directory']}: {document['unavailable']}", flush=True)
        return True
    directory = ROOT / document['directory']
    output = ROOT / '_build' / document['directory']
    output.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env['TEXINPUTS'] = f".:{ROOT}/latex//:{ROOT}/latex/images//:" + env.get('TEXINPUTS', '')
    env['BIBINPUTS'] = f".:{ROOT}/latex//:" + env.get('BIBINPUTS', '')
    with (output / 'build.log').open('w') as log:
        result = subprocess.run(
            ['latexmk', '-norc', '-pdf', '-shell-escape', '-interaction=nonstopmode',
             '-halt-on-error', '-file-line-error', f'-outdir={output}', document['main']],
            cwd=directory, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=600,
        )
    if result.returncode:
        print(f"FAIL {document['directory']} (see {output / 'build.log'})", flush=True)
        return False
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(output / Path(document['main']).with_suffix('.pdf'), target)
    print(f"OK {document['output']}", flush=True)
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('names', nargs='*', help='Document folder names (default: all)')
    parser.add_argument('--jobs', type=int, default=2)
    args = parser.parse_args()
    documents = json.loads((ROOT / 'latex/documents.json').read_text())
    if args.names:
        documents = [d for d in documents if Path(d['directory']).name in args.names]
        missing = set(args.names) - {Path(d['directory']).name for d in documents}
        if missing:
            parser.error(f"Unknown documents: {', '.join(sorted(missing))}")
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as executor:
        results = list(executor.map(build, documents))
    raise SystemExit(0 if all(results) else 1)


if __name__ == '__main__':
    main()
