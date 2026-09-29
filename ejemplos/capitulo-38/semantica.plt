:- encoding(utf8).

:- begin_tests(semantica).

% clausulas/2 lee con clause/2: los hechos tienen el cuerpo true.
test(lectura, [true(Cs == [ (llueve :- true),
                            (calle_mojada :- llueve),
                            (calle_mojada :- riego) ])]) :-
    clausulas(lluvia, Cs).

test(programa_inexistente, [error(existence_error(programa, otro))]) :-
    clausulas(otro, _).

test(programa_libre, [error(instantiation_error)]) :-
    clausulas(_, _).

% Un programa generado se nombra con un término: cadena(N).
test(generado, [true(Cs =@= [ (arco(0, 1) :- true), (arco(1, 2) :- true),
                              (camino(X, Y) :- arco(X, Y)),
                              (camino(X1, Y1) :- camino(X1, Z1),
                                                 arco(Z1, Y1)) ])]) :-
    clausulas(cadena(2), Cs).

test(generado_inexistente,
     [error(existence_error(programa, cadena(1, 2)))]) :-
    clausulas(cadena(1, 2), _).

% Una lista de cláusulas no es un nombre de programa.
test(lista_no_es_nombre,
     [error(existence_error(programa, [(p :- true)]))]) :-
    modelo_minimo([(p :- true)], _).

% Tres interpretaciones del programa lluvia: dos modelos y una que no lo es.
test(modelos) :-
    assertion(es_modelo(lluvia, [calle_mojada, llueve])),
    assertion(es_modelo(lluvia, [llueve, riego, calle_mojada])),
    assertion(\+ es_modelo(lluvia, [llueve])),
    assertion(\+ es_modelo(lluvia, [riego, calle_mojada])).

test(modelo_de_lista) :-
    assertion(es_modelo_de([(p :- q)], [])),
    assertion(\+ es_modelo_de([(p :- true)], [])).

% T_P aplicado dos veces desde la interpretación vacía.
test(operador, [true(T1-T2 == [llueve]-[calle_mojada, llueve])]) :-
    consecuencias(lluvia, [], T1),
    consecuencias(lluvia, T1, T2).

test(minimo_lluvia, [true(M == [calle_mojada, llueve])]) :-
    modelo_minimo(lluvia, M).

% El modelo mínimo es un modelo, y está contenido en los otros dos.
test(minimo_es_el_menor) :-
    modelo_minimo(lluvia, M),
    assertion(es_modelo(lluvia, M)),
    assertion(ord_subset(M, [calle_mojada, llueve, riego])).

test(minimo_de_lista, [true(M == [p, q])]) :-
    modelo_minimo_de([(p :- true), (q :- p)], M).

% Con el ciclo a, b, c: cada uno de los tres llega a los cuatro nodos, y d
% a ninguno.
test(minimo_caminos, [true(Destinos == [a-[a, b, c, d], b-[a, b, c, d],
                                        c-[a, b, c, d]])]) :-
    modelo_minimo(caminos, M),
    findall(X-Ys,
            ( member(X, [a, b, c, d]),
              findall(Y, member(camino(X, Y), M), Ys),
              Ys \== [] ),
            Destinos).

% consecuencia/2 da los átomos del modelo mínimo, uno por respuesta.
test(consecuencias_desde_a, [all(Y == [a, b, c, d])]) :-
    consecuencia(caminos, camino(a, Y)).

test(sin_consecuencias_desde_d, [fail]) :-
    consecuencia(caminos, camino(d, _)).

test(cuantas_consecuencias, [true(N == 16)]) :-
    aggregate_all(count, consecuencia(caminos, _), N).

% Las dos evaluaciones dan el mismo modelo con los mismos pasos; la
% semi-ingenua deriva cada átomo una sola vez en este programa.
test(ingenua_y_semi, [true(C1-C2 == costo(5, 60)-costo(5, 20))]) :-
    ingenua(caminos, [], M1, C1),
    semi_ingenua(caminos, [], M2, C2),
    assertion(M1 == M2).

