:- encoding(utf8).

% Capítulo 23 - Soluciones de los ejercicios 2 a 11. Las de los ejercicios 12
% y 13 están en soluciones_buscaminas.pl, y las de 14 a 16 en
% soluciones_proyecto.pl.
%
%?- celsius_fahrenheit(C, 212).
%?- cambio(37, Monedas).
%?- sudoku([[1, _, _, _], [_, _, 3, _], [_, 4, _, _], [_, _, _, 2]]).

:- use_module(library(clpfd)).

% --- Ejercicio 2 ----------------------------------------------------------

%!  celsius_fahrenheit(?C:integer, ?F:integer) is nondet.
%
%   C grados Celsius son F grados Fahrenheit: F = C * 9 / 5 + 32, con los
%   dos enteros.
celsius_fahrenheit(C, F) :-
    5 * F #= 9 * C + 160.

% --- Ejercicio 3 ----------------------------------------------------------

%!  cambio(+Monto:integer, -Monedas:list(integer)) is semidet.
%
%   Monedas es [U, C, D]: U monedas de 1, C de 5 y D de 10 que suman Monto,
%   con la menor cantidad de monedas.
cambio(Monto, [U, C, D]) :-
    [U, C, D] ins 0..Monto,
    U + 5 * C + 10 * D #= Monto,
    Total #= U + C + D,
    once(labeling([min(Total)], [U, C, D])).

% --- Ejercicio 4 ----------------------------------------------------------

