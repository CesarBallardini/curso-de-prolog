#!/usr/bin/env python
"""Every mention of a chapter, a section, a solution or a pattern in the prose is a link.

Bare forms the book does not allow in prose (code blocks, headings and `!!!` title lines
are exempt, and so is a chapter's mention of itself):

    capítulo 5                  -> [capítulo 5](../capitulo-05-slug/index.md)
    capítulos 3 y 4             -> capítulos [3](...) y [4](...)
    sección 5.6                 -> [sección 5.6](../capitulo-05-slug/index.md#56-slug)
                                   (same page: [sección 5.6](#56-slug); from soluciones.md:
                                   [sección 5.6](index.md#56-slug))
    solución 11 del capítulo 15 -> [solución 11 del capítulo 15](../capitulo-15-control/soluciones.md#11)
    ejercicio 7 del capítulo 7  -> [ejercicio 7 del capítulo 7](../capitulo-07-listas/soluciones.md#7)
    Patrón 26                   -> [Patrón 26](../patrones.md#26-slug)

    uv run tools/check-links.py            # list the bare mentions (exit 1 if any)
    uv run tools/check-links.py --write    # link them in place

A mention split across two lines is reported but not rewritten.
"""

import re
import sys
from pathlib import Path

from markdown.extensions.toc import slugify

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs'

CHAPTER_RE = re.compile(r'capitulo-(\d\d)-')
SECTION_RE = re.compile(r'^## (\d+)\.(\d+) (.+?)\s*$')
PATTERN_RE = re.compile(r'^## (\d+) — (.+?)\s*$')

NOT_IN_LINK = r'(?<![\[\w])'
NOT_A_NUMBER_TAIL = r'(?![\d.])'
SOLUTION = re.compile(rf'(?<!\[)\b((?:soluci[oó]n|ejercicio) (\d+) del cap[ií]tulo (\d+)){NOT_A_NUMBER_TAIL}')
SECTION = re.compile(rf'{NOT_IN_LINK}(secci[oó]n) (\d+)\.(\d+){NOT_A_NUMBER_TAIL}')
SECTIONS = re.compile(rf'{NOT_IN_LINK}(secciones )((?:\d+\.\d+)(?:(?:, | y | e )\d+\.\d+)+)')
CHAPTER = re.compile(rf'{NOT_IN_LINK}(cap[ií]tulo) (\d+){NOT_A_NUMBER_TAIL}')
CHAPTERS = re.compile(rf'{NOT_IN_LINK}(cap[ií]tulos )((?:\d+)(?:(?:, | y | e )\d+)+)')
CHAPTERS_ONE = re.compile(rf'{NOT_IN_LINK}(cap[ií]tulos )(\d+){NOT_A_NUMBER_TAIL}')
# Patterns have no sub-numbers, so a full stop after the number ends the sentence
# («el Patrón 12.») unless a digit follows it.
PATTERN = re.compile(rf'{NOT_IN_LINK}(Patr[oó]n) (\d+)(?!\d|\.\d)')
ONE_SECTION = re.compile(r'(?<!\[)(\d+)\.(\d+)(?![\d.\]])')
ONE_NUMBER = re.compile(r'(?<![\[\d.])(\d+)(?![\d.\]])')
# "capítulo" at the end of a line, or a plural list whose last number is on the next line.
DANGLING = re.compile(
    r'(?<![\[\w])(cap[ií]tulos?|secci[oó]n(?:es)?|Patr[oó]n)\s*$'
    r'|(cap[ií]tulos|secciones) [\d., y]*(,| y| e)\s*$'
)
LINK = re.compile(r'\[[^\]]*\]\([^)]*\)')


def sub_outside_links(regex, handler, line):
    """Apply regex.sub(handler) to the text between existing Markdown links only."""
    out, pos = [], 0
    for m in LINK.finditer(line):
        out.append(regex.sub(handler, line[pos : m.start()]))
        out.append(m.group(0))
        pos = m.end()
    out.append(regex.sub(handler, line[pos:]))
    return ''.join(out)


def chapters():
    """{number: dir name}"""
    return {
        int(CHAPTER_RE.match(d.name).group(1)): d.name
        for d in DOCS.glob('capitulo-*')
        if d.is_dir() and CHAPTER_RE.match(d.name)
    }


def sections():
    """{(chapter, section): anchor}"""
    out = {}
    for index in DOCS.glob('capitulo-*/index.md'):
        for line in index.read_text(encoding='utf-8').split('\n'):
            m = SECTION_RE.match(line)
            if m:
                title = m.group(3).replace('`', '')
                out[(int(m.group(1)), int(m.group(2)))] = slugify(f'{m.group(1)}.{m.group(2)} {title}', '-')
    return out


def patterns():
    """{number: anchor}"""
    out = {}
    for line in (DOCS / 'patrones.md').read_text(encoding='utf-8').split('\n'):
        m = PATTERN_RE.match(line)
        if m:
            out[int(m.group(1))] = slugify(f'{m.group(1)} {m.group(2).replace("`", "")}', '-')
    return out


