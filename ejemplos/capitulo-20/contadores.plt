:- encoding(utf8).

:- begin_tests(contadores).

test(siguiente_con_hecho, [ setup(( retractall(user:contador(_)),
                                    assertz(user:contador(0)) )),
                            true(A-B == 1-2) ]) :-
    siguiente_con_hecho(A),
    siguiente_con_hecho(B).

test(siguiente_numero, [ setup(flag(numero, _, 0)),
                         true(A-B == 1-2) ]) :-
    siguiente_numero(A),
    siguiente_numero(B).

test(b_setval_se_deshace, true(X == 1)) :-
    global_con_retroceso(X).

test(nb_setval_no_se_deshace, true(X == 2)) :-
    global_sin_retroceso(X).

test(contar_respuestas, true(N == 5)) :-
    contar_respuestas(between(1, 5, _), N).

test(igual_que_aggregate_all, true(N1 == N2)) :-
    contar_respuestas(member(_, [a, b, c]), N1),
    aggregate_all(count, member(_, [a, b, c]), N2).

% Una variable global que nunca se asignó produce un error.
test(sin_asignar, [error(existence_error(variable, nunca), _)]) :-
    b_getval(nunca, _).

% nb_setval/2 guarda una copia: la variable del valor guardado no es la X.
test(nb_setval_copia, true(var(Y))) :-
    nb_setval(k, f(X)),
    X = 1,
    nb_getval(k, f(Y)).

:- end_tests(contadores).
