:- encoding(utf8).

% Capítulo 49 - Versión 1: una falla, por simulación.
%
% Un modelo de fallas dice qué hace una compuerta en cada estado: ok, la de
% su tabla; pegada(V), da siempre V; invertida, da lo contrario de su
% tabla. con_fallas/5 es una conducta para simular/4 del capítulo 48: las
% compuertas de una lista de fallas Ruta-Estado se comportan según su
% estado, y las demás, según su tabla. Una observación es un par
% Entradas-Salidas; un conjunto de fallas explica las observaciones si el
% circuito con esas fallas las reproduce todas.
%
% El diagnóstico por simulación genera fallas y prueba cada una: primero
% las de una compuerta, después las de k compuertas.
%
% solo-local: carga el módulo circuitos del capítulo 48, y SWISH no admite
% módulos propios.
%
%?- simular(sumador, [0, 0, 1], Ss).
%?- una_falla(sumador, [[0, 0, 1]-[0, 1]], F).
%?- una_falla(sumador, [[1, 1, 1]-[0, 0]], F).
%?- aggregate_all(count, k_fallas(sumador, [[1, 1, 1]-[0, 0]], 2, _), N).

:- module(fallas,
          [ modelo/4,
            falla/1,
            negacion/2,
            con_fallas/5,
            explica/3,
            una_falla/3,
            k_fallas/4
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport('../capitulo-48/circuitos').

%!  modelo(?Estado, ?Tipo, ?Entradas:list, ?Salida) is nondet.
%
%   Salida es la salida de una compuerta de tipo Tipo, en el estado Estado,
%   con las Entradas.
modelo(ok, Tipo, Entradas, Salida) :-
    tabla(Tipo, Entradas, Salida).
modelo(pegada(V), _Tipo, _Entradas, V) :-
    bit(V).
modelo(invertida, Tipo, Entradas, Salida) :-
    tabla(Tipo, Entradas, Salida0),
    negacion(Salida0, Salida).

% falla(E): E es un estado de falla del modelo de la versión 1.
falla(pegada(0)).
falla(pegada(1)).
falla(invertida).

% negacion(B, N): N es el bit opuesto a B.
negacion(0, 1).
negacion(1, 0).

%!  con_fallas(+Fallas:list(pair), +Ruta:list, ?Tipo, ?Entradas:list,
%!      ?Salida) is nondet.
%
%   La conducta de un circuito en el que cada compuerta de Fallas, una
%   lista de pares Ruta-Estado, está en su estado, y las demás, en ok.
con_fallas(Fallas, Ruta, Tipo, Entradas, Salida) :-
    (   memberchk(Ruta-Estado, Fallas)
    ->  true
    ;   Estado = ok
    ),
    modelo(Estado, Tipo, Entradas, Salida).

%!  explica(+Circuito, +Observaciones:list(pair), +Fallas:list(pair))
%!      is semidet.
%
%   Circuito con las Fallas reproduce cada observación Entradas-Salidas.
explica(Circuito, Observaciones, Fallas) :-
    forall(member(Entradas-Salidas, Observaciones),
           simular(con_fallas(Fallas), Circuito, Entradas, Salidas)).

%!  una_falla(+Circuito, +Observaciones:list(pair), -Falla) is nondet.
%
%   Falla, un par Ruta-Estado, es una falla de una sola compuerta que
%   explica las Observaciones.
una_falla(Circuito, Observaciones, Ruta-Estado) :-
    compuerta_en(Circuito, Ruta, _),
    falla(Estado),
    explica(Circuito, Observaciones, [Ruta-Estado]).

%!  k_fallas(+Circuito, +Observaciones:list(pair), +K:integer,
%!      -Fallas:list(pair)) is nondet.
%
%   Fallas son K fallas en compuertas distintas, en el orden de
%   compuerta_en/3, que explican las Observaciones.
k_fallas(Circuito, Observaciones, K, Fallas) :-
    findall(Ruta, compuerta_en(Circuito, Ruta, _), Rutas),
    length(Elegidas, K),
    subsecuencia(Elegidas, Rutas),
    maplist(con_estado, Elegidas, Fallas),
    explica(Circuito, Observaciones, Fallas).

%!  subsecuencia(?Elegidas:list, +Lista:list) is nondet.
%
%   Elegidas tiene elementos de Lista, en el mismo orden.
subsecuencia([], _).
subsecuencia([X|Xs], [X|Ys]) :-
    subsecuencia(Xs, Ys).
subsecuencia(Xs, [_|Ys]) :-
    Xs = [_|_],
    subsecuencia(Xs, Ys).

%!  con_estado(+Ruta, -Falla) is multi.
%
%   Falla es Ruta con un estado de falla.
con_estado(Ruta, Ruta-Estado) :-
    falla(Estado).
