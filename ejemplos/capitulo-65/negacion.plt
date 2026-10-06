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

test(anormal) :-
    anormal(opus),
    \+ anormal(tweety).

% no_vuela/1 pide un individuo muerto: Opus no vuela, pero no por esta
% regla.
test(no_vuela_vivo, [fail]) :-
    no_vuela(opus).

test(no_vuela_dracula, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(no_vuela(dracula), 100000, R).

:- end_tests(negacion).
