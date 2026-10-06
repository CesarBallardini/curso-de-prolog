:- encoding(utf8).

:- begin_tests(traza).

test(abuelo, [true(S == "0 abuelo(juan,A)\n0 padre(juan,A)\n1 padre(ana,A)\nvuelve\n1 padre(pedro,A)\nvuelve\n")]) :-
    with_output_to(string(S), forall(resolver(familia, abuelo(juan, _)), true)).

test(respuestas, all(N == [luis])) :-
    with_output_to(string(_), resolver(familia, abuelo(juan, N))).

% Cada paso escribe la altura de la pila y la meta.
test(paso, [true(S-R == "0 1<2\n"-sigue(m([r], [], A, [], 0, M)))]) :-
    M = med(0, 0, 0, 0, 0),
    empty_assoc(A),
    almacen:compilar([], T),
    with_output_to(string(S),
                   traza:paso(1 < 2, [r], T,
                              m([], [], A, [], 0, M), R)).

% Sin puntos de elección, volver/3 no escribe nada y termina.
test(volver_fin, [true(S-R == ""-fin(E0))]) :-
    empty_assoc(A),
    almacen:compilar([], T),
    E0 = m([], [], A, [], 0, med(0, 0, 0, 0, 0)),
    with_output_to(string(S), traza:volver(T, E0, R)).

:- end_tests(traza).
