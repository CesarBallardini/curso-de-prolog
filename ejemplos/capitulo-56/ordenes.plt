:- encoding(utf8).

:- begin_tests(ordenes).

% muestra(-D): D es una carpeta temporal nueva con el modelo de ejemplo.
muestra(D) :-
    tmp_file(ordenes, D),
    make_directory(D),
    modelo_ejemplo(M),
    crear_muestra(D, M).

% sesion(+D, +Opciones, +Lineas, -Salida): Salida es lo que escribe el
% programa sobre D al recibir las Lineas.
sesion(D, Opciones, Lineas, Salida) :-
    atomic_list_concat(Lineas, '\n', Texto),
    open_string(Texto, In),
    with_output_to(string(Salida),
                   ( current_output(Out),
                     ordenes(D, Opciones, In, Out) )).

% La sesión de la sección 56.1, línea por línea.
test(sesion, [ setup(muestra(D)),
               cleanup(delete_directory_and_contents(D)) ]) :-
    sesion(D, [eco(true)],
           [ "¿Qué archivos hay?",
             "Copia los archivos .txt de informes a la carpeta respaldo",
             "¿Cuánto ocupan los archivos de respaldo?",
             "Borra los archivos .tmp",
             "s",
             "¿Dónde está notas.txt?",
             "Renombra notas.txt como apuntes.txt",
             "¿Cuándo se modificó apuntes.txt?",
             "Borra ../secreto.txt",
             "Ejecuta hola.pl",
             "Haz una copia de todo",
             "Salir" ],
           Salida),
    split_string(Salida, "\n", "", Obtenidas),
    Esperadas =
    [ "Escribe una orden en castellano; «salir» termina.",
      "> ¿Qué archivos hay?",
      "En la carpeta de trabajo hay 5 elementos: borrador.tmp, hola.pl, informes/, notas.txt, respaldo/.",
      "> Copia los archivos .txt de informes a la carpeta respaldo",
      "informes/acta.txt se copió en respaldo/acta.txt.",
      "informes/notas.txt se copió en respaldo/notas.txt.",
      "> ¿Cuánto ocupan los archivos de respaldo?",
      "Los 2 archivos ocupan 420 bytes.",
      "> Borra los archivos .tmp",
      "¿Quieres borrar borrador.tmp? (s/n) s",
      "borrador.tmp se borró.",
      "> ¿Dónde está notas.txt?",
      "Hay 3 archivos que coinciden con notas.txt: informes/notas.txt, notas.txt, respaldo/notas.txt.",
      "> Renombra notas.txt como apuntes.txt",
      "notas.txt pasó a ser apuntes.txt.",
      "> ¿Cuándo se modificó apuntes.txt?",
      "apuntes.txt se modificó el 2026-09-20.",
      "> Borra ../secreto.txt",
      "../secreto.txt está fuera de la carpeta de trabajo: la orden no se cumple.",
      "> Ejecuta hola.pl",
      "Salida de hola.pl:",
      "  Hola desde hola.pl",
      "> Haz una copia de todo",
      "La orden no se entiende. Prueba, por ejemplo, con «lista los archivos» o «copia notas.txt a respaldo».",
      "> Salir",
      "Hasta luego.",
      "" ],
    assertion(Obtenidas == Esperadas).

test(simulacion, [ setup(muestra(D)),
                   cleanup(delete_directory_and_contents(D)) ]) :-
    sesion(D, [simulacion(true)],
           [ "Mueve los archivos de informes a respaldo",
             "Borra todos los archivos",
             "Ejecuta hola.pl" ],
           Salida),
    split_string(Salida, "\n", "", Lineas),
    Lineas == [ "Escribe una orden en castellano; «salir» termina.",
                "Modo simulación: ningún archivo se modifica.",
                "> informes/acta.txt pasaría a ser respaldo/acta.txt.",
                "informes/notas.txt pasaría a ser respaldo/notas.txt.",
                "informes/resumen.pdf pasaría a ser respaldo/resumen.pdf.",
                "> Se borraría borrador.tmp, después de confirmarlo.",
                "Se borraría hola.pl, después de confirmarlo.",
                "Se borraría notas.txt, después de confirmarlo.",
                "> Se ejecutaría hola.pl.",
                "> ",
                "" ],
    leer_modelo(D, M),
    modelo_ejemplo(M).

test(registro, [ setup(( muestra(D),
                         directory_file_path(D, 'registro.txt', F) )),
                 cleanup(delete_directory_and_contents(D)) ]) :-
    sesion(D, [registro(F)],
           [ "Haz una copia de todo", "lista", "Ordena los archivos" ], _),
    read_file_to_string(F, Registro, []),
    Registro == "Haz una copia de todo\nlista\nOrdena los archivos\n".

test(respuestas, [ setup(muestra(D)),
                   cleanup(delete_directory_and_contents(D)) ]) :-
    sesion(D, [],
           [ "", "¿Cuántos archivos .doc hay en informes?",
             "¿Cuánto ocupa hola.pl?",
             "Lista los archivos de respaldo",
             "Copia los archivos de informes a notas.txt",
             "Copia notas.txt a la carpeta informes",
             "Borra los archivos .doc",
             "Busca los archivos que terminan en .doc",
             "Ejecuta notas.txt" ],
           Salida),
    split_string(Salida, "\n", "", Lineas),
    Lineas == [ "Escribe una orden en castellano; «salir» termina.",
                "> > En la carpeta informes no hay ningún archivo que coincida con *.doc.",
                "> hola.pl ocupa 96 bytes.",
                "> En la carpeta respaldo no hay nada.",
                "> notas.txt no es una carpeta: varios archivos van a una.",
                "> Ya existe informes/notas.txt, y no se sobrescribe.",
                "> Ningún archivo de la carpeta de trabajo coincide con *.doc.",
                "> Ningún archivo coincide con *.doc.",
                "> notas.txt no es un programa: solo se ejecutan archivos .pl.",
                "> ",
                "" ].

test(cantidad, all(T == ["ningún archivo", "ninguna carpeta", "1 byte",
                         "3 elementos", "2 carpetas"])) :-
    member(K-L-G, [0-archivo-m, 0-carpeta-f, 1-byte-m, 3-elemento-m,
                   2-carpeta-f]),
    cantidad(K, L, G, T).

test(coincide, all(V == ["coincida", "coincide", "coinciden"])) :-
    member(K, [0, 1, 3]),
    coincide(K, V).

test(atender_salir, [ setup(muestra(D)),
                      cleanup(delete_directory_and_contents(D)),
                      true(S-T == no-"Hasta luego.\n") ]) :-
    with_output_to(string(T),
                   ( current_output(Out),
                     atender(D, [], user_input, Out, "Salir", S) )).

test(atender_no_entiende, [ setup(muestra(D)),
                            cleanup(delete_directory_and_contents(D)),
                            true(S == si) ]) :-
    with_output_to(string(T),
                   ( current_output(Out),
                     atender(D, [], user_input, Out, "Haz algo", S) )),
    sub_string(T, 0, _, _, "La orden no se entiende.").

test(atender_simulacion, [ setup(muestra(D)),
                           cleanup(delete_directory_and_contents(D)),
                           true(S-Existe == si-true) ]) :-
    with_output_to(string(_),
                   ( current_output(Out),
                     atender(D, [simulacion(true)], user_input, Out,
                             "Renombra notas.txt como apuntes.txt", S) )),
    directory_file_path(D, 'notas.txt', P),
    (   exists_file(P)
    ->  Existe = true
    ;   Existe = false
    ).

:- end_tests(ordenes).
