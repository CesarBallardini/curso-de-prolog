:- encoding(utf8).

% Capítulo 12 - Ejercicio 12: campeonato de selecciones.
%
% Las dos listas se arman con la estrategia para recolectar soluciones del
% capítulo 10; la condición "ganó todos los partidos que jugó" se escribe
% con doble negación.
%
%?- jugadores_victoriosos(Js).
%?- partidos_jugados(Ps).

% seleccionado(Jugador, Seleccion): Jugador, con su apellido y su número,
% pertenece a Seleccion.
seleccionado(jugador("Messi", 10), argentina).
seleccionado(jugador("Karacic", 5), australia).
seleccionado(jugador("Estrada", 11), ecuador).
seleccionado(jugador("Mendy", 6), senegal).

% partido(NroPartido, Eq1, Eq2, GolesEq1, GolesEq2): en el partido
% NroPartido, Eq1 hizo GolesEq1 goles y Eq2 hizo GolesEq2.
partido(35, ecuador, senegal, 1, 2).
partido(21, tunez, australia, 0, 1).
partido(61, argentina, croacia, 3, 0).
partido(50, argentina, australia, 2, 1).
partido(18, qatar, senegal, 1, 3).
partido(8, argentina, arabia, 1, 2).
partido(1, qatar, ecuador, 0, 2).
partido(39, polonia, argentina, 0, 2).

% presencia(NroPartido, Jugador): Jugador jugó el partido NroPartido.
presencia(21, jugador("Karacic", 5)).
presencia(35, jugador("Mendy", 6)).
presencia(8, jugador("Messi", 10)).
presencia(61, jugador("Messi", 10)).
presencia(1, jugador("Estrada", 11)).
presencia(39, jugador("Messi", 10)).
presencia(18, jugador("Mendy", 6)).
presencia(50, jugador("Messi", 10)).

%!  gano(?Seleccion, ?NroPartido) is nondet.
%
%   Seleccion ganó el partido NroPartido, como primer o como segundo equipo.
gano(S, N) :-
    partido(N, S, _, G1, G2),
    G1 > G2.
gano(S, N) :-
    partido(N, _, S, G1, G2),
    G2 > G1.

%!  victorioso(?Apellido) is nondet.
%
%   El jugador de apellido Apellido ganó todos los partidos que jugó: no
%   jugó ningún partido que su selección no haya ganado.
victorioso(Apellido) :-
    seleccionado(jugador(Apellido, Numero), Seleccion),
    \+ ( presencia(N, jugador(Apellido, Numero)),
         \+ gano(Seleccion, N) ).

%!  jugadores_victoriosos(-Js) is det.
%
%   Js es la lista de los apellidos de los jugadores que ganaron todos los
%   partidos que jugaron. Js debe llegar libre: el corte de
%   armar_victoriosos/2 es rojo.
jugadores_victoriosos(Js) :-
    armar_victoriosos(Js, []).

%!  armar_victoriosos(-Js, +YaIncluidas) is det.
%
%   Js es la lista de los jugadores victoriosos que no están en YaIncluidas.
armar_victoriosos([J|Js], YaIncluidas) :-
    victorioso(J),
    \+ member(J, YaIncluidas),
    !,
    append(YaIncluidas, [J], YaIncluidasConJ),
    armar_victoriosos(Js, YaIncluidasConJ).
armar_victoriosos([], _).

%!  partidos_jugados(-Ps) is det.
%
%   Ps es la lista de los partidos, cada uno [NroPartido, Eq1, Eq2], en orden
%   ascendente de NroPartido. Ps debe llegar libre.
partidos_jugados(Ps) :-
    armar_partidos(Ps, []).

%!  armar_partidos(-Ps, +YaIncluidas) is det.
%
%   Ps es la lista ordenada de los partidos que no están en YaIncluidas. El
%   partido elegido es el de menor número entre los que todavía no se
%   recolectaron.
armar_partidos([[N, E1, E2]|Ps], YaIncluidas) :-
    partido(N, E1, E2, _, _),
    \+ member([N, E1, E2], YaIncluidas),
    \+ ( partido(M, _, _, _, _),
         M < N,
         \+ member([M, _, _], YaIncluidas) ),
    !,
    append(YaIncluidas, [[N, E1, E2]], YaIncluidasConPartido),
    armar_partidos(Ps, YaIncluidasConPartido).
armar_partidos([], _).
