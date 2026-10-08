:- encoding(utf8).

% Capítulo 27 - Soluciones de los ejercicios 1 a 11 y 16.
%
% Usan los predicados de archivos.pl y de formatos.pl, que este archivo
% carga, y los archivos de ejemplo del directorio archivos/.
%
% solo-local: el sandbox de SWISH no permite leer ni escribir archivos.
%
%?- contar_terminos(archivos('hechos.txt'), N).
%?- numeros_del_archivo(archivos('alumnos.csv'), Numeros).

:- ensure_loaded(archivos).
:- ensure_loaded(formatos).
:- use_module(library(yaml)).
:- use_module(library(persistency)).

% --- Ejercicio 1 ------------------------------------------------------------

%!  contar_terminos(+Archivo, -N:integer) is det.
%
%   N es la cantidad de términos de Archivo.
contar_terminos(Archivo, N) :-
    leer_terminos(Archivo, Terminos),
    length(Terminos, N).

% --- Ejercicio 2 ------------------------------------------------------------

%!  agregar_termino(+Archivo, +Termino) is det.
%
%   Agrega Termino al final de Archivo, que se crea si no existe, sin borrar
%   lo que tiene.
agregar_termino(Archivo, Termino) :-
    setup_call_cleanup(open(Archivo, append, Stream, [encoding(utf8)]),
                       portray_clause(Stream, Termino),
                       close(Stream)).

% --- Ejercicio 3 ------------------------------------------------------------

%!  copiar_en_mayusculas(+Entrada, +Salida) is det.
%
%   Escribe en Salida las líneas de Entrada en mayúsculas.
copiar_en_mayusculas(Entrada, Salida) :-
    absolute_file_name(Entrada, Ruta, [access(read)]),
    setup_call_cleanup(
        open(Ruta, read, In, [encoding(utf8)]),
        setup_call_cleanup(
            open(Salida, write, Out, [encoding(utf8)]),
            copiar_lineas(In, Out),
            close(Out)),
        close(In)).

%!  copiar_lineas(+In, +Out) is det.
%
%   Copia en Out las líneas que quedan en In, cada una en mayúsculas.
copiar_lineas(In, Out) :-
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  true
    ;   string_upper(Linea, Mayusculas),
        format(Out, "~s~n", [Mayusculas]),
        copiar_lineas(In, Out)
    ).

% --- Ejercicio 4 ------------------------------------------------------------

%!  linea_mas_larga(+Archivo, -Linea:string) is det.
%
%   Linea es la línea más larga de Archivo; si hay varias del mismo largo,
%   la primera.
linea_mas_larga(Archivo, Linea) :-
    read_file_to_string(Archivo, Texto, [encoding(utf8)]),
    split_string(Texto, "\n", "\r", Lineas),
    map_list_to_pairs(string_length, Lineas, Pares),
    sort(1, @>=, Pares, [_-Linea|_]).

% --- Ejercicio 5 ------------------------------------------------------------

%!  frecuencias(+Archivo, -Pares:list(pair)) is det.
%
%   Pares son los pares Palabra-Cantidad de las palabras de Archivo, de la
%   más frecuente a la menos frecuente; con la misma cantidad, en orden
%   alfabético.
frecuencias(Archivo, Pares) :-
    palabras_del_archivo(Archivo, Palabras),
    msort(Palabras, Ordenadas),
    clumped(Ordenadas, Contadas),
    sort(2, @>=, Contadas, Pares).

% --- Ejercicio 6 ------------------------------------------------------------

%!  archivos_con_extension(+Extension:atom, -Nombres:list(atom)) is det.
%
%   Nombres son los archivos del directorio archivos/ con esa Extension.
archivos_con_extension(Extension, Nombres) :-
    archivos_del_directorio(Todos),
    include(tiene_extension(Extension), Todos, Nombres).

%!  tiene_extension(+Extension:atom, +Nombre:atom) is semidet.
%
%   Nombre termina con la Extension.
tiene_extension(Extension, Nombre) :-
    file_name_extension(_, Extension, Nombre).

% --- Ejercicio 7 ------------------------------------------------------------

%!  numeros_del_archivo(+Archivo, -Numeros:list(integer)) is det.
%
%   Numeros son los enteros sin signo que aparecen en Archivo, en orden.
numeros_del_archivo(Archivo, Numeros) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    phrase_from_file(numeros(Numeros), Ruta, [encoding(utf8)]).

%!  numeros(-Numeros:list(integer))// is det.
%
%   Los enteros del texto; lo que no es un dígito los separa.
numeros(Numeros) -->
    string_without(`0123456789`, _),
    numeros_(Numeros).

