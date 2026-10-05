:- encoding(utf8).

:- begin_tests(ciclos).

test(y_separa, [true(R == separa([-6, 4, 2], [2, 3, 3, 2, 1, 0]))]) :-
    datos(y, Es),
    entrenar_o_ciclo(1, Es, [0, 0, 0], R).

% La tercera época vuelve a los pesos del final de la segunda.
test(o_exclusivo_ciclo, [true(R == ciclo(1, [3, 3, 4]))]) :-
    datos(o_exclusivo, Es),
    entrenar_o_ciclo(1, Es, [0, 0, 0], R).

test(o_exclusivo_pesos_repetidos, [true(P2 == P3)]) :-
    datos(o_exclusivo, Es),
    epoca(1, Es, [0, 0, 0], P1, _),
    epoca(1, Es, P1, P2, _),
    epoca(1, Es, P2, P3, E3),
    E3 =:= 4.

test(puntos_separa, [true(length(C, 102))]) :-
    datos(puntos, Es),
    entrenar_o_ciclo(0.25, Es, [0.13, -0.51, -0.35], separa(_, C)).

test(dieciseis_tablas, [true(N == 16)]) :-
    aggregate_all(count, tabla(_), N).

test(ejemplos_de, [true(Es == Ey)]) :-
    ejemplos_de([-1, -1, -1, 1], Es),
    datos(y, Ey).

test(no_separables, [true(Ts == [[-1, 1, 1, -1], [1, -1, -1, 1]])]) :-
    no_separables(Ts).


test(probar_o_exclusivo, [true(R == ciclo(1, [3, 3, 4]))]) :-
    probar(o_exclusivo, R).

test(pesos_nulos, [true(P == [0, 0, 0])]) :-
    pesos_nulos([ej([5, 7], 1)], P).

test(clase, all(C == [-1, 1])) :-
    ciclos:clase(C).

test(ejemplo_de, [true(E == ej([0, 1], -1))]) :-
    ciclos:ejemplo_de([0, 1], -1, E).

test(paso_con_memoria_nuevo,
     [true(S-R-C == ([0, 2, 2]-[[0, 0, 0]])-(2-[0, 2, 2])-1)]) :-
    datos(y, Es),
    paso_con_memoria(1, Es, [0, 0, 0]-[], S, R, C).

% Pesos que separan: la época los repite y el cambio es 0.
test(paso_con_memoria_repetido, [true(C == 0)]) :-
    datos(y, Es),
    paso_con_memoria(1, Es, [-3, 2, 2]-[], _, _, C).

test(paso_con_memoria_visto, [true(C == 0)]) :-
    datos(y, Es),
    paso_con_memoria(1, Es, [0, 0, 0]-[[0, 2, 2]], _, _, C).

:- end_tests(ciclos).
