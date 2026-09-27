:- encoding(utf8).

% Capítulo 26 - Soluciones de los ejercicios 3, 4, 5, 7, 8 y 13: el proyecto.
%
% Las soluciones de estos ejercicios son, sobre todo, pruebas: están en
% soluciones_proyecto.plt. Este archivo carga el proyecto y agrega los dos
% predicados que piden los ejercicios 7 y 8.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- debug(inscripcion), inscribir_registrado(104, ssl, R).
%?- vacantes_no_negativas.

:- use_module(library(debug)).
:- use_module(inscripciones/datos).
:- use_module(inscripciones/reglas).
:- use_module(inscripciones/informes).

% --- Ejercicio 7 ------------------------------------------------------------

%!  inscribir_registrado(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Como inscribir/3, y además escribe, con el tema de depuración
%   inscripcion, el pedido y su resultado.
inscribir_registrado(Legajo, Materia, Resultado) :-
    debug(inscripcion, "inscribir ~w en ~w", [Legajo, Materia]),
    inscribir(Legajo, Materia, Resultado),
    debug(inscripcion, "resultado: ~w", [Resultado]).

% --- Ejercicio 8 ------------------------------------------------------------

%!  vacantes_no_negativas is det.
%
%   Comprueba con assertion/1 que ninguna materia tiene vacantes negativas:
%   es un invariante del programa, que inscribir/3 debe mantener.
vacantes_no_negativas :-
    forall(vacantes(_, N),
           assertion(N >= 0)),
    debug(inscripcion, "vacantes revisadas", []).