class Page:
    def __init__(self, path, chapter_dirs, section_anchors, pattern_anchors):
        self.path = path
        self.dirs = chapter_dirs
        self.sections = section_anchors
        self.patterns = pattern_anchors
        self.is_catalogue = path.name == 'patrones.md'
        self.is_index = path.name == 'index.md'
        # patrones.md and plantillas.md live in docs/ itself, not in a chapter directory.
        self.up = '' if path.parent == DOCS else '../'
        m = CHAPTER_RE.match(path.parent.name)
        self.chapter = int(m.group(1)) if m else None
        self.problems = []
        self.lineno = 0

    def note(self, kind, text):
        self.problems.append((self.lineno, kind, text))

    # --- link targets -------------------------------------------------------------------
    def chapter_page(self, n, page='index.md'):
        """The relative path of a chapter page, or None for a chapter's own index."""
        if n not in self.dirs:
            self.note('unknown chapter', str(n))
            return None
        if self.chapter == n:
            return None if (page == 'index.md' and self.is_index) else page
        return f'{self.up}{self.dirs[n]}/{page}'

    def section_target(self, n, k):
        anchor = self.sections.get((n, k))
        if anchor is None:
            self.note('unknown section', f'{n}.{k}')
            return None
        if self.chapter == n:
            return f'#{anchor}' if self.is_index else f'index.md#{anchor}'
        return f'{self.up}{self.dirs[n]}/index.md#{anchor}'

    def pattern_target(self, n):
        anchor = self.patterns.get(n)
        if anchor is None:
            self.note('unknown pattern', str(n))
            return None
        return f'#{anchor}' if self.is_catalogue else f'{self.up}patrones.md#{anchor}'

    # --- one handler per mention form ---------------------------------------------------
    def solution(self, m):
        target = self.chapter_page(int(m.group(3)), 'soluciones.md')
        return m.group(0) if target is None else f'[{m.group(1)}]({target}#{m.group(2)})'

    def section(self, m):
        target = self.section_target(int(m.group(2)), int(m.group(3)))
        return m.group(0) if target is None else f'[{m.group(1)} {m.group(2)}.{m.group(3)}]({target})'

    def section_list(self, m):
        def one(mm):
            target = self.section_target(int(mm.group(1)), int(mm.group(2)))
            return mm.group(0) if target is None else f'[{mm.group(0)}]({target})'

        return m.group(1) + ONE_SECTION.sub(one, m.group(2))

    def chapter_mention(self, m):
        target = self.chapter_page(int(m.group(2)))
        return m.group(0) if target is None else f'[{m.group(1)} {m.group(2)}]({target})'

    def chapter_list(self, m):
        def one(mm):
            target = self.chapter_page(int(mm.group(1)))
            return mm.group(0) if target is None else f'[{mm.group(0)}]({target})'

        return m.group(1) + ONE_NUMBER.sub(one, m.group(2))

    def pattern(self, m):
        target = self.pattern_target(int(m.group(2)))
        return m.group(0) if target is None else f'[{m.group(1)} {m.group(2)}]({target})'

    def rewrite_line(self, line):
        for regex, handler in (
            (SOLUTION, self.solution),
            (SECTION, self.section),
            (SECTIONS, self.section_list),
            (CHAPTER, self.chapter_mention),
            (CHAPTERS, self.chapter_list),
            (CHAPTERS_ONE, self.chapter_list),
            (PATTERN, self.pattern),
        ):
            line = sub_outside_links(regex, handler, line)
        return line

    def run(self, write):
        lines = self.path.read_text(encoding='utf-8').split('\n')
        out = []
        in_code = False
        changed = 0
        for i, line in enumerate(lines, 1):
            self.lineno = i
            if line.strip().startswith(('```', '~~~')):
                in_code = not in_code
            exempt = in_code or line.startswith(('#', '!!!', '???', '```', '~~~'))
            new = line if exempt else self.rewrite_line(line)
            if new != line:
                changed += 1
                self.note('bare mention', line.strip()[:110])
            out.append(new if write else line)
            if not exempt and DANGLING.search(line) and i < len(lines) and re.match(r'\d', lines[i].strip()):
                self.note('split across lines', f'{line.strip()[-30:]} / {lines[i].strip()[:30]}')
        if write and changed:
            self.path.write_text('\n'.join(out), encoding='utf-8', newline='\n')
        return changed


def main():
    # The lines it prints quote the prose, ★ included, which the Windows console
    # encoding cannot write.
    sys.stdout.reconfigure(encoding='utf-8')
    write = '--write' in sys.argv
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    dirs, secs, pats = chapters(), sections(), patterns()
    pages = sorted(DOCS.glob('capitulo-*/*.md')) + [DOCS / 'patrones.md', DOCS / 'plantillas.md']
    if only:
        pages = [p for p in pages if any(o.replace('\\', '/') in p.as_posix() for o in only)]
    total = 0
    for path in pages:
        page = Page(path, dirs, secs, pats)
        total += page.run(write)
        for lineno, kind, text in page.problems:
            print(f'{path.relative_to(ROOT).as_posix()}:{lineno}: {kind}: {text}')
    print(f'{total} lines {"linked" if write else "bare"}')
    return 0 if (write or total == 0) else 1


if __name__ == '__main__':
    sys.exit(main())
