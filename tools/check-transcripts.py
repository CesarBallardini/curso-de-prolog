#!/usr/bin/env python
"""Run every transcript of the book against SWI-Prolog and compare the answers.

    ./tools/check-transcripts.py                  every chapter of part I
    ./tools/check-transcripts.py capitulo-07      one chapter
    ./tools/check-transcripts.py -v               list the transcripts that pass too

A transcript is a fenced block holding a query and the answers the book claims
for it:

    ?- padre(juan, Quien).
    Quien = ana ;
    Quien = pedro.

Two things are compared, and they are the two the reader can check: how many
answers the query has, and whether the last one ends in a full stop or in
`false.`. That distinction is not cosmetic -- the book teaches in chapter 1 that
a full stop means no alternatives are left -- and it is exactly what goes stale
when an example program grows a clause.

The answers themselves are not compared textually: the toplevel's layout of
bindings is its own business, and reproducing it here would report differences
that are not mistakes.

Each query runs against the example file named by the nearest `<!-- ejemplo: -->`
marker above it, which is the program the section is talking about. A query that
needs something that file does not define is reported as skipped, not as a
failure.

Exits 1 if any transcript disagrees with the interpreter.
"""

import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from typing import TYPE_CHECKING

import examples

if TYPE_CHECKING:
    from pathlib import Path

LIMIT = 15  # seconds per query
PROBE = examples.ROOT / 'tools' / 'transcript-probe.pl'

FENCE = re.compile(r'^```(\w*)\s*$')
MARKER_LINE = re.compile(r'^<!-- ejemplo: (?P<file>[\w./-]+)')
PROMPT = re.compile(r'^\?-\s*(?P<query>.*)$')

COUNT = re.compile(r'^COUNT (\d+)$', re.M)
DET = re.compile(r'^DET (true|false)$', re.M)
ERROR = re.compile(r'^ERROR (.+)$', re.M)
UNKNOWN = re.compile(r'existence_error\(procedure')


@dataclass
class Transcript:
    page: Path
    line: int
    context: Path | None
    query: str
    answers: list[tuple[str, str]]  # (text, terminator) with terminator in ';.'
    raises: bool
    truncated: bool = False  # the block ends in `...`: some answers, deliberately not all
    staged: bool = False  # shows the state before the program is loaded

    @property
    def partial(self) -> bool:
        """The block shows some answers and not all of them."""
        return self.truncated or (bool(self.answers) and self.answers[-1][1] == ';')

    @property
    def expected(self) -> tuple[int, bool | None]:
        """How many answers the book claims, and whether the last one ends in a full stop."""
        answers = self.answers
        if answers and answers[-1][0] == 'false' and len(answers) > 1:
            return len(answers) - 1, False
        if len(answers) == 1 and answers[0][0] == 'false':
            return 0, True
        if self.partial:
            return len(answers), None
        return len(answers), True


def transcripts(page: Path) -> list[Transcript]:
    """Every query block of one page, with the example file its section is about."""
    found: list[Transcript] = []
    context: Path | None = None
    inside = False
    block: list[str] = []
    start = 0

    for number, text in enumerate(page.read_text(encoding='utf-8').splitlines(), start=1):
        marker = MARKER_LINE.match(text)
        if marker:
            context = examples.EXAMPLES / marker.group('file')
            continue
        fence = FENCE.match(text)
        if fence and not inside:
            inside, block, start = True, [], number
            continue
        if fence and inside:
            found.extend(split(block, page, start, context))
            inside = False
            continue
        if inside:
            block.append(text)
    return found


def split(block: list[str], page: Path, start: int, context: Path | None) -> list[Transcript]:
    """One block may hold several `?- ...` queries, each with its own answers."""
    found: list[Transcript] = []
    current: Transcript | None = None

    for offset, text in enumerate(block):
        prompt = PROMPT.match(text.strip())
        if prompt:
            current = Transcript(page, start + offset + 1, context, prompt.group('query'), [], raises=False)
            found.append(current)
            continue
        if current is None:
            continue
        stripped = text.strip()
        if not stripped:
            continue
        if stripped.startswith(('ERROR:', 'Warning:')):
            current.raises = True
            # A block that shows Prolog complaining about an undefined predicate
            # is demonstrating what happens *before* the program is loaded, so
            # running it against the loaded program proves nothing.
            if 'Unknown procedure' in stripped or 'Unknown predicate' in stripped:
                current.staged = True
            continue
        if stripped in {'...', '…'}:
            current.truncated = True
            continue
        if stripped.endswith(';'):
            current.answers.append((stripped[:-1].strip().rstrip(','), ';'))
        elif stripped.endswith('.'):
            current.answers.append((stripped[:-1].strip().rstrip(','), '.'))
        # a binding that spills over several lines contributes its last line only,
        # which is the one carrying the terminator
    return [item for item in found if item.answers or item.raises]


def candidates(item: Transcript) -> list[list[Path]]:
    """The example files to try, best guess first.

    The marker above the section names the program being discussed, and that is
    almost always the right context. A solutions page whose first answers come
    before any marker falls back to the chapter's own `soluciones.pl`, and the
    last resort is every example of the chapter at once -- good enough to check
    a count, and reported as such when two files define the same predicate.
    """
    tries: list[list[Path]] = []
    if item.context and item.context.exists():
        tries.append([item.context])

    chapter = examples.CHAPTER_DIR.match(item.page.parent.name)
    if not chapter:
        return tries
    folder = examples.EXAMPLES / f'capitulo-{chapter.group(1)}'
    if not folder.is_dir():
        return tries

    solutions = folder / 'soluciones.pl'
    if item.page.name == 'soluciones.md' and solutions.exists() and [solutions] not in tries:
        tries.append([solutions])

    # `soluciones.pl` restates the chapter's data to stand on its own, so loading
    # it beside the chapter's own examples doubles predicates like `gusta/2` and
    # invents answers. The wide fallback therefore leaves it out, except on the
    # solutions page, where it is the subject.
    wide = [path for path in sorted(folder.glob('*.pl')) if path != solutions or item.page.name == 'soluciones.md']
    if wide and wide not in tries:
        tries.append(wide)
    return tries


