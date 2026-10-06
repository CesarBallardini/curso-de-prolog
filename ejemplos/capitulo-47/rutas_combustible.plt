:- encoding(utf8).

:- begin_tests(rutas_combustible).

test(dos_cargas, [true(Es == [ en(pradera_alta, 60), en(puerto_quieto, 24),
                               en(puerto_quieto, 60), en(piedra_mora, 34),
                               en(ribera_honda, 14), en(ribera_honda, 60),
                               en(alto_del_cardo, 50),
                               en(ermita_vieja, 33) ])]) :-
    ruta_con_carga(pradera_alta, ermita_vieja, 60, _, Es).

% Dos cargas de 15 minutos sobre el recorrido más rápido de la versión 6.
test(minutos, [true(M =:= M0 + 30)]) :-
    ruta_con_carga(pradera_alta, ermita_vieja, 60, M, _),
    ruta(pradera_alta, ermita_vieja, M0, _).

test(horario, [true(H == [ '8:00'-pradera_alta, '8:33'-puerto_quieto,
                           '8:48'-carga(puerto_quieto), '9:24'-piedra_mora,
                           '9:45'-ribera_honda, '10:00'-carga(ribera_honda),
                           '10:08'-alto_del_cardo,
                           '10:21'-ermita_vieja ])]) :-
    horario_con_carga(pradera_alta, ermita_vieja, 60, 8:00, H).

% Con autonomía suficiente, el horario es el de la versión 6.
test(sin_cargas, [true(H1 == H2)]) :-
    horario_con_carga(pradera_alta, ermita_vieja, 200, 8:00, H1),
    horario(pradera_alta, ermita_vieja, 8:00, H2).

test(una_carga, [true(Cargas == [carga(puerto_quieto)])]) :-
    horario_con_carga(pradera_alta, ermita_vieja, 80, 8:00, H),
    findall(carga(C), member(_-carga(C), H), Cargas).

% Con 40 km no hay recorrido: desde la última estación de cada camino a
% ermita_vieja, la distancia supera la autonomía.
test(no_alcanza, [fail]) :-
    ruta_con_carga(pradera_alta, ermita_vieja, 40, _, _).

test(autonomia, [error(type_error(positive_integer, 0))]) :-
    ruta_con_carga(pradera_alta, ermita_vieja, 0, _, _).

test(estaciones, [true(length(Es, 5))]) :-
    findall(E, estacion(E), Es).

test(minutos_de_carga, [true(M == 15)]) :-
    minutos_de_carga(M).

% Desde Puerto Quieto con 30 km: el tramo de 26 km a Piedra Mora, y la
% carga.
test(sucesores, all(S == [en(piedra_mora, 4), en(puerto_quieto, 60)])) :-
    sucesor_con_carga(60, en(puerto_quieto, 30), S, _).

% Con el tanque lleno no se carga.
test(sin_carga_lleno, all(S == [en(puerto_quieto, 24), en(arroyo_pinto, 30),
                                en(campo_lindero, 9),
                                en(loma_tendida, 21)])) :-
    sucesor_con_carga(60, en(pradera_alta, 60), S, _).

% Sin estación tampoco.
test(sin_estacion, all(S == [en(ribera_honda, 0)])) :-
    sucesor_con_carga(60, en(piedra_mora, 20), S, _).

test(llegada) :-
    llegada(ermita_vieja, en(ermita_vieja, 3)).

test(llegada_otra, [fail]) :-
    llegada(ermita_vieja, en(piedra_mora, 3)).

test(pasos_con_carga, [true(H == ['8:00'-a, '8:10'-b, '8:25'-carga(b)])]) :-
    pasos_con_carga([en(a, 5)-0, en(b, 0)-10, en(b, 5)-25], ninguna, 480, H).

test(pasos_con_carga_vacio, [true(H == [])]) :-
    pasos_con_carga([], ninguna, 480, H).

:- end_tests(rutas_combustible).
