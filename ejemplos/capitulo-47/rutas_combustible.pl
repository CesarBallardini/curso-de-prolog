:- encoding(utf8).

% Capítulo 47 - Versión 7: el combustible.
%
% Un vehículo recorre, con el tanque lleno, una cantidad fija de
% kilómetros, su autonomía, y solo carga combustible en las ciudades que
% tienen una estación. La ciudad ya no alcanza como estado de la búsqueda:
% el estado es en(Ciudad, Restantes), con los kilómetros que el tanque
% todavía permite recorrer. Un sucesor recorre un tramo que no supera los
% kilómetros restantes, o carga combustible en una estación, lo que lleva
% 15 minutos y llena el tanque. La búsqueda es la misma costo_uniforme/4 de
% la versión 6: solo cambian el estado, la meta y los sucesores.
%
% solo-local: carga rutas.pl, y SWISH no carga otros archivos.
%
%?- ruta_con_carga(pradera_alta, ermita_vieja, 60, Minutos, Estados).
%?- horario_con_carga(pradera_alta, ermita_vieja, 60, 8:00, H).
%?- ruta_con_carga(pradera_alta, ermita_vieja, 40, Minutos, Estados).

:- ensure_loaded(rutas).

% estacion(Ciudad): en Ciudad se puede cargar combustible.
estacion(pradera_alta).
estacion(puerto_quieto).
estacion(loma_tendida).
estacion(campo_lindero).
estacion(ribera_honda).

% minutos_de_carga(Minutos): cargar combustible lleva Minutos.
minutos_de_carga(15).

%!  sucesor_con_carga(+Autonomia:integer, +Estado, -Siguiente,
%!                    -Minutos:rational) is nondet.
%
%   Desde Estado, en(Ciudad, Restantes), se pasa a Siguiente en Minutos:
%   por un tramo no más largo que Restantes, o cargando combustible en una
%   estación hasta tener Autonomia kilómetros por recorrer.
sucesor_con_carga(_, en(A, R), en(B, R1), Minutos) :-
    km_tramo(A, B, Km),
    Km =< R,
    R1 is R - Km,
    once(minutos_tramo(A, B, Minutos)).
sucesor_con_carga(Autonomia, en(A, R), en(A, Autonomia), Minutos) :-
    R < Autonomia,
    estacion(A),
    minutos_de_carga(Minutos).

%!  llegada(+Destino:atom, +Estado) is semidet.
%
%   Estado está en Destino, con cualquier cantidad de combustible.
llegada(Destino, en(Destino, _)).

%!  ruta_con_carga(+Origen:atom, +Destino:atom, +Autonomia:integer,
%!                 -Minutos:rational, -Estados:list) is semidet.
%
%   Estados es el recorrido más rápido de Origen a Destino para un
%   vehículo de Autonomia kilómetros que sale con el tanque lleno, y lleva
%   Minutos contando las cargas. Cada estado es en(Ciudad, Restantes).
%   Falla si ningún recorrido lo permite.
ruta_con_carga(Origen, Destino, Autonomia, Minutos, Estados) :-
    must_be(atom, Origen),
    must_be(atom, Destino),
    must_be(positive_integer, Autonomia),
    costo_uniforme(en(Origen, Autonomia), llegada(Destino),
                   sucesor_con_carga(Autonomia), Camino),
    last(Camino, _-Minutos),
    pairs_keys(Camino, Estados).

%!  horario_con_carga(+Origen:atom, +Destino:atom, +Autonomia:integer,
%!                    +Salida, -Horario:list) is semidet.
%
%   Horario es la lista de pares Hora-Paso del recorrido de
%   ruta_con_carga/5 saliendo a la hora Salida: Paso es la Ciudad a la que
%   se llega a esa Hora, o carga(Ciudad) si a esa Hora termina una carga.
horario_con_carga(Origen, Destino, Autonomia, Salida, Horario) :-
    minutos_del_dia(Salida, Inicio),
    must_be(atom, Origen),
    must_be(atom, Destino),
    must_be(positive_integer, Autonomia),
    costo_uniforme(en(Origen, Autonomia), llegada(Destino),
                   sucesor_con_carga(Autonomia), Camino),
    pasos_con_carga(Camino, ninguna, Inicio, Horario).

%!  pasos_con_carga(+Camino:list, +Anterior, +Inicio:integer,
%!                  -Horario:list) is det.
%
%   Horario tiene un par Hora-Paso por cada par en(Ciudad, _)-Minutos de
%   Camino. Paso es carga(Ciudad) si Ciudad es la misma que la Anterior, y
%   Ciudad si no.
pasos_con_carga([], _, _, []).
pasos_con_carga([en(C, _)-M|Resto], Anterior, Inicio, [Hora-Paso|Pasos]) :-
    T is Inicio + M,
    hora_escrita(T, Hora),
    (   C == Anterior
    ->  Paso = carga(C)
    ;   Paso = C
    ),
    pasos_con_carga(Resto, C, Inicio, Pasos).
