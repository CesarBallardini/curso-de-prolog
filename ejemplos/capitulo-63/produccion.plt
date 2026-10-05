:- encoding(utf8).

:- begin_tests(produccion).

test(bien_formado, [nondet]) :-
    programa(familia, Reglas),
    maplist(bien_formado, Reglas).

% El punto fijo del capítulo 20: de 7 hechos a 34.
test(familia, [N, R] == [34, nada_aplicable]) :-
    familia(H),
    encadenar(familia, orden, H, M, R),
    length(M, N).

% hermanos se dispara dos veces por par, una por cada progenitor, y la
% segunda no cambia la memoria.
test(ciclos, C == 29) :-
    familia(H),
    cantidad_de_ciclos(familia, orden, H, C).

test(hermanos, all(A-B == [eva-luis, luis-eva, pedro-ana, ana-pedro])) :-
    familia(H),
    encadenar(familia, orden, H, M, _),
    member(hermanos(A, B), M).

% Con el intérprete del capítulo 60, la primera regla repite su hecho.
test(capitulo_60, [N, D, R] == [107, 8, limite(100)]) :-
    familia(H),
    vigilar(familia, primera, 100, H, M, R),
    length(M, N),
    sort(M, S),
    length(S, D).

test(conjunto_conflicto, Nombres == [progenitor_p, abuelo]) :-
    programa(familia, Reglas),
    memoria_con([padre(juan, ana), progenitor(ana, sofia)], M),
    conjunto_conflicto(Reglas, M, Is),
    findall(N, member(instanciacion(N, _, _, _), Is), Nombres0),
    exclude(==(antepasado_1), Nombres0, Nombres).

test(refraccion, Nuevas == [instanciacion(b, [2], 1, [])]) :-
    refractar([instanciacion(a, [1], 1, []), instanciacion(b, [2], 1, [])],
              [a-[1]], Nuevas).

test(traza, S == "1: progenitor_p de 2, con [1-padre(juan,ana)]\n\c
                  2: progenitor_m de 2, con [2-madre(ana,sofia)]\n\c
                  3: abuelo de 3, con [1-padre(juan,ana),\c
                  4-progenitor(ana,sofia)]\n\c
                  4: antepasado_1 de 2, con [4-progenitor(ana,sofia)]\n\c
                  5: antepasado_1 de 2, con [3-progenitor(juan,ana)]\n\c
                  6: antepasado_2 de 1, con [3-progenitor(juan,ana),\c
                  6-antepasado(ana,sofia)]\n") :-
    with_output_to(string(S),
                   rastrear(familia, orden,
                            [padre(juan, ana), madre(ana, sofia)], _, _)).

test(quitar_ausente, [fail]) :-
    memoria_con([a], M),
    aplicar_acciones([quitar(b)], M, _, _).

test(parar, [F, H] == [parar(listo), [b, a]]) :-
    memoria_con([a], M0),
    aplicar_acciones([agregar(b), parar(listo), agregar(c)], M0, M, F),
    hechos(M, H).

% cumple_condicion/4: un patrón agrega el sello del hecho; una prueba y
% una negación no agregan ninguno.
test(cumple_patron, all(S == [[1]])) :-
    memoria_con([padre(juan, ana), padre(ana, luis)], M),
    cumple_condicion(padre(juan, _), M, S, []).

test(cumple_prueba, all(S == [[]])) :-
    memoria_con([a], M),
    cumple_condicion({1 < 2}, M, S, []).

test(cumple_negacion, all(S == [[]])) :-
    memoria_con([padre(juan, ana)], M),
    cumple_condicion(no(padre(luis, _)), M, S, []).

test(cumple_negacion_falla, [fail]) :-
    memoria_con([padre(juan, ana)], M),
    cumple_condicion(no(padre(juan, _)), M, _, []).

% reconocer_actuar/9 cuenta los ciclos desde N0 y termina cuando no hay
% instanciaciones nuevas, o con el resultado de parar/1.
test(reconocer_actuar, [true(N-R-H == 2-nada_aplicable-[ prog(juan, ana),
                                                         prog(ana, luis),
                                                         padre(ana, luis),
                                                         padre(juan, ana)
                                                       ])]) :-
    memoria_con([padre(juan, ana), padre(ana, luis)], M),
    reconocer_actuar([(r1 :: [padre(A, B)] ---> [agregar(prog(A, B))])],
                     orden, sin_traza, 0, N, [], M, M1, R),
    hechos(M1, H).

test(reconocer_actuar_parar, [true(N-R == 4-listo)]) :-
    memoria_con([padre(juan, ana), padre(ana, luis)], M),
    reconocer_actuar([(r1 :: [padre(_, _)] ---> [parar(listo)])],
                     orden, sin_traza, 3, N, [], M, _, R).

:- end_tests(produccion).
