:- encoding(utf8).

% Pruebas de soluciones_construir.pl: la prueba de lo construido, que pasa
% con contar.pl y no con refranes.pl, que no tiene la opción --help.

:- use_module(library(filesex)).

:- begin_tests(soluciones_construir).

%!  del_capitulo(+Archivo:atom, -Ruta:atom) is det.
%
%   Ruta es Archivo en el directorio de este capítulo.
del_capitulo(Archivo, Ruta) :-
    source_file(user:probar(_, _), Constructor),
    file_directory_name(Constructor, Capitulo),
    directory_file_path(Capitulo, Archivo, Ruta).

test(pasa, [ setup(( tmp_file(construido, D), make_directory(D) )),
             cleanup(delete_directory_and_contents(D)) ]) :-
    del_capitulo('contar.pl', Programa),
    with_output_to(string(_), construir_y_probar(D, true, Programa)).

test(no_pasa, [ setup(( tmp_file(construido, D), make_directory(D) )),
                cleanup(delete_directory_and_contents(D)),
                throws(prueba(_, exit(1))) ]) :-
    del_capitulo('refranes.pl', Programa),
    with_output_to(string(_), construir_y_probar(D, true, Programa)).

test(sin_probar, [ setup(( tmp_file(construido, D), make_directory(D) )),
                   cleanup(delete_directory_and_contents(D)) ]) :-
    del_capitulo('refranes.pl', Programa),
    with_output_to(string(_), construir_y_probar(D, false, Programa)).

:- end_tests(soluciones_construir).
