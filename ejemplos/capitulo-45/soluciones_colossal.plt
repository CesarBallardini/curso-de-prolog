:- encoding(utf8).



:- begin_tests(soluciones_colossal, [setup(iniciar_personajes),
                                     cleanup(iniciar_personajes)]).

test(perro_empieza_en_el_taller, all(P == [perro])) :-
    iniciar_personajes,
    personaje_en(P, taller).

test(perro_se_va, true(Rs == [vista(taller, [banco], [sotano,
                                                     vestibulo]),
                              se_va(perro)])) :-
    iniciar_personajes,
    restablecer([aqui(taller), esta_en(banco, taller),
                  cerrada(trampilla)]),
    turno(mirar, Rs).

test(perro_vuelve, true(Rs == [vista(taller, [banco], [sotano,
                                                      vestibulo]),
                               llega(perro)])) :-
    iniciar_personajes,
    restablecer([aqui(taller), esta_en(banco, taller),
                  cerrada(trampilla)]),
    turno(mirar, _),
    turno(mirar, Rs).

test(trampa, all(S == [pozo])) :-
    trampa(S).

test(no_es_trampa, fail) :-
    trampa(tesoro).

test(pendientes_al_empezar, true(Ls == [esta_en(llave, jugador)-5,
                                        esta_en(linterna, jugador)-5,
                                        aqui(sotano)-10,
                                        esta_en(lente, jugador)-10,
                                        esta_en(lente, telescopio)-20])) :-
    iniciar_puntaje,
    logros_pendientes(Ls).

test(pendientes_con_la_llave, true(L == 4)) :-
    iniciar_puntaje,
    jugada(ir(biblioteca), _),
    jugada(tomar(llave), _),
    logros_pendientes(Ls),
    length(Ls, L).

:- end_tests(soluciones_colossal).
