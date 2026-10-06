:- encoding(utf8).

:- begin_tests(capitulo41).

test(alfabeta, [true(J-V-N == 5-1-36)]) :-
    inicial(tateti(3), P),
    alfabeta(tateti(3), P, 2, J, V, N).

test(profundizar, [true(D >= 1)]) :-
    inicial(tateti(3), P),
    profundizar(tateti(3), P, 1, _, _, D).

test(fin, [true(R == gana(x))]) :-
    fin(tateti(3), pos([x, x, x, o, o, v, v, v, v], o), R).

test(jugadas, [true(N == 9)]) :-
    inicial(tateti(3), P),
    aggregate_all(count, jugada(tateti(3), P, _, _), N).

test(turno, [true(L == min)]) :-
    turno(tateti(3), pos([x, v, v, v, v, v, v, v, v], o), L).

test(valor_final, [true(V == 0)]) :-
    valor_final(empate, cualquiera, V).

test(evaluar, [true(V == 4)]) :-
    evaluar(tateti(3), pos([v, v, v, v, x, v, v, v, v], o), V).

:- end_tests(capitulo41).
