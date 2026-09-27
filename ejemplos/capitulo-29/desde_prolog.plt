:- encoding(utf8).

% Pruebas de desde_prolog.pl. Necesitan Python: test_desde_prolog.py las
% ejecuta dentro del proceso de Python, con Janus.

:- begin_tests(desde_prolog).

test(raiz, true(R =:= 4)) :-
    raiz(16, R).

test(mediana, true(M == 3)) :-
    mediana([3, 1, 4, 1, 5], M).

test(palabras_frecuentes, true(P == [a-3, b-2])) :-
    palabras_frecuentes("a b a c b a", 2, P).

% Un error de Python llega a Prolog como una excepción.
test(error_de_python, error(python_error('ValueError', _))) :-
    raiz(-1, _).

:- end_tests(desde_prolog).
