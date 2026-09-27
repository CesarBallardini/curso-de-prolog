:- encoding(utf8).

% Capítulo 29 - Solución del ejercicio 12, del lado de Prolog.
%
% inscriptos_py/2 prepara los inscriptos de una materia como datos que
% cruzan a Python: una lista de dicts. Se carga después del proyecto.
%
% solo-local: SWISH no admite módulos propios ni ejecuta Python.
%
%?- inscriptos_py(log, Alumnos).

:- ensure_loaded(inscripciones/inscripciones).

%!  inscriptos_py(+Materia:atom, -Alumnos:list(dict)) is det.
%
%   Alumnos son los inscriptos en Materia, en orden de legajo: un dict por
%   alumno, con las claves legajo y nombre.
inscriptos_py(Materia, Alumnos) :-
    inscriptos(Materia, Legajos),
    maplist(alumno_py, Legajos, Alumnos).

%!  alumno_py(+Legajo:integer, -Alumno:dict) is det.
%
%   Alumno es el dict del alumno Legajo.
alumno_py(Legajo, _{legajo: Legajo, nombre: Nombre}) :-
    alumno(Legajo, Nombre, _, _).
