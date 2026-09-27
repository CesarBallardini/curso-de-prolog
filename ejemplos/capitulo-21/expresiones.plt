:- encoding(utf8).

:- begin_tests(expresiones).

test(resta, true(V == 5)) :-
    phrase(resta(V), `10-3-2`).

test(un_numero, true(V == 7)) :-
    phrase(resta(V), `7`).

test(incompleta, [fail]) :-
    phrase(resta(_), `10-`).

% Sin acumulador, la resta agrupa a la derecha.
test(resta_derecha, true(V == 9)) :-
    phrase(resta_derecha(V), `10-3-2`).

% La recursión a izquierda no termina: con un límite de un millón de
% inferencias, la consulta lo agota sin dar ninguna respuesta.
test(recursion_a_izquierda, true(R == inference_limit_exceeded)) :-
    call_with_inference_limit(phrase(resta_izquierda(_), `10-3-2`),
                              1000000, R).

:- end_tests(expresiones).
