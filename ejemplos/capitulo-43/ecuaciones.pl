:- encoding(utf8).

% Capítulo 43 - Versión 5 del programa que resuelve ecuaciones: el
% respaldo numérico y la comprobación.
%
% resolver/3 usa los métodos simbólicos de la versión 4; si ninguno da
% una solución, busca raíces de Izq - Der con el método de Newton, desde
% varios valores iniciales, con derivar/3 y evaluar/3 del capítulo 32.
% valores/3 calcula el valor de cada solución y conserva solo las que
% tienen un valor real y cumplen la ecuación original.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- resolver(x ^ 3 - 2 * x - 5 = 0, x, S).
%?- valores(log(x + 1) + log(x - 1) = 3, x, Vs).
%?- newton(x ^ 3 - 2 * x - 5, x, 1, R).
%?- valores(x ^ 4 - 5 * x ^ 2 + 4 = 0, x, Vs).

:- module(ecuaciones,
          [ resolver/3,
            valores/3,
            raices/4,
            newton/4
          ]).

:- use_module(library(error)).
:- use_module(library(apply)).
:- use_module(capitulo32, [derivar/3, evaluar/3]).
:- use_module(polinomio, [resolver/3 as resolver_simbolico]).

%!  resolver(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = E, una solución de la Ecuacion cerrada en la
%   incógnita X: E sin X, si la da un método simbólico; si ninguno la da,
%   E es un número, una raíz hallada con el método de Newton.
resolver(Ecuacion, X, Solucion) :-
    (   resolver_simbolico(Ecuacion, X, Solucion)
    *-> true
    ;   resolver_numerico(Ecuacion, X, Solucion)
    ).

%!  resolver_numerico(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = R, con R una raíz de Izq - Der hallada con el método
%   de Newton desde uno de los valores iniciales, de menor a mayor y sin
%   repetir. Falla si derivar/3 no puede derivar Izq - Der.
resolver_numerico(Izq = Der, X, X = R) :-
    F = Izq - Der,
    catch(derivar(F, X, DF),
          error(domain_error(expresion_derivable, _), _),
          fail),
    raices(F, DF, X, Rs),
    member(R, Rs).

%!  raices(+F, +DF, +X:atom, -Rs:list(number)) is det.
%
%   Rs son las raíces de la expresión F en X que el método de Newton, con
%   la derivada DF, halla desde los valores iniciales: de menor a mayor y
%   sin repetir.
raices(F, DF, X, Rs) :-
    findall(R,
            ( inicial(X0),
              newton(F, DF, X, X0, R) ),
            Rs0),
    distintos(Rs0, Rs).

% inicial(X0): X0 es uno de los valores desde los que empieza Newton.
inicial(-10).
inicial(-1).
inicial(1).
inicial(10).

%!  newton(+F, +X:atom, +X0:number, -R:number) is semidet.
%
%   R es una raíz de la expresión F en X, hallada con el método de Newton
%   desde X0. Falla si la derivada se anula, si F no tiene valor real en
%   algún paso, o si no converge en 100 pasos.
newton(F, X, X0, R) :-
    derivar(F, X, DF),
    newton(F, DF, X, X0, R).

%!  newton(+F, +DF, +X:atom, +X0:number, -R:number) is semidet.
%
%   Como newton/4, con la derivada DF de F ya calculada.
newton(F, DF, X, X0, R) :-
    newton(F, DF, X, X0, 100, R).

%!  newton(+F, +DF, +X:atom, +X0:number, +N:integer, -R:number) is semidet.
%
%   Como newton/5, con N pasos como máximo.
newton(F, DF, X, X0, N, R) :-
    N > 0,
    valor(F, X, X0, Y),
    valor(DF, X, X0, Pendiente),
    Pendiente =\= 0,
    X1 is X0 - Y / Pendiente,
    (   cerca(X0, X1)
    ->  R = X1
    ;   N1 is N - 1,
        newton(F, DF, X, X1, N1, R)
    ).

%!  valor(+E, +X:atom, +V:number, -Y:number) is semidet.
%
%   Y es el valor de E con X = V. Falla si ese valor no es un número real.
valor(E, X, V, Y) :-
    catch(evaluar(E, [X-V], Y),
          error(evaluation_error(_), _),
          fail).

%!  cerca(+A:number, +B:number) is semidet.
%
%   A y B difieren en menos de una parte en 10^9 del mayor de 1, |A|, |B|.
cerca(A, B) :-
    abs(A - B) =< 1.0e-9 * max(1, max(abs(A), abs(B))).

%!  valores(+Ecuacion, +X:atom, -Vs:list(number)) is det.
%
%   Vs son los valores de las soluciones de resolver/3 que son números
%   reales y cumplen la Ecuacion, de menor a mayor y sin repetir.
valores(Ecuacion, X, Vs) :-
    findall(V,
            ( resolver(Ecuacion, X, X = E),
              catch(V is E, error(evaluation_error(_), _), fail),
              cumple(Ecuacion, X, V) ),
            Vs0),
    distintos(Vs0, Vs).

%!  cumple(+Ecuacion, +X:atom, +V:number) is semidet.
%
%   Los dos lados de la Ecuacion tienen valores reales y cercanos con
%   X = V.
cumple(Izq = Der, X, V) :-
    valor(Izq, X, V, A),
    valor(Der, X, V, B),
    cerca(A, B).

%!  distintos(+Vs0:list(number), -Vs:list(number)) is det.
%
%   Vs son los números de Vs0 de menor a mayor, con uno solo de cada
%   grupo de números cercanos.
distintos(Vs0, Vs) :-
    msort(Vs0, Ordenados),
    sin_cercanos(Ordenados, Vs).

%!  sin_cercanos(+Vs0:list(number), -Vs:list(number)) is det.
%
%   Vs es la lista ordenada Vs0 sin los números cercanos al anterior que
%   se conserva.
sin_cercanos([], []).
sin_cercanos([V|Vs0], [V|Vs]) :-
    exclude(cerca(V), Vs0, Vs1),
    sin_cercanos(Vs1, Vs).
