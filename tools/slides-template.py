#!/usr/bin/env python
"""Build diapositivas/plantilla.pptx, the reference document of the slides.

    ./tools/slides-template.py            write diapositivas/plantilla.pptx

Pandoc writes the slides of `diapositivas/capitulo-NN.md` as a .pptx whose
styles come from a reference document. This starts from pandoc's own default
(`pandoc --print-default-data-file reference.pptx`) and changes only what the
course needs:

- Verdana for titles and text, Consolas for code (pandoc sets the
  code font from the `monofont` variable of each slide file, not from here);
- a plain white background and dark, left-aligned titles in a thin band at the
  top, so the content area is as tall as the slide allows;
- body text at 16 pt, which is also the size of the code: pandoc writes code
  runs without a size, so they inherit it. At 16 pt the content area holds
  fifteen lines of code, and a line of 70 characters (35 in a column);
- paragraphs flush with the title, without the hanging indent of the default;
- the placeholders of the two-column and comparison layouts moved to match.

Every edit is a plain string replacement that must match exactly once, so a
change in pandoc's default fails loudly instead of producing a half-styled
template.
"""

import io
import shutil
import subprocess
import sys
import zipfile

import examples

TARGET = examples.ROOT / 'diapositivas' / 'plantilla.pptx'

SANS = 'Verdana'
TITLE_COLOUR = '1F3A5F'

# EMU: the slide is 9144000 x 5143500 (10 x 5.625 in, 16:9).
TOP, BOTTOM = 800000, 4900000  # the content area, below the title band
TITLE_Y, TITLE_H = 150000, 600000
HEAD_H = 420000  # the header line of the comparison layout

MASTER = 'ppt/slideMasters/slideMaster1.xml'
THEME = 'ppt/theme/theme1.xml'


def area(x, cx, y, h):
    return f'<a:off x="{x}" y="{y}"/><a:ext cx="{cx}" cy="{h}"/>'


