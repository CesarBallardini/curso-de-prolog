:- encoding(utf8).

:- begin_tests(extension).

test(una_accion, [true(P == [mover(c, a, b)]), nondet]) :-
    planificar(cubos, sussman, [sobre(c, b)], 4, P).

test(nada, [true(P == []), nondet]) :-
    planificar(cubos, sussman, [sobre(c, a)], 4, P).

% La anomalía de Sussman: cuatro acciones, con un rodeo.
test(sussman, [true(P == [mover(c, a, mesa), mover(b, mesa, a),
                          mover(b, a, c), mover(a, mesa, b)])]) :-
    once(planificar(cubos, sussman, [sobre(a, b), sobre(b, c)], 8, P)).

test(sussman_otro_orden, [true(L == 4)]) :-
    once(planificar(cubos, sussman, [sobre(b, c), sobre(a, b)], 8, P)),
    length(P, L).

% Con tres acciones no hay plan por extensión.
test(sin_intercalar, [fail]) :-
    planificar(cubos, sussman, [sobre(a, b), sobre(b, c)], 3, _).

test(inconsistente, [fail]) :-
    planificar(cubos, sussman, [sobre(a, b), sobre(a, c)], 8, _).

test(cada_plan_logra, [true]) :-
    Metas = [sobre(c, a), sobre(a, b)],
    once(planificar(cubos, sussman, Metas, 8, P)),
    regresion:logra(cubos, sussman, P, Metas).

test(gastar, [true(C == 2)]) :-
    gastar(3, C).

test(gastar_cero, [fail]) :-
    gastar(0, _).

test(sin_cota, [true(C == sin_cota)]) :-
    gastar(sin_cota, C).

test(proteger, [true(Ps == [libre(a)])]) :-
    proteger(libre(a), [libre(a)], Ps).

% resolver/9, un caso por cláusula: ya vale (queda protegida), prueba
% que se cumple, una acción la logra, y sin cota para la acción.
test(resolver_ya_vale, [true(Ps-H == [sobre(c, a)]-[]), nondet]) :-
    extension:resolver(cubos, sussman, sobre(c, a), [], Ps, [], H, 0, _).

test(resolver_prueba, [true(Ps-H == []-[]), nondet]) :-
    extension:resolver(cubos, sussman, distinto(a, b), [], Ps, [], H, 0, _).

test(resolver_accion, [all(H-C == [[mover(c, a, b)]-0])]) :-
    extension:resolver(cubos, sussman, sobre(c, b), [], _, [], H, 1, C).

test(resolver_sin_cota, [fail]) :-
    extension:resolver(cubos, sussman, sobre(c, b), [], _, [], _, 0, _).

% lograr/8: la acción va al final; falla si borra un protegido.
test(lograr, [all(H == [[mover(c, a, b)]])]) :-
    extension:lograr(cubos, sussman, mover(c, a, b), [], [], H, 1, _).

test(lograr_borra_protegido, [fail]) :-
    extension:lograr(cubos, sussman, mover(c, a, b), [libre(b)], [], _, 1,
                     _).

% no_borra_ninguna/3: con el destino libre, la prueba es optimista.
test(no_borra_ninguna_variable) :-
    no_borra_ninguna(cubos, mover(c, a, _), [libre(b), sobre(a, mesa)]).

test(no_borra_ninguna_ligada, [fail]) :-
    no_borra_ninguna(cubos, mover(c, a, b), [libre(b)]).

% inconsistente/3: entre los nuevos, o entre nuevos y protegidos; un
% objeto desconocido no basta para la prueba distinto/2.
test(inconsistente_nuevos) :-
    inconsistente(cubos, [sobre(a, b), sobre(a, c)], []).

test(inconsistente_protegidos) :-
    inconsistente(cubos, [sobre(a, b)], [libre(b)]).

test(inconsistente_desconocido, [fail]) :-
    inconsistente(cubos, [sobre(a, _)], [sobre(a, b)]).

test(consistente, [fail]) :-
    inconsistente(cubos, [sobre(a, b)], []).

:- end_tests(extension).
