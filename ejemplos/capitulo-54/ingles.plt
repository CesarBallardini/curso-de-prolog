:- encoding(utf8).

:- begin_tests(ingles).

test(transitiva, all(A == [o(sn(the, [big, black], cat, sg), eat,
                             sn(a, [], apple, sg))])) :-
    phrase(oracion_en(A),
           ["the", "big", "black", "cat", "eats", "an", "apple"]).

test(an_mal, fail) :-
    phrase(oracion_en(_), ["he", "eats", "a", "apple"]).

test(a_mal, fail) :-
    phrase(oracion_en(_), ["he", "eats", "an", "black", "apple"]).

test(sin_articulo, all(A == [o(sn(sin, [], cat, pl), eat,
                               sn(sin, [], apple, pl))])) :-
    phrase(oracion_en(A), ["cats", "eat", "apples"]).

test(singular_sin_articulo, fail) :-
    phrase(oracion_en(_), ["cat", "eats"]).

test(concordancia, fail) :-
    phrase(oracion_en(_), ["the", "cats", "eats"]).

test(has, all(A == [o(pron(it), have, sn(a, [], book, pl))])) :-
    phrase(oracion_en(A), ["it", "has", "some", "books"]).

test(generar_an, all(Ps == [["she", "reads", "an", "old", "book"]])) :-
    phrase(oracion_en(o(pron(she), read, sn(a, [old], book, sg))), Ps).

test(generar_a, all(Ps == [["she", "reads", "a", "black", "apple"]])) :-
    phrase(oracion_en(o(pron(she), read, sn(a, [black], apple, sg))), Ps).

test(generar_plural, all(Ps == [["cats", "eat", "apples"]])) :-
    phrase(oracion_en(o(sn(sin, [], cat, pl), eat, sn(sin, [], apple, pl))),
           Ps).

:- end_tests(ingles).
