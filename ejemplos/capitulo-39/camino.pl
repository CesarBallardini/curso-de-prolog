:- encoding(utf8).

% Capítulo 39 - La directiva table: recursión a la izquierda y ciclos que
% terminan.
%
% camino_prolog/2 es la definición del capítulo 38, con la recursión a la
% izquierda sobre un grafo con un ciclo: Prolog no termina. camino/2 es la
% misma definición con la directiva table: cada llamada guarda sus
% respuestas en una tabla, y una llamada variante de otra en curso consume
% las respuestas de la tabla en lugar de volver a resolverse. Con las mismas
% cláusulas, la consulta termina. antepasado_izq/2 es la relación del
% capítulo 33, también con la recursión a la izquierda, y tabulada.
%
%?- camino(a, Y).
%?- camino(d, Y).
%?- antepasado_izq(A, eva).
%?- findall(Y, limit(8, camino_prolog(a, Y)), Ys).

% arco(X, Y): hay un arco de X a Y.
arco(a, b).
arco(b, c).
arco(c, a).
arco(c, d).

%!  camino_prolog(?X, ?Y) is nondet.
%
%   Hay un camino de X a Y. Con la recursión a la izquierda y el ciclo de
%   a, b y c, Prolog repite las respuestas sin fin y no termina después de
%   la última.
camino_prolog(X, Y) :-
    arco(X, Y).
camino_prolog(X, Y) :-
    camino_prolog(X, Z),
    arco(Z, Y).

:- table camino/2.

%!  camino(?X, ?Y) is nondet.
%
%   Hay un camino de X a Y. Las mismas cláusulas que camino_prolog/2,
%   tabuladas: cada respuesta aparece una vez y la consulta termina.
camino(X, Y) :-
    arco(X, Y).
camino(X, Y) :-
    camino(X, Z),
    arco(Z, Y).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(luis, eva).

:- table antepasado_izq/2.

%!  antepasado_izq(?A, ?D) is nondet.
%
%   A es un antepasado de D, con la recursión a la izquierda y tabulado.
antepasado_izq(A, D) :-
    padre(A, D).
antepasado_izq(A, D) :-
    antepasado_izq(A, H),
    padre(H, D).
