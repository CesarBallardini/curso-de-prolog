:- encoding(utf8).

% Capítulo 32 - Un simplificador de expresiones aritméticas.
%
% simplificar/2 reescribe una expresión cerrada, con los átomos como
% incógnitas, de abajo hacia arriba: simplifica los argumentos de cada
% nodo, aplica una regla a la raíz y, si una regla se aplicó, simplifica
% otra vez el resultado. El capítulo 43 carga este archivo para resolver
% ecuaciones.
%
%?- simplificar((x * 2) * 3, E).
%?- simplificar(2 * x + (y - y) * z + x ^ 1, E).

:- use_module(library(error)).
:- use_module(library(terms)).

%!  simplificar(+E0, -E) is det.
%
%   E es la expresión cerrada E0 simplificada: ninguna regla se aplica a
%   ninguno de sus nodos. Produce un error de instanciación si E0 tiene
%   variables.
simplificar(E0, E) :-
    must_be(ground, E0),
    simp(E0, E).

%!  simp(+E0, -E) is det.
%
%   E es E0 simplificada, como en simplificar/2, sin verificar E0.
simp(E0, E) :-
    (   compound(E0)
    ->  mapargs(simp, E0, E1)
    ;   E1 = E0
    ),
    (   regla(E1, E2)
    ->  simp(E2, E)
    ;   E = E1
    ).

%!  regla(+E0, -E) is nondet.
%
%   E es el resultado de reescribir la raíz de la expresión cerrada E0 con
%   una regla: una respuesta por cada regla que se aplica, en el orden de
%   las cláusulas. Los simplificadores usan solo la primera.
regla(E, V) :-
    E =.. [Op, A, B],
    memberchk(Op, [+, -, *]),
    number(A),
    number(B),
    V is E.
regla(0 + X, X).
regla(X + 0, X).
regla(X - 0, X).
regla(X - X, 0).
regla(0 * _, 0).
regla(_ * 0, 0).
regla(1 * X, X).
regla(X * 1, X).
regla(X * N, N * X) :-
    number(N),
    \+ number(X).
regla(N * (M * X), P * X) :-
    number(N),
    number(M),
    P is N * M.
regla(X + X, 2 * X).
regla(_ ^ 0, 1).
regla(X ^ 1, X).
