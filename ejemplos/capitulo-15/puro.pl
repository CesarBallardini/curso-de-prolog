:- encoding(utf8).

% Capítulo 15 - El condicional puro: if_/3 de library(reif).
%
% sacar/3 de condicional.pl compara con ==, que pregunta por el estado actual
% de los términos: con X libre, ninguna comparación se cumple y el predicado
% falla sin decir nada. if_/3 decide con una condición reificada, (=)/3, que
% con X libre considera los dos casos: X igual a Y, y X distinto de Y.
%
% solo-local: requiere el pack reif (pack_install(reif)).
%?- sacar_puro(X, [a, b], R).
%?- tfilter(=(a), [a, b, a], L).

:- use_module(library(reif)).

%!  sacar_puro(?X, +L:list, ?R:list) is nondet.
%!  sacar_puro(+X, +L:list, ?R:list) is semidet.
%
%   R es L sin la primera aparición de X. Con X ligado se comporta como
%   sacar/3, sin dejar alternativas; con X libre enumera cada elemento que se
%   puede sacar.
sacar_puro(X, [Y|Ys], R) :-
    if_(X = Y,
        R = Ys,
        ( R = [Y|R0],
          sacar_puro(X, Ys, R0) )).

%!  iguales_a(?X, +L:list, ?Iguales:list) is nondet.
%
%   Iguales son los elementos de L que son iguales a X. tfilter/3 conserva los
%   elementos para los que la condición reificada es verdadera.
iguales_a(X, L, Iguales) :-
    tfilter(=(X), L, Iguales).
