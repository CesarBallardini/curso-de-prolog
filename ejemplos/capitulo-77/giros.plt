:- encoding(utf8).

:- begin_tests(giros).

test(giros, [true(Co-G == 234-4)]) :-
    camino_con_giros(taller, 1-4, 20-6, C, Co, _),
    giros_de(C, G).

test(giros_sin_visitados, [true(Co-K == 122-2312)]) :-
    camino_con_giros_sin_visitados(patio, 28-8, 32-8, _, Co, K).

test(giros_ida, [true(Co == 122)]) :-
    camino_con_giros_ida(patio, 28-8, 32-8, _, Co, _).

test(giros_de, [true(G == 2)]) :-
    giros_de([1-1, 2-1, 3-1, 3-2, 4-2], G).

test(giros_de_recto, [true(G == 0)]) :-
    giros_de([1-1, 1-2, 1-3], G).

test(costo_paso, [true(Cs == [10, 10, 11])]) :-
    giros:costo_paso(ninguna, este, A),
    giros:costo_paso(este, este, B),
    giros:costo_paso(este, sur, C),
    Cs = [A, B, C].

:- end_tests(giros).
