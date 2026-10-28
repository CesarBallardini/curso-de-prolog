#!/usr/bin/env python
"""Rewrite the rest of the book after chapters move headings and exercises between their pages.

    ./tools/apply-page-maps.py MAPS_DIR            dry run: print what would change
    ./tools/apply-page-maps.py MAPS_DIR --write    rewrite the files

When a chapter's sections move from index.md to its other pages, or its exercises are spread
over those pages and renumbered, whoever edits the chapter fixes the links inside it and writes
a map, `map-NN.tsv` (NN the chapter number), with tab-separated lines:

    anchor     OLDPAGE#OLDID   NEWPAGE#NEWID     a heading id that disappeared or moved
    exercise   OLD             NEW     PAGE      every exercise: old number, new number, page
    nav        index.md page2.md ... soluciones.md    the chapter's pages in reading order

This tool applies every map in MAPS_DIR to the rest of the repository:

- nav: the chapter's entries in mkdocs.yml, reordered as the map says (titles kept);
- anchor: every link from outside the chapter to OLDPAGE#OLDID goes to NEWPAGE#NEWID;
- exercise: outside the chapter, `soluciones.md#OLD` (or `#ejercicio-OLD`) and the text
  «ejercicio/solución OLD del capítulo NN» take the new number, all in one pass, so no number is
  renumbered twice. Links to the chapter's `index.md#ejercicios` are listed for review: the
  exercise they mean may now be on another page.

A chapter's own folders (docs/ and ejemplos/) are left alone: they were rewritten with the map.
Run it once per set of maps: a second run would renumber the exercises again. A mention that
names the chapter only through a nearby link («la del [ejercicio 5](../capitulo-49-…/index.md)»)
is not recognized; look for those by hand.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FILES = (
    'docs/**/*.md',
    'references/**/*.md',
    'ejemplos/**/*.pl',
    'ejemplos/**/*.plt',
    'tools/assistant/**/*.py',
    'tests/**/*.py',
    'tests/**/*.feature',
    'README.md',
)
CHAPTER = re.compile(r'capitulo-(\d\d)')
LINK = re.compile(r'\]\(([^)\s#]*)(#[^)\s]*)?\)')
# «ejercicio 16 del capítulo 35», also with the chapter as a link text: «del\n[capítulo 35](…)».
MENTION = re.compile(r'\b((?:[Ee]jercicio|[Ss]oluci[oó]n) )(\d+)(\s+del\s+\[?cap[ií]tulo )(\d+)\b')


def load(path: Path):
    """(anchors {old: new}, exercises {old: (new, page)}, nav [pages]) of one map."""
    anchors, exercises, nav = {}, {}, None
    for line in path.read_text(encoding='utf-8').splitlines():
        if not line.strip():
            continue
        kind, *rest = line.split('\t')
        if kind == 'anchor':
            anchors[rest[0]] = rest[1]
        elif kind == 'exercise':
            exercises[int(rest[0])] = (int(rest[1]), rest[2])
        elif kind == 'nav':
            nav = rest[0].split()
        else:
            raise SystemExit(f'{path}: unknown line {line!r}')
    return anchors, exercises, nav


def chapter_of(path: Path) -> int | None:
    """The chapter a path belongs to, from its first `capitulo-NN` component."""
    for part in path.parts:
        if m := CHAPTER.match(part):
            return int(m.group(1))
    return None


def reorder_nav(chapters, folders, write: bool) -> None:
    """Put each mapped chapter's nav entries in the map's order."""
    mkdocs = ROOT / 'mkdocs.yml'
    lines = mkdocs.read_text(encoding='utf-8').split('\n')
    for n, (_, _, nav) in sorted(chapters.items()):
        if nav is None:
            continue
        folder = folders[n] + '/'
        where = [i for i, line in enumerate(lines) if folder in line]
        if where != list(range(where[0], where[0] + len(where))):
            raise SystemExit(f'chapter {n}: its nav entries are not contiguous')
        entries = {re.search(r'[\w-]+\.md', lines[i][lines[i].index(folder) :]).group(0): lines[i] for i in where}
        if sorted(entries) != sorted(nav):
            raise SystemExit(f'chapter {n}: the nav has {sorted(entries)}, the map {sorted(nav)}')
        new = [entries[name] for name in nav]
        if new != [lines[i] for i in where]:
            print(f'nav {n}: {" ".join(nav)}')
            lines[where[0] : where[-1] + 1] = new
    if write:
        mkdocs.write_text('\n'.join(lines), encoding='utf-8', newline='\n')


def rewrite(file: Path, chapters, review: list[str]) -> str:
    """The file's text with every mapped link and exercise mention updated."""
    own = chapter_of(file.relative_to(ROOT))

    def relink(m):
        target, anchor = m.group(1), m.group(2) or ''
        if not target.endswith('.md'):
            return m.group(0)
        resolved = (file.parent / target).resolve()
        n = chapter_of(resolved.relative_to(ROOT))
        if n is None or n == own or n not in chapters:
            return m.group(0)
        anchors, exercises, _ = chapters[n]
        key = f'{resolved.name}{anchor}'
        if key in anchors:
            page, _, new_anchor = anchors[key].partition('#')
            prefix = target[: len(target) - len(resolved.name)]
            return f']({prefix}{page}#{new_anchor})' if new_anchor else f']({prefix}{page})'
        if resolved.name == 'soluciones.md' and (e := re.fullmatch(r'#(ejercicio-)?(\d+)', anchor)):
            old = int(e.group(2))
            if old in exercises:
                return f']({target}#{e.group(1) or ""}{exercises[old][0]})'
        if resolved.name == 'index.md' and anchor == '#ejercicios':
            review.append(f'{file.relative_to(ROOT).as_posix()}: links to the exercises of chapter {n}')
        return m.group(0)

    def renumber(m):
        n, old = int(m.group(4)), int(m.group(2))
        if n == own or n not in chapters or old not in chapters[n][1]:
            return m.group(0)
        return f'{m.group(1)}{chapters[n][1][old][0]}{m.group(3)}{m.group(4)}'

    return MENTION.sub(renumber, LINK.sub(relink, file.read_text(encoding='utf-8')))


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if len(args) != 1:
        raise SystemExit(__doc__)
    write = '--write' in sys.argv
    chapters = {int(path.stem.split('-')[1]): load(path) for path in sorted(Path(args[0]).glob('map-*.tsv'))}
    folders = {int(d.name[9:11]): d.name for d in (ROOT / 'docs').glob('capitulo-*')}
    reorder_nav(chapters, folders, write)

    review, changed = [], 0
    for file in sorted({p for pattern in FILES for p in ROOT.glob(pattern) if p.is_file()}):
        original = file.read_text(encoding='utf-8')
        text = rewrite(file, chapters, review)
        if text == original:
            continue
        changed += 1
        for before, after in zip(original.split('\n'), text.split('\n'), strict=True):
            if before != after:
                print(f'{file.relative_to(ROOT).as_posix()}:\n  - {before.strip()[:160]}\n  + {after.strip()[:160]}')
        if write:
            file.write_text(text, encoding='utf-8', newline='\n')
    print(f'{len(chapters)} maps; {changed} files {"rewritten" if write else "would change"}')
    for line in sorted(set(review)):
        print('review', line)
    return 0


if __name__ == '__main__':
    sys.exit(main())
