:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 7: la salida en un módulo aparte.
%
% mostrar_informe/2 escribe; el resto de informes solo calcula. Este módulo
% importa informes sin su mostrar_informe/2 y define el suyo: el núcleo
% calcula, el borde escribe.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- informe(aprobadas, [101, 105], F), mostrar_informe(aprobadas, F).

:- module(salida, [mostrar_informe/2]).

:- use_module('../inscripciones/datos').
:- use_module('../inscripciones/informes', except([mostrar_informe/2])).

%!  mostrar_informe(+Titulo:atom, +Filas:list(pair)) is semidet.
%
%   Escribe Titulo y una línea por fila, con el legajo, el nombre y el valor.
mostrar_informe(Titulo, Filas) :-
    format("~w~n", [Titulo]),
    maplist(mostrar_fila, Filas).

%!  mostrar_fila(+Fila:pair) is semidet.
%
%   Escribe una fila Legajo-Valor de un informe.
mostrar_fila(Legajo-Valor) :-
    alumno(Legajo, Nombre, _, _),
    format("  ~d ~w: ~w~n", [Legajo, Nombre, Valor]).
