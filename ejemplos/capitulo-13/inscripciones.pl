:- encoding(utf8).

% Capítulo 13 - El proyecto Inscripciones: el primer archivo.
%
% Los datos de un sistema de inscripción a las materias de una carrera: los
% mismos hechos que el capítulo 42 traduce desde SQL. Todavía no hay reglas:
% este archivo es el punto de partida del proyecto de la parte II.
%
%?- inscripcion(101, Materia, Nota).
%?- correlativa(bd, Requisito).

% alumno(Legajo, Nombre, Carrera, Ingreso): el alumno de ese legajo cursa esa
% carrera desde el año de ingreso.
alumno(101, ana,      sistemas,   2023).
alumno(102, bruno,    sistemas,   2024).
alumno(103, carla,    civil,      2023).
alumno(104, diego,    sistemas,   2024).
alumno(105, elena,    civil,      2025).
alumno(106, facundo,  industrial, 2024).
alumno(107, gabriela, industrial, 2025).

% materia(Codigo, Nombre, Anio): la materia de ese código es del año indicado.
materia(am1, analisis_1,     1).
materia(alg, algebra,        1).
materia(log, logica,         1).
materia(am2, analisis_2,     2).
materia(pp,  paradigmas,     2).
materia(ssl, sintaxis,       2).
materia(bd,  bases_de_datos, 3).

% correlativa(Materia, Requisito): para cursar Materia es necesario aprobar
% Requisito.
correlativa(am2, am1).
correlativa(am2, alg).
correlativa(pp,  log).
correlativa(ssl, log).
correlativa(ssl, alg).
correlativa(bd,  pp).
correlativa(bd,  ssl).

% inscripcion(Legajo, Materia, Nota): el alumno cursó o cursa la materia;
% Nota es null mientras la cursa y todavía no tiene nota.
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
