:- encoding(utf8).

:- begin_tests(enigma).

test(desarreglos_de_4, [true(N == 9)]) :-
    desarreglos(4, Ps),
    length(Ps, N).

test(desarreglo_sin_puntos_fijos, [nondet]) :-
    forall(desarreglo(5, P),
           forall(nth1(I, P, X), X =\= I)).

test(desarreglos_de_8, [true(N == 14833)]) :-
    aggregate_all(count, desarreglo(8, _), N).

test(fila_libre, [true(L == 3)]) :-
    fila_libre(3, F),
    length(F, L),
    term_variables(F, Vs),
    length(Vs, 3).

test(fila_de, [true(F == [c, d])]) :-
    fila_de([[a, b], [c, d]], 2, F).

test(patron_de_un_3_ciclo, [true(K == 2)]) :-
    matriz_patron([2, 3, 1], M),
    M = [[A, B, A2]|_],
    A == A2,
    A \== B,
    term_variables(M, Vs),
    length(Vs, K).

test(columna_igual_a_fila) :-
    P = [2, 1, 4, 3],
    matriz_patron(P, M),
    transpose(M, Columnas),
    forall(nth1(J, P, I),
           ( nth1(J, Columnas, Col), nth1(I, M, Fila), Col == Fila )).

test(filas_distintas_variables) :-
    filas_distintas([[A, B], [B, A]]).

test(filas_iguales, [fail]) :-
    filas_distintas([[A, B], [c, d], [A, B]]).

test(frecuencia, [true(N-V == 2-X)]) :-
    frecuencia([X, Y, X], X, N-V),
    Y \== X.

test(evaluar, [true(M-T == [[2, 2, 1], [2, 1, 2]]-10)]) :-
    M = [[A, A, B], [A, B, A]],
    evaluar(M, T).

test(tablero_3, [nondet, true(M-T == [[2, 1, 2], [2, 2, 1], [1, 2, 2]]-15)]) :-
    tablero(3, [2, 3, 1], M, T).

test(tablero_4_primero, [true(P-T == [2, 1, 4, 3]-40)]) :-
    once(tablero(4, P, _, T)).

test(maximo_6, [true(T-E == 180-265)]) :-
    maximo(6, T, E).

test(maximo_2_falla, [fail]) :-
    maximo(2, _, _).

:- end_tests(enigma).
