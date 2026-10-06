:- encoding(utf8).

% Capítulo 86 - El mini-SQL frente a SQLite.
%
% Ejecuta en el mini-SQL las sentencias SQL de los pares SQL/Prolog del
% capítulo 42 que su subconjunto admite (42 de las 57 verificaciones de
% los 50 pares), y compara las filas con las que da SQLite 3.50 sobre el
% mismo esquema (schema.sql del banco de ejercicios). sqlite/2 guarda esas filas, obtenidas una vez con el
% módulo sqlite3 de Python. Las tablas de la empresa y de los vuelos se
% crean con empresa/0, en el subconjunto del mini-SQL: sin REFERENCES ni
% CHECK. Cada par se ejecuta sobre una copia del estado, que después se
% repone.
%
% solo-local: carga los módulos del capítulo y modifica la base.
%
%?- coincide('49').
%?- resumen(Coinciden, Total).

:- module(comparacion,
          [ par/3,
            sqlite/2,
            empresa/0,
            filas_par/2,
            coincide/1,
            resumen/2
          ]).

:- reexport(minisql).
:- use_module(library(lists)).
:- use_module(library(apply)).

%!  empresa is det.
%
%   Crea y llena las tablas departamentos, empleados y vuelos.
empresa :-
    guion("CREATE TABLE departamentos (codigo TEXT PRIMARY KEY,
             nombre TEXT NOT NULL, ciudad TEXT NOT NULL);
           CREATE TABLE empleados (id INTEGER PRIMARY KEY,
             nombre TEXT NOT NULL, depto TEXT NOT NULL,
             salario INTEGER NOT NULL, jefe INTEGER);
           CREATE TABLE vuelos (origen TEXT NOT NULL, destino TEXT NOT NULL,
             aerolinea TEXT NOT NULL, precio INTEGER NOT NULL,
             PRIMARY KEY (origen, destino, aerolinea));
           INSERT INTO departamentos VALUES
             ('dir', 'direccion', 'rosario'), ('ventas', 'ventas', 'cordoba'),
             ('it', 'sistemas', 'rosario'),
             ('rrhh', 'recursos_humanos', 'rosario'),
             ('legal', 'legales', 'mendoza');
           INSERT INTO empleados VALUES
             (1, 'marta', 'dir', 900000, NULL),
             (2, 'jorge', 'ventas', 500000, 1),
             (3, 'lucia', 'it', 650000, 1),
             (4, 'pablo', 'ventas', 350000, 2),
             (5, 'sofia', 'ventas', 380000, 2),
             (6, 'tomas', 'it', 420000, 3),
             (7, 'valeria', 'it', 450000, 3),
             (8, 'nicolas', 'it', 300000, 7),
             (9, 'irene', 'rrhh', 400000, 1);
           INSERT INTO vuelos VALUES
             ('ros', 'aep', 'ar', 50), ('aep', 'cor', 'ar', 70),
             ('cor', 'aep', 'fb', 60), ('aep', 'mdz', 'ar', 90),
             ('cor', 'mdz', 'fb', 55), ('mdz', 'brc', 'ar', 120),
             ('aep', 'brc', 'fb', 110), ('aep', 'ush', 'ar', 150),
             ('cor', 'sla', 'fb', 80), ('igr', 'aep', 'ar', 95)",
          Rs),
    forall(member(R, Rs), R \= error(_)).

%!  filas_par(+Id, -Filas:list) is det.
%
%   Filas son las filas de la última sentencia del par Id, ejecutado con
%   las tablas de la empresa. El estado anterior se repone al terminar.
filas_par(Id, Filas) :-
    par(Id, _, Lineas),
    atomic_list_concat(Lineas, '\n', Texto),
    estado(E),
    call_cleanup(( empresa,
                   guion(Texto, Rs),
                   last(Rs, filas(_, Filas)) ),
                 restaurar(E)).

%!  coincide(+Id) is semidet.
%
%   El mini-SQL da las mismas filas que SQLite en el par Id: en el mismo
%   orden si el par tiene ORDER BY, y con las mismas repeticiones en
%   cualquier orden si no.
coincide(Id) :-
    par(Id, Modo, _),
    sqlite(Id, Esperadas),
    filas_par(Id, Obtenidas),
    (   Modo == orden
    ->  Obtenidas == Esperadas
    ;   msort(Obtenidas, O),
        msort(Esperadas, O1),
        O == O1
    ).