#  Queries that act on the session rather than on the program: what they print
#  depends on where the reader is sitting, not on the example file.
ENVIRONMENT = re.compile(r'^\s*(consult|halt|listing|trace|notrace|edit|make)\b')


def ask(swipl: str, item: Transcript) -> tuple[str, str]:
    """Run one query against each candidate context until one of them defines it."""
    if item.staged:
        return 'skip', 'shows the state before the program is loaded'
    if ENVIRONMENT.match(item.query):
        return 'skip', 'acts on the session, not on the program'
    outcome, detail = 'skip', 'no example file for this chapter'
    for files in candidates(item) or [[]]:
        outcome, detail = run_once(swipl, item, files)
        if not (outcome == 'skip' and detail.startswith('needs a predicate')):
            return outcome, detail
    return outcome, detail


def run_once(swipl: str, item: Transcript, context: list[Path]) -> tuple[str, str]:
    """Run one query; returns (outcome, detail)."""
    query = item.query.rstrip().rstrip('.')
    files = [str(PROBE)] + [str(path) for path in context]
    try:
        # A small stack, so that the one endless generator the book shows,
        # `natural(N)`, runs out of it in about a second instead of filling the
        # default gigabyte, which took most of LIMIT on this machine and more
        # than that on the CI runner. No query the book prints needs anything
        # like 64 MB.
        done = subprocess.run(  # noqa: S603
            [swipl, '-q', '--stack-limit=64m', '-g', f'probe(({query}))', '-t', 'halt', *files],
            capture_output=True,
            text=True,
            errors='replace',
            timeout=LIMIT,
        )
    except subprocess.TimeoutExpired:
        # Counted as a failure, not as a skip. No query the book prints should
        # take this long: the one endless generator it shows, `natural(N)`, runs
        # out of the small stack above and is recognised by its error. Treating
        # a timeout as a skip made the run flaky -- one slow query under load silently lowered
        # the count of checked transcripts, which is exactly how a real failure
        # would hide.
        return 'bad', f'did not finish in {LIMIT}s'

    output = done.stdout + done.stderr
    if UNKNOWN.search(output):
        return 'skip', 'needs a predicate the example file does not define'

    error = ERROR.search(output)
    count, det = COUNT.search(output), DET.search(output)
    if not count or not det:
        return 'skip', (output.strip().splitlines() or ['no answer from the probe'])[0]

    actual_count, actual_det = int(count.group(1)), det.group(1) == 'true'

    if item.raises:
        return ('ok', 'raises') if error else ('bad', 'the book shows an error, the query does not raise one')
    if error:
        # A block that ends in `...` over a generator the book calls endless is
        # right to stop there; the interpreter runs out of stack, as it should.
        if item.truncated and 'resource_error' in error.group(1):
            return 'ok', 'endless, as the book says'
        return 'bad', f'the query raises {error.group(1)}, the book shows answers'

    wanted_count, wanted_det = item.expected
    if item.partial:
        if actual_count < wanted_count:
            return 'bad', f'shows {wanted_count} answers, there are {actual_count}'
        return 'ok', f'{wanted_count} of {actual_count}'
    if actual_count != wanted_count:
        return 'bad', f'shows {wanted_count} answers, there are {actual_count}'
    if wanted_det is not None and actual_det != wanted_det:
        shown = 'a full stop' if wanted_det else '`false.`'
        real = 'no choice point is left' if actual_det else 'a choice point is left'
        return 'bad', f'ends with {shown}, but {real}'
    return 'ok', f'{actual_count} answers'


def pages(wanted: list[str]) -> list[Path]:
    chosen = []
    for directory in sorted(examples.DOCS.glob('capitulo-*')):
        number = examples.CHAPTER_DIR.match(directory.name)
        if not number or int(number.group(1)) > examples.LAST_OF_PART_1:
            continue
        if wanted and not any(name in directory.name for name in wanted):
            continue
        chosen.extend(sorted(directory.glob('*.md')))
    return chosen


def main() -> int:
    swipl = shutil.which('swipl')
    if swipl is None:
        print('swipl is not on PATH', file=sys.stderr)
        return 1

    argv = sys.argv[1:]
    loud = '-v' in argv
    wanted = [name for name in argv if not name.startswith('-')]

    bad, skipped, checked = [], [], 0
    for page in pages(wanted):
        for item in transcripts(page):
            outcome, detail = ask(swipl, item)
            where = f'{page.relative_to(examples.ROOT).as_posix()}:{item.line}'
            if outcome == 'bad':
                bad.append((where, item.query, detail))
            elif outcome == 'skip':
                skipped.append((where, item.query, detail))
            else:
                checked += 1
                if loud:
                    print(f'  ok   {where}  ?- {item.query}  ({detail})')

    if skipped:
        print(f'\n{len(skipped)} transcripts could not be checked:')
        for where, query, detail in skipped:
            print(f'  -    {where}\n       ?- {query}\n       {detail}')

    if bad:
        print(f'\n{len(bad)} transcripts disagree with SWI-Prolog:')
        for where, query, detail in bad:
            print(f'  BAD  {where}\n       ?- {query}\n       {detail}')
        print(f'\n{checked} agree.')
        return 1

    print(f'\n{checked} transcripts agree with SWI-Prolog.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
