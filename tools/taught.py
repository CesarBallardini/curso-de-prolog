"""What the book has taught by each chapter, read from the book itself.

A chapter declares what it teaches in two places: its `## Resumen` table (one row per
primitive, with the indicator in backticks: `findall/3`, `phrase//1`) and its numbered
section headings. `taught_by()` reads both from every written chapter and gives, per
predicate name, the first chapter that presents it.

Part I is assumed known from chapter 13 on: every name that appears in a prolog code block
of chapters 1 to 12 counts as taught in chapter 12 at the latest.

`in_swi()` asks the local SWI-Prolog which of a set of names are predicates it knows
(system or autoloadable library), so that a data functor like `estado(...)` is never
mistaken for a predicate the book forgot to present.
"""

import re
import subprocess
import tempfile
from pathlib import Path

import examples

# `findall/3`, `phrase//1`, and a range such as `maplist/2..5` or `foldl/4..6`.
INDICATOR = re.compile(r'`([a-z]\w*)(?://|/)(\d+)(?:\.\.\d+)?`')
SECTION = re.compile(r'^## \d+\.\d+ ')
RESUMEN = re.compile(r'^## Resumen\s*$')
NEXT_H2 = re.compile(r'^## ')
CODE_BLOCK = re.compile(r'^```prolog\n(?P<code>.*?)^```', re.M | re.S)
CALL = re.compile(r'(?<![\w\'])([a-z]\w*)\s*\(')


def chapter_pages():
    """(chapter number, index.md) for every written chapter, in order."""
    for index in sorted(examples.DOCS.glob('capitulo-*/index.md')):
        match = examples.CHAPTER_DIR.match(index.parent.name)
        if match and examples.is_written(index.parent):
            yield int(match.group(1)), index


def declared(index: Path) -> set[str]:
    """The predicate names the Resumen table and the section headings of a page name."""
    names = set()
    in_resumen = False
    for line in index.read_text(encoding='utf-8').split('\n'):
        if RESUMEN.match(line):
            in_resumen = True
        elif NEXT_H2.match(line):
            in_resumen = False
        if in_resumen or SECTION.match(line):
            names |= {m.group(1) for m in INDICATOR.finditer(line)}
    return names


def used_in_part_1() -> set[str]:
    """Every name called or defined in the prolog blocks of chapters 1 to 12."""
    names = set()
    for chapter, index in chapter_pages():
        if chapter > examples.LAST_OF_PART_1:
            continue
        for page in (index, index.with_name('soluciones.md')):
            if not page.exists():
                continue
            for block in CODE_BLOCK.finditer(page.read_text(encoding='utf-8')):
                names |= {m.group(1) for m in CALL.finditer(examples.without_comments(block.group('code')))}
    return names


def taught_by() -> dict[str, int]:
    """{name: first chapter that presents it}; Part I names map to chapter 12 at most."""
    first: dict[str, int] = {}
    for chapter, index in chapter_pages():
        for name in declared(index):
            first.setdefault(name, chapter)
    for name in used_in_part_1():
        first[name] = min(first.get(name, examples.LAST_OF_PART_1), examples.LAST_OF_PART_1)
    return first


def in_swi(names: set[str], swipl: str = 'swipl') -> set[str]:
    """The subset of names that SWI-Prolog knows as system or autoloadable predicates."""
    if not names:
        return set()
    with tempfile.NamedTemporaryFile('w', suffix='.pl', delete=False, encoding='utf-8') as f:
        f.write(':- initialization(main, main).\n')
        f.write('main :- forall(candidate(N), (known(N) -> format("~w~n", [N]) ; true)).\n')
        f.write("known(N) :- ( current_predicate(system:N/_) ; '$in_library'(N, _, _) ), !.\n")
        for name in sorted(names):
            f.write(f"candidate('{name}').\n")
        path = f.name
    try:
        out = subprocess.run(  # noqa: S603 -- our own temporary program, no user input
            [swipl, path], capture_output=True, text=True, encoding='utf-8', timeout=120
        )
    finally:
        Path(path).unlink(missing_ok=True)
    return {line.strip() for line in out.stdout.split('\n') if line.strip()}
