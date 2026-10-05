:- encoding(utf8).

% Capítulo 43 - El emparejamiento que conoce la conmutatividad.
%
% Una regla de colección como U * W + V * W ~> (U + V) * W unifica su
% patrón con el subtérmino tal como está escrito, y no se aplica a
% sin(x) * 2 + 3 * sin(x), que es la misma suma con los factores en otro
% orden. Este archivo prueba cada regla también sobre las variantes del
% subtérmino que intercambian los operandos de + y de *, hasta una
% profundidad dada.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- variante(a * b + c, 2, V).
%?- colectar_ac(sin(x) * 2 + 3 * sin(x) = 1, x, E).
%?- resolver_ac(sin(x) * 2 + 3 * sin(x) = 1, x, S).

:- module(emparejamiento,
          [ variante/3,
            colectar_ac/3,
            resolver_ac/3
          ]).

:- use_module(library(error)).
:- use_module(capitulo32, [apariciones/3, simplificar/2]).
:- use_module(reescribir, [reescribir/4]).
:- use_module(aislar, [aislar/3]).
:- use_module(colectar, []).
:- use_module(ecuaciones, [resolver/3]).

%!  variante(+T, +N:integer, -V) is multi.
%
%   V es T con los operandos de algunas sumas y productos intercambiados,
%   en los N niveles más altos de T. La primera respuesta es T mismo.
variante(T, N, V) :-
    (   N > 0,
        compound(T),
        compound_name_arguments(T, Op, [A, B])
    ->  N1 is N - 1,
        variante(A, N1, A1),
        variante(B, N1, B1),
        (   V =.. [Op, A1, B1]
        ;   conmutativa(Op),
            V =.. [Op, B1, A1]
        )
    ;   V = T
    ).

% conmutativa(Op): el operador binario Op es conmutativo.
conmutativa(+).
conmutativa(*).

%!  regla_ac(+X:atom, +S0, -S) is nondet.
%
%   S resulta de aplicar una regla de colección a una variante de S0 en
%   sus dos niveles más altos.
regla_ac(X, S0, S) :-
    variante(S0, 2, V),
    colectar:regla(X, V, S).

%!  colectar_ac(+Ecuacion0, +X:atom, -Ecuacion) is semidet.
%
%   Como colectar/3, pero cada regla se prueba también sobre las
%   variantes conmutativas de cada subtérmino.
colectar_ac(Ecuacion0, X, Ecuacion) :-
    apariciones(Ecuacion0, X, N0),
    once(( reescribir(regla_ac, X, Ecuacion0, Ecuacion),
           apariciones(Ecuacion, X, N),
           N < N0 )).

%!  resolver_ac(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = E, una solución de la Ecuacion cerrada: aísla si X
%   aparece una vez, colecta con colectar_ac/3 y vuelve a empezar, y si
%   ninguno se aplica usa resolver/3 de ecuaciones.pl.
resolver_ac(Ecuacion, X, Solucion) :-
    must_be(ground, Ecuacion),
    must_be(atom, X),
    resolver_ac_(Ecuacion, X, Solucion).

%!  resolver_ac_(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver_ac/3, sin verificar los argumentos.
resolver_ac_(Ecuacion, X, X = E) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, X = E0),
        simplificar(E0, E)
    ;   colectar_ac(Ecuacion, X, Ecuacion1)
    ->  resolver_ac_(Ecuacion1, X, X = E)
    ;   resolver(Ecuacion, X, X = E)
    ).
