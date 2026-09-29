:- encoding(utf8).

:- begin_tests(tdf).

test(coeficientes, [true(As == [a(0), a(1), a(2)])]) :-
    coeficientes(3, As).

test(matriz, [true(W == [[w(0), w(0), w(0)],
                         [w(0), w(1), w(2)],
                         [w(0), w(2), w(4)]])]) :-
    matriz_tdf(3, W).

test(salida_uno, [true(E == 0 + w(0) * a(0) + w(1) * a(1) + w(2) * a(2)
                             + w(3) * a(3))]) :-
    tdf_ingenua(4, [_, E|_]).

% N productos y N sumas por salida, contada la suma con 0.
test(costo_cuadratico, [true(S-P == 64-64)]) :-
    tdf_ingenua(8, Es),
    operaciones(Es, S, P).

% Una subexpresión repetida se cuenta cada vez.
test(repetidas, [true(S-P == 2-2)]) :-
    operaciones([a + b * c, d + b * c], S, P).

test(orden_no_positivo, [error(type_error(positive_integer, 0))]) :-
    tdf_ingenua(0, _).

:- end_tests(tdf).
