:- encoding(utf8).

:- begin_tests(anomalias).

test(variantes, [true(Ns == [ base, otra_lista, sin_dos_precedencias,
                              mas_cortas, cuatro_procesadores ])]) :-
    findall(N, variante(N, _, _), Ns).

test(base, [true(P == proyecto([ tarea(t1, 3), tarea(t2, 2), tarea(t3, 2),
                                 tarea(t4, 2), tarea(t5, 4), tarea(t6, 4),
                                 tarea(t7, 4), tarea(t8, 4), tarea(t9, 9) ],
                               [ antes(t1, t9), antes(t4, t5),
                                 antes(t4, t6), antes(t4, t7),
                                 antes(t4, t8) ],
                               3))]) :-
    variante(base, P, L),
    assertion(L == [t1, t2, t3, t4, t5, t6, t7, t8, t9]).

test(sin_dos_precedencias, [true(Ps == [ antes(t1, t9), antes(t4, t7),
                                         antes(t4, t8) ])]) :-
    variante(sin_dos_precedencias, proyecto(_, Ps, _), _).

test(mas_cortas, [true(Ds == [2, 1, 1, 1, 3, 3, 3, 3, 8])]) :-
    variante(mas_cortas, proyecto(Ts, _, _), _),
    findall(D, member(tarea(_, D), Ts), Ds).

test(cuatro, [true(N == 4)]) :-
    variante(cuatro_procesadores, proyecto(_, _, N), _).

test(calendario_base,
     [true(C == [ asignada(t1, 1, 0, 3), asignada(t2, 2, 0, 2),
                  asignada(t3, 3, 0, 2), asignada(t4, 2, 2, 4),
                  asignada(t9, 1, 3, 12), asignada(t5, 2, 4, 8),
                  asignada(t6, 3, 4, 8), asignada(t7, 2, 8, 12),
                  asignada(t8, 3, 8, 12) ])]) :-
    variante(base, P, L),
    por_lista(P, ordenadas(L), C),
    valido(P, C).

test(validos) :-
    forall(variante(_, P, L),
           ( por_lista(P, ordenadas(L), C),
             valido(P, C) )).

test(anomalias, [true(Fs == [ fila(base, 12, 12),
                              fila(otra_lista, 14, 12),
                              fila(sin_dos_precedencias, 16, 12),
                              fila(mas_cortas, 13, 10),
                              fila(cuatro_procesadores, 15, 12) ])]) :-
    anomalias(Fs).

test(ver_variante, [true(S == "P1 t1----t9----------------\nP2 t2--t4--t5------t7------\nP3 t3--....t6------t8------\nduración: 12\n")]) :-
    with_output_to(string(S), ver_variante(base)).

test(variante_inexistente, [fail]) :-
    ver_variante(ninguna).

test(tareas_graham, [true(Ts == [tarea(t1, 1), tarea(t2, 0)])]) :-
    anomalias:tareas_graham(2, Ts0),
    Ts0 = [A, B|_],
    Ts = [A, B].

test(precedencias_graham, [true(Ps == [antes(t4, t5), antes(t4, t6)])]) :-
    anomalias:precedencias_graham([antes(t1, t9), antes(t4, t7),
                                   antes(t4, t8)], Ps).

test(lista_graham, [true(L == [t1, t2, t3, t4, t5, t6, t7, t8, t9])]) :-
    anomalias:lista_graham(L).

:- end_tests(anomalias).
