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

:- end_tests(optimo).
