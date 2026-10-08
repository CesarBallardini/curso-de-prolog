:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 15: una directiva initialization/1 que
% informa cuántas inscripciones hay.
%
% Es inscripciones.pl con la directiva agregada: carga los cinco módulos del
% proyecto y, al terminar, comprueba los datos y escribe la cantidad de
% inscripciones.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- informar_inscripciones.

:- use_module('../inscripciones/datos').
:- use_module('../inscripciones/reglas').
:- use_module('../inscripciones/informes').
:- use_module('../inscripciones/comandos').
:- use_module('../inscripciones/horarios').

%!  informar_inscripciones is det.
%
%   Escribe cuántas inscripciones hay.
informar_inscripciones :-
    aggregate_all(count, inscripcion(_, _, _), N),
    format("~d inscripciones~n", [N]).

:- initialization(comprobar_datos).
:- initialization(informar_inscripciones).
