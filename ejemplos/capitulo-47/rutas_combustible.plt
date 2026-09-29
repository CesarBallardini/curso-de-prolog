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

:- end_tests(rutas_combustible).
