:- encoding(utf8).

% Capítulo 43 - Soluciones de los ejercicios 6, 7, 8 y 12: métodos nuevos
% alrededor del programa.
%
% resolver_factores/3 (factorización), resolver_homogeneo/3
% (homogeneización) y resolver_bicuadrada/3 prueban su método y, si no
% se aplica, usan resolver/3 de ecuaciones.pl. resolver_parcial/3 es el
% despachador de la versión 4 con el aislamiento parcial, que aísla el
% menor subtérmino que contiene todas las apariciones de la incógnita.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- resolver_factores(cos(x) * (1 - 2 * sin(x)) = 0, x, S).
%?- resolver_homogeneo(2 ^ (2 * x) - 5 * 2 ^ (x + 1) + 16 = 0, x, S).
%?- resolver_bicuadrada(x ^ 4 - 5 * x ^ 2 + 4 = 0, x, S).
%?- resolver_parcial(sqrt(x) * sqrt(x + 5) = 6, x, S).

:- module(soluciones_metodos,
          [ resolver_factores/3,
            resolver_homogeneo/3,
            resolver_bicuadrada/3,
            resolver_parcial/3,
            aislar_parcial/3
          ]).

:- use_module(library(error)).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(terms)).
:- use_module(capitulo32, [apariciones/3, simplificar/2]).
:- use_module(reescribir).
:- use_module(aislar, [aislar/3, posicion/3]).
:- use_module(colectar, [colectar/3]).
:- use_module(atraer, [atraer/3]).
:- use_module(polinomio, [ forma_normal/3,
                           polinomio_termino/3,
                           colectar_normal/3,
                           resolver_polinomio/3
                         ]).
:- use_module(ecuaciones, [resolver/3]).

% Ejercicio 6 ---------------------------------------------------------

