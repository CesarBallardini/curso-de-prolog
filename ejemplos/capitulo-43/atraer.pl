:- encoding(utf8).

% Capítulo 43 - Versión 3 del programa que resuelve ecuaciones: la
% atracción.
%
% Una regla de atracción no reduce las apariciones de la incógnita: las
% acerca, y deja a otra regla de colección, o al aislamiento, la tarea de
% reducirlas. La distancia entre las apariciones es la suma de sus
% profundidades medidas desde el menor subtérmino que las contiene a
% todas; una regla de atracción se acepta solo si la reduce.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- distancia(log(x + 1) + log(x - 1) = 3, x, D).
%?- atraer(log(x + 1) + log(x - 1) = 3, x, E).
%?- resolver(log(x + 1) + log(x - 1) = 3, x, S).
%?- resolver(2 ^ x * 2 ^ (x + 1) = 32, x, S).

:- module(atraer,
          [ resolver/3,
            atraer/3,
            distancia/3
          ]).

:- use_module(library(error)).
:- use_module(library(lists)).
:- use_module(capitulo32, [apariciones/3, simplificar/2]).
:- use_module(aislar, [aislar/3, posicion/3]).
:- use_module(colectar, [colectar/3]).
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

log(U) + log(V) ~> log(U * V) si con(U), con(V).
exp(U) * exp(V) ~> exp(U + V) si con(U), con(V).
A ^ U * A ^ V ~> A ^ (U + V) si libre(A), con(U), con(V).

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
%   Como resolver/3, sin verificar los argumentos ni simplificar: aísla,
%   colecta o atrae, en ese orden, y después de colectar o de atraer
%   vuelve a empezar.
resolver_(Ecuacion, X, Solucion) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, Solucion)
    ;   colectar(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ;   atraer(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ).

%!  atraer(+Ecuacion0, +X:atom, -Ecuacion) is semidet.
%
%   Ecuacion resulta de reescribir un subtérmino de Ecuacion0 con la
%   primera regla de atracción que reduce la distancia entre las
%   apariciones de X.
atraer(Ecuacion0, X, Ecuacion) :-
    distancia(Ecuacion0, X, D0),
    once(( reescribir(regla, X, Ecuacion0, Ecuacion),
           distancia(Ecuacion, X, D),
           D < D0 )).

%!  distancia(+E, +X:atom, -D:integer) is semidet.
%
%   D es la suma de las profundidades de las apariciones de X en E,
%   medidas desde el menor subtérmino que las contiene a todas. Falla si
%   X no aparece en E.
distancia(E, X, D) :-
    findall(P, posicion(X, E, P), [P1|Ps]),
    foldl(prefijo_comun, Ps, P1, Comun),
    length(Comun, L),
    foldl(profundidad_bajo(L), [P1|Ps], 0, D).

%!  prefijo_comun(+P:list, +Q:list, -R:list) is det.
%
%   R es el prefijo más largo común a P y Q.
prefijo_comun([A|P], [B|Q], R) :-
    A == B,
    !,
    R = [A|R1],
    prefijo_comun(P, Q, R1).
prefijo_comun(_, _, []).

%!  profundidad_bajo(+L:integer, +P:list, +D0:integer, -D:integer) is det.
%
%   D es D0 más la longitud de P menos L.
profundidad_bajo(L, P, D0, D) :-
    length(P, N),
    D is D0 + N - L.
