:- encoding(utf8).

:- use_module(library(apply)).

:- begin_tests(secuenciales).

test(divisor, [nondet, true(Ss == [[0], [1], [0], [1], [0]])]) :-
    vacios(5, Ps),
    ejecutar(divisor, [0], Ps, Ss).

test(paridad, [nondet, true(Ss == [[1], [1], [1], [0], [1], [1]])]) :-
    ejecutar(paridad, [0], [[1], [0], [0], [1], [1], [0]], Ss).

% En sentido inverso: las entradas que dan una sucesión de paridades.
test(paridad_inversa, [true(Ps == [[[1], [0], [1]]])]) :-
    findall(P, ejecutar(paridad, [0], P, [[1], [1], [0]]), Ps).

% La salida del registro es la entrada de cuatro pulsos antes.
test(registro4, [nondet, true(Ss == [[0], [0], [0], [0], [1], [0], [0],
                                     [1], [1], [0]])]) :-
    ejecutar(registro4, [0, 0, 0, 0],
             [[1], [0], [0], [1], [1], [0], [0], [1], [1], [1]], Ss).

test(gray, [nondet, true(Ss == [[0, 0, 0], [1, 0, 0], [1, 1, 0], [0, 1, 0],
                                [0, 1, 1], [1, 1, 1], [1, 0, 1], [0, 0, 1],
                                [0, 0, 0]])]) :-
    vacios(9, Ps),
    ejecutar(contador_gray, [0, 0, 0], Ps, Ss).

test(paso, [nondet, true(Ss-E == [0, 1, 1]-[1, 0, 1])]) :-
    paso(contador_gray, [0, 0, 1], [], Ss, E).

test(estado_incorrecto, [fail]) :-
    paso(contador_gray, [0, 0], [], _, _).

% vacios(N, Ps): Ps son N pulsos sin entradas externas.
vacios(N, Ps) :-
    length(Ps, N),
    maplist(=([]), Ps).

test(secuencial, [true(C-K == divisor_c-1)]) :-
    secuencial(divisor, C, K).

test(pulso, [nondet, true(Ss-E == [1]-[1])]) :-
    secuenciales:pulso(paridad, [1], Ss, [0], E).

:- end_tests(secuenciales).
