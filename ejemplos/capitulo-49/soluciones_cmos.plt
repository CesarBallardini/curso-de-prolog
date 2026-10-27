:- encoding(utf8).

:- begin_tests(soluciones_cmos).

% La tabla de la NAND: una sola salida por cada combinación de entradas.
test(nand, [forall(( member(A, [0, 1]), member(B, [0, 1]) )),
            true(Zs == [Z])]) :-
    findall(Z0, nand_cmos(A, B, Z0), Zs),
    Z is 1 - A * B.

test(nand_inversa, all(A-B == [1-1])) :-
    nand_cmos(A, B, 0).

% Con las dos entradas unidas, la NAND es un inversor.
test(nand_como_inversor, all(A-Z == [0-1, 1-0])) :-
    nand_cmos(A, A, Z).

% En el modelo de estados estables, cualquiera de los dos transistores del
% par basta: las dos variantes tienen la tabla de xor_cmos/3.
test(sin_par_p, all(A-B-Z == [0-0-0, 0-1-1, 1-0-1, 1-1-0])) :-
    xor_sin_par_p(A, B, Z).

test(sin_par_n, all(A-B-Z == [0-0-0, 0-1-1, 1-0-1, 1-1-0])) :-
    xor_sin_par_n(A, B, Z).

:- end_tests(soluciones_cmos).
