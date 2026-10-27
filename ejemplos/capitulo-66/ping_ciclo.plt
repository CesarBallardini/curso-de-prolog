:- encoding(utf8).

:- begin_tests(ping_ciclo).

% Con la incompatibilidad escrita como reglas estrictas, la consulta no
% termina.
test(no_termina, [true(L == inference_limit_exceeded)]) :-
    call_with_inference_limit(respuesta([], capitalista(ping), _), 200000,
                              L).

% La parte estricta sola sí termina: no hay hechos sobre la ideología.
test(estricta, [fail]) :-
    estricto(neg capitalista(ping)).

:- end_tests(ping_ciclo).
