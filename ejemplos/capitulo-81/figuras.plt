:- encoding(utf8).

:- begin_tests(figuras).

test(extremos_existentes) :-
    forall(member(F, [cubo, bloques, escalon, poiuyt, escalera(3)]),
           forall(segmento(F, A, B),
                  ( punto(F, A, _, _), punto(F, B, _, _) ))).

test(cantidades, [true(Ns == [cubo-7-9, bloques-15-20, escalon-11-15,
                              poiuyt-12-13])]) :-
    findall(F-P-S,
            ( member(F, [cubo, bloques, escalon, poiuyt]),
              aggregate_all(count, punto(F, _, _, _), P),
              aggregate_all(count, segmento(F, _, _), S) ),
            Ns).

test(escalera_crece, [true(Ns == [7-9, 11-15, 15-21, 43-63])]) :-
    findall(P-S,
            ( member(N, [1, 2, 3, 10]),
              aggregate_all(count, punto(escalera(N), _, _, _), P),
              aggregate_all(count, segmento(escalera(N), _, _), S) ),
            Ns).

test(escalera_sin_tamano, [fail]) :-
    punto(escalera(0), _, _, _).

test(punto_escalera, [nondet, true(X/Y == 20/10)]) :-
    punto_escalera(2, c(2), X, Y).

test(segmento_escalera, [nondet]) :-
    segmento_escalera(3, c2(1), v2(2)).

:- end_tests(figuras).
