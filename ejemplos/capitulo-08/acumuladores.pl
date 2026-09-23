:- encoding(utf8).

% Capítulo 8 - Acumuladores.
%
% Dos formas de sumar los números de una lista. La primera realiza la operación
% al retorno de la llamada recursiva; la segunda transporta el total parcial
% mientras avanza. Ambas producen el mismo resultado.
%
%?- suma_lista([3, 1, 4], Total).
%?- dar_vuelta([ana, luis, eva], AlReves).

%!  suma_lista(+L, -S) is det.
%
%   S es la suma de los números de L.
%   La operación se realiza al retorno de la llamada recursiva.
suma_lista([], 0).
suma_lista([X|Resto], S) :-
    suma_lista(Resto, Faltan),
    S is Faltan + X.

%!  suma_con_acumulador(+L, -S) is det.
%
%   La misma relación, con un acumulador.
suma_con_acumulador(L, S) :-
    sumando(L, 0, S).

%!  sumando(+L, +Hasta, -Total) is det.
%
%   Total es Hasta más la suma de los elementos de L.
%   Hasta es el acumulador: comienza en 0 y se incrementa en cada llamada.
sumando([], Total, Total).
sumando([X|Resto], Hasta, Total) :-
    Ahora is Hasta + X,
    sumando(Resto, Ahora, Total).

%!  largo(+L, -N) is det.
%
%   N es la cantidad de elementos de L, también con acumulador.
largo(L, N) :-
    contando(L, 0, N).

%!  contando(+L, +Hasta, -N) is det.
%
%   N es Hasta más la cantidad de elementos de L.
contando([], N, N).
contando([_|Resto], Hasta, N) :-
    Ahora is Hasta + 1,
    contando(Resto, Ahora, N).

%!  dar_vuelta(+L, -R) is det.
%
%   R es L en orden inverso. En este caso el acumulador no es un número: es la
%   lista que se construye.
dar_vuelta(L, R) :-
    dando_vuelta(L, [], R).

%!  dando_vuelta(+L, +Hasta, -R) is det.
%
%   R es L en orden inverso, seguida de Hasta.
dando_vuelta([], R, R).
dando_vuelta([X|Resto], Hasta, R) :-
    dando_vuelta(Resto, [X|Hasta], R).
