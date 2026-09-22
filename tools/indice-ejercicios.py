# /// script
# requires-python = ">=3.14"
# ///
"""Generate references/ejercicios/README.md: the exercise bank indexed by chapter.

Every file of the bank holds entries `### <ID> — <title>` whose `- **Tema:**` line carries one
or more tags of the 0-11/A/X scheme. CHAPTERS translates each tag into chapters of the course,
and the index counts the entries by chapter, by difficulty and by source.

Each Spanish literal is either a marker the bank files contain or text of the generated page.

    uv run tools/indice-ejercicios.py
"""

import collections
import re
from pathlib import Path

BANK = Path(__file__).resolve().parent.parent / 'references' / 'ejercicios'

# Tag carried by a bank entry -> chapters of the course.
CHAPTERS = {
    '0': ['1'],
    '1': ['2'],
    '2': ['3'],
    '3': ['4'],
    '4': ['5'],
    '5': ['6'],
    '6': ['7'],
    '7': ['8'],
    '8': ['9-10'],
    '9': ['15-16'],
    '10': ['17'],
    '11': ['34'],
    'A': ['19'],
    'X': ['24-33'],
}
TITLES = {
    '1': 'La primera hora',
    '2': 'Hechos, consultas y variables',
    '3': 'Reglas y conjunciones',
    '4': 'Términos y unificación',
    '5': 'Cómo responde Prolog',
    '6': 'Recursión',
    '7': 'Listas',
    '8': 'Aritmética',
    '9-10': 'Backtracking y corte · Negación como falla',
    '15-16': 'Todas las soluciones · Orden superior',
    '17': 'Base de datos dinámica',
    '19': 'Gramáticas (DCG)',
    '24-33': 'Parte III (a clasificar por capítulo)',
    '34': 'Prolog y SQL',
}
ORDER = list(TITLES)
# Tags whose content cannot appear in Part I (higher order, dynamic database, and so on).
OUTSIDE_PART_I = {'9', '10', '11', 'A', 'X'}

ENTRY = re.compile(r'^### (.+?) — (.+)$')  # the ID may be a group: "AoP-17.2-1 a AoP-17.2-5"
TAG = re.compile(r'\b(1[01]|[0-9]|A|X)\b')


def read_entries(path):
    entries, current, in_code = [], None, False
    for line in path.read_text(encoding='utf-8').splitlines():
        if line.startswith('```'):
            in_code = not in_code
            continue
        if in_code:
            continue  # templates and sample code, not entries
        if m := ENTRY.match(line):
            current = {'id': m[1], 'title': m[2], 'topic': None, 'difficulty': None, 'solution': ''}
            entries.append(current)
        elif line.startswith('## ') or (line.startswith('### ') and current):
            current = None  # a section heading closes the previous entry
        elif current is not None:
            if line.startswith('- **Tema:**'):
                current['topic'] = line.removeprefix('- **Tema:**')
            elif line.startswith('- **Dificultad:**') and current['difficulty'] is None:
                found = re.search(r'[123]', line)
                current['difficulty'] = found[0] if found else '?'
            elif line.startswith('- **Solución:**'):
                current['solution'] = line.removeprefix('- **Solución:**').strip()
    return [e for e in entries if e['topic'] is not None]


def main():
    sources = {}
    for path in sorted(BANK.glob('*.md')):
        if path.name != 'README.md':
            sources[path.name] = read_entries(path)

    by_chapter = collections.defaultdict(list)
    difficulty = collections.defaultdict(collections.Counter)
    part_i = 0
    total = 0
    for name, entries in sources.items():
        for entry in entries:
            total += 1
            tags = set(TAG.findall(entry['topic']))
            if tags and not tags & OUTSIDE_PART_I:
                part_i += 1
            for chapter in sorted({c for t in tags for c in CHAPTERS[t]}, key=ORDER.index):
                by_chapter[chapter].append((name, entry))
                difficulty[chapter][entry['difficulty']] += 1

    with_solution = sum(
        1 for es in sources.values() for e in es if e['solution'] and not re.match(r'(?i)\**no\b', e['solution'])
    )

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
        'Las entradas están etiquetadas con el temario viejo (0–11, A, X). Esta es la traducción a',
        'los capítulos del plan; una entrada con varias etiquetas aparece en varios capítulos.',
        '',
        '| Etiqueta | Capítulos |',
        '|---|---|',
    ]
    out += [f'| {t} | {", ".join(c)} |' for t, c in CHAPTERS.items()]
    out += [
        '',
        'Las etiquetas 3 (términos) y 8 (corte) también alimentan capítulos de la Parte II y III',
        '(13 Control, 24 Inspección de términos); y la etiqueta X se clasifica a mano entre los',
        'capítulos 24–33 al escribir cada uno.',
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
        '| Capítulo | Título | Entradas | Dif. 1 | Dif. 2 | Dif. 3 |',
        '|---|---|---|---|---|---|',
    ]
    for chapter in ORDER:
        counts = difficulty[chapter]
        out.append(
            f'| {chapter} | {TITLES[chapter]} | {len(by_chapter[chapter])} |'
            f' {counts["1"]} | {counts["2"]} | {counts["3"]} |'
        )
    for chapter in ORDER:
        out += ['', f'## Capítulo {chapter} — {TITLES[chapter]}', '']
        groups = collections.defaultdict(list)
        for name, entry in by_chapter[chapter]:
            groups[name].append(f'{entry["id"]}<sup>{entry["difficulty"]}</sup>')
        for name, ids in groups.items():
            out.append(f'- [{name}]({name}): {", ".join(ids)}')
    (BANK / 'README.md').write_text('\n'.join(out) + '\n', encoding='utf-8')
    print(f'{total} entradas, {len(sources)} archivos -> {BANK / "README.md"}')


if __name__ == '__main__':
    main()
