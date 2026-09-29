:- encoding(utf8).

% Capítulo 46 - Versión 4: sistemas de ecuaciones lineales por Gauss–Seidel.
%
% El sistema A x = b es una lista de filas de coeficientes y una lista de
% términos independientes. Cada barrido despeja la incógnita i de la fila
% i con los valores más recientes de las demás: los ya calculados en el
% mismo barrido y los del barrido anterior. El ciclo es iterar/4, con un
% vector como aproximación.
%
% solo-local: carga los programas del capítulo 32, y SWISH no carga otros
% archivos.
%
%?- gauss_seidel([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18], Xs).

:- ensure_loaded(iteracion).

%!  gauss_seidel(+Filas:list(list(number)), +Bs:list(number),
%!               -Xs:list(float)) is semidet.
%
%   Xs es la solución del sistema de Filas y Bs, buscada desde el vector
%   nulo con una tolerancia de 1.0e-12. Falla si no converge.
gauss_seidel(Filas, Bs, Xs) :-
    length(Bs, N),
    length(X0s, N),
    maplist(=(0.0), X0s),
    gauss_seidel(Filas, Bs, X0s, 1.0e-12, Aproximaciones),
    last(Aproximaciones, Xs).

%!  gauss_seidel(+Filas:list(list(number)), +Bs:list(number),
%!               +X0s:list(number), +Tol:float,
%!               -Aproximaciones:list(list(float))) is semidet.
%
%   Aproximaciones son los vectores que da cada barrido desde X0s, hasta
%   que ninguna componente cambia en más de Tol. Falla si un coeficiente
%   de la diagonal es 0 o si no converge en maximo_de_pasos/1 barridos.
gauss_seidel(Filas, Bs, X0s, Tol, Aproximaciones) :-
    iterar(paso_gauss_seidel(Filas, Bs), Tol, X0s, Aproximaciones).

%!  paso_gauss_seidel(+Filas, +Bs, +X0s, -Xs, -Xs, -Cambio:float)
%!      is semidet.
%
%   Xs es el resultado de un barrido desde X0s; Cambio es el mayor cambio
%   de una componente.
paso_gauss_seidel(Filas, Bs, X0s, Xs, Xs, Cambio) :-
    barrido(Filas, Bs, [], X0s, Xs),
    foldl(mayor_diferencia, X0s, Xs, 0.0, Cambio).

%!  barrido(+Filas, +Bs, +Nuevos:list(float), +Viejos:list(number),
%!          -Xs:list(float)) is semidet.
%
%   Xs es Nuevos, los valores ya calculados en este barrido, seguido de
%   los que se calculan con las Filas que faltan. Viejos son los valores
%   anteriores de esas incógnitas. Falla si un coeficiente de la diagonal
%   es 0.
barrido([], [], Xs, [], Xs).
barrido([Fila|Filas], [B|Bs], Nuevos, [_|Viejos], Xs) :-
    length(Nuevos, K),
    length(Izquierda, K),
    append(Izquierda, [Diagonal|Derecha], Fila),
    Diagonal =\= 0,
    producto_escalar(Izquierda, Nuevos, P1),
    producto_escalar(Derecha, Viejos, P2),
    X is (B - P1 - P2) / Diagonal,
    append(Nuevos, [X], Nuevos1),
    barrido(Filas, Bs, Nuevos1, Viejos, Xs).

%!  producto_escalar(+Us:list(number), +Vs:list(number), -P:float) is det.
%
%   P es la suma de los productos de los elementos de Us y Vs, de igual
%   longitud.
producto_escalar(Us, Vs, P) :-
    foldl(sumar_producto, Us, Vs, 0.0, P).

%!  sumar_producto(+U:number, +V:number, +S0:float, -S:float) is det.
%
%   S es S0 más el producto de U y V.
sumar_producto(U, V, S0, S) :-
    S is S0 + U * V.

%!  mayor_diferencia(+U:number, +V:number, +M0:float, -M:float) is det.
%
%   M es el mayor entre M0 y la diferencia entre U y V.
mayor_diferencia(U, V, M0, M) :-
    M is max(M0, abs(U - V)).
