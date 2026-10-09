#!/usr/bin/env python
"""Prepare, collect and test the search keywords of the course assistant, one entry per section.

    make docs
    uv run --frozen tools/assistant/keywords.py check
    uv run --frozen tools/assistant/keywords.py export [--toc] [--all] [--only REGEX]
    uv run --frozen tools/assistant/keywords.py merge
    uv run --frozen tools/assistant/keywords.py blind --count 60 --seed 7 [--only REGEX]

A student often asks with words the section does not use ("atrapar un error" for a section on
catch/3). The words and questions a student would use for each section are written by Claude Code
agents, not by this tool (see tools/assistant/README.md and the skill assistant-keywords): `export`
writes the sections that need keywords into text files, the agents write one JSON file per text file,
and `merge` checks those and stores them in tools/assistant/keywords.json, which is versioned. No model
runs in CI or in the students' browsers: they read the stored words.

Each entry keeps a hash of its section, so after the course changes `export` writes only the sections
that are new or changed, and `merge` drops the entries of sections that no longer exist.

The work directory (--work, default .assistant-work/, git-ignored) holds:

    in/NAME.txt       sections to describe: a line `@@@ <location>`, the title, the text
    out/NAME.json     one answer per input file: {"<location>": {"words": [...], "questions": [...]}}
    <set>/in.txt      a blind set for the question writer (`blind`), and <set>/truth.json

The home page's location is the empty string; in the work files it is called <home>. An answer is
accepted only for the sections its own input file lists, so answers left from an earlier export can
never be stored as if they described the current text; `export` refuses to run while out/ holds any.
"""

import argparse
import json
import random
import re
import sys
from pathlib import Path
from typing import TYPE_CHECKING, NamedTuple, Protocol, TypedDict, cast

import sections as course

if TYPE_CHECKING:
    from collections.abc import Callable

    from sections import KeywordEntryDto, Location, Section

WORK = course.ROOT / '.assistant-work'
MAX_SECTION_CHARS = 3000
MAX_SECTION_CHARS_TOC = 8000
PART_CHARS = 40_000
AGENT_CHARS = 150_000
MAX_WORDS = 20
MAX_QUESTIONS = 3
MAX_ENTRY_CHARS = 80
MIN_BLIND_CHARS = 400
QUESTION_STYLES = ['question', 'keywords', 'problem']
SECTION_MARKER = '@@@ '
HOME_LABEL = '<home>'

type JsonValue = str | int | float | bool | None | list[JsonValue] | dict[str, JsonValue]


class AgentAnswerDto(TypedDict):
    """What an agent writes for one section, before it is normalized and stored."""

    words: list[str]
    questions: list[str]


class CommonArgs(Protocol):
    work: Path
    keywords: Path
    search_index: Path


class ExportArgs(CommonArgs, Protocol):
    all: bool
    toc: bool
    only: str | None
    agent_chars: int


class BlindArgs(CommonArgs, Protocol):
    count: int
    seed: int
    only: str | None
    name: str | None
    exclude: list[Path]


class KeywordState(NamedTuple):
    """The indexed sections against the stored keywords."""

    sections: dict[Location, Section]
    stored: dict[Location, KeywordEntryDto]
    outdated: list[Location]  # keywords missing, or written for another text
    orphans: list[Location]  # stored, but no longer a section


class InputFile(NamedTuple):
    name: str
    sections: int
    chars: int


type InputWriter = Callable[[KeywordState, list[Location], Path], list[InputFile]]


def keyword_state(args: CommonArgs) -> KeywordState:
    sections = course.indexed_sections(args.search_index)
    stored = course.load_keywords(args.keywords)['sections']
    outdated = [
        loc
        for loc, section in sections.items()
        if loc not in stored or stored[loc]['hash'] != course.section_hash(section)
    ]
    orphans = [loc for loc in stored if loc not in sections]
    return KeywordState(sections, stored, outdated, orphans)


