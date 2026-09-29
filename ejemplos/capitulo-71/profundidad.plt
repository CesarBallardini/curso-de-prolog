:- encoding(utf8).

:- begin_tests(profundidad).

test(primer_arbol, [true(K-C == 24-241)]) :-
    resolver(rio(cero), ruta(alamos, islas), A, K),
    costo(A, C).

test(recorrido, [true(Ps == [alamos, cantera, paso, granja, islas, fuente,
                             molino, fuente, granja, islas])]) :-
    resolver(rio(cero), ruta(alamos, islas), A, _),
    pueblos(A, Ps).

test(primitivo, [true(A-K == meta(ruta(paso, paso))-0)]) :-
    resolver(rio(cero), ruta(paso, paso), A, K).

test(sin_solucion, [fail]) :-
    resolver(hanoi_inexistente, ruta(alamos, islas), _, _).

test(cuenta_fracasos, [true(R-K == no-0)]) :-
    profundidad(rio(cero), ruta(alamos, islas), [ruta(alamos, islas)], R,
                0, K).

test(viaje, [true(C-K == 241-24)]) :-
    viaje(profundidad, alamos, islas, _, C, K).

:- end_tests(profundidad).