%!  cuadrado_magico(-Filas:list(list(integer))) is nondet.
%
%   Filas son las tres filas de un cuadrado mágico de 3 x 3 con los números
%   del 1 al 9: filas, columnas y diagonales suman 15.
cuadrado_magico([[A, B, C], [D, E, F], [G, H, I]]) :-
    Vs = [A, B, C, D, E, F, G, H, I],
    Vs ins 1..9,
    all_different(Vs),
    maplist([X, Y, Z]>>(X + Y + Z #= 15),
            [A, D, G, A, B, C, A, C], [B, E, H, D, E, F, E, E],
            [C, F, I, G, H, I, I, G]),
    label(Vs).

% --- Ejercicio 5 ----------------------------------------------------------

%!  sudoku(?Filas:list(list(integer))) is nondet.
%
%   Filas es un sudoku de 4 x 4 resuelto: cada fila, cada columna y cada
%   cuadro de 2 x 2 tienen los números del 1 al 4.
sudoku(Filas) :-
    Filas = [[A, B, C, D], [E, F, G, H], [I, J, K, L], [M, N, O, P]],
    append(Filas, Vs),
    Vs ins 1..4,
    maplist(all_different, Filas),
    transpose(Filas, Columnas),
    maplist(all_different, Columnas),
    maplist(all_different, [[A, B, E, F], [C, D, G, H],
                            [I, J, M, N], [K, L, O, P]]),
    label(Vs).

% --- Ejercicio 6 ----------------------------------------------------------

%!  dos_de_cada(-Xs:list(integer)) is nondet.
%
%   Xs son seis valores entre 1 y 3, con exactamente dos de cada uno.
dos_de_cada(Xs) :-
    length(Xs, 6),
    Xs ins 1..3,
    global_cardinality(Xs, [1-2, 2-2, 3-2]),
    label(Xs).

% --- Ejercicio 7 ----------------------------------------------------------

%!  exactamente(?N:integer, ?Xs:list(integer), +V:integer) is nondet.
%
%   Exactamente N elementos de Xs son iguales a V.
exactamente(N, Xs, V) :-
    maplist({V}/[X, B]>>(B #<==> (X #= V)), Xs, Bs),
    sum(Bs, #=, N).

%!  dados_con_dos_seis(-Cantidad:integer) is det.
%
%   Cantidad es la cantidad de resultados de tirar tres dados en los que
%   salen exactamente dos seis.
dados_con_dos_seis(Cantidad) :-
    Dados = [_, _, _],
    Dados ins 1..6,
    exactamente(2, Dados, 6),
    aggregate_all(count, label(Dados), Cantidad).

% --- Ejercicio 8 ----------------------------------------------------------

%!  to_go_out(-Letras:list(integer)) is det.
%
%   Letras son los dígitos de T, O, G y U, distintos entre sí, tales que
%   TO + GO = OUT, sin ceros a la izquierda.
to_go_out([T, O, G, U]) :-
    Letras = [T, O, G, U],
    Letras ins 0..9,
    all_different(Letras),
    T #\= 0,
    G #\= 0,
    O #\= 0,
    10 * T + O + 10 * G + O #= 100 * O + 10 * U + T,
    label(Letras).

%!  soluciones_sin_ceros(-Con:integer, -Sin:integer) is det.
%
%   Con es la cantidad de soluciones de SEND + MORE = MONEY que exigen que S
%   y M no sean cero, y Sin la cantidad sin esa exigencia.
soluciones_sin_ceros(Con, Sin) :-
    aggregate_all(count, send_more_money(true), Con),
    aggregate_all(count, send_more_money(false), Sin).

%!  send_more_money(+SinCeros:boolean) is nondet.
%
%   Una solución de SEND + MORE = MONEY; con SinCeros en true, S y M no son
%   cero.
send_more_money(SinCeros) :-
    Letras = [S, E, N, D, M, O, R, Y],
    Letras ins 0..9,
    all_different(Letras),
    (   SinCeros == true
    ->  S #\= 0,
        M #\= 0
    ;   true
    ),
              1000 * S + 100 * E + 10 * N + D
    +         1000 * M + 100 * O + 10 * R + E
    #= 10000 * M + 1000 * O + 100 * N + 10 * E + Y,
    label(Letras).

% --- Ejercicio 9 ----------------------------------------------------------

% provincia(P): P es una de las provincias del mapa del capítulo.
provincia(san_juan).
provincia(mendoza).
provincia(san_luis).
provincia(la_rioja).
provincia(cordoba).
provincia(la_pampa).
provincia(neuquen).
provincia(rio_negro).

% limita(A, B): las provincias A y B tienen un límite en común.
limita(san_juan, la_rioja).
limita(san_juan, mendoza).
limita(san_juan, san_luis).
limita(mendoza, san_luis).
limita(mendoza, la_pampa).
limita(mendoza, neuquen).
limita(san_luis, la_rioja).
limita(san_luis, cordoba).
limita(san_luis, la_pampa).
limita(la_rioja, cordoba).
limita(cordoba, la_pampa).
limita(la_pampa, neuquen).
limita(la_pampa, rio_negro).
limita(neuquen, rio_negro).

%!  colorear_gyp(+K:integer, -Colores:list(pair)) is nondet.
%
%   La relación de colorear/2 del capítulo, con generar y probar: a cada
%   provincia se le asigna un color con between/3, y después se comprueban
%   todos los límites.
colorear_gyp(K, Colores) :-
    findall(P-_, provincia(P), Colores),
    maplist({K}/[_-C]>>between(1, K, C), Colores),
    \+ ( limita(A, B),
         memberchk(A-X, Colores),
         memberchk(B-X, Colores) ).

% --- Ejercicio 10 ---------------------------------------------------------

%!  reinas(+Opciones:list, +N:integer, -Qs:list(integer)) is nondet.
%
%   Las N reinas del capítulo, con las Opciones de labeling/2.
reinas(Opciones, N, Qs) :-
    length(Qs, N),
    Qs ins 1..N,
    seguras(Qs),
    labeling(Opciones, Qs).

%!  seguras(+Qs:list) is semidet.
%
%   Ninguna reina de Qs ataca a otra.
seguras([]).
seguras([Q|Qs]) :-
    no_ataca(Q, Qs, 1),
    seguras(Qs).

%!  no_ataca(+Q, +Qs:list, +D:integer) is semidet.
%
%   La reina Q no ataca a las de Qs, la primera D columnas a su derecha.
no_ataca(_, [], _).
no_ataca(Q, [Q1|Qs], D) :-
    Q #\= Q1,
    abs(Q - Q1) #\= D,
    D1 is D + 1,
    no_ataca(Q, Qs, D1).

% --- Ejercicio 11 ---------------------------------------------------------

%!  todos_distintos(+Xs:list) is semidet.
%
%   Los elementos de Xs son distintos entre sí, con dif/2: vale para
%   cualquier término, y con variables se posterga.
todos_distintos([]).
todos_distintos([X|Xs]) :-
    maplist(dif(X), Xs),
    todos_distintos(Xs).
