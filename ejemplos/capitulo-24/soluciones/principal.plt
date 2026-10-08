:- encoding(utf8).

:- begin_tests(principal).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
test(cantidad, true(S == "17 inscripciones\n")) :-
    with_output_to(string(S), informar_inscripciones).

:- end_tests(principal).
