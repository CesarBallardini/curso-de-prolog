:- encoding(utf8).

:- begin_tests(motores).

test(primeros, [true(L == [3, 6, 9, 12, 15])]) :-
    primeros(5, X, multiplo(3, X), L).

% Una meta con menos respuestas que las pedidas da todas las que tiene.
test(menos_respuestas, [true(L == [a, b])]) :-
    primeros(5, X, member(X, [a, b]), L).

test(ninguna, [true(L == [])]) :-
    primeros(0, X, natural(X), L).

% La mezcla es la unión ordenada de los dos generadores.
test(mezclar, [true(L == Esperada)]) :-
    mezclar(20, multiplo(4), multiplo(6), L),
    findall(M, ( between(1, 60, M),
                 ( M mod 4 =:= 0 ; M mod 6 =:= 0 ) ), Ms),
    sort(Ms, Todos),
    length(Esperada, 20),
    append(Esperada, _, Todos).

test(parciales, [true(Ps == [5, 8, 18, 20])]) :-
    parciales([5, 3, 10, 2], Ps).

test(parciales_vacia, [true(Ps == [])]) :-
    parciales([], Ps).

% Los motores se destruyen al terminar: no queda ninguno.
test(sin_motores, [true(Ms == [])]) :-
    primeros(3, X, natural(X), _),
    mezclar(3, multiplo(2), multiplo(3), _),
    parciales([1, 2], _),
    findall(M, current_engine(M), Ms).

% Dos generadores iguales: cada número aparece una sola vez.
test(mezclar_iguales, [true(L == [2, 4, 6, 8, 10])]) :-
    mezclar(5, multiplo(2), multiplo(2), L).

:- end_tests(motores).