%!  resumen(-Coinciden:integer, -Total:integer) is det.
%
%   De los Total pares, Coinciden dan las mismas filas que SQLite.
resumen(Coinciden, Total) :-
    findall(Id, par(Id, _, _), Ids),
    length(Ids, Total),
    include(coincide, Ids, Bien),
    length(Bien, Coinciden).

% par(Id, Modo, Lineas): las sentencias del par Id del capítulo 42, línea
% por línea; Modo es orden si el resultado tiene ORDER BY, bolsa si no.
par('1', bolsa,
    [ "SELECT legajo, nombre FROM alumnos WHERE carrera = 'sistemas';" ]).
par('2', bolsa,
    [ "SELECT nombre, carrera, ingreso FROM alumnos",
      "WHERE ingreso >= 2024 AND carrera <> 'civil';" ]).
par('3', bolsa,
    [ "SELECT carrera FROM alumnos;" ]).
par('4', orden,
    [ "SELECT DISTINCT carrera FROM alumnos",
      "ORDER BY carrera;" ]).
par('5', orden,
    [ "SELECT ingreso, nombre FROM alumnos",
      "ORDER BY ingreso, nombre;" ]).
par('6', bolsa,
    [ "SELECT a.nombre, i.nota",
      "FROM alumnos a JOIN inscripciones i ON a.legajo = i.legajo",
      "WHERE i.materia = 'am1';" ]).
par('7', bolsa,
    [ "SELECT a.nombre, m.nombre, i.nota",
      "FROM inscripciones i",
      "JOIN alumnos  a ON a.legajo = i.legajo",
      "JOIN materias m ON m.codigo = i.materia",
      "WHERE i.nota >= 6;" ]).
par('8', bolsa,
    [ "SELECT a1.nombre, a2.nombre, a1.carrera",
      "FROM alumnos a1 JOIN alumnos a2",
      "  ON a1.carrera = a2.carrera AND a1.legajo < a2.legajo;" ]).
par('9', orden,
    [ "SELECT legajo FROM inscripciones WHERE materia = 'am1'",
      "UNION",
      "SELECT legajo FROM inscripciones WHERE materia = 'log'",
      "ORDER BY legajo;" ]).
par('10', bolsa,
    [ "SELECT legajo FROM inscripciones WHERE materia = 'am1'",
      "UNION ALL",
      "SELECT legajo FROM inscripciones WHERE materia = 'log';" ]).
par('11', bolsa,
    [ "SELECT legajo FROM inscripciones WHERE materia = 'am1'",
      "INTERSECT",
      "SELECT legajo FROM inscripciones WHERE materia = 'alg';" ]).
par('12', bolsa,
    [ "SELECT legajo FROM inscripciones WHERE materia = 'am1'",
      "EXCEPT",
      "SELECT legajo FROM inscripciones WHERE materia = 'alg';" ]).
par('13', bolsa,
    [ "SELECT a.legajo, a.nombre FROM alumnos a",
      "WHERE NOT EXISTS (SELECT * FROM inscripciones i",
      "                  WHERE i.legajo = a.legajo);" ]).
par('15', bolsa,
    [ "CREATE VIEW aprobadas AS",
      "  SELECT legajo, materia, nota FROM inscripciones",
      "  WHERE nota >= 6;",
      "SELECT materia FROM aprobadas WHERE legajo = 101;" ]).
par('16', bolsa,
    [ "SELECT a.legajo, a.nombre FROM alumnos a",
      "WHERE NOT EXISTS (",
      "  SELECT * FROM materias m",
      "  WHERE m.anio = 1",
      "    AND NOT EXISTS (SELECT * FROM inscripciones i",
      "                    WHERE i.legajo = a.legajo",
      "                      AND i.materia = m.codigo",
      "                      AND i.nota >= 6));" ]).
par('17', bolsa,
    [ "SELECT COUNT(*) FROM alumnos WHERE carrera = 'sistemas';" ]).
par('18', bolsa,
    [ "SELECT carrera, COUNT(*) FROM alumnos",
      "GROUP BY carrera;" ]).
par('20', bolsa,
    [ "SELECT legajo, AVG(nota) FROM inscripciones",
      "WHERE nota IS NOT NULL",
      "GROUP BY legajo;" ]).
par('21', bolsa,
    [ "SELECT a.nombre, i.nota",
      "FROM inscripciones i JOIN alumnos a ON a.legajo = i.legajo",
      "WHERE i.materia = 'log'",
      "  AND i.nota = (SELECT MAX(nota) FROM inscripciones",
      "                WHERE materia = 'log');" ]).
