:- encoding(utf8).

:- begin_tests(soluciones_orden).

% Ejercicio 7: sin amenazas, las dos evaluaciones coinciden.
test(sin_amenazas, [true(A-B == 1-1)]) :-
    P = pos([x, v, v, v, o, v, v, v, x], o),
    evaluar(tateti(3), P, A),
    evaluar_amenazas(tateti(3), P, B).

test(amenaza_de_x, [true(A-B == 0-10)]) :-
    P = pos([x, x, v, v, o, v, v, v, v], o),
    evaluar(tateti(3), P, A),
    evaluar_amenazas(tateti(3), P, B).

% Una amenaza de cada jugador se compensan.
test(amenazas_compensadas, [true(A == B)]) :-
    P = pos([o, o, v, x, x, v, v, v, v], x),
    evaluar(tateti(3), P, A),
    evaluar_amenazas(tateti(3), P, B).

% Ejercicio 8: el orden central, con el mismo valor y menos nodos que el
% natural.
test(central_3, [true(J-V-N == 5-0-7865)]) :-
    inicial(tateti(3), P),
    alfabeta(central, tateti(3), P, 9, J, V, N).

test(central_4, [true(J-V-N == 1-0-14637)]) :-
    inicial(tateti(4), P),
    alfabeta(central, tateti(4), P, 6, J, V, N).

:- end_tests(soluciones_orden).
