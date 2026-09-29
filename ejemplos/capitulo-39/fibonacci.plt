:- encoding(utf8).

:- begin_tests(fibonacci).

test(iguales, [forall(between(0, 20, N)), true(F1 == F2)]) :-
    fib(N, F1),
    fib_tabla(N, F2).

test(grande, [true(F == 354224848179261915075)]) :-
    fib_tabla(100, F).

% Una segunda llamada encuentra la respuesta en la tabla.
test(segunda_llamada, [true(I < 10)]) :-
    fib_tabla(200, _),
    statistics(inferences, I0),
    fib_tabla(200, _),
    statistics(inferences, I1),
    I is I1 - I0.

% abolish_all_tables/0 borra las tablas: la llamada siguiente recalcula.
test(borrar, [true(I > 1000)]) :-
    fib_tabla(200, _),
    abolish_all_tables,
    statistics(inferences, I0),
    fib_tabla(200, _),
    statistics(inferences, I1),
    I is I1 - I0.

% Los recorridos hasta (F, C) son las combinaciones de F + C en F.
test(grilla, [true(Ns == [1, 2, 6, 20, 70])]) :-
    findall(N, ( between(0, 4, K), caminos_grilla(K, K, N) ), Ns).

test(grilla_rectangular, [true(N == 10)]) :-
    caminos_grilla(2, 3, N).

test(grilla_grande, [true(N == 601080390)]) :-
    caminos_grilla(16, 16, N).

test(grilla_verificar, [fail]) :-
    caminos_grilla(0, 3, 5).

:- end_tests(fibonacci).
