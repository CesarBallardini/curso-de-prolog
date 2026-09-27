:- encoding(utf8).

% Capítulo 24 - meta_predicate y los módulos.
%
% El módulo meta exporta dos versiones del cada_uno/2 del capítulo 18. La
% primera no declara que su primer argumento es un objetivo, y lo llama en el
% módulo meta: un predicado definido en otro módulo no se encuentra. La
% segunda lo declara con meta_predicate, y el argumento llega calificado con
% el módulo que hace la llamada.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- cada_uno_meta(integer, [1, 2]).

:- module(meta, [cada_uno_sin_declarar/2, cada_uno_meta/2]).

:- meta_predicate
    cada_uno_meta(1, ?).

%!  cada_uno_sin_declarar(+Condicion, +L:list) is semidet.
%
%   Todos los elementos de L cumplen Condicion, que se llama en el módulo
%   meta: solo encuentra predicados de ese módulo y los predefinidos.
cada_uno_sin_declarar(Condicion, L) :-
    maplist(Condicion, L).

%!  cada_uno_meta(:Condicion, +L:list) is semidet.
%
%   Todos los elementos de L cumplen Condicion, que se llama en el módulo
%   desde el que se llamó a cada_uno_meta/2.
cada_uno_meta(Condicion, L) :-
    maplist(Condicion, L).
