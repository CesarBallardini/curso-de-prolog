:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(circuitos).

test(sumador, [nondet, true(Ss == [0, 1])]) :-
    simular(sumador, [1, 1, 0], Ss).

test(sumador_inverso, [true(Es == [[1, 1, 1]])]) :-
    findall(E, simular(sumador, E, [1, 1]), Es).

% La descripción del sumador da lo mismo que el sumador/5 de la versión 1.
test(como_version_1, [forall(( member(A, [0, 1]), member(B, [0, 1]),
                               member(C, [0, 1]) )),
                      nondet, true([S, Co] == [S1, Co1])]) :-
    simular(sumador, [A, B, C], [S, Co]),
    circuitos:sumador(A, B, C, S1, Co1).

test(xor_nand, [true(F == [[0, 0]-[0], [0, 1]-[1], [1, 0]-[1], [1, 1]-[0]])]) :-
    tabla_de_verdad(xor_nand, F).

% El sumador de tres bits suma: 3 + 5 = 8, es decir 000 con acarreo 1.
test(sumador3, [nondet, true(Ss == [0, 0, 0, 1])]) :-
    simular(sumador3, [1, 1, 0, 1, 0, 1], Ss).

test(sumador3_aritmetica, [forall(( between(0, 7, X), between(0, 7, Y) )),
                           nondet, true(Z =:= X + Y)]) :-
    bits3(X, [A0, A1, A2]),
    bits3(Y, [B0, B1, B2]),
    simular(sumador3, [A0, A1, A2, B0, B1, B2], [S0, S1, S2, C]),
    Z is S0 + 2 * S1 + 4 * S2 + 8 * C.

test(biestable, [true(Qs == [[1, 0], [0, 1]])]) :-
    findall(Q, simular(biestable, [1, 1], Q), Qs).

test(rutas, [true(Rs == [[m1, x1]-xor, [m1, y1]-and, [m2, x1]-xor,
                         [m2, y1]-and, [o1]-or])]) :-
    findall(R-T, compuerta_en(sumador, R, T), Rs).

test(compuertas, [true(N == 12)]) :-
    compuertas(sumador3, N).

% Una conducta que invierte la salida de una sola compuerta, por su ruta.
test(conducta, [nondet, true(Ss == [0, 0])]) :-
    simular(invierte([o1]), sumador, [1, 1, 0], Ss).

test(desconocido, [fail]) :-
    simular(no_existe, [0], _).

% bits3(N, Bs): Bs son los tres bits de N, el menos significativo primero.
bits3(N, [B0, B1, B2]) :-
    B0 is N /\ 1,
    B1 is (N >> 1) /\ 1,
    B2 is (N >> 2) /\ 1.

% invierte(Ruta, R, Tipo, Es, S): la compuerta de Ruta da la salida opuesta
% a la de su tabla; las demás funcionan.
invierte(Ruta, R, Tipo, Es, S) :-
    tabla(Tipo, Es, S0),
    (   R == Ruta
    ->  S is 1 - S0
    ;   S = S0
    ).

:- end_tests(circuitos).
