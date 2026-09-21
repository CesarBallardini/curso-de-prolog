#!/usr/bin/env python
"""Check that part I never uses what part I has not taught yet.

Chapters 1 to 11 go as far as the cut, negation as failure and derivation trees,
and do everything with facts, rules, unification, recursion and lists. No
higher-order predicates and no dynamic database: those start in part II, and an
example that jumps ahead leaves the student looking at something the text has
not explained.

It reads the `.pl` and `.plt` files of `ejemplos/capitulo-01/` to `capitulo-11/`,
and the prolog code blocks of chapters 1 to 11 under `docs/`, solutions included.

    ./tools/check-part-1.py

Exits 1 if anything in part I uses a predicate from part II.
"""

import re
import sys

import examples

# The forbidden predicate, and the chapter where the book introduces it, which is
# what whoever sees this check fail needs to be told.
FORBIDDEN = {
    'findall': 15,
    'bagof': 15,
    'setof': 15,
    'aggregate_all': 15,
    'forall': 15,
    'maplist': 16,
    'foldl': 16,
    'include': 16,
    'exclude': 16,
    'partition': 16,
    'convlist': 16,
    'call': 16,
    'apply': 16,
    'assert': 17,
    'asserta': 17,
    'assertz': 17,
    'retract': 17,
    'retractall': 17,
    'abolish': 17,
    'nb_setval': 17,
    'nb_getval': 17,
    'b_setval': 17,
    'b_getval': 17,
}

CALL = re.compile(r'\b({})\s*\('.format('|'.join(sorted(FORBIDDEN))))
CODE_BLOCK = re.compile(r'^```prolog\n(?P<code>.*?)^```', re.M | re.S)
CHAPTER_DOC = re.compile(r'^capitulo-(\d+)')


def findings(code, offset=0):
    """The (line, predicate) pairs forbidden in part I that this code contains."""
    clean = examples.without_comments(code)
    return [(clean[: m.start()].count('\n') + 1 + offset, m.group(1)) for m in CALL.finditer(clean)]


def in_examples():
    found = []
    for example in examples.all_examples():
        if not example.in_part_1:
            continue
        for path in (example.path, example.tests):
            if not path.exists():
                continue
            found += [(path, line, name) for line, name in findings(path.read_text(encoding='utf-8'))]
    return found


def in_text():
    """The code blocks of chapters 1 to 11, solutions included."""
    found = []
    if not examples.DOCS.is_dir():
        return found
    for path in sorted(examples.DOCS.rglob('*.md')):
        chapter = CHAPTER_DOC.match(path.parent.name)
        if not chapter or int(chapter.group(1)) > examples.LAST_OF_PART_1:
            continue
        text = path.read_text(encoding='utf-8')
        for block in CODE_BLOCK.finditer(text):
            before = text[: block.start('code')].count('\n')
            found += [(path, line, name) for line, name in findings(block.group('code'), before)]
    return found


def main():
    found = in_examples() + in_text()
    for path, line, name in found:
        where = path.relative_to(examples.ROOT).as_posix()
        print(f'{where}:{line}: {name} belongs to part II (chapter {FORBIDDEN[name]})')
    if found:
        print(
            '\nPart I goes as far as the cut and negation as failure: no higher-order predicates, no dynamic database.'
        )
        return 1
    print('Part I does not jump ahead to part II.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
