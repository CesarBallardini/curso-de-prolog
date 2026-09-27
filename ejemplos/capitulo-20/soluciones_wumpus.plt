:- encoding(utf8).

:- begin_tests(soluciones_wumpus, [ cleanup(reiniciar) ]).

% Ejercicio 11
test(camino_de_vuelta, [ setup(explorar(oro(C))),
                         true(L == [2-3, 2-2, 1-2, 1-1]) ]) :-
    camino_de_vuelta(C, L).

% Cada paso del camino va a una celda vecina y visitada.
test(camino_valido, [ setup(explorar(oro(C))), fail ]) :-
    camino_de_vuelta(C, L),
    append(_, [A, B|_], L),
    \+ ( vecina(A, B), visitada(B) ).

test(desde_la_entrada, [ setup(explorar(_)), true(L == [1-1]) ]) :-
    camino_de_vuelta(1-1, L).

% Ejercicio 12
test(posibles_pozos, [ setup(explorar(_)),
                       all(C == [2-4, 3-1, 3-3, 4-2]) ]) :-
    posible_pozo(C).

% Los pozos de la cueva vecinos de una celda visitada están entre los
% posibles.
test(pozos_reales, [ setup(explorar(_)), all(C == [3-1, 3-3]) ]) :-
    pozo(C),
    posible_pozo(C).

:- end_tests(soluciones_wumpus).
