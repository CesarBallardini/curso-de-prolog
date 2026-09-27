:- encoding(utf8).

:- begin_tests(rutas).

test(alumno_cargado, true(N == ana)) :-
    alumno(101, N, _, _).

test(alias) :-
    absolute_file_name(proyecto(datos), _,
                       [file_type(prolog), access(read)]).

:- end_tests(rutas).
