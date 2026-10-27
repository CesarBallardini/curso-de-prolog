:- encoding(utf8).

:- begin_tests(profundizacion).

% Con tiempo suficiente, la profundización llega al final de la partida y
% da el mismo valor que la búsqueda completa.
test(completa, [true(V-D == 0-5)]) :-
    P = pos([x, o, v, v, x, v, v, v, o], o),
    profundizar(tateti(3), P, 10, _, V, D),
    alfabeta(tateti(3), P, 5, _, V, _).

% Una victoria encontrada a profundidad 3 detiene la profundización.
test(victoria, [true(J-V-D == 4-102-3)]) :-
    profundizar(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), 10, J, V, D).

test(sin_tiempo, [true(J-V-D == ninguna-0-0)]) :-
    profundizar(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), 0, J, V, D).

% Con poco tiempo, el 4 por 4 queda a una profundidad intermedia, que
% depende de la máquina.
test(interrumpida, [true((integer(J), D >= 1, D < 16))]) :-
    inicial(tateti(4), P),
    profundizar(tateti(4), P, 0.2, J, _, D).

% La jugada que ya fue la mejor se busca primero.
test(primero, [true(J-V == 4-0)]) :-
    primero(tateti(3), pos([x, o, v, v, x, v, v, v, o], o), 5, 4, J, V).

test(completa_llena, [true]) :-
    completa(tateti(3), pos([x, o, v, v, x, v, v, v, o], o), 5, 0).

test(completa_victoria, [true]) :-
    completa(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), 3, 102).

test(no_completa, [fail]) :-
    completa(tateti(3), pos([x, o, v, v, x, v, v, v, o], o), 3, 0).

:- end_tests(profundizacion).
