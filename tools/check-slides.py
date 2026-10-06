#!/usr/bin/env python
"""Check that every slide deck's .odp and .pdf still match its Markdown source.

A deck is written in `diapositivas/capitulo-NN.md` and built, with pandoc and
LibreOffice, into `capitulo-NN.odp` and `capitulo-NN.pdf`; both are versioned and
published with the site. Rebuilding them needs those two programs and does not give
byte-identical files, so this compares what the reader sees instead:

  - the .odp has one slide per heading of the source (the title slide from `#` or
    from `title:` in the front matter, then one per `##`), in the same order and
    with the same titles;
  - the .pdf has one page per slide.

A heading changed, added or removed without rebuilding the deck fails here, and so
does an .odp exported to PDF before its last rebuild. The transcripts of the decks
are checked by `tools/check-transcripts.py --slides`.

    ./tools/check-slides.py [capitulo-07 ...]
"""

import re
import sys
import zipfile

import examples

HEADING = re.compile(r'^(#{1,2}) (?P<title>.+)$', re.M)
FRONT_MATTER = re.compile(r'\A---\n.*?\n---\n', re.S)
TITLE_FIELD = re.compile(r'^title:\s*"?(?P<title>.*?)"?\s*$', re.M)
FENCE = re.compile(r'^(```|~~~).*?^\1', re.M | re.S)
PAGE = re.compile(r'<draw:page\b.*?</draw:page>', re.S)
TITLE = re.compile(r'<draw:frame\b[^>]*presentation:class="title"[^>]*>(?P<body>.*?)</draw:frame>', re.S)
TAG = re.compile(r'<[^>]+>')
PDF_PAGE = re.compile(rb'/Type\s*/Page\b(?!s)')


def plain(text: str) -> str:
    """A title as the slide shows it: no Markdown marks, entities decoded, spaces collapsed."""
    text = re.sub(r'[`*_]', '', text)
    text = text.replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>').replace('&apos;', "'")
    text = text.replace('&quot;', '"')
    return ' '.join(text.split())


def source_titles(markdown: str) -> list[str]:
    """The slide titles in order; pandoc makes the title slide from `title:` when there is one."""
    front = FRONT_MATTER.match(markdown)
    declared = TITLE_FIELD.search(front.group(0)) if front else None
    titles = [plain(declared.group('title'))] if declared else []
    body = FENCE.sub('', FRONT_MATTER.sub('', markdown))
    return titles + [plain(m.group('title')) for m in HEADING.finditer(body)]


def deck_titles(odp) -> list[str]:
    content = zipfile.ZipFile(odp).read('content.xml').decode('utf-8')
    titles = []
    for page in PAGE.findall(content):
        frame = TITLE.search(page)
        titles.append(plain(TAG.sub(' ', frame.group('body'))) if frame else '')
    return titles


def problems(source) -> list[str]:
    found = []
    odp, pdf = source.with_suffix('.odp'), source.with_suffix('.pdf')
    expected = source_titles(source.read_text(encoding='utf-8'))
    if not odp.exists():
        return [f'{odp.name} is missing (make slides)']
    built = deck_titles(odp)
    if len(built) != len(expected):
        found.append(f'{odp.name} has {len(built)} slides, the source has {len(expected)} headings')
    for number, (want, have) in enumerate(zip(expected, built, strict=False), start=1):
        if want != have:
            found.append(f'{odp.name} slide {number} is titled «{have}», the source says «{want}»')
            break
    if not pdf.exists():
        found.append(f'{pdf.name} is missing (make slides-pdf)')
    else:
        pages = len(PDF_PAGE.findall(pdf.read_bytes()))
        if pages != len(built):
            found.append(f'{pdf.name} has {pages} pages, {odp.name} has {len(built)} slides')
    return found


def main() -> int:
    sys.stdout.reconfigure(encoding='utf-8')
    wanted = [name for name in sys.argv[1:] if not name.startswith('-')]
    sources = [
        s for s in sorted(examples.SLIDES.glob('capitulo-*.md')) if not wanted or any(w in s.stem for w in wanted)
    ]
    failed = 0
    for source in sources:
        found = problems(source)
        if found:
            failed += 1
            print(f'{source.stem:<15} OUT OF DATE')
            for line in found:
                print(f'    {line}')
        else:
            print(f'{source.stem:<15} .odp and .pdf match the source')
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
