:- encoding(utf8).

:- begin_tests(capitulo41).

test(ganada) :-
    ganada(tateti(3), pos([x,o,v, v,x,v, v,v,o], x)).

test(no_ganada, [fail]) :-
    ganada(tateti(3), pos([v,v,v, v,v,v, v,v,v], x)).

test(fin, [true(R == gana(x))]) :-
    fin(tateti(3), pos([x,x,x, o,o,v, v,v,v], o), R).

:- end_tests(capitulo41).
