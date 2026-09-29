:- encoding(utf8).

% Capítulo 48 - Versión 4: verificar circuitos con library(clpb).
%
% La tercera conducta para la misma descripción: cada cable es una
% variable booleana de library(clpb), y cada compuerta, la restricción que
% iguala su salida con la fórmula de la versión 3. Dos circuitos con la
% misma interfaz son equivalentes si cada salida del primero equivale a la
% del segundo con las mismas entradas: taut/2 lo decide sin recorrer la
% tabla de verdad. Si no lo son, labeling/1 da una entrada donde difieren.
%
% El archivo agrega tres circuitos a los del módulo circuitos: una
% compuerta XOR sola, un sumador con el acarreo como mayoría, y el mismo
% sumador con un cable mal conectado.
%
% solo-local: carga los módulos circuitos y formulas, y SWISH no admite
% módulos propios.
%
%?- equivalentes(sumador, sumador_mayoria).
%?- diferencia(sumador, sumador_error, Es).

:- module(verificar,
          [ restriccion/4,
            equivalentes/2,
            diferencia/3,
            cuantas/4
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(clpb)).
:- use_module(circuitos).
:- use_module(formulas).

:- multifile circuitos:circuito/3, circuitos:componente/5.

circuitos:circuito(xor1, [x, y], [z]).
circuitos:componente(xor1, g1, xor, [x, y], [z]).

% El acarreo es 1 si al menos dos de las tres entradas lo son.
circuitos:circuito(sumador_mayoria, [a, b, ci], [s, co]).
circuitos:componente(sumador_mayoria, x1, xor, [a, b], [t]).
circuitos:componente(sumador_mayoria, x2, xor, [t, ci], [s]).
circuitos:componente(sumador_mayoria, y1, and, [a, b], [p]).
circuitos:componente(sumador_mayoria, y2, and, [a, ci], [q]).
circuitos:componente(sumador_mayoria, y3, and, [b, ci], [r]).
circuitos:componente(sumador_mayoria, o1, or, [p, q], [u]).
circuitos:componente(sumador_mayoria, o2, or, [u, r], [co]).

% El mismo, con la segunda entrada de y2 conectada a b en lugar de ci.
circuitos:circuito(sumador_error, [a, b, ci], [s, co]).
circuitos:componente(sumador_error, x1, xor, [a, b], [t]).
circuitos:componente(sumador_error, x2, xor, [t, ci], [s]).
circuitos:componente(sumador_error, y1, and, [a, b], [p]).
circuitos:componente(sumador_error, y2, and, [a, b], [q]).
circuitos:componente(sumador_error, y3, and, [b, ci], [r]).
circuitos:componente(sumador_error, o1, or, [p, q], [u]).
circuitos:componente(sumador_error, o2, or, [u, r], [co]).

%!  restriccion(+Ruta:list, +Tipo, +Entradas:list, ?Salida) is det.
%
%   Salida y Entradas son variables booleanas de library(clpb), y la
%   restricción impone que Salida equivalga a la fórmula de la compuerta
%   Tipo sobre las Entradas.
restriccion(Ruta, Tipo, Entradas, Salida) :-
    simbolica(Ruta, Tipo, Entradas, Formula),
    sat(Salida =:= Formula).

%!  modelo(+Circuito, -Entradas:list, -Salidas:list) is det.
%
%   Entradas y Salidas son variables booleanas, y las restricciones de
%   las compuertas de Circuito las relacionan.
modelo(Circuito, Entradas, Salidas) :-
    circuito(Circuito, NEs, NSs),
    same_length(NEs, Entradas),
    same_length(NSs, Salidas),
    once(simular(restriccion, Circuito, Entradas, Salidas)).

%!  equivalentes(+Circuito1, +Circuito2) is semidet.
%
%   Los dos circuitos tienen tantas entradas y salidas uno como el otro, y
%   con las mismas entradas dan las mismas salidas, en todos los casos.
equivalentes(C1, C2) :-
    modelo(C1, Entradas, Salidas1),
    modelo(C2, Entradas, Salidas2),
    maplist(equivalente, Salidas1, Salidas2).

%!  equivalente(+X, +Y) is semidet.
%
%   Las restricciones vigentes hacen que X e Y sean siempre iguales.
equivalente(X, Y) :-
    taut(X =:= Y, 1).

%!  diferencia(+Circuito1, +Circuito2, -Entradas:list) is nondet.
%
%   Entradas es una combinación de valores con la que alguna salida de
%   Circuito1 es distinta de la misma salida de Circuito2.
diferencia(C1, C2, Entradas) :-
    modelo(C1, Entradas, Salidas1),
    modelo(C2, Entradas, Salidas2),
    maplist([X, Y, X # Y]>>true, Salidas1, Salidas2, Distintas),
    sat(+(Distintas)),
    labeling(Entradas).

%!  cuantas(+Circuito, +Salida, +Valor, -N:integer) is det.
%
%   N es la cantidad de combinaciones de valores de las entradas de
%   Circuito con las que la salida Salida vale Valor.
cuantas(Circuito, Salida, Valor, N) :-
    circuito(Circuito, _, NSs),
    nth1(I, NSs, Salida),
    !,
    modelo(Circuito, Entradas, Salidas),
    nth1(I, Salidas, S),
    sat(S =:= Valor),
    sat_count(+[1|Entradas], N).
