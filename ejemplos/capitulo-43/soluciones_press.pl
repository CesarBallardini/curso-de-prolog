:- encoding(utf8).

% Capítulo 43 - Soluciones de los ejercicios 13 y 14: el axioma de la
% potencia impar en las desigualdades, y los valores de las soluciones en
% un intervalo.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- desigualdades:resolver_desigualdad(x ^ 3 + 1 > -7, x, S).
%?- valores_en(x ^ 2 - 2 = 0, x, i(0, 3), Vs).
%?- valores_en(x ^ 2 + 1 = 0, x, i(-10, 10), Vs).

:- module(soluciones_press,
          [ valores_en/4,
            raiz_impar/3
          ]).

:- use_module(library(apply)).
:- use_module(desigualdades, []).
:- use_module(ecuaciones, [valores/3]).
:- use_module(intervalos, [sin_raices/3]).

% Ejercicio 13 --------------------------------------------------------

% La potencia de exponente natural impar es creciente: conserva el
% sentido de la desigualdad.
desigualdades:axioma_d(1, d(R, U ^ N, W), d(R, U, Raiz)) :-
    integer(N),
    N > 0,
    N mod 2 =:= 1,
    raiz_impar(W, N, Raiz).

%!  raiz_impar(+W, +N:integer, -Raiz) is det.
%
%   Raiz es la expresión de la raíz real N-ésima de W, con N impar: la
%   potencia 1 / N de un número negativo no tiene valor real en is/2, y
%   por eso, si W es negativo, se escribe como el opuesto de la raíz del
%   valor de -W.
raiz_impar(W, N, Raiz) :-
    V is W,
    (   V >= 0
    ->  Raiz = W ^ (1 / N)
    ;   A is -V,
        Raiz = -(A ^ (1 / N))
    ).

% Ejercicio 14 --------------------------------------------------------

%!  valores_en(+Ecuacion, +X:atom, +I, -Vs:list(number)) is det.
%
%   Vs son los valores de valores/3 que están en el intervalo I =
%   i(Lo, Hi). Si la aritmética de intervalos prueba que la Ecuacion no
%   tiene raíces en I, Vs es [] sin resolverla.
valores_en(Ecuacion, X, i(Lo0, Hi0), Vs) :-
    (   sin_raices(Ecuacion, X, i(Lo0, Hi0))
    ->  Vs = []
    ;   Lo is Lo0,
        Hi is Hi0,
        valores(Ecuacion, X, Vs0),
        include(entre(Lo, Hi), Vs0, Vs)
    ).

%!  entre(+Lo:number, +Hi:number, +V:number) is semidet.
%
%   V está entre Lo y Hi.
entre(Lo, Hi, V) :-
    Lo =< V,
    V =< Hi.
