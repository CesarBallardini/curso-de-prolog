:- encoding(utf8).

% Pruebas de las soluciones de los ejercicios 12 a 15. Las que cambian el
% estado lo restauran; las que escriben usan un archivo temporal.

:- begin_tests(soluciones_proyecto).

%!  escribir_csv(+Archivo, +Filas:list) is det.
%
%   Escribe Filas en Archivo como CSV: los datos de entrada de una prueba.
escribir_csv(Archivo, Filas) :-
    csv_write_file(Archivo, Filas, [encoding(utf8)]).

% --- Ejercicio 12 -----------------------------------------------------------

test(guardar_y_cargar_hechos, [ setup(( estado(E), tmp_file(hechos, F) )),
                                cleanup(( restaurar(E), delete_file(F) )),
                                true(Despues == E) ]) :-
    guardar_hechos(F),
    agregar_inscripcion(104, ssl, cursando),
    cambiar_vacantes(ssl, -1),
    cargar_hechos(F),
    estado(Despues).

% El archivo tiene un hecho por línea: 17 inscripciones, 7 vacantes y el
% contador.
test(un_hecho_por_linea, [ setup(tmp_file(hechos, F)),
                           cleanup(delete_file(F)),
                           true(N == 25) ]) :-
    guardar_hechos(F),
    read_file_to_string(F, S, [encoding(utf8)]),
    split_string(S, "\n", "", Lineas),
    length(Lineas, N0),
    N is N0 - 1.

test(hechos_ajenos, [ setup(( estado(E), tmp_file(hechos, F) )),
                      cleanup(( restaurar(E), delete_file(F) )),
                      error(domain_error(archivo_de_hechos, _)) ]) :-
    setup_call_cleanup(open(F, write, S, [encoding(utf8)]),
                       portray_clause(S, padre(juan, ana)),
                       close(S)),
    cargar_hechos(F).

% --- Ejercicio 13 -----------------------------------------------------------

test(exportar_inscriptos, [ setup(tmp_file(inscriptos, F)),
                            cleanup(delete_file(F)),
                            true(Filas == [ row(legajo, nombre, estado),
                                            row(101, ana, 8),
                                            row(102, bruno, 4),
                                            row(103, carla, 7),
                                            row(105, elena, cursando),
                                            row(106, facundo, 6) ]) ]) :-
    exportar_inscriptos(am1, F),
    csv_read_file(F, Filas).

% --- Ejercicio 14 -----------------------------------------------------------

% Una nota nueva, y otra que reemplaza una cursada.
test(importar_notas, [ setup(( estado(E), tmp_file(notas, F) )),
                       cleanup(( restaurar(E), delete_file(F) )),
                       true(Estados == [nota(9), nota(7)]) ]) :-
    escribir_csv(F, [ row(legajo, materia, nota),
                      row(104, ssl, 9),
                      row(105, am1, 7) ]),
    importar_notas(F),
    findall(Estado, ( member(L-M, [104-ssl, 105-am1]),
                      inscripcion(L, M, Estado) ),
            Estados).

% Una fila incorrecta: no se registra ninguna, tampoco las correctas.
test(alumno_inexistente, [ setup(( estado(E), tmp_file(notas, F) )),
                           cleanup(( restaurar(E), delete_file(F) )),
                           true(Despues == E) ]) :-
    escribir_csv(F, [ row(legajo, materia, nota),
                      row(104, ssl, 9),
                      row(999, am1, 7) ]),
    catch(importar_notas(F), error(existence_error(alumno, 999), _), true),
    estado(Despues).

test(materia_inexistente, [ setup(( estado(E), tmp_file(notas, F) )),
                            cleanup(( restaurar(E), delete_file(F) )),
                            error(existence_error(materia, quimica)) ]) :-
    escribir_csv(F, [row(legajo, materia, nota), row(104, quimica, 9)]),
    importar_notas(F).

test(nota_invalida, [ setup(( estado(E), tmp_file(notas, F) )),
                      cleanup(( restaurar(E), delete_file(F) )),
                      error(type_error(between(1, 10), 11)) ]) :-
    escribir_csv(F, [row(legajo, materia, nota), row(104, ssl, 11)]),
    importar_notas(F).

% --- Ejercicio 15 -----------------------------------------------------------

test(escribir_materias, true(Lineas == [
         "Código  Nombre          Año     Inscriptos  Promedio",
         "am1     analisis_1      1                5      6.25",
         "alg     algebra         1                4      5.75",
         "log     logica          1                4      7.00",
         "am2     analisis_2      2                2      7.00",
         "pp      paradigmas      2                2      8.00",
         "ssl     sintaxis        2                0         -",
         "bd      bases_de_datos  3                0         -",
         "" ])) :-
    with_output_to(string(S), escribir_materias(current_output)),
    split_string(S, "\n", "", Lineas).

:- end_tests(soluciones_proyecto).
