:- encoding(utf8).

:- begin_tests(soluciones_vectores).

test(suma_rec, [true(S == 10)]) :-
    suma_rec([1, 2, 3, 4], S).

test(suma_acc, [true(S == 10)]) :-
    suma_acc([1, 2, 3, 4], S).

test(suma_acc3, [true(S == 15)]) :-
    suma_acc([1, 2, 3, 4], 5, S).

test(costos_suma, [true(Cs == [rec-2003, acc-2004])]) :-
    costos_suma(1000, Cs).

test(con_pila_rec, [true(R == sin_pila)]) :-
    con_pila(12000000, suma_rec, 200000, R).

test(con_pila_acc, [true(R == suma(20000100000))]) :-
    con_pila(12000000, suma_acc, 200000, R).

test(con_pila_restituye, [true(L1 == L0)]) :-
    current_prolog_flag(stack_limit, L0),
    con_pila(12000000, suma_acc, 10, _),
    current_prolog_flag(stack_limit, L1).

test(esquema_general, [true(R == 3)]) :-
    esquema_general(==(3), =, succ, 0, R).

test(entrenar_general, [true]) :-
    forall(member(N-T-P0, [y-1-[0, 0, 0],
                           puntos-0.25-[0.13, -0.51, -0.35]]),
           ( pasos(N, T, P0, P1, K1),
             entrenar_general(N, T, P0, P2, K2),
             K1 == K2,
             maplist(=:=, P1, P2) )).

test(minimo, [true(M == -3)]) :-
    minimo([7, -3, 2, 5], M).

test(minimo_uno, [true(M == 4)]) :-
    minimo([4], M).

test(minimo_vacio, [fail]) :-
    minimo([], _).

test(resto_vacio, [true]) :-
    resto_vacio([]-1).

test(menor, [true(M == 2)]) :-
    menor([5]-2, M).

test(avanzar, [true(A == [2]-(-3))]) :-
    avanzar([-3, 2]-7, A).

:- end_tests(soluciones_vectores).
