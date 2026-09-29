:- encoding(utf8).

:- begin_tests(mapa).

test(pueblos, [true(N == 13)]) :-
    aggregate_all(count, pueblo(_, _, _, _), N).

test(caminos, [true(N == 22)]) :-
    aggregate_all(count, camino(_, _, _), N).

% Ningún camino es más corto que la distancia en línea recta: la
% estimación distancia no supera nunca el costo verdadero.
test(admisible, [true(Malos == [])]) :-
    findall(A-B,
            ( camino(A, B, L), distancia(A, B, D), D > L ),
            Malos).

test(cruces, [true(Hs == [cruce(alamos, molino, islas)-0,
                          cruce(alamos, paso, islas)-0,
                          cruce(alamos, barca, islas)-0])]) :-
    expansion(rio(cero), ruta(alamos, islas), o, Hs).

test(caminos_de_alamos, [true(Hs == [ruta(cantera, paso)-25,
                                     ruta(dique, paso)-33,
                                     ruta(bosque, paso)-40])]) :-
    expansion(rio(cero), ruta(alamos, paso), o, Hs).

test(cruce_y, [true(Hs == [ruta(a, p)-0, ruta(p, b)-0])]) :-
    expansion(rio(cero), cruce(a, p, b), y, Hs).

test(primitivo) :-
    primitivo(rio(cero), ruta(paso, paso)).

test(sin_expansion, [fail]) :-
    expansion(rio(cero), ruta(paso, paso), _, _).

test(estimacion, [true(H-H0 == 80-0)]) :-
    estimacion(rio(distancia), ruta(alamos, islas), H),
    estimacion(rio(cero), ruta(alamos, islas), H0).

test(estimacion_cruce, [true(H == 80)]) :-
    estimacion(rio(distancia), cruce(alamos, paso, islas), H).

test(pueblos_de_un_arbol, [true(Ps == [alamos, cantera, paso, huerta])]) :-
    pueblos(o(ruta(alamos, huerta),
              y(cruce(alamos, paso, huerta),
                [o(ruta(alamos, paso),
                   o(ruta(cantera, paso),
                     meta(ruta(paso, paso))-24)-25)-0,
                 o(ruta(paso, huerta),
                   meta(ruta(huerta, huerta))-31)-0])-0),
            Ps).

:- end_tests(mapa).
