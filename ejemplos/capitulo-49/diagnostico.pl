:- encoding(utf8).

% Capítulo 49 - El programa terminado.
%
% Carga las cinco versiones del proyecto: las fallas simuladas, el
% intérprete abductivo, los diagnósticos mínimos, el modelo débil y la
% elección de la próxima medición. Los circuitos son los del módulo
% circuitos del capítulo 48, que la primera versión carga y reexporta.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- simular(sumador, [0, 0, 1], Ss).
%?- mas_simples(fuerte, sumador, [[0, 0, 1]-[0, 1]], Ds).
%?- minimos(fuerte, sumador, [[0, 0, 1]-[0, 1]], 2, Ds), length(Ds, N).

:- use_module(fallas).
:- use_module(abduccion).
:- use_module(minimos).
:- use_module(modelos).
:- use_module(medicion).
