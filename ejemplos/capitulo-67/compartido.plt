:- encoding(utf8).

:- begin_tests(compartido).

test(tamanos, [true(F == [orden-331-26, frecuente-357-48,
                          informacion-419-46])]) :-
    tamanos(F).

% El subárbol de b aparece dos veces y se guarda una.
test(reticulado, [true(R-N == 5-[n(1)-hoja(x), n(2)-hoja(y),
                                 n(3)-pregunta(b, 1, 2),
                                 n(4)-pregunta(c, 3, 2),
                                 n(5)-pregunta(a, 3, 4)])]) :-
    reticulado(pregunta(a, pregunta(b, hoja(x), hoja(y)),
                        pregunta(c, pregunta(b, hoja(x), hoja(y)),
                                 hoja(y))),
               R, N).

% El reticulado responde lo mismo que el árbol en los prototipos.
test(mismas_respuestas, [true(D == [])]) :-
    arbol(frecuente, A),
    reticulado(A, R, Ns),
    findall(H2-H3,
            ( prototipo(_, Os),
              consultar_reticulado(Ns, R, lista(Os), H2),
              consultar(A, lista(Os), H3, _),
              H2 \== H3 ),
            D).

test(consultar_reticulado, [true(H == cebra)]) :-
    arbol(orden, A),
    reticulado(A, R, Ns),
    consultar_reticulado(Ns, R, lista([da_leche, tiene_cascos,
                                       rayas_negras]), H).

test(compartir, [true(Id-N == 1-[n(1)-hoja(x)])]) :-
    empty_assoc(T),
    compartir(hoja(x), T-[], _-N, Id).

test(numerar_existente, [true(Id == 1)]) :-
    list_to_assoc([hoja(x)-1], T),
    numerar(hoja(x), T-[n(1)-hoja(x)], _-Ns, Id),
    Ns == [n(1)-hoja(x)].

test(nodos_arbol, [true(N == 3)]) :-
    nodos_arbol(pregunta(a, hoja(x), hoja(y)), N).

:- end_tests(compartido).
