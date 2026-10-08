:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 16: las dependencias de un módulo.
%
% Los módulos de los que un módulo importa al menos un predicado, sin los de
% la biblioteca, que tienen la clase library. Aplicado a los módulos del
% proyecto, reproduce la columna «Importa» de la tabla de la sección 24.9.
% use_module/2 con la lista vacía carga los módulos sin importar nada.
% predicate_property/2 se presenta en el capítulo 33.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- dependencias(informes, Modulos).

:- module(dependencias, [dependencias/2]).

:- use_module('../inscripciones/comandos', []).
:- use_module('../inscripciones/horarios', []).

%!  dependencias(+Modulo:atom, -Modulos:list(atom)) is det.
%
%   Modulos son los módulos de clase user de los que Modulo importa al menos
%   un predicado, ordenados y sin repetidos.
dependencias(Modulo, Modulos) :-
    findall(Origen,
            ( predicate_property(Modulo:_, imported_from(Origen)),
              module_property(Origen, class(user)) ),
            Origenes),
    sort(Origenes, Modulos).
