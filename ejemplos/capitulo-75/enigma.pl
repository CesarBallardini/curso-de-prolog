:- encoding(utf8).

% Capítulo 75 - Versión 6: Enigma 1225 por generación y prueba.
%
% Un tablero de N por N lleva un entero positivo en cada casilla; sus filas
% son distintas, cada fila es igual a una columna de otro número y, si el
% mayor número escrito es K, aparecen todos los de 1 a K. Se busca la mayor
% suma posible. Para cada desarreglo P (una permutación sin puntos fijos)
% se arma la matriz de variables libres más general cuya columna J es la
% fila nth1(J, P): una sola unificación, entre la matriz y la traspuesta de
% sus filas permutadas, impone el patrón. Si las filas son distintas, se
% evalúa: el valor más alto va a la variable que más se repite.
%
%?- desarreglos(4, Ps), length(Ps, N).
%?- tablero(3, [2, 3, 1], M, Total).
%?- maximo(6, Total, Evaluadas).

:- use_module(library(clpfd), [transpose/2]).

%!  desarreglo(+N:integer, -P:list(integer)) is nondet.
%
%   P es una permutación de 1..N que no deja ningún número en su lugar:
%   nth1(I, P, X) implica X =\= I.
desarreglo(N, P) :-
    numlist(1, N, Numeros),
    desarreglo(Numeros, 1, Numeros, P).

%!  desarreglo(+Posiciones:list, +I:integer, +Libres:list, -P:list)
%!      is nondet.
%
%   P asigna a las posiciones I, I+1, ... números distintos de Libres,
%   ninguno igual a su posición.
desarreglo([], _, [], []).
desarreglo([_|Posiciones], I, Libres, [X|P]) :-
    select(X, Libres, Libres1),
    X =\= I,
    I1 is I + 1,
    desarreglo(Posiciones, I1, Libres1, P).

%!  desarreglos(+N:integer, -Ps:list) is det.
%
%   Ps son todos los desarreglos de 1..N, en orden lexicográfico.
desarreglos(N, Ps) :-
    findall(P, desarreglo(N, P), Ps).

%!  matriz_patron(+P:list(integer), -M:list(list)) is det.
%
%   M es la matriz de variables libres más general cuya columna J es igual
%   a su fila nth1(J, P).
matriz_patron(P, M) :-
    length(P, N),
    length(M, N),
    maplist(fila_libre(N), M),
    maplist(fila_de(M), P, Filas),
    transpose(Filas, M).

%!  fila_libre(+N:integer, -Fila:list) is det.
%
%   Fila es una lista de N variables libres.
fila_libre(N, Fila) :-
    length(Fila, N).

%!  fila_de(+M:list(list), +I:integer, -Fila:list) is det.
%
%   Fila es la fila I de M.
fila_de(M, I, Fila) :-
    nth1(I, M, Fila).

%!  filas_distintas(+M:list(list)) is semidet.
%
%   Ningún par de filas de M es idéntico: la comparación es con ==/2, así
%   que dos filas de variables libres distintas cuentan como distintas.
filas_distintas([]).
filas_distintas([Fila|Filas]) :-
    \+ ( member(Otra, Filas), Otra == Fila ),
    filas_distintas(Filas).

%!  evaluar(+M:list(list), -Total:integer) is det.
%
%   Liga cada variable de M a un número entre 1 y la cantidad K de
%   variables distintas: K a la que más se repite, K-1 a la siguiente, y
%   así; Total es la suma de la matriz resultante, la mayor que admite el
%   patrón.
evaluar(M, Total) :-
    append(M, Casillas),
    term_variables(Casillas, Variables),
    maplist(frecuencia(Casillas), Variables, Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, PorFrecuencia),
    length(PorFrecuencia, K),
    numlist(1, K, PorFrecuencia),
    sum_list(Casillas, Total).

%!  frecuencia(+Casillas:list, +V, -Par) is det.
%
%   Par es Veces-V, donde Veces es la cantidad de casillas idénticas a V.
frecuencia(Casillas, V, Veces-V) :-
    aggregate_all(count, ( member(X, Casillas), X == V ), Veces).

%!  tablero(+N:integer, ?P:list(integer), -M:list(list), -Total:integer)
%!      is nondet.
%
%   M es el tablero de mayor suma para el desarreglo P de 1..N, si sus
%   filas son distintas; Total es su suma. Con P libre, recorre los
%   desarreglos.
tablero(N, P, M, Total) :-
    desarreglo(N, P),
    matriz_patron(P, M),
    filas_distintas(M),
    evaluar(M, Total).

%!  maximo(+N:integer, -Total:integer, -Evaluadas:integer) is semidet.
%
%   Total es la mayor suma de un tablero de N por N; Evaluadas es la
%   cantidad de desarreglos cuyo patrón tiene filas distintas y se evaluó.
%   Falla si ningún desarreglo da filas distintas.
maximo(N, Total, Evaluadas) :-
    findall(T, tablero(N, _, _, T), Totales),
    length(Totales, Evaluadas),
    max_list(Totales, Total).
