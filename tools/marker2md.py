# /// script
# requires-python = ">=3.14"
# dependencies = ["pymupdf"]
# ///
r"""Turn Marker's Markdown of a scanned paper into a books/ conversion.

Marker is a math-aware OCR: it writes formulas in LaTeX, which Tesseract garbles, but it drops the
page boundaries and makes recurring mistakes. This tool, in order:

1. normalizes Marker's spacing around inline math;
2. makes numbered section headings level 2 (``## 5. Title``) and the references ``## References``;
3. applies the paper's repairs (a TOML file of checked replacements, below);
4. optionally bolds numbered definition labels (``**5.10 Key triples.**``), one paragraph each;
5. joins the paragraphs Marker split at a page break;
6. inserts ``<!-- page N, journal p. M -->`` where each page begins, aligning the words with a text
   that keeps the page boundaries: the PDF's own text layer, or an ocrmypdf ``--sidecar`` file;
7. applies the repairs marked ``stage = "after"`` and writes the contents-by-line header.

    uv run tools/marker2md.py MARKER.md PAGES OUT.md --repairs REPAIRS.toml

PAGES is a PDF or a text file with a form feed between pages. Each repair states how many times it
must match (once by default); the tool lists those that do not and exits 1, so a new Marker
version cannot skip a fix unnoticed.

Repairs file::

    page_offset = 22          # journal page = PDF page + page_offset; 0 writes only the PDF page
    running_head = '...'      # regex for a page's first line, ignored when aligning (optional)
    bold_labels = true

    [header]
    intro = '''...'''         # the paragraph that opens the contents-by-line header
    [header.sections]
    "1" = "Introduction"      # how the contents name section 1 (default: its heading)

    [[repair]]
    old = '...'               # exact text, or a Python regex with regex = true
    new = '...'               # inserted as written (a regex replacement takes no group references)
    regex = false
    flags = ""                # with regex: "s" (dot matches newline), "m" (multiline)
    count = 1                 # or all = true: every occurrence, at least one
    stage = "before"          # "after": once the page markers are in

The two inputs, in Git Bash (the commands used for Robinson 1965, whose repairs file records them
too, in books/robinson-machine-oriented-logic-resolution-principle/marker-repairs.toml):

1. The page text, with ocrmypdf (Tesseract on PATH; pypdfium when Ghostscript is missing)::

       uvx ocrmypdf -f -l eng --rasterizer pypdfium --output-type pdf --oversample 400 \
           --sidecar pages.txt IN.pdf ocr.pdf

2. Marker. Pin version 1: version 2 needs an inference server (vLLM in Docker, or llama-server).
   Keep paths short: Marker writes DIR/NAME/NAME.md and Windows limits paths to 260 characters.
   On the CPU, 19 pages took about 1.5 hours and 8.5 GB; small batches lower the memory, and
   procgov (Chocolatey) caps the whole job (its --maxws needs an elevated shell) and needs the
   Windows path of uvx. Run it in the foreground of a terminal of your own: a background job may
   be stopped when the system is short of memory::

       cp IN.pdf "$DIR/r.pdf"; cd "$DIR"
       PYTHONIOENCODING=utf-8 TORCH_DEVICE=cpu RECOGNITION_BATCH_SIZE=4 DETECTOR_BATCH_SIZE=2 \
           LAYOUT_BATCH_SIZE=2 TEXIFY_BATCH_SIZE=2 TABLE_REC_BATCH_SIZE=2 OCR_ERROR_BATCH_SIZE=2 \
           procgov --maxjobmem 12G -- "$(cygpath -w "$(which uvx)")" --python 3.12 \
           --from 'marker-pdf<2' marker_single r.pdf --output_format markdown --output_dir . \
           --force_ocr --disable_image_extraction

   With an NVIDIA GPU, TORCH_DEVICE=cuda and a CUDA build of PyTorch (add
   --index pytorch=https://download.pytorch.org/whl/cu126 --index-strategy unsafe-best-match
   --with "torch==2.14.1+cu126" --with "torchvision==0.29.1+cu126" to uvx) should be much faster;
   not tried yet, and 4 GB of video memory may be too little.
"""

