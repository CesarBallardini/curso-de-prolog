:- encoding(utf8).

:- use_module(library(apply)).

:- begin_tests(moore).

% 101 es 5: los restos de 1, 10 y 101 son 1, 2 y 2.
test(resto, all(S == [[0, 1, 2, 2]])) :-
    moore(resto3, [1, 0, 1], S).

test(vacia, all(S == [[0]])) :-
    moore(resto3, [], S).

% Las salidas determinan la entrada: los restos sucesivos dan los bits.
test(inversa, all(E == [[1, 0, 1]])) :-
    length(E, 3),
    moore(resto3, E, [0, 1, 2, 2]).

test(salida_estado, all(Q-S == [r0-0, r1-1, r2-2])) :-
    salida_estado(resto3, Q, S).

test(recorrer, all(S == [[1, 2]])) :-
    moore:recorrer(resto3, r0, [1, 0], S).

test(mealy, all(S == [[1, 2, 2]])) :-
    transducir(mealy(resto3), [1, 0, 1], S).

test(mealy_inversa, all(E == [[1, 0, 1]])) :-
    length(E, 3),
    transducir(mealy(resto3), E, [1, 2, 2]).

% La máquina de Mealy da la salida de Moore sin la del estado inicial.
test(moore_mealy, [forall(( between(0, 5, N), length(E, N),
                            maplist([B]>>member(B, [0, 1]), E) )),
                   true(S == [0|S1])]) :-
    once(moore(resto3, E, S)),
    once(transducir(mealy(resto3), E, S1)).

% El último resto es el resto del número.
test(resto_final, [forall(between(0, 20, N)), true(R =:= N mod 3)]) :-
    format(atom(A), '~2r', [N]),
    atom_chars(A, Cs),
    maplist([C, B]>>atom_number(C, B), Cs, Bits),
    once(moore(resto3, Bits, S)),
    last(S, R).

:- end_tests(moore).
