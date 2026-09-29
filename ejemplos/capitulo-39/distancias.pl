:- encoding(utf8).

% Capítulo 39 - Subsunción de respuestas: la tabla guarda solo la mejor.
%
% tramo/3 es un grafo con distancias y un ciclo. suma_tramos/3, tabulada
% como las relaciones de la sección 39.1, tiene infinitas respuestas
% distintas: cada vuelta al ciclo da una distancia mayor, y la tabla no se
% completa nunca. distancia/3 declara el modo min en su tercer argumento:
% la tabla guarda, para cada par de nodos, solo la menor distancia, y una
% distancia mayor no es una respuesta nueva. ruta/3 guarda la distancia con
% el recorrido, y elige entre dos con mas_corta/3, un reticulado.
%
%?- distancia(a, Y, D).
%?- ruta(a, d, R).

% tramo(X, Y, D): hay un tramo de X a Y de longitud D.
tramo(a, b, 4).
tramo(a, c, 1).
tramo(c, b, 2).
tramo(b, d, 5).
tramo(d, a, 3).

:- table suma_tramos/3.

%!  suma_tramos(?X, ?Y, -D:integer) is nondet.
%
%   Hay un recorrido de X a Y de longitud D. Con el ciclo, hay infinitas
%   respuestas y la consulta no termina.
suma_tramos(X, Y, D) :-
    tramo(X, Y, D).
suma_tramos(X, Y, D) :-
    suma_tramos(X, Z, D0),
    tramo(Z, Y, D1),
    D is D0 + D1.

:- table distancia(_, _, min).

%!  distancia(?X, ?Y, -D:integer) is nondet.
%
%   D es la longitud del recorrido más corto de X a Y. D debe llegar libre.
distancia(X, Y, D) :-
    tramo(X, Y, D).
distancia(X, Y, D) :-
    distancia(X, Z, D0),
    tramo(Z, Y, D1),
    D is D0 + D1.

:- table ruta(_, _, lattice(mas_corta/3)).

%!  ruta(?X, ?Y, -R) is nondet.
%
%   R es D-Nodos: el recorrido más corto de X a Y, con su longitud D y la
%   lista de sus nodos. R debe llegar libre.
ruta(X, Y, D-[X, Y]) :-
    tramo(X, Y, D).
ruta(X, Y, D-Nodos) :-
    ruta(X, Z, R0),
    R0 = D0-Nodos0,
    tramo(Z, Y, D1),
    D is D0 + D1,
    append(Nodos0, [Y], Nodos).

%!  mas_corta(+R1, +R2, -R) is det.
%
%   R es la más corta de las rutas R1 y R2, de la forma D-Nodos; con
%   longitudes iguales, R1.
mas_corta(D1-N1, D2-N2, R) :-
    (   D1 =< D2
    ->  R = D1-N1
    ;   R = D2-N2
    ).
