:- encoding(utf8).

% Capítulo 47 - Versión 6: un planificador de rutas con horario.
%
% El mapa es una lista de tramos entre ciudades, cada uno con su longitud
% en kilómetros, el tipo de calzada, el tránsito y la pendiente; el mapa es
% inventado para el ejemplo, con sus ciudades y sus datos. La velocidad de
% un tramo es la de su calzada multiplicada por un factor de tránsito y
% otro de pendiente, todos racionales, así que el tiempo de cada tramo, en
% minutos, es un racional exacto: el redondeo se hace una sola vez, al
% escribir el horario.
% costo_uniforme/4 es la búsqueda de costo uniforme del capítulo 40, con
% un montículo de library(heaps) como frontera y el problema como dos
% argumentos: la meta y la relación de sucesores con su costo.
%
%?- ruta(pradera_alta, ermita_vieja, Minutos, Ciudades).
%?- horario(pradera_alta, ermita_vieja, 8:00, H).
%?- ruta_mas_corta(pradera_alta, ermita_vieja, Km, Ciudades).

:- use_module(library(apply)).
:- use_module(library(error)).
:- use_module(library(heaps)).
:- use_module(library(lists)).
:- use_module(library(ordsets)).

% tramo(A, B, Km, Calzada, Transito, Pendiente): un camino de Km
% kilómetros une A y B, en los dos sentidos.
tramo(pradera_alta, puerto_quieto, 36, autopista, alto, llano).
tramo(pradera_alta, arroyo_pinto, 30, pavimento, medio, ondulado).
tramo(pradera_alta, campo_lindero, 51, autopista, medio, llano).
tramo(pradera_alta, loma_tendida, 39, autopista, medio, llano).
tramo(puerto_quieto, piedra_mora, 26, pavimento, alto, ondulado).
tramo(puerto_quieto, loma_tendida, 38, pavimento, medio, ondulado).
tramo(arroyo_pinto, alto_del_cardo, 40, ripio, bajo, montana).
tramo(piedra_mora, ribera_honda, 20, pavimento, medio, ondulado).
tramo(ribera_honda, alto_del_cardo, 10, pavimento, bajo, ondulado).
tramo(alto_del_cardo, ermita_vieja, 17, pavimento, bajo, llano).
tramo(campo_lindero, ermita_vieja, 75, ripio, bajo, llano).

% velocidad(Calzada, V): en una calzada de ese tipo se viaja a V km/h
% sin tránsito y en llano.
velocidad(autopista, 110).
velocidad(pavimento, 80).
velocidad(ripio, 50).

% factor_transito(T, F): el tránsito T multiplica la velocidad por F.
factor_transito(bajo, 1).
factor_transito(medio, 4r5).
factor_transito(alto, 3r5).

% factor_pendiente(P, F): la pendiente P multiplica la velocidad por F.
factor_pendiente(llano, 1).
factor_pendiente(ondulado, 9r10).
factor_pendiente(montana, 7r10).

%!  conecta(?A, ?B, ?Km, ?Calzada, ?Transito, ?Pendiente) is nondet.
%
%   Un tramo de Km kilómetros va de A a B, en cualquiera de los dos
%   sentidos en que está escrito.
conecta(A, B, Km, C, T, P) :-
    tramo(A, B, Km, C, T, P).
conecta(A, B, Km, C, T, P) :-
    tramo(B, A, Km, C, T, P).

%!  minutos_tramo(?A, ?B, -Minutos:rational) is nondet.
%
%   Ir de A a B por un tramo directo lleva Minutos, un número exacto.
minutos_tramo(A, B, Minutos) :-
    conecta(A, B, Km, Calzada, Transito, Pendiente),
    velocidad(Calzada, V0),
    factor_transito(Transito, FT),
    factor_pendiente(Pendiente, FP),
    Minutos is Km * 60 rdiv (V0 * FT * FP).

%!  km_tramo(?A, ?B, -Km:integer) is nondet.
%
%   Un tramo directo de Km kilómetros une A y B.
km_tramo(A, B, Km) :-
    conecta(A, B, Km, _, _, _).

%!  costo_uniforme(+Inicio, :Meta, :Sucesor, -Camino:list) is semidet.
%
%   Camino es un camino de menor costo desde Inicio hasta un estado que
%   cumple call(Meta, Estado), donde call(Sucesor, E, E1, Costo) da los
%   sucesores de E con el costo de cada paso, que no es negativo. Camino es
%   una lista de pares Estado-Costo, con el costo acumulado desde Inicio,
%   en el orden del recorrido. Falla si ningún estado alcanzable es meta.
costo_uniforme(Inicio, Meta, Sucesor, Camino) :-
    list_to_heap([0-[Inicio-0]], Frontera),
    costo_uniforme(Frontera, [], Meta, Sucesor, Invertido),
    reverse(Invertido, Camino).

