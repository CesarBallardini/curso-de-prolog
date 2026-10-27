:- encoding(utf8).

:- begin_tests(optimo).

test(alamos_islas, [true(C-K-Ps == 106-255103-[alamos, cantera, paso, granja,
                                               islas])]) :-
    optimo(rio(cero), ruta(alamos, islas), A, C, K),
    pueblos(A, Ps),
    costo(A, C).

test(bosque_fuente, [true(C-Ps == 49-[bosque, molino, fuente])]) :-
    optimo(rio(cero), ruta(bosque, fuente), A, C, _),
    pueblos(A, Ps).

test(sin_solucion, [fail]) :-
    optimo(otro, ruta(alamos, islas), _, _, _).

test(viaje, [true(Ps-C == [bosque, molino, fuente]-49)]) :-
    viaje(optimo, bosque, fuente, Ps, C, _).

test(mejor_arbol, [true(C-K == 49-64981)]) :-
    mejor_arbol(rio(cero), ruta(bosque, fuente), [], si(_, C), 0, K).

test(mejor_arbol_ancestro, [true(R-K == no-0)]) :-
    mejor_arbol(rio(cero), ruta(a, b), [ruta(a, b)], R, 0, K).

test(combinar_o, [true(R == si(o(n, b-2), 3))]) :-
    combinar(o, n, [no, si(a-1, 5), si(b-2, 3)], R).

test(combinar_o_ninguno, [true(R == no)]) :-
    combinar(o, n, [no, no], R).

test(combinar_y, [true(R == si(y(n, [a-1, b-2]), 8))]) :-
    combinar(y, n, [si(a-1, 5), si(b-2, 3)], R).

test(combinar_y_falta_uno, [true(R == no)]) :-
    combinar(y, n, [si(a-1, 5), no], R).

:- end_tests(optimo).
