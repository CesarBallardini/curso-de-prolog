:- encoding(utf8).

:- begin_tests(mejor).

test(distancia, [true(C-K-Ps == 106-6-[alamos, cantera, paso, granja,
                                       islas])]) :-
    mejor(rio(distancia), ruta(alamos, islas), A, C, K),
    pueblos(A, Ps),
    costo(A, C).

test(cero, [true(C-K == 106-76)]) :-
    mejor(rio(cero), ruta(alamos, islas), _, C, K).

test(otros_optimos, [true(Cs == [103, 89, 106, 70, 121, 91, 105, 49])]) :-
    findall(C,
            ( member(X-Y, [alamos-jardin, alamos-fuente, dique-islas,
                           dique-jardin, dique-fuente, bosque-islas,
                           bosque-jardin, bosque-fuente]),
              mejor(rio(distancia), ruta(X, Y), _, C, _) ),
            Cs).

% Las dos estimaciones son admisibles: dan el mismo costo en los 169
% pares de pueblos, y distancia expande muchos menos nodos.
test(todos_los_pares, [true(Malos-S1-S0 == []-566-3342)]) :-
    findall(X-Y, ( pueblo(X, _, _, _), pueblo(Y, _, _, _) ), Pares),
    findall(X-Y,
            ( member(X-Y, Pares),
              mejor(rio(distancia), ruta(X, Y), _, C1, _),
              mejor(rio(cero), ruta(X, Y), _, C0, _),
              C1 =\= C0 ),
            Malos),
    aggregate_all(sum(K), ( member(X-Y, Pares),
                            mejor(rio(distancia), ruta(X, Y), _, _, K) ), S1),
    aggregate_all(sum(K), ( member(X-Y, Pares),
                            mejor(rio(cero), ruta(X, Y), _, _, K) ), S0).

test(sin_solucion, [fail]) :-
    mejor(otro, ruta(alamos, islas), _, _, _).

test(viaje, [true(Ps-C-K == [alamos, cantera, paso, granja, islas]-106-6)]) :-
    viaje(mejor(distancia), alamos, islas, Ps, C, K).

test(mostrar_viaje, [true(Ls == ["ruta(bosque,fuente)  o",
                                   "  +0 cruce(bosque,molino,fuente)  y",
                                   "    +0 ruta(bosque,molino)  o",
                                   "      +27 ruta(molino,molino)",
                                   "    +0 ruta(molino,fuente)  o",
                                   "      +22 ruta(fuente,fuente)",
                                   ""])]) :-
    with_output_to(string(S),
                   mostrar_viaje(mejor(distancia), bosque, fuente)),
    split_string(S, "
", "", Ls).

% rehacer/4: el nodo O queda hecho cuando su hijo de menor F está resuelto.
test(rehacer_o_hecho, [true(T == hecho(n, 3, o(n, meta(y)-1)))]) :-
    rehacer(o, n, [punta(x, 4)-1, hecho(y, 2, meta(y))-1], T).

test(rehacer_o_abierto, [true(T == o(n, 2, [punta(x, 1)-1,
                                            hecho(y, 2, meta(y))-1]))]) :-
    rehacer(o, n, [punta(x, 1)-1, hecho(y, 2, meta(y))-1], T).

test(rehacer_o_imposible, [true(T == imposible(n))]) :-
    rehacer(o, n, [imposible(x)-1, imposible(y)-1], T).

test(rehacer_o_sin_hijos, [true(T == imposible(n))]) :-
    rehacer(o, n, [], T).

test(rehacer_y_hecho, [true(T == hecho(n, 4, y(n, [meta(x)-1, meta(y)-1])))]) :-
    rehacer(y, n, [hecho(x, 0, meta(x))-1, hecho(y, 2, meta(y))-1], T).

test(rehacer_y_abierto, [true(F == 4)]) :-
    rehacer(y, n, [hecho(x, 0, meta(x))-1, punta(y, 2)-1], y(n, F, _)).

test(rehacer_y_imposible, [true(T == imposible(n))]) :-
    rehacer(y, n, [imposible(x)-1, punta(y, 2)-1], T).

% expandir/4 sobre una punta: el nodo O de los tres cruces del río.
test(expandir_punta, [true(Hs == [punta(cruce(alamos, molino, islas), 112)-0,
                                  punta(cruce(alamos, paso, islas), 80)-0,
                                  punta(cruce(alamos, barca, islas), 112)-0])]) :-
    expandir(punta(ruta(alamos, islas), 80), rio(distancia), [],
             o(ruta(alamos, islas), 80, Hs)).

% Un pueblo sin caminos: nodo O sin hijos, imposible.
test(expandir_sin_hijos, [true(T == imposible(ruta(zz, islas)))]) :-
    expandir(punta(ruta(zz, islas), 80), rio(distancia), [], T).

test(ciclo, [true(F-K == 106-6)]) :-
    nuevo(rio(distancia), [], ruta(alamos, islas), T0),
    ciclo(rio(distancia), T0, 0, hecho(_, F, _), K).

test(buscar_imposible, [true(T == imposible(ruta(zz, islas)))]) :-
    buscar_mejor(rio(cero), ruta(zz, islas), T, _).

:- end_tests(mejor).
