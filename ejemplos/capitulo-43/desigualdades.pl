:- encoding(utf8).

% Capítulo 43 - El aislamiento en las desigualdades.
%
% Una desigualdad Izq < Der, Izq =< Der, Izq > Der o Izq >= Der con una
% sola aparición de la incógnita se resuelve como una ecuación, con un
% axioma por nivel de la posición. La diferencia está en el sentido:
% multiplicar o dividir por un número negativo, o pasar el sustraendo al
% otro lado, lo invierte. Cada axioma que multiplica o divide evalúa el
% signo de un factor cerrado; si el factor vale 0, no se aplica.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- resolver_desigualdad(3 - 2 * x < 7, x, S).
%?- resolver_desigualdad(10 < x / -2, x, S).
%?- resolver_desigualdad(exp(x + 1) >= 5, x, S).

:- module(desigualdades,
          [ resolver_desigualdad/3,
            invertida/2
          ]).

:- use_module(library(error)).
:- use_module(capitulo32, [apariciones/3, simplificar/2]).
:- use_module(aislar, [posicion/3]).

:- multifile axioma_d/3.

%!  resolver_desigualdad(+Desigualdad, +X:atom, -Solucion) is semidet.
%
%   Solucion es X Rel E, con E sin X, equivalente a la Desigualdad cerrada
%   en la que X aparece una sola vez. Falla si X no aparece exactamente una
%   vez, o si un axioma no se aplica: un factor que vale 0, o un
%   logaritmo de un valor que no es positivo. Cada operación tiene un solo
%   axioma por argumento, y once/1 descarta las alternativas que la
%   indexación deja abiertas.
resolver_desigualdad(Desigualdad, X, Solucion) :-
    must_be(ground, Desigualdad),
    must_be(atom, X),
    Desigualdad =.. [Rel, Izq, Der],
    relacion(Rel),
    apariciones(Desigualdad, X, 1),
    once(posicion(X, Desigualdad, [Lado|Camino])),
    orientar(Lado, d(Rel, Izq, Der), D),
    once(aislar_desigualdad(Camino, D, d(Rel1, X, E0))),
    simplificar(E0, E),
    Solucion =.. [Rel1, X, E].

% relacion(Rel): Rel es una relación de orden.
relacion(<).
relacion(=<).
relacion(>).
relacion(>=).

%!  invertida(?Rel, ?Inv) is nondet.
%
%   Inv es la relación de orden que resulta de intercambiar los lados de
%   Rel: A Rel B si y solo si B Inv A.
invertida(<, >).
invertida(=<, >=).
invertida(>, <).
invertida(>=, =<).

%!  orientar(+Lado:integer, +D0, -D) is det.
%
%   D es la desigualdad D0, d(Rel, Izq, Der), con el lado número Lado a
%   la izquierda.
orientar(1, D, D).
orientar(2, d(Rel, Izq, Der), d(Inv, Der, Izq)) :-
    invertida(Rel, Inv).

%!  aislar_desigualdad(+Camino:list(integer), +D0, -D) is semidet.
%
%   D resulta de aplicar a D0 un axioma por cada número de Camino.
aislar_desigualdad([], D, D).
aislar_desigualdad([N|Camino], D0, D) :-
    axioma_d(N, D0, D1),
    aislar_desigualdad(Camino, D1, D).

%!  axioma_d(+N:integer, +D0, -D) is semidet.
%
%   D es equivalente a D0, con la operación de la raíz del lado izquierdo
%   pasada al lado derecho; la incógnita está en su argumento N. Es
%   multifile: otro archivo puede agregar axiomas.
axioma_d(1, d(R, -U, W), d(I, U, -W)) :-
    invertida(R, I).
axioma_d(1, d(R, U + V, W), d(R, U, W - V)).
axioma_d(2, d(R, U + V, W), d(R, V, W - U)).
axioma_d(1, d(R, U - V, W), d(R, U, W + V)).
axioma_d(2, d(R, U - V, W), d(I, V, U - W)) :-
    invertida(R, I).
axioma_d(1, d(R, U * V, W), d(R1, U, W / V)) :-
    segun_signo(V, R, R1).
axioma_d(2, d(R, U * V, W), d(R1, V, W / U)) :-
    segun_signo(U, R, R1).
axioma_d(1, d(R, U / V, W), d(R1, U, W * V)) :-
    segun_signo(V, R, R1).
axioma_d(1, d(R, exp(U), W), d(R, U, log(W))) :-
    W1 is W,
    W1 > 0.

%!  segun_signo(+E, +R, -R1) is semidet.
%
%   R1 es R si la expresión cerrada E es positiva, y R invertida si es
%   negativa. Falla si E vale 0.
segun_signo(E, R, R1) :-
    V is E,
    (   V > 0
    ->  R1 = R
    ;   V < 0
    ->  invertida(R, R1)
    ).
