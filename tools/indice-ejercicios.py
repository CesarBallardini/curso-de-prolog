# /// script
# requires-python = ">=3.14"
# ///
"""Genera references/ejercicios/README.md: el índice del banco de ejercicios por capítulo.

Cada archivo del banco tiene entradas `### <ID> — <título>` con una línea `- **Tema:**`
etiquetada con el temario viejo (0–11, A, X). Este script traduce esas etiquetas a los
capítulos 1–34 del plan y cuenta por capítulo, dificultad y fuente.

    uv run tools/indice-ejercicios.py
"""

import collections
import re
from pathlib import Path

BANCO = Path(__file__).resolve().parent.parent / "references" / "ejercicios"

# Etiqueta vieja -> capítulos del libro.
CAPITULOS = {
    "0": ["1"],
    "1": ["2"],
    "2": ["3"],
    "3": ["4"],
    "4": ["5"],
    "5": ["6"],
    "6": ["7"],
    "7": ["8"],
    "8": ["9-10"],
    "9": ["15-16"],
    "10": ["17"],
    "11": ["34"],
    "A": ["19"],
    "X": ["24-33"],
}
TITULOS = {
    "1": "La primera hora",
    "2": "Hechos, consultas y variables",
    "3": "Reglas y conjunciones",
    "4": "Términos y unificación",
    "5": "Cómo responde Prolog",
    "6": "Recursión",
    "7": "Listas",
    "8": "Aritmética",
    "9-10": "Backtracking y corte · Negación como falla",
    "15-16": "Todas las soluciones · Orden superior",
    "17": "Base de datos dinámica",
    "19": "Gramáticas (DCG)",
    "24-33": "Parte III (a clasificar por capítulo)",
    "34": "Prolog y SQL",
}
ORDEN = list(TITULOS)
# Etiquetas cuyo contenido no puede aparecer en la Parte I (orden superior, base dinámica, etc.).
FUERA_DE_PARTE_I = {"9", "10", "11", "A", "X"}

ENTRADA = re.compile(r"^### (.+?) — (.+)$")  # el ID puede ser un grupo: "AoP-17.2-1 a AoP-17.2-5"
ETIQUETA = re.compile(r"\b(1[01]|[0-9]|A|X)\b")


def leer(archivo):
    entradas, actual, en_codigo = [], None, False
    for linea in archivo.read_text(encoding="utf-8").splitlines():
        if linea.startswith("```"):
            en_codigo = not en_codigo
            continue
        if en_codigo:
            continue  # plantillas y código de ejemplo, no entradas
        if m := ENTRADA.match(linea):
            actual = {"id": m[1], "titulo": m[2], "tema": None, "dif": None, "sol": ""}
            entradas.append(actual)
        elif linea.startswith("## ") or (linea.startswith("### ") and actual):
            actual = None  # títulos de sección: cierran la entrada anterior
        elif actual is not None:
            if linea.startswith("- **Tema:**"):
                actual["tema"] = linea.removeprefix("- **Tema:**")
            elif linea.startswith("- **Dificultad:**") and actual["dif"] is None:
                d = re.search(r"[123]", linea)
                actual["dif"] = d[0] if d else "?"
            elif linea.startswith("- **Solución:**"):
                actual["sol"] = linea.removeprefix("- **Solución:**").strip()
    return [e for e in entradas if e["tema"] is not None]


def main():
    fuentes = {}
    for archivo in sorted(BANCO.glob("*.md")):
        if archivo.name != "README.md":
            fuentes[archivo.name] = leer(archivo)

    por_capitulo = collections.defaultdict(list)
    dificultad = collections.defaultdict(collections.Counter)
    parte_i = 0
    total = 0
    for nombre, entradas in fuentes.items():
        for e in entradas:
            total += 1
            etiquetas = set(ETIQUETA.findall(e["tema"]))
            if etiquetas and not etiquetas & FUERA_DE_PARTE_I:
                parte_i += 1
            for cap in sorted({c for t in etiquetas for c in CAPITULOS[t]}, key=ORDEN.index):
                por_capitulo[cap].append((nombre, e))
                dificultad[cap][e["dif"]] += 1

    con_solucion = sum(
        1
        for es in fuentes.values()
        for e in es
        if e["sol"] and not re.match(r"(?i)\**no\b", e["sol"])
    )

    out = [
        "# Banco de ejercicios: índice por capítulo",
        "",
        "Generado por `uv run tools/indice-ejercicios.py`; no editar a mano. Cada archivo de esta",
        "carpeta tiene en su encabezado la fuente, la URL y la licencia: una fuente sin licencia",
        "abierta o con licencia no comercial se cita y se reformula, nunca se copia.",
        "",
        f"**{total} entradas** en {sum(1 for es in fuentes.values() if es)} archivos; {con_solucion} indican una solución"
        f" (publicada o verificada); {parte_i} usan solo lo que permite la Parte I.",
        "",
        "Las entradas están etiquetadas con el temario viejo (0–11, A, X). Esta es la traducción a",
        "los capítulos del plan; una entrada con varias etiquetas aparece en varios capítulos.",
        "",
        "| Etiqueta | Capítulos |",
        "|---|---|",
    ]
    out += [f"| {t} | {', '.join(c)} |" for t, c in CAPITULOS.items()]
    out += [
        "",
        "Las etiquetas 3 (términos) y 8 (corte) también alimentan capítulos de la Parte II y III",
        "(13 Control, 24 Inspección de términos); y la etiqueta X se clasifica a mano entre los",
        "capítulos 24–33 al escribir cada uno.",
        "",
        "## Por fuente",
        "",
        "| Archivo | Entradas |",
        "|---|---|",
    ]
    out += [f"| [{n}]({n}) | {len(es)} |" for n, es in fuentes.items() if es]
    out += [
        "",
        "## Por capítulo",
        "",
        "| Capítulo | Título | Entradas | Dif. 1 | Dif. 2 | Dif. 3 |",
        "|---|---|---|---|---|---|",
    ]
    for cap in ORDEN:
        d = dificultad[cap]
        out.append(
            f"| {cap} | {TITULOS[cap]} | {len(por_capitulo[cap])} | {d['1']} | {d['2']} | {d['3']} |"
        )
    for cap in ORDEN:
        out += ["", f"## Capítulo {cap} — {TITULOS[cap]}", ""]
        grupos = collections.defaultdict(list)
        for nombre, e in por_capitulo[cap]:
            grupos[nombre].append(f"{e['id']}<sup>{e['dif']}</sup>")
        for nombre, ids in grupos.items():
            out.append(f"- [{nombre}]({nombre}): {', '.join(ids)}")
    (BANCO / "README.md").write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"{total} entradas, {len(fuentes)} archivos -> {BANCO / 'README.md'}")


if __name__ == "__main__":
    main()