test(cadena, [true(C1-C2 == costo(22, 3520)-costo(22, 230))]) :-
    ingenua(cadena(20), [], M1, C1),
    semi_ingenua(cadena(20), [], M2, C2),
    assertion(M1 == M2),
    assertion(length(M1, 230)).

% Las versiones _de reciben la lista: cadena/2 la construye.
test(cadena_de_lista, [true(C == costo(22, 230))]) :-
    cadena(20, Cs),
    semi_ingenua_de(Cs, [], _, C).

% Una cabeza con variables que el cuerpo no liga es un error.
test(cabeza_sin_ligar, [error(instantiation_error)]) :-
    consecuencias_de([(p(_) :- true)], [], _).

test(negado_sin_ligar, [error(instantiation_error)]) :-
    consecuencias_de([(p :- \+ q(_))], [], _).

test(comparacion, [true(T == [grande(90)])]) :-
    consecuencias_de([(grande(X) :- peso(X), X > 50)],
                     [peso(30), peso(90)], T).

test(dependencias, [true(As == [camino/2-arco/2-pos, camino/2-camino/2-pos,
                                inalcanzable/2-camino/2-neg,
                                inalcanzable/2-nodo/1-pos])]) :-
    dependencias(grafo, As).

test(dependencias_de_lista, [true(As == [p/0-q/0-neg])]) :-
    dependencias_de([(p :- \+ q, 1 < 2)], As).

test(estratos_grafo, [true(E == [0-[arco/2, camino/2, nodo/1],
                                 1-[inalcanzable/2]])]) :-
    estratos(grafo, E).

% Un programa definido tiene un solo estrato.
test(estratos_definido, [true(E == [0-[arco/2, camino/2]])]) :-
    estratos(caminos, E).

test(estratos_de_cadena_de_negaciones,
     [true(E == [0-[a/0], 1-[b/0], 2-[c/0]])]) :-
    estratos_de([(b :- \+ a), (c :- \+ b)], E).

test(no_estratificado, [fail]) :-
    estratos(juego, _).

test(ciclos_juego, [true(P == [gana/2-gana/2])]) :-
    ciclos_negativos(juego, P).

test(ciclos_circular, [true(P == [p/0-q/0, q/0-p/0, r/0-r/0])]) :-
    ciclos_negativos(circular, P).

test(sin_ciclos, [true(P == [])]) :-
    ciclos_negativos(grafo, P).

test(ciclos_de_lista, [true(P == [r/0-r/0])]) :-
    ciclos_negativos_de([(r :- \+ r)], P).

test(estandar_grafo, [true(I == [d-a, d-b, d-c, d-d])]) :-
    modelo_estandar(grafo, M),
    findall(X-Y, member(inalcanzable(X, Y), M), I).

test(estandar_circular, [fail]) :-
    modelo_estandar(circular, _).

% En un programa definido, el modelo estándar es el mínimo.
test(estandar_definido) :-
    modelo_estandar(caminos, M1),
    modelo_minimo(caminos, M2),
    assertion(M1 == M2).

test(estandar_de_lista, [true(M == [b])]) :-
    modelo_estandar_de([(b :- \+ a)], M).

test(bien_fundado_juego,
     [true(G-I == [gana(j1, b), gana(j2, c)]-[gana(j2, a), gana(j2, b)])]) :-
    bien_fundado(juego, V, I),
    findall(gana(J, X), member(gana(J, X), V), G).

test(bien_fundado_circular, [true(V-I == [s]-[p, q, r])]) :-
    bien_fundado(circular, V, I).

test(bien_fundado_de_lista, [true(V-I == []-[p, q])]) :-
    bien_fundado_de([(p :- \+ q), (q :- \+ p)], V, I).

