:- encoding(utf8).

:- begin_tests(soluciones).

test(restador) :-
    resta_correcta.

test(restador_ejemplo, [nondet, true(Ds == [1, 1, 1, 1])]) :-
    simular(restador3, [1, 0, 0, 0, 1, 0], Ds).

test(mux_sdp, [nondet, true(Ps == [[a, ~s], [b, s]])]) :-
    formula(mux, z, F),
    suma_de_productos(F, Ps).

test(mux_nand) :-
    equivalentes(mux, mux_nand).

test(nand_universal) :-
    equivalentes(inv_nand, inv1),
    equivalentes(and_nand, and1),
    equivalentes(or_nand, or1).

test(pegada_s, [true(Ess == [[0, 0, 1], [0, 1, 0], [1, 0, 0], [1, 1, 1]])]) :-
    findall(Es, detecta(sumador, [m2, x1], 0, Es), Ess).

test(pegada_co, [true(Ess == [[0, 0, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0]])]) :-
    findall(Es, detecta(sumador, [o1], 1, Es), Ess).

test(minterminos_xor, [true(Ps == [[x, ~y], [y, ~x]])]) :-
    minterminos(xor_nand, z, Ps).

test(minterminos_co, [true(Ps == [[a, b, ci], [a, b, ~ci], [a, ci, ~b],
                                  [b, ci, ~a]])]) :-
    minterminos(sumador, co, Ps).

test(consenso_acarreo, [nondet, true(Ps == [[a, b], [a, ci], [b, ci]])]) :-
    formula(sumador, co, F),
    suma_de_productos(F, Ps0),
    simplificar_consenso(Ps0, Ps).

% Los productos de los mintérminos del acarreo se reducen igual.
test(consenso_minterminos, [true(Ps == [[a, b], [a, ci], [b, ci]])]) :-
    minterminos(sumador, co, Ps0),
    simplificar_consenso(Ps0, Ps).

test(consenso_xor, [true(Ps == [[x, ~y], [y, ~x]])]) :-
    simplificar_consenso([[x, ~y], [y, ~x]], Ps).

test(contador2, [nondet, true(Ss == [[0, 0], [1, 0], [0, 1], [0, 1], [1, 1],
                                     [1, 1]])]) :-
    ejecutar(contador2, [0, 0], [[1], [1], [0], [1], [0], [1]], Ss).

test(contador2_estados, [true(N == 4)]) :-
    aggregate_all(count, alcanzable(contador2, [0, 0], _), N).

test(detector,
     [nondet, true(Ss == [[0], [0], [1], [0], [1], [0], [0], [1]])]) :-
    ejecutar(detector, [0, 0], [[1], [0], [1], [0], [1], [1], [0], [1]], Ss).

test(detector_correcto) :-
    detector_correcto.

test(anticipado) :-
    equivalentes(sumador3, sumador3_anticipado).

test(anticipado_compuertas, [true(N-M == 12-15)]) :-
    compuertas(sumador3, N),
    compuertas(sumador3_anticipado, M).

test(profundidad, [true(P1-P2 == [1, 2, 4, 5]-[1, 2, 4, 4])]) :-
    once(simular(profundidad, sumador3, [0, 0, 0, 0, 0, 0], P1)),
    once(simular(profundidad, sumador3_anticipado, [0, 0, 0, 0, 0, 0], P2)).

:- end_tests(soluciones).
