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

:- end_tests(mejor).
