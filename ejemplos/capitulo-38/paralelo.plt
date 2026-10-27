:- encoding(utf8).

:- begin_tests(paralelo).

test(primos, [true(N == 25)]) :-
    primos_en(1-100, N).

% La versión paralela da el mismo total que la secuencial.
test(igual_total, [true(P == S)]) :-
    tramos(16, 2000, Ts),
    contar_primos(Ts, S),
    contar_primos_paralelo(Ts, P).

test(tramos, [true(Ts == [1-10, 11-20, 21-30])]) :-
    tramos(3, 10, Ts).

test(goldbach) :-
    goldbach_hasta(2000),
    goldbach_paralelo(2000).

test(suma_de_primos, [true(Par == 3-97)]) :-
    suma_de_primos(100, Par).

% Si un caso no se cumple, concurrent_forall/2 falla.
test(forall_falla, [fail]) :-
    concurrent_forall(between(1, 100, I), I < 100).

% Con un único divisor posible, la respuesta no depende de qué búsqueda
% termina primero.
test(un_divisor, [true(D == 3)]) :-
    N is 3 * 1000003,
    un_divisor(N, D).

% Con varios divisores, cualquiera de las dos búsquedas puede ganar: la
% prueba acepta los dos resultados posibles.
test(dos_posibles, [true(memberchk(D, [2, 25]))]) :-
    un_divisor(1000, D).

test(primo_sin_divisor, [fail]) :-
    un_divisor(1000003, _).

test(primo, [true(Ps == [2, 3, 5, 7, 11, 13, 97])]) :-
    include(primo, [0, 1, 2, 3, 4, 5, 7, 9, 11, 13, 25, 97], Ps).

% 11 no es la suma de dos primos: 2 + 9, 3 + 8 y 5 + 6 no lo son.
test(impar_sin_suma, [fail]) :-
    suma_de_primos(11, _).

% Cada búsqueda por separado da su extremo.
test(extremos, [true(A-B == 2-25)]) :-
    desde_abajo(1000, A),
    desde_arriba(1000, B).

:- end_tests(paralelo).
