:- encoding(utf8).

:- begin_tests(soluciones_ebg).

test(pesado, [true(R =@= (pesado(A) :- [peso(A, P), volumen(A, V),
                                         D is P / V, D > 1]))]) :-
    aprender_is(bloque1, pesado(bloque1), R).

test(corcho, [fail]) :-
    aprender_is(corcho1, pesado(corcho1), _).

test(explicar, [true]) :-
    hechos_is(bloque1, Hs),
    once(explicar_is(Hs, pesado(bloque1))).

test(regla_is, [true(H =@= pesado(_))]) :-
    regla_is((H :- _)).

test(predefinido_is, all(F == [is, <, >])) :-
    member(G, [_ is 1, 1 < 2, 2 > 1, peso(a, 1)]),
    predefinido_is(G),
    functor(G, F, _).

% La prueba del ejemplo calcula D = 3; la copia general conserva el
% cociente sin evaluar.
test(generalizar_is, [nondet, true(GG-L =@= pesado(A)-[peso(A, P),
                                                     volumen(A, V),
                                                     D is P / V, D > 1])]) :-
    hechos_is(bloque1, Hs),
    phrase(generalizar_is(Hs, pesado(bloque1), GG), L).

test(generalizar_is_falla, [fail]) :-
    hechos_is(corcho1, Hs),
    phrase(generalizar_is(Hs, pesado(corcho1), _), _).

:- end_tests(soluciones_ebg).
