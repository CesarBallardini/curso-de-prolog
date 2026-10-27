:- encoding(utf8).

:- begin_tests(comparar).

test(mismas) :-
    forall(member(F, [cubo, bloques, escalon, poiuyt, escalera(3)]),
           forall(member(M, [sin_borde, borde]),
                  mismas(F, M, [alfabetico, vecindad, waltz, clpfd]))).

test(generar_coincide) :-
    mismas(cubo, sin_borde, [generar, waltz]).

test(posibles_iguales) :-
    forall(member(F, [cubo, bloques, escalon, escalera(3)]),
           forall(member(M, [sin_borde, borde]),
                  ( posibles_waltz(F, M, P),
                    posibles_clpfd(F, M, P) ))).

test(todas, [true(N == 4)]) :-
    todas(waltz, cubo, sin_borde, Ls),
    length(Ls, N).

test(etiquetar, [nondet]) :-
    etiquetar(clpfd, cubo, borde, _).

test(medir, [true(N == 1)]) :-
    medir(vecindad, cubo, borde, N, I),
    integer(I).

test(tabla_de_costos, [true(Vs == [alfabetico-1, vecindad-1, waltz-1,
                                   clpfd-1])]) :-
    tabla_de_costos(cubo, borde, Filas),
    findall(V-N, member(V-N-_, Filas), Vs).

test(posibles_de_linea, [true(P == (a-b)-[mas])]) :-
    filtrar(cubo, borde, D),
    posibles_de_linea(D, a-b, P).

:- end_tests(comparar).
