:- encoding(utf8).

% Capítulo 24 - Ejercicio 4: el segundo de dos módulos que exportan saludo/1.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- saludo(S).

:- module(saludo_b, [saludo/1]).

% saludo(S): S es el saludo de este módulo.
saludo(chau).
