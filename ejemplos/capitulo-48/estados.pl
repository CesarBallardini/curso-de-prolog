:- encoding(utf8).

% Capítulo 48 - Versión 6: los estados alcanzables.
%
% Ejecutar un circuito secuencial recorre una sola sucesión de entradas.
% Los estados a los que puede llegar con cualquier sucesión forman un grafo:
% un arco por cada estado, cada combinación de entradas y el estado
% siguiente. El grafo tiene ciclos —un contador vuelve a empezar—, y la
% relación de alcance con la recursión a la izquierda termina porque está
% tabulada. Sobre los estados alcanzables se verifica una propiedad para
% toda entrada, sin elegir las sucesiones a mano.
%
% solo-local: carga los módulos circuitos y secuenciales, y SWISH no admite
% módulos propios.
%
%?- alcanzables(registro4, [0, 0, 0, 0], Es), length(Es, N).
%?- grafo(paridad, [0], Arcos).

:- module(estados,
          [ transicion/5,
            alcanzable/3,
            alcanzable_sin_tabla/3,
            alcanzables/3,
            grafo/3,
            siempre/3,
            distancia/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(circuitos).
:- use_module(secuenciales).

%!  transicion(+Nombre, +Estado0:list, ?Entradas:list, ?Salidas:list,
%!             ?Estado:list) is nondet.
%
%   Como paso/5, pero con las Entradas enumeradas cuando llegan libres: un
%   arco del grafo de estados del circuito secuencial Nombre.
transicion(Nombre, Estado0, Entradas, Salidas, Estado) :-
    paso(Nombre, Estado0, Entradas, Salidas, Estado),
    maplist(bit, Entradas).

%!  alcanzable_sin_tabla(+Nombre, +Estado0:list, ?Estado:list) is nondet.
%
%   El circuito Nombre pasa de Estado0 a Estado en uno o más pulsos. Sin
%   tabla, la recursión a la izquierda no termina.
alcanzable_sin_tabla(Nombre, Estado0, Estado) :-
    transicion(Nombre, Estado0, _, _, Estado).
alcanzable_sin_tabla(Nombre, Estado0, Estado) :-
    alcanzable_sin_tabla(Nombre, Estado0, Estado1),
    transicion(Nombre, Estado1, _, _, Estado).

:- table alcanzable/3.

%!  alcanzable(+Nombre, +Estado0:list, ?Estado:list) is nondet.
%
%   La misma relación, tabulada: cada estado una vez, y la consulta
%   termina.
alcanzable(Nombre, Estado0, Estado) :-
    transicion(Nombre, Estado0, _, _, Estado).
alcanzable(Nombre, Estado0, Estado) :-
    alcanzable(Nombre, Estado0, Estado1),
    transicion(Nombre, Estado1, _, _, Estado).

%!  alcanzables(+Nombre, +Estado0:list, -Estados:list) is det.
%
%   Estados son Estado0 y los estados alcanzables desde él, ordenados.
alcanzables(Nombre, Estado0, Estados) :-
    findall(E, alcanzable(Nombre, Estado0, E), Es),
    sort([Estado0|Es], Estados).

%!  grafo(+Nombre, +Estado0:list, -Arcos:list) is det.
%
%   Arcos son los arcos E-Entradas/Salidas-E1 que salen de los estados
%   alcanzables desde Estado0, incluido él.
grafo(Nombre, Estado0, Arcos) :-
    alcanzables(Nombre, Estado0, Estados),
    findall(E-Es/Ss-E1,
            ( member(E, Estados),
              transicion(Nombre, E, Es, Ss, E1) ),
            Arcos).

:- meta_predicate siempre(+, +, 4).

%!  siempre(+Nombre, +Estado0:list, :Condicion) is semidet.
%
%   Cada arco E-Entradas/Salidas-E1 alcanzable desde Estado0 cumple
%   call(Condicion, E, Entradas, Salidas, E1).
siempre(Nombre, Estado0, Condicion) :-
    grafo(Nombre, Estado0, Arcos),
    forall(member(E-Es/Ss-E1, Arcos),
           call(Condicion, E, Es, Ss, E1)).

%!  distancia(+Xs:list, +Ys:list, -D:integer) is det.
%
%   D es la cantidad de posiciones en que difieren las listas de bits Xs e
%   Ys, de la misma longitud.
distancia(Xs, Ys, D) :-
    foldl([X, Y, D0, D1]>>(D1 is D0 + abs(X - Y)), Xs, Ys, 0, D).
