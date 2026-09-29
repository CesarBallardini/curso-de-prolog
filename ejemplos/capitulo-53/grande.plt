:- encoding(utf8).

:- begin_tests(grande).

test(cantidad, [true(N == 500)]) :-
    findall(L, sintetico(L), Ls),
    sort(Ls, Distintos),
    length(Distintos, N).

test(en_el_lexico) :-
    once(verbo("badar", regular)).

test(verbos, [true(N == 523)]) :-
    findall(V, verbo(V, _), Vs),
    length(Vs, N).

:- end_tests(grande).
