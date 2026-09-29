:- encoding(utf8).

:- begin_tests(minimizar).

test(det_pares_a, [true(N == 4)]) :-
    numero_estados(det(pares_a), N).

test(min_pares_a, [true(T == automata(2, [0], [0-a-1, 0-b-0, 1-a-0,
                                               1-b-1]))]) :-
    tabla(min(pares_a), T).

test(clases, [true(Cs == [[[e0], [e2]], [[e1], [e3]]])]) :-
    estados(min(pares_a), Cs).

test(indistinguibles, [fail]) :-
    distinguible(det(pares_a), [e0], [e2]).

test(palabra_que_distingue, [true(W == [])]) :-
    distinguibles(det(pares_a), [e0], [e1], W).

test(palabra_que_distingue_2, [true(W == [b])]) :-
    distinguibles(det(termina_ab), [q0], [q0, q1], W).

test(equivalente) :-
    equivalentes(min(pares_a), pares_a).

test(min_multiplo3, [true(N == 3)]) :-
    numero_estados(min(multiplo3), N).

test(min_termina_ab, [true(N == 3)]) :-
    numero_estados(min(termina_ab), N).

:- end_tests(minimizar).
