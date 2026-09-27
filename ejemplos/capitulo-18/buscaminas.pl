:- encoding(utf8).

% Capítulo 18 - Buscaminas: descubrir una región.
%
% Al descubrir una celda sin minas vecinas, el juego descubre también sus
% vecinas, y sigue así mientras encuentre celdas sin minas vecinas.
% descubrir/3 recorre la región con foldl/4: el valor acumulado es la lista de
% celdas ya descubiertas, que además evita volver a visitar una celda.
% mostrar/1 escribe el tablero con maplist/2.
%
%?- descubrir(1-6, [], D), length(D, N).
%?- descubrir(1-6, [], D), mostrar(D).

% tamanio(Filas, Columnas): las dimensiones del tablero.
tamanio(6, 6).

% mina(Fila, Columna): hay una mina en esa celda.
mina(1, 1).
mina(3, 2).
mina(4, 5).
mina(6, 3).

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

%!  descubrir(+Celda:pair, +Vistas:list, -Descubiertas:list) is det.
%
%   Descubiertas son las celdas de Vistas más las que descubre un clic en
%   Celda, un par Fila-Columna sin mina: la celda, y si no tiene minas
%   vecinas, las que descubren sus vecinas.
descubrir(F-C, Vistas, Descubiertas) :-
    (   memberchk(F-C, Vistas)
    ->  Descubiertas = Vistas
    ;   minas_alrededor(F, C, 0)
    ->  findall(VF-VC, vecina(F, C, VF, VC), Vecinas),
        foldl(descubrir, Vecinas, [F-C|Vistas], Descubiertas)
    ;   Descubiertas = [F-C|Vistas]
    ).

%!  mostrar(+Descubiertas:list) is det.
%
%   Escribe el tablero, una fila por línea: el número de minas vecinas en
%   las celdas descubiertas y # en las demás.
mostrar(Descubiertas) :-
    tamanio(Filas, _),
    numlist(1, Filas, Fs),
    maplist(mostrar_fila(Descubiertas), Fs).

%!  mostrar_fila(+Descubiertas:list, +F:integer) is det.
%
%   Escribe la fila F del tablero.
mostrar_fila(Descubiertas, F) :-
    tamanio(_, Columnas),
    numlist(1, Columnas, Cs),
    maplist(celda_visible(Descubiertas, F), Cs, Simbolos),
    format("~s~n", [Simbolos]).

%!  celda_visible(+Descubiertas:list, +F, +C, -Simbolo:integer) is det.
%
%   Simbolo es el código del carácter que se muestra en la celda (F, C).
celda_visible(Descubiertas, F, C, Simbolo) :-
    (   memberchk(F-C, Descubiertas)
    ->  minas_alrededor(F, C, N),
        Simbolo is 0'0 + N
    ;   Simbolo = 0'#
    ).
