:- encoding(utf8).

:- begin_tests(archivos).

% La regla se lee con variables nuevas: se compara con =@=, que acepta
% cualquier nombre de variable.
test(leer_terminos,
     true(T =@= [ padre(juan, ana), padre(juan, pedro), edad(ana, 41),
                  (abuelo(X, Z) :- padre(X, Y), padre(Y, Z)) ])) :-
    leer_terminos(archivos('hechos.txt'), T).

% Un texto con tildes se escribe en UTF-8 (í son dos bytes, 195 y 173) y se
% vuelve a leer igual.
test(utf8, [ setup(tmp_file(terminos, F)),
             cleanup(delete_file(F)),
             true(T == [nombre('Ana María')]) ]) :-
    escribir_terminos(F, [nombre('Ana María')]),
    read_file_to_codes(F, Bytes, [type(binary)]),
    once(append(_, [195, 173|_], Bytes)),
    leer_terminos(F, T).

test(archivo_inexistente, error(existence_error(source_sink, _))) :-
    leer_terminos(archivos('no_existe.txt'), _).

% Escribir y volver a leer da los mismos términos, también una regla.
test(ida_y_vuelta, [ setup(tmp_file(terminos, F)),
                     cleanup(delete_file(F)),
                     true(T == Terminos) ]) :-
    Terminos = [edad(ana, 41), (a :- b, c), nombre('Ana')],
    escribir_terminos(F, Terminos),
    leer_terminos(F, T).

test(escribir_reemplaza, [ setup(tmp_file(terminos, F)),
                           cleanup(delete_file(F)),
                           true(T == [b]) ]) :-
    escribir_terminos(F, [a]),
    escribir_terminos(F, [b]),
    leer_terminos(F, T).

test(contar_lineas, true(N == 4)) :-
    contar_lineas(archivos('texto.txt'), N).

test(numerar_lineas, [ setup(tmp_file(salida, F)),
                       cleanup(delete_file(F)),
                       true(L == [ "  1  hola mundo", "  2  segunda linea",
                                   "  3  ", "  4  tercera", "" ]) ]) :-
    numerar_lineas(archivos('texto.txt'), F),
    read_file_to_string(F, S, [encoding(utf8)]),
    split_string(S, "\n", "", L).

test(lineas_no_vacias, true(L == ["hola mundo", "segunda linea", "tercera"])) :-
    lineas_no_vacias(archivos('texto.txt'), L).

test(palabras, true(P == ["hola", "mundo", "segunda", "linea", "tercera"])) :-
    palabras_del_archivo(archivos('texto.txt'), P).

test(archivos_del_directorio,
     true(N == ['ajustes.cfg', 'alumnos.csv', 'hechos.txt', 'materias.json',
                'texto.txt'])) :-
    archivos_del_directorio(N).

:- end_tests(archivos).
