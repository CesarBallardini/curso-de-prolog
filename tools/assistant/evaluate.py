#!/usr/bin/env python
"""Score the course assistant's retrieval on a blind question set, with and without keywords.

    uv run --frozen tools/assistant/evaluate.py <set-directory> [--keywords FILE] [--boosts 1 3] [-v]

The ranking is the domain's search (docs/javascripts/assistant/domain/), in its relevance order.
A set directory holds `truth.json` (id -> location of the section a question was written from) and
`out.json` (id -> the question), as `keywords.py blind` and the question writer produce them. A
question is a hit at rank n when the n-th section of the answer is the target, or the same heading on
the sibling page of its chapter (domain/section-key.js). The site is served as it is published, and its own
retrieval module ranks the sections in headless Chromium, so the scores are those of the widget; build
the site first (make docs).

Two settings are always scored: no keywords, and the production settings (the module's defaults).
--boosts adds other keyword weights, --title-matches other bonuses for a title that holds the query;
--keywords replaces the index's keywords with those of another keywords file, to try a rewrite without
touching tools/assistant/keywords.json.
"""

import argparse
import json
import sys
from pathlib import Path
from typing import TYPE_CHECKING, NamedTuple, Protocol, TypedDict, cast

import sections as course
from playwright.sync_api import sync_playwright

if TYPE_CHECKING:
    from sections import Location

MODULES = 'javascripts/assistant/'

RANK = """
async ({ questions, options, keywords }) => {
  const base = new URL('.', location.href);
  const { createSearch } = await import(new URL('MODULES/domain/ranking.js', base));
  const { createTokenizer } = await import(new URL('MODULES/domain/text.js', base));
  const { sameSection } = await import(new URL('MODULES/domain/section-key.js', base));
  const { fetchIndex } = await import(new URL('MODULES/adapters/index-source.js', base));
  const { loadSpanish } = await import(new URL('MODULES/adapters/lunr-spanish.js', base));
  let chunks = await fetchIndex(base);
  if (keywords) chunks = chunks.map((c) => (c.location in keywords ? { ...c, keywords: keywords[c.location] } : c));
  const search = createSearch(chunks, createTokenizer(await loadSpanish(base)), options);
  // Relevance order: the order of the course is for the student, and would make @1 and MRR meaningless.
  return questions.map(({ question, location }) =>
    search.ask(question, { sections: 10 }).sections.findIndex((s) => sameSection(s.location, location)),
  );
}
""".replace('MODULES/', MODULES)


class QuestionDto(TypedDict):
    """One question of a blind set and the section it was written from."""

    id: str
    location: Location
    question: str


class SearchOptionsDto(TypedDict, total=False):
    """The options of createSearch in domain/ranking.js; none means the production settings."""

    useKeywords: bool
    keywordBoost: float
    titleMatch: float
    minShare: float


class RankRequestDto(TypedDict):
    """What the page script RANK receives."""

    questions: list[QuestionDto]
    options: SearchOptionsDto
    keywords: dict[Location, str] | None


class Setting(NamedTuple):
    label: str
    options: SearchOptionsDto


class EvaluateArgs(Protocol):
    set_dir: Path
    keywords: Path | None
    boosts: list[float]
    title_matches: list[float]
    min_shares: list[float]
    verbose: bool


# The rank of the target among the sections of an answer, from 0; -1 when it is not among them.
type Rank = int


class Scores(NamedTuple):
    at_1: float
    at_3: float
    at_5: float
    mrr: float

    @classmethod
    def of(cls, ranks: list[Rank]) -> Scores:
        n = len(ranks)
        return cls(
            sum(r == 0 for r in ranks) / n,
            sum(0 <= r < 3 for r in ranks) / n,
            sum(0 <= r < 5 for r in ranks) / n,
            sum(1 / (r + 1) for r in ranks if r >= 0) / n,
        )


def print_scores(label: str, ranks: list[Rank], questions: list[QuestionDto]) -> None:
    s = Scores.of(ranks)
    by_part: dict[str, list[Rank]] = {}
    for rank, question in zip(ranks, questions, strict=True):
        by_part.setdefault(course.part_of(question['location']), []).append(rank)
    parts = '  '.join(f'{part} @5 {Scores.of(rs).at_5:.2f} (n={len(rs)})' for part, rs in sorted(by_part.items()))
    print(
        f'{label:<16} n={len(ranks)}  @1 {s.at_1:.2f}  @3 {s.at_3:.2f}  @5 {s.at_5:.2f}  MRR {s.mrr:.2f}   | {parts}'
    )


def print_misses(ranks: list[Rank], questions: list[QuestionDto]) -> None:
    for rank, q in zip(ranks, questions, strict=True):
        if not 0 <= rank < 5:
            print(f'   miss {q["id"]} (rank {rank + 1 if rank >= 0 else "none"}): {q["question"]}')
            print(f'        wanted {q["location"]}')


def read_questions(set_dir: Path) -> list[QuestionDto]:
    truth: dict[str, Location] = json.loads((set_dir / 'truth.json').read_text(encoding='utf-8'))
    written: dict[str, str] = json.loads((set_dir / 'out.json').read_text(encoding='utf-8'))
    return [{'id': i, 'location': loc, 'question': written[i]} for i, loc in truth.items()]


def parse_args() -> EvaluateArgs:
    parser = argparse.ArgumentParser(description=(__doc__ or '').splitlines()[0])
    parser.add_argument('set_dir', type=Path, help='directory with truth.json and out.json')
    parser.add_argument('--keywords', type=Path, help="keywords file to use instead of the index's own keywords")
    parser.add_argument('--boosts', type=float, nargs='*', default=[], help='other keyword weights to try')
    parser.add_argument(
        '--title-matches', type=float, nargs='*', default=[], help='bonus for a title holding the query'
    )
    parser.add_argument('--min-shares', type=float, nargs='*', default=[], help='share of the best score to list')
    parser.add_argument('-v', '--verbose', action='store_true', help='list the misses of the production settings')
    return cast('EvaluateArgs', parser.parse_args())


def main() -> None:
    args = parse_args()
    course.utf8_console()
    if not (course.SITE / 'assistant' / 'index.json').is_file():
        sys.exit('no site/assistant/index.json: build the site first (make docs)')
    questions = read_questions(args.set_dir)
    keywords: dict[Location, str] | None = None
    if args.keywords:
        stored = course.load_keywords(args.keywords)['sections']
        keywords = {loc: course.keywords_text(entry) for loc, entry in stored.items()}

    settings = [Setting('no keywords', {'useKeywords': False}), Setting('production', {})]
    settings += [Setting(f'keywords x{boost:g}', {'keywordBoost': boost}) for boost in args.boosts]
    settings += [Setting(f'title match x{bonus:g}', {'titleMatch': bonus}) for bonus in args.title_matches]
    settings += [Setting(f'min share {share:g}', {'minShare': share}) for share in args.min_shares]
    site = course.serve_site()
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch()
        page = browser.new_page()
        page.goto(site.base)
        for setting in settings:
            request: RankRequestDto = {'questions': questions, 'options': setting.options, 'keywords': keywords}
            ranks: list[Rank] = page.evaluate(RANK, request)
            print_scores(setting.label, ranks, questions)
            if args.verbose and setting.label == 'production':
                print_misses(ranks, questions)
        browser.close()
    site.server.shutdown()


if __name__ == '__main__':
    main()
