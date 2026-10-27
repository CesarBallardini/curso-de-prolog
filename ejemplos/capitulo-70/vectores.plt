:- encoding(utf8).

:- begin_tests(vectores).

test(escalar_rec, [true(Ys == [2, 4, 6])]) :-
    escalar_rec([1, 2, 3], 2, Ys).

test(escalar_rec_vacio, [true(Ys == [])]) :-
    escalar_rec([], 5, Ys).

test(escalar_k, [nondet, true(Ys == [2, 4, 6])]) :-
    escalar_k(2, [1, 2, 3], Ys).

test(sumar_rec, [true(Zs == [4, 6])]) :-
    sumar_rec([1, 2], [3, 4], Zs).

test(sumar_rec_distinta_longitud, [fail]) :-
    sumar_rec([1, 2], [3], _).

test(escalar_acc, [true(Ys == [2, 4, 6])]) :-
    escalar_acc([1, 2, 3], 2, Ys).

test(escalar_acc4, [true(Ys == [9, 8, 2, 4])]) :-
    escalar_acc([1, 2], 2, [8, 9], Ys).

test(sumar_acc, [true(Zs == [4, 6])]) :-
    sumar_acc([1, 2], [3, 4], Zs).

test(sumar_acc4, [true(Zs == [1, 4, 6])]) :-
    sumar_acc([1, 2], [3, 4], [1], Zs).

% Las dos formas dan lo mismo con vectores de punto flotante.
test(rec_igual_acc, [true]) :-
    numlist(1, 50, Ns),
    maplist([N, X]>>(X is N / 7), Ns, Xs),
    escalar_rec(Xs, 0.25, A1),
    escalar_acc(Xs, 0.25, A2),
    A1 == A2,
    sumar_rec(Xs, A1, B1),
    sumar_acc(Xs, A1, B2),
    B1 == B2.

test(por, [true(Y == 6)]) :-
    por(2, 3, Y).

test(mas, [true(Z == 5)]) :-
    mas(2, 3, Z).

test(corregir_vectores, [true(P == [-2, 0, 0])]) :-
    corregir_vectores(1, ej([0, 0], -1), [0, 0, 0], P).

% Con cada ejemplo de cada conjunto, desde unos pesos fijos, corregir/4
% y corregir_vectores/4 dan los mismos valores.
test(corregir_igual, [true]) :-
    forall(( datos(_, Es),
             member(E, Es),
             member(P0, [[0, 0, 0], [0.13, -0.51, -0.35], [-3, 2, 2]]) ),
           ( corregir(0.25, E, P0, P1),
             corregir_vectores(0.25, E, P0, P2),
             maplist(=:=, P1, P2) )).

test(costos_vectores, [true(Cs == [rec-44, acc-70, maplist-66])]) :-
    costos_vectores(10, Cs).

% El acumulador cuesta más: tiene que invertir el resultado.
test(costos_vectores_orden, [true]) :-
    costos_vectores(1000, [rec-R, acc-A, maplist-_]),
    R < A.

test(parada, [true]) :-
    parada(en(1, [ej([1, 1], 1), ej([0, 0], -1)], [-3, 2, 2], 0)).

test(parada_no, [fail]) :-
    parada(en(1, [ej([1, 0], 1)], [-3, 2, 2], 0)).

test(extraer, [true(R == sal([1, 2], 7))]) :-
    extraer(en(1, [], [1, 2], 7), R).

test(transformar, [true(A == en(1, [ej([1, 1], 1), ej([0, 0], -1)],
                                 [-2, 0, 0], 1))]) :-
    transformar(en(1, [ej([0, 0], -1), ej([1, 1], 1)], [0, 0, 0], 0), A).

test(esquema, [true(R == sal([-3, 2, 2], 0))]) :-
    esquema(en(1, [ej([1, 1], 1)], [-3, 2, 2], 0), R).

% El esquema reproduce los pasos y los pesos de entrenar_uno/5.
test(entrenar_esquema_igual, [true]) :-
    forall(( member(N-T-P0, [y-1-[0, 0, 0], o-1-[0, 0, 0],
                             puntos-0.25-[0.13, -0.51, -0.35]]) ),
           ( pasos(N, T, P0, P1, K1),
             entrenar_esquema(N, T, P0, P2, K2),
             K1 == K2,
             maplist(=:=, P1, P2) )).

test(entrenar_esquema_puntos, [true(K == 801)]) :-
    entrenar_esquema(puntos, 0.25, [0.13, -0.51, -0.35], _, K).

:- end_tests(vectores).
