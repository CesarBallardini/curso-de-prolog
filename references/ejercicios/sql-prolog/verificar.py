"""Verifica los ejercicios PAR-n de la unidad 11 (Prolog y SQL).

Para cada ejercicio ejecuta la solución SQL sobre una base SQLite nueva en
memoria (creada con schema.sql) y la solución Prolog (par/2 en consultas.pl,
con datos.pl) en SWI-Prolog, y compara los dos resultados.

Uso (desde cualquier directorio):

    uv run -p 3.14 python verificar.py          # resumen
    uv run -p 3.14 python verificar.py -v       # muestra cada resultado

Modos de comparación:

    bolsa     mismas filas con las mismas repeticiones, en cualquier orden
    orden     mismas filas en el mismo orden (ORDER BY)
    difieren  los resultados DEBEN ser distintos (ejercicios "dónde difieren")
    esperado  sólo Prolog (sql=None) o sólo SQL (prolog=False): se compara
              contra las filas de `esperado`

Requiere `swipl` (SWI-Prolog 9.x) en el PATH.
"""

from __future__ import annotations

import json
import sqlite3
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

DIR = Path(__file__).resolve().parent
SCHEMA = (DIR / "schema.sql").read_text(encoding="utf-8")


@dataclass
class Par:
    id: str
    sql: str | None
    modo: str = "bolsa"
    esperado: list | None = None
    prolog: bool = True


