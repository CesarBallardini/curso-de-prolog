:- encoding(utf8).

:- begin_tests(memo).

test(fib_20, true(F == 6765)) :-
    fib(20, F).

test(fib_memo_20, [ setup(olvidar_fib), cleanup(olvidar_fib),
                    true(F == 6765) ]) :-
    fib_memo(20, F).

test(fib_iguales, [ setup(olvidar_fib), cleanup(olvidar_fib),
                    true(F1 == F2) ]) :-
    fib(15, F1),
    fib_memo(15, F2).

% Los valores guardados: del 2 al 20.
test(guardados, [ setup(olvidar_fib), cleanup(olvidar_fib),
                  true(N == 19) ]) :-
    fib_memo(20, _),
    aggregate_all(count, fib_guardado(_, _), N).

% Estabilidad: con el resultado ligado a un valor falso, falla.
test(fib_memo_estable, [ setup(olvidar_fib), cleanup(olvidar_fib), fail ]) :-
    fib_memo(10, 54).

% Las cantidades exactas varían con el contexto; las cotas no.
test(menos_inferencias, [ setup(olvidar_fib), cleanup(olvidar_fib) ]) :-
    inferencias(fib(20, _), Ingenua),
    inferencias(fib_memo(20, _), Memo),
    Ingenua > 60000,
    Memo < 300.

test(segunda_llamada, [ setup(olvidar_fib), cleanup(olvidar_fib) ]) :-
    fib_memo(20, _),
    inferencias(fib_memo(20, _), I),
    I < 10.

:- end_tests(memo).
