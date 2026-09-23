:- encoding(utf8).

% Capítulo 6 - Soluciones de los ejercicios.
%
% Los naturales del capítulo con los predicados que piden los ejercicios, y la
% cadena de padres para los ejercicios sobre generaciones.
%
%?- mayor(s(s(cero)), s(cero)).
%?- par(s(s(cero))).

%!  natural(+N) is semidet.
%!  natural(-N) is multi.
%
%   N es un número natural.
natural(cero).
natural(s(N)) :-
    natural(N).

%!  suma(?A, ?B, ?C) is nondet.
%
%   C es A más B.
suma(cero, B, B).
suma(s(A), B, s(C)) :-
    suma(A, B, C).

%!  valor(+N, -V) is det.
%
%   V es el entero predefinido que corresponde al natural N.
valor(cero, 0).
valor(s(N), V) :-
    valor(N, Anterior),
    V is Anterior + 1.

% --- Ejercicio 1 -----------------------------------------------------------

dos(s(s(cero))).
tres(s(s(s(cero)))).
cuatro(s(s(s(s(cero))))).

% --- Ejercicio 3 -----------------------------------------------------------

%!  mayor(?A, ?B) is nondet.
%
%   A es mayor que B. Equivale a menor/2 con los argumentos invertidos,
%   pero está definido de manera independiente.
mayor(s(_), cero).
mayor(s(A), s(B)) :-
    mayor(A, B).

% --- Ejercicio 4 -----------------------------------------------------------

%!  doble_natural(?N, ?D) is nondet.
%
%   D es N sumado consigo mismo.
doble_natural(N, D) :-
    suma(N, N, D).

% --- Ejercicio 5 -----------------------------------------------------------

%!  desde(+V, -N) is det.
%
%   N es el natural en notación s que corresponde al entero V.
desde(0, cero).
desde(V, s(N)) :-
    V > 0,
    Anterior is V - 1,
    desde(Anterior, N).

% --- Ejercicio 7 -----------------------------------------------------------

padre(juan, ana).
padre(ana, luis).
padre(luis, eva).

%!  generaciones(?A, ?D, -N) is nondet.
%
%   D está N generaciones por debajo de A.
generaciones(A, D, 1) :-
    padre(A, D).
generaciones(A, D, N) :-
    padre(A, Hijo),
    generaciones(Hijo, D, Faltan),
    N is Faltan + 1.

%!  tatarabuelo(?A, ?D) is nondet.
%
%   D está cuatro generaciones por debajo de A.
tatarabuelo(A, D) :-
    generaciones(A, D, 4).

% --- Ejercicio 9 -----------------------------------------------------------

%!  par(?N) is nondet.
%
%   N tiene una cantidad par de s. Un caso base, y un caso recursivo que
%   avanza de a dos.
par(cero).
par(s(s(N))) :-
    par(N).

% --- Ejercicio 13 ----------------------------------------------------------

%!  menor_o_igual(?A, ?B) is nondet.
%
%   A es menor o igual que B, sobre los naturales en s.
menor_o_igual(cero, _).
menor_o_igual(s(A), s(B)) :-
    menor_o_igual(A, B).

% --- Ejercicio 14 ----------------------------------------------------------

%!  impar(?N) is nondet.
%
%   N tiene una cantidad impar de s.
impar(s(cero)).
impar(s(s(N))) :-
    impar(N).

%!  paridad(?N, ?P) is nondet.
%
%   P es par o impar, según la cantidad de s de N.
paridad(N, par) :-
    par(N).
paridad(N, impar) :-
    impar(N).
