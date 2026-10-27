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

test(salidas, [true(length(Ss, 3))]) :-
    findall(H, salida(puerto_quieto, ribera_honda, H, _), Ss).

test(sin_costo, [true(M == 360r11)]) :-
    once(sin_costo(minutos_tramo, pradera_alta, 99, puerto_quieto, M)).

% Puerto Quieto no tiene tramo directo a Ribera Honda: llegando 50 minutos
% después de las 8:00, la balsa de las 8:45 ya salió, y quedan las de las
% 9:45 y las 10:45, con 20 minutos de viaje.
test(sucesor_con_balsa, all(P == [75, 135])) :-
    sucesor_con_balsa(480, puerto_quieto, 50, ribera_honda, P).

test(minutos_evitando, all(B == [ribera_honda, puerto_quieto])) :-
    minutos_evitando([ripio], piedra_mora, B, _).

test(minutos_evitando_excluye, [fail]) :-
    minutos_evitando([ripio], arroyo_pinto, alto_del_cardo, _).

:- end_tests(soluciones_rutas).
