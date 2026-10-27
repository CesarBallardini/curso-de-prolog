:- encoding(utf8).

:- begin_tests(agencia).

test(tours_de_tres, all(T == [[roma, venecia, atenas], [atenas, roma, venecia],
                              [atenas, venecia, roma],
                              [venecia, roma, atenas]])) :-
    tour([roma, atenas, venecia], T).

test(tours_de_cuatro_comienzan_bien, all(T == [[dresde, colonia, hamburgo, viena],
                                                [dresde, hamburgo, colonia, viena]])) :-
    tour([dresde, viena, colonia, hamburgo], T),
    T = [dresde|_].

test(vuelve_a_italia, [fail]) :-
    tour([roma, atenas, venecia], [roma, atenas, venecia]).

:- end_tests(agencia).