par('22', bolsa,
    [ "SELECT a.nombre, COUNT(*)",
      "FROM alumnos a JOIN inscripciones i ON i.legajo = a.legajo",
      "WHERE i.nota >= 6",
      "GROUP BY a.legajo, a.nombre",
      "HAVING COUNT(*) >= 3;" ]).
par('23', bolsa,
    [ "SELECT e.nombre, j.nombre",
      "FROM empleados e JOIN empleados j ON e.jefe = j.id;" ]).
par('25', bolsa,
    [ "SELECT e.nombre, d.nombre",
      "FROM empleados e JOIN departamentos d ON e.depto = d.codigo",
      "WHERE d.ciudad = 'rosario';" ]).
par('26', bolsa,
    [ "SELECT d.codigo FROM departamentos d",
      "WHERE NOT EXISTS (SELECT * FROM empleados e",
      "                  WHERE e.depto = d.codigo);" ]).
par('27', bolsa,
    [ "SELECT depto, SUM(salario) FROM empleados",
      "GROUP BY depto",
      "HAVING SUM(salario) > 1000000;" ]).
par('28', bolsa,
    [ "SELECT e.depto, e.nombre, e.salario FROM empleados e",
      "WHERE e.salario = (SELECT MAX(salario) FROM empleados e2",
      "                   WHERE e2.depto = e.depto);" ]).
par('29', orden,
    [ "SELECT nombre, salario FROM empleados",
      "ORDER BY salario DESC",
      "LIMIT 3;" ]).
par('30', bolsa,
    [ "SELECT id, nombre FROM empleados",
      "WHERE id NOT IN (SELECT jefe FROM empleados);" ]).
par('31', bolsa,
    [ "SELECT e.id, e.nombre FROM empleados e",
      "WHERE NOT EXISTS (SELECT * FROM empleados s",
      "                  WHERE s.jefe = e.id);" ]).
par('32', bolsa,
    [ "SELECT nombre FROM empleados WHERE jefe <> 1;" ]).
par('36', bolsa,
    [ "SELECT v1.destino, v2.destino, v1.precio + v2.precio",
      "FROM vuelos v1 JOIN vuelos v2 ON v1.destino = v2.origen",
      "WHERE v1.origen = 'ros';" ]).
par('39', bolsa,
    [ "INSERT INTO inscripciones (legajo, materia, nota) VALUES (107, 'log', NULL);",
      "SELECT materia, nota FROM inscripciones WHERE legajo = 107;" ]).
par('40', bolsa,
    [ "UPDATE inscripciones SET nota = 8",
      "WHERE legajo = 101 AND materia = 'pp';",
      "SELECT materia, nota FROM inscripciones WHERE legajo = 101;" ]).
par('41', bolsa,
    [ "UPDATE empleados SET salario = salario * 110 / 100",
      "WHERE depto = 'it';",
      "SELECT id, salario FROM empleados WHERE depto = 'it';" ]).
par('42', bolsa,
    [ "DELETE FROM inscripciones WHERE nota IS NULL;",
      "SELECT COUNT(*), COUNT(*) - COUNT(nota) FROM inscripciones;" ]).
par('43', bolsa,
    [ "DELETE FROM vuelos WHERE aerolinea = 'fb' AND precio > 70;",
      "SELECT origen, destino, precio FROM vuelos WHERE aerolinea = 'fb';" ]).
par('44', bolsa,
    [ "INSERT INTO alumnos VALUES (101, 'zoe', 'civil', 2025);",
      "-- Error: UNIQUE constraint failed: alumnos.legajo",
      "SELECT nombre FROM alumnos WHERE legajo = 101;" ]).
par('46', bolsa,
    [ "SELECT COUNT(*) FROM alumnos WHERE carrera = 'quimica';" ]).
par('46b', bolsa,
    [ "SELECT carrera, COUNT(*) FROM alumnos",
      "WHERE carrera = 'quimica'",
      "GROUP BY carrera;" ]).
par('47', bolsa,
    [ "SELECT SUM(salario) FROM empleados WHERE depto = 'legal';" ]).
par('47b', bolsa,
    [ "SELECT MAX(salario) FROM empleados WHERE depto = 'legal';" ]).
par('49', bolsa,
    [ "SELECT legajo, materia, nota FROM inscripciones",
      "WHERE NOT (nota >= 6);" ]).
par('50', bolsa,
    [ "SELECT COUNT(carrera), COUNT(DISTINCT carrera) FROM alumnos;" ]).

% sqlite(Id, Filas): las filas que da SQLite 3.50 con la última sentencia
% del par Id; NULL es null.
sqlite('1',
    [ [101, ana],
      [102, bruno],
      [104, diego] ]).