PARES: list[Par] = [
    # ---------------- Esquema académico: selección, proyección, joins ----------------
    Par("1", "SELECT legajo, nombre FROM alumnos WHERE carrera = 'sistemas';"),
    Par("2", "SELECT nombre, carrera, ingreso FROM alumnos\nWHERE ingreso >= 2024 AND carrera <> 'civil';"),
    Par("3", "SELECT carrera FROM alumnos;"),
    Par("4", "SELECT DISTINCT carrera FROM alumnos\nORDER BY carrera;", modo="orden"),
    Par("5", "SELECT ingreso, nombre FROM alumnos\nORDER BY ingreso, nombre;", modo="orden"),
    Par("6", "SELECT a.nombre, i.nota\nFROM alumnos a JOIN inscripciones i ON a.legajo = i.legajo\nWHERE i.materia = 'am1';"),
    Par(
        "7",
        "SELECT a.nombre, m.nombre, i.nota\n"
        "FROM inscripciones i\n"
        "JOIN alumnos  a ON a.legajo = i.legajo\n"
        "JOIN materias m ON m.codigo = i.materia\n"
        "WHERE i.nota >= 6;",
    ),
    Par(
        "8",
        "SELECT a1.nombre, a2.nombre, a1.carrera\n"
        "FROM alumnos a1 JOIN alumnos a2\n"
        "  ON a1.carrera = a2.carrera AND a1.legajo < a2.legajo;",
    ),
    Par(
        "9",
        "SELECT legajo FROM inscripciones WHERE materia = 'am1'\n"
        "UNION\n"
        "SELECT legajo FROM inscripciones WHERE materia = 'log'\n"
        "ORDER BY legajo;",
        modo="orden",
    ),
    Par(
        "10",
        "SELECT legajo FROM inscripciones WHERE materia = 'am1'\n"
        "UNION ALL\n"
        "SELECT legajo FROM inscripciones WHERE materia = 'log';",
    ),
    Par(
        "11",
        "SELECT legajo FROM inscripciones WHERE materia = 'am1'\n"
        "INTERSECT\n"
        "SELECT legajo FROM inscripciones WHERE materia = 'alg';",
    ),
    Par(
        "12",
        "SELECT legajo FROM inscripciones WHERE materia = 'am1'\n"
        "EXCEPT\n"
        "SELECT legajo FROM inscripciones WHERE materia = 'alg';",
    ),
    Par(
        "13",
        "SELECT a.legajo, a.nombre FROM alumnos a\n"
        "WHERE NOT EXISTS (SELECT * FROM inscripciones i\n"
        "                  WHERE i.legajo = a.legajo);",
    ),
    Par(
        "14",
        "SELECT a.legajo, a.nombre FROM alumnos a\n"
        "WHERE NOT EXISTS (SELECT * FROM inscripciones i\n"
        "                  WHERE i.legajo = a.legajo);",
        modo="difieren",
    ),
    Par(
        "15",
        "CREATE VIEW aprobadas AS\n"
        "  SELECT legajo, materia, nota FROM inscripciones\n"
        "  WHERE nota >= 6;\n"
        "\n"
        "SELECT materia FROM aprobadas WHERE legajo = 101;",
    ),
    Par(
        "16",
        "SELECT a.legajo, a.nombre FROM alumnos a\n"
        "WHERE NOT EXISTS (\n"
        "  SELECT * FROM materias m\n"
        "  WHERE m.anio = 1\n"
        "    AND NOT EXISTS (SELECT * FROM inscripciones i\n"
        "                    WHERE i.legajo = a.legajo\n"
        "                      AND i.materia = m.codigo\n"
        "                      AND i.nota >= 6));",
    ),
    Par(
        "16b",
        "SELECT a.legajo, a.nombre FROM alumnos a\n"
        "WHERE NOT EXISTS (\n"
        "  SELECT * FROM materias m\n"
        "  WHERE m.anio = 1\n"
        "    AND NOT EXISTS (SELECT * FROM inscripciones i\n"
        "                    WHERE i.legajo = a.legajo\n"
        "                      AND i.materia = m.codigo\n"
        "                      AND i.nota >= 6));",
    ),
    # ---------------- Agregados ----------------
    Par("17", "SELECT COUNT(*) FROM alumnos WHERE carrera = 'sistemas';"),
    Par("18", "SELECT carrera, COUNT(*) FROM alumnos\nGROUP BY carrera;"),
    Par(
        "19",
        "SELECT m.codigo, COUNT(i.legajo)\n"
        "FROM materias m LEFT JOIN inscripciones i ON i.materia = m.codigo\n"
        "GROUP BY m.codigo;",
    ),
    Par(
        "20",
        "SELECT legajo, AVG(nota) FROM inscripciones\n"
        "WHERE nota IS NOT NULL\n"
        "GROUP BY legajo;",
    ),
    Par(
        "21",
        "SELECT a.nombre, i.nota\n"
        "FROM inscripciones i JOIN alumnos a ON a.legajo = i.legajo\n"
        "WHERE i.materia = 'log'\n"
        "  AND i.nota = (SELECT MAX(nota) FROM inscripciones\n"
        "                WHERE materia = 'log');",
    ),
    Par(
        "22",
        "SELECT a.nombre, COUNT(*)\n"
        "FROM alumnos a JOIN inscripciones i ON i.legajo = a.legajo\n"
        "WHERE i.nota >= 6\n"
        "GROUP BY a.legajo, a.nombre\n"
        "HAVING COUNT(*) >= 3;",
    ),
    # ---------------- Esquema empresa ----------------
    Par(
        "23",
        "SELECT e.nombre, j.nombre\n"
        "FROM empleados e JOIN empleados j ON e.jefe = j.id;",
    ),
    Par(
        "24",
        "SELECT e.nombre, j.nombre\n"
        "FROM empleados e LEFT JOIN empleados j ON e.jefe = j.id;",
    ),
    Par(
        "25",
        "SELECT e.nombre, d.nombre\n"
        "FROM empleados e JOIN departamentos d ON e.depto = d.codigo\n"
        "WHERE d.ciudad = 'rosario';",
    ),
    Par(
        "26",
        "SELECT d.codigo FROM departamentos d\n"
        "WHERE NOT EXISTS (SELECT * FROM empleados e\n"
        "                  WHERE e.depto = d.codigo);",
    ),
    Par(
        "27",
        "SELECT depto, SUM(salario) FROM empleados\n"
        "GROUP BY depto\n"
        "HAVING SUM(salario) > 1000000;",
    ),
    Par(
        "28",
        "SELECT e.depto, e.nombre, e.salario FROM empleados e\n"
        "WHERE e.salario = (SELECT MAX(salario) FROM empleados e2\n"
        "                   WHERE e2.depto = e.depto);",
    ),
    Par(
        "29",
        "SELECT nombre, salario FROM empleados\nORDER BY salario DESC\nLIMIT 3;",
        modo="orden",
    ),
    Par(
        "30",
        "SELECT id, nombre FROM empleados\n"
        "WHERE id NOT IN (SELECT jefe FROM empleados);",
        modo="difieren",
    ),
    Par(
        "31",
        "SELECT e.id, e.nombre FROM empleados e\n"
        "WHERE NOT EXISTS (SELECT * FROM empleados s\n"
        "                  WHERE s.jefe = e.id);",
    ),
    Par("32", "SELECT nombre FROM empleados WHERE jefe <> 1;", modo="difieren"),
    Par("32b", "SELECT nombre FROM empleados WHERE jefe <> 1;"),
    # ---------------- Recursión ----------------
    Par(
        "33",
        "WITH RECURSIVE subordinado(id) AS (\n"
        "  SELECT id FROM empleados WHERE jefe = 3\n"
        "  UNION\n"
        "  SELECT e.id FROM empleados e JOIN subordinado s ON e.jefe = s.id\n"
        ")\n"
        "SELECT e.id, e.nombre FROM empleados e JOIN subordinado s ON e.id = s.id;",
    ),
    Par(
        "34",
        "WITH RECURSIVE nivel(id, k) AS (\n"
        "  SELECT id, 0 FROM empleados WHERE jefe IS NULL\n"
        "  UNION\n"
        "  SELECT e.id, n.k + 1 FROM empleados e JOIN nivel n ON e.jefe = n.id\n"
        ")\n"
        "SELECT e.nombre, n.k FROM empleados e JOIN nivel n ON e.id = n.id;",
    ),
    Par(
        "35",
        "WITH RECURSIVE requisito(r) AS (\n"
        "  SELECT requisito FROM correlativas WHERE materia = 'bd'\n"
        "  UNION\n"
        "  SELECT c.requisito FROM correlativas c JOIN requisito q ON c.materia = q.r\n"
        ")\n"
        "SELECT r FROM requisito ORDER BY r;",
        modo="orden",
    ),
    Par(
        "35b",
        "WITH RECURSIVE requisito(r) AS (\n"
        "  SELECT requisito FROM correlativas WHERE materia = 'bd'\n"
        "  UNION ALL\n"
        "  SELECT c.requisito FROM correlativas c JOIN requisito q ON c.materia = q.r\n"
        ")\n"
        "SELECT r FROM requisito;",
    ),
    Par(
        "36",
        "SELECT v1.destino, v2.destino, v1.precio + v2.precio\n"
        "FROM vuelos v1 JOIN vuelos v2 ON v1.destino = v2.origen\n"
        "WHERE v1.origen = 'ros';",
    ),
    Par(
        "37",
        "WITH RECURSIVE alcanza(ciudad) AS (\n"
        "  SELECT destino FROM vuelos WHERE origen = 'ros'\n"
        "  UNION\n"
        "  SELECT v.destino FROM vuelos v JOIN alcanza a ON v.origen = a.ciudad\n"
        ")\n"
        "SELECT ciudad FROM alcanza;",
    ),
    Par(
        "38",
        "WITH RECURSIVE camino(destino, precio, ruta) AS (\n"
        "  SELECT destino, precio, 'ros/' || destino FROM vuelos WHERE origen = 'ros'\n"
        "  UNION\n"
        "  SELECT v.destino, c.precio + v.precio, c.ruta || '/' || v.destino\n"
        "  FROM camino c JOIN vuelos v ON v.origen = c.destino\n"
        "  WHERE instr(c.ruta, v.destino) = 0\n"
        ")\n"
        "SELECT destino, MIN(precio) FROM camino GROUP BY destino;",
    ),
    # ---------------- Actualizaciones ----------------
    Par(
        "39",
        "INSERT INTO inscripciones (legajo, materia, nota) VALUES (107, 'log', NULL);\n"
        "\n"
        "SELECT materia, nota FROM inscripciones WHERE legajo = 107;",
    ),
    Par(
        "40",
        "UPDATE inscripciones SET nota = 8\n"
        "WHERE legajo = 101 AND materia = 'pp';\n"
        "\n"
        "SELECT materia, nota FROM inscripciones WHERE legajo = 101;",
    ),
    Par(
        "41",
        "UPDATE empleados SET salario = salario * 110 / 100\n"
        "WHERE depto = 'it';\n"
        "\n"
        "SELECT id, salario FROM empleados WHERE depto = 'it';",
    ),
    Par(
        "42",
        "DELETE FROM inscripciones WHERE nota IS NULL;\n"
        "\n"
        "SELECT COUNT(*), COUNT(*) - COUNT(nota) FROM inscripciones;",
    ),
    Par(
        "43",
        "DELETE FROM vuelos WHERE aerolinea = 'fb' AND precio > 70;\n"
        "\n"
        "SELECT origen, destino, precio FROM vuelos WHERE aerolinea = 'fb';",
    ),
    Par(
        "44",
        "INSERT INTO alumnos VALUES (101, 'zoe', 'civil', 2025);\n"
        "-- Error: UNIQUE constraint failed: alumnos.legajo\n"
        "\n"
        "SELECT nombre FROM alumnos WHERE legajo = 101;",
    ),
    Par("44b", None, modo="esperado", esperado=[["ana"], ["zoe"]]),
    Par(
        "45",
        "PRAGMA foreign_keys = ON;\n"
        "\n"
        "INSERT INTO inscripciones (legajo, materia) VALUES (999, 'am1');\n"
        "-- Error: FOREIGN KEY constraint failed\n"
        "INSERT INTO inscripciones (legajo, materia) VALUES (107, 'am1');\n"
        "\n"
        "SELECT legajo, materia, nota FROM inscripciones\n"
        "WHERE legajo IN (999, 107);",
    ),
    # ---------------- Dónde difieren ----------------
    Par("46", "SELECT COUNT(*) FROM alumnos WHERE carrera = 'quimica';"),
    Par(
        "46b",
        "SELECT carrera, COUNT(*) FROM alumnos\n"
        "WHERE carrera = 'quimica'\n"
        "GROUP BY carrera;",
    ),
    Par("47", "SELECT SUM(salario) FROM empleados WHERE depto = 'legal';", modo="difieren"),
    Par("47b", "SELECT MAX(salario) FROM empleados WHERE depto = 'legal';", modo="difieren"),
    Par("48", None, modo="esperado", esperado=[["no_termina"]]),
    Par(
        "48b",
        "WITH RECURSIVE alcanza(ciudad) AS (\n"
        "  SELECT destino FROM vuelos WHERE origen = 'ros'\n"
        "  UNION ALL\n"
        "  SELECT v.destino FROM vuelos v JOIN alcanza a ON v.origen = a.ciudad\n"
        ")\n"
        "SELECT COUNT(*) FROM (SELECT * FROM alcanza LIMIT 1000);",
        modo="esperado",
        esperado=[[1000]],
        prolog=False,
    ),
    Par(
        "49",
        "SELECT legajo, materia, nota FROM inscripciones\n"
        "WHERE NOT (nota >= 6);",
        modo="difieren",
    ),
    Par("50", "SELECT COUNT(carrera), COUNT(DISTINCT carrera) FROM alumnos;"),
]


