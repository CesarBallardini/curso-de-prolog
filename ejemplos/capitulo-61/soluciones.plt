:- encoding(utf8).

:- begin_tests(soluciones).

test(ejercicio1, [true(S-M == 3-4), nondet]) :-
    resolver(almacen, listas, suma([1, 2], S)),
    resolver(almacen, maximo, maximo(3, 4, M)).

test(ejercicio1_indice, [true(S == 3)]) :-
    resolver(indice, listas, suma([1, 2], S)).

test(ejercicio1_resolvente, all(M == [4])) :-
    resolver(resolvente, maximo, maximo(3, 4, M)).

test(ejercicio2, [true(C == 1814)]) :-
    almacen:medir(listas, suma_hasta(200, _), M),
    memberchk(celdas-C, M).

test(ejercicio3, [true(N == 2)]) :-
    ejecutar_archivo(ejemplos('capitulo-07/recorrer'), largo([a, b], N)).

test(ejercicio4, [true(I1-I2 == 5-3)]) :-
    medir_tipos(S, P),
    memberchk(intentos-I1, S),
    memberchk(intentos-I2, P).

test(ejercicio5, [fail]) :-
    empty_assoc(A),
    unificar_con_prueba('$v'(0), f('$v'(0)), 0, A-[], _).

test(ejercicio5_sin_prueba, [true(R == [])]) :-
    empty_assoc(A),
    unificar('$v'(0), f('$v'(0)), 0, A-[], _-R).

test(ejercicio5_ligada, [fail]) :-
    empty_assoc(A0),
    unificar_con_prueba('$v'(0), g('$v'(1)), 0, A0-[], A1),
    unificar_con_prueba('$v'(1), h('$v'(0)), 0, A1, _).

test(ejercicio7_signo, all(S == [negativo, positivo])) :-
    transformado(disyuncion, signo(-2, S)).

test(ejercicio7_nativo, [true(Ss == Ns)]) :-
    disyuncion(Cs),
    nativas(Cs, signo(-2, _), Ns),
    findall(signo(-2, S), transformado(disyuncion, signo(-2, S)), Ss).

test(ejercicio7_soltero, all(P == [ana])) :-
    transformado(disyuncion, soltero(P)).

% El corte de la disyunción transformada no corta las cláusulas de p/1.
test(ejercicio7_corte, [true(Xs-Ns == [1, 3]-[p(1)])]) :-
    findall(X, transformado(corte_en_disyuncion, p(X)), Xs),
    corte_en_disyuncion(Cs),
    nativas(Cs, p(_), Ns).

test(ejercicio8, [true(Ps == [295-86, 985-166, 3565-326])]) :-
    findall(P-Q, ( member(N, [20, 40, 80]),
                   pasos_de(invertir_hasta(N, _), P),
                   pasos_de(invertir_acc_hasta(N, _), Q)
                 ), Ps).

test(ejercicio11, [true(Ms == [51-4, 101-4])]) :-
    findall(P-Q, ( member(N, [50, 100]),
                   metas_de(longitud_hasta(N, _), P),
                   metas_de(longitud_acc_hasta(N, _), Q)
                 ), Ms).

:- end_tests(soluciones).
