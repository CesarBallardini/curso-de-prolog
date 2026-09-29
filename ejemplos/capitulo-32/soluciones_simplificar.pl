:- encoding(utf8).

% Capítulo 32 - Soluciones de los ejercicios 11 y 13: el simplificador con
% las reglas que agrupan términos semejantes, y la derivada simbólica.
%
% El archivo contiene el simplificador de simplificar.pl con tres reglas
% más, para cargarse solo. derivar/3 deriva con un caso por operación
% y simplifica el resultado.
%
%?- simplificar(2 * x + (y - y) * z + x ^ 1, E).
%?- derivar(x ^ 2 + 3 * x, x, D).

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
regla(N * X + X, P * X) :-
    number(N),
    P is N + 1.
regla(X + N * X, P * X) :-
    number(N),
    P is N + 1.
regla(N * X + M * X, P * X) :-
    number(N),
    number(M),
    P is N + M.
regla(X + X, 2 * X).
regla(_ ^ 0, 1).
regla(X ^ 1, X).

%!  derivar(+E, +X:atom, -D) is det.
%
%   D es la derivada de la expresión cerrada E respecto de la incógnita X,
%   simplificada. E usa +, -, * y ^ con exponente numérico.
derivar(E, X, D) :-
    must_be(ground, E),
    must_be(atom, X),
    derivada(E, X, D0),
    simplificar(D0, D).

%!  derivada(+E, +X:atom, -D) is det.
%
%   D es la derivada de E respecto de X, sin simplificar. Produce un error
%   de dominio si E contiene otra operación.
derivada(E, X, D) :-
    (   E == X
    ->  D = 1
    ;   atomic(E)
    ->  D = 0
    ;   E = U + V
    ->  D = DU + DV,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = U - V
    ->  D = DU - DV,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = U * V
    ->  D = DU * V + U * DV,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = U ^ N,
        number(N)
    ->  N1 is N - 1,
        D = N * U ^ N1 * DU,
        derivada(U, X, DU)
    ;   domain_error(expresion_derivable, E)
    ).