# ---------------------------------------------------------------------------


def normalizar(valor):
    """Iguala representaciones: 4.0 -> 4, 8.5 queda 8.5, redondeo a 6 decimales."""
    if isinstance(valor, float):
        return int(valor) if valor.is_integer() else round(valor, 6)
    return valor


def filas(rs) -> list[list]:
    return [[normalizar(v) for v in fila] for fila in rs]


def filas_prolog(rs) -> list[list]:
    """El átomo `null` de datos.pl representa el NULL de SQL."""
    return [[None if v == "null" else v for v in fila] for fila in filas(rs)]


def clave(fila):
    return json.dumps(fila, sort_keys=True)


def ejecutar_sql(sql: str) -> tuple[list[list], list[str]]:
    """Base nueva por ejercicio. Todas las sentencias menos la última se
    ejecutan capturando errores de integridad (se informan); la última es
    la consulta cuyo resultado se compara."""
    con = sqlite3.connect(":memory:")
    con.executescript(SCHEMA)
    sentencias = [
        s.strip()
        for s in "\n".join(
            ln for ln in sql.splitlines() if not ln.lstrip().startswith("--")
        ).split(";")
        if s.strip()
    ]
    errores = []
    for s in sentencias[:-1]:
        try:
            con.execute(s)
        except sqlite3.IntegrityError as e:
            errores.append(str(e))
    rs = con.execute(sentencias[-1]).fetchall()
    con.close()
    return filas(rs), errores


