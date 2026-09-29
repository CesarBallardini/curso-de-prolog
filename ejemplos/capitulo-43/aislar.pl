:- encoding(utf8).

% Capítulo 43 - Versión 1 del programa que resuelve ecuaciones: el
% aislamiento.
%
% Una ecuación es un término Izq = Der; la incógnita es un átomo. Si la
% incógnita aparece una sola vez, su posición en la ecuación es una lista
% de números de argumento, y cada número elige el axioma que pasa al
% otro lado la operación de ese nivel. Al agotar la posición, la
% incógnita queda sola a la izquierda. log/1 es el logaritmo natural.
%
% solo-local: carga el módulo capitulo32, y SWISH no permite cargar otro
% archivo.
%
%?- resolver(3 * x + 2 = 11, x, S).
%?- posicion(x, 1 - 2 * sin(x) = 0, P).
%?- resolver(1 - 2 * sin(x) = 0, x, S).
%?- resolver(2 * x + 3 * x = 10, x, S).

:- module(aislar,
          [ resolver/3,
            aislar/3,
            posicion/3
          ]).

:- use_module(library(error)).
:- use_module(capitulo32, [apariciones/3, simplificar/2]).

%!  resolver(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = E, con E sin X, una solución de la Ecuacion cerrada
%   Izq = Der en la incógnita X, simplificada. Hay una respuesta por
%   solución; falla si X no aparece exactamente una vez.
resolver(Ecuacion, X, X = E) :-
    must_be(ground, Ecuacion),
    must_be(atom, X),
    aislar(Ecuacion, X, X = E0),
    simplificar(E0, E).

%!  aislar(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es la Ecuacion con X, que aparece una sola vez, aislada a la
%   izquierda. Falla si X no aparece o aparece más de una vez.
aislar(Ecuacion, X, Solucion) :-
    apariciones(Ecuacion, X, 1),
    posicion(X, Ecuacion, [Lado|Camino]),
    orientar(Lado, Ecuacion, Ecuacion1),
    aislar_camino(Camino, Ecuacion1, Solucion).

%!  posicion(+S, +T, -Camino:list(integer)) is nondet.
%
%   Camino es la lista de números de argumento que lleva de T a un
%   subtérmino idéntico (==) a S. Hay una respuesta por aparición.
posicion(S, T, []) :-
    T == S.
posicion(S, T, [N|Camino]) :-
    compound(T),
    arg(N, T, A),
    posicion(S, A, Camino).

%!  orientar(+Lado:integer, +Ecuacion, -Orientada) is det.
%
%   Orientada es la Ecuacion con el lado número Lado a la izquierda.
orientar(1, Izq = Der, Izq = Der).
orientar(2, Izq = Der, Der = Izq).

%!  aislar_camino(+Camino:list(integer), +Ecuacion, -Aislada) is nondet.
%
%   Aislada resulta de aplicar a la Ecuacion un axioma por cada número de
%   Camino, la posición de la incógnita en el lado izquierdo.
aislar_camino([], Ecuacion, Ecuacion).
aislar_camino([N|Camino], Ecuacion0, Ecuacion) :-
    axioma(N, Ecuacion0, Ecuacion1),
    aislar_camino(Camino, Ecuacion1, Ecuacion).

:- multifile axioma/3.

%!  axioma(+N:integer, +Ecuacion0, -Ecuacion) is nondet.
%
%   Ecuacion es equivalente a Ecuacion0, con la operación de la raíz del
%   lado izquierdo pasada al lado derecho; la incógnita está en el
%   argumento N de esa operación. Hay una respuesta por cada solución que
%   el axioma separa. Es multifile: otro archivo puede agregar axiomas.
axioma(1, -U = W, U = -W).
axioma(1, U + V = W, U = W - V).
axioma(2, U + V = W, V = W - U).
axioma(1, U - V = W, U = W + V).
axioma(2, U - V = W, V = U - W).
axioma(1, U * V = W, U = W / V) :-
    V \== 0.
axioma(2, U * V = W, V = W / U) :-
    U \== 0.
axioma(1, U ^ 2 = W, U = sqrt(W)).
axioma(1, U ^ 2 = W, U = -sqrt(W)).
axioma(1, U ^ N = W, U = W ^ (1 / N)) :-
    N \== 2.
axioma(2, A ^ U = W, U = log(W) / log(A)).
axioma(1, sqrt(U) = W, U = W ^ 2).
axioma(1, exp(U) = W, U = log(W)).
axioma(1, log(U) = W, U = exp(W)).
axioma(1, sin(U) = W, U = asin(W)).
axioma(1, sin(U) = W, U = pi - asin(W)).
axioma(1, cos(U) = W, U = acos(W)).
axioma(1, cos(U) = W, U = -acos(W)).
axioma(1, tan(U) = W, U = atan(W)).
