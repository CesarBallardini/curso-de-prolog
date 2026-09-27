:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1.
test(contar_terminos, true(N == 4)) :-
    contar_terminos(archivos('hechos.txt'), N).

% Ejercicio 2: agregar no borra lo anterior.
test(agregar_termino, [ setup(tmp_file(terminos, F)),
                        cleanup(delete_file(F)),
                        true(T == [a(1), b]) ]) :-
    agregar_termino(F, a(1)),
    agregar_termino(F, b),
    leer_terminos(F, T).

% Ejercicio 3.
test(copiar_en_mayusculas,
     [ setup(tmp_file(salida, F)),
       cleanup(delete_file(F)),
       true(S == "HOLA MUNDO\nSEGUNDA LINEA\n\nTERCERA\n") ]) :-
    copiar_en_mayusculas(archivos('texto.txt'), F),
    read_file_to_string(F, S, [encoding(utf8)]).

% Ejercicio 4.
test(linea_mas_larga, true(L == "segunda linea")) :-
    linea_mas_larga(archivos('texto.txt'), L).

% Ejercicio 5: con un archivo donde las palabras se repiten.
test(frecuencias, [ setup(tmp_file(texto, F)),
                    cleanup(delete_file(F)),
                    true(P == ["a"-3, "b"-2, "c"-1]) ]) :-
    setup_call_cleanup(open(F, write, S, [encoding(utf8)]),
                       format(S, "b a c~na b~n  a~n", []),
                       close(S)),
    frecuencias(F, P).

% Ejercicio 6.
test(archivos_con_extension, true(N == ['alumnos.csv'])) :-
    archivos_con_extension(csv, N).

test(sin_archivos_con_extension, true(N == [])) :-
    archivos_con_extension(xml, N).

% Ejercicio 7: legajos y años de ingreso, alternados.
test(numeros_del_archivo, true(Primeros == [101, 2023, 102, 2024])) :-
    numeros_del_archivo(archivos('alumnos.csv'), Numeros),
    length(Numeros, 14),
    length(Primeros, 4),
    append(Primeros, _, Numeros).

% Ejercicio 8: escribir y volver a leer da los mismos alumnos.
test(alumnos_a_csv, [ setup(tmp_file(alumnos, F)),
                      cleanup(delete_file(F)),
                      true(Leidos == Alumnos) ]) :-
    alumnos_csv(archivos('alumnos.csv'), Alumnos),
    alumnos_a_csv(Alumnos, F),
    alumnos_csv(F, Leidos).

% Ejercicio 9.
test(materias_validadas, true(N == 7)) :-
    materias_json_validado(archivos('materias.json'), M),
    length(M, N).

test(materia_sin_anio,
     [ setup(tmp_file(materias, F)),
       cleanup(delete_file(F)),
       error(domain_error(objeto_materia, _{codigo: am1, nombre: x})) ]) :-
    setup_call_cleanup(open(F, write, S, [encoding(utf8)]),
                       write(S, '[{"codigo": "am1", "nombre": "x"}]'),
                       close(S)),
    materias_json_validado(F, _).

% Ejercicio 10.
test(materias_a_yaml, true(Primeras == ["- anio: 1", "  codigo: am1",
                                        "  nombre: analisis_1"])) :-
    materias_a_yaml(archivos('materias.json'), Texto),
    split_string(Texto, "\n", "", [A, B, C|_]),
    Primeras = [A, B, C].

% Ejercicio 11.
test(tabla_ajustable, [ setup(set_setting(user:ancho, 10)),
                        cleanup(restore_setting(user:ancho)),
                        true(S == "Legajo    Nombre        Promedio\n\c
                                   101       ana               8.50\n") ]) :-
    with_output_to(string(S), tabla_ajustable([101-ana-8.5])).

test(ajuste_guardado, [ setup(( set_setting(user:ancho, 10),
                                tmp_file(ajustes, F) )),
                        cleanup(( restore_setting(user:ancho),
                                  delete_file(F) )),
                        true(T == [setting(user:ancho, 10)]) ]) :-
    save_settings(F),
    leer_terminos(F, T).

:- end_tests(soluciones).
