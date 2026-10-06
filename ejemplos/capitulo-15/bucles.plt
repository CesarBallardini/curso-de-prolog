:- encoding(utf8).

:- begin_tests(bucles).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
test(listar_las_tres_edades, true(S == "juan: 68\nana: 41\nluis: 12\n")) :-
    with_output_to(string(S), listar_edades).

test(tabla_del_7, true(Primera == "7 x 1 = 7")) :-
    with_output_to(string(S), tabla_de_multiplicar(7)),
    split_string(S, "\n", "", [Primera|_]).

test(tabla_de_diez_lineas, true(N == 10)) :-
    with_output_to(string(S), tabla_de_multiplicar(3)),
    split_string(S, "\n", "", Lineas),
    length(Lineas, Largo),
    N is Largo - 1.

:- end_tests(bucles).
