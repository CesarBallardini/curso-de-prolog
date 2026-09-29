:- encoding(utf8).

% Capítulo 43 - Soluciones de los ejercicios 3, 4 y 5: reglas de colección
% y de atracción agregadas al programa.
%
% Las reglas se escriben con la notación de reescribir.pl dentro de
% coleccion/1 o de atraccion/1, y term_expansion/2 las carga como
% cláusulas de regla/3 de colectar.pl o de atraer.pl, que son multifile.
% colectar_sin_medida/3 y resolver_sin_medida/3 son la versión 2 sin la
% condición de que las apariciones disminuyan.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- colectar:resolver(sin(x) ^ 2 * sin(x) = 0.125, x, S).
%?- colectar:resolver(x * x + x = 6, x, S).
%?- ecuaciones:valores(exp(2 * x) / exp(x) = 5, x, Vs).

:- module(soluciones_reglas,
          [ colectar_sin_medida/3,
            resolver_sin_medida/3
          ]).

:- use_module(reescribir).
:- use_module(capitulo32, [apariciones/3]).
:- use_module(aislar, [aislar/3]).
:- use_module(colectar, []).
:- use_module(atraer, []).
:- use_module(ecuaciones, []).

:- multifile
    colectar:regla/3,
    atraer:regla/3.

%!  term_expansion(+Termino, -Clausula) is semidet.
%
%   coleccion(Regla) se carga como una cláusula de colectar:regla/3, y
%   atraccion(Regla) como una de atraer:regla/3.
term_expansion(coleccion(Regla), colectar:Clausula) :-
    expandir_regla(Regla, Clausula).
term_expansion(atraccion(Regla), atraer:Clausula) :-
    expandir_regla(Regla, Clausula).

% Ejercicio 3: una regla que aumenta las apariciones.
coleccion((W ^ 2 ~> W * W si con(W))).

% Ejercicio 4: potencias de la misma base y un sumando sin coeficiente.
coleccion((W ^ M * W ^ N ~> W ^ (M + N) si con(W), libre(M), libre(N))).
coleccion((W ^ N * W ~> W ^ (N + 1) si con(W), libre(N))).
coleccion((W * W ^ N ~> W ^ (N + 1) si con(W), libre(N))).
coleccion((W + U * W ~> (1 + U) * W si con(W), libre(U))).

% Ejercicio 5: cocientes de exponenciales de la misma base.
atraccion((exp(U) / exp(V) ~> exp(U - V) si con(U), con(V))).
atraccion((A ^ U / A ^ V ~> A ^ (U - V) si libre(A), con(U), con(V))).

%!  resolver_sin_medida(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver_/3 de colectar.pl, con colectar_sin_medida/3: puede no
%   terminar.
resolver_sin_medida(Ecuacion, X, Solucion) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, Solucion)
    ;   colectar_sin_medida(Ecuacion, X, Ecuacion1)
    ->  resolver_sin_medida(Ecuacion1, X, Solucion)
    ).

%!  colectar_sin_medida(+Ecuacion0, +X:atom, -Ecuacion) is semidet.
%
%   Ecuacion resulta de reescribir un subtérmino de Ecuacion0 con la
%   primera regla de colección que se aplica, reduzca o no las
%   apariciones de X.
colectar_sin_medida(Ecuacion0, X, Ecuacion) :-
    once(reescribir(colectar:regla, X, Ecuacion0, Ecuacion)).
