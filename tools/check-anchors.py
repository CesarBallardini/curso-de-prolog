#!/usr/bin/env python
"""Check the links of one chapter against the headings of its pages, without building the site.

    uv run --frozen tools/check-anchors.py capitulo-41              links inside the chapter
    uv run --frozen tools/check-anchors.py capitulo-41 --incoming   also links from elsewhere into it

Every heading id comes from Python-Markdown's own `toc` extension, with the site's extensions, so
the ids are the site's. Inside the chapter, every link `page.md#id` or `#id` from one of its pages
(soluciones.md included) must name a page of the chapter and an id on it. With --incoming, the
links from every other file of docs/ into the chapter are checked too, and listed: those are the
ones to rewrite when a heading of the chapter moves or changes.

Exits 1 when a link is broken.
"""

import re
import sys
from pathlib import Path

import markdown

ROOT = Path(__file__).resolve().parent.parent
DOCS = Path('docs')
# The site's extensions, by name, from mkdocs.yml; their options do not change a heading's id.
MKDOCS = (ROOT / 'mkdocs.yml').read_text(encoding='utf-8')
EXTENSIONS = re.findall(r'^  - ([\w.]+):?\s*$', MKDOCS.split('\nmarkdown_extensions:\n')[1].split('\n\n')[0], re.M)
LINK = re.compile(r'\]\(([^)\s]*?)(?:#([^)\s]*))?\)')
FENCE = re.compile(r'^```.*?^```', re.M | re.S)


def ids(page: Path) -> set[str]:
    md = markdown.Markdown(extensions=EXTENSIONS)
    html = md.convert(page.read_text(encoding='utf-8'))
    return set(re.findall(r'\sid="([^"]+)"', html))


def links(page: Path):
    """(line, target path or '', anchor or None) for every Markdown link of a page, outside code."""
    text = FENCE.sub(lambda b: '\n' * b.group(0).count('\n'), page.read_text(encoding='utf-8'))
    for number, line in enumerate(text.split('\n'), 1):
        for m in LINK.finditer(line):
            yield number, m.group(1), m.group(2)


def main() -> int:
    name = next(a for a in sys.argv[1:] if not a.startswith('-'))
    folder = next(d for d in sorted(DOCS.glob('capitulo-*')) if d.name.startswith(name))
    anchors = {page.name: ids(page) for page in folder.glob('*.md')}
    broken = 0
    for page in sorted(folder.glob('*.md')):
        for line, target, anchor in links(page):
            if target.startswith(('http:', 'https:', 'mailto:')) or '/' in target:
                continue  # another folder: checked by the build
            if target and not target.endswith('.md'):
                continue  # an image or a file
            file = target or page.name
            if file not in anchors:
                print(f'{page.name}:{line}: {target} is not a page of the chapter')
                broken += 1
            elif anchor and anchor not in anchors[file]:
                print(f'{page.name}:{line}: {file}#{anchor} has no such heading')
                broken += 1
    if '--incoming' in sys.argv:
        for page in sorted(DOCS.rglob('*.md')):
            if page.parent == folder:
                continue
            for line, target, anchor in links(page):
                path = (page.parent / target).resolve() if target else None
                if not path or path.parent != folder.resolve() or not anchor:
                    continue
                if path.name not in anchors or anchor not in anchors[path.name]:
                    print(f'incoming {page.as_posix()}:{line}: {path.name}#{anchor}')
                    broken += 1
    print(f'{folder.name}: {broken} broken link(s)')
    return 1 if broken else 0


if __name__ == '__main__':
    sys.exit(main())
