:- encoding(utf8).

% Capítulo 40 - Las N reinas con la lista de las filas libres.
%
% Una reina por columna: Qs tiene la fila de la reina de cada columna. La
% búsqueda coloca las reinas de a una, y elige la fila de cada una con
% select/3 de la lista de filas que quedan libres. Esa lista es la otra
% forma de no repetir estados: cada fila se usa una vez, y la lista se
% reduce en cada paso, lo que además asegura que la búsqueda termina. Solo
% las diagonales se comprueban, contra las reinas ya colocadas, en cuanto
% se elige la fila; el capítulo 23 resuelve el mismo problema con
% restricciones.
%
%?- reinas(8, Qs).
%?- aggregate_all(count, reinas(8, _), N).

%!  reinas(+N:integer, -Qs:list(integer)) is nondet.
%
%   Qs es una ubicación de N reinas que no se atacan: la reina de la columna
%   i está en la fila i-ésima de Qs.
reinas(N, Qs) :-
    numlist(1, N, Filas),
    colocar(Filas, [], Qs).

%!  colocar(+Libres:list, +Colocadas:list, -Qs:list) is nondet.
%
%   Qs completa Colocadas, las filas de las reinas ya colocadas, la última
%   primero, con una reina en cada fila de Libres.
colocar([], Qs, Qs).
colocar(Libres, Colocadas, Qs) :-
    select(Q, Libres, Resto),
    segura(Q, Colocadas, 1),
    colocar(Resto, [Q|Colocadas], Qs).

%!  segura(+Q:integer, +Colocadas:list, +D:integer) is semidet.
%
%   Una reina en la fila Q no comparte diagonal con las de Colocadas, la
%   primera de las cuales está D columnas antes.
segura(_, [], _).
segura(Q, [Q1|Qs], D) :-
    Q1 - Q =\= D,
    Q - Q1 =\= D,
    D1 is D + 1,
    segura(Q, Qs, D1).
