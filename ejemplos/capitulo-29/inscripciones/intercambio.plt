:- encoding(utf8).

% Pruebas del módulo intercambio (capítulo 29): leer y escribir archivos. Las
% que escriben usan un archivo temporal y lo borran al terminar.

:- use_module(library(csv)).
:- use_module(library(settings)).
:- use_module(datos).
:- use_module(reglas).

:- begin_tests(intercambio).

% --- Importar --------------------------------------------------------------

test(importar_alumnos, true(A-N == alumno(101, ana, sistemas, 2023)-7)) :-
    importar_alumnos(archivos('alumnos.csv'), [A|Resto]),
    length([A|Resto], N).

% El CSV y los hechos del programa tienen los mismos alumnos.
test(alumnos_iguales, true(D == [])) :-
    alumnos_distintos(archivos('alumnos.csv'), D).

test(alumno_distinto, [ setup(tmp_file(alumnos, F)),
                        cleanup(delete_file(F)),
                        true(D == [alumno(101, ana, civil, 2023),
                                   alumno(108, hugo, civil, 2025)]) ]) :-
    csv_write_file(F, [ row(legajo, nombre, carrera, ingreso),
                        row(101, ana, civil, 2023),
                        row(102, bruno, sistemas, 2024),
                        row(108, hugo, civil, 2025) ]),
    alumnos_distintos(F, D).

test(importar_materias, true(M == Hechos)) :-
    importar_materias(archivos('materias.json'), M),
    findall(materia(C, N, A), materia(C, N, A), Hechos).

% --- Ajustes --------------------------------------------------------------

test(nota_minima_por_omision, true(N == 6)) :-
    nota_minima(N).

% Con los ajustes del archivo, la nota mínima es 7, y un 6 ya no aprueba.
test(cargar_ajustes, [ cleanup(restore_setting(datos:nota_minima)),
                       true(N == 7) ]) :-
    cargar_ajustes(archivos('ajustes.cfg')),
    nota_minima(N),
    \+ aprobada(106, am1, _).

% --- Guardar y cargar el estado --------------------------------------------

% Lo que se guarda se recupera, aunque el estado cambie entre medio.
test(guardar_y_cargar, [ setup(( estado(E), tmp_file(estado, F) )),
                         cleanup(( restaurar(E), delete_file(F) )),
                         true(Despues == E) ]) :-
    guardar_estado(F),
    agregar_inscripcion(104, ssl, cursando),
    cambiar_vacantes(ssl, -1),
    cargar_estado(F),
    estado(Despues).

test(archivo_sin_estado, [ error(domain_error(archivo_de_estado, _)) ]) :-
    absolute_file_name(archivos('hechos.txt'), F),
    cargar_estado(F).

% --- Exportar --------------------------------------------------------------

test(exportar_notas, [ setup(tmp_file(notas, F)),
                       cleanup(delete_file(F)),
                       true(Primeras-N == [ row(legajo, materia, nota),
                                            row(101, alg, 9) ]-15) ]) :-
    exportar_notas(F),
    csv_read_file(F, Filas),
    Filas = [A, B|_],
    Primeras = [A, B],
    length(Filas, N).

test(escribir_ranking, true(Lineas == [ "Legajo  Nombre        Promedio",
                                        "101     ana               8.50",
                                        "104     diego             8.00",
                                        "103     carla             6.00",
                                        "106     facundo           4.50",
                                        "102     bruno             4.00",
                                        "" ])) :-
    with_output_to(string(S), escribir_ranking(current_output)),
    split_string(S, "\n", "", Lineas).

% El archivo tiene lo mismo que se escribe en la terminal.
test(exportar_ranking, [ setup(tmp_file(ranking, F)),
                         cleanup(delete_file(F)),
                         true(EnArchivo == EnPantalla) ]) :-
    exportar_ranking(F),
    read_file_to_string(F, EnArchivo, []),
    with_output_to(string(EnPantalla), escribir_ranking(current_output)).

:- end_tests(intercambio).
