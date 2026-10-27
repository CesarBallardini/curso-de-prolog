:- encoding(utf8).

:- begin_tests(tablero).

test(ocho_simetrias, [true(N == 8)]) :-
    aggregate_all(count, simetria(_, _), N).

test(inversas, [nondet]) :-
    forall(( simetria(S, I), member(P, [1-1, 2-3, 1-3]) ),
           ( dimensiones(S, 2, 3, F1, C1),
             simetria_de(S, 2, 3, P, Q),
             simetria_de(I, F1, C1, Q, R),
             R == P )).

test(dimensiones, [true(F-C == 3-2)]) :-
    dimensiones(giro90, 2, 3, F, C).

test(giro90, [true(P == 1-2)]) :-
    simetria_de(giro90, 2, 3, 1-1, P).

test(antitraspuesta, [true(P == 3-2)]) :-
    simetria_de(antitraspuesta, 2, 3, 1-1, P).

test(marca_imagen, [true(M == numeral(3-1))]) :-
    marca_imagen(espejo_filas, 3, 3, numeral(1-1), M).

test(problema_sim, [true(F-C-Ms == 3-3-[circulo(1-1), circulo(3-1),
                                         numeral(2-3)])]) :-
    problema(sim(giro270, chico), F, C, Ms).

test(problema_forma, [true(F == 3)]) :-
    problema(forma(t(3, 4, [])), F, _, _).

test(imagen, [true(I == t(3, 3, [circulo(3-1), circulo(3-3),
                                 numeral(1-2)]))]) :-
    imagen(espejo_filas, chico, I).

test(forma_comun, [nondet]) :-
    forma(csenki1, F),
    forall(simetria(S, _), forma(sim(S, csenki1), F)).

test(forma_con_simetria, [true(I == F)]) :-
    forma(chico, S, F),
    imagen(S, chico, I).

test(lazo_imagen, [true(F == [1-1, 1-2, 2-2, 2-1])]) :-
    lazo_imagen(giro90, 2, 2, [1-1, 1-2, 2-2, 2-1], F).

test(lazos_de_forma, [true(N == 1)]) :-
    forma(chico, F),
    lazos_de_forma(F, Ls),
    length(Ls, N).

test(resolver_igual_a_buscar, [nondet]) :-
    forall(simetria(S, _),
           ( resolver(sim(S, csenki1), A),
             distintos(sim(S, csenki1), B),
             A == B )).

test(cruz_simetrica, [true(N == 5)]) :-
    resolver(cruz, Ls),
    length(Ls, N).

:- end_tests(tablero).
