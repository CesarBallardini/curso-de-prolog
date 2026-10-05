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

test(distinguible, set(Q == [[q0, q1], [q0, q2]])) :-
    distinguible(det(termina_ab), [q0], Q).

% Las dos versiones dan los mismos pares.
test(directo, [true(Ps == Qs)]) :-
    findall(P-Q, ( distinguible_directo(det(multiplo3), P, Q), P @< Q ), Ps0),
    sort(Ps0, Ps),
    findall(P-Q, ( distinguible(det(multiplo3), P, Q), P @< Q ), Qs0),
    sort(Qs0, Qs).

test(arcos, [true(As == [[q0, q1]-a-[q0, q1], [q0, q1]-b-[q0, q2],
                         [q0, q2]-a-[q0, q1], [q0, q2]-b-[q0],
                         [q0]-a-[q0, q1], [q0]-b-[q0]])]) :-
    minimizar:arcos(det(termina_ab), As).

test(predecesor, set(S-P == [a-[q0], a-[q0, q1], a-[q0, q2]])) :-
    minimizar:predecesor(det(termina_ab), [q0, q1], S, P).

test(distinguibles, [true(W == [b])]) :-
    distinguibles(det(termina_ab), [q0], [q0, q1], W).

test(distinguibles_iguales, [fail]) :-
    distinguibles(det(termina_ab), [q0], [q0], _).

test(lleva, all(W-P == [[a, a]-[q0, q1], [a, b]-[q0, q2], [b, a]-[q0, q1],
                        [b, b]-[q0]])) :-
    length(W, 2),
    minimizar:lleva(det(termina_ab), [q0], W, P).

test(clase_sola, [true(C == [[q0]])]) :-
    clase(det(termina_ab), [q0], C).

:- end_tests(minimizar).
