:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 9: preguntar a las partes.
test(largo_mal_vacia, true(N == 1)) :-
    largo_mal([], N).

test(largo, true(N-M == 0-2)) :-
    largo([], N),
    largo([a, b], M).

% Ejercicio 10
test(hermanos_mal_falla, [fail]) :-
    hermanos_mal(ana, pedro).

test(hermanos_recortado, [nondet]) :-
    hermanos_recortado(ana, pedro).

test(hermanos, all(H == [pedro])) :-
    hermanos(ana, H).

% Ejercicio 14: un límite para una consulta que no termina. Un límite de
% inferencias no depende de la velocidad de la máquina.
test(no_termina, true(R == inference_limit_exceeded)) :-
    call_with_inference_limit(natural(-1), 100000, R).

test(con_limite, [timeout(5)]) :-
    natural(3),
    !.

:- end_tests(soluciones).
