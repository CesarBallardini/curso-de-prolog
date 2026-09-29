:- encoding(utf8).

:- begin_tests(soluciones_cmos).

test(inversor, [true(Fs == [0-1, 1-0])]) :-
    findall(A-Z, ( member(A, [0, 1]), inversor_cmos(A, Z) ), Fs).

% La tabla de la NAND: una sola salida por cada combinación de entradas.
test(nand, [forall(( member(A, [0, 1]), member(B, [0, 1]) )),
            true(Zs == [Z])]) :-
    findall(Z0, nand_cmos(A, B, Z0), Zs),
    Z is 1 - A * B.

test(realimentado, [fail]) :-
    inversor_cmos(X, X).

:- end_tests(soluciones_cmos).
