:- encoding(utf8).

% Capítulo 43 - El intercambio de funciones: la raíz cuadrada.
%
% Una raíz cuadrada que contiene la incógnita, cuando la incógnita
% aparece también fuera de ella, se aísla como si fuera una incógnita
% propia y se eleva al cuadrado: sqrt(U) = R pasa a ser U = R ^ 2, una
% ecuación sin esa raíz. Si R tiene otra raíz, el cuadrado se desarrolla
% para que esa raíz quede como un sumando que se puede aislar. Elevar al
% cuadrado agrega las soluciones de sqrt(U) = -R, y por eso cada valor se
% comprueba en la ecuación original.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- intercambiar(sqrt(x + 3) = x + 1, x, E).
%?- resolver_intercambio(sqrt(x + 3) = x + 1, x, S).
%?- valores_intercambio(sqrt(x + 3) = x + 1, x, Vs).
%?- valores_intercambio(sqrt(5 * x - 25) - sqrt(x - 1) = 2, x, Vs).

:- module(intercambio,
          [ intercambiar/3,
            resolver_intercambio/3,
            valores_intercambio/3,
            raices_con/3,
            desarrollar/2
          ]).

:- use_module(library(error)).
:- use_module(library(terms)).
:- use_module(library(apply)).
:- use_module(reescribir, [con/2, libre/2]).
:- use_module(aislar, [aislar/3]).
:- use_module(ecuaciones, [resolver/3]).

%!  intercambiar(+Ecuacion, +X:atom, -Ecuacion1) is semidet.
%
%   Ecuacion1 resulta de aislar en la Ecuacion la primera raíz cuadrada
%   sqrt(U) que contiene X, como si fuera una incógnita, y de elevar al
%   cuadrado los dos lados: U = R2, con R2 el cuadrado de R desarrollado
%   por desarrollar/2. Se acepta solo si Ecuacion1 tiene menos raíces
%   cuadradas con X que la Ecuacion.
intercambiar(Ecuacion, X, U = R2) :-
    raices_con(Ecuacion, X, N0),
    N0 > 0,
    libre(z, Ecuacion),
    once(( sub_term(S, Ecuacion),
           S = sqrt(U),
           con(X, U) )),
    mapsubterms(reemplazo(S, z), Ecuacion, Ecuacion0),
    once(aislar(Ecuacion0, z, z = R)),
    desarrollar(R ^ 2, R2),
    raices_con(U = R2, X, N),
    N < N0.

%!  desarrollar(+E0, -E) is det.
%
%   E es E0 con el cuadrado de una raíz cuadrada reemplazado por su
%   argumento, y el cuadrado de una suma o una resta con una raíz cuadrada
%   desarrollado: (A + sqrt(U)) ^ 2 pasa a ser A ^ 2 + 2 * A * sqrt(U) + U.
desarrollar(E0, E) :-
    (   cuadrado(E0, E1)
    ->  E = E1
    ;   compound(E0)
    ->  mapargs(desarrollar, E0, E)
    ;   E = E0
    ).

%!  cuadrado(+T, -E) is semidet.
%
%   E es el desarrollo del cuadrado T.
cuadrado(sqrt(U) ^ 2, U).
cuadrado((A + sqrt(U)) ^ 2, A ^ 2 + 2 * A * sqrt(U) + U).
cuadrado((A - sqrt(U)) ^ 2, A ^ 2 - 2 * A * sqrt(U) + U).
cuadrado((sqrt(U) + A) ^ 2, U + 2 * A * sqrt(U) + A ^ 2).
cuadrado((sqrt(U) - A) ^ 2, U - 2 * A * sqrt(U) + A ^ 2).

%!  reemplazo(+S, +Nuevo, +T0, -T) is semidet.
%
%   T es Nuevo si T0 es idéntico a S.
reemplazo(S, Nuevo, T0, Nuevo) :-
    T0 == S.

%!  raices_con(+E, +X:atom, -N:integer) is det.
%
%   N es la cantidad de raíces cuadradas de E que contienen X.
raices_con(E, X, N) :-
    aggregate_all(count,
                  ( sub_term(S, E),
                    nonvar(S),
                    S = sqrt(U),
                    con(X, U) ),
                  N).

%!  resolver_intercambio(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es una solución X = E de la Ecuacion, o de la ecuación que
%   resulta de intercambiar/3 si resolver/3 no da ninguna. Puede ser una
%   solución espuria: valores_intercambio/3 las descarta.
resolver_intercambio(Ecuacion, X, Solucion) :-
    must_be(ground, Ecuacion),
    must_be(atom, X),
    (   resolver(Ecuacion, X, Solucion)
    *-> true
    ;   intercambiar(Ecuacion, X, Ecuacion1),
        resolver_intercambio(Ecuacion1, X, Solucion)
    ).

%!  valores_intercambio(+Ecuacion, +X:atom, -Vs:list(number)) is det.
%
%   Vs son los valores de las soluciones de resolver_intercambio/3 que
%   cumplen la Ecuacion original, de menor a mayor y sin repetir. Sumar 0
%   lleva el -0.0 de una raíz nula a 0.0.
valores_intercambio(Ecuacion, X, Vs) :-
    findall(V,
            ( resolver_intercambio(Ecuacion, X, X = E),
              catch(V is E + 0, error(evaluation_error(_), _), fail),
              cumple(Ecuacion, X, V) ),
            Vs0),
    sort(Vs0, Vs).

%!  cumple(+Ecuacion, +X:atom, +V:number) is semidet.
%
%   Los dos lados de la Ecuacion tienen valores reales que difieren en
%   menos de 10^-9 con X = V.
cumple(Izq = Der, X, V) :-
    mapsubterms(reemplazo(X, V), Izq = Der, I = D),
    catch(( A is I, B is D ), error(evaluation_error(_), _), fail),
    abs(A - B) =< 1.0e-9 * max(1, max(abs(A), abs(B))).
