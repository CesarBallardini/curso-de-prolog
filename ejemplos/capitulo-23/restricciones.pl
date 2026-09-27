:- encoding(utf8).

% Capítulo 23 - Restricciones sobre enteros con library(clpfd), y dif/2.
%
% #= es una igualdad aritmética que admite variables en los dos lados: la
% relación funciona en todos los sentidos. Las variables tienen dominios, las
% restricciones los reducen, y label/1 busca los valores. El criptoaritmo
% SEND + MORE = MONEY es el ejemplo clásico.
%
%?- n_factorial(N, 120).
%?- send_more_money(Letras).

:- use_module(library(clpfd)).

%!  doble(?X:integer, ?Y:integer) is semidet.
%
%   Y es el doble de X. Con uno de los dos ligado, hay a lo sumo una
%   respuesta; con los dos libres, la relación queda como restricción.
doble(X, Y) :-
    Y #= 2 * X.

%!  n_factorial(?N:integer, ?F:integer) is nondet.
%
%   F es el factorial de N. Funciona en los dos sentidos: de N a F y de F a
%   N.
n_factorial(0, 1).
n_factorial(N, F) :-
    N #> 0,
    N1 #= N - 1,
    F #= N * F1,
    n_factorial(N1, F1).

%!  tres_que_suman(?Suma:integer, -Xs:list(integer)) is nondet.
%
%   Xs son tres dígitos distintos, en orden creciente, que suman Suma.
tres_que_suman(Suma, Xs) :-
    Xs = [A, B, C],
    Xs ins 0..9,
    all_different(Xs),
    A #< B,
    B #< C,
    sum(Xs, #=, Suma),
    label(Xs).

%!  cantidad_de_unos(?Xs:list(integer), ?N:integer) is nondet.
%
%   N es la cantidad de elementos de Xs iguales a 1. Cada comparación se
%   refleja en una variable booleana, 1 si se cumple y 0 si no, y N es su
%   suma.
cantidad_de_unos(Xs, N) :-
    maplist([X, B]>>(B #<==> (X #= 1)), Xs, Bs),
    sum(Bs, #=, N).

%!  send_more_money(-Letras:list(integer)) is det.
%
%   Letras son los dígitos de S, E, N, D, M, O, R e Y, distintos entre sí,
%   tales que SEND + MORE = MONEY, sin ceros a la izquierda.
send_more_money([S, E, N, D, M, O, R, Y]) :-
    Letras = [S, E, N, D, M, O, R, Y],
    Letras ins 0..9,
    all_different(Letras),
    S #\= 0,
    M #\= 0,
              1000 * S + 100 * E + 10 * N + D
    +         1000 * M + 100 * O + 10 * R + E
    #= 10000 * M + 1000 * O + 100 * N + 10 * E + Y,
    label(Letras).

%!  distintos(?X, ?Y) is semidet.
%
%   X e Y son distintos, con dif/2: si todavía no tienen valor, la
%   comparación se posterga hasta que lo tengan.
distintos(X, Y) :-
    dif(X, Y).
