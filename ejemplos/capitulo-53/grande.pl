:- encoding(utf8).

% Capítulo 53 - Un léxico más grande, para medir.
%
% Agrega al léxico 500 verbos regulares inventados, de la forma
% consonante, vocal, consonante y -ar: badar, bafar... Con ellos el
% léxico describe 6 328 formas en lugar de 328. Se carga después de la
% versión que se quiere medir. Los verbos se agregan como hechos, al
% cargar el archivo, para que el léxico los encuentre por su primer
% argumento como a los demás.
%
% solo-local: carga el módulo lexico.
%
%?- sintetico(L).

:- use_module(lexico).
:- use_module(library(lists)).

%!  sintetico(?Lema:string) is nondet.
%
%   Lema es uno de los 500 verbos inventados.
sintetico(Lema) :-
    Consonantes = [b, d, f, l, m, n, p, r, s, t],
    member(C1, Consonantes),
    member(V, [a, e, i, o, u]),
    member(C2, Consonantes),
    atomic_list_concat([C1, V, C2, ar], Atomo),
    atom_string(Atomo, Lema).

% Al cargar, la línea verbos_sinteticos se reemplaza por un hecho
% lexico:verbo(Lema, regular) por cada verbo inventado.
term_expansion(verbos_sinteticos, Hechos) :-
    findall(lexico:verbo(Lema, regular), sintetico(Lema), Hechos).

verbos_sinteticos.
