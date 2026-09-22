#!/usr/bin/env python
"""Keep the code blocks of the text equal to the files under `ejemplos/`.

The files under `ejemplos/` are the source of truth: they are loaded and tested
by `make examples`. The text does not repeat that code by hand, it declares it
with a marker, and this copies it in.

A marker is an HTML comment right above a fenced block. It is written in
Spanish, like everything else the author writes in `docs/`:

    <!-- ejemplo: capitulo-01/familia.pl predicado: abuelo/2 -->
    ```prolog
    ...what this tool writes...
    ```

The pieces a marker can ask for:

    archivo                  the whole file, without its header block
    predicado: padre/2       every clause of that predicate, with its comments
    predicado: padre/2 abuelo/2   several, in that order
    fragmento: A .. B        the lines from the first containing A to the one containing B

Any piece takes a trailing `aviso: texto`, which opens the block with that text
as a comment. It is for code shown in order to criticise it:

    <!-- ejemplo: capitulo-09/corte.pl predicado: maximo/3 aviso: MAL: el corte cambia el significado -->

    ./tools/sync-examples.py             report where text and files differ
    ./tools/sync-examples.py --write     rewrite the blocks from the files

Exits 1 when they differ (with --write, when something could not be resolved).
"""

import difflib
import sys
from pathlib import Path

import examples


def piece_of(source, piece):
    what, _, value = (x.strip() for x in piece.partition(':'))
    if not what or what == 'archivo':
        return examples.without_header(source)
    if what == 'predicado':
        return examples.predicate(source, value)
    if what == 'fragmento':
        return examples.excerpt(source, value)
    raise KeyError(f'unknown piece {what!r} (try archivo, predicado or fragmento)')


def expected(marker):
    path = examples.EXAMPLES / marker.group('file')
    if not path.exists():
        raise FileNotFoundError(path.relative_to(examples.ROOT).as_posix())
    parts = examples.marker_parts(marker.group('piece'))
    code = piece_of(path.read_text(encoding='utf-8'), parts['pieza'])
    return f'% {parts["aviso"]}\n{code}' if parts['aviso'] else code


def process(path, write):
    text = path.read_text(encoding='utf-8')
    trouble, in_sync, rewritten = [], 0, 0
    out, end_of_previous = [], 0
    for marker in examples.MARKER.finditer(text):
        try:
            wanted = expected(marker) + '\n'
        except Exception as e:  # noqa: BLE001
            trouble.append('{}: {}'.format(marker.group('file'), e))
            continue
        current = marker.group('body')
        if current == wanted:
            in_sync += 1
            continue
        if write:
            out.append(text[end_of_previous : marker.start('body')])
            out.append(wanted)
            end_of_previous = marker.end('body')
            rewritten += 1
        else:
            diff = list(
                difflib.unified_diff(
                    current.splitlines(), wanted.splitlines(), 'the text', 'the file', lineterm='', n=1
                )
            )
            changed = len([d for d in diff if d[:1] in '+-'])
            piece = marker.group('piece') or 'archivo'
            shown = '\n      '.join(diff[2:10])
            trouble.append(f'{marker.group("file")} ({piece}): {changed} lines differ\n      {shown}')
    if write and rewritten:
        out.append(text[end_of_previous:])
        path.write_text(''.join(out), encoding='utf-8')

    total = in_sync + rewritten + len(trouble)
    if total:
        state = f'{in_sync} blocks in sync'
        if rewritten:
            state += f', {rewritten} rewritten'
        if trouble:
            state += f', {len(trouble)} with trouble'
        where = path.relative_to(examples.DOCS).as_posix()
        print(f'{where:<40} {state}')
    for problem in trouble:
        print(f'    {problem}')
    return total, not trouble


def wanted(argv):
    """The pages to process: the ones named on the command line, or all of them.

    Naming pages matters when more than one person is writing at once: a global
    run rewrites every chapter's blocks from its example files, which is right
    when you are the only author and wrong when somebody else is mid-edit
    somewhere else in the book.
    """
    named = [Path(a).resolve() for a in argv if not a.startswith('-')]
    if not named:
        return sorted(examples.DOCS.rglob('*.md'))
    pages = []
    for path in named:
        if path.is_dir():
            pages += sorted(path.rglob('*.md'))
        else:
            pages.append(path)
    return pages


def main():
    write = '--write' in sys.argv
    if not examples.DOCS.is_dir():
        print(f'There is no {examples.DOCS} yet.', file=sys.stderr)
        return 1
    total, all_good = 0, True
    for path in wanted(sys.argv[1:]):
        counted, ok = process(path, write)
        total += counted
        all_good = all_good and ok
    if total == 0:
        print('No block carries an example marker.')
    print(
        'Text and examples agree.'
        if all_good
        else 'The text does not match the examples (run with --write to copy them in).'
    )
    return 0 if all_good else 1


if __name__ == '__main__':
    sys.exit(main())
