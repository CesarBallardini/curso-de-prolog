:- encoding(utf8).

:- begin_tests(tateti).

test(inicial, [true(P == pos([v, v, v, v, v, v, v, v, v], x))]) :-
    inicial(tateti(3), P).

test(jugadas, [true(Js == [3, 4, 6, 7, 8])]) :-
    findall(J, jugada(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), J, _),
            Js).

test(jugada, [true(P == pos([x, o, v, v, x, v, x, v, o], o))]) :-
    jugada(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), 7, P).

test(lineas, [true(N-M == 8-10)]) :-
    lineas(tateti(3), L3),
    length(L3, N),
    lineas(tateti(4), L4),
    length(L4, M).

test(gana_fila, [true(R == gana(x))]) :-
    fin(tateti(3), pos([x, x, x, o, o, v, v, v, v], o), R).

test(gana_diagonal, [true(R == gana(o))]) :-
    fin(tateti(3), pos([x, x, o, x, o, v, o, v, v], x), R).

test(gana_columna_4, [true(R == gana(x))]) :-
    fin(tateti(4), pos([v, x, v, v, o, x, o, v, v, x, v, o, v, x, v, v], o),
        R).

test(empate, [true(R == empate)]) :-
    fin(tateti(3), pos([x, o, x, x, o, o, o, x, x], o), R).

test(sigue, [fail]) :-
    fin(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), _).

test(valor_final, [true(Vs == [104, -103, 0])]) :-
    valor_final(gana(x), pos([x, x, x, o, o, v, v, v, v], o), V1),
    valor_final(gana(o), pos([x, x, o, x, o, v, o, v, v], x), V2),
    valor_final(empate, pos([x, o, x, x, o, o, o, x, x], o), V3),
    Vs = [V1, V2, V3].

% x juega 7 y amenaza dos líneas a la vez.
test(ganada) :-
    ganada(tateti(3), pos([x, o, v, v, x, v, v, v, o], x)).

% Con buen juego de los dos, el ta-te-ti es un empate.
test(no_ganada, [fail]) :-
    inicial(tateti(3), P),
    ganada(tateti(3), P).

test(no_ganada_o, [fail]) :-
    ganada(tateti(3), pos([x, v, v, v, v, v, v, v, v], o)).

test(partidas, [true(N == 5)]) :-
    partidas(tateti(3), pos([x, o, x, o, x, v, v, v, o], x), N).

test(filas, [true(L == ["X O 3", "4 X 6", "7 8 O"])]) :-
    filas(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), L).

test(turno, [true(Ls == [max, min])]) :-
    turno(tateti(3), pos([v, v, v, v, v, v, v, v, v], x), L1),
    turno(tateti(3), pos([x, v, v, v, v, v, v, v, v], o), L2),
    Ls = [L1, L2].

% Ocupada, la casilla no admite otra marca.
test(jugada_ocupada, [fail]) :-
    jugada(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), 1, _).

test(perdida_terminada) :-
    perdida(tateti(3), pos([x, x, x, o, o, v, v, v, v], o)).

% Con x en 1 y en 5, y o en 2 y en 9, o no pierde si le toca mover.
test(perdida_no, [fail]) :-
    perdida(tateti(3), pos([x, o, v, v, x, v, v, v, o], o)).

test(empate_no_es_perdida, [fail]) :-
    perdida(tateti(3), pos([x, o, x, x, o, o, o, x, x], x)).

test(partida, [all(Js == [[6, 7, 8], [6, 8, 7], [7], [8, 6, 7],
                          [8, 7, 6]])]) :-
    partida(tateti(3), pos([x, o, x, o, x, v, v, v, o], x), Js).

test(partidas_terminada, [true(N == 1)]) :-
    partidas(tateti(3), pos([x, x, x, o, o, v, v, v, v], o), N).

test(filas_4, [true(L == [" X  2  3  4", " 5  O  7  8", " 9 10 11 12",
                          "13 14 15 16"])]) :-
    filas(tateti(4), pos([x, v, v, v, v, o, v, v, v, v, v, v, v, v, v, v],
                         x), L).

:- end_tests(tateti).
