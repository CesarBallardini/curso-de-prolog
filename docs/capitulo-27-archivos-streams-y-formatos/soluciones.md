# Soluciones del capítulo 27 — Archivos, streams y formatos

El código de esta página está en `ejemplos/capitulo-27/soluciones.pl` y
`soluciones_proyecto.pl`, con sus archivos de pruebas, y pasa sus pruebas. Las
pruebas que escriben usan archivos temporales, y las que cambian el estado del
proyecto lo restauran.

## 1

<!-- ejemplo: capitulo-27/soluciones.pl predicado: contar_terminos/2 consulta: contar_terminos(archivos('hechos.txt'), N). -->
```prolog
%!  contar_terminos(+Archivo, -N:integer) is det.
%
%   N es la cantidad de términos de Archivo.
contar_terminos(Archivo, N) :-
    leer_terminos(Archivo, Terminos),
    length(Terminos, N).
```

```prolog
?- contar_terminos(archivos('hechos.txt'), N).
N = 4.
```

La regla de `hechos.txt` es un término más, con el functor `:-`.

## 2

<!-- ejemplo: capitulo-27/soluciones.pl predicado: agregar_termino/2 consulta: contar_terminos(archivos('hechos.txt'), N). -->
```prolog
%!  agregar_termino(+Archivo, +Termino) is det.
%
%   Agrega Termino al final de Archivo, que se crea si no existe, sin borrar
%   lo que tiene.
agregar_termino(Archivo, Termino) :-
    setup_call_cleanup(open(Archivo, append, Stream, [encoding(utf8)]),
                       portray_clause(Stream, Termino),
                       close(Stream)).
```

El modo `append` escribe al final y crea el archivo si no existe. Con `write`,
cada llamada borraría lo que dejó la anterior.

## 3

<!-- ejemplo: capitulo-27/soluciones.pl predicado: copiar_en_mayusculas/2 copiar_lineas/2 consulta: contar_terminos(archivos('hechos.txt'), N). -->
```prolog
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
```

