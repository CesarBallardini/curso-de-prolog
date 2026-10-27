:- encoding(utf8).

:- begin_tests(consultas).

test(ranking, true(R == [101-8.5, 104-8, 103-6, 106-4.5, 102-4])) :-
    ranking(R).

test(horario, true(D == 1)) :-
    once(horario(5, 6, H)),
    memberchk(am1-D, H).

:- end_tests(consultas).
