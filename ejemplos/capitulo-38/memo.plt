:- encoding(utf8).

:- begin_tests(memo).

% Las dos versiones dan el valor correcto en todos los hilos.
test(correctos, [forall(member(Fib, [fib_compartido, fib_local]))]) :-
    en_hilos(Fib, 8, 300).

% La tabla compartida tiene al menos un hecho por valor calculado; cuántos
% repetidos más depende del orden de los hilos, y no se prueba.
test(compartida, [true(Distintos == 299)]) :-
    en_hilos(fib_compartido, 8, 300),
    aggregate_all(count, user:guardado(_, _), Hechos),
    assertion(Hechos >= 299),
    findall(N, user:guardado(N, _), Ns),
    sort(Ns, Sin),
    length(Sin, Distintos).

% La tabla de cada hilo es suya: el hilo que llama no ve las de los otros.
test(local, [true(N == 0)]) :-
    en_hilos(fib_local, 8, 300),
    aggregate_all(count, user:guardado_local(_, _), N).

test(local_propia, [true(F-N == 55-9)]) :-
    retractall(user:guardado_local(_, _)),
    fib_local(10, F),
    aggregate_all(count, user:guardado_local(_, _), N).

:- end_tests(memo).
