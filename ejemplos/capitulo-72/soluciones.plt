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

test(limitado_o, [true(A == o(n, meta(ruta(paso, paso))-3)), nondet]) :-
    limitado(o, rio(cero), n, [ruta(paso, paso)-3], 0, A).

test(arco_limitado, [true(A == meta(ruta(paso, paso))-4), nondet]) :-
    arco_limitado(rio(cero), 0, ruta(paso, paso)-4, A).

test(arco_limitado_sin_limite, [fail]) :-
    arco_limitado(rio(cero), 0, ruta(alamos, cantera)-4, _).

test(contar_ancestro, [true(N == 0)]) :-
    contar(rio(cero), ruta(a, b), [ruta(a, b)], N).

test(contar_hijo, [true(N == 1)]) :-
    contar_hijo(rio(cero), [], ruta(paso, paso)-7, N).

test(cobrar, [true(Hs == [cruce(a, barca, b)-15, cruce(a, paso, b)-0])]) :-
    maplist(cobrar(15), [cruce(a, barca, b)-0, cruce(a, paso, b)-0], Hs).

test(costo_m_memoria, [true(C-Ns == 2-[x, y])]) :-
    empty_assoc(M0),
    costo_m(y(x, [meta(y)-1, meta(y)-1]), C, M0, M),
    assoc_to_keys(M, Ns).

test(costo_nodo_o, [true(C == 5)]) :-
    empty_assoc(M0),
    costo_nodo(o(x, meta(y)-5), C, M0, _).

test(costo_arco, [true(S == 10)]) :-
    empty_assoc(M0),
    costo_arco(meta(y)-3, 7-M0, S-_).

test(posicion_esquina, [true(P == pos([x, v, o, v, v, v, v, v, v], x))]) :-
    posicion_esquina(3, P).

test(casilla_esquina, [true(Ms == [x, o, v])]) :-
    length(Ms, 3),
    foldl(casilla_esquina(2), Ms, 1, _).

test(inmediata, [true(Fs == [3*x, x^2/2, x^4/4, -cos(x), sin(x), exp(x)])]) :-
    maplist(inmediata, [3, x, x^3, sin(x), cos(x), exp(x)], Fs).

test(inmediata_inversa, [fail]) :-
    inmediata(x^(-1), _).

test(transformacion, [all(T == [suma(2*(x+1), x)])]) :-
    transformacion(2*(x+1)+x, T).

test(transformacion_producto, [all(T == [factor(2, x+1),
                                         distribuir(2*x+2*1)])]) :-
    transformacion(2*(x+1), T).

:- end_tests(soluciones).
