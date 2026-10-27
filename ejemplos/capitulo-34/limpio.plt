:- encoding(utf8).

:- begin_tests(limpio).

test(limpiar,
     true(C == (prog(edad(a, E)), prog(edad(b, F)), sis(E > F)))) :-
    limpiar((edad(a, E), edad(b, F), E > F), C).

test(limpiar_hecho, true(C == true)) :-
    limpiar(true, C).

test(clausula_hecho, all(H == [ana, pedro])) :-
    clausula(padre(juan, H), true).

test(mayor_que, all(P == [ana, pedro])) :-
    resolver(mayor_que(juan, P)).

test(mayor_que_falla, [fail]) :-
    resolver(mayor_que(pedro, juan)).

test(ejecutar_falla, [fail]) :-
    ejecutar(3 < 2).

test(ejecutar_corte, [true]) :-
    ejecutar(!).

test(limpiar_corte, true(C == sis(!))) :-
    limpiar(!, C).

test(mayor_que_como_prolog, true(Rs == Ps)) :-
    findall(A-B, resolver(mayor_que(A, B)), Rs),
    findall(A-B, mayor_que(A, B), Ps).

test(antepasado_como_prolog, true(Rs == Ps)) :-
    findall(A-D, resolver(antepasado(A, D)), Rs),
    findall(A-D, antepasado(A, D), Ps).

test(longitud, [nondet, true(N == 1000)]) :-
    numlist(1, 1000, L),
    resolver(longitud(L, N)).

% El corte del programa no llega al intérprete: maximo/3 da dos respuestas,
% y la segunda es incorrecta.
test(maximo_prolog, all(M == [5])) :-
    maximo(5, 3, M).

test(maximo_interpretado, all(M == [5, 3])) :-
    resolver(maximo(5, 3, M)).

% Un predicado no definido: Prolog produce un error; el intérprete falla,
% porque clause/2 falla.
test(no_definido_prolog,
     [error(existence_error(procedure, _))]) :-
    user:no_definido(_).

test(no_definido_interpretado, [fail]) :-
    resolver(no_definido(_)).

:- end_tests(limpio).
