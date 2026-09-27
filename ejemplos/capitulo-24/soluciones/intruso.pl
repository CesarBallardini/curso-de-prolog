:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 9: un módulo que modifica los datos de
% otro.
%
% intruso importa datos, y con eso inscripcion/3. assertz/1 sobre un
% predicado importado modifica el del módulo que lo define: nada impide que
% intruso cambie los datos sin pasar por agregar_inscripcion/3.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- agregar_mal(104, ssl), inscripcion(104, ssl, E).

:- module(intruso, [agregar_mal/2]).

:- use_module('../inscripciones/datos').

%!  agregar_mal(+Legajo:integer, +Materia:atom) is det.
%
%   Agrega una inscripción con assertz/1, sin pasar por la interfaz de datos.
agregar_mal(Legajo, Materia) :-
    assertz(inscripcion(Legajo, Materia, cursando)).
