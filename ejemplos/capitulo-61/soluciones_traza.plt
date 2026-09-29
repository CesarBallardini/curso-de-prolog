:- encoding(utf8).

:- begin_tests(traza).

test(abuelo, [true(S == "0 abuelo(juan,A)\n0 padre(juan,A)\n1 padre(ana,A)\nvuelve\n1 padre(pedro,A)\nvuelve\n")]) :-
    with_output_to(string(S), forall(resolver(familia, abuelo(juan, _)), true)).

test(respuestas, all(N == [luis])) :-
    with_output_to(string(_), resolver(familia, abuelo(juan, N))).

:- end_tests(traza).
