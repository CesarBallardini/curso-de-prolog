:- encoding(utf8).

:- begin_tests(soluciones).

% clause/2, que obtiene las cláusulas de un predicado,
% se presenta en el capítulo 33.
% Ejercicio 1: la secuencia del enunciado, desde una base vacía. Las pruebas
% corren en su propio módulo, y por eso los hechos llevan user:.
test(ejercicio_1, [ setup(( retractall(user:q(_, _)),
                            retractall(user:p(_)) )),
                    cleanup(( retractall(user:q(_, _)),
                              retractall(user:p(_)) )),
                    true(Q1-Q2-Q3-P == [x-y, a-b, 1-2]-[x-y, a-b]-[]-1) ]) :-
    assertz(user:q(a, b)),
    assertz(user:q(1, 2)),
    asserta(user:q(x, y)),
    findall(X-Y, q(X, Y), Q1),
    retract(user:q(1, 2)),
    assertz(user:(p(Z) :- h(Z))),
    findall(X-Y, q(X, Y), Q2),
    \+ ( retract(user:q(_, _)), fail ),
    findall(X-Y, q(X, Y), Q3),
    aggregate_all(count, clause(user:p(_), _), P).

% Ejercicio 2
test(nadie_nada_bien, [fail]) :-
    nada_bien(_).

% Ejercicio 3: el recorrido ve los números del comienzo.
test(forall_y_assertz, [ cleanup(( retractall(user:numero(_)),
                                   forall(member(N, [1, 2, 3]),
                                          assertz(user:numero(N))) )),
                         true(L == [1, 2, 3, 2, 3, 4]) ]) :-
    forall(numero(N), ( M is N + 1, assertz(user:numero(M)) )),
    findall(N, numero(N), L).

test(retract_en_un_bucle, [ cleanup(( retractall(user:numero(_)),
                                      forall(member(N, [1, 2, 3]),
                                             assertz(user:numero(N))) )),
                            true(L == []) ]) :-
    forall(numero(N), retract(user:numero(N))),
    findall(N, numero(N), L).

% Ejercicio 4: la secuencia con semilla 13.
test(aleatorios, [ setup(( retractall(user:semilla(_)),
                           assertz(user:semilla(13)) )),
                   true(L == [4, 7, 8, 5, 6, 9]) ]) :-
    primeros_aleatorios(6, 10, L).

% Ejercicio 5
test(cuenta, [ setup(iniciar_cuenta), cleanup(iniciar_cuenta),
               true(S == 70) ]) :-
    depositar(100),
    extraer(30),
    saldo(S).

test(saldo_insuficiente, [ setup(iniciar_cuenta), cleanup(iniciar_cuenta),
                           true(S == 100) ]) :-
    depositar(100),
    \+ extraer(500),
    saldo(S).

test(monto_negativo, [ setup(iniciar_cuenta), cleanup(iniciar_cuenta),
                       fail ]) :-
    depositar(-5).

test(cuenta_cerrada, [ setup(iniciar_cuenta), cleanup(iniciar_cuenta),
                       fail ]) :-
    cerrar_cuenta,
    depositar(5).

% Ejercicio 6
test(suma_hasta, [ setup(olvidar_sumas), cleanup(olvidar_sumas),
                   true(S == 5050) ]) :-
    suma_hasta(100, S).

test(suma_guardada, [ setup(olvidar_sumas), cleanup(olvidar_sumas),
                      true(N == 99) ]) :-
    suma_hasta(100, _),
    aggregate_all(count, suma_guardada(_, _), N).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
% Ejercicio 8
test(como, [ setup((reiniciar, encadenar)), cleanup(reiniciar),
             true(L == ["abuelo(juan,sofia): por abuelo",
                        "  padre(juan,ana): dato inicial",
                        "  progenitor(ana,sofia): por progenitor_m",
                        "    madre(ana,sofia): dato inicial",
                        ""]) ]) :-
    with_output_to(string(S), como(abuelo(juan, sofia))),
    split_string(S, "\n", "", L).

test(como_sin_hecho, [ setup(reiniciar), fail ]) :-
    como(abuelo(juan, sofia)).

% Ejercicio 9
test(tio_o_tia, [ setup((reiniciar, encadenar)), cleanup(reiniciar),
                  all(T-S == [ana-luis, ana-eva, pedro-sofia]) ]) :-
    hecho(tio_o_tia(T, S)).

test(primos, [ setup((reiniciar, encadenar)), cleanup(reiniciar),
               true(L == [eva-sofia, luis-sofia, sofia-eva, sofia-luis]) ]) :-
    setof(A-B, hecho(primos(A, B)), L).

test(punto_fijo, [ setup((reiniciar, encadenar)), cleanup(reiniciar),
                   true(N == 41) ]) :-
    aggregate_all(count, hecho(_), N).

% Ejercicio 10: tres rondas, y los mismos hechos que de a uno.
test(rondas, [ setup(reiniciar), cleanup(reiniciar), true(R-N == 3-41) ]) :-
    encadenar_por_rondas(R),
    aggregate_all(count, hecho(_), N).

% msort/2, que ordena sin eliminar repetidos, se presenta en el capítulo 22.
test(mismos_hechos, [ cleanup(reiniciar), true(L1 == L2) ]) :-
    reiniciar,
    encadenar,
    findall(H, hecho(H), H1),
    msort(H1, L1),
    reiniciar,
    encadenar_por_rondas(_),
    findall(H, hecho(H), H2),
    msort(H2, L2).

:- end_tests(soluciones).
