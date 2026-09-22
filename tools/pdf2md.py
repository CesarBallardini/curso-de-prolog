# /// script
# requires-python = ">=3.14"
# dependencies = ["pymupdf"]
# ///
"""Convert an OCR'd book PDF into one Markdown file per chapter.

Uses the PDF's own text layer (no re-OCR) and its bookmark outline:
outline entries become headings and split the book into files. Code is
detected by font (monospace) or by indentation plus a Prolog-ish shape.

    uv run tools/pdf2md.py BOOK.pdf OUT_DIR [--code-fonts Courier,Calibri-Bold]
"""

import argparse
import collections
import re
import unicodedata
from pathlib import Path

import pymupdf

CODE_SHAPE = re.compile(
    r'^\s*(\?-|:-|%)'  # query, directive, comment
    r'|:-\s*$|:-\s'  # rule neck
    r'|^[a-z]\w*\(.*\)\s*[.,;]?\s*$'  # fact/goal: name(args).
    r'|^\s*[a-z]\w*\s*\.\s*$'  # atom goal: nl.
)


def slug(text):
    text = unicodedata.normalize('NFKD', text).encode('ascii', 'ignore').decode()
    return re.sub(r'[^a-z0-9]+', '-', text.lower()).strip('-')[:60]


def norm(text):
    return re.sub(r'[^a-z0-9]', '', text.lower())


def is_mono(font, code_fonts):
    return any(f.lower() in font.lower() for f in code_fonts)


def page_lines(page, code_fonts):
    """Yield (x0, y0, y1, size, text, markdown, mono_ratio) per text line."""
    out = []
    for block in page.get_text('dict', sort=True)['blocks']:
        for line in block.get('lines', []):
            spans = [s for s in line['spans'] if s['text'].strip()]
            if not spans:
                continue
            text = ''.join(s['text'] for s in line['spans']).rstrip()
            mono = sum(len(s['text']) for s in spans if is_mono(s['font'], code_fonts))
            md = []
            for s in line['spans']:
                t = s['text']
                core = t.strip()
                if not core:
                    md.append(t)
                    continue
                lead, trail = t[: len(t) - len(t.lstrip())], t[len(t.rstrip()) :]
                if is_mono(s['font'], code_fonts):
                    core = f'`{core}`'
                elif 'Italic' in s['font'] or s['flags'] & 2:
                    core = f'*{core}*'
                md.append(lead + core + trail)
            md = re.sub(r'`\s*`', ' ', ''.join(md)).rstrip()
            md = re.sub(r'\*\s*\*', ' ', md)
            size = max(s['size'] for s in spans)
            x0, y0, _, y1 = line['bbox']
            out.append((x0, y0, y1, size, text, md, mono / max(1, sum(len(s['text']) for s in spans))))
    return out


def strip_furniture(lines, titles):
    """Drop the running head (top row of the page) and a bare bottom page number.

    Scans are offset, so "top of page" means the first text row, not a fixed band.
    """
    if not lines:
        return lines
    top = min(ln[1] for ln in lines)
    head = [ln for ln in lines if ln[1] < top + 4]
    text = ' '.join(ln[4].strip() for ln in head)
    if len(text) < 90 and (
        re.search(r'(^|\s)[\divxlc]+(\s|$)', text) or norm(text) in titles or any(norm(ln[4]) in titles for ln in head)
    ):
        lines = [ln for ln in lines if ln not in head]
    if lines and re.fullmatch(r'[\divxlc]+', lines[-1][4].strip()):
        lines = lines[:-1]
    return lines


def fix_text(s):
    s = s.replace('­', '').replace('ﬁ', 'fi').replace('ﬂ', 'fl')
    return re.sub(r'[ \t]+', ' ', s)


def join_paragraph(pieces):
    """One paragraph out of its lines, healing a word hyphenated across a line break."""
    text = ''
    for piece in pieces:
        if text.endswith('-') and piece[:1].islower():
            text = text[:-1] + piece
        else:
            text = f'{text} {piece}' if text else piece
    return fix_text(text).strip()


