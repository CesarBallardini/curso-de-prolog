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
    r"^\s*(\?-|:-|%)"            # query, directive, comment
    r"|:-\s*$|:-\s"              # rule neck
    r"|^[a-z]\w*\(.*\)\s*[.,;]?\s*$"  # fact/goal: name(args).
    r"|^\s*[a-z]\w*\s*\.\s*$"    # atom goal: nl.
)


def slug(text):
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")[:60]


def norm(text):
    return re.sub(r"[^a-z0-9]", "", text.lower())


def is_mono(font, code_fonts):
    return any(f.lower() in font.lower() for f in code_fonts)


def page_lines(page, code_fonts):
    """Yield (x0, y0, y1, size, text, markdown, mono_ratio) per text line."""
    out = []
    for block in page.get_text("dict", sort=True)["blocks"]:
        for line in block.get("lines", []):
            spans = [s for s in line["spans"] if s["text"].strip()]
            if not spans:
                continue
            text = "".join(s["text"] for s in line["spans"]).rstrip()
            mono = sum(len(s["text"]) for s in spans if is_mono(s["font"], code_fonts))
            md = []
            for s in line["spans"]:
                t = s["text"]
                core = t.strip()
                if not core:
                    md.append(t)
                    continue
                lead, trail = t[: len(t) - len(t.lstrip())], t[len(t.rstrip()):]
                if is_mono(s["font"], code_fonts):
                    core = f"`{core}`"
                elif "Italic" in s["font"] or s["flags"] & 2:
                    core = f"*{core}*"
                md.append(lead + core + trail)
            md = re.sub(r"`\s*`", " ", "".join(md)).rstrip()
            md = re.sub(r"\*\s*\*", " ", md)
            size = max(s["size"] for s in spans)
            x0, y0, _, y1 = line["bbox"]
            out.append((x0, y0, y1, size, text, md, mono / max(1, sum(len(s["text"]) for s in spans))))
    return out


def strip_furniture(lines, titles):
    """Drop the running head (top row of the page) and a bare bottom page number.

    Scans are offset, so "top of page" means the first text row, not a fixed band.
    """
    if not lines:
        return lines
    top = min(ln[1] for ln in lines)
    head = [ln for ln in lines if ln[1] < top + 4]
    text = " ".join(ln[4].strip() for ln in head)
    if len(text) < 90 and (re.search(r"(^|\s)[\divxlc]+(\s|$)", text) or norm(text) in titles
                           or any(norm(ln[4]) in titles for ln in head)):
        lines = [ln for ln in lines if ln not in head]
    if lines and re.fullmatch(r"[\divxlc]+", lines[-1][4].strip()):
        lines = lines[:-1]
    return lines


def fix_text(s):
    s = s.replace("­", "").replace("ﬁ", "fi").replace("ﬂ", "fl")
    return re.sub(r"[ \t]+", " ", s)


