#!/usr/bin/env python
"""Load every example under `ejemplos/` with its `.plt` and run its plunit tests.

    ./tools/run-examples.py                 all of them
    ./tools/run-examples.py familia         one, by name
    ./tools/run-examples.py capitulo-01     a whole chapter

The `.pl` and the `.plt` are loaded together with `consult/1`. Passing the `.plt`
as a file on the command line does not load it ("No tests to run"), and calling
`load_test_files/1` after a script load leaves the test unit unable to see the
program's predicates ("Unknown procedure plunit_ej:...").

A source that fails to load does not make `run_tests` fail: plunit counts the
tests of a unit that never compiled as passed, and `swipl` exits 0. So the exit
status is not enough here, and any `ERROR:` in the output counts as a failure.
So does any `Warning:`, which is where singleton variables show up, and tests
that leave a choice point without declaring themselves `nondet`: in a book those
are defects of the example, not noise.

Exits 1 if anything fails.
"""

import re
import shutil
import subprocess
import sys

import examples

LIMIT = 120  # seconds per example
PASSED = re.compile(r'(?:All )?(\d+) tests passed')
TROUBLE = re.compile(r'^(ERROR|Warning):', re.M)


def goal(example):
    files = ','.join(f"'{path.as_posix()}'" for path in (example.path, example.tests))
    return f'consult([{files}]),run_tests'


def run(swipl, example):
    if not example.tests.exists():
        return False, f'has no {example.tests.name}'
    try:
        done = subprocess.run(  # noqa: S603
            [swipl, '-g', goal(example), '-t', 'halt'], capture_output=True, text=True, errors='replace', timeout=LIMIT
        )
    except subprocess.TimeoutExpired:
        # A program that does not terminate leaves swipl waiting at the debugger
        # prompt: the limit is the only thing telling "hung" from "slow" apart.
        return False, f'did not finish in {LIMIT} seconds (endless search?)'
    output = done.stdout + done.stderr
    if done.returncode != 0 or TROUBLE.search(output):
        return False, '\n'.join([line for line in output.splitlines() if line.strip()][:12])
    how_many = PASSED.search(output)
    return True, '%s tests, all green' % (how_many.group(1) if how_many else '?')


def main():
    swipl = shutil.which('swipl')
    if swipl is None:
        print('swipl is not on the PATH.', file=sys.stderr)
        return 1
    wanted = [a for a in sys.argv[1:] if not a.startswith('-')]
    found = examples.all_examples(wanted)
    if not found:
        print('No examples to run%s' % (' by that name' if wanted else ''), file=sys.stderr)
        return 1
    width = max(len(e.relative) for e in found)
    failed = []
    for example in found:
        ok, detail = run(swipl, example)
        shown = detail if ok else 'FAILS'
        print(f'{example.relative:<{width}} {shown}')
        if not ok:
            print('    {}'.format(detail.replace('\n', '\n    ')))
            failed.append(example.relative)
    print('All green.' if not failed else 'Failed: {}'.format(', '.join(failed)))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
