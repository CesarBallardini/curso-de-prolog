:- encoding(utf8).

:- begin_tests(referencias).

% Guardar solo los sellos ocupa cerca de un cuarto de las celdas.
test(familia, [true(C-S == 1266-336)]) :-
    tamano_memorias(familia, familia, C, S).

test(cadena, [true(L == [5-837-231, 10-2532-696, 20-8397-2301])]) :-
    findall(N-C-S, ( member(N, [5, 10, 20]),
                     tamano_memorias(familia, cadena(N), C, S) ),
            L).

% Cada instancia guardada se reconstruye desde sus sellos, sin ambigüedad.
test(reconstruibles, [true(T-A == 42-0)]) :-
    reconstruibles(familia, familia, T, A).

% Con una prueba de varias soluciones, los sellos no alcanzan.
test(rangos, [true(T-A == 5-5)]) :-
    reconstruibles(rangos, lista([n(2), n(3)]), T, A).

test(reconstruir, [true(Is == [[alfa(n(2), [between(1, 2, 1)])],
                               [alfa(n(2), [between(1, 2, 2)])]])]) :-
    memoria_con([n(2)], M),
    findall(I, reconstruir([alfa(n(X), [between(1, X, _)])], M, [1], I),
            Is).

test(reconstruir_pasos, [true(Ps == [alfa(p(a), []), {a == a}, no(q(a))])]) :-
    memoria_con([p(a)], M),
    Ps = [alfa(p(X), []), {X == a}, no(q(X))],
    reconstruir_pasos(Ps, M, [1]).

test(reconstruir_paso_sin_hecho, [fail]) :-
    memoria_con([p(a)], M),
    reconstruir_paso(alfa(p(_), []), M, [2], _).

test(estado_final, [true(N == 8)]) :-
    estado_final(familia, lista([padre(juan, ana), padre(ana, sofia)]), _,
                 M, _),
    hechos(M, Hs),
    length(Hs, N).

test(todos_los_tokens, [true(N == 2)]) :-
    red_con_pruebas(familia, Red),
    cargar(Red, [padre(juan, ana), padre(ana, sofia)], _, R),
    todos_los_tokens(Red, R, Ts),
    include([B-_]>>(B =:= 1), Ts, Uno),
    length(Uno, N).

test(verificar_token, [true(A == 0)]) :-
    red_con_pruebas(familia, Red),
    cargar(Red, [padre(juan, ana)], M, R),
    todos_los_tokens(Red, R, [T|_]),
    Red = red(_, _, Nodos, _),
    verificar_token(Nodos, M, T, 0, A).

:- end_tests(referencias).
