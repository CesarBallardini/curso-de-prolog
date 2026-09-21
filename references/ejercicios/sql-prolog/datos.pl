% Unidad 11: Prolog y SQL. Los mismos datos que schema.sql, como hechos.
%
% Cada tabla es un predicado; cada fila, un hecho; cada columna, un argumento
% (en el mismo orden que en el CREATE TABLE).
%
% NULL no existe en Prolog. Aquí lo representamos con el átomo `null`, que es
% un átomo más: no tiene ningún significado especial para Prolog.
%
% Los predicados se declaran dinámicos para poder modificarlos con
% assertz/retract en los ejercicios de actualización (PAR-39 a PAR-45).

:- dynamic alumno/4, materia/3, correlativa/2, inscripcion/3.
:- dynamic departamento/3, empleado/5, vuelo/4.

% ============================================================
% Esquema 1: académico
% ============================================================

% alumno(Legajo, Nombre, Carrera, Ingreso)
alumno(101, ana,      sistemas,   2023).
alumno(102, bruno,    sistemas,   2024).
alumno(103, carla,    civil,      2023).
alumno(104, diego,    sistemas,   2024).
alumno(105, elena,    civil,      2025).
alumno(106, facundo,  industrial, 2024).
alumno(107, gabriela, industrial, 2025).

% materia(Codigo, Nombre, Anio)
materia(am1, analisis_1,     1).
materia(alg, algebra,        1).
materia(log, logica,         1).
materia(am2, analisis_2,     2).
materia(pp,  paradigmas,     2).
materia(ssl, sintaxis,       2).
materia(bd,  bases_de_datos, 3).

% correlativa(Materia, Requisito): para cursar Materia hay que aprobar Requisito.
correlativa(am2, am1).
correlativa(am2, alg).
correlativa(pp,  log).
correlativa(ssl, log).
correlativa(ssl, alg).
correlativa(bd,  pp).
correlativa(bd,  ssl).

% inscripcion(Legajo, Materia, Nota)   Nota = null: cursando, sin nota.
inscripcion(101, am1, 8).
inscripcion(101, alg, 9).
inscripcion(101, log, 10).
inscripcion(101, am2, 7).
inscripcion(101, pp,  null).
inscripcion(102, am1, 4).
inscripcion(102, log, 6).
inscripcion(102, alg, 2).
inscripcion(103, am1, 7).
inscripcion(103, alg, 5).
inscripcion(103, am2, null).
inscripcion(104, log, 9).
inscripcion(104, alg, 7).
inscripcion(104, pp,  8).
inscripcion(105, am1, null).
inscripcion(106, log, 3).
inscripcion(106, am1, 6).

% ============================================================
% Esquema 2: empresa
% ============================================================

% departamento(Codigo, Nombre, Ciudad)
departamento(dir,    direccion,        rosario).
departamento(ventas, ventas,           cordoba).
departamento(it,     sistemas,         rosario).
departamento(rrhh,   recursos_humanos, rosario).
departamento(legal,  legales,          mendoza).

% empleado(Id, Nombre, Depto, Salario, Jefe)   Jefe = null: no tiene jefe.
empleado(1, marta,   dir,    900000, null).
empleado(2, jorge,   ventas, 500000, 1).
empleado(3, lucia,   it,     650000, 1).
empleado(4, pablo,   ventas, 350000, 2).
empleado(5, sofia,   ventas, 380000, 2).
empleado(6, tomas,   it,     420000, 3).
empleado(7, valeria, it,     450000, 3).
empleado(8, nicolas, it,     300000, 7).
empleado(9, irene,   rrhh,   400000, 1).

% ============================================================
% Esquema 3: vuelos (grafo dirigido CON un ciclo: aep -> cor -> aep)
% ============================================================

% vuelo(Origen, Destino, Aerolinea, Precio)
vuelo(ros, aep, ar, 50).
vuelo(aep, cor, ar, 70).
vuelo(cor, aep, fb, 60).
vuelo(aep, mdz, ar, 90).
vuelo(cor, mdz, fb, 55).
vuelo(mdz, brc, ar, 120).
vuelo(aep, brc, fb, 110).
vuelo(aep, ush, ar, 150).
vuelo(cor, sla, fb, 80).
vuelo(igr, aep, ar, 95).
