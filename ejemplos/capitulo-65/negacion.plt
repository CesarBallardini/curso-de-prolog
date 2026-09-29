:- encoding(utf8).

:- begin_tests(negacion).

test(tweety, [nondet]) :-
    vuela(tweety).

test(opus, [fail]) :-
    vuela(opus).

% Un ave anormal y un individuo desconocido dan la misma respuesta.
test(nadie, [fail]) :-
    vuela(nadie).

% Las dos reglas se niegan una a la otra: la consulta no termina.
test(dracula_no_termina, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(vuela(dracula), 100000, R).

:- end_tests(negacion).
