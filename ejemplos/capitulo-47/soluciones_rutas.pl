:- encoding(utf8).

% Capítulo 47 - Soluciones de los ejercicios 11 y 12: las rutas.
%
% solo-local: carga rutas.pl, y SWISH no carga otros archivos.
%
%?- horario_con_balsa(pradera_alta, ribera_honda, 8:00, H).
%?- horario_con_balsa(pradera_alta, ribera_honda, 8:20, H).
%?- ruta_evitando(pradera_alta, ermita_vieja, [autopista], M, Cs).

:- ensure_loaded(rutas).

:- meta_predicate
    costo_uniforme_t(+, 1, 4, -),
    costo_uniforme_t(+, +, 1, 4, -),
    sin_costo(3, +, +, -, -).

% Ejercicio 11

% salida(A, B, Hora, Minutos): una balsa sale de A hacia B a la Hora y
% llega Minutos después.
salida(puerto_quieto, ribera_honda, 8:45, 20).
salida(puerto_quieto, ribera_honda, 9:45, 20).
salida(puerto_quieto, ribera_honda, 10:45, 20).

%!  costo_uniforme_t(+Inicio, :Meta, :Sucesor, -Camino:list) is semidet.
%
%   Como costo_uniforme/4, pero call(Sucesor, E, C, E1, Paso) recibe
%   también el costo C acumulado hasta E. El camino es de costo mínimo si
%   llegar más tarde a un estado nunca permite llegar antes al siguiente.
costo_uniforme_t(Inicio, Meta, Sucesor, Camino) :-
    list_to_heap([0-[Inicio-0]], Frontera),
    costo_uniforme_t(Frontera, [], Meta, Sucesor, Invertido),
    reverse(Invertido, Camino).

%!  costo_uniforme_t(+Frontera, +Cerrados:list, :Meta, :Sucesor,
%!                   -Invertido:list) is semidet.
%
%   Invertido es el camino de menor costo hasta una meta, del último
%   estado al primero, como en costo_uniforme/5.
costo_uniforme_t(Frontera0, Cerrados, Meta, Sucesor, Invertido) :-
    get_from_heap(Frontera0, C, [E-C|Resto], Frontera1),
    (   call(Meta, E)
    ->  Invertido = [E-C|Resto]
    ;   ord_memberchk(E, Cerrados)
    ->  costo_uniforme_t(Frontera1, Cerrados, Meta, Sucesor, Invertido)
    ;   findall(C1-[E1-C1, E-C|Resto],
                ( call(Sucesor, E, C, E1, Paso),
                  C1 is C + Paso ),
                Hijos),
        foldl(agregar_a_frontera, Hijos, Frontera1, Frontera),
        ord_add_element(Cerrados, E, Cerrados1),
        costo_uniforme_t(Frontera, Cerrados1, Meta, Sucesor, Invertido)
    ).

%!  sin_costo(:Sucesor, +E, +C, -E1, -Paso) is nondet.
%
%   Adapta un sucesor de costo_uniforme/4, que no usa el costo C:
%   costo_uniforme/4 es costo_uniforme_t/4 con sin_costo(Sucesor).
sin_costo(Sucesor, E, _, E1, Paso) :-
    call(Sucesor, E, E1, Paso).

%!  sucesor_con_balsa(+Salida:integer, +A:atom, +C:number, -B:atom,
%!                    -Paso:number) is nondet.
%
%   Desde A, a la que se llega C minutos después del minuto Salida del
%   día, se pasa a B en Paso minutos: por un tramo de ruta, o esperando
%   una balsa que sale después de la llegada y viajando en ella.
sucesor_con_balsa(_, A, _, B, Paso) :-
    minutos_tramo(A, B, Paso).
sucesor_con_balsa(Salida, A, C, B, Paso) :-
    salida(A, B, Hora, Viaje),
    minutos_del_dia(Hora, Parte),
    Llegada is Salida + C,
    Parte >= Llegada,
    Paso is Parte - Llegada + Viaje.

%!  horario_con_balsa(+Origen:atom, +Destino:atom, +Salida,
%!                    -Horario:list) is semidet.
%
%   Horario es el horario del recorrido más rápido de Origen a Destino
%   saliendo a la hora Salida, por ruta o en balsa.
horario_con_balsa(Origen, Destino, Salida, Horario) :-
    minutos_del_dia(Salida, Inicio),
    must_be(atom, Origen),
    must_be(atom, Destino),
    costo_uniforme_t(Origen, es(Destino), sucesor_con_balsa(Inicio),
                     Camino),
    maplist(paso_del_horario(Inicio), Camino, Horario).

% Ejercicio 12

%!  minutos_evitando(+Calzadas:list(atom), ?A, ?B, -Minutos) is nondet.
%
%   Ir de A a B por un tramo directo lleva Minutos, y el tramo no tiene
%   ninguna de las Calzadas.
minutos_evitando(Calzadas, A, B, Minutos) :-
    conecta(A, B, _, Calzada, _, _),
    \+ memberchk(Calzada, Calzadas),
    once(minutos_tramo(A, B, Minutos)).

%!  ruta_evitando(+Origen:atom, +Destino:atom, +Calzadas:list(atom),
%!                -Minutos:rational, -Ciudades:list(atom)) is semidet.
%
%   Ciudades es el recorrido más rápido de Origen a Destino que no usa
%   tramos con ninguna de las Calzadas, y lleva Minutos. Falla si no hay
%   ninguno.
ruta_evitando(Origen, Destino, Calzadas, Minutos, Ciudades) :-
    must_be(atom, Origen),
    must_be(atom, Destino),
    must_be(list(atom), Calzadas),
    costo_uniforme(Origen, es(Destino), minutos_evitando(Calzadas),
                   Camino),
    last(Camino, Destino-Minutos),
    pairs_keys(Camino, Ciudades).
