:- encoding(utf8).

% Capítulo 43 - Versión 4 del programa que resuelve ecuaciones: la forma
% normal de un polinomio.
%
% forma_normal/3 lleva una expresión polinómica en la incógnita, con
% coeficientes numéricos, a la lista de sus monomios Grado-Coeficiente:
% los grados de mayor a menor, uno por grado, sin coeficientes nulos. La
% resta y el signo menos pasan a los coeficientes, los productos y las
% potencias se distribuyen, y los monomios del mismo grado se suman.
% polinomio_termino/3 escribe esa lista como una suma asociada a
% izquierda. La forma normal da dos métodos más: el polinomio de grado 1
% o 2, y la colección de un subtérmino polinómico.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- forma_normal((x + 1) * (x - 1) - 2 * (x - 3), x, Ms).
%?- forma_normal(x + 2 * x, x, Ms), polinomio_termino(Ms, x, T).
%?- resolver(x ^ 2 - 3 * x + 2 = 0, x, S).
%?- resolver(2 ^ x * 2 ^ (x + 1) = 32, x, S).

:- module(polinomio,
          [ resolver/3,
            forma_normal/3,
            polinomio_termino/3,
            normalizar/3,
            colectar_normal/3,
            resolver_polinomio/3
          ]).

:- use_module(library(error)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(terms)).
:- use_module(capitulo32, [apariciones/3, simplificar/2]).
:- use_module(aislar, [aislar/3]).
:- use_module(colectar, [colectar/3]).
:- use_module(atraer, [atraer/3]).
:- use_module(reescribir, [libre/2]).

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
%   Como resolver/3, sin verificar los argumentos ni simplificar. Prueba
%   los métodos en orden: aislar, el polinomio, colectar con las reglas,
%   colectar con la forma normal, y atraer.
resolver_(Ecuacion, X, Solucion) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, Solucion)
    ;   Ecuacion = (Izq = Der),
        forma_normal(Izq - Der, X, Ms)
    ->  resolver_polinomio(Ms, X, Solucion)
    ;   colectar(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ;   colectar_normal(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ;   atraer(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ).

%!  colectar_normal(+Ecuacion0, +X:atom, -Ecuacion) is semidet.
%
%   Ecuacion es Ecuacion0 con sus subtérminos polinómicos en forma normal,
%   si eso reduce las apariciones de X.
colectar_normal(Ecuacion0, X, Ecuacion) :-
    normalizar(Ecuacion0, X, Ecuacion),
    apariciones(Ecuacion0, X, N0),
    apariciones(Ecuacion, X, N),
    N < N0.

%!  normalizar(+E0, +X:atom, -E) is det.
%
%   E es E0 con cada subtérmino maximal que es un polinomio en X, con
%   coeficientes numéricos, escrito en forma normal.
normalizar(E0, X, E) :-
    normal(X, E0, E).

%!  normal(+X:atom, +E0, -E) is det.
%
%   Como normalizar/3, con la incógnita primero, para mapargs/3.
normal(X, E0, E) :-
    (   E0 \== X,
        \+ libre(X, E0),
        forma_normal(E0, X, Ms)
    ->  polinomio_termino(Ms, X, E)
    ;   compound(E0)
    ->  mapargs(normal(X), E0, E)
    ;   E = E0
    ).

%!  forma_normal(+E, +X:atom, -Ms:list(pair)) is semidet.
%
%   Ms son los monomios Grado-Coeficiente de la expresión cerrada E, un
%   polinomio en X con coeficientes numéricos: grados de mayor a menor,
%   uno por grado, sin coeficientes nulos. Falla si E no es un polinomio.
forma_normal(E, X, Ms) :-
    monomios(E, X, Ms0),
    semejantes(Ms0, Ms).

%!  monomios(+E, +X:atom, -Ms:list(pair)) is semidet.
%
%   Ms son los monomios Grado-Coeficiente de E, sin agrupar.
monomios(E, X, Ms) :-
    (   E == X
    ->  Ms = [1-1]
    ;   number(E)
    ->  Ms = [0-E]
    ;   E = U + V
    ->  monomios(U, X, MU),
        monomios(V, X, MV),
        append(MU, MV, Ms)
    ;   E = U - V
    ->  monomios(U, X, MU),
        monomios(V, X, MV),
        maplist(por(-1), MV, MV1),
        append(MU, MV1, Ms)
    ;   E = -U
    ->  monomios(U, X, MU),
        maplist(por(-1), MU, Ms)
    ;   E = U * V
    ->  monomios(U, X, MU),
        monomios(V, X, MV),
        producto(MU, MV, Ms)
    ;   E = U / V
    ->  forma_normal(V, X, [0-C]),
        monomios(U, X, MU),
        Inversa is 1 / C,
        maplist(por(Inversa), MU, Ms)
    ;   E = U ^ N,
        integer(N),
        N >= 0
    ->  monomios(U, X, MU),
        potencia(N, MU, Ms)
    ).

%!  por(+K:number, +M:pair, -P:pair) is det.
%
%   P es el monomio M multiplicado por la constante K.
por(K, G-C, G-C1) :-
    C1 is K * C.

%!  producto(+Ms1:list(pair), +Ms2:list(pair), -Ms:list(pair)) is det.
%
%   Ms es el producto de los polinomios Ms1 y Ms2, con los semejantes
%   sumados.
producto(Ms1, Ms2, Ms) :-
    findall(G-C,
            ( member(G1-C1, Ms1),
              member(G2-C2, Ms2),
              G is G1 + G2,
              C is C1 * C2 ),
            Ms0),
    semejantes(Ms0, Ms).

%!  potencia(+N:integer, +Ms:list(pair), -P:list(pair)) is det.
%
%   P es el polinomio Ms elevado a N.
potencia(N, Ms, P) :-
    (   N =:= 0
    ->  P = [0-1]
    ;   N1 is N - 1,
        potencia(N1, Ms, P1),
        producto(Ms, P1, P)
    ).

%!  semejantes(+Ms0:list(pair), -Ms:list(pair)) is det.
%
%   Ms tiene un monomio por grado de Ms0, con la suma de los coeficientes
%   de ese grado, de mayor a menor grado y sin los nulos.
semejantes(Ms0, Ms) :-
    keysort(Ms0, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    foldl(sumar_grupo, Grupos, [], Ms).

%!  sumar_grupo(+Grupo:pair, +Ms0:list(pair), -Ms:list(pair)) is det.
%
%   Ms es Ms0 con el monomio del Grupo Grado-Coeficientes delante, salvo
%   que los coeficientes sumen 0. Como los grupos llegan de menor a mayor
%   grado, la lista queda de mayor a menor.
sumar_grupo(G-Cs, Ms0, Ms) :-
    sum_list(Cs, C),
    (   C =:= 0
    ->  Ms = Ms0
    ;   Ms = [G-C|Ms0]
    ).

%!  polinomio_termino(+Ms:list(pair), +X:atom, -T) is det.
%
%   T es la suma, asociada a izquierda, de los monomios Ms en X; los
%   coeficientes negativos, salvo el del primero, se escriben restando.
polinomio_termino([], _, 0).
polinomio_termino([M|Ms], X, T) :-
    monomio(X, M, T0),
    foldl(sumar_monomio(X), Ms, T0, T).

%!  sumar_monomio(+X:atom, +M:pair, +T0, -T) is det.
%
%   T es la suma, o la resta si el coeficiente es negativo, de T0 y M.
sumar_monomio(X, G-C, T0, T) :-
    (   C < 0
    ->  C1 is -C,
        monomio(X, G-C1, M),
        T = T0 - M
    ;   monomio(X, G-C, M),
        T = T0 + M
    ).

%!  monomio(+X:atom, +M:pair, -T) is det.
%
%   T es el monomio Grado-Coeficiente M escrito como término.
monomio(_, 0-C, C) :-
    !.
monomio(X, 1-1, X) :-
    !.
monomio(X, 1-C, C * X) :-
    !.
monomio(X, G-1, X ^ G) :-
    !.
monomio(X, G-C, C * X ^ G).

%!  resolver_polinomio(+Ms:list(pair), +X:atom, -Solucion) is nondet.
%
%   Solucion es X = V, con V un número real, una raíz del polinomio de
%   grado 1 o 2 en forma normal Ms. Falla si el grado es otro, o si no
%   tiene raíces reales.
resolver_polinomio([1-A|Ms], X, X = V) :-
    coeficiente(0, Ms, B),
    V is -B / A.
resolver_polinomio([2-A|Ms], X, X = V) :-
    coeficiente(1, Ms, B),
    coeficiente(0, Ms, C),
    D is B * B - 4 * A * C,
    (   D =:= 0
    ->  V is -B / (2 * A)
    ;   D > 0,
        (   V is (-B + sqrt(D)) / (2 * A)
        ;   V is (-B - sqrt(D)) / (2 * A)
        )
    ).

%!  coeficiente(+G:integer, +Ms:list(pair), -C:number) is det.
%
%   C es el coeficiente de grado G en Ms, o 0 si no hay monomio de ese
%   grado.
coeficiente(G, Ms, C) :-
    (   memberchk(G-C0, Ms)
    ->  C = C0
    ;   C = 0
    ).
