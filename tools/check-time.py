#!/usr/bin/env python
"""Recompute every chapter's time estimate and report the ones that drifted.

    ./tools/check-time.py                  every chapter of part I
    ./tools/check-time.py capitulo-07      one chapter
    ./tools/check-time.py -v               print the figures of every chapter

Each chapter opens with an `!!! info "Tiempo estimado"` block holding three figures
in h:mm: reading the chapter with its examples and activities, solving the starred
exercises, and solving all of them. They are written by hand, so an exercise added,
removed or re-graded leaves them wrong with nothing to say so.

The model is the one the figures were written from:

    prose        120 words per minute
    code block    10 seconds per line
    activity       5 minutes
    exercise       6, 18 or 35 minutes for difficulty 1, 2 or 3

The figures are published rounded to five minutes, so a difference up to TOLERANCE is
not drift. The two counts the block states -- how many exercises carry a star and how
many there are -- are compared exactly: those are facts, not estimates.

Exits 1 if any chapter disagrees with the model.
"""

import re
import sys
from typing import TYPE_CHECKING

import examples

if TYPE_CHECKING:
    from pathlib import Path

WORDS_PER_MINUTE = 120
CODE_LINES_PER_MINUTE = 6  # ten seconds a line
MINUTES_PER_ACTIVITY = 5
MINUTES_BY_DIFFICULTY = {'1': 6, '2': 18, '3': 35}
TOLERANCE = 5  # minutes; the published figures are rounded to five

# The star is read from the Spanish page, never printed: this console is cp1252.
STAR = '★'
READING = re.compile(r'hacer las actividades: \*\*(\d+):(\d\d) h\*\*')
STARRED = re.compile(rf'Resolver los (\d+) ejercicios marcados con {STAR}: \*\*(\d+):(\d\d) h\*\*')
EVERY = re.compile(r'Resolver los (\d+) ejercicios del final: \*\*(\d+):(\d\d) h\*\*')

FENCE = re.compile(r'^```.*?^```', re.M | re.S)
ACTIVITY = re.compile(r'!!! question "Actividad"')
ITEM = re.compile(r'^\d+\. ', re.M)
DIFFICULTY = re.compile(r'\*\*\((\d)\)\*\*')


def split_fences(text: str) -> tuple[str, int]:
    """The text without its fenced blocks, and how many lines those blocks held."""
    lines = 0
    for block in FENCE.finditer(text):
        lines += block.group(0).count('\n') - 1  # the two fence lines are not read
    return FENCE.sub('', text), lines


def reading_minutes(body: str) -> float:
    """Reading the chapter: its prose, its code blocks and its activities."""
    prose, code_lines = split_fences(body)
    activities = len(ACTIVITY.findall(body))
    return (
        len(prose.split()) / WORDS_PER_MINUTE + code_lines / CODE_LINES_PER_MINUTE + activities * MINUTES_PER_ACTIVITY
    )


def exercises(section: str) -> list[tuple[bool, str]]:
    """Every exercise of the section, as (starred?, difficulty).

    An exercise is a top-level numbered item; everything it carries -- its own
    sub-list, a code block, a table -- is indented under it, so the split is on a
    digit at the start of a line.
    """
    found = []
    text, _ = split_fences(section)
    starts = [match.start() for match in ITEM.finditer(text)]
    for begin, end in zip(starts, [*starts[1:], len(text)], strict=True):
        item = text[begin:end]
        graded = DIFFICULTY.search(item)
        found.append((STAR in item.split('\n')[0], graded.group(1) if graded else '?'))
    return found


def solving_minutes(items: list[tuple[bool, str]]) -> int:
    return sum(MINUTES_BY_DIFFICULTY[difficulty] for _, difficulty in items if difficulty != '?')


def hm(minutes: float) -> str:
    total = int(minutes)
    return f'{total // 60}:{total % 60:02d}'


def claimed(text: str, page: Path) -> tuple[int, int, int, int, int]:
    """The five numbers the chapter states: three times in minutes and two counts."""
    reading, starred, every = READING.search(text), STARRED.search(text), EVERY.search(text)
    if not (reading and starred and every):
        raise SystemExit(f'{page}: no "Tiempo estimado" block, or one this tool cannot read')
    return (
        int(reading.group(1)) * 60 + int(reading.group(2)),
        int(starred.group(2)) * 60 + int(starred.group(3)),
        int(every.group(2)) * 60 + int(every.group(3)),
        int(starred.group(1)),
        int(every.group(1)),
    )


def check(page: Path) -> tuple[list[str], tuple[float, int, int]]:
    """Compare one chapter with the model; returns its complaints and its minutes."""
    text = page.read_text(encoding='utf-8')
    body, _, rest = text.partition('## Ejercicios')
    section = rest.partition('## Resumen')[0]
    items = exercises(section)
    starred = [item for item in items if item[0]]

    read = reading_minutes(body)
    star_time = solving_minutes(starred)
    all_time = solving_minutes(items)
    says_read, says_star, says_all, says_star_count, says_count = claimed(text, page)

    bad = []
    for what, model, says in (
        ('reading', read, says_read),
        ('the starred exercises', star_time, says_star),
        ('all the exercises', all_time, says_all),
    ):
        if abs(model - says) > TOLERANCE:
            bad.append(f'{what}: shows {hm(says)}, the model says {hm(model)}')
    if len(starred) != says_star_count:
        bad.append(f'says {says_star_count} exercises are starred, there are {len(starred)}')
    if len(items) != says_count:
        bad.append(f'says there are {says_count} exercises, there are {len(items)}')
    ungraded = sum(1 for _, difficulty in items if difficulty == '?')
    if ungraded:
        many = f'{ungraded} exercises state' if ungraded > 1 else 'one exercise states'
        bad.append(f'{many} no difficulty **(1)**, **(2)** or **(3)**')
    return bad, (read, star_time, all_time)


def chapters(wanted: list[str]) -> list[Path]:
    chosen = []
    for directory in sorted(examples.DOCS.glob('capitulo-*')):
        number = examples.CHAPTER_DIR.match(directory.name)
        if not number or int(number.group(1)) > examples.LAST_OF_PART_1:
            continue
        if wanted and not any(name in directory.name for name in wanted):
            continue
        chosen.append(directory / 'index.md')
    return chosen


def main() -> int:
    argv = sys.argv[1:]
    loud = '-v' in argv
    wanted = [name for name in argv if not name.startswith('-')]

    drifted, totals = [], [0.0, 0, 0]
    pages = chapters(wanted)
    for page in pages:
        bad, minutes = check(page)
        where = page.parent.name
        totals = [total + one for total, one in zip(totals, minutes, strict=True)]
        if bad:
            drifted.append((where, bad))
        elif loud:
            print(f'  ok   {where}  {hm(minutes[0])} + {hm(minutes[1])} / {hm(minutes[2])}')

    if drifted:
        print(f'\n{len(drifted)} chapters disagree with the model:')
        for where, bad in drifted:
            print(f'  DRIFT {where}')
            for complaint in bad:
                print(f'        {complaint}')
        return 1

    agree = '1 chapter agrees' if len(pages) == 1 else f'{len(pages)} chapters agree'
    print(
        f'{agree} with the model: '
        f'{hm(totals[0])} of reading, {hm(totals[1])} of starred exercises, {hm(totals[2])} of all.'
    )
    return 0


if __name__ == '__main__':
    sys.exit(main())
