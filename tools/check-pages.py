#!/usr/bin/env python
"""A chapter that continues on extra pages reads as one stream and closes on its pages.

    ./tools/check-pages.py                 every chapter
    ./tools/check-pages.py capitulo-41     one chapter

A long chapter continues on pages of its own in the same folder. The pages are read in the
order of the nav, and that order is checked:

- the nav lists index.md first, then the other pages, and «Soluciones» last;
- the numbered sections `## N.M` carry the chapter's number, appear once, and increase along
  the pages: a section lives on the page that holds its text, with no stub of it on index.md;
- the exercises are numbered 1, 2, 3, ... across the pages, each page's under its own
  `## Ejercicios`, and soluciones.md has a `## N` (or `## Ejercicio N`) for every one of them;
- `## Resumen` and `## Temas que se retoman` are on the last page that has numbered sections
  (index.md when none of the others has): a page without them, such as the full source of a
  program, is an appendix;
- each page ends with its closing sections, in this order: Ejercicios, Resumen, Temas que se
  retoman, Referencias. No other level-2 heading follows the first of them.

A chapter of one page is checked for the last two rules only. Exits 1 if any rule fails.
"""

import re
import sys

import examples

FENCE = re.compile(r'^```.*?^```', re.M | re.S)
H2 = re.compile(r'^## (.+?)\s*$', re.M)
SECTION = re.compile(r'^(\d+)\.(\d+) ')
ITEM = re.compile(r'^(\d+)\. ', re.M)
SOLUTION = re.compile(r'^## (?:Ejercicio )?(\d+)\s*$', re.M)  # `## 3`, or `## Ejercicio 3` in some capstones
CLOSING = ['Ejercicios', 'Resumen', 'Temas que se retoman', 'Referencias']
LAST_PAGE_ONLY = ('Resumen', 'Temas que se retoman')
NAV = (examples.ROOT / 'mkdocs.yml').read_text(encoding='utf-8')
NAV = NAV[NAV.index('\nnav:') :]
NAV_ENTRY = re.compile(r'^\s*-\s(?:.*\s)?"?(\S+?\.md)"?\s*$', re.M)


def without_fences(text: str) -> str:
    """The page with its fenced blocks blanked out, so a `## ` inside code is not a heading."""
    return FENCE.sub(lambda block: '\n' * block.group(0).count('\n'), text)


def nav_pages(folder: str) -> list[str]:
    """The file names of one chapter's pages, in the order of the nav."""
    return [entry.split('/', 1)[1] for entry in NAV_ENTRY.findall(NAV) if entry.startswith(folder + '/')]


def exercise_numbers(text: str) -> list[int]:
    """The numbers of the top-level items of the page's `## Ejercicios` section."""
    _, found, rest = text.partition('\n## Ejercicios\n')
    if not found:
        return []
    following = H2.search(rest)
    return [int(n) for n in ITEM.findall(rest[: following.start()] if following else rest)]


def closing_order(name: str, text: str) -> list[str]:
    """The complaints about the order of the closing sections of one page."""
    bad, seen = [], []
    for heading in H2.findall(text):
        if heading in CLOSING:
            if heading in seen:
                bad.append(f'{name}: «{heading}» twice')
            elif seen and CLOSING.index(heading) < CLOSING.index(seen[-1]):
                bad.append(f'{name}: «{heading}» after «{seen[-1]}»')
            seen.append(heading)
        elif seen:
            bad.append(f'{name}: «{heading}» after the closing section «{seen[-1]}»')
    return bad


def check(directory) -> list[str]:
    """The complaints about one chapter."""
    chapter = int(examples.CHAPTER_DIR.match(directory.name).group(1))
    names = nav_pages(directory.name)
    on_disk = sorted(page.name for page in directory.glob('*.md'))
    bad = [f'{name}: not in the nav' for name in on_disk if name not in names]
    if not names or names[0] != 'index.md' or names[-1] != 'soluciones.md':
        bad.append(f'the nav lists {names}: index.md must come first and soluciones.md last')
        return bad
    pages = {name: without_fences((directory / name).read_text(encoding='utf-8')) for name in names[:-1]}
    for name, text in pages.items():
        bad += closing_order(name, text)

    sections, last = [], 'index.md'
    for name, text in pages.items():
        for heading in H2.findall(text):
            if m := SECTION.match(heading):
                number = (int(m.group(1)), int(m.group(2)))
                if number[0] != chapter:
                    bad.append(f'{name}: section {heading!r} does not belong to chapter {chapter}')
                elif sections and number <= sections[-1][0]:
                    bad.append(f'{name}: section {number[0]}.{number[1]} after {sections[-1][1]}')
                sections.append((number, f'{number[0]}.{number[1]} on {name}'))
                last = name
    for heading in LAST_PAGE_ONLY:
        for name, text in pages.items():
            if name != last and f'\n## {heading}\n' in text:
                bad.append(f'{name}: «{heading}» belongs on {last}, the last page of the chapter')

    numbers = [n for text in pages.values() for n in exercise_numbers(text)]
    if numbers != list(range(1, len(numbers) + 1)):
        bad.append(f'the exercises are numbered {numbers}, not 1 to {len(numbers)} across the pages')
    answers = without_fences((directory / 'soluciones.md').read_text(encoding='utf-8'))
    solutions = [int(n) for n in SOLUTION.findall(answers)]
    if numbers and solutions != list(range(1, len(numbers) + 1)):
        bad.append(f'soluciones.md has the headings {solutions}, not 1 to {len(numbers)}')
    return bad


def main() -> int:
    wanted = [name for name in sys.argv[1:] if not name.startswith('-')]
    failed = 0
    chapters = [
        d
        for d in sorted(examples.DOCS.glob('capitulo-*'))
        if examples.is_written(d) and (not wanted or any(name in d.name for name in wanted))
    ]
    for directory in chapters:
        bad = check(directory)
        if bad:
            failed += 1
            print(f'  {directory.name}')
            for complaint in bad:
                print(f'      {complaint}')
    if failed:
        print(f'{failed} of {len(chapters)} chapters break the page rules.')
        return 1
    print(f'{len(chapters)} chapters follow the page rules.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
