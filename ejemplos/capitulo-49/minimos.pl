:- encoding(utf8).

% Capítulo 49 - Versión 3: diagnósticos mínimos.
%
% Un diagnóstico es mínimo si ningún otro supone fallas en un subconjunto
% propio de sus compuertas. por_filtro/4 los obtiene como Flach: genera
% todos los diagnósticos y descarta los que contienen a otro. La conducta
% acotada/7 agrega al intérprete un presupuesto de fallas, que poda la
% búsqueda en cuanto una rama supone demasiadas; con él, mas_simples/4
% prueba presupuestos crecientes hasta encontrar diagnósticos, y
% minimos/5 da los mínimos con a lo sumo K fallas.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- por_filtro(fuerte, sumador, [[0, 0, 1]-[0, 1]], Ds).
%?- mas_simples(fuerte, sumador, [[1, 1, 1]-[0, 0]], Ds).
%?- minimos(fuerte, sumador3, [[1, 1, 0, 1, 0, 1]-[0, 1, 0, 1]], 2, Ds).

:- module(minimos,
          [ por_filtro/4,
            acotada/7,
            diagnostico_k/5,
            mas_simples/4,
            minimos/5,
            rutas/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(library(pairs)).
:- use_module(fallas).
:- reexport(abduccion).

%!  por_filtro(+Modelo, +Circuito, +Observaciones:list(pair),
%!      -Minimos:list(list)) is det.
%
%   Minimos son los diagnósticos mínimos de las Observaciones: se generan
%   todos, y se descartan los que contienen a otro.
por_filtro(Modelo, Circuito, Observaciones, Minimos) :-
    findall(D, diagnostico(Modelo, Circuito, Observaciones, D), Ds0),
    sort(Ds0, Ds),
    include(minimo(Ds), Ds, Minimos).

%!  minimo(+Diagnosticos:list(list), +Diagnostico:list) is semidet.
%
%   Ningún diagnóstico de Diagnosticos tiene sus fallas en un subconjunto
%   propio de las compuertas de Diagnostico.
minimo(Diagnosticos, Diagnostico) :-
    rutas(Diagnostico, Rutas),
    \+ ( member(Otro, Diagnosticos),
         rutas(Otro, Otras),
         Otras \== Rutas,
         ord_subset(Otras, Rutas)
       ).

%!  rutas(+Fallas:list(pair), -Rutas:list) is det.
%
%   Rutas son las rutas de las compuertas de Fallas, como conjunto
%   ordenado.
rutas(Fallas, Rutas) :-
    pairs_keys(Fallas, Rutas0),
    sort(Rutas0, Rutas).

%!  acotada(+Modelo, +K:integer, ?Supuestos:list, +Ruta:list, ?Tipo,
%!      ?Entradas:list, ?Salida) is nondet.
%
%   La conducta abductiva de la versión 2, con a lo sumo K compuertas en
%   falla entre los Supuestos: la rama que supone más falla en seguida.
acotada(Modelo, K, Supuestos, Ruta, Tipo, Entradas, Salida) :-
    abductiva(Modelo, Supuestos, Ruta, Tipo, Entradas, Salida),
    en_falla(Supuestos, N),
    N =< K.

%!  en_falla(+Supuestos:list, -N:integer) is det.
%
%   N es la cantidad de pares del diccionario incompleto Supuestos cuyo
%   estado no es ok.
en_falla(Supuestos, 0) :-
    var(Supuestos),
    !.
en_falla([_-Estado|Resto], N) :-
    en_falla(Resto, N0),
    (   Estado == ok
    ->  N = N0
    ;   N is N0 + 1
    ).

%!  diagnostico_k(+Modelo, +Circuito, +Observaciones:list(pair),
%!      +K:integer, -Fallas:list(pair)) is nondet.
%
%   Como diagnostico/4, con a lo sumo K compuertas en falla.
diagnostico_k(Modelo, Circuito, Observaciones, K, Fallas) :-
    maplist(observar_k(Modelo, K, Circuito, Supuestos), Observaciones),
    cerrar(Supuestos),
    fallas(Supuestos, Fallas).

%!  observar_k(+Modelo, +K:integer, +Circuito, ?Supuestos:list,
%!      +Observacion:pair) is nondet.
%
%   Circuito reproduce la Observacion Entradas-Salidas con los Supuestos,
%   con a lo sumo K compuertas en falla.
observar_k(Modelo, K, Circuito, Supuestos, Entradas-Salidas) :-
    simular(acotada(Modelo, K, Supuestos), Circuito, Entradas, Salidas).

%!  mas_simples(+Modelo, +Circuito, +Observaciones:list(pair),
%!      -Diagnosticos:list(list)) is semidet.
%
%   Diagnosticos son los diagnósticos con la menor cantidad de fallas:
%   se prueban presupuestos de 0, 1, 2... fallas, hasta el primero que da
%   alguno. Falla si ningún diagnóstico explica las Observaciones.
mas_simples(Modelo, Circuito, Observaciones, Diagnosticos) :-
    compuertas(Circuito, N),
    between(0, N, K),
    setof(D, diagnostico_k(Modelo, Circuito, Observaciones, K, D),
          Diagnosticos),
    !.

%!  minimos(+Modelo, +Circuito, +Observaciones:list(pair), +K:integer,
%!      -Minimos:list(list)) is det.
%
%   Minimos son los diagnósticos mínimos con a lo sumo K fallas.
minimos(Modelo, Circuito, Observaciones, K, Minimos) :-
    findall(D, diagnostico_k(Modelo, Circuito, Observaciones, K, D), Ds0),
    sort(Ds0, Ds),
    include(minimo(Ds), Ds, Minimos).
