:- encoding(utf8).

% Capítulo 32 - Un simplificador de expresiones: los primeros peldaños.
%
% regla/2 reescribe un nodo de una expresión aritmética cerrada, con los
% átomos como incógnitas. simplificar_raiz/2 aplica una regla solo a la
% raíz; simplificar_pasada/2 recorre la expresión una vez, de abajo hacia
% arriba; simplificar_repetido/2 repite pasadas completas hasta que la
% expresión no cambia. La versión final está en simplificar.pl.
%
%?- simplificar_raiz(x * (1 + 0), E).
%?- simplificar_pasada(x * (1 + 0), E).
%?- simplificar_pasada((x * 2) * 3, E).

:- use_module(library(terms)).

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

%!  simplificar_raiz(+E0, -E) is det.
%
%   E es E0 con una regla aplicada a la raíz, o E0 si ninguna se aplica.
simplificar_raiz(E0, E) :-
    (   regla(E0, E1)
    ->  E = E1
    ;   E = E0
    ).

%!  simplificar_pasada(+E0, -E) is det.
%
%   E es E0 simplificada en una pasada de abajo hacia arriba: primero los
%   argumentos, después la raíz, con una regla a lo sumo en cada nodo.
simplificar_pasada(E0, E) :-
    (   compound(E0)
    ->  mapargs(simplificar_pasada, E0, E1)
    ;   E1 = E0
    ),
    (   regla(E1, E2)
    ->  E = E2
    ;   E = E1
    ).

%!  simplificar_repetido(+E0, -E) is det.
%
%   E es E0 después de repetir pasadas completas hasta que una pasada no la
%   cambia.
simplificar_repetido(E0, E) :-
    simplificar_pasada(E0, E1),
    (   E1 == E0
    ->  E = E0
    ;   simplificar_repetido(E1, E)
    ).

%!  suma_de_prueba(+N:integer, -E) is det.
%
%   E es la expresión 0 + y * 1 * 3 + y * 2 * 3 + … + y * N * 3, con N
%   términos, para medir los simplificadores.
suma_de_prueba(N, E) :-
    numlist(1, N, Is),
    foldl([I, E0, E0 + y * I * 3]>>true, Is, 0, E).

%!  simplificar_verificando(+E0, -E) is det.
%
%   E es E0 simplificada hasta que ninguna regla se aplica, como en
%   simplificar.pl, pero verifica con must_be/2 que la expresión es cerrada
%   en cada llamada, también en las recursivas.
simplificar_verificando(E0, E) :-
    must_be(ground, E0),
    (   compound(E0)
    ->  mapargs(simplificar_verificando, E0, E1)
    ;   E1 = E0
    ),
    (   regla(E1, E2)
    ->  simplificar_verificando(E2, E)
    ;   E = E1
    ).
