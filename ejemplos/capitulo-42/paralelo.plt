:- encoding(utf8).

:- begin_tests(paralelo).

% En paralelo se obtienen la misma jugada y el mismo valor que en la
% búsqueda secuencial.
test(igual_3, [true(R == [])]) :-
    inicial(tateti(3), P0),
    findall(P, ( jugada(tateti(3), P0, _, P1),
                 jugada(tateti(3), P1, _, P) ), Ps),
    findall(P, ( nth0(I, Ps, P),
                 I mod 6 =:= 0,
                 alfabeta(tateti(3), P, 4, J1, V1, _),
                 en_paralelo(tateti(3), P, 4, J2, V2),
                 J1-V1 \== J2-V2 ), R).

test(igual_4, [true(J-V == 1-3)]) :-
    inicial(tateti(4), P),
    en_paralelo(tateti(4), P, 3, J, V).

test(gana_x, [true(J-V == 4-102)]) :-
    en_paralelo(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), 9, J, V).

test(terminada, [fail]) :-
    en_paralelo(tateti(3), pos([x, x, x, o, o, v, v, v, v], o), 5, _, _).

test(a_tiempo, [true(J-V == 1-3)]) :-
    inicial(tateti(4), P),
    en_paralelo(tateti(4), P, 3, 10, J, V).

% Ninguna búsqueda de profundidad 7 termina en 0,05 segundos.
test(fuera_de_tiempo, [fail]) :-
    inicial(tateti(4), P),
    en_paralelo(tateti(4), P, 7, 0.05, _, _).

test(elegir_max, [true(M == 5-b)]) :-
    elegir(max, [3-a, 5-b, 5-c, 1-d], M).

test(elegir_min, [true(M == 1-d)]) :-
    elegir(min, [3-a, 5-b, 1-d, 1-e], M).

test(elegir_vacia, [true(M == (-inf)-ninguna)]) :-
    elegir(max, [], M).

:- end_tests(paralelo).
