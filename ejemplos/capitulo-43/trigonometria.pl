:- encoding(utf8).

% Capítulo 43 - La homogeneización trigonométrica.
%
% Una ecuación en la que la incógnita aparece solo dentro de senos y
% cosenos, de x o de 2 * x, se escribe como un polinomio en un término
% reducido, sin(x) o cos(x), con las identidades del ángulo doble y del
% cuadrado. El polinomio se resuelve en una incógnita nueva, u, y cada
% valor de u da una ecuación sin(x) = V o cos(x) = V que el aislamiento
% resuelve.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- reducir_trigonometrica(cos(2 * x) - sin(x) = 0, x, u, F, E).
%?- resolver_trigonometrica(cos(2 * x) - sin(x) = 0, x, S).
%?- resolver_trigonometrica(2 * sin(x) ^ 2 + 3 * cos(x) = 3, x, S).

:- module(trigonometria,
          [ resolver_trigonometrica/3,
            reducir_trigonometrica/5,
            en_funcion_de/5
          ]).

:- use_module(library(error)).
:- use_module(reescribir, [libre/2]).
:- use_module(ecuaciones, [resolver/3]).

%!  resolver_trigonometrica(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = E, una solución de la Ecuacion cerrada. Si la Ecuacion
%   se escribe como un polinomio en sin(X) o en cos(X), lo resuelve en ese
%   término; si no, usa resolver/3 de ecuaciones.pl.
resolver_trigonometrica(Ecuacion, X, Solucion) :-
    must_be(ground, Ecuacion),
    must_be(atom, X),
    (   reducir_trigonometrica(Ecuacion, X, u, F, Ecuacion1)
    ->  resolver(Ecuacion1, u, u = V),
        \+ fuera_de_rango(V),
        T =.. [F, X],
        resolver(T = V, X, Solucion)
    ;   resolver(Ecuacion, X, Solucion)
    ).

%!  fuera_de_rango(+V) is semidet.
%
%   La expresión cerrada V tiene un valor real de valor absoluto mayor
%   que 1: ningún seno ni coseno real lo alcanza.
fuera_de_rango(V) :-
    catch(W is V, error(evaluation_error(_), _), fail),
    abs(W) > 1.

%!  reducir_trigonometrica(+Ecuacion, +X:atom, +U:atom, -F, -Ecuacion1)
%!      is semidet.
%
%   Ecuacion1 es la Ecuacion escrita en función de U = F(X), con F el
%   primero de sin y cos que lo permite, y X ya no aparece en ella. U no
%   debe aparecer en la Ecuacion.
reducir_trigonometrica(Ecuacion, X, U, F, Ecuacion1) :-
    libre(U, Ecuacion),
    member(F, [sin, cos]),
    en_funcion_de(F, X, U, Ecuacion, Ecuacion1),
    libre(X, Ecuacion1),
    !.

%!  en_funcion_de(+F, +X:atom, +U:atom, +E0, -E) is det.
%
%   E es E0 con cada término trigonométrico de X reescrito en función de
%   U = F(X) con las identidades de reducida/5. Lo que no tiene identidad
%   queda como está.
en_funcion_de(F, X, U, E0, E) :-
    (   reducida(F, X, U, E0, E1)
    ->  E = E1
    ;   compound(E0)
    ->  mapargs(en_funcion_de(F, X, U), E0, E)
    ;   E = E0
    ).

%!  reducida(+F, +X:atom, +U:atom, +T, -E) is semidet.
%
%   E es el término trigonométrico T escrito en función de U = F(X).
reducida(F, X, U, T, U) :-
    T =.. [F, Y],
    Y == X.
reducida(sin, X, U, cos(Y) ^ 2, 1 - U ^ 2) :-
    Y == X.
reducida(cos, X, U, sin(Y) ^ 2, 1 - U ^ 2) :-
    Y == X.
reducida(sin, X, U, cos(2 * Y), 1 - 2 * U ^ 2) :-
    Y == X.
reducida(cos, X, U, cos(2 * Y), 2 * U ^ 2 - 1) :-
    Y == X.
