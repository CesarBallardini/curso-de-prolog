:- encoding(utf8).

% Capítulo 48 - El programa terminado.
%
% Carga los seis archivos del proyecto: las compuertas y la descripción de
% los circuitos, sus fórmulas, la verificación con library(clpb), los
% circuitos secuenciales y sus estados alcanzables.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- simular(sumador3, [1, 1, 0, 1, 0, 1], Ss).
%?- formula(sumador, co, F), suma_de_productos(F, Ps).
%?- equivalentes(sumador, sumador_mayoria).
%?- alcanzables(contador_gray, [0, 0, 0], Es).

:- use_module(circuitos).
:- use_module(formulas).
:- use_module(verificar).
:- use_module(secuenciales).
:- use_module(estados).
