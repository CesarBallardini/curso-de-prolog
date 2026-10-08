:- encoding(utf8).

% Capítulo 24 - Un operador en la interfaz de un módulo.
%
% La lista de exportación incluye op(700, xfx, aprobo): el módulo que importa
% relaciones puede escribir 101 aprobo am1, y los demás no. reglas se carga
% con una ruta relativa al directorio de este archivo, no al directorio de
% trabajo.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- 101 aprobo Materia.

:- module(relaciones,
          [ op(700, xfx, aprobo),
            aprobo/2
          ]).

:- use_module('../inscripciones/reglas', [aprobada/3]).

%!  aprobo(?Legajo:integer, ?Materia:atom) is nondet.
%
%   El alumno Legajo aprobó Materia.
Legajo aprobo Materia :-
    aprobada(Legajo, Materia, _).