def render_code(code):
    """A fenced code block; each line keeps its indentation, measured from its x position."""
    base = min(x for x, _ in code)
    return ['```prolog', *[' ' * round((x - base) / 5) + t.strip() for x, t in code], '```', '']


def matching_heading(pending, text):
    """The outline entry this line begins, out of those the page still owes."""
    key = norm(text)
    if not key:
        return None
    return next(
        (h for h in pending if norm(h[1]).startswith(key[:25]) and len(key) >= min(6, len(norm(h[1])))),
        None,
    )


def page_metrics(lines):
    """The left margin and the font size of the page's body text, code lines aside."""
    body = [ln for ln in lines if ln[6] < 0.5]
    margin = collections.Counter(round(ln[0]) for ln in body).most_common(1)[0][0] if body else lines[0][0]
    size = collections.Counter(round(ln[3]) for ln in body).most_common(1)[0][0] if body else 10
    return margin, size


def is_title_echo(text, size, body_size, titles, top_title):
    """Heading text reappearing as body: the chapter number and title on its opening page,
    or the rest of a multi-line heading whose first line was already emitted."""
    key = norm(text)
    if top_title and (re.fullmatch(r'[\dA-Z]{1,2}', text) or (key and key in top_title and size > body_size * 1.1)):
        return True
    return key in titles and size > body_size * 1.1


def looks_like_code(md, text, mono, indented, in_block):
    """Whether a line belongs in a code block: set in a monospace font, or indented and
    shaped like Prolog, or the continuation of the block being built.

    A run of three plain words outside inline code means prose, whatever the font.
    """
    if re.search(r'\b[a-z]{2,} [a-z]{2,} [a-z]{2,}\b', re.sub(r'`[^`]*`', '', md)):
        return False
    return mono >= 0.5 or (indented > 12 and bool(CODE_SHAPE.search(text))) or (in_block and indented > 12)


class Chapter:
    """The Markdown of one chapter, accumulated line by line.

    A paragraph, a list item or a code block is built up as its lines arrive, and is
    flushed when a different kind of content starts.
    """

    def __init__(self):
        self.out = []
        self.para = []
        self.code = []
        self.item_x = None  # x of the current list item's text, when para is a list item
        self.bullet = False
        self.prev_y1 = None  # bottom of the previous line, which sets the paragraph gap

    def text(self):
        return '\n'.join(self.out)

    def flush_para(self):
        if self.para:
            self.out.append(join_paragraph(self.para))
            self.out.append('')
            self.para.clear()
        self.item_x = None

    def flush_code(self):
        if self.code:
            self.out.extend(render_code(self.code))
            self.code.clear()

    def line(self, ln, pending, margin, body_size, titles, top_title):
        """Place one line of a page: a heading, code, a list item, a paragraph, or nothing.

        `pending` are the outline entries the page still owes; a line that matches one emits
        the heading and takes it off the list.
        """
        x0, y0, y1, size, text, md, mono = ln
        t = text.strip()
        gap = self.prev_y1 is not None and y0 - self.prev_y1 > (y1 - y0) * 0.9
        self.prev_y1 = y1

        # Outline headings (matched by text on their own page).
        hit = matching_heading(pending, t)
        if hit:
            self.flush_para()
            self.flush_code()
            pending.remove(hit)
            self.out.append('#' * hit[0] + ' ' + hit[1].strip())
            self.out.append('')
            return
        if is_title_echo(t, size, body_size, titles, top_title):
            return
        indented = x0 - margin
        if looks_like_code(md, t, mono, indented, bool(self.code)):
            self.flush_para()
            self.code.append((x0, t))
            return
        self.flush_code()
        if re.fullmatch(r'[•�●▪·–-]', t):
            self.flush_para()
            self.bullet = True
            return
        if self.bullet:
            self.bullet = False
            self.para.append('- ' + md.strip())
            self.item_x = x0
            return
        if self.item_x is not None and abs(x0 - self.item_x) < 4 and not gap:
            self.para.append(md.strip())
            return
        if self.para and (gap or indented > 6 or re.match(r'^([•\-–]|\(?[a-z0-9]\)|\d+\.\s)', t)):
            self.flush_para()
        if size > body_size * 1.15 and len(t) < 90 and not self.para:
            self.out.append(f'**{fix_text(t)}**')
            self.out.append('')
        else:
            self.para.append(md.strip())