import argparse
import difflib
import re
import sys
import tomllib
from pathlib import Path

import pymupdf

FLAGS = {'s': re.S, 'm': re.M}
WORD = re.compile(r'[A-Za-z]{3,}')


def normalize(text):
    """Collapse Marker's double spaces around inline math and before punctuation."""
    text = '\n'.join(re.sub(r'(?<=\S) {2,}', ' ', line).rstrip() for line in text.split('\n'))
    text = re.sub(r' ([,.;:)])(?=\s|$)', r'\1', text)
    return re.sub(r'\$ ([,.;:])', r'$\1', text)


def headings(text):
    """Numbered sections become level 2, and so does the references heading."""
    text = re.sub(r'^#{1,4} (\d+)\. (.+)$', r'## \1. \2', text, flags=re.M)
    return re.sub(r'^#{1,4} references$', '## References', text, flags=re.M | re.I)


def replace(text, rep):
    """Return (matches, text with every match of one repair replaced)."""
    old, new = rep['old'], rep['new']
    if not rep.get('regex'):
        return text.count(old), text.replace(old, new)
    pattern = re.compile(old, sum(FLAGS[f] for f in rep.get('flags', '')))
    return pattern.subn(lambda _m: new, text)[::-1]


def apply_repairs(text, repairs, stage, problems):
    """Apply the repairs of one stage, recording those that match a wrong number of times."""
    for rep in repairs:
        if rep.get('stage', 'before') != stage:
            continue
        found, fixed = replace(text, rep)
        if (rep.get('all') and found == 0) or (not rep.get('all') and found != rep.get('count', 1)):
            problems.append(f'{found} match(es): {rep["old"][:70]!r}')
        else:
            text = fixed
    return text


def bold_labels(text):
    """Bold `N.M Name.` labels, strip Marker's list bullets from them, one paragraph each."""
    label = re.compile(r'^\s*(?:- )?(\d\.\d{1,2}) ([A-Z][A-Za-z\- ]+?)\. ')
    sublabel = re.compile(r'^\s*- (\d\.\d{1,2}\.\d\.) ')
    out = []
    for line in text.split('\n'):
        m, s = label.match(line), sublabel.match(line)
        if m:
            line = f'**{m[1]} {m[2]}.** ' + line[m.end() :]
        elif s:
            line = s[1] + ' ' + line[s.end() :]
        if (m or s) and out and out[-1] != '':
            out.append('')
        out.append(line)
    return '\n'.join(out)


def join_split_paragraphs(text):
    """Join a paragraph that ends mid-sentence with the next one, which starts in lower case."""
    plain = re.compile(r'^(?![#$\-|`]|\d\.\s)')
    paras = text.split('\n\n')
    joined = [paras[0]]
    for para in paras[1:]:
        prev = joined[-1]
        if (
            plain.match(prev)
            and not prev.rstrip().endswith('$$')
            and re.search(r'[a-z,\-]$', prev)
            and re.match(r'[a-z]', para)
        ):
            joined[-1] = prev[:-1] + para if prev.endswith('-') else prev + ' ' + para
        else:
            joined.append(para)
    return '\n\n'.join(joined)


def read_pages(path):
    """Return the text of each page: a PDF's text layer, or a file with form feeds between pages."""
    if path.suffix.lower() == '.pdf':
        with pymupdf.open(path) as doc:
            return [page.get_text() for page in doc]
    pages = path.read_text(encoding='utf-8').split('\f')
    while pages and not pages[-1].strip():
        pages.pop()
    return pages


def words(text):
    """Return (offset, word) for every word of three letters or more."""
    return [(m.start(), m.group().lower()) for m in WORD.finditer(text)]


