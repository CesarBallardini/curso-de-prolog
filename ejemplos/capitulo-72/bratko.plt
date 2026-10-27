:- encoding(utf8).

:- begin_tests(bratko).

% Los dos árboles solución de la figura 13.4 de Bratko: 9 por b y 8 por c.
test(figura_profundidad, [true(C == 9)]) :-
    resolver(bratko(cero), a, A, _),
    costo(A, C).

test(figura_mejor, [true(A-C == o(a, y(c, [o(f, meta(h)-2)-2,
                                           meta(g)-1])-3)-8)]) :-
    mejor(bratko(cero), a, A, C, _).

% Las hojas son los problemas triviales: llegar al cruce y llegar a islas.
test(ruta, [true(C-K-Hs == 106-6-[paso-paso, islas-islas])]) :-
    mejor(bratko(distancia), alamos-islas, A, C, K),
    hojas(A, Hs).

% La ruta con puntos clave cuesta lo mismo que la del problema rio(cero).
test(igual_que_rio, [true(C1-K1 == C2-K2)]) :-
    mejor(bratko(cero), alamos-islas, _, C1, K1),
    mejor(rio(cero), ruta(alamos, islas), _, C2, K2).

test(clave, [all(Y == [molino, paso, barca])]) :-
    clave(alamos-islas, Y).

test(sin_clave, [fail]) :-
    clave(alamos-cantera, _).

test(expansion_clave, [true(T-Hs == o-[(alamos-islas via molino)-0,
                                       (alamos-islas via paso)-0,
                                       (alamos-islas via barca)-0])]) :-
    expansion(bratko(cero), alamos-islas, T, Hs).

test(expansion_via, [true(T-Hs == y-[(alamos-paso)-0, (paso-islas)-0])]) :-
    expansion(bratko(cero), alamos-islas via paso, T, Hs).

test(expansion_trivial, [fail]) :-
    expansion(bratko(cero), paso-paso, _, _).

test(primitivo) :-
    primitivo(bratko(cero), d).

test(estimacion, [true(H1-H2-H3 == 80-80-0)]) :-
    estimacion(bratko(distancia), alamos-islas, H1),
    estimacion(bratko(distancia), alamos-islas via paso, H2),
    estimacion(bratko(distancia), a, H3).

test(distancia_bratko, [true(H == 0)]) :-
    distancia_bratko(f, H).

test(tipo_bratko, [all(T == [o, y])]) :-
    tipo_bratko(_, T).

test(arco_bratko, [true(A == h-6)]) :-
    arco_bratko(h/6, A).

:- end_tests(bratko).
