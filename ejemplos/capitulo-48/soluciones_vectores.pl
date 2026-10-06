:- encoding(utf8).

% Capítulo 48 - Solución del ejercicio 12: la cobertura mínima.
%
% Los implicantes primos de una salida cubren todas sus filas en 1, pero
% algunos pueden sobrar. cobertura/3 elige la menor cantidad de ellos que
% cubre todas las filas, probando primero los conjuntos más chicos.
%
% solo-local: carga el módulo vectores, y SWISH no admite módulos propios.
%
%?- unos(sumador, co, Us), implicantes_primos(Us, Ps), cobertura(Us, Ps, Cs).

:- use_module(vectores).

%!  cobertura(+Unos:list(list), +Primos:list(list), -Elegidos:list(list))
%!      is semidet.
%
%   Elegidos es un subconjunto de Primos, de la menor cantidad posible de
%   elementos, tal que cada vector de Unos está cubierto por alguno de
%   ellos. Entre los del mismo tamaño, da el primero en el orden de
%   Primos. Falla si Primos no cubre todos los Unos.
cobertura(Unos, Primos, Elegidos) :-
    length(Primos, N),
    between(0, N, K),
    length(Elegidos, K),
    subconjunto(Primos, Elegidos),
    forall(member(U, Unos),
           ( member(P, Elegidos),
             cubre(P, U) )),
    !.

%!  subconjunto(+Lista:list, ?Sub:list) is nondet.
%
%   Sub tiene elementos de Lista, en el mismo orden.
subconjunto([], []).
subconjunto([X|Xs], [X|Ys]) :-
    subconjunto(Xs, Ys).
subconjunto([_|Xs], Ys) :-
    subconjunto(Xs, Ys).
