:- encoding(utf8).

:- begin_tests(tareas).

test(coffman_valido) :-
    ejemplo(coffman, P),
    calendario_coffman(C),
    valido(P, C).

test(duracion, [true(D == 24)]) :-
    calendario_coffman(C),
    duracion(C, D).

test(duracion_vacia, [true(D == 0)]) :-
    duracion([], D).

test(precedencia_violada, [fail]) :-
    ejemplo(coffman, P),
    calendario_coffman(C0),
    selectchk(asignada(t5, 1, 4, 24), C0, asignada(t5, 1, 1, 21), C),
    valido(P, C).

test(superpuestas, [fail]) :-
    ejemplo(coffman, P),
    calendario_coffman(C0),
    selectchk(asignada(t7, 3, 2, 13), C0, asignada(t7, 1, 2, 13), C),
    valido(P, C).

test(falta_una, [fail]) :-
    ejemplo(coffman, P),
    calendario_coffman(C0),
    selectchk(asignada(t6, _, _, _), C0, C),
    valido(P, C).

test(duracion_equivocada, [fail]) :-
    ejemplo(coffman, P),
    calendario_coffman(C0),
    selectchk(asignada(t6, 3, 13, 24), C0, asignada(t6, 3, 13, 23), C),
    valido(P, C).

test(procesador_inexistente, [fail]) :-
    ejemplo(coffman, P),
    calendario_coffman(C0),
    selectchk(asignada(t6, 3, 13, 24), C0, asignada(t6, 4, 13, 24), C),
    valido(P, C).

test(lineas, [true(L == ["P1 a-..b-", "P2 c-----"])]) :-
    lineas(proyecto([tarea(a, 1), tarea(b, 1), tarea(c, 3)], [], 2),
           [asignada(a, 1, 0, 1), asignada(c, 2, 0, 3), asignada(b, 1, 2, 3)],
           L).

test(repartir, [true(C == [asignada(b, 1, 0, 2), asignada(a, 2, 0, 4),
                          asignada(c, 1, 2, 5), asignada(d, 2, 4, 6)])]) :-
    repartir(2, [tramo(d, 4, 6), tramo(c, 2, 5), tramo(b, 0, 2),
                 tramo(a, 0, 4)], C).

test(repartir_sin_lugar, [fail]) :-
    repartir(1, [tramo(a, 0, 4), tramo(b, 1, 2)], _).

test(taller, [true(N-M == 8-2)]) :-
    ejemplo(taller(8), P),
    aggregate_all(count, tarea(P, _, _), N),
    aggregate_all(count, precede(P, _, _), M).

test(casa_procesadores, [true(N == 2)]) :-
    ejemplo(casa, P),
    procesadores(P, N).

test(orden_topologico, [true(Ts == [cimientos, paredes, aberturas, agua,
                                     luz, techo, revoque, pintura])]) :-
    ejemplo(casa, P),
    orden_topologico(P, Ts).

test(ciclo, [fail]) :-
    orden_topologico(proyecto([tarea(a, 1), tarea(b, 1)],
                              [antes(a, b), antes(b, a)], 1), _).

test(superpuestas) :-
    tareas:superpuestas([asignada(a, 1, 0, 4), asignada(b, 1, 3, 5)]).

% Una tarea que empieza cuando otra termina, o en otro procesador, no se
% superpone.
test(no_superpuestas, [fail]) :-
    tareas:superpuestas([asignada(a, 1, 0, 4), asignada(b, 1, 4, 5),
                         asignada(c, 2, 0, 5)]).

test(por_inicio, [true(X == 2-tramo(t1, 2, 6))]) :-
    tareas:por_inicio(tramo(t1, 2, 6), X).

test(ubicar, [true(A-L == asignada(t4, 1, 4, 24)-[24, 4, 4])]) :-
    tareas:ubicar(tramo(t4, 4, 24), A, [2, 4, 4], L).

test(ubicar_sin_procesador, [fail]) :-
    tareas:ubicar(tramo(t4, 1, 24), _, [2, 4, 4], _).

:- end_tests(tareas).
