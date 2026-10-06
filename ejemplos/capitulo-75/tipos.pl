:- encoding(utf8).

% Capítulo 75 - Versión 7: una evaluación por clase de simetría.
%
% Si Q = S o P o S^-1 (Q es la conjugada de P por la permutación S), el
% patrón de Q es el de P con las filas y las columnas reordenadas por S: el
% mismo total y las mismas filas distintas. Dos permutaciones son
% conjugadas exactamente cuando tienen el mismo tipo, la lista ordenada de
% las longitudes de sus ciclos. El tipo es la forma canónica de la clase:
% maximo_por_tipo/3 recorre los desarreglos, como enigma.pl, pero lleva un
% registro de los tipos ya vistos y arma y evalúa un solo patrón por tipo.
%
% solo-local: carga enigma.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- tipo([2, 3, 1, 5, 4], T).
%?- conjugada([2, 1, 3], [3, 1, 2], Q).
%?- maximo_por_tipo(8, Total, Tipos).

:- ensure_loaded(enigma).
:- use_module(library(ordsets)).

%!  ciclos(+P:list(integer), -Ciclos:list(list(integer))) is det.
%
%   Ciclos son los ciclos de la permutación P, cada uno empezando por su
%   menor elemento, en el orden de esos elementos.
ciclos(P, Ciclos) :-
    length(P, N),
    numlist(1, N, Pendientes),
    ciclos(Pendientes, P, Ciclos).

%!  ciclos(+Pendientes:list, +P:list, -Ciclos:list) is det.
%
%   Ciclos son los ciclos de P que pasan por los elementos de Pendientes.
ciclos([], _, []).
ciclos([I|Pendientes], P, [Ciclo|Ciclos]) :-
    ciclo_desde(I, I, P, Ciclo),
    sort(Ciclo, Visitados),
    ord_subtract(Pendientes, Visitados, Resto),
    ciclos(Resto, P, Ciclos).

%!  ciclo_desde(+Inicio:integer, +I:integer, +P:list, -Ciclo:list) is det.
%
%   Ciclo es I seguido de sus imágenes sucesivas por P, hasta volver a
%   Inicio sin incluirlo.
ciclo_desde(Inicio, I, P, [I|Ciclo]) :-
    nth1(I, P, J),
    (   J =:= Inicio
    ->  Ciclo = []
    ;   ciclo_desde(Inicio, J, P, Ciclo)
    ).

%!  tipo(+P:list(integer), -Tipo:list(integer)) is det.
%
%   Tipo es la lista de las longitudes de los ciclos de P, de menor a
%   mayor: la forma canónica de P bajo la conjugación.
tipo(P, Tipo) :-
    ciclos(P, Ciclos),
    maplist(length, Ciclos, Longitudes),
    msort(Longitudes, Tipo).

%!  conjugada(+P:list(integer), +S:list(integer), -Q:list(integer)) is det.
%
%   Q es S o P o S^-1: lleva S(I) a S(P(I)). Es P con sus elementos
%   renombrados por S.
conjugada(P, S, Q) :-
    length(P, N),
    numlist(1, N, Is),
    maplist(imagen_renombrada(P, S), Is, Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Q).

%!  imagen_renombrada(+P:list, +S:list, +I:integer, -Par) is det.
%
%   Par es S(I)-S(P(I)).
imagen_renombrada(P, S, I, SI-SPI) :-
    nth1(I, S, SI),
    nth1(I, P, PI),
    nth1(PI, S, SPI).

%!  maximo_por_tipo(+N:integer, -Total:integer, -Tipos:list) is semidet.
%
%   Total es la mayor suma de un tablero de N por N; Tipos es la lista de
%   pares Tipo-T, uno por cada tipo de desarreglo cuyo patrón tiene filas
%   distintas, con el total T de su patrón. Arma un patrón por tipo. Falla
%   si ningún tipo da filas distintas.
maximo_por_tipo(N, Total, Tipos) :-
    desarreglos(N, Ps),
    foldl(visitar, Ps, []-[], _-Tipos0),
    reverse(Tipos0, Tipos),
    pairs_values(Tipos, Totales),
    max_list(Totales, Total).

%!  visitar(+P:list, +Estado0, -Estado) is det.
%
%   Estado es Vistos-Tipos: Vistos es el conjunto ordenado de los tipos
%   ya considerados y Tipos los pares Tipo-T hallados, el último primero.
%   Si el tipo de P ya está en Vistos, P no se evalúa.
visitar(P, Vistos0-Tipos0, Vistos-Tipos) :-
    tipo(P, Tipo),
    (   ord_memberchk(Tipo, Vistos0)
    ->  Vistos = Vistos0,
        Tipos = Tipos0
    ;   ord_add_element(Vistos0, Tipo, Vistos),
        (   matriz_patron(P, M),
            filas_distintas(M)
        ->  evaluar(M, T),
            Tipos = [Tipo-T|Tipos0]
        ;   Tipos = Tipos0
        )
    ).
