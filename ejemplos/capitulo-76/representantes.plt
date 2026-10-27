:- encoding(utf8).

:- begin_tests(representantes).

test(particiones_de_8,
     [true(Ts == [[2, 2, 2, 2], [2, 2, 4], [2, 3, 3], [2, 6], [3, 5], [4, 4],
                  [8]])]) :-
    findall(T, particion(8, T), Ts).

test(particion_con_minima, [all(T == [[3, 3], [6]])]) :-
    particion(6, 3, T).

test(sin_particiones_de_1, [fail]) :-
    particion(1, _).

test(representante, [true(P == [2, 1, 4, 5, 3])]) :-
    representante([2, 3], P).

test(bloque, [true(I-H == [5, 6, 4]-7)]) :-
    bloque(3, I, 4, H).

test(representante_del_tipo, [nondet]) :-
    forall(particion(9, T),
           ( representante(T, P), tipo(P, T) )).

test(total_de_tipo, [true(T == 544)]) :-
    total_de_tipo([2, 2, 2, 2], T).

test(tipo_sin_filas_distintas, [fail]) :-
    total_de_tipo([2, 3, 3], _).

test(maximo_8, [true(T == 544)]) :-
    maximo_representantes(8, T, _).

test(maximo_14, [true(T == 4900)]) :-
    maximo_representantes(14, T, _).

test(igual_a_por_tipo, [nondet]) :-
    forall(between(3, 8, N),
           ( maximo_por_tipo(N, T, _), maximo_representantes(N, T, _) )).

:- end_tests(representantes).
