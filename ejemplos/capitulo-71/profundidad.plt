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

% reducir/8, alguno/6 y todos/6 sobre nodos primitivos, sin expandir nada.
test(reducir_o, [true(R-K == si(o(n, meta(ruta(paso, paso))-3))-0)]) :-
    reducir(o, rio(cero), n, [], [ruta(paso, paso)-3], R, 0, K).

test(reducir_y, [true(R == si(y(n, [meta(ruta(paso, paso))-1,
                                    meta(ruta(molino, molino))-2])))]) :-
    reducir(y, rio(cero), n, [], [ruta(paso, paso)-1, ruta(molino, molino)-2],
            R, 0, _).

% Un hijo que repite un ancestro no tiene solución: el nodo Y tampoco.
test(reducir_y_ancestro, [true(R == no)]) :-
    reducir(y, rio(cero), n, [ruta(molino, molino)],
            [ruta(paso, paso)-1, ruta(molino, molino)-2], R, 0, _).

test(alguno_vacio, [true(R-K == no-5)]) :-
    alguno([], rio(cero), [], R, 5, K).

test(alguno_salta, [true(R == si(meta(ruta(paso, paso))-2))]) :-
    alguno([ruta(a, a)-1, ruta(paso, paso)-2], rio(cero), [ruta(a, a)], R,
           0, _).

test(todos_vacio, [true(R == si([]))]) :-
    todos([], rio(cero), [], R, 0, _).

test(todos_falla_uno, [true(R == no)]) :-
    todos([ruta(paso, paso)-1, ruta(a, a)-2], rio(cero), [ruta(a, a)], R, 0,
          _).

:- end_tests(profundidad).
