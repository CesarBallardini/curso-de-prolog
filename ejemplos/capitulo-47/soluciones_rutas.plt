:- encoding(utf8).

:- begin_tests(soluciones_rutas).

% A las 8:33 en Puerto Quieto, la balsa de las 8:45 llega antes que la ruta.
test(con_balsa, [true(H == ['8:00'-pradera_alta, '8:33'-puerto_quieto,
                            '9:05'-ribera_honda])]) :-
    horario_con_balsa(pradera_alta, ribera_honda, 8:00, H).

% A las 8:53, la balsa siguiente sale a las 9:45: conviene la ruta.
test(sin_balsa, [true(H1 == H2)]) :-
    horario_con_balsa(pradera_alta, ribera_honda, 8:20, H1),
    horario(pradera_alta, ribera_honda, 8:20, H2).

test(balsa_y_ruta, [true(Ultimo == '9:26'-ermita_vieja)]) :-
    horario_con_balsa(pradera_alta, ermita_vieja, 8:00, H),
    last(H, Ultimo).

% Con sin_costo/5, la búsqueda generalizada da lo mismo que la original.
test(generaliza, [true(C1 == C2)]) :-
    costo_uniforme_t(pradera_alta, es(ermita_vieja),
                     sin_costo(minutos_tramo), C1),
    costo_uniforme(pradera_alta, es(ermita_vieja), minutos_tramo, C2).

test(evitando_autopista, [true(M-Cs == 788r7-[pradera_alta, arroyo_pinto,
                                             alto_del_cardo,
                                             ermita_vieja])]) :-
    ruta_evitando(pradera_alta, ermita_vieja, [autopista], M, Cs).

test(evitando_ripio, [true(Cs1 == Cs2)]) :-
    ruta_evitando(pradera_alta, ermita_vieja, [ripio], _, Cs1),
    ruta(pradera_alta, ermita_vieja, _, Cs2).

test(evitando_todo, [fail]) :-
    ruta_evitando(pradera_alta, ermita_vieja, [autopista, ripio], _, _).

:- end_tests(soluciones_rutas).