PROLOG_MAIN = r"""
:- use_module(library(http/json)).
main :-
    findall(Id, clause(par(Id, _), _), Ids0),
    list_to_set(Ids0, Ids),
    forall(member(Id, Ids),
           ( snapshot(findall(F, par(Id, F), Fs)),
             format("~w\t", [Id]),
             json_write(current_output, Fs, [width(0)]), nl )).
"""


def ejecutar_prolog() -> dict[str, list[list]]:
    main = DIR / "_main_verificar.pl"
    main.write_text(PROLOG_MAIN, encoding="utf-8")
    try:
        out = subprocess.run(
            ["swipl", "-q", "-g", "main", "-t", "halt",
             str(DIR / "consultas.pl"), str(main)],
            capture_output=True, text=True, encoding="utf-8", cwd=DIR,
            timeout=120,
        )
    finally:
        main.unlink(missing_ok=True)
    if out.returncode != 0 or out.stderr.strip():
        print(out.stderr, file=sys.stderr)
        if out.returncode != 0:
            sys.exit("swipl falló")
    res = {}
    for ln in out.stdout.splitlines():
        ident, js = ln.split("\t", 1)
        res[ident] = filas_prolog(json.loads(js))
    return res


def main() -> int:
    verbose = "-v" in sys.argv
    prolog = ejecutar_prolog()
    fallos = 0
    for p in PARES:
        pl = prolog.get(p.id) if p.prolog else None
        if p.prolog and pl is None:
            print(f"PAR-{p.id}: FALTA par({p.id}, _) en consultas.pl")
            fallos += 1
            continue
        sq, errores = ejecutar_sql(p.sql) if p.sql else (None, [])
        if p.modo == "bolsa":
            ok = sorted(sq, key=clave) == sorted(pl, key=clave)
        elif p.modo == "orden":
            ok = sq == pl
        elif p.modo == "difieren":
            ok = sorted(sq, key=clave) != sorted(pl, key=clave)
        elif p.modo == "esperado":
            obtenido = pl if p.prolog else sq
            ok = sorted(obtenido, key=clave) == sorted(p.esperado, key=clave)
        else:
            raise ValueError(p.modo)
        estado = "ok" if ok else "FALLA"
        fallos += not ok
        print(f"PAR-{p.id:<4} {p.modo:<9} {estado}")
        if verbose or not ok:
            if sq is not None:
                print(f"    SQL    : {sq}")
            if errores:
                print(f"    errores: {errores}")
            if pl is not None:
                print(f"    Prolog : {pl}")
    total = len(PARES)
    print(f"\n{total - fallos}/{total} verificaciones correctas")
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
