:- encoding(utf8).

% Capítulo 31 - Buscaminas completo, módulo vecinos: las celdas que rodean
% a otra, y cuántas minas hay entre ellas (capítulo 17).
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- minas_vecinas(3, 3, [1-1], 2-2, N).

:- module(vecinos,
          [ vecina/4,
            minas_vecinas/5
          ]).

:- use_module(library(ordsets)).

%!  vecina(+Filas:integer, +Columnas:integer, +Celda:pair, -Vecina:pair)
%!      is nondet.
%
%   Vecina es una de las celdas que rodean a Celda dentro de un tablero de
%   Filas por Columnas.
vecina(Filas, Columnas, F-C, VF-VC) :-
    between(-1, 1, DF),
    between(-1, 1, DC),
    ( DF, DC ) \== ( 0, 0 ),
    VF is F + DF,
    VC is C + DC,
    between(1, Filas, VF),
    between(1, Columnas, VC).

%!  minas_vecinas(+Filas:integer, +Columnas:integer, +Minas:list,
%!                +Celda:pair, -N:integer) is det.
%
%   N es la cantidad de vecinas de Celda que están en Minas, un conjunto
%   ordenado.
minas_vecinas(Filas, Columnas, Minas, Celda, N) :-
    aggregate_all(count,
                  ( vecina(Filas, Columnas, Celda, V),
                    ord_memberchk(V, Minas) ),
                  N).
