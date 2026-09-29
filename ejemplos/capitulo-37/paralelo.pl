:- encoding(utf8).

% Capítulo 37 - Paralelismo de datos: el mismo trabajo sobre muchos datos
% independientes, repartido entre los núcleos.
%
% contar_primos/2 cuenta los primos de una lista de tramos con maplist/3;
% contar_primos_paralelo/2, con concurrent_maplist/3. goldbach_hasta/1 y
% goldbach_paralelo/1 comprueban la conjetura de Goldbach hasta un número,
% con forall/2 y con concurrent_forall/2. un_divisor/2 prueba dos
% estrategias a la vez con first_solution/3 y se queda con la primera que
% responde.
%
% solo-local: SWISH no permite crear hilos.
%
%?- tramos(4, 1000, Ts), contar_primos_paralelo(Ts, N).
%?- goldbach_paralelo(10000).
%?- un_divisor(100000099999829, D).

%!  primo(+N:integer) is semidet.
%
%   N es un número primo.
primo(2).
primo(N) :-
    N > 2,
    N mod 2 =\= 0,
    \+ divisor_impar(N, 3).

%!  divisor_impar(+N:integer, +D:integer) is semidet.
%
%   N tiene un divisor impar entre D y la raíz cuadrada de N; D es impar.
divisor_impar(N, D) :-
    D * D =< N,
    (   N mod D =:= 0
    ->  true
    ;   D2 is D + 2,
        divisor_impar(N, D2)
    ).

%!  tramos(+N:integer, +Largo:integer, -Tramos:list) is det.
%
%   Tramos son N intervalos Desde-Hasta consecutivos de Largo números cada
%   uno, desde 1.
tramos(N, Largo, Tramos) :-
    findall(Desde-Hasta,
            ( between(1, N, I),
              Desde is (I - 1) * Largo + 1,
              Hasta is I * Largo ),
            Tramos).

%!  primos_en(+Tramo, -C:integer) is det.
%
%   C es la cantidad de primos del intervalo Tramo, Desde-Hasta.
primos_en(Desde-Hasta, C) :-
    aggregate_all(count, ( between(Desde, Hasta, N), primo(N) ), C).

%!  contar_primos(+Tramos:list, -Total:integer) is det.
%
%   Total es la cantidad de primos de todos los Tramos.
contar_primos(Tramos, Total) :-
    maplist(primos_en, Tramos, Cs),
    sum_list(Cs, Total).

%!  contar_primos_paralelo(+Tramos:list, -Total:integer) is det.
%
%   La misma relación, con los tramos repartidos entre varios hilos.
contar_primos_paralelo(Tramos, Total) :-
    concurrent_maplist(primos_en, Tramos, Cs),
    sum_list(Cs, Total).

%!  suma_de_primos(+P:integer, -Par) is semidet.
%
%   Par es A-B, con A y B primos, A =< B y A + B = P; A es el menor posible.
suma_de_primos(P, A-B) :-
    Mitad is P // 2,
    between(2, Mitad, A),
    primo(A),
    B is P - A,
    primo(B),
    !.

%!  goldbach_hasta(+N:integer) is semidet.
%
%   Cada número par entre 4 y N es la suma de dos primos.
goldbach_hasta(N) :-
    Mitad is N // 2,
    forall(between(2, Mitad, I),
           ( P is 2 * I,
             suma_de_primos(P, _) )).

%!  goldbach_paralelo(+N:integer) is semidet.
%
%   La misma relación, con los números repartidos entre varios hilos.
goldbach_paralelo(N) :-
    Mitad is N // 2,
    concurrent_forall(between(2, Mitad, I),
                      ( P is 2 * I,
                        suma_de_primos(P, _) )).

%!  un_divisor(+N:integer, -D:integer) is semidet.
%
%   D es un divisor de N mayor que 1 y no mayor que su raíz cuadrada. Busca
%   a la vez desde 2 hacia arriba y desde la raíz hacia abajo, y responde
%   con la búsqueda que termina primero. Falla si N es primo.
un_divisor(N, D) :-
    first_solution(D, [ desde_abajo(N, D),
                        desde_arriba(N, D) ],
                   []).

%!  desde_abajo(+N:integer, -D:integer) is semidet.
%
%   D es el menor divisor de N entre 2 y la raíz cuadrada de N.
desde_abajo(N, D) :-
    Raiz is truncate(sqrt(N)),
    between(2, Raiz, D),
    N mod D =:= 0,
    !.

%!  desde_arriba(+N:integer, -D:integer) is semidet.
%
%   D es el mayor divisor de N entre 2 y la raíz cuadrada de N.
desde_arriba(N, D) :-
    Raiz is truncate(sqrt(N)),
    between(2, Raiz, K),
    D is Raiz + 2 - K,
    N mod D =:= 0,
    !.
