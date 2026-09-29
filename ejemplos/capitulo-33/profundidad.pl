:- encoding(utf8).

% Capítulo 33 - Límites de profundidad y profundización iterativa.
%
% resolver_limite/2 no usa cláusulas más allá de una profundidad dada: la
% búsqueda termina siempre, pero un false. ya no distingue entre «no hay
% prueba» y «no hay prueba corta». resolver_iterativo_ingenuo/1 prueba con
% límites 0, 1, 2…, y repite cada respuesta en cada límite mayor.
% resolver_iterativo/1 acepta en cada límite solo las pruebas de esa altura
% exacta: cada prueba aparece una vez, las más cortas primero.
%
%?- resolver_limite(camino(a, c, C), 4).
%?- limit(2, resolver_iterativo(camino(a, c, C))).

% arista(X, Y): hay una arista de X a Y. Las aristas van y vuelven: el
% grafo tiene ciclos.
arista(a, b).
arista(b, a).
arista(b, c).
arista(c, b).
arista(c, d).
arista(d, c).
arista(d, e).
arista(e, d).
arista(e, f).

%!  camino(?X, ?Z, ?Aristas:list) is nondet.
%
%   Aristas es un camino de X a Z, como lista de pares Desde-Hasta. En un
%   grafo con ciclos hay infinitos caminos, y Prolog puede no encontrar
%   ninguno.
camino(X, X, []).
camino(X, Z, [X-Y|Aristas]) :-
    arista(X, Y),
    camino(Y, Z, Aristas).

% predefinido(G): el intérprete ejecuta G con ejecutar/1.
predefinido(_ = _).
predefinido(_ is _).
predefinido(_ < _).
predefinido(_ > _).

%!  ejecutar(+G) is semidet.
%
%   Ejecuta el objetivo predefinido G.
ejecutar(X = Y) :-
    X = Y.
ejecutar(X is E) :-
    X is E.
ejecutar(X < Y) :-
    X < Y.
ejecutar(X > Y) :-
    X > Y.

%!  clausula(+Meta, -Cuerpo) is nondet.
%
%   Meta :- Cuerpo es una cláusula del programa, con el cuerpo en la
%   representación limpia: true, (A, B), prog(G) o sis(G).
clausula(Meta, Cuerpo) :-
    clause(Meta, Cuerpo0),
    limpiar(Cuerpo0, Cuerpo).

%!  limpiar(+Cuerpo0, -Cuerpo) is det.
%
%   Cuerpo es el cuerpo Cuerpo0 con cada objetivo marcado.
limpiar(true, true) :-
    !.
limpiar((A0, B0), (A, B)) :-
    !,
    limpiar(A0, A),
    limpiar(B0, B).
limpiar(G, sis(G)) :-
    predefinido(G),
    !.
limpiar(G, prog(G)).

%!  resolver_limite(+Meta, +Limite:integer) is nondet.
%
%   Meta tiene una prueba cuya altura, contada en cláusulas, no pasa de
%   Limite: una respuesta por cada una. Siempre termina.
resolver_limite(Meta, Limite) :-
    limite(prog(Meta), Limite).

%!  limite(+Cuerpo, +N:integer) is nondet.
%
%   Cuerpo se prueba sin usar cláusulas a más de N niveles de profundidad.
limite(true, _).
limite((A, B), N) :-
    limite(A, N),
    limite(B, N).
limite(sis(G), _) :-
    ejecutar(G).
limite(prog(G), N) :-
    N > 0,
    N1 is N - 1,
    clausula(G, Cuerpo),
    limite(Cuerpo, N1).

%!  resolver_iterativo_ingenuo(+Meta) is nondet.
%
%   Meta se prueba con límites de profundidad crecientes. Cada respuesta se
%   repite en todos los límites mayores que su altura, sin fin.
resolver_iterativo_ingenuo(Meta) :-
    length(_, N),
    resolver_limite(Meta, N).

%!  resolver_iterativo(+Meta) is nondet.
%
%   Meta se prueba con límites de profundidad crecientes: una respuesta por
%   cada prueba, en orden de altura. No termina después de la última.
resolver_iterativo(Meta) :-
    length(_, N),
    altura(prog(Meta), N, N).

%!  altura(+Cuerpo, +N:integer, ?H:integer) is nondet.
%
%   Cuerpo se prueba sin pasar de N niveles, y H es la altura de la
%   prueba: la mayor cantidad de cláusulas en una rama.
altura(true, _, 0).
altura((A, B), N, H) :-
    altura(A, N, HA),
    altura(B, N, HB),
    H is max(HA, HB).
altura(sis(G), _, 0) :-
    ejecutar(G).
altura(prog(G), N, H) :-
    N > 0,
    N1 is N - 1,
    clausula(G, Cuerpo),
    altura(Cuerpo, N1, H0),
    H is H0 + 1.