%!  resolver_factores(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Si la Ecuacion es A * B = 0, Solucion es una solución de F = 0 para
%   uno de los factores F que contienen X; si no, una solución de
%   resolver/3.
resolver_factores(Ecuacion, X, Solucion) :-
    (   Ecuacion = (A * B = 0)
    ->  factores(A * B, X, Fs0),
        list_to_set(Fs0, Fs),
        member(F, Fs),
        resolver_factores(F = 0, X, Solucion)
    ;   resolver(Ecuacion, X, Solucion)
    ).

%!  factores(+E, +X:atom, -Fs:list) is det.
%
%   Fs son los factores del producto E que contienen X, en orden.
factores(E, X, Fs) :-
    (   E = A * B
    ->  factores(A, X, FA),
        factores(B, X, FB),
        append(FA, FB, Fs)
    ;   con(X, E)
    ->  Fs = [E]
    ;   Fs = []
    ).

% Ejercicio 7 ---------------------------------------------------------

%!  resolver_homogeneo(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Si todas las potencias B ^ E de la Ecuacion con X en el exponente
%   tienen la misma base B y un exponente lineal C * X + D, con C entero
%   positivo, la Ecuacion se escribe como un polinomio en u = B ^ X, se
%   resuelve en u, y Solucion es una solución de B ^ X = u. Si no, una
%   solución de resolver/3.
resolver_homogeneo(Ecuacion, X, Solucion) :-
    (   homogeneizar(Ecuacion, X, u, B, Ecuacion1)
    ->  resolver(Ecuacion1, u, u = V),
        resolver(B ^ X = V, X, Solucion)
    ;   resolver(Ecuacion, X, Solucion)
    ).

%!  homogeneizar(+Ecuacion, +X:atom, +U:atom, -B, -Ecuacion1) is semidet.
%
%   Ecuacion1 es la Ecuacion con cada potencia B ^ (C * X + D) escrita
%   como B ^ D * U ^ C, y sin X. U no debe aparecer en la Ecuacion.
homogeneizar(Ecuacion, X, U, B, Ecuacion1) :-
    libre(U, Ecuacion),
    once(( sub_term(B ^ E, Ecuacion),
           libre(X, B),
           con(X, E) )),
    homogeneo(B, X, U, Ecuacion, Ecuacion1),
    libre(X, Ecuacion1).

%!  homogeneo(+B, +X:atom, +U:atom, +E0, -E) is semidet.
%
%   E es E0 con cada B ^ (C * X + D) escrita como B ^ D * U ^ C. Falla si
%   un exponente con X no es lineal con C entero positivo.
homogeneo(B, X, U, E0, E) :-
    (   E0 = B ^ Exponente,
        con(X, Exponente)
    ->  forma_normal(Exponente, X, Ms),
        lineal(Ms, C, D),
        integer(C),
        C > 0,
        potencia(U, C, P),
        (   D =:= 0
        ->  E = P
        ;   E = B ^ D * P
        )
    ;   compound(E0)
    ->  mapargs(homogeneo(B, X, U), E0, E)
    ;   E = E0
    ).

%!  lineal(+Ms:list(pair), -C:number, -D:number) is semidet.
%
%   Ms es la forma normal de C * X + D, con C distinto de 0.
lineal([1-C], C, 0).
lineal([1-C, 0-D], C, D).

%!  potencia(+U:atom, +C:integer, -P) is det.
%
%   P es U elevado a C, escrito U si C es 1.
potencia(U, C, P) :-
    (   C =:= 1
    ->  P = U
    ;   P = U ^ C
    ).

% Ejercicio 8 ---------------------------------------------------------

%!  resolver_bicuadrada(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Si la Ecuacion es un polinomio en X de grado mayor que 2 con todos los
%   grados pares, se resuelve como un polinomio en u = X ^ 2, y Solucion
%   es una solución de X ^ 2 = u. Si no, una solución de resolver/3.
resolver_bicuadrada(Izq = Der, X, Solucion) :-
    (   forma_normal(Izq - Der, X, Ms),
        Ms = [G-_|_],
        G > 2,
        maplist(grado_par, Ms)
    ->  maplist(mitad, Ms, Ms2),
        polinomio_termino(Ms2, u, T),
        resolver(T = 0, u, u = V),
        resolver(X ^ 2 = V, X, Solucion)
    ;   resolver(Izq = Der, X, Solucion)
    ).

%!  grado_par(+M:pair) is semidet.
%
%   El monomio M tiene grado par.
grado_par(G-_) :-
    G mod 2 =:= 0.

%!  mitad(+M:pair, -M2:pair) is det.
%
%   M2 es el monomio M con la mitad del grado.
mitad(G-C, G2-C) :-
    G2 is G // 2.

% Ejercicio 12 --------------------------------------------------------

% La atracción de las raíces cuadradas, agregada a regla/3 de atraer.pl.
:- multifile atraer:regla/3.

atraer:regla(X, sqrt(U) * sqrt(V), sqrt(U * V)) :-
    con(X, U),
    con(X, V).

%!  resolver_parcial(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver/3 de polinomio.pl, con el aislamiento parcial después
%   del método del polinomio.
resolver_parcial(Ecuacion, X, X = E) :-
    must_be(ground, Ecuacion),
    must_be(atom, X),
    parcial(Ecuacion, X, X = E0),
    simplificar(E0, E).

%!  parcial(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver_parcial/3, sin verificar los argumentos ni simplificar.
parcial(Ecuacion, X, Solucion) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, Solucion)
    ;   Ecuacion = (Izq = Der),
        forma_normal(Izq - Der, X, Ms)
    ->  resolver_polinomio(Ms, X, Solucion)
    ;   findall(E, aislar_parcial(Ecuacion, X, E), [E1|Es])
    ->  member(E2, [E1|Es]),
        parcial(E2, X, Solucion)
    ;   colectar(Ecuacion, X, Ecuacion1)
    ->  parcial(Ecuacion1, X, Solucion)
    ;   colectar_normal(Ecuacion, X, Ecuacion1)
    ->  parcial(Ecuacion1, X, Solucion)
    ;   atraer(Ecuacion, X, Ecuacion1)
    ->  parcial(Ecuacion1, X, Solucion)
    ).

%!  aislar_parcial(+Ecuacion, +X:atom, -Ecuacion1) is nondet.
%
%   Ecuacion1 es S = R, con S el menor subtérmino de la Ecuacion que
%   contiene todas las apariciones de X, si es menor que un lado entero.
%   R resulta de aislar S como si fuera una incógnita: hay una respuesta
%   por cada solución que separan los axiomas.
aislar_parcial(Ecuacion, X, S = R) :-
    findall(P, posicion(X, Ecuacion, P), [P1|Ps]),
    Ps \== [],
    foldl(prefijo_comun, Ps, P1, Comun),
    Comun = [_, _|_],
    subtermino(Comun, Ecuacion, S),
    libre(z, Ecuacion),
    mapsubterms(reemplazo(S, z), Ecuacion, Ecuacion0),
    aislar(Ecuacion0, z, z = R).

%!  prefijo_comun(+P:list, +Q:list, -R:list) is det.
%
%   R es el prefijo más largo común a P y Q.
prefijo_comun(P, Q, R) :-
    (   P = [A|P1],
        Q = [B|Q1],
        A == B
    ->  R = [A|R1],
        prefijo_comun(P1, Q1, R1)
    ;   R = []
    ).

%!  subtermino(+Camino:list(integer), +T, -S) is det.
%
%   S es el subtérmino de T en la posición Camino.
subtermino([], T, T).
subtermino([N|Camino], T, S) :-
    arg(N, T, A),
    subtermino(Camino, A, S).

%!  reemplazo(+S, +Nuevo, +T0, -T) is semidet.
%
%   T es Nuevo si T0 es idéntico a S; falla si no, y entonces
%   mapsubterms/3 sigue por los argumentos de T0.
reemplazo(S, Nuevo, T0, Nuevo) :-
    T0 == S.
