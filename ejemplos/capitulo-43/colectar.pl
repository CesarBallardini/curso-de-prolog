:- encoding(utf8).

% Capítulo 43 - Versión 2 del programa que resuelve ecuaciones: la
% colección.
%
% Si la incógnita aparece más de una vez, una regla de colección
% reescribe un subtérmino de la ecuación en otro con menos apariciones.
% Las reglas se escriben con la notación de reescribir.pl y se cargan
% como cláusulas de regla/3. Cuando queda una sola aparición, el
% aislamiento de la versión 1 termina el trabajo.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- resolver(2 * x + 3 * x = 10, x, S).
%?- colectar(2 * sin(x) + 3 * sin(x) = 1, x, E).
%?- resolver(2 * sin(x) + 3 * sin(x) = 1, x, S).
%?- resolver(log(x + 1) + log(x - 1) = 3, x, S).

:- module(colectar,
          [ resolver/3,
            colectar/3
          ]).

:- use_module(library(error)).
:- use_module(capitulo32, [apariciones/3, simplificar/2]).
:- use_module(aislar, [aislar/3]).
:- use_module(reescribir).

%!  term_expansion(+Regla, -Clausula) is semidet.
%
%   Una regla Izq ~> Der si Condicion se carga como una cláusula de
%   regla/3.
term_expansion(Regla, Clausula) :-
    expandir_regla(Regla, Clausula).

% regla(X, Izq, Der): las reglas de abajo, cargadas como cláusulas. Es
% multifile: otro archivo puede agregar reglas.
:- multifile regla/3.

W * W ~> W ^ 2 si con(W).
U * W + V * W ~> (U + V) * W si con(W), libre(U), libre(V).
W * U + W * V ~> W * (U + V) si con(W), libre(U), libre(V).
U * W - V * W ~> (U - V) * W si con(W), libre(U), libre(V).
U * W + W ~> (U + 1) * W si con(W), libre(U).
W + W ~> 2 * W si con(W).
(W + U) * (W - U) ~> W ^ 2 - U * U si con(W), libre(U).

%!  resolver(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = E, con E sin X, una solución de la Ecuacion cerrada
%   en la incógnita X, simplificada. Hay una respuesta por solución.
resolver(Ecuacion, X, X = E) :-
    must_be(ground, Ecuacion),
    must_be(atom, X),
    resolver_(Ecuacion, X, X = E0),
    simplificar(E0, E).

%!  resolver_(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver/3, sin verificar los argumentos ni simplificar: aísla
%   la incógnita si aparece una vez, y si no, colecta y vuelve a empezar.
resolver_(Ecuacion, X, Solucion) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, Solucion)
    ;   colectar(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ).

%!  colectar(+Ecuacion0, +X:atom, -Ecuacion) is semidet.
%
%   Ecuacion resulta de reescribir un subtérmino de Ecuacion0 con la
%   primera regla de colección que reduce las apariciones de X.
colectar(Ecuacion0, X, Ecuacion) :-
    apariciones(Ecuacion0, X, N0),
    once(( reescribir(regla, X, Ecuacion0, Ecuacion),
           apariciones(Ecuacion, X, N),
           N < N0 )).
