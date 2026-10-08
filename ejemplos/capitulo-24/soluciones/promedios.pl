:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 14: la importación explícita de
% library(apply).
%
% La parte de informes que usa foldl/4, con la directiva que el ejercicio
% agrega a informes.pl: sin la autocarga, foldl/4 no se encuentra si el
% módulo no importa library(apply).
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- promedio([7, 9], P).

:- module(promedios, [promedio/2]).

:- use_module(library(apply), [foldl/4]).

%!  promedio(+Notas:list(number), -Promedio:number) is semidet.
%
%   Promedio es el promedio de Notas. Falla con la lista vacía.
promedio(Notas, Promedio) :-
    foldl(contar_y_sumar, Notas, 0-0, Cantidad-Suma),
    Cantidad > 0,
    Promedio is Suma / Cantidad.

%!  contar_y_sumar(+Nota:number, +Hasta:pair, -Total:pair) is det.
%
%   Total es el par Cantidad-Suma de Hasta con Nota agregada.
contar_y_sumar(Nota, Cantidad0-Suma0, Cantidad-Suma) :-
    Cantidad is Cantidad0 + 1,
    Suma is Suma0 + Nota.
