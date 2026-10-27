:- encoding(utf8).

:- begin_tests(rimas).

test(sufijos, [true(Ss == [[a], [b, a], [c, b, a]])]) :-
    sufijos([c, b, a], Ss).

test(sufijos_vacia, [true(Ss == [])]) :-
    sufijos([], Ss).

test(estrofa_corta, [true(Ls == ["Esta es la casa que construyó Juan."])]) :-
    cadena(C),
    last(C, E),
    estrofa([E], Ls).

test(estrofa_tres, [true(Ls == ["Esta es la rata",
                                "que se comió la malta",
                                "que estaba en la casa que construyó Juan."])]) :-
    cadena(C),
    once(append(_, [R, M, Casa], C)),
    estrofa([R, M, Casa], Ls).

test(versos_contraccion, [true(Ls == ["que mató a la rata",
                                      "que asustó al gato"])]) :-
    versos(v("que mató", a), [e(la, "rata", v("que asustó", a)),
                              e(el, "gato", fin)], Ls).

test(contraccion, [true(U == al)]) :-
    contraccion(a, el, U).

test(con_punto, [true(Ls == ["a", "b."])]) :-
    con_punto(["a", "b"], Ls).

test(rima, [true(N-L == 11-11)]) :-
    rima(Es),
    length(Es, N),
    last(Es, Ultima),
    length(Ultima, L).

test(rima_acumulativa) :-
    rima(Es),
    forall(nextto(A, B, Es),
           ( append(_, [_|Cola], A),
             append(_, Cola, B) )).

test(estrofa_n, [true(Ls == ["Esta es la malta",
                               "que estaba en la casa que construyó Juan."])]) :-
    estrofa_n(2, Ls).

test(estrofa_n_fuera, [fail]) :-
    estrofa_n(12, _).

test(en_letras, [true(Ps == ["uno", "dieciséis", "veintiuno", "treinta",
                             "treinta y uno", "noventa y nueve"])]) :-
    maplist(en_letras, [1, 16, 21, 30, 31, 99], Ps).

test(en_letras_fuera, [fail]) :-
    en_letras(100, _).

test(ante_sustantivo, [true(Ps == ["un", "veintiún", "treinta y un", "dos"])]) :-
    maplist(ante_sustantivo, [1, 21, 31, 2], Ps).

test(estrofa_uno, [true(Ls == ["Un elefante se balanceaba",
                               "sobre la tela de una araña;",
                               "como veía que resistía",
                               "fue a llamar a otro elefante."])]) :-
    estrofa_elefantes(1, Ls).

test(estrofa_veintiuno, [true(L1 == "Veintiún elefantes se balanceaban")]) :-
    estrofa_elefantes(21, [L1|_]).

test(numero_gramatical, [true(Ns == [singular, plural])]) :-
    maplist(numero_gramatical, [1, 2], Ns).

test(mayuscula_inicial, [true(T == "Treinta")]) :-
    mayuscula_inicial("treinta", T).

test(cancion, [true(N == 99)]) :-
    aggregate_all(count, cancion(_), N).

test(cancion_orden, [true(L1 == "Dos elefantes se balanceaban")]) :-
    findall(E, limit(2, cancion(E)), [_, [L1|_]]).

:- end_tests(rimas).
