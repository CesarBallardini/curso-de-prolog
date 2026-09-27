:- encoding(utf8).

% Capítulo 23 - Las N reinas: ubicar N reinas en un tablero de N x N sin que
% ninguna ataque a otra.
%
% La reina de la columna i está en la fila Qi: la lista [Q1, …, QN] ya pone
% una reina por columna. reinas/2 restringe filas y diagonales y etiqueta;
% reinas_gyp/2 genera las permutaciones de las filas y prueba cada una, como
% la plantilla 15.
%
%?- reinas(8, Qs).
%?- reinas(20, Qs).

:- use_module(library(clpfd)).

%!  reinas(+N:integer, -Qs:list(integer)) is nondet.
%
%   Qs es una ubicación de N reinas que no se atacan: la reina de la columna
%   i está en la fila i-ésima de Qs.
reinas(N, Qs) :-
    length(Qs, N),
    Qs ins 1..N,
    seguras(Qs),
    labeling([ff], Qs).

%!  seguras(+Qs:list) is semidet.
%
%   Ninguna reina de Qs ataca a otra: restringe cada una contra las de su
%   derecha.
seguras([]).
seguras([Q|Qs]) :-
    no_ataca(Q, Qs, 1),
    seguras(Qs).

%!  no_ataca(+Q, +Qs:list, +D:integer) is semidet.
%
%   La reina Q no ataca a las de Qs, la primera de las cuales está D
%   columnas a su derecha: otra fila y otra diagonal.
no_ataca(_, [], _).
no_ataca(Q, [Q1|Qs], D) :-
    Q #\= Q1,
    abs(Q - Q1) #\= D,
    D1 is D + 1,
    no_ataca(Q, Qs, D1).

%!  reinas_gyp(+N:integer, -Qs:list(integer)) is nondet.
%
%   La misma relación, con generar y probar: cada permutación de las filas
%   se genera completa y después se comprueba.
reinas_gyp(N, Qs) :-
    numlist(1, N, Filas),
    permutation(Filas, Qs),
    seguras_gyp(Qs).

%!  seguras_gyp(+Qs:list(integer)) is semidet.
%
%   Ninguna reina de Qs, ya ubicadas, ataca a otra.
seguras_gyp([]).
seguras_gyp([Q|Qs]) :-
    no_ataca_gyp(Q, Qs, 1),
    seguras_gyp(Qs).

%!  no_ataca_gyp(+Q:integer, +Qs:list(integer), +D:integer) is semidet.
%
%   La reina Q no ataca a las de Qs, comparando filas ya conocidas.
no_ataca_gyp(_, [], _).
no_ataca_gyp(Q, [Q1|Qs], D) :-
    Q =\= Q1,
    abs(Q - Q1) =\= D,
    D1 is D + 1,
    no_ataca_gyp(Q, Qs, D1).
