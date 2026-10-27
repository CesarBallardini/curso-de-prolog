:- encoding(utf8).

:- begin_tests(planificador).

test(coffman, [true(D-G == 24-optima(a_estrella))]) :-
    ejemplo(coffman, P),
    planificar(P, 1000000, C, G),
    valido(P, C),
    duracion(C, D).

test(casa_limite, [true(D-G == 28-entre(27, 28))]) :-
    ejemplo(casa, P),
    planificar(P, 10000, C, G),
    valido(P, C),
    duracion(C, D).

test(casa, [true(D-G == 28-optima(a_estrella))]) :-
    ejemplo(casa, P),
    planificar(P, 1000000, C, G),
    duracion(C, D).

test(por_lista, [true(D-G == 30-optima(por_lista))]) :-
    ejemplo(taller(14), P),
    planificar(P, 1000, C, G),
    valido(P, C),
    duracion(C, D).

test(cota, [true(Cs == [24, 27, 27])]) :-
    findall(C, ( member(E, [coffman, casa, taller(13)]),
                 ejemplo(E, P),
                 cota_inferior(P, C) ),
            Cs).

test(mejor_por_lista, [true(D == 28)]) :-
    ejemplo(taller(13), P),
    mejor_por_lista(P, C),
    valido(P, C),
    duracion(C, D).

test(ciclo, [fail]) :-
    P = proyecto([tarea(a, 1), tarea(b, 1)], [antes(a, b), antes(b, a)], 2),
    planificar(P, 1000, _, _).

test(informe, [true(S == "P1 a---c-\nP2 b-\nduración: 3\nes la duración óptima (por_lista)\n")]) :-
    P = proyecto([tarea(a, 2), tarea(b, 1), tarea(c, 1)], [antes(a, c)], 2),
    with_output_to(string(S), informe(P, 1000)).

test(planificar_ejemplo, [true(L == [28-entre(27, 28), 27-optima(a_estrella)])]) :-
    findall(D-G,
            ( member(Limite, [1000000, 3000000]),
              planificar_ejemplo(taller(13), Limite, D, G) ),
            L).

test(informe_de) :-
    with_output_to(string(S), informe_de(coffman, 1000000)),
    once(sub_string(S, _, _, _, "duración: 24")).

:- end_tests(planificador).
