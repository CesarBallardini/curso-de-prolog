:- encoding(utf8).

:- begin_tests(soluciones_cintas).

% Ejercicio 14: final_de(anbn) acepta por estado final las mismas
% palabras que anbn acepta por pila vacía.
test(ej14_mismas, [true(Ws == Vs)]) :-
    findall(W, ( between(0, 6, L), length(W, L),
                 maplist([S]>>member(S, [a, b]), W),
                 once(acepta_pila(final_de(anbn), W)) ), Ws),
    findall(W, ( between(0, 6, L), length(W, L),
                 maplist([S]>>member(S, [a, b]), W),
                 once(acepta_vacia(anbn, W)) ), Vs).

test(ej14_acepta, [nondet]) :-
    acepta_pila(final_de(anbn), [a, a, b, b]).

test(ej14_rechaza, [fail]) :-
    acepta_pila(final_de(anbn), [a, a, b]).

% De ida y vuelta: vacia(final_de(anbn)) acepta lo mismo que anbn.
test(ej14_ida_y_vuelta, [true(Ws == [[], [a, b], [a, a, b, b]])]) :-
    findall(W, ( between(0, 4, L), length(W, L),
                 once(acepta_vacia(vacia(final_de(anbn)), W)) ), Ws).

% Ejercicio 15: con dos cintas, 3n + 3 pasos; con una, un número que
% crece con el cuadrado de n.
test(ej15_pasos, [true(Ps == [2-6-9, 4-15-15, 8-45-27, 16-153-51])]) :-
    findall(N-P1-P2, ( member(N, [2, 4, 8, 16]),
                       comparar_pasos(N, P1, P2) ), Ps).

% Ejercicio 16: unario da el valor de cada número de hasta 5 bits.
test(ej16_unario, [forall(between(0, 31, V)), true(N =:= V)]) :-
    format(atom(A), '~2r', [V]),
    atom_chars(A, Cs),
    maplist([C, D]>>atom_number(C, D), Cs, Bits),
    markov(unario, Bits, 10000, fin(Is)),
    maplist(==(i), Is),
    length(Is, N).

test(ej16_ceros, [true(R == fin([]))]) :-
    markov(unario, [0, 0, 0], 100, R).

:- end_tests(soluciones_cintas).
