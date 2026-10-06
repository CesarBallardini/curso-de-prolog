:- encoding(utf8).

:- begin_tests(transistores).

test(pwr, all(X == [1])) :-
    pwr(X).

test(gnd, all(X == [0])) :-
    gnd(X).

% ptran/3 y ntran/3: los estados estables de cada transistor.
test(ptran_conduce, [nondet, true(D == 1)]) :-
    ptran(1, 0, D).

test(ptran_abierto, [true(var(D))]) :-
    ptran(1, 1, D).

test(ntran_conduce, [nondet, true(D == 0)]) :-
    ntran(0, 1, D).

test(ntran_abierto, [nondet]) :-
    ntran(0, 0, 1).

test(inversor, all(A-Z == [0-1, 1-0])) :-
    inversor_cmos(A, Z).

test(inversor_inverso, all(A == [1])) :-
    inversor_cmos(A, 0).

% Un inversor realimentado no tiene estados estables.
test(realimentado, [fail]) :-
    inversor_cmos(X, X).

test(cortocircuito, [fail]) :-
    cortocircuito(_).

test(xor, all(A-B-Z == [0-0-0, 0-1-1, 1-0-1, 1-1-0])) :-
    xor_cmos(A, B, Z).

% Cada combinación de entradas tiene una sola salida, la de xor/3.
test(xor_tabla, [forall(( member(A, [0, 1]), member(B, [0, 1]) )),
                 true(Zs == [Z])]) :-
    findall(Z0, xor_cmos(A, B, Z0), Zs),
    Z is A xor B.

test(xor_inverso, all(A-B == [0-1, 1-0])) :-
    xor_cmos(A, B, 1).

:- end_tests(transistores).
