# /// script
# requires-python = ">=3.14"
# dependencies = ["piper-tts", "pymupdf"]
# ///
"""Turn a slide deck into a narrated video: each slide on screen while a voice reads its notes.

    uv run tools/video.py diapositivas/capitulo-01.odp              write diapositivas/capitulo-01.mp4
    uv run tools/video.py DECK -o OUT.mp4                            somewhere else
    uv run tools/video.py DECK --text                                print what the voice will say, and stop
    uv run tools/video.py DECK --images DIR                          use DIR/*.png instead of rendering the deck
    uv run tools/video.py DECK --keep DIR                            keep the intermediate files in DIR

`make video` runs it on every deck (`make video c=01` on one). It is a PEP 723 script: `uv run`
installs Piper and PyMuPDF in a throwaway environment, so the project needs neither.

The pipeline
------------
1. Notes. The speaker notes are read from the deck itself, in slide order, so that the pictures
   and the narration can never drift apart: from `content.xml` of an .odp (`presentation:notes`),
   or from `ppt/notesSlides` of a .pptx (pandoc's output). A slide without notes gets no voice.
   The same pass counts the visible code lines of each slide: lines whose text is all in a
   monospaced font, which is how pandoc sets code blocks.
2. Text for speech. The notes are written to be read, and Prolog notation reads badly aloud.
   `speech()` strips Markdown leftovers and backticks and reads the notation in Spanish with the
   ordered table `READINGS`: `padre/2` is «padre de aridad 2», `:-` is «si», `[H|T]` is «cabeza
   H, cola T», `_` is «variable anónima», and so on. It never rewrites the prose: extend the
   table, not the notes. Most entries cannot occur in Spanish prose and apply to the whole note;
   the few that can (`!`, `;`, `%`, a bare `=`) apply only to code, meaning monospaced runs or
   backtick spans. LibreOffice drops the fonts of the notes when it imports pandoc's .pptx, so in
   an .odp only the first kind is at work; a .pptx keeps both.
3. Voice. Piper (neural, offline) with the Argentine voice `VOICE`, one paragraph at a time with
   `PARAGRAPH_PAUSE` between paragraphs. The model is downloaded once from rhasspy/piper-voices
   into `$PIPER_VOICES`, by default `%LOCALAPPDATA%/piper-voices` (Windows) or
   `~/.local/share/piper-voices`, outside the repository.
4. Pictures. LibreOffice exports the deck to PDF (with a throwaway user profile, so a running
   LibreOffice does not get in the way) and PyMuPDF renders every page at `WIDTH` x `HEIGHT`.
   The number of pages must equal the number of slides with notes read in step 1.
5. Timing, per slide (the parameters below):
       duration = max(MIN_SLIDE, PRE_ROLL + narration + CODE_LINE * code lines + POST_ROLL)
   and `SILENT_SLIDE` instead of `MIN_SLIDE` for a slide without notes, rounded up to a tenth of
   a second. The voice starts `PRE_ROLL` after the slide appears, so the viewer sees the slide
   first; the code allowance comes after the voice, to read the code the voice has presented.
6. Assembly. The sound track is built here, sample by sample: each slide's stretch is silence,
   its narration at `PRE_ROLL`, silence to the end, so sound and picture cannot drift. The
   pictures are joined with a `CROSSFADE` (0 for plain cuts) in a single ffmpeg pass: slide k
   starts fading in at the sum of the earlier durations minus one crossfade each, which is
   exactly where its stretch of sound begins, and the fade ends long before the voice starts.
   The sound is normalised with ffmpeg's `loudnorm` in two passes (measure, then a linear gain
   to `LOUDNESS`), and the result is H.264 (yuv420p) with AAC sound, which plays everywhere.

The tool prints the timing table: slide, start, duration, narration, code lines and title.
"""

import argparse
import dataclasses
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
import wave
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

