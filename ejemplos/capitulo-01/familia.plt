:- encoding(utf8).

:- begin_tests(familia).

test(abuelo_de_luis, [nondet]) :-
    abuelo(juan, luis).

test(nietos_de_juan, all(N == [luis, eva])) :-
    abuelo(juan, N).

test(juan_no_tiene_abuelo, [fail]) :-
    abuelo(_, juan).

:- end_tests(familia).
