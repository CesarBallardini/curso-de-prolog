:- encoding(utf8).

:- begin_tests(transferencia).

test(adjetivos_invertidos,
     all(En == [o(sn(the, [big, black], cat, sg), sleep),
                o(sn(the, [large, black], cat, sg), sleep)])) :-
    transferir(o(sn(el, gato, sg, [negro, grande]), dormir), En).

test(tacito, all(En == [o(pron(he), run), o(pron(she), run),
                        o(pron(it), run)])) :-
    transferir(o(tacito(sg), correr), En).

test(generico, all(En == [o(sn(the, [], cat, pl), eat, sn(the, [], apple, pl)),
                          o(sn(sin, [], cat, pl), eat, sn(the, [], apple, pl))
                         ])) :-
    transferir(o(sn(el, gato, pl, []), comer, sn(el, manzana, pl, [])), En).

test(inverso, all(Es == [o(tacito(sg), comer, sn(sin, manzana, pl, [rojo])),
                         o(pron(f, sg), comer, sn(sin, manzana, pl, [rojo]))
                        ])) :-
    transferir(Es, o(pron(she), eat, sn(sin, [red], apple, pl))).

test(inverso_generico,
     all(Es == [o(sn(sin, gato, pl, []), comer, sn(sin, manzana, pl, [])),
                o(sn(el, gato, pl, []), comer, sn(sin, manzana, pl, []))])) :-
    transferir(Es, o(sn(sin, [], cat, pl), eat, sn(sin, [], apple, pl))).

test(they, all(Es == [tacito(pl), pron(m, pl), pron(f, pl)])) :-
    sujeto(Es, pron(they)).

test(it, all(Es == [tacito(sg)])) :-
    sujeto(Es, pron(it)).

test(adjetivos_inverso, all(Es == [[negro, grande]])) :-
    adjetivos(Es, [big, black]).

test(ingenuo_no_termina, true(R == inference_limit_exceeded)) :-
    call_with_inference_limit(findall(Es, adjetivos_ingenuo(Es, [big, black]),
                                      _),
                              100000, R).

:- end_tests(transferencia).
