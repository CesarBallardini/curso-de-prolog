:- encoding(utf8).

:- begin_tests(azar).

test(rango, [true(Ks == [])]) :-
    findall(K,
            ( between(1, 200, I),
              azar(7, K, I, _),
              \+ between(0, 6, K) ),
            Ks).

% La misma semilla da siempre el mismo número y el mismo estado siguiente.
test(reproducible, [true(K1-S1 == K2-S2)]) :-
    azar(20, K1, 12345, S1),
    azar(20, K2, 12345, S2).

test(estado, [true(S == 1103527590)]) :-
    azar(2, _, 1, S).

test(distintos, [true(N == 6)]) :-
    numlist(1, 20, Xs),
    elegir_distintos(6, Xs, Es, 99, _),
    sort(Es, Ordenados),
    length(Ordenados, N).

test(pocos, [fail]) :-
    elegir_distintos(3, [a, b], _, 1, _).

test(vacia, [fail]) :-
    elegir([], _, 1, _).

test(tamano, [error(type_error(positive_integer, 0))]) :-
    azar(0, _, 1, _).

:- end_tests(azar).
