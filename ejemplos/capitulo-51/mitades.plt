:- encoding(utf8).

:- begin_tests(mitades).

test(alternar, [true(P-I == [0, 2, 4, 6]-[1, 3, 5, 7])]) :-
    alternar([0, 1, 2, 3, 4, 5, 6, 7], P, I).

test(impar, [fail]) :-
    alternar([0, 1, 2], _, _).

test(inversa, [true(L == [a, 1, b, 2])]) :-
    alternar(L, [a, b], [1, 2]).

test(salida_seis, [true(E == a(0) + w(0) * a(4)
                             + w(4) * (a(2) + w(0) * a(6))
                             + w(6) * (a(1) + w(0) * a(5)
                                       + w(4) * (a(3) + w(0) * a(7))))]) :-
    evaluar([0, 1, 2, 3, 4, 5, 6, 7], 6, 8, E).

test(un_indice, [true(E == a(5))]) :-
    evaluar([5], 3, 8, E).

% Sin compartir, los árboles cuestan casi lo mismo que la matriz.
test(costo, [true(S-P == 56-56)]) :-
    fft_arboles(8, Es),
    operaciones(Es, S, P).

test(como_definicion, [forall(member(N, [1, 2, 4, 8, 16]))]) :-
    numlist(1, N, Cs),
    definicion(Cs, Vs),
    fft_arboles(N, Es),
    maplist(valor(N, Cs), Es, Vs0),
    cercanos(Vs, Vs0).

test(no_potencia, [error(domain_error(potencia_de_dos, 6))]) :-
    fft_arboles(6, _).

% El primer índice va aparte; el resto se alterna.
test(evaluar_5, [true(E == a(0) + w(2) * a(2)
                         + w(1) * (a(1) + w(2) * a(3)))]) :-
    evaluar([1, 2, 3], 0, 1, 4, E).

test(alternar_vacia, [true(P-I == []-[])]) :-
    alternar([], P, I).

% Las dos mitades tienen la misma longitud.
test(alternar_desparejas, [fail]) :-
    alternar(_, [a], []).

test(potencia_de_dos, [true]) :-
    potencia_de_dos(8).

test(potencia_cero, [error(type_error(positive_integer, 0))]) :-
    potencia_de_dos(0).

test(orden_uno, [true(Es == [a(0)])]) :-
    fft_arboles(1, Es).

test(orden_dos, [true(Es == [a(0) + w(0) * a(1), a(0) + w(1) * a(1)])]) :-
    fft_arboles(2, Es).

:- end_tests(mitades).