Es el [Patrón 36](../patrones.md#36-leer-procesar-escribir): dos `setup_call_cleanup/3` anidados, el recorrido de las
líneas en `copiar_lineas/2`, y la transformación en `string_upper/2`, que no
usa streams. Aplicado a `texto.txt`, escribe:

```text
HOLA MUNDO
SEGUNDA LINEA

TERCERA
```

## 4

<!-- ejemplo: capitulo-27/soluciones.pl predicado: linea_mas_larga/2 consulta: linea_mas_larga(archivos('texto.txt'), L). -->
```prolog
%!  linea_mas_larga(+Archivo, -Linea:string) is det.
%
%   Linea es la línea más larga de Archivo; si hay varias del mismo largo,
%   la primera.
linea_mas_larga(Archivo, Linea) :-
    read_file_to_string(Archivo, Texto, [encoding(utf8)]),
    split_string(Texto, "\n", "\r", Lineas),
    map_list_to_pairs(string_length, Lineas, Pares),
    sort(1, @>=, Pares, [_-Linea|_]).
```

```prolog
?- linea_mas_larga(archivos('texto.txt'), L).
L = "segunda linea".
```

`map_list_to_pairs/3` arma los pares `Largo-Linea`, y `sort/4` con `@>=` los
ordena de mayor a menor sin quitar repetidos. El orden es estable: entre dos
líneas del mismo largo, queda primero la que estaba primero en el archivo.

## 5

<!-- ejemplo: capitulo-27/soluciones.pl predicado: frecuencias/2 consulta: frecuencias(archivos('texto.txt'), P). -->
```prolog
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
```

`msort/2` ordena las palabras sin quitar las repetidas, y `clumped/2` agrupa
las iguales, que quedaron juntas, en pares `Palabra-Cantidad`. Como el orden
de `sort/4` es estable, las palabras con la misma cantidad quedan en orden
alfabético. En `texto.txt` cada palabra aparece una vez; con un archivo que
dice `b a c`, `a b` y `a`, el resultado es `["a"-3, "b"-2, "c"-1]`.

## 6

<!-- ejemplo: capitulo-27/soluciones.pl predicado: archivos_con_extension/2 tiene_extension/2 consulta: archivos_con_extension(csv, N). -->
```prolog
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
```

```prolog
?- archivos_con_extension(csv, N).
N = ['alumnos.csv'].
```

## 7

<!-- ejemplo: capitulo-27/soluciones.pl predicado: numeros_del_archivo/2 numeros//1 numeros_//1 consulta: numeros_del_archivo(archivos('alumnos.csv'), Numeros). -->
```prolog
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
```

```prolog
?- numeros_del_archivo(archivos('alumnos.csv'), Ns).
Ns = [101, 2023, 102, 2024, 103, 2023, 104, 2024, 105|...].
```

`string_without//2`, de `library(dcg/basics)`, consume lo que no es un
dígito; `numeros_//1` empieza siempre en un dígito o al final del texto. Un
signo menos no forma parte del número: `-3` se lee como 3, y `2.5` como 2 y 5.

## 8

<!-- ejemplo: capitulo-27/soluciones.pl predicado: alumnos_a_csv/2 fila_alumno/2 consulta: numeros_del_archivo(archivos('alumnos.csv'), Numeros). -->
```prolog
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
```

```prolog
test(alumnos_a_csv, [ setup(tmp_file(alumnos, F)),
                      cleanup(delete_file(F)),
                      true(Leidos == Alumnos) ]) :-
    alumnos_csv(archivos('alumnos.csv'), Alumnos),
    alumnos_a_csv(Alumnos, F),
    alumnos_csv(F, Leidos).
```

Es el [Patrón 37](../patrones.md#37-convertir-en-el-borde) en las dos direcciones: `fila_alumno/2` convierte entre el
término del programa y la fila de CSV. La prueba de ida y vuelta verifica que
las dos conversiones son inversas.

## 9

<!-- ejemplo: capitulo-27/soluciones.pl predicado: materias_json_validado/2 objeto_materia_validado/2 consulta: numeros_del_archivo(archivos('alumnos.csv'), Numeros). -->
```prolog
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
```

Con un archivo que dice `[{"codigo": "am1", "nombre": "x"}]`, el error nombra
el objeto incorrecto:

```text
error(domain_error(objeto_materia, _{codigo:am1, nombre:x}), _)
```

`materias_json/2` fallaba con el mismo archivo, sin decir por qué: es la
diferencia entre una falla y un error del [capítulo 25](../capitulo-25-errores-y-excepciones/index.md#255-fallo-o-error).
`read_file_to_string/3` y `atom_json_dict/3` reemplazan aquí al stream: con un
archivo pequeño, leerlo entero es más simple.

## 10

<!-- ejemplo: capitulo-27/soluciones.pl predicado: materias_a_yaml/2 consulta: numeros_del_archivo(archivos('alumnos.csv'), Numeros). -->
```prolog
%!  materias_a_yaml(+ArchivoJson, -Texto:string) is det.
%
%   Texto son las materias de ArchivoJson escritas en YAML.
materias_a_yaml(ArchivoJson, Texto) :-
    materias_json(ArchivoJson, Materias),
    maplist(materia_objeto, Materias, Objetos),
    with_output_to(string(Texto), yaml_write(current_output, Objetos)).
```

El texto empieza así:

```text
- anio: 1
  codigo: am1
  nombre: analisis_1
- anio: 1
  codigo: alg
  nombre: algebra
```

La conversión de `materia/3` a dict es la misma de JSON, `materia_objeto/2`:
solo cambia el predicado que escribe.

## 11

<!-- ejemplo: capitulo-27/soluciones.pl fragmento: :- setting(ancho .. [Legajo, A, Nombre, B, Promedio, C])). consulta: numeros_del_archivo(archivos('alumnos.csv'), Numeros). -->
```prolog
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
```

`~*|` toma la posición de la columna de la lista de argumentos, en lugar de
tenerla escrita en el formato. Después de `set_setting(ancho, 10)`,
`save_settings/1` escribe:

<!-- markdownlint-disable MD010 MD012 -->
```text
/*  Saved settings
    Date: Fri Sep 25 00:59:56 2026
*/


%	Ancho de la primera columna de tabla_ajustable/1
setting(user:ancho, 10).
```
<!-- markdownlint-enable MD010 MD012 -->

Solo se guardan los ajustes que cambiaron, con su descripción como
comentario. El archivo es un archivo de términos: `load_settings/1` lo lee, y
`leer_terminos/2` también.

## 12

<!-- ejemplo: capitulo-27/soluciones_proyecto.pl predicado: guardar_hechos/1 cargar_hechos/1 leer_hechos/2 es_inscripcion/1 es_vacantes/1 consulta: escribir_materias(user_output). -->
```prolog
%!  guardar_hechos(+Archivo) is det.
%
%   Escribe en Archivo el estado del programa como hechos, uno por línea:
%   las inscripciones, las vacantes y el contador de operaciones.
guardar_hechos(Archivo) :-
    estado(estado(Inscripciones, Vacantes, Operaciones)),
    append(Inscripciones, Vacantes, Hechos0),
    append(Hechos0, [operaciones(Operaciones)], Hechos),
    setup_call_cleanup(open(Archivo, write, Stream, [encoding(utf8)]),
                       forall(member(H, Hechos), portray_clause(Stream, H)),
                       close(Stream)).

%!  cargar_hechos(+Archivo) is det.
%
%   Reemplaza el estado del programa por los hechos de Archivo, escrito con
%   guardar_hechos/1.
%
%   @error domain_error(archivo_de_hechos, Archivo) si Archivo tiene otros
%          términos, o no tiene exactamente un contador de operaciones.
cargar_hechos(Archivo) :-
    setup_call_cleanup(open(Archivo, read, Stream, [encoding(utf8)]),
                       leer_hechos(Stream, Hechos),
                       close(Stream)),
    partition(es_inscripcion, Hechos, Inscripciones, Resto),
    partition(es_vacantes, Resto, Vacantes, Otros),
    (   Otros = [operaciones(N)]
    ->  restaurar(estado(Inscripciones, Vacantes, N))
    ;   domain_error(archivo_de_hechos, Archivo)
    ).

%!  leer_hechos(+Stream, -Hechos:list) is det.
%
%   Hechos son los términos que quedan en Stream.
leer_hechos(Stream, Hechos) :-
    read_term(Stream, Hecho, []),
    (   Hecho == end_of_file
    ->  Hechos = []
    ;   Hechos = [Hecho|Resto],
        leer_hechos(Stream, Resto)
    ).

%!  es_inscripcion(+Termino) is semidet.
%
%   Termino es un hecho inscripcion/3.
es_inscripcion(inscripcion(_, _, _)).

%!  es_vacantes(+Termino) is semidet.
%
%   Termino es un hecho vacantes/2.
es_vacantes(vacantes(_, _)).
```

El archivo tiene la forma de un archivo de hechos de Prolog, una línea por
hecho:

```text
inscripcion(101, am1, nota(8)).
inscripcion(101, alg, nota(9)).
…
vacantes(bd, 15).
operaciones(0).
```

A diferencia del término único de `guardar_estado/1`, se lee y se compara con
otras versiones línea por línea, y se puede corregir a mano. A cambio,
cargarlo exige clasificar los hechos: `partition/4` separa las inscripciones
y las vacantes, y lo que queda tiene que ser exactamente un contador. Un
archivo con otros términos produce un error, y el estado no cambia.

## 13

<!-- ejemplo: capitulo-27/soluciones_proyecto.pl predicado: exportar_inscriptos/2 valor_de_estado/2 consulta: escribir_materias(user_output). -->
```prolog
%!  exportar_inscriptos(+Materia:atom, +Archivo) is det.
%
%   Escribe en Archivo un CSV con los inscriptos en Materia, en orden de
%   legajo: legajo, nombre y estado, que es la nota o cursando.
exportar_inscriptos(Materia, Archivo) :-
    findall(row(Legajo, Nombre, Valor),
            ( inscripcion(Legajo, Materia, Estado),
              alumno(Legajo, Nombre, _, _),
              valor_de_estado(Estado, Valor) ),
            Filas0),
    sort(Filas0, Filas),
    csv_write_file(Archivo, [row(legajo, nombre, estado)|Filas],
                   [encoding(utf8)]).

%!  valor_de_estado(+Estado, -Valor) is det.
%
%   Valor es lo que se escribe en el CSV para Estado: la nota, o cursando.
valor_de_estado(nota(N), N).
valor_de_estado(cursando, cursando).
```

Para `am1`, el archivo dice:

```text
legajo,nombre,estado
101,ana,8
102,bruno,4
103,carla,7
105,elena,cursando
106,facundo,6
```

`valor_de_estado/2` convierte el término `nota(8)` en el valor que va en la
columna: un CSV no tiene términos compuestos.

## 14

<!-- ejemplo: capitulo-27/soluciones_proyecto.pl predicado: importar_notas/1 validar_fila/1 registrar_fila/1 consulta: escribir_materias(user_output). -->
```prolog
%!  importar_notas(+Archivo) is det.
%
%   Registra las notas de Archivo, un CSV legajo, materia, nota con una fila
%   de encabezado: cada nota reemplaza la inscripción que el alumno tenía en
%   la materia. Valida todas las filas antes de registrar la primera: si una
%   es incorrecta, no se registra ninguna.
%
%   @error existence_error(alumno, Legajo) o existence_error(materia,
%          Materia) si no existen.
%   @error type_error(between(1, 10), Nota) si la nota no es válida.
importar_notas(Archivo) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    csv_read_file(Ruta, [_Encabezado|Filas], [encoding(utf8)]),
    maplist(validar_fila, Filas),
    maplist(registrar_fila, Filas).

%!  validar_fila(+Fila) is det.
%
%   Fila, row(Legajo, Materia, Nota), tiene un alumno y una materia que
%   existen y una nota válida.
validar_fila(row(Legajo, Materia, Nota)) :-
    (   alumno(Legajo, _, _, _)
    ->  true
    ;   existence_error(alumno, Legajo)
    ),
    (   materia(Materia, _, _)
    ->  true
    ;   existence_error(materia, Materia)
    ),
    must_be(between(1, 10), Nota).

%!  registrar_fila(+Fila) is det.
%
%   Registra la nota de Fila, row(Legajo, Materia, Nota), en lugar de la
%   inscripción anterior del alumno en la materia, si tenía una.
registrar_fila(row(Legajo, Materia, Nota)) :-
    ignore(quitar_inscripcion(Legajo, Materia, _)),
    agregar_inscripcion(Legajo, Materia, nota(Nota)).
```

La validación recorre todas las filas antes de registrar la primera: un
archivo con un error no deja la mitad de sus notas registradas. La prueba
`alumno_inexistente` lo verifica con un archivo cuya primera fila es correcta
y la segunda no: el estado después del error es el de antes.

## 15

<!-- ejemplo: capitulo-27/soluciones_proyecto.pl predicado: escribir_materias/1 promedio_texto/2 consulta: escribir_materias(user_output). -->
```prolog
%!  escribir_materias(+Stream) is det.
%
%   Escribe en Stream una tabla con cada materia: código, nombre, año,
%   cantidad de inscriptos y promedio de sus notas, o un guion si no tiene
%   ninguna.
escribir_materias(Stream) :-
    format(Stream, "~w~t~8|~w~t~24|~w~t~30|~t~w~42|~t~w~52|~n",
           ['Código', 'Nombre', 'Año', 'Inscriptos', 'Promedio']),
    forall(materia(Codigo, Nombre, Anio),
           ( inscriptos(Codigo, Legajos),
             length(Legajos, Cantidad),
             promedio_texto(Codigo, Promedio),
             format(Stream, "~w~t~8|~w~t~24|~w~t~30|~t~d~42|~t~w~52|~n",
                    [Codigo, Nombre, Anio, Cantidad, Promedio]) )).

%!  promedio_texto(+Materia:atom, -Texto:atom) is det.
%
%   Texto es el promedio de Materia con dos decimales, o un guion si la
%   materia no tiene notas.
promedio_texto(Materia, Texto) :-
    (   promedio_de_materia(Materia, Promedio)
    ->  format(atom(Texto), "~2f", [Promedio])
    ;   Texto = '-'
    ).
```

```text
Código  Nombre          Año     Inscriptos  Promedio
am1     analisis_1      1                5      6.25
alg     algebra         1                4      5.75
log     logica          1                4      7.00
am2     analisis_2      2                2      7.00
pp      paradigmas      2                2      8.00
ssl     sintaxis        2                0         -
bd      bases_de_datos  3                0         -
```

`promedio_de_materia/2` falla con una materia sin notas; `promedio_texto/2`
convierte esa falla en un guion. Los números van alineados a la derecha, con
`~t` antes del valor.
