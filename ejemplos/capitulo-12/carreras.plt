:- encoding(utf8).

:- begin_tests(carreras).

test(recibidos_de_civil, all(N == ["Lucía Ferreyra"])) :-
    exigencias_cumplidas(ingenieria_civil, N).

test(recibidos_de_quimica, all(N == ["Romina Montalbán"])) :-
    exigencias_cumplidas(ingenieria_quimica, N).

test(daniel_debe_materiales, [fail]) :-
    exigencias_cumplidas(ingenieria_civil, "Daniel Hernández").

test(materias_que_debe_daniel, all(M == [materiales])) :-
    materia_no_aprobada(ingenieria_civil, 2310, M).

:- end_tests(carreras).