%!  costo_uniforme(+Frontera, +Cerrados:list, :Meta, :Sucesor,
%!                 -Invertido:list) is semidet.
%
%   Invertido es el camino de menor costo hasta una meta, del último
%   estado al primero. Frontera es un montículo de caminos invertidos,
%   ordenado por su costo, y Cerrados es el conjunto ordenado de los
%   estados ya expandidos, que no se vuelven a expandir.
costo_uniforme(Frontera0, Cerrados, Meta, Sucesor, Invertido) :-
    get_from_heap(Frontera0, C, [E-C|Resto], Frontera1),
    (   call(Meta, E)
    ->  Invertido = [E-C|Resto]
    ;   ord_memberchk(E, Cerrados)
    ->  costo_uniforme(Frontera1, Cerrados, Meta, Sucesor, Invertido)
    ;   findall(C1-[E1-C1, E-C|Resto],
                ( call(Sucesor, E, E1, Paso),
                  C1 is C + Paso ),
                Hijos),
        foldl(agregar_a_frontera, Hijos, Frontera1, Frontera),
        ord_add_element(Cerrados, E, Cerrados1),
        costo_uniforme(Frontera, Cerrados1, Meta, Sucesor, Invertido)
    ).

%!  agregar_a_frontera(+Par:pair, +Frontera0, -Frontera) is det.
%
%   Frontera es Frontera0 con el camino del Par Costo-Camino agregado con
%   prioridad Costo.
agregar_a_frontera(Costo-Camino, Frontera0, Frontera) :-
    add_to_heap(Frontera0, Costo, Camino, Frontera).

%!  es(+X, +Y) is semidet.
%
%   X e Y son el mismo término. Sirve como meta de costo_uniforme/4.
es(X, Y) :-
    X == Y.

%!  ruta(+Origen:atom, +Destino:atom, -Minutos:rational,
%!       -Ciudades:list(atom)) is semidet.
%
%   Ciudades es el recorrido más rápido de Origen a Destino, que lleva
%   Minutos. Falla si no hay ningún recorrido.
ruta(Origen, Destino, Minutos, Ciudades) :-
    must_be(atom, Origen),
    must_be(atom, Destino),
    costo_uniforme(Origen, es(Destino), minutos_tramo, Camino),
    last(Camino, Destino-Minutos),
    pairs_keys(Camino, Ciudades).

%!  ruta_mas_corta(+Origen:atom, +Destino:atom, -Km:integer,
%!                 -Ciudades:list(atom)) is semidet.
%
%   Ciudades es el recorrido de menos kilómetros de Origen a Destino, que
%   tiene Km kilómetros. Falla si no hay ningún recorrido.
ruta_mas_corta(Origen, Destino, Km, Ciudades) :-
    must_be(atom, Origen),
    must_be(atom, Destino),
    costo_uniforme(Origen, es(Destino), km_tramo, Camino),
    last(Camino, Destino-Km),
    pairs_keys(Camino, Ciudades).

%!  horario(+Origen:atom, +Destino:atom, +Salida, -Horario:list) is semidet.
%
%   Horario es la lista de pares Hora-Ciudad del recorrido más rápido de
%   Origen a Destino, saliendo a la hora Salida, escrita H:M. Cada Hora es
%   un átomo 'H:MM' redondeado al minuto.
horario(Origen, Destino, Salida, Horario) :-
    minutos_del_dia(Salida, Inicio),
    must_be(atom, Origen),
    must_be(atom, Destino),
    costo_uniforme(Origen, es(Destino), minutos_tramo, Camino),
    maplist(paso_del_horario(Inicio), Camino, Horario).

%!  paso_del_horario(+Inicio:integer, +Par:pair, -Paso:pair) is det.
%
%   Paso es Hora-Ciudad para el Par Ciudad-Minutos: la hora a la que se
%   llega a Ciudad, Minutos después del minuto Inicio del día.
paso_del_horario(Inicio, Ciudad-Minutos, Hora-Ciudad) :-
    T is Inicio + Minutos,
    hora_escrita(T, Hora).

%!  minutos_del_dia(+Hora, -Minutos:integer) is det.
%
%   Minutos es la cantidad de minutos desde las 0:00 hasta Hora, escrita
%   H:M. Produce un error de tipo si Hora no es una hora del día.
minutos_del_dia(Hora, Minutos) :-
    (   Hora = H:M,
        integer(H),
        integer(M),
        between(0, 23, H),
        between(0, 59, M)
    ->  Minutos is H * 60 + M
    ;   type_error(hora, Hora)
    ).

%!  hora_escrita(+Minutos:number, -Hora:atom) is det.
%
%   Hora es el átomo 'H:MM' del minuto del día más cercano a Minutos,
%   contados desde las 0:00; pasada la medianoche, vuelve a empezar.
hora_escrita(Minutos, Hora) :-
    T is round(Minutos) mod (24 * 60),
    H is T // 60,
    M is T mod 60,
    format(atom(Hora), "~d:~|~`0t~d~2+", [H, M]).
