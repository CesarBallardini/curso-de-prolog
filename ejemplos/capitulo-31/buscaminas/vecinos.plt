:- encoding(utf8).

:- begin_tests(vecinos).

test(esquina, true(N == 3)) :-
    aggregate_all(count, vecina(3, 3, 1-1, _), N).

test(centro, true(N == 8)) :-
    aggregate_all(count, vecina(3, 3, 2-2, _), N).

test(minas_vecinas, true(N == 2)) :-
    minas_vecinas(3, 3, [1-1, 3-3], 2-2, N).

:- end_tests(vecinos).
