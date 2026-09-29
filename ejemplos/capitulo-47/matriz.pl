:- encoding(utf8).

% Capítulo 47 - Versión 3: matrices como listas de listas.
%
% Una matriz de F filas y C columnas es una lista de F filas, y cada fila
% es una lista de C elementos. El producto de A por B multiplica cada fila
% de A por cada columna de B; las columnas de B son las filas de su
% traspuesta. producto_con/4 recibe como argumento el predicado que
% multiplica una fila por una columna: producto/3 lo usa con el producto
% interno numérico, que con is/2 sirve para enteros, racionales y números
% de punto flotante, y la versión 4 lo usa con un producto interno que
% construye expresiones.
%
%?- transpuesta([[1, 2, 3], [4, 5, 6]], T).
%?- producto([[1, 2], [3, 4]], [[0, 1], [1, 0]], C).
%?- producto([[1r2, 0], [0, 1r3]], [[2], [3]], C).
%?- identidad(3, I).

:- use_module(library(apply)).
:- use_module(library(error)).
:- use_module(library(lists)).

%!  transpuesta(+M:list(list), -T:list(list)) is det.
%
%   T es la traspuesta de la matriz M: la fila i de T es la columna i de
%   M. La traspuesta de la matriz sin filas es la matriz sin filas.
transpuesta([], []).
transpuesta([F|Fs], T) :-
    columnas(F, [F|Fs], T).

%!  columnas(+Guia:list, +M:list(list), -T:list(list)) is det.
%
%   T son las columnas de M, una por cada elemento de Guia, que tiene
%   tantos elementos como columnas quedan en M.
columnas([], _, []).
columnas([_|Guia], M, [C|Cs]) :-
    maplist(primero_y_resto, M, C, M1),
    columnas(Guia, M1, Cs).

%!  primero_y_resto(+Lista:list, -Primero, -Resto:list) is det.
%
%   Lista es [Primero|Resto].
primero_y_resto([X|Xs], X, Xs).

%!  dimensiones(+M:list(list), -F:integer, -C:integer) is det.
%
%   La matriz M tiene F filas y C columnas. Produce un error de dominio si
%   las filas no tienen todas la misma longitud.
dimensiones([], 0, 0).
dimensiones([Fila|Filas], F, C) :-
    length([Fila|Filas], F),
    length(Fila, C),
    (   maplist([X]>>length(X, C), Filas)
    ->  true
    ;   domain_error(matriz, [Fila|Filas])
    ).

%!  producto_interno(+V:list(number), +W:list(number), -X:number) is det.
%
%   X es la suma de los productos de los elementos de V y W en la misma
%   posición. V y W tienen la misma longitud.
producto_interno(V, W, X) :-
    foldl(sumar_producto, V, W, 0, X).

%!  sumar_producto(+A:number, +B:number, +S0:number, -S:number) is det.
%
%   S es S0 + A * B.
sumar_producto(A, B, S0, S) :-
    S is S0 + A * B.

%!  producto_con(:Interno, +A:list(list), +B:list(list),
%!               -C:list(list)) is det.
%
%   C es el producto de las matrices A y B, donde call(Interno, Fila,
%   Columna, X) multiplica una fila de A por una columna de B. Produce un
%   error de dominio si A no tiene tantas columnas como filas tiene B.
producto_con(Interno, A, B, C) :-
    dimensiones(A, _, CA),
    dimensiones(B, FB, _),
    (   CA =:= FB
    ->  true
    ;   domain_error(matrices_compatibles, A-B)
    ),
    transpuesta(B, BT),
    maplist(fila_por_columnas(Interno, BT), A, C).

%!  fila_por_columnas(:Interno, +Columnas:list(list), +Fila:list,
%!                    -Resultado:list) is det.
%
%   Resultado es la fila del producto: Fila multiplicada por cada una de
%   las Columnas con Interno.
fila_por_columnas(Interno, Columnas, Fila, Resultado) :-
    maplist(call(Interno, Fila), Columnas, Resultado).

%!  producto(+A:list(list), +B:list(list), -C:list(list)) is det.
%
%   C es el producto de las matrices numéricas A y B.
producto(A, B, C) :-
    producto_con(producto_interno, A, B, C).

%!  identidad(+N:integer, -I:list(list)) is det.
%
%   I es la matriz identidad de N filas y N columnas.
identidad(N, I) :-
    must_be(nonneg, N),
    numlist(1, N, Is),
    maplist(fila_identidad(Is), Is, I).

%!  fila_identidad(+Indices:list(integer), +K:integer, -Fila:list) is det.
%
%   Fila tiene un 1 en la posición K y un 0 en las demás posiciones de
%   Indices.
fila_identidad(Is, K, Fila) :-
    maplist(uno_si_igual(K), Is, Fila).

%!  uno_si_igual(+K:integer, +J:integer, -X:integer) is det.
%
%   X es 1 si K y J son iguales, y 0 si no.
uno_si_igual(K, J, X) :-
    (   K =:= J
    ->  X = 1
    ;   X = 0
    ).
