:- encoding(utf8).

:- begin_tests(lista).

test(coffman_orden, [true(D == 33)]) :-
    ejemplo(coffman, P),
    por_lista(P, orden, C),
    valido(P, C),
    duracion(C, D).

test(coffman_larga, [true(D == 33)]) :-
    ejemplo(coffman, P),
    por_lista(P, larga, C),
    valido(P, C),
    duracion(C, D).

test(coffman_calendario,
     [true(C == [ asignada(t1, 1, 0, 4), asignada(t2, 2, 0, 2),
                  asignada(t3, 3, 0, 2), asignada(t6, 2, 2, 13),
                  asignada(t7, 3, 2, 13), asignada(t4, 1, 4, 24),
                  asignada(t5, 2, 13, 33) ])]) :-
    ejemplo(coffman, P),
    por_lista(P, orden, C).

test(casa, [true(D == 28)]) :-
    ejemplo(casa, P),
    por_lista(P, orden, C),
    valido(P, C),
    duracion(C, D).

test(ordenadas, [true(D1-D2 == 13-10)]) :-
    P = proyecto([tarea(a, 3), tarea(b, 3), tarea(c, 10)], [], 2),
    por_lista(P, ordenadas([a, b, c]), C1),
    duracion(C1, D1),
    por_lista(P, ordenadas([c, a, b]), C),
    valido(P, C),
    duracion(C, D2).

test(espera, [true(C == [ asignada(a, 1, 0, 5), asignada(b, 2, 0, 1),
                          asignada(c, 1, 5, 6) ])]) :-
    P = proyecto([tarea(a, 5), tarea(b, 1), tarea(c, 1)],
                 [antes(a, c)], 2),
    por_lista(P, orden, C).

test(ciclo, [fail]) :-
    P = proyecto([tarea(a, 1), tarea(b, 1)], [antes(a, b), antes(b, a)], 2),
    por_lista(P, orden, _).

test(lista, [true(Ts == [t4, t5, t6, t7])]) :-
    ejemplo(coffman, P),
    findall(T, ( tarea(P, T, _),
                 \+ memberchk(T, [t1, t2, t3]),
                 lista(P, T, 4, [t1-4, t2-2, t3-2]) ),
            Ts).

test(medir_lista, [true(D == 28)]) :-
    medir_lista(casa, larga, D).

test(ver_lista) :-
    with_output_to(string(S), ver_lista(coffman, orden)),
    once(sub_string(S, _, _, _, "duración: 33")).

:- end_tests(lista).