# (file, old, new) or (file, old, new, count): every old string must occur
# exactly once in its file, or exactly count times.
EDITS = [
    # Fonts of the theme: headings and body.
    (THEME, '<a:majorFont><a:latin typeface="Calibri"/>', f'<a:majorFont><a:latin typeface="{SANS}"/>'),
    (THEME, '<a:minorFont><a:latin typeface="Calibri"/>', f'<a:minorFont><a:latin typeface="{SANS}"/>'),
    # A plain white background instead of the theme's background reference.
    (
        MASTER,
        '<p:bg><p:bgRef idx="1001"><a:schemeClr val="bg1"/></p:bgRef></p:bg>',
        '<p:bg><p:bgPr><a:solidFill><a:srgbClr val="FFFFFF"/></a:solidFill><a:effectLst/></p:bgPr></p:bg>',
    ),
    # Title band and content area of the master.
    (MASTER, area(457200, 8229600, 205979, 857250), area(457200, 8229600, TITLE_Y, TITLE_H)),
    (MASTER, area(457200, 8229600, 1200151, 3394472), area(457200, 8229600, TOP, BOTTOM - TOP)),
    # Titles: left-aligned, 28 pt, dark blue, bold.
    (
        MASTER,
        '<a:lvl1pPr algn="ctr" defTabSz="342900" rtl="0" eaLnBrk="1" latinLnBrk="0" hangingPunct="1">'
        '<a:spcBef><a:spcPct val="0"/></a:spcBef><a:buNone/><a:defRPr sz="3300" kern="1200">'
        '<a:solidFill><a:schemeClr val="tx1"/></a:solidFill>',
        '<a:lvl1pPr algn="l" defTabSz="342900" rtl="0" eaLnBrk="1" latinLnBrk="0" hangingPunct="1">'
        '<a:spcBef><a:spcPct val="0"/></a:spcBef><a:buNone/><a:defRPr sz="2800" b="1" kern="1200">'
        f'<a:solidFill><a:srgbClr val="{TITLE_COLOUR}"/></a:solidFill>',
    ),
    # Body text flush with the title, with no hanging indent, and some space
    # between blocks (a code block and the run after it, for instance). The
    # hanging indent of pandoc's default put the first line of a block that
    # pandoc does not highlight, written as one run with line feeds, 0.375 in
    # to the left of the rest, and took those 0.375 in from every code line.
    (
        MASTER,
        '<a:lvl1pPr marL="342900" indent="-342900" algn="l" defTabSz="342900" rtl="0" eaLnBrk="1" '
        'latinLnBrk="0" hangingPunct="1"><a:spcBef><a:spcPct val="20000"/></a:spcBef>',
        '<a:lvl1pPr marL="0" indent="0" algn="l" defTabSz="342900" rtl="0" eaLnBrk="1" '
        'latinLnBrk="0" hangingPunct="1"><a:spcBef><a:spcPts val="1200"/></a:spcBef>',
    ),
    # Section titles as written, not in capitals.
    (
        'ppt/slideLayouts/slideLayout3.xml',
        '<a:defRPr sz="3000" b="1" cap="all"/>',
        '<a:defRPr sz="3000" b="1"/>',
    ),
    # Body text, and with it the code, at 16 pt.
    (
        MASTER,
        '<a:buChar char="•"/><a:defRPr sz="2400" kern="1200">',
        '<a:buChar char="•"/><a:defRPr sz="1600" kern="1200">',
    ),
    # Two Content: both columns start and end with the content area.
    (
        'ppt/slideLayouts/slideLayout4.xml',
        area(457200, 4038600, 1200151, 3394472),
        area(457200, 4038600, TOP, BOTTOM - TOP),
    ),
    (
        'ppt/slideLayouts/slideLayout4.xml',
        area(4648200, 4038600, 1200151, 3394472),
        area(4648200, 4038600, TOP, BOTTOM - TOP),
    ),
    # Comparison: a header line over each column, then the columns.
    (
        'ppt/slideLayouts/slideLayout5.xml',
        area(457200, 4040188, 1151335, 479822),
        area(457200, 4040188, TOP, HEAD_H),
    ),
    (
        'ppt/slideLayouts/slideLayout5.xml',
        area(457200, 4040188, 1631156, 2963466),
        area(457200, 4040188, TOP + HEAD_H, BOTTOM - TOP - HEAD_H),
    ),
    (
        'ppt/slideLayouts/slideLayout5.xml',
        area(4645026, 4041775, 1151335, 479822),
        area(4645026, 4041775, TOP, HEAD_H),
    ),
    (
        'ppt/slideLayouts/slideLayout5.xml',
        area(4645026, 4041775, 1631156, 2963466),
        area(4645026, 4041775, TOP + HEAD_H, BOTTOM - TOP - HEAD_H),
    ),
    # The column placeholders of both layouts set their own, larger text size;
    # code in a column is the same 16 pt as everywhere else.
    (
        'ppt/slideLayouts/slideLayout4.xml',
        '<a:lvl1pPr><a:defRPr sz="2100"/></a:lvl1pPr>',
        '<a:lvl1pPr><a:defRPr sz="1600"/></a:lvl1pPr>',
        2,
    ),
    (
        'ppt/slideLayouts/slideLayout5.xml',
        '<a:lvl1pPr><a:defRPr sz="1800"/></a:lvl1pPr>',
        '<a:lvl1pPr><a:defRPr sz="1600"/></a:lvl1pPr>',
        2,
    ),
]


def default_reference():
    pandoc = shutil.which('pandoc')
    if pandoc is None:
        sys.exit('pandoc is not on PATH')
    done = subprocess.run(  # noqa: S603
        [pandoc, '--print-default-data-file', 'reference.pptx'], capture_output=True, check=True
    )
    return done.stdout


def main():
    source = zipfile.ZipFile(io.BytesIO(default_reference()))
    files = {info.filename: source.read(info) for info in source.infolist()}
    for name, old, new, *count in EDITS:
        text = files[name].decode('utf-8')
        wanted = count[0] if count else 1
        if text.count(old) != wanted:
            sys.exit(f'{name}: expected {wanted} of {old[:60]!r}…, found {text.count(old)}')
        files[name] = text.replace(old, new).encode('utf-8')
    TARGET.parent.mkdir(exist_ok=True)
    with zipfile.ZipFile(TARGET, 'w', zipfile.ZIP_DEFLATED) as out:
        for info in source.infolist():
            # A fixed date keeps the file byte-for-byte the same from one run to the next.
            fixed = zipfile.ZipInfo(info.filename, date_time=(2026, 1, 1, 0, 0, 0))
            fixed.compress_type = zipfile.ZIP_DEFLATED
            out.writestr(fixed, files[info.filename])
    print(f'wrote {TARGET.relative_to(examples.ROOT).as_posix()}')


if __name__ == '__main__':
    main()
