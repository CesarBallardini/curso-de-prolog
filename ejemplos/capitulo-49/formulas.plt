:- encoding(utf8).

:- use_module(circuitos).

:- begin_tests(formulas).

test(sumador, [true(Fs == [s-(a#b#ci), co-(a*b + (a#b)*ci)])]) :-
    findall(S-F, formula(sumador, S, F), Fs).

test(sumador3_acarreo,
     [nondet, true(F == a2*b2 + (a2#b2)*(a1*b1 + (a1#b1)*(a0*b0)))]) :-
    formula(sumador3, c, F).

test(fnn, [true(N == ~a + ~b*c)]) :-
    fnn(~(a * (b + ~c)), N).

test(fnn_xor, [true(N == a * ~b + ~a * b)]) :-
    fnn(a # b, N).

test(productos, [true(Ps == [[a, c], [a, d], [b, c], [b, d]])]) :-
    productos((a + b) * (c + d), Ps).

test(simplificar, [true(Ps == [[a], [b, c]])]) :-
    simplificar([[a, b], [c, b], [a], [a, ~a], [b, b, c]], Ps).

test(constantes, [true(Ps-Qs == [[]]-[])]) :-
    suma_de_productos(a + 1, Ps),
    suma_de_productos(a * ~a, Qs).

test(xor_nand, [nondet, true(Ps == [[x, ~y], [y, ~x]])]) :-
    formula(xor_nand, z, F),
    suma_de_productos(F, Ps).

% El acarreo del sumador y el de la mayoría son la misma función, pero
% sus sumas de productos son distintas.
test(acarreo, [nondet, true(Ps \== Qs)]) :-
    formula(sumador, co, F),
    suma_de_productos(F, Ps),
    suma_de_productos(a*b + a*ci + b*ci, Qs),
    Qs == [[a, b], [a, ci], [b, ci]].

test(como_formula, [true(F == a*b + b*ci * ~a)]) :-
    como_formula([[a, b], [b, ci, ~a]], F).

test(como_formula_constantes, [true(F-G == 0-1)]) :-
    como_formula([], F),
    como_formula([[]], G).

test(realimentacion,
     [error(domain_error(circuito_sin_realimentacion, biestable))]) :-
    formula(biestable, q, _).

% La fórmula y la simulación dan el mismo valor en cada fila.
test(como_simular, [forall(( member(A, [0, 1]), member(B, [0, 1]),
                             member(C, [0, 1]) )),
                    nondet, true(V =:= S)]) :-
    simular(sumador, [A, B, C], [S, _]),
    formula(sumador, s, F),
    evaluar(F, [a-A, b-B, ci-C], V).

% evaluar(F, Valores, V): V es el valor de la fórmula F con los valores
% de las entradas dados como pares.
evaluar(0, _, 0).
evaluar(1, _, 1).
evaluar(X, Vs, V) :- atom(X), memberchk(X-V, Vs).
evaluar(~F, Vs, V) :- evaluar(F, Vs, V0), V is 1 - V0.
evaluar(F * G, Vs, V) :- evaluar(F, Vs, V1), evaluar(G, Vs, V2), V is V1 /\ V2.
evaluar(F + G, Vs, V) :- evaluar(F, Vs, V1), evaluar(G, Vs, V2), V is V1 \/ V2.
evaluar(F # G, Vs, V) :- evaluar(F, Vs, V1), evaluar(G, Vs, V2), V is V1 xor V2.

test(simbolica_inv, [nondet, true(F == ~a)]) :-
    formulas:simbolica([], inv, [a], F).

test(simbolica_nand, [nondet, true(F == ~(a * b))]) :-
    formulas:simbolica([], nand, [a, b], F).

test(negar_nombre, [true(N == ~a)]) :-
    formulas:negar(a, N).

test(negar_constantes, [true(N0-N1 == 1-0)]) :-
    formulas:negar(0, N0),
    formulas:negar(1, N1).

test(negar_de_morgan, [true(N == ~a + b)]) :-
    formulas:negar(a * ~b, N).

test(negar_xor, [true(N == a * b + ~a * ~b)]) :-
    formulas:negar(a # b, N).

test(contradictorio) :-
    formulas:contradictorio([a, b, ~a]).

test(no_contradictorio, [fail]) :-
    formulas:contradictorio([a, ~b]).

test(absorbido) :-
    formulas:absorbido([[a], [a, b]], [a, b]).

test(no_absorbido, [fail]) :-
    formulas:absorbido([[a, b], [c]], [a, b]).

test(producto, [true(F == a * ~b * c)]) :-
    formulas:producto([a, ~b, c], F).

test(producto_vacio, [true(F == 1)]) :-
    formulas:producto([], F).

test(sumar, [true(F == x + a * b)]) :-
    formulas:sumar([a, b], x, F).

:- end_tests(formulas).
