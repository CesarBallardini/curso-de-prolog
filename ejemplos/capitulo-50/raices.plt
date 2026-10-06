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

test(regla_modulo, all(E == [w(1)])) :-
    regla_raices(4, w(5), E).

test(regla_uno, all(E == [1])) :-
    regla_raices(4, w(0), E).

% Sin regla de las raíces, se aplica una del capítulo 32.
test(regla_del_simplificador, all(E == [x])) :-
    regla_raices(4, x + 0, E).

% Un exponente menor que N/2 no cambia el signo.
test(raiz_sin_signo, [fail]) :-
    raiz(8, a(0) + w(3) * a(1), _).

test(raiz_reducida, [fail]) :-
    raiz(8, w(3), _).

test(simp_raices, [true(E == a(0) - a(1))]) :-
    simp_raices(4, a(0) + w(2) * a(1), E).

test(valor, [true(V == c(2.0, 1.0))]) :-
    valor(4, [1, 2], a(1) + w(1) * a(0), V).

test(valor_complejo, [true(V == c(3, 3))]) :-
    valor(4, [c(1, 1)], 3 * a(0), V).

test(complejo_numero, [true(V == c(3, 0))]) :-
    complejo(3, V).

test(complejo_par, [true(V == c(1, 2))]) :-
    complejo(c(1, 2), V).

test(raiz_numerica, [true(cercano(V, c(0, 1)))]) :-
    raiz_numerica(4, 1, V).

test(operar_producto, [true(V == c(-1, 0))]) :-
    operar(*, c(0, 1), c(0, 1), V).

test(operar_resta, [true(V == c(2, 0))]) :-
    operar(-, c(3, 1), c(1, 1), V).

test(salida_definicion, [true(cercano(V, c(-2, 0)))]) :-
    salida_definicion([1, 2, 3, 4], 4, 2, V).

test(cercano, [true]) :-
    cercano(c(1, 0), c(1.0000000001, 0)).

test(lejano, [fail]) :-
    cercano(c(1, 0), c(1.001, 0)).

test(cercanos_longitud, [fail]) :-
    cercanos([c(1, 0)], [c(1, 0), c(2, 0)]).

:- end_tests(raices).
