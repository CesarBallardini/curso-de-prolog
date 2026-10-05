#!/usr/bin/env python
r"""Turn the line feeds inside the text runs of a .pptx into line breaks.

    ./tools/slides-breaks.py capitulo-01.pptx      rewrite the file in place

Pandoc writes a highlighted code block as one paragraph whose lines are runs
separated by `<a:br/>`. A block it does not highlight (```text, or a language
it does not know) comes out as a single run with literal line feeds inside.
LibreOffice's import turns each of those line feeds into a new paragraph, so the
block gets the space between paragraphs after every line, and a blank line
inside it disappears. This splits every such run into one run per line, joined
by `<a:br/>` and each keeping the run's properties, which is exactly what pandoc
does for highlighted code. `make slides` runs it on the intermediate .pptx
before LibreOffice converts it.
"""

import re
import sys
import zipfile
from pathlib import Path

# A run: its optional properties, then its text. Pandoc writes the properties
# either empty (`<a:rPr />`) or with children (`<a:rPr><a:latin …/></a:rPr>`).
RUN = re.compile(r'<a:r>(?P<props><a:rPr[^>]*/>|<a:rPr[^>]*>.*?</a:rPr>)?<a:t>(?P<text>[^<]*)</a:t></a:r>', re.S)
SLIDE = re.compile(r'^ppt/slides/slide\d+\.xml$')


def split_run(found):
    text = found.group('text')
    if '\n' not in text:
        return found.group(0)
    props = found.group('props') or ''
    return '<a:br/>'.join(f'<a:r>{props}<a:t>{line}</a:t></a:r>' for line in text.split('\n'))


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    path = Path(sys.argv[1])
    with zipfile.ZipFile(path) as source:
        items = [(info, source.read(info)) for info in source.infolist()]
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_DEFLATED) as out:
        for info, data in items:
            if SLIDE.match(info.filename):
                data = RUN.sub(split_run, data.decode('utf-8')).encode('utf-8')
            out.writestr(info, data)


if __name__ == '__main__':
    main()
