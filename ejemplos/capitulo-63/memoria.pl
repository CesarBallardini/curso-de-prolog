:- encoding(utf8).

% Capítulo 63 - La memoria de trabajo como conjunto con sellos de tiempo.
%
% La memoria es un término mt(Reloj, Elementos). Elementos es una lista de
% pares Sello-Hecho, del más reciente al más antiguo, sin dos hechos
% iguales; Sello es el valor del reloj cuando el hecho entró, y Reloj, el
% último sello asignado. Agregar un hecho que ya está no cambia nada: la
% memoria es un conjunto. Los hechos no tienen variables.
%
%?- memoria_con([a, b, a], M).
%?- memoria_con([a, b], M0), afirmar(c, M0, M1), retirar(a, M1, M).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).

%!  memoria_vacia(-Memoria) is det.
%
%   Memoria es la memoria sin hechos, con el reloj en 0.
memoria_vacia(mt(0, [])).

%!  memoria_con(+Hechos:list, -Memoria) is det.
%
%   Memoria tiene los Hechos, agregados en el orden de la lista: el primero
%   recibe el sello 1. Un hecho repetido conserva el sello de su primera
%   aparición.
memoria_con(Hechos, Memoria) :-
    memoria_vacia(Memoria0),
    foldl(afirmar, Hechos, Memoria0, Memoria).

%!  afirmar(+Hecho, +Memoria0, -Memoria) is det.
%
%   Memoria es Memoria0 con Hecho, que recibe el sello siguiente del reloj.
%   Si Hecho ya estaba, Memoria es Memoria0: ni el hecho ni el reloj
%   cambian.
afirmar(Hecho, mt(Reloj0, Elementos), Memoria) :-
    (   memberchk(_-Hecho, Elementos)
    ->  Memoria = mt(Reloj0, Elementos)
    ;   Reloj is Reloj0 + 1,
        Memoria = mt(Reloj, [Reloj-Hecho|Elementos])
    ).

%!  retirar(+Hecho, +Memoria0, -Memoria) is semidet.
%
%   Memoria es Memoria0 sin el hecho que unifica con Hecho. Falla si no hay
%   ninguno.
retirar(Hecho, mt(Reloj, Elementos0), mt(Reloj, Elementos)) :-
    selectchk(_-Hecho, Elementos0, Elementos).

%!  elemento(?Sello, ?Hecho, +Memoria) is nondet.
%
%   Hecho está en Memoria con el Sello. Enumera los hechos del más reciente
%   al más antiguo.
elemento(Sello, Hecho, mt(_, Elementos)) :-
    member(Sello-Hecho, Elementos).

%!  hechos(+Memoria, -Hechos:list) is det.
%
%   Hechos son los hechos de Memoria, del más reciente al más antiguo.
hechos(mt(_, Elementos), Hechos) :-
    pairs_values(Elementos, Hechos).
