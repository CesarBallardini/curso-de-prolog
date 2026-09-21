-- Unidad 11: Prolog y SQL. Esquemas y datos compartidos (dialecto SQLite).
-- La misma información está escrita como hechos Prolog en datos.pl.
-- Convención: los textos son palabras en minúscula sin espacios, para que
-- coincidan exactamente con los átomos de Prolog.

PRAGMA foreign_keys = ON;

-- ============================================================
-- Esquema 1: académico
-- ============================================================

CREATE TABLE alumnos (
    legajo  INTEGER PRIMARY KEY,
    nombre  TEXT    NOT NULL,
    carrera TEXT    NOT NULL,
    ingreso INTEGER NOT NULL
);

CREATE TABLE materias (
    codigo TEXT    PRIMARY KEY,
    nombre TEXT    NOT NULL,
    anio   INTEGER NOT NULL
);

-- correlativas(materia, requisito): para cursar `materia` hay que aprobar `requisito`.
CREATE TABLE correlativas (
    materia   TEXT NOT NULL REFERENCES materias(codigo),
    requisito TEXT NOT NULL REFERENCES materias(codigo),
    PRIMARY KEY (materia, requisito)
);

-- nota NULL = cursando, todavía sin nota.
CREATE TABLE inscripciones (
    legajo  INTEGER NOT NULL REFERENCES alumnos(legajo),
    materia TEXT    NOT NULL REFERENCES materias(codigo),
    nota    INTEGER CHECK (nota BETWEEN 1 AND 10),
    PRIMARY KEY (legajo, materia)
);

INSERT INTO alumnos VALUES
    (101, 'ana',      'sistemas',   2023),
    (102, 'bruno',    'sistemas',   2024),
    (103, 'carla',    'civil',      2023),
    (104, 'diego',    'sistemas',   2024),
    (105, 'elena',    'civil',      2025),
    (106, 'facundo',  'industrial', 2024),
    (107, 'gabriela', 'industrial', 2025);

INSERT INTO materias VALUES
    ('am1', 'analisis_1',     1),
    ('alg', 'algebra',        1),
    ('log', 'logica',         1),
    ('am2', 'analisis_2',     2),
    ('pp',  'paradigmas',     2),
    ('ssl', 'sintaxis',       2),
    ('bd',  'bases_de_datos', 3);

INSERT INTO correlativas VALUES
    ('am2', 'am1'),
    ('am2', 'alg'),
    ('pp',  'log'),
    ('ssl', 'log'),
    ('ssl', 'alg'),
    ('bd',  'pp'),
    ('bd',  'ssl');

INSERT INTO inscripciones VALUES
    (101, 'am1', 8),
    (101, 'alg', 9),
    (101, 'log', 10),
    (101, 'am2', 7),
    (101, 'pp',  NULL),
    (102, 'am1', 4),
    (102, 'log', 6),
    (102, 'alg', 2),
    (103, 'am1', 7),
    (103, 'alg', 5),
    (103, 'am2', NULL),
    (104, 'log', 9),
    (104, 'alg', 7),
    (104, 'pp',  8),
    (105, 'am1', NULL),
    (106, 'log', 3),
    (106, 'am1', 6);

-- ============================================================
-- Esquema 2: empresa
-- ============================================================

CREATE TABLE departamentos (
    codigo TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    ciudad TEXT NOT NULL
);

-- jefe NULL = no tiene jefe (la directora general).
CREATE TABLE empleados (
    id      INTEGER PRIMARY KEY,
    nombre  TEXT    NOT NULL,
    depto   TEXT    NOT NULL REFERENCES departamentos(codigo),
    salario INTEGER NOT NULL CHECK (salario > 0),
    jefe    INTEGER REFERENCES empleados(id)
);

INSERT INTO departamentos VALUES
    ('dir',    'direccion',        'rosario'),
    ('ventas', 'ventas',           'cordoba'),
    ('it',     'sistemas',         'rosario'),
    ('rrhh',   'recursos_humanos', 'rosario'),
    ('legal',  'legales',          'mendoza');

INSERT INTO empleados VALUES
    (1, 'marta',   'dir',    900000, NULL),
    (2, 'jorge',   'ventas', 500000, 1),
    (3, 'lucia',   'it',     650000, 1),
    (4, 'pablo',   'ventas', 350000, 2),
    (5, 'sofia',   'ventas', 380000, 2),
    (6, 'tomas',   'it',     420000, 3),
    (7, 'valeria', 'it',     450000, 3),
    (8, 'nicolas', 'it',     300000, 7),
    (9, 'irene',   'rrhh',   400000, 1);

-- ============================================================
-- Esquema 3: vuelos (grafo dirigido CON un ciclo: aep -> cor -> aep)
-- ============================================================

CREATE TABLE vuelos (
    origen    TEXT    NOT NULL,
    destino   TEXT    NOT NULL,
    aerolinea TEXT    NOT NULL,
    precio    INTEGER NOT NULL,
    PRIMARY KEY (origen, destino, aerolinea)
);

INSERT INTO vuelos VALUES
    ('ros', 'aep', 'ar', 50),
    ('aep', 'cor', 'ar', 70),
    ('cor', 'aep', 'fb', 60),
    ('aep', 'mdz', 'ar', 90),
    ('cor', 'mdz', 'fb', 55),
    ('mdz', 'brc', 'ar', 120),
    ('aep', 'brc', 'fb', 110),
    ('aep', 'ush', 'ar', 150),
    ('cor', 'sla', 'fb', 80),
    ('igr', 'aep', 'ar', 95);