def display_path(path: Path) -> Path:
    try:
        return path.relative_to(course.ROOT)
    except ValueError:
        return path


def label(location: Location) -> str:
    return location or HOME_LABEL


def location_of(label_text: str) -> Location:
    return '' if label_text == HOME_LABEL else label_text


def section_block(location: Location, section: Section, limit: int) -> str:
    return f'{SECTION_MARKER}{label(location)}\n{section.title}\n{section.text[:limit]}\n'


def listed_locations(input_path: Path) -> set[Location]:
    """The locations an input file asks the agent to describe."""
    lines = input_path.read_text(encoding='utf-8').splitlines()
    return {location_of(line[len(SECTION_MARKER) :]) for line in lines if line.startswith(SECTION_MARKER)}


def normalize_entries(items: list[str], limit: int) -> list[str]:
    """Lowercase, single-spaced, without repeats or overlong entries, at most `limit`."""
    seen: set[str] = set()
    out: list[str] = []
    for item in items:
        entry = re.sub(r'\s+', ' ', item).strip().lower()
        if entry and len(entry) <= MAX_ENTRY_CHARS and entry not in seen:
            seen.add(entry)
            out.append(entry)
    return out[:limit]


def strings(value: JsonValue) -> list[str] | None:
    """The value as a list of strings, or None if it is anything else."""
    if not isinstance(value, list):
        return None
    out = [item for item in value if isinstance(item, str)]
    return out if len(out) == len(value) else None


def as_answer(value: JsonValue) -> AgentAnswerDto | None:
    """An agent's entry if it has the expected shape: lists of strings under "words" and "questions"."""
    if not isinstance(value, dict):
        return None
    words, questions = strings(value.get('words')), strings(value.get('questions'))
    if words is None or questions is None:
        return None
    return {'words': words, 'questions': questions}


def check(args: CommonArgs) -> int:
    state = keyword_state(args)
    print(
        f'{len(state.sections)} sections, {len(state.outdated)} without current keywords, '
        f'{len(state.orphans)} entries to drop'
    )
    return 1 if state.outdated or state.orphans else 0


def chapter_of(location: Location) -> str:
    """The page group a section belongs to: a chapter with all its extra pages, the patterns, the templates."""
    return location.split('/')[0] or HOME_LABEL


def write_by_chapter(state: KeywordState, wanted: list[Location], inputs: Path) -> list[InputFile]:
    """One file per chapter: its table of contents first, then the sections to describe, in fuller text."""
    chapters: dict[str, list[Location]] = {}
    for loc in wanted:
        chapters.setdefault(chapter_of(loc), []).append(loc)
    files: list[InputFile] = []
    for n, (chapter, locations) in enumerate(chapters.items()):
        toc = '\n'.join(
            f'- {label(loc)}  |  {section.title}'
            for loc, section in state.sections.items()
            if chapter_of(loc) == chapter
        )
        body = '\n'.join(section_block(loc, state.sections[loc], MAX_SECTION_CHARS_TOC) for loc in locations)
        header = f'CHAPTER: {chapter}\nTABLE OF CONTENTS (all sections, location | title):\n{toc}'
        name = f'{n:02d}-{chapter.strip("<>")}.txt'
        course.write_text(inputs / name, f'{header}\n\nSECTIONS TO DESCRIBE:\n\n{body}')
        chars = sum(min(len(state.sections[loc].text), MAX_SECTION_CHARS_TOC) for loc in locations)
        files.append(InputFile(name, len(locations), chars))
    return files


def write_in_parts(state: KeywordState, wanted: list[Location], inputs: Path) -> list[InputFile]:
    """Files of about PART_CHARS characters, the sections in the site's order."""
    blocks = [section_block(loc, state.sections[loc], MAX_SECTION_CHARS) for loc in wanted]
    files: list[InputFile] = []
    for n, part in enumerate(course.pack(blocks, len, PART_CHARS)):
        name = f'part-{n:03d}.txt'
        course.write_text(inputs / name, '\n'.join(part))
        files.append(InputFile(name, len(part), sum(map(len, part))))
    return files


