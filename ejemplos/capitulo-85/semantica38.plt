:- encoding(utf8).

:- begin_tests(semantica38).

test(clausulas, [true(Cs == [(llueve :- true), (calle_mojada :- llueve),
                             (calle_mojada :- riego)])]) :-
    clausulas(lluvia, Cs).

test(experto, [true(N == 12)]) :-
    clausulas(base(original), Cs),
    length(Cs, N).

test(semi_ingenua_de, [true(C == costo(5, 20))]) :-
    clausulas(caminos, Cs),
    semi_ingenua_de(Cs, [], _, C).

test(modelo_estandar_de, [true(M == [p, q])]) :-
    modelo_estandar_de([(p :- true), (q :- p, \+ r)], M).

test(estratos_de, [true(E == [0-[arco/2, camino/2, nodo/1],
                              1-[inalcanzable/2]])]) :-
    clausulas(grafo, Cs),
    estratos_de(Cs, E).

test(bien_fundado_de, [true(I == [gana(j2, a), gana(j2, b)])]) :-
    clausulas(juego, Cs),
    bien_fundado_de(Cs, _, I).

:- end_tests(semantica38).
