:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(soluciones).

test(ejercicio_2, [true(F-D == [[[g1]], [[g2]], [[g4]]]-[[[g1]], [[g2]], [[g4]]])]) :-
    sospechosas(fuerte, xor_nand, [[1, 0]-[0]], 2, F),
    sospechosas(debil, xor_nand, [[1, 0]-[0]], 2, D).

test(ejercicio_2_dos, [true(Ds == [[[g1]-invertida], [[g1]-pegada(0)],
                                   [[g2]-pegada(1)], [[g4]-pegada(0)]])]) :-
    mas_simples(fuerte, xor_nand, [[1, 0]-[0], [0, 0]-[0]], Ds).

test(ejercicio_3, [nondet, true(D == [[m2, x1]-pegada(0), [o1]-pegada(0),
                                      [o1]-pegada(1)])]) :-
    diagnostico_mal(sumador, [[0, 0, 1]-[0, 1], [1, 0, 0]-[1, 0]], D),
    repetida(D).

test(ejercicio_4, [true(N-M == 8-4)]) :-
    aggregate_all(count, diagnostico(flach, sumador, [[0, 0, 1]-[0, 1]], _),
                  N),
    por_filtro(flach, sumador, [[0, 0, 1]-[0, 1]], Ds),
    length(Ds, M).

test(ejercicio_4_dos, [fail]) :-
    mas_simples(flach, sumador, [[0, 0, 1]-[0, 1], [1, 0, 0]-[1, 0]], _).

test(ejercicio_6, [true(D == [A])]) :-
    A = [[m1, y1]-pegada(1), [m2, x1]-pegada(0)],
    predecir(sumador_sondas, [0, 0, 1], A, Ss),
    localizar(sumador_sondas, A, [[0, 0, 1]-Ss], _, D).

test(ejercicio_7, [nondet, true(R == [[m1, x1], [m1, y1], [m2, x1], [m2, y1],
                                      [o1]])]) :-
    explicar(fuerte, sumador, [[1, 0, 1]-[0, 1]], S),
    sanas(S, R).

test(ejercicio_8, [true(Ss == [[arranque-malo, bateria-bien],
                                [combustible-vacio, bateria-bien]])]) :-
    findall(S, ( abducir((motor(no_arranca), luces(encendidas)), S),
                 cerrar(S) ),
            Ss).

test(ejercicio_9, [true(D == [[s2, m2, y1]-pegada(0)])]) :-
    mas_probables(sumador3, [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 0]], 2,
                  [_-D|_]).

test(ejercicio_10, [true(C == [[m1, x1], [m2, x1]])]) :-
    cono(sumador, s, C).

test(ejercicio_10_conos, [true]) :-
    O = [1, 1, 0, 1, 0, 1]-[1, 0, 0, 0],
    minimos(fuerte, sumador3, [O], 2, Ds),
    forall(member(D, Ds), toca_los_conos(sumador3, O, D)).

test(ejercicio_11, [true(P-U == [[0, 0, 0], [0, 1, 1], [1, 1, 1]]-[])]) :-
    conjunto_de_pruebas(sumador, P, U).

:- end_tests(soluciones).
