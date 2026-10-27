:- encoding(utf8).

:- begin_tests(jarras).

test(inicial, [true(E == j(0, 0))]) :-
    inicial(jarras(4, 3, 2), E).

test(sucesores_iniciales, [true(Ts == [llenar(1)-j(4, 0)-4,
                                       llenar(2)-j(0, 3)-3])]) :-
    findall(A-E-C, sucesor(jarras(4, 3, 2), j(0, 0), A, E, C), Ts).

test(pasar, [true(Ts == [vaciar(1)-j(0, 3)-4, vaciar(2)-j(4, 0)-3])]) :-
    findall(A-E-C, sucesor(jarras(4, 3, 2), j(4, 3), A, E, C), Ts).

test(pasar_parcial, [nondet, true(E == j(1, 3))]) :-
    sucesor(jarras(4, 3, 2), j(4, 0), pasar(1, 2), E, 3).

test(meta, [true]) :-
    meta(jarras(4, 3, 2), j(1, 2)).

test(no_meta, [fail]) :-
    meta(jarras(4, 3, 2), j(4, 3)).

% La búsqueda ingenua no termina: la limita un contador de inferencias.
test(ingenuo_no_termina, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(resolver_ingenuo(jarras(4, 3, 2), _),
                              100000, R).

% Con la longitud del plan fijada, la búsqueda ingenua termina.
test(ingenuo_con_longitud,
     [true(P == [llenar(2), pasar(2, 1), llenar(2), pasar(2, 1)])]) :-
    length(P, 4),
    once(resolver_ingenuo(jarras(4, 3, 2), P)).

:- end_tests(jarras).
