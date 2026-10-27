:- encoding(utf8).

:- begin_tests(mastermind).

test(primeros, [true(Cs == [[0, 1, 2, 3], [0, 1, 2, 4], [0, 1, 2, 5]])]) :-
    findall(C, limit(3, codigo(C)), Cs).

test(cantidad, [true(N == 5040)]) :-
    aggregate_all(count, codigo(_), N).

test(ultimo, [true(C == [9, 8, 7, 6])]) :-
    findall(C0, codigo(C0), Cs),
    last(Cs, C).

test(respuesta, [true(T-V == 1-1)]) :-
    respuesta([1, 2, 3, 4], [1, 3, 5, 6], T, V).

test(acierto, [true(T-V == 4-0)]) :-
    respuesta([3, 8, 1, 6], [3, 8, 1, 6], T, V).

test(todas_vacas, [true(T-V == 0-4)]) :-
    respuesta([1, 2, 3, 4], [4, 3, 2, 1], T, V).

% La respuesta es simétrica: el secreto y el intento pueden intercambiarse.
test(simetrica, [true(Asimetricos == [])]) :-
    findall(A-B, ( member(A, [[0, 1, 2, 3], [3, 8, 1, 6], [9, 8, 7, 6]]),
                   member(B, [[1, 0, 4, 5], [6, 1, 8, 3], [3, 8, 1, 6]]),
                   respuesta(A, B, T1, V1),
                   \+ respuesta(B, A, T1, V1) ),
            Asimetricos).

test(consistente) :-
    consistente([r([0, 1, 2, 3], 1, 0)], [0, 4, 5, 6]).

test(inconsistente, [fail]) :-
    consistente([r([0, 1, 2, 3], 1, 0)], [1, 0, 4, 5]).

test(siguiente, [true(I == [1, 4, 5, 6])]) :-
    siguiente([r([0, 1, 2, 3], 0, 1)], I).

test(contradiccion, [fail]) :-
    siguiente([r([0, 1, 2, 3], 4, 0), r([0, 1, 2, 4], 4, 0)], _).

test(adivinar, [true(Is == [[0, 1, 2, 3], [1, 0, 4, 5], [2, 3, 5, 6],
                            [2, 4, 3, 7], [3, 8, 0, 6], [3, 8, 1, 6]])]) :-
    adivinar([3, 8, 1, 6], Is).

test(primero, [true(Is == [[0, 1, 2, 3]])]) :-
    adivinar([0, 1, 2, 3], Is).

test(medir, [true(Q-M == [1-1, 6-1]-3.5)]) :-
    medir(adivinar, [[0, 1, 2, 3], [3, 8, 1, 6]], Q, M).

:- end_tests(mastermind).
