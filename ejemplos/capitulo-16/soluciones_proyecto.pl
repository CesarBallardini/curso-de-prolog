:- encoding(utf8).

% Capítulo 16 - Solución del ejercicio 12: una prueba de rendimiento para el
% proyecto.
%
% Carga generar_datos.pl, que genera los 5 000 alumnos y mide inferencias, y
% agrega la versión del proyecto de aprobada_por_nombre/2, cuyo orden de
% objetivos protege la prueba de soluciones_proyecto.plt.
%
% solo-local: carga generar_datos.pl, otro archivo del capítulo.
%
%?- generar(5000), inferencias(aprobada_por_nombre(alumno_2500, _), I).

:- ensure_loaded(generar_datos).

%!  aprobada(?Legajo:integer, ?Materia:atom, ?Nota:integer) is nondet.
%
%   El alumno Legajo aprobó Materia con Nota: la del proyecto.
aprobada(Legajo, Materia, Nota) :-
    inscripcion(Legajo, Materia, nota(Nota)),
    Nota >= 6.

%!  aprobada_por_nombre(?Nombre:atom, ?Materia:atom) is nondet.
%
%   La del proyecto: primero el alumno, después sus inscripciones.
aprobada_por_nombre(Nombre, Materia) :-
    alumno(Legajo, Nombre, _, _),
    aprobada(Legajo, Materia, _Nota).
