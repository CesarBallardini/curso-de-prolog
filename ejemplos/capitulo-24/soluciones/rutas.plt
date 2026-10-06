:- encoding(utf8).

:- begin_tests(rutas).

test(alumno_cargado, true(N == ana)) :-
    alumno(101, N, _, _).

% absolute_file_name/3, que resuelve la ruta de un archivo,
% se presenta en el capítulo 27.
test(alias) :-
    absolute_file_name(proyecto(datos), _,
                       [file_type(prolog), access(read)]).

:- end_tests(rutas).
