:- encoding(utf8).

:- begin_tests(sistema).

% muestra(-D): D es una carpeta temporal nueva con el modelo de ejemplo.
muestra(D) :-
    tmp_file(ordenes, D),
    make_directory(D),
    modelo_ejemplo(M),
    crear_muestra(D, M).

% cumplir(+D, +Orden, +Respuestas, -Resultados, -Preguntas): cumple Orden
% en D; las confirmaciones se leen de Respuestas y se escriben en Preguntas.
cumplir(D, Orden, Respuestas, Resultados, Preguntas) :-
    leer_modelo(D, M),
    planificar(Orden, M, Plan),
    open_string(Respuestas, In),
    with_output_to(string(Preguntas),
                   ( current_output(Out),
                     ejecutar_plan(real, D, Plan, read_line_to_string(In),
                                   Out, Resultados) )).

existe(D, R) :-
    directory_file_path(D, R, Abs),
    exists_file(Abs).

test(ida_y_vuelta, [ setup(muestra(D)),
                     cleanup(delete_directory_and_contents(D)) ]) :-
    leer_modelo(D, M),
    modelo_ejemplo(M).

test(copiar, [ setup(muestra(D)),
               cleanup(delete_directory_and_contents(D)) ]) :-
    cumplir(D, copiar(archivos("informes", patron("*.txt")), a("respaldo")),
            "", Rs, _),
    Rs == [ copiado("informes/acta.txt", "respaldo/acta.txt"),
            copiado("informes/notas.txt", "respaldo/notas.txt") ],
    existe(D, "respaldo/acta.txt"),
    existe(D, "informes/acta.txt").

test(mover, [ setup(muestra(D)),
              cleanup(delete_directory_and_contents(D)) ]) :-
    cumplir(D, mover(archivo("notas.txt"), a("apuntes.txt")), "", Rs, _),
    Rs == [movido("notas.txt", "apuntes.txt")],
    existe(D, "apuntes.txt"),
    \+ existe(D, "notas.txt").

test(borrar_si, [ setup(muestra(D)),
                  cleanup(delete_directory_and_contents(D)) ]) :-
    cumplir(D, borrar(archivo("borrador.tmp")), "sí\n", Rs, Pregunta),
    Rs == [borrado("borrador.tmp")],
    Pregunta == "¿Quieres borrar borrador.tmp? (s/n) ",
    \+ existe(D, "borrador.tmp").

test(borrar_no, [ setup(muestra(D)),
                  cleanup(delete_directory_and_contents(D)) ]) :-
    cumplir(D, borrar(archivos("informes", patron("*.txt"))), "s\nn\n", Rs,
            _),
    Rs == [borrado("informes/acta.txt"), conservado("informes/notas.txt")],
    existe(D, "informes/notas.txt").

test(borrar_sin_respuesta, [ setup(muestra(D)),
                             cleanup(delete_directory_and_contents(D)) ]) :-
    cumplir(D, borrar(archivo("notas.txt")), "", Rs, _),
    Rs == [conservado("notas.txt")],
    existe(D, "notas.txt").

test(simulacion, [ setup(muestra(D)),
                   cleanup(delete_directory_and_contents(D)) ]) :-
    leer_modelo(D, M),
    planificar(borrar(archivos(".", patron("*"))), M, Plan),
    ejecutar_plan(simulacion, D, Plan, read_line_to_string(user_input),
                  user_output, Rs),
    Rs == [ simulada(borrar("borrador.tmp")),
            simulada(borrar("hola.pl")),
            simulada(borrar("notas.txt")) ],
    leer_modelo(D, M).

test(ejecutar, [ setup(muestra(D)),
                 cleanup(delete_directory_and_contents(D)) ]) :-
    cumplir(D, ejecutar(archivo("hola.pl")), "", Rs, _),
    Rs == [salida("hola.pl", exit(0), ["Hola desde hola.pl"])].

test(informar, [ setup(muestra(D)),
                 cleanup(delete_directory_and_contents(D)) ]) :-
    cumplir(D, tamano(archivo("informes/notas.txt")), "", Rs, _),
    Rs == [tamano(["informes/notas.txt"], 120)].

test(fuera, [ setup(muestra(D)),
              cleanup(delete_directory_and_contents(D)),
              error(permission_error(acceder, ruta, "../x")) ]) :-
    ruta_real(D, "../x", _).

:- end_tests(sistema).
