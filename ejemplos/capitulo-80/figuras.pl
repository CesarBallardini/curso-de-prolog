:- encoding(utf8).

% Capítulo 80 - Los dibujos de líneas del capítulo.
%
% Un dibujo es un conjunto de puntos con coordenadas enteras, con el eje y
% hacia arriba, y de segmentos entre ellos. Cada punto donde terminan dos o
% tres segmentos es una unión. Cuando una línea queda tapada por un cuerpo,
% el dibujo la corta donde desaparece, y ese punto es una unión en te sobre
% el contorno del cuerpo que tapa.
%
% cubo es un cubo visto desde arriba y de frente; bloques, el mismo cubo
% delante de otro igual, que queda tapado en parte; escalon, un bloque en
% forma de ele, con una arista cóncava; poiuyt, un dibujo con las mismas
% uniones, y las líneas de cada una en el mismo orden, que el poiuyt de la
% figura 17.10 de Norvig, un objeto imposible; escalera(N), una escalera
% de N escalones generada con N.
%
% Los dos predicados se declaran multifile: otro archivo, como el de las
% soluciones, puede agregar dibujos sin modificar este.
%
%?- punto(cubo, P, X, Y).

:- multifile punto/4, segmento/3.

%!  punto(?F, ?P, ?X:integer, ?Y:integer) is nondet.
%
%   El punto P del dibujo F está en (X, Y). Los puntos de escalera(N) se
%   calculan con N.
punto(cubo, a, 0, 0).
punto(cubo, b, -25, 15).
punto(cubo, c, 25, 15).
punto(cubo, d, 0, -30).
punto(cubo, e, 0, 30).
punto(cubo, f, 25, -15).
punto(cubo, g, -25, -15).

punto(bloques, a, 0, 0).
punto(bloques, b, -25, 15).
punto(bloques, c, 25, 15).
punto(bloques, d, 0, -30).
punto(bloques, e, 0, 30).
punto(bloques, f, 25, -15).
punto(bloques, g, -25, -15).
punto(bloques, h, 30, 20).
punto(bloques, i, 5, 35).
punto(bloques, j, 55, 35).
punto(bloques, k, 30, -10).
punto(bloques, l, 30, 50).
punto(bloques, m, 55, 5).
punto(bloques, n, 5, 27).
punto(bloques, o, 25, -7).

punto(escalon, a, 0, 0).
punto(escalon, b, 40, 0).
punto(escalon, c, 40, 10).
punto(escalon, d, 10, 10).
punto(escalon, e, 10, 30).
punto(escalon, f, 0, 30).
punto(escalon, g, 12, 38).
punto(escalon, h, 22, 38).
punto(escalon, i, 22, 18).
punto(escalon, j, 52, 18).
punto(escalon, k, 52, 8).

punto(poiuyt, a, -20, 30).
punto(poiuyt, b, 40, 30).
punto(poiuyt, c, 5, -20).
punto(poiuyt, d, 15, -14).
punto(poiuyt, e, -10, 16).
punto(poiuyt, f, 0, 10).
punto(poiuyt, g, -20, -30).
punto(poiuyt, h, 20, -24).
punto(poiuyt, i, -10, 6).
punto(poiuyt, j, 40, 0).
punto(poiuyt, k, 0, 0).
punto(poiuyt, l, 10, -30).

punto(escalera(N), P, X, Y) :-
    integer(N),
    N >= 1,
    punto_escalera(N, P, X, Y).

%!  segmento(?F, ?A, ?B) is nondet.
%
%   El dibujo F tiene una línea entre los puntos A y B. Los segmentos de
%   escalera(N) se calculan con N.
segmento(cubo, a, b).
segmento(cubo, a, c).
segmento(cubo, a, d).
segmento(cubo, b, e).
segmento(cubo, e, c).
segmento(cubo, c, f).
segmento(cubo, f, d).
segmento(cubo, d, g).
segmento(cubo, g, b).

