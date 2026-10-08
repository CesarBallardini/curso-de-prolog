:- encoding(utf8).

% Capítulo 39 - Inscripciones: la cadena de correlativas, tabulada.
%
% El módulo reglas del capítulo 31 calcula requisitos_de/2 con findall/3 y
% sort/2 sobre requisito/2, que da una respuesta por cada camino de
% correlativas, y guarda el resultado en el predicado dinámico
% requisitos_guardados/2 (Patrón 17). Este módulo usa los datos del
% capítulo 31 y reemplaza las dos cosas por una tabla: requisito/2 da cada
% requisito una sola vez, termina aunque el plan de estudios tenga un
% ciclo, y no deja estado que borrar. requisito_sin_tabla/2 es la
% definición del capítulo 31.
%
% solo-local: carga el módulo datos del capítulo 31, y SWISH no admite
% módulos propios.
%
%?- requisito(bd, R).
%?- requisitos_de(bd, Rs).

:- module(requisitos,
          [ requisito/2,
            requisito_sin_tabla/2,
            requisitos_de/2
          ]).

:- use_module('../capitulo-31/inscripciones/datos').

%!  requisito_sin_tabla(+Materia:atom, -Requisito:atom) is nondet.
%
%   Requisito es una correlativa de Materia, o una correlativa de una de
%   ellas. Una respuesta por cada camino de correlativas.
requisito_sin_tabla(Materia, Requisito) :-
    correlativa(Materia, Requisito).
requisito_sin_tabla(Materia, Requisito) :-
    correlativa(Materia, Intermedia),
    requisito_sin_tabla(Intermedia, Requisito).

:- table requisito/2.

%!  requisito(?Materia:atom, ?Requisito:atom) is nondet.
%
%   La misma relación, tabulada: una respuesta por requisito.
requisito(Materia, Requisito) :-
    correlativa(Materia, Requisito).
requisito(Materia, Requisito) :-
    requisito(Materia, Intermedia),
    correlativa(Intermedia, Requisito).

%!  requisitos_de(+Materia:atom, -Requisitos:list(atom)) is det.
%
%   Requisitos son todas las materias que se deben aprobar antes de cursar
%   Materia, directa o indirectamente, en orden y sin repetidos.
requisitos_de(Materia, Requisitos) :-
    must_be(atom, Materia),
    findall(R, requisito(Materia, R), Todos),
    sort(Todos, Requisitos).
