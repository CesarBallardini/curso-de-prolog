:- encoding(utf8).

:- begin_tests(clausulas).

test(llega) :-
    once(llega(alamos, paso)).

test(mismo_pueblo) :-
    once(llega(islas, islas)).

% La búsqueda en profundidad entra en un ciclo de caminos y no termina.
test(ciclo, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(llega(alamos, islas), 1000000, R).

:- end_tests(clausulas).
