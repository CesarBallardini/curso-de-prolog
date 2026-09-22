:- encoding(utf8).

% Capítulo 6 - Soluciones de los ejercicios.
%
% Los naturales del capítulo con los predicados que piden los ejercicios, y la
% cadena de padres para los ejercicios sobre generaciones.
%
%?- mayor(s(s(0)), s(0)).
%?- par(s(s(0))).

natural(0).
natural(s(N)) :-
    natural(N).

suma(0, B, B).
suma(s(A), B, s(C)) :-
    suma(A, B, C).

valor(0, 0).
valor(s(N), V) :-
    valor(N, Anterior),
    V is Anterior + 1.

% --- Ejercicio 1 -----------------------------------------------------------

dos(s(s(0))).
tres(s(s(s(0)))).
cuatro(s(s(s(s(0))))).

% --- Ejercicio 3 -----------------------------------------------------------

% mayor(A, B): A es mayor que B. Equivale a menor/2 con los argumentos
% invertidos, pero está definido de manera independiente.
mayor(s(_), 0).
mayor(s(A), s(B)) :-
    mayor(A, B).

% --- Ejercicio 4 -----------------------------------------------------------

% doble_natural(N, D): D es N sumado consigo mismo.
doble_natural(N, D) :-
    suma(N, N, D).

% --- Ejercicio 5 -----------------------------------------------------------

% desde(V, N): N es el natural en notación s que corresponde al entero V.
desde(0, 0).
desde(V, s(N)) :-
    V > 0,
    Anterior is V - 1,
    desde(Anterior, N).

% --- Ejercicio 7 -----------------------------------------------------------

padre(juan, ana).
padre(ana, luis).
padre(luis, eva).

generaciones(A, D, 1) :-
    padre(A, D).
generaciones(A, D, N) :-
    padre(A, Hijo),
    generaciones(Hijo, D, Faltan),
    N is Faltan + 1.

% tatarabuelo(A, D): D está cuatro generaciones por debajo de A.
tatarabuelo(A, D) :-
    generaciones(A, D, 4).

% --- Ejercicio 9 -----------------------------------------------------------

% par(N): N tiene una cantidad par de s. Un caso base, y un caso recursivo que
% avanza de a dos.
par(0).
par(s(s(N))) :-
    par(N).

% --- Ejercicio 13 ----------------------------------------------------------

% menor_o_igual(A, B): A es menor o igual que B, sobre los naturales en s.
menor_o_igual(0, _).
menor_o_igual(s(A), s(B)) :-
    menor_o_igual(A, B).

% --- Ejercicio 14 ----------------------------------------------------------

% impar(N): N tiene una cantidad impar de s.
impar(s(0)).
impar(s(s(N))) :-
    impar(N).

% paridad(N, P): P es par o impar, según la cantidad de s de N.
paridad(N, par) :-
    par(N).
paridad(N, impar) :-
    impar(N).
