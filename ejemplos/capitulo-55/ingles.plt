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

test(sujeto_pronombre, all(S-N == [pron(they)-pl])) :-
    phrase(sujeto_en(S, N), ["they"]).

test(sn_an, all(SN == [sn(a, [old], book, sg)])) :-
    phrase(sn_en(SN, sg), ["an", "old", "book"]).

test(sn_a_mal, fail) :-
    phrase(sn_en(_, _), ["a", "old", "book"]).

test(sn_genera_an, all(Fs == [["an", "apple"]])) :-
    phrase(sn_en(sn(a, [], apple, sg), sg), Fs).

test(articulo_the, all(A-F == [the-"the"])) :-
    phrase(articulo_en(A, _, F), ["the"]).

test(adjetivos, all(As-Resto == [[]-["big", "black"], [big]-["black"],
                                  [big, black]-[]])) :-
    phrase(adjetivos_en(As, _, _), ["big", "black"], Resto).

test(nombre, all(L-N == [apple-pl])) :-
    phrase(nombre_en(L, N, _), ["apples"]).

test(verbo, all(L-C-N == [sleep-intransitivo-sg])) :-
    phrase(verbo_en(L, C, N), ["sleeps"]).

test(antes_de, [true(Ps == [an-apple, the-apple, a-book])]) :-
    findall(A-P, ( member(A0-P0, ["an"-"apple", "an"-"book", "a"-"apple",
                                  "the"-"apple", "a"-"book"]),
                   antes_de(A0, P0),
                   atom_string(A, A0),
                   atom_string(P, P0) ),
            Ps).

test(empieza_con_vocal) :-
    empieza_con_vocal("old").

test(empieza_con_consonante, fail) :-
    empieza_con_vocal("cat").

test(palabra_vacia, fail) :-
    empieza_con_vocal("").

:- end_tests(ingles).