# --- Timing (seconds) ----------------------------------------------------------------------------
PRE_ROLL = 1.5  # the slide alone on screen before the voice starts
POST_ROLL = 2.0  # after the voice (and the code allowance) ends
MIN_SLIDE = 6.0  # no slide with notes is shorter
SILENT_SLIDE = 7.0  # a slide without notes (the title slide, for instance)
CODE_LINE = 0.5  # extra reading time per visible code line
CROSSFADE = 0.3  # between slides; 0 gives plain cuts
PARAGRAPH_PAUSE = 0.6  # between the paragraphs of one slide's notes
STEP = 0.1  # every duration is rounded up to a multiple of this (three frames at 30 fps)

# --- Picture and sound ---------------------------------------------------------------------------
WIDTH, HEIGHT, FPS = 1920, 1080, 30
LOUDNESS = {'I': -16.0, 'TP': -1.5, 'LRA': 11.0}  # EBU R128 target of loudnorm (spoken word)
VOICE = 'es_AR-daniela-high'
VOICE_URL = 'https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_AR/daniela/high/'

# --- Reading Prolog aloud ------------------------------------------------------------------------
# (scope, pattern, reading), applied in this order. Scope ALL: the whole note, because the
# pattern cannot occur in Spanish prose; CODE: monospaced runs and backtick spans only. Longer
# operators come before the shorter ones they contain. A reading is a string or a function of
# the match.
ALL, CODE = 'all', 'code'


def _list(match):
    head, tail = match.group(1).strip(), match.group(2).strip()
    first = 'primeros' if ',' in head else 'cabeza'
    return f' {first} {head}, cola {tail} '


READINGS = [
    (ALL, r'\b([a-z]\w*)//(\d+)\b', r'\1 de aridad \2 en gramática'),  # frase//2 (DCG)
    (ALL, r'\b([a-z]\w*)/(\d+)\b', r'\1 de aridad \2'),  # padre/2
    (ALL, r'\[\s*\]', ' lista vacía '),
    (ALL, r'\[([^\[\]|]+)\|([^\[\]|]+)\]', _list),  # [H|T], [A, B|T]
    (ALL, r'\[([^\[\]|]*)\]', r' lista \1 '),  # [a, b, c]
    (ALL, r'=\\=', ' distinto aritméticamente de '),
    (ALL, r'=:=', ' igual aritméticamente a '),
    (ALL, r'\\==', ' no idéntico a '),
    (ALL, r'==', ' idéntico a '),
    (ALL, r'=\.\.', ' univ '),
    (ALL, r'\\=', ' no unifica con '),
    (ALL, r'\\\+', ' no '),
    (ALL, r'-->', ' se reescribe como '),
    (ALL, r'\?-', ' consulta '),
    (ALL, r':-', ' si '),
    (ALL, r'->', ' entonces '),
    (ALL, r'>=', ' mayor o igual que '),
    (ALL, r'=<', ' menor o igual que '),
    (ALL, r'(?<=\s)<(?=\s)', ' menor que '),
    (ALL, r'(?<=\s)>(?=\s)', ' mayor que '),
    (ALL, r'(?<=\s)=(?=\s)', ' igual a '),
    (CODE, r'<', ' menor que '),
    (CODE, r'>', ' mayor que '),
    (CODE, r'=', ' igual a '),
    (CODE, r'!', ' corte '),
    (CODE, r';', ' punto y coma '),
    (CODE, r'%', ' comentario: '),
    (CODE, r'[()]', ' '),
    (ALL, r'(?<!\w)_(?!\w)', ' variable anónima '),  # _
    (ALL, r'(?<!\w)_(?=\w)', ' '),  # _Resto: the name is enough
    (ALL, r'(?<=\w)_(?=\w)', ' '),  # primer_multiplo
    # English words of the toplevel and of the headers, spelt for a Spanish voice. The full stop
    # of an answer inside a sentence («es true., y no…») would end the sentence aloud.
    (ALL, r'\b(true|false)\.(?=,|\s+[a-záéíóúñ])', r'\1'),
    (ALL, r'\btrue\b', 'tru'),
    (ALL, r'\bfalse\b', 'fols'),
    (ALL, r'\bsemidet\b', 'semi det'),
    (ALL, r'\bnondet\b', 'non det'),
]
READINGS = [(scope, re.compile(pattern), reading) for scope, pattern, reading in READINGS]

