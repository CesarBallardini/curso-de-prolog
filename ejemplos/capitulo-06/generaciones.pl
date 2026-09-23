:- encoding(utf8).

% Capítulo 6 - Recursión que produce un resultado.
%
% Las reglas recursivas de los capítulos anteriores solo verificaban una
% relación. Esta produce además un número: la cantidad de generaciones entre dos
% personas.
%
%?- generaciones(juan, eva, Cuantas).
%?- generaciones(juan, Quien, 2).

% padre(P, H): P es el padre de H. A diferencia del árbol de antepasados.pl,
% estos hechos forman una cadena sin hermanos: entre dos personas hay un único
% camino, y por eso la cantidad de generaciones que las separa es una sola.
padre(juan, ana).
padre(ana, luis).
padre(luis, eva).

%!  generaciones(?A, ?D, -N) is nondet.
%
%   D está N generaciones por debajo de A.
% Caso base: una generación, cuando A es el padre de D.
generaciones(A, D, 1) :-
    padre(A, D).
% Caso recursivo: una generación, más las que resten desde el hijo.
generaciones(A, D, N) :-
    padre(A, Hijo),
    generaciones(Hijo, D, Faltan),
    N is Faltan + 1.
