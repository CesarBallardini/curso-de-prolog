:- encoding(utf8).

% Capítulo 24 - Un módulo que importa un operador.
%
% usa_relaciones importa relaciones, y con él el operador aprobo, que puede
% escribir en sus cláusulas. Quien importa usa_relaciones recibe
% aprobadas_de/2, pero no el operador: la importación no es transitiva.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- aprobadas_de(101, Materias).

:- module(usa_relaciones, [aprobadas_de/2]).

:- use_module(relaciones).

%!  aprobadas_de(+Legajo:integer, -Materias:list(atom)) is det.
%
%   Materias son las materias que aprobó el alumno Legajo, en el orden de
%   los datos.
aprobadas_de(Legajo, Materias) :-
    findall(Materia, Legajo aprobo Materia, Materias).
