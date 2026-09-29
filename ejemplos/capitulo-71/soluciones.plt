:- encoding(utf8).

:- begin_tests(soluciones).

test(profundizando, [true(L-C-Ps == 4-131-[alamos, bosque, molino, fuente,
                                          islas])]) :-
    profundizando(rio(cero), ruta(alamos, islas), A, L),
    costo(A, C),
    pueblos(A, Ps).

test(limitado_falla, [fail]) :-
    resolver_limitado(rio(cero), ruta(alamos, islas), 3, _).

test(contar, [true(N == 177)]) :-
    contar_arboles(rio(cero), ruta(alamos, paso), N).

test(contar_primitivo, [true(N == 1)]) :-
    contar_arboles(rio(cero), ruta(paso, paso), N).

test(peaje, [true(R == [0-70-[dique, barca, jardin],
                        15-85-[dique, barca, jardin],
                        40-107-[dique, ermita, paso, huerta, jardin]])]) :-
    findall(T-C-Ps,
            ( member(T, [0, 15, 40]),
              mejor(peaje(distancia, T), ruta(dique, jardin), A, C, _),
              pueblos(A, Ps) ),
            R).

test(doble, [true(R == 15-65-566-434)]) :-
    comparar_doble(D, E, K1, K2),
    R = D-E-K1-K2.

test(costo_compartido, [true(C == 1048575)]) :-
    compartido(hanoi, torre(20, a, c), A, _),
    costo_compartido(A, C).

test(costo_compartido_mapa, [true(C == 106)]) :-
    mejor(rio(distancia), ruta(alamos, islas), A, _, _),
    costo_compartido(A, C).

test(esquina, [true(Rs == [2-21, 3-21, 4-21, 5-ninguna, 6-21, 7-21, 8-21,
                           9-21])]) :-
    respuestas_a_la_esquina(Rs).

test(memoria_en_el_mapa, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(compartido(rio(cero), ruta(alamos, islas),
                                         _, _),
                              1000000, R).

test(integral, [true(C-F == 4-(3*(x^3/3)+2*(-cos(x)+sin(x))))]) :-
    mejor(integral, int(3*x^2+2*(sin(x)+cos(x))), A, C, _),
    primitiva(A, F).

test(integral_exp, [true(C-F == 2-2*(x^2/2+exp(x)))]) :-
    mejor(integral, int(2*(x+exp(x))), A, C, _),
    primitiva(A, F).

test(sin_primitiva, [fail]) :-
    mejor(integral, int(x*sin(x)), _, _, _).

test(medir_esquina, [true(Rs == [2-[170, 102, 73], 3-[129, 91, 73],
                                  4-[28, 24, 66], 5-[431, 170, 362],
                                  6-[73, 61, 85], 7-[26, 23, 68],
                                  8-[92, 69, 85], 9-[84, 67, 80]])]) :-
    medir_esquina(Rs).

test(mostrar_estrategia, [true(N == 10)]) :-
    with_output_to(string(S),
                   mostrar_estrategia(mejor, [x,o,v, v,x,v, v,v,o])),
    split_string(S, "
", "", Ls),
    length(Ls, N0),
    N is N0 - 1.

:- end_tests(soluciones).
