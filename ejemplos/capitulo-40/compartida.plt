:- encoding(utf8).

:- begin_tests(compartida, [setup(abolish_all_tables)]).

% Lo que otro hilo calculó en una tabla común se vuelve a calcular.
test(privada, [setup(abolish_all_tables), true(I > 1000)]) :-
    en_otro_hilo(fib_privada(300, _)),
    inferencias(fib_privada(300, _), I).

% Una tabla compartida completa se usa desde cualquier hilo.
test(compartida, [setup(abolish_all_tables), true(I < 100)]) :-
    en_otro_hilo(fib_compartida(300, _)),
    inferencias(fib_compartida(300, _), I).

% Varios hilos a la vez sobre la misma tabla dan los valores correctos.
test(concurrentes, [setup(abolish_all_tables), true(Fs == [F, F, F, F])]) :-
    fib_privada(250, F),
    concurrent_maplist([N, X]>>fib_compartida(N, X), [250, 250, 250, 250],
                       Fs).

test(falla, [fail]) :-
    en_otro_hilo(fail).

:- end_tests(compartida).
