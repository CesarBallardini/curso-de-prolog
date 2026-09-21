#!/usr/bin/env python
"""Check that every example can run in SWISH, without opening SWISH.

SWISH does not run just anything: before running a query it asks
`library(sandbox)` whether the goal, and everything that goal calls, is allowed.
An example that uses `shell/1`, opens a file or starts a thread reaches the book
with a broken link, and nobody finds out until a student clicks it.

This asks the same question, through the same `library(sandbox)`, about every
`%?-` query in the example's header.

An example that cannot run in SWISH (files, threads, user interfaces,
compilation: most of part III) says so in its header and is skipped:

    % solo-local: abre un archivo del disco, que el sandbox de SWISH no permite.

The text then prints "Solo local (swipl)" where the link would go.

    ./tools/check-swish.py                 all of them
    ./tools/check-swish.py capitulo-07     one chapter

Exits 1 if an example that promises SWISH does not pass the sandbox.
"""

import json
import shutil
import subprocess
import sys
from pathlib import Path

import examples

DRIVER = Path(__file__).resolve().parent / 'check-swish.pl'
LIMIT = 60


def goal(example):
    # A Prolog string takes the same escapes as a JSON one, so json.dumps leaves
    # each query ready to paste into the goal.
    queries = ','.join(json.dumps(q.rstrip('.')) for q in example.queries)
    return f"check('{example.path.as_posix()}',[{queries}])"


def check(swipl, example):
    if not examples.declares_encoding(example.source):
        return False, 'is missing its first line,  :- encoding(utf8).'
    if example.local_only:
        return True, f'local only: {example.local_only}'
    if not example.queries:
        # With no query there is no link to test, and the reader would not know
        # what to ask it.
        return False, 'declares no %?- query in its header'
    try:
        done = subprocess.run(  # noqa: S603
            [swipl, '-g', goal(example), '-t', 'halt', str(DRIVER)],
            capture_output=True,
            text=True,
            errors='replace',
            timeout=LIMIT,
        )
    except subprocess.TimeoutExpired:
        return False, f'the sandbox did not answer in {LIMIT} seconds'
    output = (done.stdout + done.stderr).strip()
    head = '\n'.join(output.splitlines()[:10])
    # swipl exits 0 even when a declaration inside check-swish.pl was refused at
    # load time, which would quietly turn this check into a no-op. So any ERROR:
    # in the output is a failure, whatever the exit status says.
    if done.returncode == 0 and 'ERROR:' in output:
        return False, 'check-swish.pl did not load cleanly:\n' + head
    if done.returncode != 0:
        return False, 'the SWISH sandbox rejects it:\n' + head
    return True, f'{len(example.queries)} query(ies) pass the sandbox'


def main():
    swipl = shutil.which('swipl')
    if swipl is None:
        print('swipl is not on the PATH.', file=sys.stderr)
        return 1
    wanted = [a for a in sys.argv[1:] if not a.startswith('-')]
    found = examples.all_examples(wanted)
    if not found:
        print('No examples to check%s' % (' by that name' if wanted else ''), file=sys.stderr)
        return 1
    width = max(len(e.relative) for e in found)
    failed = []
    for example in found:
        ok, detail = check(swipl, example)
        shown = detail if ok else 'FAILS'
        print(f'{example.relative:<{width}} {shown}')
        if not ok:
            print('    {}'.format(detail.replace('\n', '\n    ')))
            failed.append(example.relative)
    print('All of them open in SWISH.' if not failed else 'Failed: {}'.format(', '.join(failed)))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