# Markdown that may survive in the notes: bold, italics, headings. Backticks mark code instead.
MARKDOWN = [
    (r'\*\*', ''),  # bold
    (r'(?<!\w)\*(?=\S)|(?<=\S)\*(?!\w)', ''),  # italics; never _, which is Prolog's anonymous variable
    (r'^#+\s*', ''),  # a heading
]
MARKDOWN = [(re.compile(pattern), reading) for pattern, reading in MARKDOWN]

MONO = re.compile(r'mono|courier|consol|menlo', re.IGNORECASE)

NS = {
    'a': 'http://schemas.openxmlformats.org/drawingml/2006/main',
    'p': 'http://schemas.openxmlformats.org/presentationml/2006/main',
    'r': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
    'rel': 'http://schemas.openxmlformats.org/package/2006/relationships',
    'office': 'urn:oasis:names:tc:opendocument:xmlns:office:1.0',
    'style': 'urn:oasis:names:tc:opendocument:xmlns:style:1.0',
    'text': 'urn:oasis:names:tc:opendocument:xmlns:text:1.0',
    'draw': 'urn:oasis:names:tc:opendocument:xmlns:drawing:1.0',
    'fo': 'urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0',
    'svg': 'urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0',
    'presentation': 'urn:oasis:names:tc:opendocument:xmlns:presentation:1.0',
}


def q(name):
    prefix, local = name.split(':')
    return f'{{{NS[prefix]}}}{local}'


@dataclasses.dataclass
class Slide:
    title: str
    notes: list  # paragraphs; each a list of (text, monospaced) runs
    code_lines: int
    speech: list = dataclasses.field(default_factory=list)  # the paragraphs as the voice says them
    narration: float = 0.0
    duration: float = 0.0
    start: float = 0.0


# --- Step 1: the notes and the code lines of every slide ------------------------------------------


def lines_of(runs):
    """Split a paragraph's runs (text, mono) at the line breaks, marked by a None run."""
    lines, current = [], []
    for run in runs:
        if run is None:
            lines.append(current)
            current = []
        else:
            current.append(run)
    lines.append(current)
    return lines


def count_code(paragraphs):
    count = 0
    for runs in paragraphs:
        for line in lines_of(runs):
            visible = [mono for text, mono in line if text.strip()]
            count += bool(visible) and all(visible)
    return count


def plain(runs):
    return ''.join(text for text, _ in (run for run in runs if run is not None)).strip()


def pptx_runs(paragraph):
    runs = []
    for node in paragraph:
        if node.tag in (q('a:r'), q('a:fld')):
            font = node.find('a:rPr/a:latin', NS)
            mono = font is not None and bool(MONO.search(font.get('typeface', '')))
            # A code block pandoc does not highlight is one run with its line feeds inside.
            for i, line in enumerate(node.findtext('a:t', '', NS).split('\n')):
                runs += [None] * bool(i) + [(line, mono)]
        elif node.tag == q('a:br'):
            runs.append(None)
    return runs


