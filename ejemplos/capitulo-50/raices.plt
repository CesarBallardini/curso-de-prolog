:- encoding(utf8).

:- begin_tests(raices).

test(modulo, [true(E == w(4))]) :-
    simplificar_raices(8, w(12), E).

test(uno, [true(E == a(3))]) :-
    simplificar_raices(8, w(8) * a(3), E).

test(menos_uno, [true(E == a(0) - a(1))]) :-
    simplificar_raices(8, a(0) + w(12) * a(1), E).

test(signo, [true(E == a(0) - w(1) * a(1))]) :-
    simplificar_raices(8, a(0) + w(5) * a(1), E).

test(tdf_cuatro, [true(Es == [a(0) + a(1) + a(2) + a(3),
                              a(0) + w(1) * a(1) - a(2) - w(1) * a(3),
                              a(0) - a(1) + a(2) - a(3),
                              a(0) - w(1) * a(1) - a(2) + w(1) * a(3)])]) :-
    tdf_ingenua(4, Es0),
    maplist(simplificar_raices(4), Es0, Es).

test(con_variables, [error(instantiation_error)]) :-
    simplificar_raices(4, a(0) + _, _).

% De orden 2: la suma y la diferencia.
test(definicion) :-
    definicion([1, 2], Vs),
    cercanos(Vs, [c(3, 0), c(-1, 0)]).

% Las expresiones de la matriz, simplificadas o no, valen lo que la
% definición, con coeficientes reales y complejos.
test(valor_como_definicion, [forall(member(N, [1, 2, 4, 8, 6]))]) :-
    numlist(1, N, Cs0),
    maplist([X, c(X, Y)]>>(Y is X * X - 3), Cs0, Cs),
    definicion(Cs, Vs),
    tdf_ingenua(N, Es0),
    maplist(valor(N, Cs), Es0, Vs0),
    cercanos(Vs, Vs0),
    maplist(simplificar_raices(N), Es0, Es),
    maplist(valor(N, Cs), Es, Vs1),
    cercanos(Vs, Vs1).

:- end_tests(raices).
