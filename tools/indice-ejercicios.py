# /// script
# requires-python = ">=3.14"
# ///
"""Generate references/ejercicios/README.md: the exercise bank indexed by chapter.

Every file of the bank holds entries `### <ID> — <title>` with a `- **Capítulos:**` line that
lists the chapters of the course where the entry serves as an exercise, primary chapter first
(retagged on 2026-09-24). The older `- **Tema:**` line, with the 0-11/A/X scheme of the first
syllabus, stays in each entry as history and is no longer read. The chapter titles come from the
`# Capítulo N — Título` heading of each chapter page.

The index counts the entries by chapter (all tags, and primary tag), by difficulty and by source,
and fails if an entry has a Tema line but no Capítulos line, or a chapter outside the book.

Each Spanish literal is either a marker the bank files contain or text of the generated page.

    uv run tools/indice-ejercicios.py
"""

import collections
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BANK = ROOT / 'references' / 'ejercicios'
DOCS = ROOT / 'docs'
LAST_OF_PART_1 = 12
PARTS = [(1, 12, 'Parte I'), (13, 30, 'Parte II'), (31, 38, 'Parte III'), (39, 39, 'Prolog y SQL')]

ENTRY = re.compile(r'^### (.+?) — (.+)$')  # the ID may be a group: "AoP-17.2-1 a AoP-17.2-5"
HEADING = re.compile(r'^# Capítulo (\d+) — (.+)$', re.M)


def chapter_titles():
    titles = {}
    for page in DOCS.glob('capitulo-*/index.md'):
        if m := HEADING.search(page.read_text(encoding='utf-8')):
            titles[int(m[1])] = m[2].strip()
    return dict(sorted(titles.items()))


def read_entries(path):
    entries, current, in_code = [], None, False
    for line in path.read_text(encoding='utf-8').splitlines():
        if line.startswith('```'):
            in_code = not in_code
            continue
        if in_code:
            continue  # templates and sample code, not entries
        if m := ENTRY.match(line):
            current = {'id': m[1], 'title': m[2], 'topic': None, 'chapters': None, 'difficulty': None, 'solution': ''}
            entries.append(current)
        elif line.startswith('## ') or (line.startswith('### ') and current):
            current = None  # a section heading closes the previous entry
        elif current is not None:
            if line.startswith('- **Tema:**'):
                current['topic'] = line.removeprefix('- **Tema:**')
            elif line.startswith('- **Capítulos:**'):
                current['chapters'] = [int(n) for n in re.findall(r'\d+', line)]
            elif line.startswith('- **Dificultad:**') and current['difficulty'] is None:
                found = re.search(r'[123]', line)
                current['difficulty'] = found[0] if found else '?'
            elif line.startswith('- **Solución:**'):
                current['solution'] = line.removeprefix('- **Solución:**').strip()
    return [e for e in entries if e['topic'] is not None]


def problem(name, entry, titles):
    """Why an entry cannot be indexed, or None when it can."""
    chapters = entry['chapters']
    if not chapters:
        return f'{name}: {entry["id"]} has no Capítulos line'
    if unknown := [c for c in chapters if c not in titles]:
        return f'{name}: {entry["id"]} names chapters outside the book: {unknown}'
    return None


def count(sources, titles):
    """Index the entries by chapter, or exit listing the ones that cannot be indexed."""
    problems = []
    index = {
        'by_chapter': collections.defaultdict(list),
        'primary': collections.Counter(),
        'difficulty': collections.defaultdict(collections.Counter),
        'part_i': 0,
        'total': 0,
        'with_solution': 0,
    }
    for name, entries in sources.items():
        for entry in entries:
            index['total'] += 1
            if found := problem(name, entry, titles):
                problems.append(found)
                continue
            chapters = entry['chapters']
            if max(chapters) <= LAST_OF_PART_1:
                index['part_i'] += 1
            if entry['solution'] and not re.match(r'(?i)\**no\b', entry['solution']):
                index['with_solution'] += 1
            index['primary'][chapters[0]] += 1
            for chapter in dict.fromkeys(chapters):
                index['by_chapter'][chapter].append((name, entry, chapter == chapters[0]))
                index['difficulty'][chapter][entry['difficulty']] += 1
    if problems:
        print('\n'.join(problems), file=sys.stderr)
        sys.exit(1)
    return index


def main():
    titles = chapter_titles()
    sources = {}
    for path in sorted(BANK.glob('*.md')):
        if path.name != 'README.md':
            sources[path.name] = read_entries(path)
    index = count(sources, titles)
    by_chapter, primary, difficulty = index['by_chapter'], index['primary'], index['difficulty']
    total, with_solution, part_i = index['total'], index['with_solution'], index['part_i']

    out = [
        '# Banco de ejercicios: índice por capítulo',
        '',
        'Generado por `uv run tools/indice-ejercicios.py`; no editar a mano. Cada archivo de esta',
        'carpeta tiene en su encabezado la fuente, la URL y la licencia: una fuente sin licencia',
        'abierta o con licencia no comercial se cita y se reformula, nunca se copia.',
        '',
        f'**{total} entradas** en {sum(1 for es in sources.values() if es)} archivos;'
        f' {with_solution} indican una solución (publicada o verificada);'
        f' {part_i} usan solo lo que permite la Parte I.',
        '',
        'Cada entrada tiene una línea `- **Capítulos:**` con los capítulos del curso donde sirve',
        'como ejercicio; el primero es el capítulo principal: el primero cuyas herramientas',
        'alcanzan para resolverla y cuyo tema practica (etiquetado del 2026-09-24). La línea',
        '`- **Tema:**` conserva el etiquetado del temario anterior y ya no se usa.',
        '',
        'En la lista de cada capítulo, **negrita** marca las entradas cuyo capítulo principal es',
        'ese; las demás lo tienen como capítulo adicional.',
        '',
        '## Por fuente',
        '',
        '| Archivo | Entradas |',
        '|---|---|',
    ]
    out += [f'| [{n}]({n}) | {len(es)} |' for n, es in sources.items() if es]
    out += [
        '',
        '## Por capítulo',
        '',
        '| Capítulo | Título | Entradas | Principal | Dif. 1 | Dif. 2 | Dif. 3 |',
        '|---|---|---|---|---|---|---|',
    ]
    for first, last, part in PARTS:
        out.append(f'| | **{part}** | | | | | |')
        for chapter in range(first, last + 1):
            counts = difficulty[chapter]
            out.append(
                f'| {chapter} | {titles[chapter]} | {len(by_chapter[chapter])} | {primary[chapter]} |'
                f' {counts["1"]} | {counts["2"]} | {counts["3"]} |'
            )
    for chapter, title in titles.items():
        out += ['', f'## Capítulo {chapter} — {title}', '']
        if not by_chapter[chapter]:
            out.append('Sin entradas.')
            continue
        groups = collections.defaultdict(list)
        for name, entry, is_primary in by_chapter[chapter]:
            label = f'{entry["id"]}<sup>{entry["difficulty"]}</sup>'
            groups[name].append(f'**{label}**' if is_primary else label)
        for name, ids in groups.items():
            out.append(f'- [{name}]({name}): {", ".join(ids)}')
    (BANK / 'README.md').write_text('\n'.join(out) + '\n', encoding='utf-8', newline='\n')
    print(f'{total} entradas, {len(sources)} archivos -> {BANK / "README.md"}')


if __name__ == '__main__':
    main()
