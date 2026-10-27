:- encoding(utf8).

:- begin_tests(traza).

test(abuelo, all(N == [luis, eva])) :-
    abuelo(juan, N).

test(nietos_de_nadie, [fail]) :-
    abuelo(luis, _).

:- end_tests(traza).
