:- encoding(utf8).

% Capítulo 43 - Soluciones de los ejercicios 9 y 10: el respaldo numérico
% con más derivadas, y los pasos de Newton.
%
% derivar_mas/3 deriva también el cociente, el signo menos, sin/1,
% cos/1, exp/1 y log/1, y simplifica con simplificar/2 del capítulo 32.
% resolver_mas/3 usa resolver/3 de ecuaciones.pl y, si no da ninguna
% solución, las raíces que Newton halla con derivar_mas/3.
% pasos_newton/5 da los primeros valores que recorre Newton.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- derivar_mas(cos(x) - x, x, D).
%?- resolver_mas(cos(x) = x, x, S).
%?- resolver_mas(x + 1 = 1 / x, x, S).
%?- pasos_newton(x ^ 3 - 2 * x + 2, x, 0, 5, Xs).

:- module(soluciones_numericas,
          [ derivar_mas/3,
            resolver_mas/3,
            pasos_newton/5
          ]).

:- use_module(library(error)).
:- use_module(capitulo32, [simplificar/2, derivar/3, evaluar/3]).
:- use_module(ecuaciones, [resolver/3, raices/4]).

% Ejercicio 9 ---------------------------------------------------------

%!  derivar_mas(+E, +X:atom, -D) is det.
%
%   D es la derivada simplificada de la expresión cerrada E respecto de X.
%   E usa +, -, *, /, ^ con exponente numérico, sin/1, cos/1, exp/1 y
%   log/1; cualquier otra operación produce un error de dominio.
derivar_mas(E, X, D) :-
    must_be(ground, E),
    must_be(atom, X),
    derivada(E, X, D0),
    simplificar(D0, D).

%!  derivada(+E, +X:atom, -D) is det.
%
%   D es la derivada de E respecto de X, sin simplificar.
derivada(E, X, D) :-
    (   E == X
    ->  D = 1
    ;   atomic(E)
    ->  D = 0
    ;   E = U + V
    ->  D = DU + DV,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = U - V
    ->  D = DU - DV,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = -U
    ->  D = -DU,
        derivada(U, X, DU)
    ;   E = U * V
    ->  D = DU * V + U * DV,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = U / V
    ->  D = (DU * V - U * DV) / V ^ 2,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = U ^ N,
        number(N)
    ->  N1 is N - 1,
        D = N * U ^ N1 * DU,
        derivada(U, X, DU)
    ;   E = sin(U)
    ->  D = cos(U) * DU,
        derivada(U, X, DU)
    ;   E = cos(U)
    ->  D = -sin(U) * DU,
        derivada(U, X, DU)
    ;   E = exp(U)
    ->  D = exp(U) * DU,
        derivada(U, X, DU)
    ;   E = log(U)
    ->  D = DU / U,
        derivada(U, X, DU)
    ;   domain_error(expresion_derivable, E)
    ).

%!  resolver_mas(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es una solución de resolver/3 de ecuaciones.pl; si no hay
%   ninguna, X = R con R una raíz que Newton halla con derivar_mas/3.
resolver_mas(Ecuacion, X, Solucion) :-
    (   resolver(Ecuacion, X, Solucion)
    *-> true
    ;   Ecuacion = (Izq = Der),
        F = Izq - Der,
        derivar_mas(F, X, DF),
        raices(F, DF, X, Rs),
        member(R, Rs),
        Solucion = (X = R)
    ).

% Ejercicio 10 --------------------------------------------------------

%!  pasos_newton(+F, +X:atom, +X0:number, +N:integer, -Xs:list) is det.
%
%   Xs son los valores que recorre el método de Newton sobre la expresión
%   F en X desde X0, con X0 primero y N pasos como máximo; la lista se
%   corta antes si la derivada se anula.
pasos_newton(F, X, X0, N, [X0|Xs]) :-
    derivar(F, X, DF),
    pasos(F, DF, X, X0, N, Xs).

%!  pasos(+F, +DF, +X:atom, +X0:number, +N:integer, -Xs:list) is det.
%
%   Como pasos_newton/5, con la derivada DF calculada y sin X0.
pasos(F, DF, X, X0, N, Xs) :-
    (   N > 0,
        evaluar(DF, [X-X0], Pendiente),
        Pendiente =\= 0
    ->  evaluar(F, [X-X0], Y),
        X1 is X0 - Y / Pendiente,
        N1 is N - 1,
        Xs = [X1|Xs1],
        pasos(F, DF, X, X1, N1, Xs1)
    ;   Xs = []
    ).
