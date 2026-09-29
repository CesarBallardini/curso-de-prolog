:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 3: sin premio por ganar antes, cualquier victoria vale 100.
test(plano, [true(J-V == 4-100)]) :-
    minimax(plano(3), pos([x, o, x, v, x, o, v, o, v], x), 9, J, V, _).

test(con_premio, [true(J-V == 7-102)]) :-
    minimax(tateti(3), pos([x, o, x, v, x, o, v, o, v], x), 9, J, V, _).

% Ejercicio 4: negamax da lo mismo que minimax.
test(negamax_arbol, [true(J-V-N == b-5-15)]) :-
    negamax(arbol, a, 3, J, V, N).

test(negamax_igual, [true(R == [])]) :-
    inicial(tateti(3), P0),
    findall(P, ( jugada(tateti(3), P0, _, P1),
                 jugada(tateti(3), P1, _, P2),
                 jugada(tateti(3), P2, _, P) ), Ps),
    findall(P, ( nth0(I, Ps, P),
                 I mod 40 =:= 0,
                 minimax(tateti(3), P, 6, J1, V1, N1),
                 negamax(tateti(3), P, 6, J2, V2, N2),
                 J1-V1-N1 \== J2-V2-N2 ), R).

% Ejercicio 5: con c primero quedan sin buscar g2 y e2.
test(invertido, [true(J-V-N == b-5-13)]) :-
    alfabeta(invertido, a, 3, J, V, N).

% Ejercicio 6.
test(lineas_3_y_4) :-
    findall(L, linea(3, L), L3),
    lineas(tateti(3), L3),
    findall(L, linea(4, L), L4),
    lineas(tateti(4), L4).

test(lineas_5, [true(N == 12)]) :-
    aggregate_all(count, linea(5, _), N).

% Ejercicio 9: pierde quien mueve con un múltiplo de 4.
test(restar, [true(Ps == [4, 8, 12])]) :-
    perdedoras(12, Ps).

test(restar_jugada, [true(J == 3)]) :-
    alfabeta(restar(7), r(7, x), 7, J, _, _).

% Ejercicio 11.
test(poda_tabulada, [true(V-T == 0-5138)]) :-
    abolish_all_tables,
    inicial(tateti(3), P),
    acotado_tabulado(tateti(3), P, -inf, inf, V),
    tablas_de_la_poda(T).

:- end_tests(soluciones).