def page_starts(text, pages, running_head):
    """Return (offset in text, page number) for pages 2 onwards, by aligning the two word streams."""
    head = re.compile(running_head + r'[^\n]*\n', re.I) if running_head else None
    side, starts = [], []
    for page in pages:
        if head:
            page = head.sub('', page, count=1)
        starts.append(len(side))
        side += [w for _, w in words(page)]
    masked = re.sub(r'\$[^$]*\$', lambda m: ' ' * len(m.group()), text)  # words inside math do not count
    mine = words(masked)
    blocks = difflib.SequenceMatcher(None, side, [w for _, w in mine], autojunk=False).get_matching_blocks()
    found = []
    for number, start in enumerate(starts[1:], 2):
        block = next(b for b in blocks if b.a + b.size > start)
        found.append((mine[block.b + max(0, start - block.a)][0], number))
    return found


def page_markers(text, pages, offset, running_head):
    """Insert a comment where each page begins: on its own line at a paragraph start, else inline."""
    for pos, number in sorted(page_starts(text, pages, running_head), reverse=True):
        tag = marker(number, offset)
        start = text.rfind('\n', 0, pos) + 1
        if re.fullmatch(r'(?:\*\*|## )?[\d.]*\s*|[A-Za-z]+ ', text[start:pos]):
            pos = start  # a label, a heading number or a single word: mark the whole line
        if text[:pos].endswith('\n\n') or pos == 0:
            text = text[:pos] + tag + '\n' + text[pos:]
        else:
            text = text[:pos].rstrip(' ') + ' ' + tag + ' ' + text[pos:]
    return marker(1, offset) + '\n' + text


def marker(number, offset):
    """Return the page comment, with the journal page when the offset is known."""
    return f'<!-- page {number}, journal p. {number + offset} -->' if offset else f'<!-- page {number} -->'


def contents_header(body, header):
    """Prepend the contents-by-line header: the intro, then the line where each section begins."""
    names = header.get('sections', {})
    entries = []
    for i, line in enumerate(body.split('\n'), 1):
        if m := re.match(r'## (\d+)\. (.+)$', line):
            entries.append((i, f'Section {m[1]} — {names.get(m[1], m[2])}'))
        elif line == '## References':
            entries.append((i, 'References'))
    head = '<!-- toc-by-line -->\n' + header['intro'].strip() + '\n\n'
    offset = head.count('\n') + len(entries) + 1  # body line i is file line offset + i
    toc = ''.join(f'- {name}: line {i + offset}\n' for i, name in entries)
    return head + toc + '\n' + body


def convert(text, pages, config):
    """Run every step; return the Markdown and the repairs that did not match."""
    problems = []
    repairs = config.get('repair', [])
    text = headings(normalize(text))
    text = apply_repairs(text, repairs, 'before', problems)
    if config.get('bold_labels'):
        text = bold_labels(text)
    text = join_split_paragraphs(text)
    text = page_markers(text, pages, config.get('page_offset', 0), config.get('running_head'))
    text = apply_repairs(text, repairs, 'after', problems)
    text = re.sub(r'\n{3,}', '\n\n', text).rstrip() + '\n'
    if 'header' in config:
        text = contents_header(text, config['header'])
    return text, problems


def main():
    """Parse the arguments, convert, and report the repairs that did not match."""
    parser = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    parser.add_argument('marker', type=Path, help="Marker's Markdown output")
    parser.add_argument('pages', type=Path, help='the PDF, or its text with a form feed between pages')
    parser.add_argument('out', type=Path, help='the Markdown file to write')
    parser.add_argument('--repairs', type=Path, help='TOML file of repairs and settings')
    args = parser.parse_args()
    config = tomllib.loads(args.repairs.read_text(encoding='utf-8')) if args.repairs else {}
    text, problems = convert(args.marker.read_text(encoding='utf-8'), read_pages(args.pages), config)
    args.out.write_text(text, encoding='utf-8', newline='\n')
    markers = len(re.findall(r'^<!-- page \d+| <!-- page \d+', text, re.M))
    print(f'{args.out}: {markers} page markers, {len(config.get("repair", []))} repairs')
    for problem in problems:
        print('repair did not match:', problem, file=sys.stderr)
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main())