% En un programa estratificado, el modelo bien fundado es el estándar, sin
% indefinidos.
test(bien_fundado_estratificado, [true(I == [])]) :-
    bien_fundado(grafo, V, I),
    modelo_estandar(grafo, M),
    assertion(V == M).

test(valores, [true(Vs == [falso, verdadero, falso, indefinido, indefinido,
                           verdadero, falso])]) :-
    findall(V,
            ( member(A, [gana(j1, a), gana(j1, b), gana(j1, c),
                         gana(j2, a), gana(j2, b), gana(j2, c),
                         gana(j2, d)]),
              valor(juego, A, V) ),
            Vs).

test(valor_de_lista, [true(V == indefinido)]) :-
    valor_de([(r :- \+ r)], r, V).

test(valor_sin_ligar, [error(instantiation_error)]) :-
    valor(juego, gana(j1, _), _).

% cumple/3 da una respuesta por cada forma de hacer verdadero el cuerpo, con
% sus variables ligadas; la negación se evalúa contra el tercer argumento.
test(cumple_respuestas, [all(X == [2, 3])]) :-
    cumple((p(X), X > 1), [p(1), p(2), p(3)], []).

test(cumple_negacion, [all(Y == [e])]) :-
    cumple((camino(a, Y), \+ nodo(Y)),
           [camino(a, b), camino(a, e), nodo(b)], [nodo(b)]).

test(cumple_falla, [fail]) :-
    cumple((p, q), [p], []).

% derivar/4 conserva las repeticiones: dos formas de derivar q.
test(derivar_repetidas, [true(Cs == [q, q])]) :-
    derivar([(q :- p(_))], [p(1), p(2)], [p(1), p(2)], Cs).

% Las dos evaluaciones pueden empezar desde una interpretación dada.
test(ingenua_desde_hechos, [true(M-C == [p, q, r]-costo(3, 5))]) :-
    ingenua_de([(q :- p), (r :- q)], [p], M, C).

test(semi_desde_hechos, [true(M-C == [p, q, r]-costo(3, 2))]) :-
    semi_ingenua_de([(q :- p), (r :- q)], [p], M, C).

% Una derivación que toma de Nuevos los dos átomos del cuerpo aparece dos
% veces.
test(con_nuevos_dos_veces, [true(Cs == [c(a, c), c(a, c)])]) :-
    derivar_con_nuevos([(c(X, Y) :- c(X, Z), c(Z, Y))],
                       [c(a, b), c(b, c)], [c(a, b), c(b, c)], Cs).

test(con_nuevos_sin_nuevos, [true(Cs == [])]) :-
    derivar_con_nuevos([(c(X, Y) :- c(X, Z), c(Z, Y))],
                       [c(a, b), c(b, c)], [], Cs).

% reducido/3: con J vacío, todas las negaciones se cumplen; con p en J, la
% de p deja de cumplirse.
test(reducido_vacio, [true(M == [p, q])]) :-
    reducido([(p :- \+ q), (q :- \+ p)], [], M).

test(reducido_con_p, [true(M == [p])]) :-
    reducido([(p :- \+ q), (q :- \+ p)], [p], M).

% alcanza/3 sigue las aristas en su sentido, y la sucesión vacía cuenta.
test(alcanza) :-
    assertion(alcanza([a-b-pos, b-c-neg], a, c)),
    assertion(\+ alcanza([a-b-pos, b-c-neg], c, a)),
    assertion(alcanza([], a, a)).

test(dependencia_negada, [nondet, true(Q-S == p/1-neg)]) :-
    dependencia(\+ p(x), Q, S).

test(dependencia_comparacion, [fail]) :-
    dependencia(1 < 2, _, _).

% El programa lluvia, ejecutado por Prolog.
test(calle_mojada, [nondet]) :-
    calle_mojada.

test(s_sin_t) :-
    s.

:- end_tests(semantica).
