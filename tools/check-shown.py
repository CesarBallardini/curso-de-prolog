#!/usr/bin/env python
"""Every predicate a transcript consults is shown on the page, or the page names its file.

A reader reproduces a transcript from the text. When `?- cuantos(N).` answers `N = 3`
because of a fact `invitados([...])` that lives only in `ejemplos/capitulo-07/invitados.pl`,
the page must either show that clause in a code block or name `invitados.pl` in its prose.

For every written chapter page (index.md and soluciones.md), the tool takes the names the
`?-` queries of its transcripts call, keeps the ones that a `.pl` file of the chapter
defines, and reports each one that is neither a clause head in a prolog block of the page
nor defined in a file whose name the page mentions.

    ./tools/check-shown.py [capitulo-07 ...]
"""

import re
import sys

import examples
import taught

FENCE = re.compile(r'^```')
PROMPT = re.compile(r'^\?-\s*(?P<query>.*)$')
CODE_BLOCK = re.compile(r'^```prolog\n(?P<code>.*?)^```', re.M | re.S)


def queried(text: str) -> set[str]:
    """Names called by the `?-` lines of every fenced block of a page."""
    names = set()
    in_block = False
    for line in text.split('\n'):
        if FENCE.match(line):
            in_block = not in_block
            continue
        if in_block:
            match = PROMPT.match(line)
            if match:
                names |= {m.group(1) for m in taught.CALL.finditer(match.group('query'))}
    return names


NECK = re.compile(r':-|-->')


def head_functors(clause: str) -> set[str]:
    """Every functor written in the head of a clause, its own name included.

    A query may pass a data term, like `madre(marta, pedro)` to a grammar whose rule
    `relacion(A, B, madre(A, B)) --> ...` is on the page: the reader sees `madre/2`
    there, as a term, and nothing about it needs another file.
    """
    code = '\n'.join(line for line in clause.split('\n') if not line.lstrip().startswith('%'))
    return {m.group(1) for m in taught.CALL.finditer(NECK.split(code, maxsplit=1)[0])}


def shown(text: str) -> set[str]:
    """Clause names of the prolog blocks of a page, and the functors their heads carry."""
    names = set()
    for block in CODE_BLOCK.finditer(text):
        for clause in examples.clauses(block.group('code')):
            if clause.name:
                names |= {clause.name} | head_functors(clause.text)
    return names


def defined_in_files(chapter: int) -> dict[str, set[str]]:
    """{name: {file names that define it}} over the chapter's .pl files."""
    out: dict[str, set[str]] = {}
    for path in sorted(examples.EXAMPLES.glob(f'capitulo-{chapter:02d}/**/*.pl')):
        for clause in examples.clauses(path.read_text(encoding='utf-8')):
            if clause.name:
                out.setdefault(clause.name, set()).add(path.name)
    return out


def main() -> int:
    wanted = [a for a in sys.argv[1:] if not a.startswith('--')]
    problems = []
    for chapter, index in taught.chapter_pages():
        if wanted and not any(w in index.parent.name for w in wanted):
            continue
        files = defined_in_files(chapter)
        for page in (index, index.with_name('soluciones.md')):
            if not page.exists():
                continue
            text = page.read_text(encoding='utf-8')
            visible = shown(text)
            for name in sorted(queried(text) & set(files)):
                if name in visible or any(f in text for f in files[name]):
                    continue
                where = page.relative_to(examples.ROOT).as_posix()
                problems.append(f'{where}: {name} is consulted but defined only in {", ".join(sorted(files[name]))}')
    for line in problems:
        print(line)
    if problems:
        return 1
    print('Every consulted predicate is shown on its page or its file is named.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
