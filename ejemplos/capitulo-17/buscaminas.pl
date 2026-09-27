:- encoding(utf8).

% Capítulo 17 - Buscaminas: las minas alrededor de una celda.
%
% Un tablero de 5 x 5 con cuatro minas. El número que el juego muestra en una
% celda descubierta es la cantidad de minas en sus ocho vecinas: se cuenta
% con aggregate_all/3, sin reunir las vecinas en una lista.
%
%     1 2 3 4 5
%   1 * . . . .
%   2 . . * . .
%   3 . . . . .
%   4 . * . . *
%   5 . . . . .
%
%?- minas_alrededor(2, 2, N).
%?- minas_alrededor(3, 3, N).

% tamanio(Filas, Columnas): las dimensiones del tablero.
tamanio(5, 5).

% mina(Fila, Columna): hay una mina en esa celda.
mina(1, 1).
mina(2, 3).
mina(4, 2).
mina(4, 5).

%!  vecina(+F:integer, +C:integer, -VF:integer, -VC:integer) is nondet.
%
%   (VF, VC) es una de las celdas vecinas de (F, C), dentro del tablero: las
%   ocho que la rodean, o menos en los bordes.
vecina(F, C, VF, VC) :-
    tamanio(Filas, Columnas),
    between(-1, 1, DF),
    between(-1, 1, DC),
    ( DF, DC ) \== ( 0, 0 ),
    VF is F + DF,
    VC is C + DC,
    between(1, Filas, VF),
    between(1, Columnas, VC).

%!  minas_alrededor(+F:integer, +C:integer, -N:integer) is det.
%
%   N es la cantidad de minas en las celdas vecinas de (F, C).
minas_alrededor(F, C, N) :-
    aggregate_all(count, ( vecina(F, C, VF, VC), mina(VF, VC) ), N).
