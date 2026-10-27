:- encoding(utf8).

:- use_module(estados).

:- begin_tests(retardos).

% El ejemplo de Clocksin: tres retardos y ocho pulsos.
test(clocksin, [true(Qs == [0, 0, 0, 1, 1, 0, 0, 1])]) :-
    retardar([1, 1, 0, 0, 1, 1, 0, 0], [0, 0, 0], Qs).

test(retardo, [true(Q-E == 1-[1, 0, 1])]) :-
    retardo([0, 1, 1], 1, Q, E).

test(sin_etapas, [true(Q-E == 1-[])]) :-
    retardo([], 1, Q, E).

test(retardo_general, [true(Q-E == S2-[A, S1])]) :-
    retardo([S1, S2], A, Q, E).

test(retardo_inverso, [nondet, true(E0 == [0, 1])]) :-
    retardo(E0, 1, 1, [1, 0]).

test(retardar_inverso, [true(Es = [1, 0, _, _])]) :-
    retardar(Es, [0, 0], [0, 0, 1, 0]).

test(retardar_vacio, [true(Qs == [])]) :-
    retardar([], [0, 0], Qs).

test(retardo_en_pulso, [true(Q-E == 0-[1, 1])]) :-
    retardos:retardo_en_pulso(1, Q, [1, 0], E).

test(etapas, [true(Qs == [q1, q2, q3])]) :-
    etapas(3, Qs).

test(etapas_cero, [true(Qs == [])]) :-
    etapas(0, Qs).

test(circuito, [true(Es-Ss == [x, q1, q2]-[q2, x, q1])]) :-
    circuitos:circuito(desplazamiento_c(2), Es, Ss).

test(circuito_sin_etapas, [fail]) :-
    circuitos:circuito(desplazamiento_c(0), _, _).

test(secuencial, [true(C-K == desplazamiento_c(5)-5)]) :-
    secuencial(desplazamiento(5), C, K).

test(secuencial_libre, [fail]) :-
    secuencial(desplazamiento(_), _, _).

% El registro de N etapas y la cascada de N retardos dan las mismas
% salidas.
test(como_la_cascada, [forall(member(N, [1, 2, 3, 5])), nondet,
                       true(Ss == Qs1)]) :-
    Entradas = [1, 1, 0, 0, 1, 1, 0, 0],
    length(E0, N),
    maplist(=(0), E0),
    retardar(Entradas, E0, Qs),
    maplist([Q, [Q]]>>true, Qs, Qs1),
    maplist([A, [A]]>>true, Entradas, Pulsos),
    ejecutar(desplazamiento(N), E0, Pulsos, Ss).

test(como_registro4, [nondet, true(Ss1 == Ss2)]) :-
    Ps = [[1], [0], [0], [1], [1], [0], [0], [1]],
    ejecutar(registro4, [0, 0, 0, 0], Ps, Ss1),
    ejecutar(desplazamiento(4), [0, 0, 0, 0], Ps, Ss2).

% Un registro de N etapas alcanza los 2^N estados.
test(alcanzables, [true(N == 8)]) :-
    aggregate_all(count,
                  alcanzable(desplazamiento(3), [0, 0, 0], _), N).

:- end_tests(retardos).