def share_among_agents(files: list[InputFile], limit: int) -> None:
    """Print a split of the input files into consecutive shares of about `limit` characters."""
    shares = course.pack(files, lambda f: f.chars, limit)
    print(f'shared among {len(shares)} agents of about {limit} characters:')
    for i, share in enumerate(shares):
        count = sum(f.sections for f in share)
        print(f'  agent {i}: {share[0].name} .. {share[-1].name}  ({len(share)} files, {count} sections)')


def matching(locations: list[Location], only: str | None) -> list[Location]:
    if not only:
        return locations
    pattern = re.compile(only)
    return [loc for loc in locations if pattern.search(loc)]


def export(args: ExportArgs) -> int:
    answers = args.work / 'out'
    if any(answers.glob('*.json')):
        sys.exit(f'{display_path(answers)} holds answers of an earlier export: merge them, or remove them, first')
    state = keyword_state(args)
    if args.all:
        wanted = [loc for loc in state.sections if loc in state.stored and state.stored[loc]['words']]
    else:
        wanted = state.outdated
    wanted = matching(wanted, args.only)
    inputs = args.work / 'in'
    for old in inputs.glob('*.txt'):
        old.unlink()
    answers.mkdir(parents=True, exist_ok=True)
    write: InputWriter = write_by_chapter if args.toc else write_in_parts
    files = write(state, wanted, inputs)
    print(f'{len(wanted)} sections written to {len(files)} files in {display_path(inputs)}')
    share_among_agents(files, args.agent_chars)
    return 0


def read_answers(answer_path: Path, state: KeywordState, problems: list[str]) -> dict[Location, AgentAnswerDto]:
    """The valid entries of one answer file; what is wrong goes to `problems`."""
    input_path = answer_path.parent.parent / 'in' / answer_path.with_suffix('.txt').name
    if not input_path.is_file():
        problems.append(f'{answer_path.name}: no input file {input_path.name} in this work directory')
        return {}
    listed = listed_locations(input_path)
    try:
        entries: JsonValue = json.loads(answer_path.read_text(encoding='utf-8'))
    except ValueError as error:
        problems.append(f'{answer_path.name}: not valid JSON ({error})')
        return {}
    if not isinstance(entries, dict):
        problems.append(f'{answer_path.name}: not a JSON object')
        return {}
    valid: dict[Location, AgentAnswerDto] = {}
    for label_text, value in entries.items():
        loc = location_of(label_text)
        if loc not in listed:
            problems.append(f'{answer_path.name}: {loc!r} is not a section of {input_path.name}')
        elif loc not in state.sections:
            problems.append(f'{answer_path.name}: {loc!r} is no longer a section')
        elif (answer := as_answer(value)) is None:
            problems.append(f'{answer_path.name}: {loc!r} needs lists of text "words" and "questions"')
        else:
            valid[loc] = answer
    return valid


def merge(args: CommonArgs) -> int:
    state = keyword_state(args)
    data = course.load_keywords(args.keywords)
    stored = data['sections']
    for loc in state.orphans:
        del stored[loc]
    problems: list[str] = []
    added = 0
    for answer_path in sorted((args.work / 'out').glob('*.json')):
        for loc, answer in read_answers(answer_path, state, problems).items():
            stored[loc] = {
                'hash': course.section_hash(state.sections[loc]),
                'words': normalize_entries(answer['words'], MAX_WORDS),
                'questions': normalize_entries(answer['questions'], MAX_QUESTIONS),
            }
            added += 1
    course.save_keywords(data, args.keywords)
    for problem in problems:
        print(problem, file=sys.stderr)
    missing = len(keyword_state(args).outdated)
    print(
        f'{added} entries read, {len(problems)} problems; {missing} of {len(state.sections)} sections without keywords'
    )
    return 1 if problems else 0


