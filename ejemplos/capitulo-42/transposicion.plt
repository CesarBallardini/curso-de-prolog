:- encoding(utf8).

:- begin_tests(transposicion, [setup(abolish_all_tables)]).

test(vacio, [true(J-V == 1-0)]) :-
    inicial(tateti(3), P),
    jugada_optima(tateti(3), P, J, V).

% El árbol tiene 549 946 nodos; las posiciones distintas son 5 478.
test(posiciones, [true(N == 5478)]) :-
    abolish_all_tables,
    inicial(tateti(3), P),
    jugada_optima(tateti(3), P, _, _),
    posiciones(N).

test(defiende_o, [true(J-V == 3-0)]) :-
    jugada_optima(tateti(3), pos([x, o, v, v, x, v, v, v, o], o), J, V).

test(gana_x, [true(J-V == 4-102)]) :-
    jugada_optima(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), J, V).

test(terminada, [fail]) :-
    jugada_optima(tateti(3), pos([x, x, x, o, o, v, v, v, v], o), _, _).

% Los valores de las respuestas a una esquina: solo el centro empata.
test(respuestas, [true(Vs == [2-102, 3-102, 4-102, 5-0, 6-102, 7-102,
                              8-102, 9-102])]) :-
    findall(C-V, ( jugada(tateti(3), pos([x, v, v, v, v, v, v, v, v], o),
                          C, P),
                   valor(tateti(3), P, V) ), Vs).

test(limitado, [true(Vs == [3, 0, 3])]) :-
    inicial(tateti(4), P),
    findall(V, ( between(1, 3, D),
                 valor_limitado(tateti(4), P, D, V) ), Vs).

:- end_tests(transposicion).
