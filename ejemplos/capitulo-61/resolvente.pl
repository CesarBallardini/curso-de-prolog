:- encoding(utf8).

% Capítulo 61 - Versión 1: la resolvente como una lista de metas.
%
% El estado de la demostración es la lista de las metas que faltan probar,
% la resolvente. Cada paso toma la primera meta y la reemplaza por el
% cuerpo de una cláusula cuya cabeza unifica con ella. La continuación,
% lo que queda por hacer, es un dato; la elección de la cláusula, en
% cambio, la hace member/2, y las alternativas pendientes son puntos de
% elección del propio Prolog. Las variables del programa objeto son
% variables de Prolog, y copy_term/2 renombra cada cláusula antes de
% usarla. El corte no se puede expresar: se ejecuta como true.
%
% solo-local: carga el módulo programas.
%
%?- resolver(familia, abuelo(juan, N)).
%?- resolver(maximo, maximo(4, 3, M)).

:- module(resolvente, [resolver/2]).

:- use_module(library(lists)).
:- use_module(programas).

%!  resolver(+Nombre:atom, ?Meta) is nondet.
%
%   Meta se prueba con las cláusulas del programa objeto Nombre: una
%   respuesta por cada demostración, en el orden de Prolog.
resolver(Nombre, Meta) :-
    programa(Nombre, Clausulas),
    resolver_metas([Meta], Clausulas).

%!  resolver_metas(+Metas:list, +Clausulas:list) is nondet.
%
%   Las Metas, la resolvente, se prueban con las Clausulas.
resolver_metas([], _).
resolver_metas([Meta|Metas], Clausulas) :-
    clase(Meta, Clase),
    paso(Clase, Metas, Clausulas, Metas1),
    resolver_metas(Metas1, Clausulas).

%!  paso(+Clase, +Metas:list, +Clausulas:list, -Metas1:list) is nondet.
%
%   Metas1 es la resolvente que queda después de probar una meta de la
%   Clase dada, seguida de Metas: una alternativa por cada cláusula que
%   sirve.
paso(verdad, Metas, _, Metas).
paso(conjuncion(A, B), Metas, _, [A, B|Metas]).
paso(corte, Metas, _, Metas).
paso(predefinida(Meta), Metas, _, Metas) :-
    ejecutar(Meta).
paso(usuario(Meta), Metas, Clausulas, [Cuerpo|Metas]) :-
    member(Clausula, Clausulas),
    copy_term(Clausula, (Meta :- Cuerpo)).