%!  numeros_(-Numeros:list(integer))// is det.
%
%   Los enteros del texto, que empieza con un dígito o está vacío.
numeros_([N|Ns]) -->
    digits([D|Ds]),
    !,
    { number_codes(N, [D|Ds]) },
    numeros(Ns).
numeros_([]) -->
    [].

% --- Ejercicio 8 ------------------------------------------------------------

%!  alumnos_a_csv(+Alumnos:list, +Archivo) is det.
%
%   Escribe en Archivo un CSV con una fila de encabezado y una fila por cada
%   término alumno/4 de Alumnos: lo que alumnos_csv/2 vuelve a leer.
alumnos_a_csv(Alumnos, Archivo) :-
    maplist(fila_alumno, Alumnos, Filas),
    csv_write_file(Archivo, [row(legajo, nombre, carrera, ingreso)|Filas],
                   [encoding(utf8)]).

%!  fila_alumno(?Alumno, ?Fila) is det.
%
%   Fila es la fila de CSV del término alumno/4 Alumno.
fila_alumno(alumno(L, N, C, I), row(L, N, C, I)).

% --- Ejercicio 9 ------------------------------------------------------------

%!  materias_json_validado(+Archivo, -Materias:list) is det.
%
%   Como materias_json/2, pero un objeto al que le falta un campo produce un
%   error, en lugar de hacer fallar la lectura completa.
%
%   @error domain_error(objeto_materia, Objeto) con el objeto incorrecto.
materias_json_validado(Archivo, Materias) :-
    read_file_to_string(Archivo, Texto, [encoding(utf8)]),
    atom_json_dict(Texto, Objetos, [value_string_as(atom)]),
    maplist(objeto_materia_validado, Objetos, Materias).

%!  objeto_materia_validado(+Objeto:dict, -Materia) is det.
%
%   Materia es el término materia/3 de Objeto.
%
%   @error domain_error(objeto_materia, Objeto) si a Objeto le falta un
%          campo.
objeto_materia_validado(Objeto, Materia) :-
    (   objeto_materia(Objeto, Materia)
    ->  true
    ;   domain_error(objeto_materia, Objeto)
    ).

% --- Ejercicio 10 -----------------------------------------------------------

%!  materias_a_yaml(+ArchivoJson, -Texto:string) is det.
%
%   Texto son las materias de ArchivoJson escritas en YAML.
materias_a_yaml(ArchivoJson, Texto) :-
    materias_json(ArchivoJson, Materias),
    maplist(materia_objeto, Materias, Objetos),
    with_output_to(string(Texto), yaml_write(current_output, Objetos)).

% --- Ejercicio 11 -----------------------------------------------------------

:- setting(ancho, between(4, 40), 8,
           'Ancho de la primera columna de tabla_ajustable/1').

%!  tabla_ajustable(+Filas:list) is det.
%
%   Como tabla/1, con la primera columna del ancho que dice el ajuste ancho.
tabla_ajustable(Filas) :-
    setting(ancho, A),
    B is A + 12,
    C is B + 10,
    format("~w~t~*|~w~t~*|~t~w~*|~n",
           ['Legajo', A, 'Nombre', B, 'Promedio', C]),
    forall(member(Legajo-Nombre-Promedio, Filas),
           format("~w~t~*|~w~t~*|~t~2f~*|~n",
                  [Legajo, A, Nombre, B, Promedio, C])).

% --- Ejercicio 16 -----------------------------------------------------------

:- persistent
    asistencia(legajo:integer, fecha:atom).

%!  abrir_asistencias(+Archivo) is det.
%
%   Asocia Archivo a las asistencias: carga las que tiene, y los cambios
%   siguientes se le agregan. Se llama desde aquí por el mismo detalle de
%   módulos que abrir_notas/1, de persistencia.pl.
abrir_asistencias(Archivo) :-
    db_attach(Archivo, []).

%!  cerrar_asistencias is det.
%
%   Cierra el archivo asociado y olvida las asistencias cargadas.
cerrar_asistencias :-
    db_detach.

%!  marcar_asistencia(+Legajo:integer, +Fecha:atom) is det.
%
%   Registra que el alumno Legajo asistió en Fecha. Una asistencia ya
%   registrada no se repite.
marcar_asistencia(Legajo, Fecha) :-
    (   asistencia(Legajo, Fecha)
    ->  true
    ;   assert_asistencia(Legajo, Fecha)
    ).

%!  asistencias_de(+Legajo:integer, -Fechas:list(atom)) is det.
%
%   Fechas son las fechas en que asistió el alumno Legajo, ordenadas.
asistencias_de(Legajo, Fechas) :-
    findall(Fecha, asistencia(Legajo, Fecha), Todas),
    sort(Todas, Fechas).