def blind(args: BlindArgs) -> int:
    state = keyword_state(args)
    used: set[Location] = set()
    for truth_path in args.exclude:
        truth: dict[str, Location] = json.loads(truth_path.read_text(encoding='utf-8'))
        used |= set(truth.values())
    eligible = [
        loc
        for loc, section in state.sections.items()
        if loc
        and loc not in used
        and len(section.text) >= MIN_BLIND_CHARS
        and loc in state.stored
        and state.stored[loc]['words']
    ]
    eligible = matching(eligible, args.only)
    if len(eligible) < args.count:
        sys.exit(f'only {len(eligible)} eligible sections for {args.count} questions')
    picked = random.Random(args.seed).sample(eligible, args.count)  # noqa: S311 -- a reproducible sample, not a secret
    target = args.work / (args.name or f'blind-{args.seed}')
    picked_truth: dict[str, Location] = {}
    blocks: list[str] = []
    for n, loc in enumerate(picked):
        section = state.sections[loc]
        ident = f'q{n:02d}'
        picked_truth[ident] = loc
        style = QUESTION_STYLES[n % len(QUESTION_STYLES)]
        blocks.append(
            f'{SECTION_MARKER}{ident} | style: {style}\n{section.title}\n{section.text[:MAX_SECTION_CHARS]}\n'
        )
    course.write_text(target / 'in.txt', '\n'.join(blocks))
    course.write_text(target / 'truth.json', json.dumps(picked_truth, ensure_ascii=False, indent=1))
    print(f'{len(eligible)} eligible sections, {args.count} picked (seed {args.seed}) in {display_path(target)}')
    return 0


def parser() -> argparse.ArgumentParser:
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument('--work', type=Path, default=WORK, help='work directory (default .assistant-work/)')
    common.add_argument('--keywords', type=Path, default=course.KEYWORDS, help='keywords file to read and write')
    common.add_argument('--search-index', type=Path, default=course.SEARCH_INDEX, help="the built site's search index")
    top = argparse.ArgumentParser(description=(__doc__ or '').splitlines()[0])
    commands = top.add_subparsers(dest='command', required=True)
    commands.add_parser('check', parents=[common], help='exit 1 if a section lacks current keywords')
    p = commands.add_parser('export', parents=[common], help='write the sections to describe to WORK/in/')
    p.add_argument('--all', action='store_true', help='every section that has keywords, to rewrite them')
    p.add_argument('--toc', action='store_true', help='one file per chapter, with its table of contents')
    p.add_argument('--only', help='regular expression the section location must match')
    p.add_argument('--agent-chars', type=int, default=AGENT_CHARS, help='size of an agent share, in characters')
    commands.add_parser('merge', parents=[common], help='validate WORK/out/*.json and store them')
    p = commands.add_parser('blind', parents=[common], help='pick random sections for a blind question set')
    p.add_argument('--count', type=int, default=60, help='number of sections')
    p.add_argument('--seed', type=int, default=1, help='random seed')
    p.add_argument('--only', help='regular expression the section location must match')
    p.add_argument('--name', help='subdirectory of the work directory (default blind-<seed>)')
    p.add_argument('--exclude', type=Path, nargs='*', default=[], help='truth.json files of sets not to overlap')
    return top


def run(argv: list[str] | None = None) -> int:
    """Run one command; argparse's Namespace is cast to the Protocol of the command that parsed it."""
    namespace = parser().parse_args(argv)
    search_index: Path = namespace.search_index
    if not search_index.is_file():
        sys.exit(f'no {display_path(search_index)}: build the site first (make docs)')
    match namespace.command:
        case 'check':
            return check(cast('CommonArgs', namespace))
        case 'export':
            return export(cast('ExportArgs', namespace))
        case 'merge':
            return merge(cast('CommonArgs', namespace))
        case _:
            return blind(cast('BlindArgs', namespace))


def main() -> None:
    course.utf8_console()
    sys.exit(run())


if __name__ == '__main__':
    main()
