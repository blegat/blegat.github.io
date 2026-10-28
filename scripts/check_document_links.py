#!/usr/bin/env python3
"""Check that every local document link resolves to a compiled PDF."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
links = set()
for name in ['talks.md', 'publications.md', '_publications.md', 'bib.jl']:
    links.update(re.findall(r'["\'](/(?:talks|paper)/[^"\']+\.pdf)["\']',
                            (ROOT / name).read_text()))
for link in sorted(links):
    pdf = ROOT / '_documents' / link.lstrip('/')
    if not pdf.is_file() or not pdf.read_bytes().startswith(b'%PDF-'):
        raise SystemExit(f'Missing or invalid linked PDF: {link}')
print(f'Checked {len(links)} linked PDFs.')
