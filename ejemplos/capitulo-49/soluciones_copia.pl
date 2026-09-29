:- encoding(utf8).

% Capítulo 49 - Solución del ejercicio 5: el estado copia(I).
%
% En un archivo aparte, porque cambia el modelo fuerte: cargado junto con
% las demás soluciones, cambiaría sus resultados.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- mas_simples(fuerte, sumador, [[1, 1, 1]-[0, 0]], Ds).

:- use_module(library(lists)).
:- use_module(minimos).

:- multifile abduccion:regla/2.

% Una compuerta en el estado copia(I) da el valor de su entrada I.
abduccion:regla(salida(fuerte, Ruta, _, Es, S),
                (estado(Ruta, copia(I)), entrada(I, Es, S))).
abduccion:regla(entrada(I, Es, S), true) :-
    nth1(I, Es, S).
