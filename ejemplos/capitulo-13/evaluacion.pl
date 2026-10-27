:- encoding(utf8).

% Capítulo 13 - La evaluación de un programa.
%
% Tres programas pequeños para seguir los cuatro pasos de cada paso de
% resolución y el árbol que recorre el intérprete: concatenar/3 del
% capítulo 7, un programa sin variables, y consecutivos/3 en dos versiones que
% difieren solo en el orden de sus cláusulas.
%
%?- concatenar([a], [b], W).
%?- p.
%?- consecutivos(2, Z, [2, 3, 2, 4]).
%?- consecutivos_invertido(2, Z, [2, 3, 2, 4]).

%!  concatenar(+A, ?B, -C) is det.
%!  concatenar(?A, ?B, +C) is nondet.
%
%   C es la lista A seguida de la lista B. Es el predicado de la sección 7.4,
%   copiado con su encabezado.
concatenar([], B, B).
concatenar([X|RestoA], B, [X|RestoC]) :-
    concatenar(RestoA, B, RestoC).

% Un programa sin variables: cada átomo es un predicado sin argumentos. La
% segunda cláusula de n/0 abre una rama que falla, porque f/0 no se cumple.

% t: un hecho.
t.

% m: un hecho.
m.

% n: un hecho, y además la conclusión de una regla cuya condición no se cumple.
n.
n :-
    f.

% f: no se cumple nunca. La cláusula existe para que la consulta falle en vez
% de informar un predicado desconocido.
f :-
    fail.

%!  r is det.
%
%   r se cumple si se cumplen m y n.
r :-
    m,
    n.

%!  s is det.
%
%   s se cumple si se cumple m.
s :-
    m.

%!  p is det.
%
%   p se cumple si se cumplen r, s y t. Tiene una sola demostración; la
%   segunda cláusula de n/0 deja una alternativa pendiente que falla.
p :-
    r,
    s,
    t.

%!  consecutivos(?X, ?Y, ?L) is nondet.
%
%   X e Y aparecen consecutivos, en ese orden, en la lista L.
consecutivos(X, Y, [X, Y|_]).
consecutivos(X, Y, [_|Z]) :-
    consecutivos(X, Y, Z).

%!  consecutivos_invertido(?X, ?Y, ?L) is nondet.
%
%   Las dos cláusulas de consecutivos/3 en el orden inverso. El árbol es el
%   mismo, reflejado: el recorrido en profundidad encuentra las mismas
%   respuestas en el orden contrario.
consecutivos_invertido(X, Y, [_|Z]) :-
    consecutivos_invertido(X, Y, Z).
consecutivos_invertido(X, Y, [X, Y|_]).
