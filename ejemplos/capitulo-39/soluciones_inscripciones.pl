:- encoding(utf8).

% Capítulo 39 - Solución del ejercicio 14: las materias que habilita una
% materia, y las que un alumno ya puede cursar.
%
% solo-local: carga los módulos datos y reglas del capítulo 31, y SWISH no
% admite módulos propios.
%
%?- habilita(log, M).
%?- materias_habilitadas(102, Ms).

:- module(soluciones_inscripciones,
          [ habilita/2,
            materias_habilitadas/2
          ]).

:- use_module('../capitulo-31/inscripciones/datos').
:- use_module('../capitulo-31/inscripciones/reglas',
              [ aprobada/3, cursa/2 ]).

:- table habilita/2.

%!  habilita(?Materia:atom, ?Otra:atom) is nondet.
%
%   Aprobar Materia es necesario, directa o indirectamente, para cursar
%   Otra.
habilita(Materia, Otra) :-
    correlativa(Otra, Materia).
habilita(Materia, Otra) :-
    habilita(Materia, Intermedia),
    correlativa(Otra, Intermedia).

%!  materias_habilitadas(+Legajo:integer, -Materias:list(atom)) is det.
%
%   Materias son las que el alumno Legajo no aprobó ni cursa y cuyos
%   requisitos, directos e indirectos, aprobó todos; en orden.
materias_habilitadas(Legajo, Materias) :-
    must_be(integer, Legajo),
    findall(M,
            ( materia(M, _, _),
              \+ aprobada(Legajo, M, _),
              \+ cursa(Legajo, M),
              forall(habilita(R, M), aprobada(Legajo, R, _)) ),
            Ms),
    sort(Ms, Materias).
