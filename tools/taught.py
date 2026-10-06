"""What the book has taught by each chapter, read from the book itself.

A chapter declares what it teaches in two places: its `## Resumen` table (one row per
primitive, with the indicator in backticks: `findall/3`, `phrase//1`, `maplist/2..5`,
`py_call/2,3`) and its numbered section headings. `taught_by()` reads both from every
written chapter and gives, per predicate name, the first chapter that presents it.

Part I is assumed known from chapter 13 on: every name that appears in a prolog code block
of chapters 1 to 12 counts as taught in chapter 12 at the latest.

`in_swi()` asks the local SWI-Prolog which of a set of name/arity pairs are predicates it
knows (system or autoloadable library), so that a data functor like `estado(...)`, or one
like `date(A, M, D)` whose name a predicate of another arity shares, is never mistaken for a
predicate the book forgot to present.
"""

import re
import subprocess
import tempfile
from pathlib import Path

import examples

# `findall/3`, `phrase//1`, and a range such as `maplist/2..5` or `foldl/4..6`.
# A list of arities, `py_call/2,3`, also declares each of them.
INDICATOR = re.compile(r'`([a-z]\w*)(?://|/)(\d+)(?:\.\.\d+|(?:,\d+)+)?`')
ARITY_RANGE = re.compile(
    r'`(?P<name>[a-z]\w*)(?P<slashes>//|/)(?P<low>\d+)(?:\.\.(?P<high>\d+)|(?P<more>(?:,\d+)+))?`'
)
SECTION = re.compile(r'^## \d+\.\d+ ')
RESUMEN = re.compile(r'^## Resumen\s*$')
NEXT_H2 = re.compile(r'^## ')
CODE_BLOCK = re.compile(r'^```prolog\n(?P<code>.*?)^```', re.M | re.S)
# A name followed by `(`, not preceded by a letter, a quote or a dot: `D.put(edad, 42)` is a
# dict method call, not a call to put/2.
CALL = re.compile(r'(?<![\w\'.])([a-z]\w*)\s*\(')


def chapter_pages():
    """(chapter number, index.md) for every written chapter, in order."""
    for index in sorted(examples.DOCS.glob('capitulo-*/index.md')):
        match = examples.CHAPTER_DIR.match(index.parent.name)
        if match and examples.is_written(index.parent):
            yield int(match.group(1)), index


def declaring_lines(index: Path):
    """The lines of a page that declare what it teaches: its Resumen table and section headings."""
    in_resumen = False
    for line in index.read_text(encoding='utf-8').split('\n'):
        if RESUMEN.match(line):
            in_resumen = True
        elif NEXT_H2.match(line):
            in_resumen = False
        if in_resumen or SECTION.match(line):
            yield line


def declared(index: Path) -> set[str]:
    """The predicate names the Resumen table and the section headings of a page name."""
    return {m.group(1) for line in declaring_lines(index) for m in INDICATOR.finditer(line)}


def arities() -> dict[str, set[int]]:
    """{name: the arities the book declares for it}, over every written chapter.

    `maplist/2..5` gives 2 to 5; a non-terminal `phrase//1` gives 1 and, called as a
    predicate, 3. A call with another number of arguments is not that predicate: the option
    `functor(alumno)` of `csv_read_file/3` is not `functor/3`.
    """
    out: dict[str, set[int]] = {}
    for _, index in chapter_pages():
        for line in declaring_lines(index):
            for m in ARITY_RANGE.finditer(line):
                low = int(m.group('low'))
                span = set(range(low, int(m.group('high') or low) + 1))
                span |= {int(a) for a in (m.group('more') or '').split(',') if a}
                if m.group('slashes') == '//':
                    span |= {n + 2 for n in span}
                out.setdefault(m.group('name'), set()).update(span)
    return out


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


def in_swi(calls: set[tuple[str, int | None]], swipl: str = 'swipl') -> set[tuple[str, int | None]]:
    """The subset of (name, arity) pairs that SWI-Prolog knows as system or autoloadable
    predicates; an arity of None (not countable) matches any arity.

    The arity matters: the evaluable function `log(X)` inside `is/2`, the data term
    `date(A, M, D)` and a program's own functor `menu(N, Vista)` share their names with
    library predicates of another arity (`log/2`, `date/1`, `menu/3`), and a compound of
    another arity is another functor. Two more arguments also match, for a non-terminal
    called through phrase/2: `utf8_codes(Cs)` is utf8_codes//1, the predicate utf8_codes/3.
    """
    if not calls:
        return set()
    with tempfile.NamedTemporaryFile('w', suffix='.pl', delete=False, encoding='utf-8') as f:
        f.write(':- initialization(main, main).\n')
        f.write('main :- forall(candidate(N, A), (known(N, A) -> format("~w ~w~n", [N, A]) ; true)).\n')
        f.write('known(N, A) :- ( predicate(N, A) ; integer(A), A2 is A + 2, predicate(N, A2) ), !.\n')
        f.write("predicate(N, A) :- current_predicate(system:N/A) ; '$in_library'(N, A, _).\n")
        for name, arity in sorted(calls, key=lambda c: (c[0], -1 if c[1] is None else c[1])):
            f.write(f"candidate('{name}', {'_' if arity is None else arity}).\n")
        path = f.name
    try:
        out = subprocess.run(  # noqa: S603 -- our own temporary program, no user input
            [swipl, path], capture_output=True, text=True, encoding='utf-8', timeout=120
        )
    finally:
        Path(path).unlink(missing_ok=True)
    found = {tuple(line.split()) for line in out.stdout.split('\n') if line.strip()}
    known = {(name, int(arity)) for name, arity in found}
    return {(n, a) for n, a in calls if (n, a) in known or (a is None and any(k == n for k, _ in known))}
