:- encoding(utf8).

% Pruebas de soluciones_proyecto.pl: el programa del proyecto, construido,
% conserva una inscripción de una ejecución a la siguiente.

:- use_module(library(filesex)).

:- begin_tests(soluciones_proyecto).

% La primera ejecución inscribe al alumno 105 en álgebra y guarda el
% estado; la segunda lo carga, y el alumno aparece entre los inscriptos.
test(estado_conservado,
     [ setup(( tmp_file(construido, D), make_directory(D) )),
       cleanup(delete_directory_and_contents(D)),
       true(E1-S2 == exit(0)-["Inscriptos: 101, 102, 103, 104, 105."]) ]) :-
    source_file(user:ejecutar_construido(_, _, _, _, _), Solucion),
    file_directory_name(Solucion, Capitulo),
    directory_file_path(Capitulo, 'inscripciones/principal.pl', Programa),
    with_output_to(string(_), construir(D, Programa)),
    directory_file_path(D, 'estado.txt', Archivo),
    atom_concat('--estado=', Archivo, Opcion),
    ejecutar_construido(D, principal, [Opcion, inscribir, a, '105', en,
                                       algebra], _, E1),
    ejecutar_construido(D, principal, [Opcion, listar, algebra], S2, _).

% Sin el archivo de estado, cada ejecución empieza de los datos del
% programa: la inscripción no se conserva.
test(sin_estado,
     [ setup(( tmp_file(construido, D), make_directory(D) )),
       cleanup(delete_directory_and_contents(D)),
       true(S2 == ["Inscriptos: 101, 102, 103, 104."]) ]) :-
    source_file(user:ejecutar_construido(_, _, _, _, _), Solucion),
    file_directory_name(Solucion, Capitulo),
    directory_file_path(Capitulo, 'inscripciones/principal.pl', Programa),
    with_output_to(string(_), construir(D, Programa)),
    ejecutar_construido(D, principal, [inscribir, a, '105', en, algebra],
                        _, _),
    ejecutar_construido(D, principal, [listar, algebra], S2, _).

:- end_tests(soluciones_proyecto).