def read_pptx(path):
    with zipfile.ZipFile(path) as deck:

        def xml(name):
            return ET.fromstring(deck.read(name))  # noqa: S314 (our own deck)

        def targets(part):
            rels_name = str(Path(part).parent / '_rels' / (Path(part).name + '.rels')).replace('\\', '/')
            rels = xml(rels_name)
            return {
                rel.get('Id'): (rel.get('Type').rsplit('/', 1)[-1], (Path(part).parent / rel.get('Target')).as_posix())
                for rel in rels.findall('rel:Relationship', NS)
            }

        presentation = targets('ppt/presentation.xml')
        slides = []
        for slide_id in xml('ppt/presentation.xml').findall('p:sldIdLst/p:sldId', NS):
            part = os.path.normpath(presentation[slide_id.get(q('r:id'))][1]).replace('\\', '/')
            tree = xml(part)
            title = ' '.join(
                plain(pptx_runs(p))
                for sp in tree.iter(q('p:sp'))
                if (ph := sp.find('.//p:nvPr/p:ph', NS)) is not None and ph.get('type') in ('title', 'ctrTitle')
                for p in sp.iter(q('a:p'))
            )
            code = count_code([pptx_runs(p) for p in tree.iter(q('a:p'))])
            notes = []
            for kind, target in targets(part).values():
                if kind != 'notesSlide':
                    continue
                for sp in xml(os.path.normpath(target).replace('\\', '/')).iter(q('p:sp')):
                    ph = sp.find('.//p:nvPr/p:ph', NS)
                    if ph is not None and ph.get('type') == 'body':
                        notes += [pptx_runs(p) for p in sp.iter(q('a:p'))]
            slides.append(Slide(title, [runs for runs in notes if plain(runs)], code))
        return slides


def odp_mono_styles(content):
    """The names of the automatic styles whose font is monospaced."""
    faces = {
        face.get(q('style:name')): face.get(q('svg:font-family'), '') for face in content.iter(q('style:font-face'))
    }
    mono = set()
    for style in content.iter(q('style:style')):
        props = style.find('style:text-properties', NS)
        if props is None:
            continue
        name = props.get(q('style:font-name'), '')
        family = props.get(q('fo:font-family'), '') + faces.get(name, '')
        if MONO.search(name + ' ' + family):
            mono.add(style.get(q('style:name')))
    return mono


def odp_runs(paragraph, mono_styles):
    runs = []
    base = paragraph.get(q('text:style-name')) in mono_styles

    def walk(node, mono):
        if node.text:
            runs.append((node.text, mono))
        for child in node:
            if child.tag == q('text:line-break'):
                runs.append(None)
            elif child.tag == q('text:s'):
                runs.append((' ' * int(child.get(q('text:c'), '1')), mono))
            elif child.tag == q('text:tab'):
                runs.append(('\t', mono))
            else:
                style = child.get(q('text:style-name'))
                walk(child, mono if style is None else style in mono_styles)
            if child.tail:
                runs.append((child.tail, mono))

    walk(paragraph, base)
    return runs


def read_odp(path):
    with zipfile.ZipFile(path) as deck:
        content = ET.fromstring(deck.read('content.xml'))  # noqa: S314 (our own deck)
    mono_styles = odp_mono_styles(content)
    slides = []
    for page in list(content.iter(q('draw:page'))):
        notes_part = page.find('presentation:notes', NS)
        notes = []
        if notes_part is not None:
            # The notes frame only: the notes page also has a slide number field.
            notes = [
                odp_runs(p, mono_styles)
                for frame in notes_part.iter(q('draw:frame'))
                if frame.get(q('presentation:class')) == 'notes'
                for p in frame.iter(q('text:p'))
            ]
            page.remove(notes_part)
        title = ' '.join(
            plain(odp_runs(p, mono_styles))
            for frame in page.iter(q('draw:frame'))
            if frame.get(q('presentation:class')) == 'title'
            for p in frame.iter(q('text:p'))
        )
        code = count_code([odp_runs(p, mono_styles) for p in page.iter(q('text:p'))])
        slides.append(Slide(title, [runs for runs in notes if plain(runs)], code))
    return slides


def read_deck(path):
    if path.suffix == '.odp':
        return read_odp(path)
    if path.suffix == '.pptx':
        return read_pptx(path)
    sys.exit(f'{path}: expected an .odp or a .pptx')


# --- Step 2: the text the voice says ---------------------------------------------------------------


