#!/usr/bin/env python
"""Keep docs/patrones.md identical to the `Patrón N` boxes of the Part II chapters.

Every `!!! example "Patrón N — Name"` box in `docs/capitulo-*/index.md` is the source of the
catalogue entry `## N — Name`. The entry is the dedented box text, with its relative links
rewritten for `docs/patrones.md`, followed by the line that names the chapter and the section
the box lives in. The intro of the catalogue and its `## Criterios de calidad` section are
kept as they are.

    uv run tools/sync-patterns.py            # report the entries that differ
    uv run tools/sync-patterns.py --write    # rewrite docs/patrones.md
"""

import re
import sys
from pathlib import Path

from markdown.extensions.toc import slugify

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs'
CATALOGUE = DOCS / 'patrones.md'
# Numbers kept for a chapter not written yet, so that later chapters can be numbered in reading
# order meanwhile. The numbering check allows exactly these gaps; drop an entry once its box exists.
RESERVED: dict[int, str] = {}

BOX = re.compile(r'^!!! example "Patr[oó]n (\d+) — (.+)"\s*$')
SECTION = re.compile(r'^## (\d+\.\d+) (.+?)\s*$')
CHAPTER_DIR = re.compile(r'capitulo-(\d\d)-')


def boxes():
    """Yield (number, name, body_lines, chapter_dir, section_number, section_title)."""
    for index in sorted(DOCS.glob('capitulo-*/index.md')):
        lines = index.read_text(encoding='utf-8').split('\n')
        section = None
        i = 0
        while i < len(lines):
            match = SECTION.match(lines[i])
            if match:
                section = (match.group(1), match.group(2))
            match = BOX.match(lines[i])
            if match:
                number, name = int(match.group(1)), match.group(2)
                body = []
                i += 1
                while i < len(lines) and (lines[i].startswith('    ') or lines[i].strip() == ''):
                    body.append(lines[i][4:] if lines[i].startswith('    ') else '')
                    i += 1
                while body and body[-1] == '':
                    body.pop()
                yield number, name, body, index.parent.name, section
                continue
            i += 1


def relink(text, chapter_dir):
    """Rewrite the links of a box, relative to docs/capitulo-NN/, for docs/patrones.md."""
    text = re.sub(r'\]\(\.\./([^)]*)\)', r'](\1)', text)  # ../x -> x
    text = re.sub(r'\]\(#([^)]*)\)', rf']({chapter_dir}/index.md#\1)', text)  # #slug -> page#slug
    text = re.sub(r'\]\(index\.md#', rf']({chapter_dir}/index.md#', text)
    return re.sub(r'\]\(soluciones\.md#', rf']({chapter_dir}/soluciones.md#', text)


def entry(number, name, body, chapter_dir, section):
    chapter = int(CHAPTER_DIR.match(chapter_dir).group(1))
    text = relink('\n'.join(body), chapter_dir)
    if section is None:
        raise SystemExit(f'Patrón {number} is not under a numbered section in {chapter_dir}')
    anchor = slugify(f'{section[0]} {strip_code(section[1])}', '-')
    where = f'Capítulo {chapter}, [sección {section[0]}]({chapter_dir}/index.md#{anchor}).'
    return f'## {number} — {name}\n\n{text}\n\n{where}\n'


def strip_code(title):
    return title.replace('`', '')


def build():
    current = CATALOGUE.read_text(encoding='utf-8')
    head, sep, _ = current.partition('\n## 1 — ')
    if not sep:
        raise SystemExit('docs/patrones.md: the first entry `## 1 — …` was not found')
    entries = sorted(boxes(), key=lambda b: b[0])
    numbers = [b[0] for b in entries]
    if clash := sorted(set(numbers) & set(RESERVED)):
        raise SystemExit(f'patterns {clash} now exist: remove them from RESERVED in {Path(__file__).name}')
    if sorted(numbers + list(RESERVED)) != list(range(1, len(numbers) + len(RESERVED) + 1)):
        raise SystemExit(f'pattern numbers are not 1..n (reserved: {sorted(RESERVED)}): {numbers}')
    body = '\n'.join(entry(*b) for b in entries)
    return current, head.rstrip('\n') + '\n\n' + body


def main():
    current, wanted = build()
    if '--write' in sys.argv:
        CATALOGUE.write_text(wanted, encoding='utf-8', newline='\n')
        print(f'docs/patrones.md rewritten from {wanted.count(chr(10) + "## ") - 1} boxes')
        return 0
    if current == wanted:
        print('docs/patrones.md agrees with the pattern boxes')
        return 0
    old = dict(re.findall(r'^## (\d+) — .+?\n(.*?)(?=^## |\Z)', current, re.M | re.S))
    new = dict(re.findall(r'^## (\d+) — .+?\n(.*?)(?=^## |\Z)', wanted, re.M | re.S))
    differing = [n for n in new if old.get(n) != new[n]]
    print(f'docs/patrones.md differs from the boxes in {len(differing)} entries: ' + ', '.join(differing))
    print('run with --write to rewrite it')
    return 1


if __name__ == '__main__':
    sys.exit(main())
