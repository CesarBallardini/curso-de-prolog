:- encoding(utf8).

% Capítulo 15 - Soluciones de los ejercicios 10 y 15, con library(reif).
%
% solo-local: requiere el pack reif (pack_install(reif)).
%?- sin_repetidos_puro([a, X], R).
%?- categoria_pura(sofia, C).

:- use_module(library(reif)).

% --- Ejercicio 10 ----------------------------------------------------------

%!  sin_repetidos_puro(?L:list, ?R:list) is nondet.
%
%   R es L sin repetidos; conserva la primera aparición de cada elemento.
%   Con elementos libres, considera los dos casos para cada comparación.
sin_repetidos_puro(L, R) :-
    sin_los_vistos_puro(L, [], R).

%!  sin_los_vistos_puro(?L:list, +Vistos:list, ?R:list) is nondet.
%
%   R es L sin los elementos de Vistos y sin repetidos.
sin_los_vistos_puro([], _, []).
sin_los_vistos_puro([X|Resto], Vistos, R) :-
    if_(memberd_t(X, Vistos),
        R = R0,
        R = [X|R0]),
    sin_los_vistos_puro(Resto, [X|Vistos], R0).

% --- Ejercicio 15 ----------------------------------------------------------

% edad(P, A): P tiene A años.
edad(luis, 12).
edad(sofia, 3).

%!  menor_t(+X:number, +Y:number, -T:boolean) is det.
%!  menor_t(+X:number, +Y:number, +T:boolean) is semidet.
%
%   T es true si X < Y, y false si no. No es una condición reificada pura:
%   compara con </2, que exige que X e Y tengan valor.
menor_t(X, Y, T) :-
    (   X < Y
    ->  T = true
    ;   T = false
    ).

%!  categoria_pura(?P, ?C) is nondet.
%
%   C es la categoría de P según su edad, con if_/3.
categoria_pura(P, C) :-
    edad(P, A),
    if_(menor_t(A, 4),
        C = bebe,
        if_(menor_t(A, 13),
            C = chico,
            C = adulto)).
