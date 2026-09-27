:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 13: un módulo que reúne interfaces.
%
% consultas reexporta los informes y el calendario: quien solo consulta
% importa un módulo en lugar de dos.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- ranking(R).

:- module(consultas, []).

:- reexport('../inscripciones/informes').
:- reexport('../inscripciones/horarios').
