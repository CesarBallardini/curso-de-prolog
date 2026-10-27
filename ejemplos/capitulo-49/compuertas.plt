:- encoding(utf8).

:- begin_tests(compuertas).

test(semisumador_tabla,
     [true(Filas == [0-0-0-0, 0-1-1-0, 1-0-1-0, 1-1-0-1])]) :-
    findall(A-B-S-C, semisumador(A, B, S, C), Filas).

test(sumador_adelante, [nondet, true(S-C == 0-1)]) :-
    sumador(1, 1, 0, S, C).

% El sumador completo da la suma aritmética de sus tres bits.
test(sumador_aritmetica, [forall(member(A-B-Ci, [0-0-0, 0-1-1, 1-1-1])),
                           nondet, true(N =:= A + B + Ci)]) :-
    sumador(A, B, Ci, S, Co),
    N is 2 * Co + S.

test(sumador_inverso, [true(Es == [1-1-1])]) :-
    findall(A-B-Ci, sumador(A, B, Ci, 1, 1), Es).

test(sumar_bits, [nondet, true(Ss-C == [0, 0, 0]-1)]) :-
    sumar_bits([1, 1, 0], [1, 0, 1], Ss, C).

test(sumar_bits_inverso, [nondet, true(As == [1, 0, 1])]) :-
    sumar_bits(As, [1, 0, 1], [0, 1, 0], 1).

% Un inversor con la salida conectada a la entrada no tiene estado estable.
test(realimentado, [fail]) :-
    inv(X, X).

test(biestable_memoria, [true(Qs == [1-0, 0-1])]) :-
    findall(Q-Qn, biestable(1, 1, Q, Qn), Qs).

test(biestable_fija, [true(Qs == [1-0])]) :-
    findall(Q-Qn, biestable(0, 1, Q, Qn), Qs).

% Las tablas de las cinco compuertas de dos entradas, en el orden de las
% filas 00, 01, 10, 11.
test(and, [true(Ss == [0, 0, 0, 1])]) :-
    findall(S, and(_, _, S), Ss).

test(or, [true(Ss == [0, 1, 1, 1])]) :-
    findall(S, or(_, _, S), Ss).

test(xor, [true(Ss == [0, 1, 1, 0])]) :-
    findall(S, xor(_, _, S), Ss).

test(nand, [true(Ss == [1, 1, 1, 0])]) :-
    findall(S, nand(_, _, S), Ss).

test(nor, [true(Ss == [1, 0, 0, 0])]) :-
    findall(S, nor(_, _, S), Ss).

test(and_inverso, all(A-B == [0-0, 0-1, 1-0])) :-
    and(A, B, 0).

:- end_tests(compuertas).
