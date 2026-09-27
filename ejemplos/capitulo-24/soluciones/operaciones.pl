:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 8: las operaciones en un módulo
% aparte.
%
% operaciones reexporta de reglas solo lo que modifica el estado: quien
% necesita inscribir importa operaciones, y no ve las demás reglas.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- inscribir(104, ssl, R).

:- module(operaciones, []).

:- reexport('../inscripciones/reglas', [inscribir/3, dar_de_baja/2]).
