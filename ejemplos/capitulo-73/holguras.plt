:- encoding(utf8).

:- use_module(camino, [cola/3]).

:- begin_tests(holguras).

test(fechas_casa,
     [true(Fs-L == [ fechas(cimientos, 0, 0), fechas(paredes, 5, 5),
                     fechas(aberturas, 13, 25), fechas(agua, 13, 15),
                     fechas(luz, 13, 16), fechas(techo, 13, 13),
                     fechas(revoque, 19, 19), fechas(pintura, 24, 24) ]-27)]) :-
    ejemplo(casa, P),
    fechas(P, Fs, L).

test(fechas_coffman, [true(L == 24)]) :-
    ejemplo(coffman, P),
    fechas(P, _, L).

test(holguras_coffman,
     [true(Hs == [t1-0, t2-2, t3-2, t4-0, t5-0, t6-11, t7-11])]) :-
    ejemplo(coffman, P),
    holguras(P, Hs).

test(critico_casa, [true(Ts == [cimientos, paredes, techo, revoque, pintura])]) :-
    ejemplo(casa, P),
    camino_critico(P, Ts).

test(critico_coffman, [true(Ts == [t1, t4, t5])]) :-
    ejemplo(coffman, P),
    camino_critico(P, Ts).

test(sin_precedencias, [true(Fs-L == [fechas(a, 0, 3), fechas(b, 0, 0)]-5)]) :-
    fechas(proyecto([tarea(a, 2), tarea(b, 5)], [], 1), Fs, L).

test(ciclo, [fail]) :-
    fechas(proyecto([tarea(a, 1), tarea(b, 1)],
                    [antes(a, b), antes(b, a)], 1), _, _).

% La fecha tardía es la duración mínima menos la cola del capítulo.
test(tardia_y_cola) :-
    forall(member(N, [coffman, casa, taller(8)]),
           ( ejemplo(N, P),
             fechas(P, Fs, L),
             forall(member(fechas(T, _, J), Fs),
                    ( cola(P, T, C),
                      J =:= L - C )) )).

test(temprana, [true(I == 13)]) :-
    ejemplo(casa, P),
    list_to_assoc([cimientos-0, paredes-5], A0),
    holguras:temprana(P, techo, A0, A),
    get_assoc(techo, A, I).

test(mayor_fin, [true(L == 13)]) :-
    ejemplo(casa, P),
    list_to_assoc([paredes-5], A),
    holguras:mayor_fin(P, A, paredes, 10, L).

test(tardia, [true(J == 15)]) :-
    ejemplo(casa, P),
    list_to_assoc([revoque-19], A0),
    holguras:tardia(P, 27, agua, A0, A),
    get_assoc(agua, A, J).

test(fechas_de, [true(L == 27)]) :-
    fechas_de(casa, _, L).

test(holguras_de, [true(Hs == [t1-0, t2-2, t3-2, t4-0, t5-0, t6-11, t7-11])]) :-
    holguras_de(coffman, Hs).

test(de_inexistente, [fail]) :-
    holguras_de(ninguno, _).

:- end_tests(holguras).
