:- encoding(utf8).

% Capítulo 47 - Versión 2: los números racionales de SWI-Prolog.
%
% SWI-Prolog tiene los racionales como un tipo de número más, junto a los
% enteros y los de punto flotante: rdiv/2 los construye dentro de is/2, se
% escriben y se leen como 1r3, y las operaciones aritméticas de siempre los
% aceptan. is/2 reemplaza a q_valor/2, y los predicados de la versión 1 se
% reducen a conversiones. armonica/2 es la suma de la versión 1 con los
% racionales del sistema; suma_repetida/3 muestra el error de redondeo que
% los racionales evitan.
%
%?- X is 1 rdiv 3 + 1 rdiv 6.
%?- armonica(10, Q).
%?- a_nativo(fr(-3, 2), Q).
%?- de_nativo(5r2, F).
%?- suma_repetida(0.1, 10, S).
%?- suma_repetida(1r10, 10, S).

:- use_module(library(error)).

%!  a_nativo(+Fr, -Q:rational) is det.
%
%   Q es el racional de SWI-Prolog que representa el término fr(N, D).
a_nativo(fr(N, D), Q) :-
    Q is N rdiv D.

%!  de_nativo(+Q:rational, -Fr) is det.
%
%   Fr es el término fr(N, D) en forma normal que representa el racional
%   Q, que también puede ser un entero.
de_nativo(Q, fr(N, D)) :-
    must_be(rational, Q),
    rational(Q, N, D).

%!  armonica(+N:integer, -Q:rational) is det.
%
%   Q es la suma exacta 1/1 + 1/2 + ... + 1/N, con los racionales de
%   SWI-Prolog. Si N es 0, Q es 0.
armonica(N, Q) :-
    must_be(nonneg, N),
    armonica(N, 0, Q).

%!  armonica(+K:integer, +Acumulado:rational, -Q:rational) is det.
%
%   Q es Acumulado más la suma de 1/1 hasta 1/K.
armonica(0, Q, Q) :-
    !.
armonica(K, Q0, Q) :-
    Q1 is Q0 + 1 rdiv K,
    K1 is K - 1,
    armonica(K1, Q1, Q).

%!  suma_repetida(+X:number, +N:integer, -S:number) is det.
%
%   S es la suma de N sumandos iguales a X, calculada sumando uno por vez.
%   Con un X de punto flotante, cada suma redondea; con un racional, no.
suma_repetida(X, N, S) :-
    must_be(number, X),
    must_be(nonneg, N),
    suma_repetida(N, X, 0, S).

%!  suma_repetida(+K:integer, +X:number, +S0:number, -S:number) is det.
%
%   S es S0 más K sumandos iguales a X.
suma_repetida(0, _, S, S) :-
    !.
suma_repetida(K, X, S0, S) :-
    S1 is S0 + X,
    K1 is K - 1,
    suma_repetida(K1, X, S1, S).