segmento(bloques, a, b).
segmento(bloques, a, c).
segmento(bloques, a, d).
segmento(bloques, b, e).
segmento(bloques, e, n).
segmento(bloques, n, c).
segmento(bloques, c, o).
segmento(bloques, o, f).
segmento(bloques, f, d).
segmento(bloques, d, g).
segmento(bloques, g, b).
segmento(bloques, h, i).
segmento(bloques, h, j).
segmento(bloques, h, k).
segmento(bloques, i, l).
segmento(bloques, l, j).
segmento(bloques, j, m).
segmento(bloques, m, k).
segmento(bloques, k, o).
segmento(bloques, i, n).

segmento(escalon, a, b).
segmento(escalon, b, c).
segmento(escalon, c, d).
segmento(escalon, d, e).
segmento(escalon, e, f).
segmento(escalon, f, a).
segmento(escalon, f, g).
segmento(escalon, e, h).
segmento(escalon, d, i).
segmento(escalon, c, j).
segmento(escalon, b, k).
segmento(escalon, g, h).
segmento(escalon, h, i).
segmento(escalon, i, j).
segmento(escalon, j, k).

segmento(poiuyt, a, b).
segmento(poiuyt, a, g).
segmento(poiuyt, b, j).
segmento(poiuyt, c, d).
segmento(poiuyt, c, l).
segmento(poiuyt, d, h).
segmento(poiuyt, e, f).
segmento(poiuyt, e, i).
segmento(poiuyt, f, k).
segmento(poiuyt, g, l).
segmento(poiuyt, h, l).
segmento(poiuyt, i, k).
segmento(poiuyt, j, k).
segmento(escalera(N), A, B) :-
    integer(N),
    N >= 1,
    segmento_escalera(N, A, B).

% La escalera de N escalones es un dibujo generado: sus puntos y segmentos
% se calculan con N. Cada escalón mide 10 de ancho y 10 de alto, y la
% profundidad se dibuja como el desplazamiento (12, 8). Los puntos del
% frente son o y b (la base), t (arriba a la izquierda), c(K) (la esquina
% convexa de arriba del escalón K) y v(K) (la esquina cóncava donde el
% escalón K se une al anterior); los del fondo agregan un 2 al nombre.
% Con N = 2 es el mismo bloque que escalon, con otras medidas.

%!  punto_escalera(+N:integer, ?P, ?X:integer, ?Y:integer) is nondet.
%
%   P es un punto de la escalera de N escalones, en (X, Y).
punto_escalera(_, o, 0, 0).
punto_escalera(N, b, X, 0) :-
    X is 10 * N.
punto_escalera(N, t, 0, Y) :-
    Y is 10 * N.
punto_escalera(N, c(K), X, Y) :-
    between(1, N, K),
    X is 10 * K,
    Y is 10 * (N - K + 1).
punto_escalera(N, v(K), X, Y) :-
    between(2, N, K),
    X is 10 * (K - 1),
    Y is 10 * (N - K + 1).
punto_escalera(N, b2, X, 8) :-
    X is 10 * N + 12.
punto_escalera(N, t2, 12, Y) :-
    Y is 10 * N + 8.
punto_escalera(N, c2(K), X, Y) :-
    between(1, N, K),
    X is 10 * K + 12,
    Y is 10 * (N - K + 1) + 8.
punto_escalera(N, v2(K), X, Y) :-
    between(2, N, K),
    X is 10 * (K - 1) + 12,
    Y is 10 * (N - K + 1) + 8.

%!  segmento_escalera(+N:integer, ?A, ?B) is nondet.
%
%   La escalera de N escalones tiene una línea entre A y B.
segmento_escalera(_, o, b).
segmento_escalera(N, b, c(N)).
segmento_escalera(_, c(1), t).
segmento_escalera(_, t, o).
segmento_escalera(N, c(K), v(K)) :-
    between(2, N, K).
segmento_escalera(N, v(K), c(K1)) :-
    between(2, N, K),
    K1 is K - 1.
segmento_escalera(_, t, t2).
segmento_escalera(_, b, b2).
segmento_escalera(N, c(K), c2(K)) :-
    between(1, N, K).
segmento_escalera(N, v(K), v2(K)) :-
    between(2, N, K).
segmento_escalera(_, t2, c2(1)).
segmento_escalera(N, c2(K), v2(K)) :-
    between(2, N, K).
segmento_escalera(N, c2(K), v2(K1)) :-
    between(1, N, K),
    K < N,
    K1 is K + 1.
segmento_escalera(N, c2(N), b2).
