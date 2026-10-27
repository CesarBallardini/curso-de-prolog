:- encoding(utf8).

:- begin_tests(strips).

test(aplicar, [true(E1 == [libre(a), libre(b), sostiene(c),
                           sobre(a, mesa), sobre(b, mesa)])]) :-
    sussman(E),
    aplicar(E, desapilar(c, a), E1).

test(no_aplicable, [fail]) :-
    sussman(E),
    aplicar(E, tomar(a), _).

test(aplicables, [true(As == [tomar(b), desapilar(c, a)])]) :-
    sussman(E),
    findall(A, aplicar(E, A, _), As0),
    msort(As0, As).

test(sussman, [true(P == [desapilar(c, a), soltar(c), tomar(b),
                          apilar(b, c), tomar(a), apilar(a, b)])]) :-
    sussman(E),
    once(planificar(E, [sobre(a, b), sobre(b, c)], P)).

test(otro_orden, [true(L == 6)]) :-
    sussman(E),
    once(planificar(E, [sobre(b, c), sobre(a, b)], P)),
    length(P, L).

% Sin la cota de longitud, la primera respuesta logra una meta, la deshace
% para lograr la otra, y vuelve a lograrla: catorce acciones.
test(sin_cota, [true(L == 14)]) :-
    sussman(E),
    once(lograr(E, [sobre(a, b), sobre(b, c)], P, _)),
    length(P, L).

test(ya_cumplidas, [true(P == [])]) :-
    sussman(E),
    once(planificar(E, [sobre(c, a)], P)).

% El plan, aplicado, llega a un estado con las dos metas.
test(plan_valido, [true]) :-
    sussman(E),
    once(planificar(E, [sobre(a, b), sobre(b, c)], P)),
    foldl(paso, P, E, F),
    ord_subset([sobre(a, b), sobre(b, c)], F).

paso(Accion, E0, E) :-
    once(aplicar(E0, Accion, E)).

% operador/4 genera las acciones sin variables: 3 tomar, 6 desapilar,
% 3 soltar y 6 apilar con los bloques a, b y c.
test(operadores, [true(N == 18)]) :-
    aggregate_all(count, operador(_, _, _, _), N).

test(operador_tomar, [true(P-A-B == [libre(a), sobre(a, mesa), mano_vacia]-
                                   [sostiene(a)]-
                                   [libre(a), sobre(a, mesa), mano_vacia])]) :-
    operador(tomar(a), P, A, B).

test(apilar_sobre_si_mismo, [fail]) :-
    operador(apilar(a, a), _, _, _).

:- end_tests(strips).
