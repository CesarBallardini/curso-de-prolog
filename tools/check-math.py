#!/usr/bin/env python
"""Parse every formula of the book with KaTeX and report the ones it rejects.

    ./tools/check-math.py
    ./tools/check-math.py capitulo-11

A formula the renderer cannot parse does not fail the build: KaTeX is told
`throwOnError: false`, so the site and the PDF show the source in red instead of
dropping it silently. That is the right behaviour while writing and the wrong
one to publish, so this looks for those formulas before they get there.

It runs KaTeX itself, from the same pinned version the site and the PDF load,
rather than reimplementing a LaTeX parser.

Exits 1 if any formula is rejected.
"""

import re
import sys
from typing import TYPE_CHECKING

import examples
import katex_pdf
from playwright.sync_api import sync_playwright

if TYPE_CHECKING:
    from pathlib import Path

# $$…$$ first, so that the inline pass never sees the halves of a display block.
DISPLAY = re.compile(r'\$\$(.+?)\$\$', re.S)
INLINE = re.compile(r'(?<!\$)\$(?!\$)(.+?)(?<!\$)\$(?!\$)')
KATEX = f'{katex_pdf.BASE}/katex.min.js'


def formulas(page: Path):
    """Every formula of one page, as (line, display?, source)."""
    text = page.read_text(encoding='utf-8')
    for match in DISPLAY.finditer(text):
        yield text[: match.start()].count('\n') + 1, True, match.group(1).strip()
    # The line numbers of the inline pass are approximate: removing the display
    # blocks first is what keeps the two from overlapping, and that shifts them.
    for match in INLINE.finditer(DISPLAY.sub('', text)):
        yield 0, False, match.group(1).strip()


def main() -> int:
    wanted = [name for name in sys.argv[1:] if not name.startswith('-')]
    found = []
    for page in sorted(examples.DOCS.rglob('*.md')):
        if wanted and not any(name in page.as_posix() for name in wanted):
            continue
        for line, display, source in formulas(page):
            found.append([page.relative_to(examples.ROOT).as_posix(), line, display, source])

    if not found:
        print('No formulas to check.')
        return 0

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch()
        page = browser.new_page()
        page.goto('about:blank')
        page.add_script_tag(url=KATEX)
        page.wait_for_function("() => typeof window.katex === 'object'", timeout=30000)
        rejected = page.evaluate(
            """(items) => items.map(([file, line, display, tex]) => {
                 try {
                   katex.renderToString(tex, { displayMode: display, throwOnError: true });
                   return null;
                 } catch (e) {
                   return { file, line, tex: tex.slice(0, 80), error: e.message.slice(0, 140) };
                 }
               }).filter(Boolean)""",
            found,
        )
        browser.close()

    if rejected:
        print(f'\n{len(rejected)} formulas KaTeX cannot parse:')
        for bad in rejected:
            where = f'{bad["file"]}:{bad["line"]}' if bad['line'] else bad['file']
            print(f'  {where}\n      {bad["tex"]}\n      {bad["error"]}')
        return 1

    print(f'{len(found)} formulas, all of them parse.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
