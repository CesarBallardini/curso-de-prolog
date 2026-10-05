:- encoding(utf8).

:- use_module(library(lists)).
:- use_module(minimos).

:- begin_tests(medicion).

test(predecir, [true(Ss == [0, 1])]) :-
    predecir(sumador, [0, 0, 1], [[m1, x1]-pegada(1)], Ss).

test(proxima, [true(Es-P == [0, 1, 1]-5)]) :-
    minimos(fuerte, sumador, [[0, 0, 1]-[0, 1]], 2, Ds),
    proxima(sumador, Ds, Es, P).

test(localizar_simple, [true(Ds == [[[s1, m2, x1]-pegada(1)]])]) :-
    localizar(sumador3, [[s1, m2, x1]-pegada(1)],
              [[1, 1, 0, 1, 0, 1]-[0, 1, 0, 1]], _, Ds).

% Una avería doble queda entre candidatos que ninguna entrada separa.
test(localizar_doble, [true(N-M == 4-3)]) :-
    Averia = [[m1, y1]-pegada(1), [m2, x1]-pegada(0)],
    localizar(sumador, Averia, [[0, 0, 1]-[0, 1]], Obs, Ds),
    length(Obs, N),
    length(Ds, M),
    memberchk(Averia, Ds).

% pegada(1) e invertida dan lo mismo con 0, 0, 1 y con 1, 1, 1.
test(peor_grupo_iguales, [true(P == 2)]) :-
    medicion:peor_grupo(sumador, [[[m1, x1]-pegada(1)], [[m1, x1]-invertida]],
                        [1, 1, 1], P).

test(peor_grupo_separa, [true(P == 1)]) :-
    medicion:peor_grupo(sumador, [[[m1, x1]-pegada(1)], [[m1, x1]-invertida]],
                        [1, 0, 0], P).

% Con un solo candidato, toda entrada empata, y gana la primera.
test(proxima_un_candidato, [true(Es-P == [0, 0, 0]-1)]) :-
    proxima(sumador, [[]], Es, P).

test(predecir_sano, [true(Ss == [1, 1])]) :-
    predecir(sumador, [1, 1, 1], [], Ss).

% Sin fallas, el ciclo no mide nada más.
test(localizar_sano, [true(O-Ds == [[0, 0, 1]-[1, 0]]-[[]])]) :-
    localizar(sumador, [], [[0, 0, 1]-[1, 0]], O, Ds).

:- end_tests(medicion).