def convert_pages(doc, first, last, headings, code_fonts, titles):
    """Render pages [first, last) as Markdown. headings: {page: [(level, title)]}."""
    chapter = Chapter()
    top_title = None
    if headings.get(first) and headings[first][0][0] == 1:
        _, title = headings[first].pop(0)
        top_title = norm(title)
        chapter.out += ['# ' + title, '']
    for pno in range(first, last):
        lines = strip_furniture(page_lines(doc[pno], code_fonts), titles)
        if not lines:
            continue
        pending = list(headings.get(pno, []))
        margin, body_size = page_metrics(lines)
        chapter.out.append(f'<!-- page {pno + 1} -->')
        chapter.prev_y1 = None
        for ln in lines:
            chapter.line(ln, pending, margin, body_size, titles, top_title if pno == first else None)
        # Paragraphs flow across pages; code blocks do not need to.
        chapter.flush_code()
    chapter.flush_para()
    return chapter.text()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('pdf')
    ap.add_argument('out')
    ap.add_argument('--code-fonts', default='Courier')
    ap.add_argument('--split-level', type=int, default=1, help='outline level whose entries start a new file')
    args = ap.parse_args()
    code_fonts = [f for f in args.code_fonts.split(',') if f]

    doc = pymupdf.open(args.pdf)
    toc = [(lvl, title.strip(), page - 1) for lvl, title, page in doc.get_toc()]
    titles = {norm(t) for _, t, _ in toc}
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    # A file starts at each entry of level <= split-level.
    starts = [i for i, (lvl, _, _) in enumerate(toc) if lvl <= args.split_level]
    index = ['# ' + Path(args.pdf).stem, '']

    # Some PDFs carry no outline at all -- one built by a tool that never wrote
    # one, or a scan. There is nothing to split on, so the whole book goes into
    # a single file: less convenient than one file per chapter, but still the
    # searchable text.
    if not starts:
        md = convert_pages(doc, 0, len(doc), collections.defaultdict(list), code_fonts, titles)
        name = f'00-{slug(Path(args.pdf).stem)}.md'
        (out / name).write_text(md + '\n', encoding='utf-8')
        index.append(f'- [{Path(args.pdf).stem}]({name}) — pages 1–{len(doc)} (the PDF has no outline)')
        (out / 'README.md').write_text('\n'.join(index) + '\n', encoding='utf-8')
        print(f'{name}: pages 1-{len(doc)} (the PDF has no outline, so it is one file)')
        return

    for n, i in enumerate(starts):
        lvl, title, page = toc[i]
        end_i = starts[n + 1] if n + 1 < len(starts) else len(toc)
        end_page = toc[end_i][2] if end_i < len(toc) else len(doc)
        if end_page <= page:
            end_page = page + 1
        headings = collections.defaultdict(list)
        for l2, t2, p2 in toc[i:end_i]:
            headings[p2].append((min(l2 - lvl + 1, 6), t2))
        md = convert_pages(doc, page, end_page, headings, code_fonts, titles)
        name = f'{n:02d}-{slug(title)}.md'
        (out / name).write_text(md + '\n', encoding='utf-8')
        index.append(f'- [{title}]({name}) — pages {page + 1}–{end_page}')
        print(f'{name}: pages {page + 1}-{end_page}')
    (out / 'README.md').write_text('\n'.join(index) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
