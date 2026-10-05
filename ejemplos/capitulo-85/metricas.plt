:- encoding(utf8).

:- begin_tests(metricas).

archivo(registros('2026-10-01.log')).

test(reglas, [true(N == 6)]) :-
    reglas_metricas(Rs),
    length(Rs, N).

test(programa) :-
    archivo(A),
    programa_metricas(A, Cs),
    memberchk((umbral(fallos, mayor, 10) :- true), Cs),
    memberchk((medida(10, fallos, 62) :- true), Cs).

% Las mismas anomalías que el capítulo 84.
test(como_capitulo84, [true(As == Bs)]) :-
    archivo(A),
    anomalias_motor(A, As),
    anomalias_capitulo84(A, Bs).

test(anomalias, [true(Hs == [10, 12, 14, 17, 18])]) :-
    archivo(A),
    anomalias_motor(A, As),
    findall(H, member(H-_-_, As), Hs0),
    sort(Hs0, Hs).

test(rachas, [true(Rs == [racha(17, 18)])]) :-
    archivo(A),
    consulta_metricas(A, racha(D, H), Todas, _),
    findall(racha(D, H), ( member(racha(D, H), Todas), D \== H ), Rs).

test(normales, [true(Hs == [8, 9, 11, 13, 15, 16, 19])]) :-
    archivo(A),
    consulta_metricas(A, normal(_), Rs, _),
    findall(H, member(normal(H), Rs), Hs).

:- end_tests(metricas).