sqlite('2',
    [ [bruno, sistemas, 2024],
      [diego, sistemas, 2024],
      [facundo, industrial, 2024],
      [gabriela, industrial, 2025] ]).
sqlite('3',
    [ [sistemas],
      [sistemas],
      [civil],
      [sistemas],
      [civil],
      [industrial],
      [industrial] ]).
sqlite('4',
    [ [civil],
      [industrial],
      [sistemas] ]).
sqlite('5',
    [ [2023, ana],
      [2023, carla],
      [2024, bruno],
      [2024, diego],
      [2024, facundo],
      [2025, elena],
      [2025, gabriela] ]).
sqlite('6',
    [ [ana, 8],
      [bruno, 4],
      [carla, 7],
      [elena, null],
      [facundo, 6] ]).
sqlite('7',
    [ [ana, analisis_1, 8],
      [ana, algebra, 9],
      [ana, logica, 10],
      [ana, analisis_2, 7],
      [bruno, logica, 6],
      [carla, analisis_1, 7],
      [diego, logica, 9],
      [diego, algebra, 7],
      [diego, paradigmas, 8],
      [facundo, analisis_1, 6] ]).
sqlite('8',
    [ [ana, bruno, sistemas],
      [ana, diego, sistemas],
      [bruno, diego, sistemas],
      [carla, elena, civil],
      [facundo, gabriela, industrial] ]).
sqlite('9',
    [ [101],
      [102],
      [103],
      [104],
      [105],
      [106] ]).
sqlite('10',
    [ [101],
      [102],
      [103],
      [105],
      [106],
      [101],
      [102],
      [104],
      [106] ]).
sqlite('11',
    [ [101],
      [102],
      [103] ]).
sqlite('12',
    [ [105],
      [106] ]).
sqlite('13',
    [ [107, gabriela] ]).
sqlite('15',
    [ [alg],
      [am1],
      [am2],
      [log] ]).
sqlite('16',
    [ [101, ana] ]).
sqlite('17',
    [ [3] ]).
sqlite('18',
    [ [civil, 2],
      [industrial, 2],
      [sistemas, 3] ]).
sqlite('20',
    [ [101, 8.5],
      [102, 4.0],
      [103, 6.0],
      [104, 8.0],
      [106, 4.5] ]).
sqlite('21',
    [ [ana, 10] ]).
sqlite('22',
    [ [ana, 4],
      [diego, 3] ]).
sqlite('23',
    [ [jorge, marta],
      [lucia, marta],
      [pablo, jorge],
      [sofia, jorge],
      [tomas, lucia],
      [valeria, lucia],
      [nicolas, valeria],
      [irene, marta] ]).
sqlite('25',
    [ [marta, direccion],
      [lucia, sistemas],
      [tomas, sistemas],
      [valeria, sistemas],
      [nicolas, sistemas],
      [irene, recursos_humanos] ]).
sqlite('26',
    [ [legal] ]).
sqlite('27',
    [ [it, 1820000],
      [ventas, 1230000] ]).
sqlite('28',
    [ [dir, marta, 900000],
      [ventas, jorge, 500000],
      [it, lucia, 650000],
      [rrhh, irene, 400000] ]).
sqlite('29',
    [ [marta, 900000],
      [lucia, 650000],
      [jorge, 500000] ]).
sqlite('30', []).
sqlite('31',
    [ [4, pablo],
      [5, sofia],
      [6, tomas],
      [8, nicolas],
      [9, irene] ]).
sqlite('32',
    [ [pablo],
      [sofia],
      [tomas],
      [valeria],
      [nicolas] ]).
sqlite('36',
    [ [aep, brc, 160],
      [aep, cor, 120],
      [aep, mdz, 140],
      [aep, ush, 200] ]).
sqlite('39',
    [ [log, null] ]).
sqlite('40',
    [ [alg, 9],
      [am1, 8],
      [am2, 7],
      [log, 10],
      [pp, 8] ]).
sqlite('41',
    [ [3, 715000],
      [6, 462000],
      [7, 495000],
      [8, 330000] ]).
sqlite('42',
    [ [14, 0] ]).
sqlite('43',
    [ [cor, aep, 60],
      [cor, mdz, 55] ]).
sqlite('44',
    [ [ana] ]).
sqlite('46',
    [ [0] ]).
sqlite('46b', []).
sqlite('47',
    [ [null] ]).
sqlite('47b',
    [ [null] ]).
sqlite('49',
    [ [102, am1, 4],
      [102, alg, 2],
      [103, alg, 5],
      [106, log, 3] ]).
sqlite('50',
    [ [7, 3] ]).