def say(text, code):
    for scope, pattern, reading in READINGS:
        if code or scope == ALL:
            text = pattern.sub(reading, text)
    return text


def speech(runs):
    """One paragraph of notes, as the voice should say it."""
    # Adjacent runs of the same kind are one piece: highlighted code comes in many runs.
    pieces = []
    for text, mono in (run if run is not None else (' ', False) for run in runs):
        if pieces and pieces[-1][1] == mono:
            pieces[-1][0] += text
        else:
            pieces.append([text, mono])
    said = []
    for text, mono in pieces:
        if mono:
            said.append(say(text, code=True))
            continue
        # Prose: backtick spans are code; the rest loses its Markdown and keeps its words.
        for i, part in enumerate(text.split('`')):
            if not i % 2:
                for pattern, reading in MARKDOWN:
                    part = pattern.sub(reading, part)
            said.append(say(part, code=bool(i % 2)))
    text = re.sub(r'\s+', ' ', ''.join(said))
    # The readings leave spaces before punctuation; not before a dot that starts a word (.pl).
    return re.sub(r'\s+([,.;:?!])(?=\s|$)', r'\1', text).strip()


# --- Step 3: the voice -----------------------------------------------------------------------------


def voice_model():
    default = Path(os.environ.get('LOCALAPPDATA') or Path.home() / '.local' / 'share') / 'piper-voices'
    folder = Path(os.environ.get('PIPER_VOICES', default))
    model = folder / f'{VOICE}.onnx'
    for name in (model.name, model.name + '.json'):
        if not (folder / name).exists():
            folder.mkdir(parents=True, exist_ok=True)
            print(f'downloading {name} into {folder}', file=sys.stderr)
            part = folder / (name + '.part')  # renamed only when complete
            urllib.request.urlretrieve(VOICE_URL + name, part)  # noqa: S310 (fixed https URL)
            part.replace(folder / name)
    return model


def synthesise(slides):
    """Fill in the narration of every slide: 16-bit mono samples (bytes) and their length."""
    from piper import PiperVoice  # only when there is something to say

    voice = PiperVoice.load(voice_model())
    rate = voice.config.sample_rate
    audio = []
    for slide in slides:
        samples = b''
        for i, paragraph in enumerate(slide.speech):
            if i:
                samples += bytes(2 * round(PARAGRAPH_PAUSE * rate))
            samples += b''.join(chunk.audio_int16_bytes for chunk in voice.synthesize(paragraph))
        slide.narration = len(samples) / 2 / rate
        audio.append(samples)
    return audio, rate


# --- Step 4: the pictures --------------------------------------------------------------------------


def soffice():
    found = os.environ.get('SOFFICE') or shutil.which('soffice')
    if found:
        # The Makefile passes Git Bash's /c/Program Files/…, which Windows cannot run as it is.
        return re.sub(r'^/([a-zA-Z])/', r'\1:/', found) if os.name == 'nt' else found
    for candidate in (r'C:\Program Files\LibreOffice\program\soffice.exe', '/usr/bin/soffice'):
        if Path(candidate).exists():
            return candidate
    sys.exit('LibreOffice (soffice) not found: set SOFFICE to its path')


def render(deck, work):
    import pymupdf

    # A profile of its own, so that an open LibreOffice window does not swallow the conversion. It
    # lives at a short path: under a long one (the --keep folder, say) LibreOffice on Windows
    # cannot create it and quits without a word. The first start on a new profile sometimes ends
    # without output too, hence one more try.
    pdf = work / (deck.stem + '.pdf')
    with tempfile.TemporaryDirectory(prefix='lo-', ignore_cleanup_errors=True) as profile:
        command = [
            soffice(),
            f'-env:UserInstallation={Path(profile).as_uri()}',
            '--headless',
            '--convert-to',
            'pdf',
            '--outdir',
            str(work),
            str(deck),
        ]
        for _ in range(2):
            done = subprocess.run(command, capture_output=True, text=True, timeout=600, check=False)  # noqa: S603
            if pdf.exists():
                break
    if done.returncode or not pdf.exists():
        sys.exit(f'LibreOffice could not export {deck} to PDF:\n{done.stdout}{done.stderr}')
    images = []
    with pymupdf.open(pdf) as document:
        for number, page in enumerate(document, 1):
            scale = min(WIDTH / page.rect.width, HEIGHT / page.rect.height)
            image = work / f'diapositiva-{number:03}.png'
            page.get_pixmap(matrix=pymupdf.Matrix(scale, scale), alpha=False).save(image)
            images.append(image)
    return images