def convert_pages(doc, first, last, headings, code_fonts, titles):
    """Render pages [first, last) as Markdown. headings: {page: [(level, title)]}."""
    out = []
    para = []
    code = []
    item_x = None  # x of the current list item's text, when para is a list item
    bullet = False

    def flush_para():
        nonlocal item_x
        if para:
            text = ""
            for piece in para:
                if text.endswith("-") and piece[:1].islower():
                    text = text[:-1] + piece
                else:
                    text = f"{text} {piece}" if text else piece
            out.append(fix_text(text).strip())
            out.append("")
            para.clear()
        item_x = None

    def flush_code():
        if code:
            base = min(x for x, _ in code)
            out.append("```prolog")
            for x, t in code:
                out.append(" " * round((x - base) / 5) + t.strip())
            out.append("```")
            out.append("")
            code.clear()

    top_title = None
    if headings.get(first) and headings[first][0][0] == 1:
        lvl, title = headings[first].pop(0)
        top_title = norm(title)
        out += ["# " + title, ""]
    for pno in range(first, last):
        page = doc[pno]
        lines = strip_furniture(page_lines(page, code_fonts), titles)
        if not lines:
            continue
        pending = list(headings.get(pno, []))
        body = [round(ln[0]) for ln in lines if ln[6] < 0.5]
        margin = collections.Counter(body).most_common(1)[0][0] if body else lines[0][0]
        sizes = [ln[3] for ln in lines if ln[6] < 0.5]
        body_size = collections.Counter(round(s) for s in sizes).most_common(1)[0][0] if sizes else 10
        out.append(f"<!-- page {pno + 1} -->")
        prev_y1 = None
        for x0, y0, y1, size, text, md, mono in lines:
            t = text.strip()
            # Outline headings (matched by text on their own page).
            hit = next((h for h in pending if norm(t) and norm(h[1]).startswith(norm(t)[:25])
                        and len(norm(t)) >= min(6, len(norm(h[1])))), None)
            if hit:
                flush_para(); flush_code()
                pending.remove(hit)
                out.append("#" * hit[0] + " " + hit[1].strip())
                out.append("")
                prev_y1 = y1
                continue
            if pno == first and top_title and (re.fullmatch(r"[\dA-Z]{1,2}", t)
                    or norm(t) and norm(t) in top_title and size > body_size * 1.1):
                prev_y1 = y1
                continue
            if norm(t) in titles and size > body_size * 1.1:
                prev_y1 = y1
                continue  # remainder of a multi-line heading already emitted
            indented = x0 - margin
            # A run of three plain words outside inline code means prose, whatever the font.
            prose = re.search(r"\b[a-z]{2,} [a-z]{2,} [a-z]{2,}\b", re.sub(r"`[^`]*`", "", md))
            looks_code = not prose and (mono >= 0.5 or (indented > 12 and CODE_SHAPE.search(t))
                                        or (code and indented > 12))
            if looks_code:
                flush_para()
                code.append((x0, t))
                prev_y1 = y1
                continue
            flush_code()
            if re.fullmatch(r"[•�●▪·–-]", t):
                flush_para()
                bullet = True
                prev_y1 = y1
                continue
            if bullet:
                bullet = False
                para.append("- " + md.strip())
                item_x = x0
                prev_y1 = y1
                continue
            if item_x is not None and abs(x0 - item_x) < 4 and not (prev_y1 is not None and y0 - prev_y1 > (y1 - y0) * 0.9):
                para.append(md.strip())
                prev_y1 = y1
                continue
            gap = prev_y1 is not None and y0 - prev_y1 > (y1 - y0) * 0.9
            if para and (gap or indented > 6 or re.match(r"^([•\-–]|\(?[a-z0-9]\)|\d+\.\s)", t)):
                flush_para()
            if size > body_size * 1.15 and len(t) < 90 and not para:
                out.append(f"**{fix_text(t)}**")
                out.append("")
            else:
                para.append(md.strip())
            prev_y1 = y1
        # Paragraphs flow across pages; code blocks do not need to.
        flush_code()
    flush_para()
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf")
    ap.add_argument("out")
    ap.add_argument("--code-fonts", default="Courier")
    ap.add_argument("--split-level", type=int, default=1,
                    help="outline level whose entries start a new file")
    args = ap.parse_args()
    code_fonts = [f for f in args.code_fonts.split(",") if f]

    doc = pymupdf.open(args.pdf)
    toc = [(lvl, title.strip(), page - 1) for lvl, title, page in doc.get_toc()]
    titles = {norm(t) for _, t, _ in toc}
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    # A file starts at each entry of level <= split-level.
    starts = [i for i, (lvl, _, _) in enumerate(toc) if lvl <= args.split_level]
    index = ["# " + Path(args.pdf).stem, ""]
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
        name = f"{n:02d}-{slug(title)}.md"
        (out / name).write_text(md + "\n", encoding="utf-8")
        index.append(f"- [{title}]({name}) — pages {page + 1}–{end_page}")
        print(f"{name}: pages {page + 1}-{end_page}")
    (out / "README.md").write_text("\n".join(index) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
