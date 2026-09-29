#!/usr/bin/env python
"""Run the XPCE window tests of the examples under `swipl-win`.

    ./tools/run-windows.py                 every example that loads library(pce)
    ./tools/run-windows.py capitulo-36     one chapter, or one example by name

`make test` runs every example under the console `swipl`, which on Windows has
no XPCE: there the window tests of chapter 36 carry `condition(hay_xpce)` and
plunit skips them. This runs the same `.pl` and `.plt` under `swipl-win`, where
XPCE is loaded, so those tests run too. The windows are created and queried but
never opened, so nothing appears on the screen.

`swipl-win` has no standard output a shell can read: `run-windows.pl` writes the
test report to a file, which is read back here. As in `run-examples.py`, any
`ERROR:` or `Warning:` in the report is a failure.

Local only: CI runs `swipl` without XPCE, and has no `swipl-win`.
Exits 1 if anything fails, and 2 if `swipl-win` is not on the PATH.
"""

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import examples

LIMIT = 120  # seconds per example
RUNNER = Path(__file__).resolve().with_name('run-windows.pl')
PASSED = re.compile(r'(?:All )?(?:(\d+) (?:\(\+\d+ sub-tests\) )?tests|test) passed')
TROUBLE = re.compile(r'^(ERROR|Warning):', re.M)


def loads_xpce(example: examples.Example) -> bool:
    return 'library(pce)' in example.source and example.tests.exists()


def run(swipl_win: str, example: examples.Example, report: Path) -> tuple[bool, str]:
    arguments = [RUNNER.as_posix(), '--', example.path.as_posix(), example.tests.as_posix(), report.as_posix()]
    try:
        subprocess.run([swipl_win, *arguments], timeout=LIMIT, check=False)  # noqa: S603
    except subprocess.TimeoutExpired:
        # A load error leaves swipl-win open at its toplevel window.
        return False, f'did not finish in {LIMIT} seconds'
    if not report.exists():
        return False, 'wrote no report'
    output = report.read_text(encoding='utf-8', errors='replace')
    if 'RESULT ok' not in output or TROUBLE.search(output):
        return False, '\n'.join([line for line in output.splitlines() if line.strip()][:12])
    how_many = PASSED.search(output)
    count = (how_many.group(1) or '1') if how_many else '?'
    return True, f'{count} tests, all green'


def main() -> int:
    swipl_win = shutil.which('swipl-win')
    if swipl_win is None:
        print('swipl-win is not on the PATH: the window tests need it (Windows only).', file=sys.stderr)
        return 2
    wanted = [a for a in sys.argv[1:] if not a.startswith('-')]
    found = [e for e in examples.all_examples(wanted) if loads_xpce(e)]
    if not found:
        print('No example loads library(pce)%s' % (' by that name' if wanted else ''), file=sys.stderr)
        return 1
    width = max(len(e.relative) for e in found)
    failed = []
    with tempfile.TemporaryDirectory() as folder:
        for number, example in enumerate(found):
            ok, detail = run(swipl_win, example, Path(folder) / f'report-{number}.txt')
            print(f'{example.relative:<{width}} {detail if ok else "FAILS"}')
            if not ok:
                print('    {}'.format(detail.replace('\n', '\n    ')))
                failed.append(example.relative)
    print('All green.' if not failed else 'Failed: {}'.format(', '.join(failed)))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