# --- Steps 5 and 6: timing and assembly ------------------------------------------------------------


def step_up(seconds):
    return round(-(-round(seconds / STEP, 6) // 1) * STEP, 3)


def plan(slides):
    start = 0.0
    for slide in slides:
        if slide.speech:
            needed = PRE_ROLL + slide.narration + CODE_LINE * slide.code_lines + POST_ROLL
            slide.duration = step_up(max(MIN_SLIDE, needed))
        else:
            slide.duration = step_up(max(SILENT_SLIDE, PRE_ROLL + CODE_LINE * slide.code_lines + POST_ROLL))
        slide.start = round(start, 3)
        start += slide.duration - CROSSFADE
    return round(start + CROSSFADE, 3)


def write_wav(path, samples, rate):
    with wave.open(str(path), 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(rate)
        out.writeframes(samples)


def sound_track(slides, audio, rate, total, work):
    """One WAV for the whole video: each narration placed PRE_ROLL after its slide appears.

    Each narration, and the text it was made from, is also left in `work` (see --keep).
    """
    track = bytearray(2 * round(total * rate))
    for number, (slide, samples) in enumerate(zip(slides, audio, strict=True), 1):
        at = 2 * round((slide.start + PRE_ROLL) * rate)
        track[at : at + len(samples)] = samples
        if slide.speech:
            write_wav(work / f'voz-{number:03}.wav', samples, rate)
            (work / f'voz-{number:03}.txt').write_text('\n'.join(slide.speech) + '\n', encoding='utf-8', newline='\n')
    write_wav(work / 'narracion.wav', bytes(track), rate)
    return work / 'narracion.wav'


def ffmpeg(*arguments):
    command = ['ffmpeg', '-hide_banner', '-nostdin', *arguments]
    done = subprocess.run(command, capture_output=True, text=True, check=False)  # noqa: S603, S607
    if done.returncode:
        sys.exit(f'ffmpeg failed:\n{done.stderr[-3000:]}')
    return done.stderr


def loudness(media):
    """First loudnorm pass: measure the sound of a file."""
    target = ':'.join(f'{key}={value}' for key, value in LOUDNESS.items())
    report = ffmpeg('-i', str(media), '-vn', '-af', f'loudnorm={target}:print_format=json', '-f', 'null', '-')
    return json.JSONDecoder().raw_decode(report[report.rindex('{') :])[0]


def assemble(slides, images, wav, total, work, output):
    measured = loudness(wav)
    target = ':'.join(f'{key}={value}' for key, value in LOUDNESS.items())
    loudnorm = (
        f'loudnorm={target}:linear=true:measured_I={measured["input_i"]}:measured_TP={measured["input_tp"]}'
        f':measured_LRA={measured["input_lra"]}:measured_thresh={measured["input_thresh"]}'
        f':offset={measured["target_offset"]}'
    )
    inputs, graph = [], []
    for i, (slide, image) in enumerate(zip(slides, images, strict=True)):
        inputs += ['-loop', '1', '-framerate', str(FPS), '-t', f'{slide.duration:.3f}', '-i', str(image)]
        graph.append(
            f'[{i}:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=decrease,'
            f'pad={WIDTH}:{HEIGHT}:(ow-iw)/2:(oh-ih)/2:white,setsar=1,fps={FPS},format=yuv420p[s{i}]'
        )
    if CROSSFADE and len(slides) > 1:
        last = 's0'
        for i, slide in enumerate(slides[1:], 1):
            graph.append(f'[{last}][s{i}]xfade=transition=fade:duration={CROSSFADE}:offset={slide.start:.3f}[x{i}]')
            last = f'x{i}'
        graph.append(f'[{last}]null[video]')
    else:
        graph.append(''.join(f'[s{i}]' for i in range(len(slides))) + f'concat=n={len(slides)}:v=1:a=0[video]')
    graph.append(f'[{len(slides)}:a]{loudnorm},aresample=48000,aformat=channel_layouts=stereo[sound]')
    script = work / 'filtro.txt'
    script.write_text(';\n'.join(graph), encoding='utf-8', newline='\n')
    ffmpeg(
        '-y', *inputs, '-i', str(wav), '-/filter_complex', str(script),
        '-map', '[video]', '-map', '[sound]', '-t', f'{total:.3f}',
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-tune', 'stillimage', '-pix_fmt', 'yuv420p',
        '-r', str(FPS), '-c:a', 'aac', '-b:a', '160k', '-movflags', '+faststart', str(output),
    )  # fmt: skip
    return measured


def clock(seconds):
    return f'{int(seconds // 60)}:{seconds % 60:04.1f}'


def table(slides, total):
    print(f'{"#":>3}  {"start":>7}  {"dur":>5}  {"voice":>5}  {"code":>4}  title')
    for number, slide in enumerate(slides, 1):
        voice = f'{slide.narration:5.1f}' if slide.speech else '    -'
        timing = f'{clock(slide.start):>7}  {slide.duration:5.1f}  {voice}  {slide.code_lines:>4}'
        print(f'{number:>3}  {timing}  {slide.title[:60]}')
    print(f'total {clock(total)} ({total:.1f} s), {len(slides)} slides')


def build(args, work):
    slides = read_deck(args.deck)
    for slide in slides:
        slide.speech = [said for runs in slide.notes if (said := speech(runs))]
    if args.text:
        for number, slide in enumerate(slides, 1):
            print(f'--- {number}: {slide.title} ({slide.code_lines} code lines)')
            print('\n'.join(slide.speech) if slide.speech else '(no notes)')
        return
    images = sorted(args.images.glob('*.png')) if args.images else render(args.deck, work)
    if len(images) != len(slides):
        sys.exit(f'{len(images)} pictures for {len(slides)} slides: the deck and its pictures do not match')
    audio, rate = synthesise(slides)
    total = plan(slides)
    wav = sound_track(slides, audio, rate, total, work)
    before = assemble(slides, images, wav, total, work, args.output)
    after = loudness(args.output)
    table(slides, total)
    print(f'loudness (target {LOUDNESS}):')
    for name, measured in (('narration', before), ('video', after)):
        print(f'  {name:9}  {measured["input_i"]} LUFS, true peak {measured["input_tp"]} dBTP')
    print(f'wrote {args.output}')


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n', 1)[0])
    parser.add_argument('deck', type=Path, help='the .odp (or pandoc .pptx) to narrate')
    parser.add_argument('-o', '--output', type=Path, help='the video (default: the deck with .mp4)')
    parser.add_argument('--text', action='store_true', help='print the text for the voice, and stop')
    parser.add_argument('--images', type=Path, help='a folder with one PNG per slide, used instead of LibreOffice')
    parser.add_argument('--keep', type=Path, help='keep the intermediate files in this folder')
    args = parser.parse_args()
    sys.stdout.reconfigure(encoding='utf-8')  # the notes are Spanish; a Windows console is not UTF-8
    args.output = args.output or args.deck.with_suffix('.mp4')
    if args.keep:
        args.keep.mkdir(parents=True, exist_ok=True)
        build(args, args.keep)
    else:
        with tempfile.TemporaryDirectory() as work:
            build(args, Path(work))


if __name__ == '__main__':
    main()
