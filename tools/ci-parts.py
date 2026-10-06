# /// script
# requires-python = ">=3.14"
# dependencies = []
# ///
"""Decide which chapters, and so which parts of the book, a change asks CI to check.

    uv run tools/ci-parts.py BASE                 what changed between BASE and HEAD
    uv run tools/ci-parts.py --all                every chapter
    uv run tools/ci-parts.py --files F1 F2 ...    as if these files had changed (for trying it out)
    uv run tools/ci-parts.py -v ...               list the dependencies found, too

BASE is a ref or a sha; the changed files are those of `git diff --name-only
BASE...HEAD`. A BASE of all zeros (the push that creates a branch) or one that
git cannot find (a force push, a shallow clone) means every chapter: when in
doubt, check everything.

A changed file selects:

- its chapter, when it is `docs/capitulo-NN-*/...`, `ejemplos/capitulo-NN/...`,
  `diapositivas/capitulo-NN.*` or `diapositivas/imagenes/capitulo-NN/...` (the
  decks' transcripts run in `make transcripts` too);
- every chapter, when it is something the checks themselves run on: `tools/`,
  `.github/`, the `Makefile`, `pyproject.toml`, `uv.lock` or `ruff.toml`;
- nothing otherwise (`docs/licencia.md`, `mkdocs.yml`, `README.md`, `books/`,
  `references/`...): no example, test or transcript reads them.

Then every chapter that depends on a selected one, directly or through others,
is selected too. The dependencies are read from the sources on every run, so
there is no table to keep up to date: chapter MM depends on chapter NN when a
file under `ejemplos/capitulo-MM/` names `capitulo-NN` (a `use_module` of
`'../../capitulo-31/inscripciones/datos'`, a file it reads), or when a page of
`docs/capitulo-MM-*/` or the deck `diapositivas/capitulo-MM.md` runs its code
or its transcripts against `capitulo-NN` (an `<!-- ejemplo: -->` or
`<!-- contexto: -->` marker, or an `ejemplos/capitulo-NN` path).

The output is the parts of the book that hold a selected chapter, each with
its list of chapters. The tools behind `make test`, `make transcripts` and
`make swish` take that list as it is (`make test e="capitulo-42 capitulo-43"`):
test and swish match a whole directory name, transcripts a substring of it,
which is why the names always carry both digits (`capitulo-4` would also select
40 to 49). Under GitHub Actions ($GITHUB_OUTPUT set) it writes:

- `matrix`: `{"include": [{"parte": "III", "capitulos": "capitulo-42"}, ...]}`
- `capitulos`: every selected chapter, in one list
- `python`: `true` when chapter 29, 30, 31 or 36 is selected (`make appendix`)
- `any`: `true` when at least one chapter is selected
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# The four parts of the book, by their first chapter.
PARTS = [('I', 1), ('II', 13), ('III', 32), ('IV', 43)]
# The pytest suites of `make appendix`.
PYTHON_CHAPTERS = {29, 30, 31, 36}

# What the checks run on: a change here can change any result.
SHARED_DIRS = ('tools/', '.github/')
SHARED_FILES = {'Makefile', 'pyproject.toml', 'uv.lock', 'ruff.toml'}

CHANGED_CHAPTER = re.compile(
    r'^(?:docs/capitulo-(\d+)-[^/]*/'
    r'|ejemplos/capitulo-(\d+)/'
    r'|diapositivas/capitulo-(\d+)\.'
    r'|diapositivas/imagenes/capitulo-(\d+)/)'
)
# In an example: any mention of another chapter's directory is a path into it.
IN_EXAMPLE = re.compile(r'capitulo-(\d+)')
# In a page or a deck: the files its code blocks and transcripts run against.
IN_PAGE = re.compile(r'<!-- (?:ejemplo|contexto): capitulo-(\d+)|ejemplos/capitulo-(\d+)')


def chapters() -> set[int]:
    """Every chapter the book has, from docs/ and ejemplos/."""
    found = set()
    for folder in ('docs', 'ejemplos'):
        for path in (ROOT / folder).glob('capitulo-*'):
            number = re.match(r'capitulo-(\d+)', path.name)
            if number and path.is_dir():
                found.add(int(number.group(1)))
    return found


def name(chapter: int) -> str:
    return f'capitulo-{chapter:02d}'


def part(chapter: int) -> str:
    return [label for label, first in PARTS if chapter >= first][-1]


def read(path: Path) -> str:
    try:
        return path.read_text(encoding='utf-8')
    except UnicodeDecodeError, OSError:
        return ''  # a binary file names nothing


def dependencies(known: set[int]) -> dict[int, set[int]]:
    """For each chapter, the other chapters it depends on."""
    depends: dict[int, set[int]] = {chapter: set() for chapter in known}
    for chapter in known:
        sources = [(p, IN_EXAMPLE) for p in (ROOT / 'ejemplos' / name(chapter)).rglob('*') if p.is_file()]
        for folder in (ROOT / 'docs').glob(f'{name(chapter)}-*'):
            sources += [(p, IN_PAGE) for p in folder.glob('*.md')]
        sources += [(p, IN_PAGE) for p in (ROOT / 'diapositivas').glob(f'{name(chapter)}.md')]
        for path, pattern in sources:
            for match in pattern.finditer(read(path)):
                other = int(next(g for g in match.groups() if g))
                if other != chapter and other in known:
                    depends[chapter].add(other)
    return depends


def dependents(changed: set[int], depends: dict[int, set[int]]) -> set[int]:
    """The changed chapters and every chapter that depends on one of them, at any distance."""
    selected = set(changed)
    grew = True
    while grew:
        grew = False
        for chapter, needs in depends.items():
            if chapter not in selected and needs & selected:
                selected.add(chapter)
                grew = True
    return selected


def changed_files(base: str) -> list[str] | None:
    """The files changed between BASE and HEAD, or None when that cannot be told."""
    if not base or set(base) == {'0'}:
        return None
    done = subprocess.run(  # noqa: S603
        ['git', 'diff', '--name-only', f'{base}...HEAD'],  # noqa: S607
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    if done.returncode != 0:
        print(f'git diff {base}...HEAD failed, checking everything:\n{done.stderr.strip()}')
        return None
    return done.stdout.split()


def select(files: list[str] | None, known: set[int]) -> tuple[set[int], str]:
    """The chapters the files select directly, and why."""
    if files is None:
        return set(known), '--all, or a base that cannot be compared'
    shared = [f for f in files if f.startswith(SHARED_DIRS) or f in SHARED_FILES]
    if shared:
        return set(known), f'shared file {shared[0]}'
    direct = set()
    for path in files:
        match = CHANGED_CHAPTER.match(path)
        if match:
            direct.add(int(next(g for g in match.groups() if g)))
    return direct & known, f'{len(files)} changed file(s)'


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('base', nargs='?', help='ref or sha to compare HEAD with')
    parser.add_argument('--all', action='store_true', help='select every chapter')
    parser.add_argument('--files', nargs='+', metavar='FILE', help='pretend these files changed')
    parser.add_argument('-v', '--verbose', action='store_true', help='list every dependency found')
    args = parser.parse_args()

    known = chapters()
    if args.all:
        files = None
    elif args.files is not None:
        files = args.files
    elif args.base:
        files = changed_files(args.base)
    else:
        parser.error('give a BASE, --all or --files')

    depends = dependencies(known)
    direct, reason = select(files, known)
    selected = dependents(direct, depends)

    by_part: dict[str, list[str]] = {}
    for chapter in sorted(selected):
        by_part.setdefault(part(chapter), []).append(name(chapter))
    matrix = {'include': [{'parte': p, 'capitulos': ' '.join(c)} for p, c in by_part.items()]}
    flags = {
        'python': 'true' if selected & PYTHON_CHAPTERS else 'false',
        'any': 'true' if selected else 'false',
    }

    print(f'{sum(len(n) for n in depends.values())} dependencies between {len(known)} chapters.')
    if args.verbose:
        for chapter, needs in sorted(depends.items()):
            if needs:
                print(f'  {name(chapter)} depends on {" ".join(name(n) for n in sorted(needs))}')
    if direct == known:
        print(f'Selected by {reason}: all {len(known)} chapters.')
    else:
        print(f'Selected by {reason}: {", ".join(name(c) for c in sorted(direct)) or "none"}.')
    if selected - direct:
        print(f'Depending on them: {", ".join(name(c) for c in sorted(selected - direct))}.')
    for parte, names in by_part.items():
        print(f'  Parte {parte}: {" ".join(names)}')
    if not by_part:
        print('  No part to check.')
    print(f'  python={flags["python"]} any={flags["any"]}')

    output = os.environ.get('GITHUB_OUTPUT')
    if output:
        with open(output, 'a', encoding='utf-8') as out:
            out.write(f'matrix={json.dumps(matrix)}\n')
            out.write(f'capitulos={" ".join(name(c) for c in sorted(selected))}\n')
            for key, value in flags.items():
                out.write(f'{key}={value}\n')
    return 0


if __name__ == '__main__':
    sys.exit(main())
