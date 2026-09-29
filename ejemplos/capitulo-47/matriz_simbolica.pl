:- encoding(utf8).

% Capítulo 47 - Versión 4: el producto de matrices con símbolos.
%
% El recorrido del producto no depende de qué son los elementos: solo el
% producto interno hace aritmética. producto_interno_simbolico/3 no evalúa:
% construye la expresión 0 + A1 * B1 + ... + An * Bn, y el producto de
% matrices con símbolos es producto_con/4 de la versión 3 con ese producto
% interno. Las expresiones resultantes se simplifican con simplificar/2 del
% capítulo 32. rotacion/3 da las matrices de rotación del espacio en
% coordenadas homogéneas, con el ángulo como un átomo.
%
% solo-local: carga matriz.pl y el simplificador del capítulo 32, y SWISH
% no carga otros archivos.
%
%?- rotacion(z, a, R).
%?- producto_simbolico([[a, b], [c, d]], [[x], [y]], P).
%?- rotacion(y, t, A), rotacion(x, f, B), producto_simbolico(A, B, P).

:- ensure_loaded(matriz).
:- ensure_loaded('../capitulo-32/simplificar').

%!  producto_interno_simbolico(+V:list, +W:list, -E) is det.
%
%   E es la expresión, sin evaluar, de la suma de los productos de los
%   elementos de V y W en la misma posición.
producto_interno_simbolico(V, W, E) :-
    foldl(sumar_producto_simbolico, V, W, 0, E).

%!  sumar_producto_simbolico(+A, +B, +E0, -E) is det.
%
%   E es la expresión E0 + A * B.
sumar_producto_simbolico(A, B, E0, E0 + A * B).

%!  producto_sin_simplificar(+A:list(list), +B:list(list),
%!                           -C:list(list)) is det.
%
%   C es el producto de A y B con cada elemento como una expresión sin
%   evaluar ni simplificar.
producto_sin_simplificar(A, B, C) :-
    producto_con(producto_interno_simbolico, A, B, C).

%!  producto_simbolico(+A:list(list), +B:list(list), -C:list(list)) is det.
%
%   C es el producto de las matrices A y B, cuyos elementos son números,
%   átomos o expresiones cerradas, con cada elemento simplificado.
producto_simbolico(A, B, C) :-
    producto_sin_simplificar(A, B, C0),
    maplist(maplist(simplificar), C0, C).

% rotacion(Eje, Angulo, M): M es la matriz de la rotación en Angulo
% alrededor de Eje (x, y o z), en coordenadas homogéneas.
rotacion(x, T, [ [1, 0, 0, 0],
                 [0, cos(T), sin(T), 0],
                 [0, -sin(T), cos(T), 0],
                 [0, 0, 0, 1] ]).
rotacion(y, T, [ [cos(T), 0, -sin(T), 0],
                 [0, 1, 0, 0],
                 [sin(T), 0, cos(T), 0],
                 [0, 0, 0, 1] ]).
rotacion(z, T, [ [cos(T), sin(T), 0, 0],
                 [-sin(T), cos(T), 0, 0],
                 [0, 0, 1, 0],
                 [0, 0, 0, 1] ]).
