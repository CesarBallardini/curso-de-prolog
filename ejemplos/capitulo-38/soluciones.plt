:- encoding(utf8).

:- begin_tests(soluciones).

test(modelos_lluvia, [true(Ms == [[calle_mojada, llueve, riego],
                                  [calle_mojada, llueve]])]) :-
    modelos(lluvia, [calle_mojada, llueve, riego], Ms).

% La intersección de los modelos es el modelo mínimo.
test(interseccion) :-
    modelos(lluvia, [calle_mojada, llueve, riego], [M1, M2]),
    ord_intersection(M1, M2, I),
    modelo_minimo(lluvia, M),
    assertion(I == M).

test(subconjuntos, [true(Ss == [[a, b], [a], [b], []])]) :-
    findall(S, subconjunto([a, b], S), Ss).

test(base_caminos, [true(N-NM == 32-16)]) :-
    base_herbrand(caminos, B),
    length(B, N),
    modelo_minimo(caminos, M),
    length(M, NM),
    assertion(ord_subset(M, B)).

test(base_lluvia, [true(B == [calle_mojada, llueve, riego])]) :-
    base_herbrand(lluvia, B).

test(circular_modelo) :-
    modelo_minimo(circular, M),
    assertion(M == [p, q, r, s]),
    assertion(es_modelo(circular, M)).

test(circular_minimales, [true(Ms == [[p, r, s], [p, r, t], [q, r, s],
                                      [q, r, t]])]) :-
    modelos(circular, [p, q, r, s, t], Todos),
    minimales(Todos, Ms).

test(estratos_a, [true(E == [0-[d/0], 1-[b/0, c/0], 2-[a/0]])]) :-
    estratos_de([(a :- \+ b), (b :- c), (c :- \+ d)], E).

test(ciclos_b, [true(P == [a/0-c/0, c/0-a/0])]) :-
    ciclos_negativos_de([(a :- b, \+ c), (c :- \+ a)], P).

test(ciclos_c, [true(P == [a/0-b/0])]) :-
    ciclos_negativos_de([(a :- \+ b), (b :- a)], P).

test(paridad_no_estratificada, [fail]) :-
    estratos(paridad, _).

test(paridad, [true(Ps-I == [0, 2, 4, 6]-[])]) :-
    bien_fundado(paridad, V, I),
    findall(N, member(par(N), V), Ps).

test(alternancia_j2, [true(Gs == [[]-[a, b, c], [c]-[a, b, c]])]) :-
    alternancia(juego(j2), Pasos),
    findall(GV-GP,
            ( member(V-P, Pasos),
              findall(X, member(gana(j2, X), V), GV),
              findall(X, member(gana(j2, X), P), GP) ),
            Gs).

test(estables_pq, [true(Ms == [[p], [q]])]) :-
    estables_de([(p :- \+ q), (q :- \+ p)], Ms).

test(estables_circular, [true(Ms == [])]) :-
    estables(circular, Ms).

test(estables_j2, [true(Gs == [[a, c], [b, c]])]) :-
    estables(juego(j2), Ms),
    findall(G,
            ( member(M, Ms),
              findall(X, member(gana(j2, X), M), G) ),
            Gs).

% Un programa estratificado tiene un solo modelo estable: el estándar.
test(estable_estratificado, [true(Ms == [[b, c]])]) :-
    Cs = [(a :- \+ b), (b :- c), (c :- \+ d)],
    estables_de(Cs, Ms),
    modelo_estandar_de(Cs, M),
    assertion(Ms == [M]).

test(alcanza, [true(C == costo(42, 80))]) :-
    semi_ingenua(alcanzables(40), [], M, C),
    findall(Y, member(alcanza(Y), M), Ys),
    assertion(length(Ys, 40)).

test(estricta_doble, [true(C1-C2-C3 == costo(8, 1600)-costo(8, 1370)-
                                     costo(8, 4055))]) :-
    semi_ingenua(cadena_doble(20), [], M1, C1),
    semi_ingenua_estricta(cadena_doble(20), [], M2, C2),
    ingenua(cadena_doble(20), [], M3, C3),
    assertion(M1 == M2),
    assertion(M2 == M3).

% Con un solo literal recursivo, las dos semi-ingenuas cuentan lo mismo.
test(estricta_simple, [true(C1 == C2)]) :-
    cadena(20, Cs),
    semi_ingenua_de(Cs, [], _, C1),
    semi_ingenua_estricta_de(Cs, [], _, C2).

% Los programas de las soluciones se nombran con generado/2.
test(juego_j2, [true(Js == [j2])]) :-
    clausulas(juego(j2), Cs),
    findall(J, member((mueve(J, _, _) :- true), Cs), Js0),
    sort(Js0, Js).

test(base_de_lista, [true(B == [p(a), p(b)])]) :-
    base_herbrand_de([(p(a) :- p(b))], B).

test(modelos_de_lista, [true(Ms == [[p]])]) :-
    modelos_de([(p :- true)], [p], Ms).

% p es verdadero desde el segundo paso, y ahí termina la alternancia.
test(alternancia_de_lista, [true(Ps == [[]-[p], [p]-[p]])]) :-
    alternancia_de([(p :- \+ q)], Ps).

% Los auxiliares de las soluciones 2, 3, 11 y 13.
test(atomos_de_clausula, [all(A == [p(a), q(b), r])]) :-
    atomo_de((p(a) :- q(b), \+ r, 1 < 2), A).

test(constantes_de_clausula, [all(C == [a, b])]) :-
    constante((p(a, _) :- q(b)), C).

test(minimales_sin_contenidos, [true(M == [[a], [c]])]) :-
    minimales([[a], [a, b], [c]], M).

test(del_juego_j1, [true(N-Ms == 4-[a-b, b-a, b-c])]) :-
    del_juego(j1, Cs),
    length(Cs, N),
    findall(X-Y, member((mueve(_, X, Y) :- true), Cs), Ms).

test(es_arco) :-
    assertion(es_arco((arco(0, 1) :- true))),
    assertion(\+ es_arco((camino(0, 1) :- true))).

:- end_tests(soluciones).
