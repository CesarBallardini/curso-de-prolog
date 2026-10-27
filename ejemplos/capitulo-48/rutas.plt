:- encoding(utf8).

:- begin_tests(rutas).

% 36 km a 110 * 3r5 = 66 km/h: 360r11 minutos, exactos.
test(tramo_exacto, [true(M == 360r11)]) :-
    once(minutos_tramo(pradera_alta, puerto_quieto, M)).

test(dos_sentidos, [true(M1 == M2)]) :-
    once(minutos_tramo(pradera_alta, puerto_quieto, M1)),
    once(minutos_tramo(puerto_quieto, pradera_alta, M2)).

test(mas_rapida, [true(Cs == [pradera_alta, puerto_quieto, piedra_mora,
                              ribera_honda, alto_del_cardo,
                              ermita_vieja])]) :-
    ruta(pradera_alta, ermita_vieja, M, Cs),
    M == 43859r396.

% El recorrido más corto no es el más rápido: tiene un tramo de ripio en
% la montaña.
test(mas_corta, [true(Km-Cs == 87-[pradera_alta, arroyo_pinto,
                                   alto_del_cardo, ermita_vieja])]) :-
    ruta_mas_corta(pradera_alta, ermita_vieja, Km, Cs).

test(mas_corta_es_mas_lenta, [true(M1 < M2)]) :-
    ruta(pradera_alta, ermita_vieja, M1, _),
    ruta_mas_corta(pradera_alta, ermita_vieja, _, Cs),
    minutos_recorrido(Cs, M2).

% minutos_recorrido(Cs, M): recorrer las ciudades Cs, en orden, lleva M.
minutos_recorrido([C|Cs], M) :-
    foldl(sumar_tramo, Cs, C-0, _-M).

% sumar_tramo(B, A-M0, B-M): llegar a B desde A suma el tramo a M0.
sumar_tramo(B, A-M0, B-M) :-
    once(minutos_tramo(A, B, T)),
    M is M0 + T.

test(horario, [true(H == ['8:00'-pradera_alta, '8:33'-puerto_quieto,
                          '9:09'-piedra_mora, '9:30'-ribera_honda,
                          '9:38'-alto_del_cardo,
                          '9:51'-ermita_vieja])]) :-
    horario(pradera_alta, ermita_vieja, 8:00, H).

test(medianoche, [true(H == ['23:30'-pradera_alta, '0:03'-puerto_quieto,
                             '0:39'-piedra_mora, '1:00'-ribera_honda])]) :-
    horario(pradera_alta, ribera_honda, 23:30, H).

test(mismo_lugar, [true(M-Cs == 0-[pradera_alta])]) :-
    ruta(pradera_alta, pradera_alta, M, Cs).

test(sin_ruta, [fail]) :-
    ruta(pradera_alta, roma, _, _).

test(hora_invalida, [error(type_error(hora, 25:0))]) :-
    horario(pradera_alta, piedra_mora, 25:00, _).

test(origen_libre, [error(instantiation_error)]) :-
    ruta(_, piedra_mora, _, _).

test(tramo, [true(Km == 36)]) :-
    tramo(pradera_alta, puerto_quieto, Km, _, _, _).

test(velocidades, [true(Vs == [autopista-110, pavimento-80, ripio-50])]) :-
    findall(C-V, velocidad(C, V), Vs).

test(factores, [true(Ts-Ps == [1, 4r5, 3r5]-[1, 9r10, 7r10])]) :-
    findall(F, factor_transito(_, F), Ts),
    findall(F, factor_pendiente(_, F), Ps).

test(conecta_dos_sentidos, all(B == [puerto_quieto, ribera_honda])) :-
    conecta(B, piedra_mora, _, _, _, _).

test(conecta_vecinos, all(B == [ribera_honda, puerto_quieto])) :-
    conecta(piedra_mora, B, _, _, _, _).

test(km_tramo, [true(Km == 26)]) :-
    km_tramo(piedra_mora, puerto_quieto, Km).

test(km_tramo_sin_tramo, [fail]) :-
    km_tramo(pradera_alta, ermita_vieja, _).

test(agregar_a_frontera, [true(P-C == 1-[b])]) :-
    list_to_heap([5-[a]], F0),
    agregar_a_frontera(1-[b], F0, F),
    get_from_heap(F, P, C, _).

test(es) :-
    es(a, a).

test(es_distinto, [fail]) :-
    es(a, b).

test(paso_del_horario, [true(P == '8:33'-puerto_quieto)]) :-
    paso_del_horario(480, puerto_quieto-360r11, P).

test(minutos_del_dia, [true(M == 525)]) :-
    minutos_del_dia(8:45, M).

test(minutos_del_dia_minuto_invalido, [error(type_error(hora, 8:60))]) :-
    minutos_del_dia(8:60, _).

test(hora_escrita, [true(H == '8:05')]) :-
    hora_escrita(485, H).

test(hora_escrita_redondea, [true(H == '8:33')]) :-
    hora_escrita(480 + 360r11, H).

test(hora_escrita_medianoche, [true(H == '0:10')]) :-
    hora_escrita(1450, H).

:- end_tests(rutas).
