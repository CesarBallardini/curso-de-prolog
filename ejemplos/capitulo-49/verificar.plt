:- encoding(utf8).

:- use_module(circuitos).

:- begin_tests(verificar).

test(mayoria) :-
    equivalentes(sumador, sumador_mayoria).

test(xor_nand) :-
    equivalentes(xor_nand, xor1).

test(error, [fail]) :-
    equivalentes(sumador, sumador_error).

% Interfaces distintas: no hay nada que comparar.
test(interfaz, [fail]) :-
    equivalentes(sumador, semisumador).

test(diferencia, [true(Es == [[1, 0, 1]])]) :-
    findall(E, diferencia(sumador, sumador_error, E), Es).

test(sin_diferencia, [fail]) :-
    diferencia(sumador, sumador_mayoria, _).

% La diferencia que da clpb es la que da la simulación.
test(diferencia_simulada, [true(S1-S2 == [0, 1]-[0, 0])]) :-
    once(simular(sumador, [1, 0, 1], S1)),
    once(simular(sumador_error, [1, 0, 1], S2)).

test(cuantas, [true(N-M == 4-4)]) :-
    cuantas(sumador, co, 1, N),
    cuantas(sumador, s, 0, M).

% El acarreo final del sumador de tres bits es 1 en las 28 sumas de dos
% números de 0 a 7 que dan 8 o más.
test(cuantas_sumador3, [true(N == 28)]) :-
    cuantas(sumador3, c, 1, N),
    aggregate_all(count,
                  ( between(0, 7, X), between(0, 7, Y), X + Y >= 8 ),
                  28).

test(salida_desconocida, [fail]) :-
    cuantas(sumador, z, 1, _).

test(restriccion, [nondet, true(S == 0)]) :-
    restriccion([], nand, [1, 1], S).

test(restriccion_inversa, [nondet, true(A-B == 1-1)]) :-
    restriccion([], nand, [A, B], 0),
    clpb:labeling([A, B]).

test(modelo, [true(S-C == 1-0)]) :-
    verificar:modelo(semisumador, [1, 0], [S, C]).

test(equivalente) :-
    verificar:equivalente(1, 1).

test(no_equivalente, [fail]) :-
    verificar:equivalente(_, 1).

:- end_tests(verificar).
