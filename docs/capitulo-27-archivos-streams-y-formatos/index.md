# Capítulo 27 — Archivos, streams y formatos

Hasta aquí, los datos de cada programa estaban en el propio programa, como
hechos, y los resultados se leían en la terminal. Un programa en uso lee
los datos de archivos que otros escriben, en formatos que otros eligen —CSV,
JSON—, y deja sus resultados en archivos que otros leen.

Este capítulo presenta los streams, la forma en que SWI-Prolog lee y escribe
cualquier cosa: la terminal, un archivo, una cadena. Sobre ellos, la lectura
de términos, de líneas y de archivos completos; una gramática aplicada
directamente a un archivo; los formatos CSV y JSON; los ajustes de un
programa; y los hechos que persisten en un archivo. El proyecto recibe un
módulo nuevo, el único que toca archivos: importa alumnos y materias, guarda
y recupera su estado, y escribe informes en columnas.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- abrir, usar y cerrar un stream, con la codificación explícita y el cierre
  garantizado;
- leer un archivo como términos, como líneas, completo o con una gramática;
- escribir términos que se vuelven a leer, e informes en columnas;
- convertir datos de CSV y de JSON en términos al leerlos, y términos en esos
  formatos al escribirlos;
- dar a un programa ajustes que se leen de un archivo, y hechos que persisten
  en un archivo.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:29 h**.
    Resolver los 6 ejercicios marcados con ★: **1:53 h**.
    Resolver los 15 ejercicios del final: **4:16 h**.

## 27.1 Streams

Un **stream** es un canal por el que pasan caracteres o bytes: hacia afuera
del programa, o hacia adentro. Cada lectura y cada escritura de Prolog usa uno.
Tres existen siempre, con un nombre fijo:

| Alias | Es |
|---|---|
| `user_input` | la entrada de la terminal |
| `user_output` | la salida de la terminal |
| `user_error` | la salida de errores y advertencias |

`write/1`, `format/2` y `nl/0` escriben en la **salida actual**, que al empezar
es `user_output`. Cada uno tiene una versión con un stream como primer
argumento: `write/2`, `format/3`, `nl/1`. `with_output_to/2` cambia la salida
actual mientras se ejecuta un objetivo, y guarda lo escrito, por ejemplo, en
una cadena:

```prolog
?- with_output_to(string(S), (write(hola), nl, print([a, 'B']))), string_length(S, N).
S = "hola\n[a,'B']",
N = 12.
```

La [sección 25.6](../capitulo-25-errores-y-excepciones/index.md#256-setup_call_cleanup3) abrió un archivo con `open/3` y lo cerró con `close/1`;
`open/4` agrega una lista de opciones. `leer_terminos/2` lee todos los
términos de un archivo:

<!-- ejemplo: capitulo-27/archivos.pl predicado: leer_terminos/2 leer_terminos_de/2 consulta: leer_terminos(archivos('hechos.txt'), Terminos). -->
```prolog
%!  leer_terminos(+Archivo, -Terminos:list) is det.
%
%   Terminos son los términos de Archivo, en orden, cada uno terminado en un
%   punto. Archivo puede ser un alias, como archivos('hechos.txt'). El stream
%   se cierra aunque la lectura produzca un error.
leer_terminos(Archivo, Terminos) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    setup_call_cleanup(open(Ruta, read, Stream, [encoding(utf8)]),
                       leer_terminos_de(Stream, Terminos),
                       close(Stream)).

%!  leer_terminos_de(+Stream, -Terminos:list) is det.
%
%   Terminos son los términos que quedan en Stream.
leer_terminos_de(Stream, Terminos) :-
    read_term(Stream, Termino, []),
    (   Termino == end_of_file
    ->  Terminos = []
    ;   Terminos = [Termino|Resto],
        leer_terminos_de(Stream, Resto)
    ).
```

Es la forma de usar un archivo en todo el capítulo: el [Patrón 32](../patrones.md#32-recurso-con-limpieza-garantizada),
del [capítulo 25](../capitulo-25-errores-y-excepciones/index.md#256-setup_call_cleanup3).
`setup_call_cleanup/3` abre el archivo, lo usa y lo cierra, tanto si la
lectura se cumple como si falla o produce un error. Un stream que no se cierra
queda ocupando un recurso del sistema hasta que termina el programa, y en
Windows impide borrar el archivo.

El segundo argumento de `open/4` es el **modo**: `read`, `write` —que borra el
contenido anterior— o `append`, que escribe al final. El cuarto es una lista
de opciones, con la convención de la
[sección 22.8](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#228-libraryoption).
La que no conviene omitir es `encoding(utf8)`. Sin ella, `open/3` usa la
codificación del sistema, que en Linux es UTF-8 y en Windows es la de la
configuración regional: el mismo programa escribe `í` como dos bytes en Linux
y como uno solo en Windows, y un archivo escrito en una máquina se lee mal en
la otra. Todos los ejemplos de este capítulo abren sus archivos con
`encoding(utf8)`.

`leer_terminos/2` recibe el nombre del archivo como un **alias**:
`archivos('hechos.txt')` es el archivo `hechos.txt` del directorio que el
alias `archivos` nombra. `absolute_file_name/3` lo convierte en la ruta
completa; la [sección 27.4](#274-archivos-y-directorios) define el alias.

## 27.2 Leer términos y líneas

`read_term/3` lee el término siguiente del stream, hasta el punto que lo
termina, con la misma sintaxis de un archivo de Prolog. Al llegar al final,
devuelve el átomo `end_of_file`, y `leer_terminos_de/2` se detiene allí. El
archivo `hechos.txt` tiene tres hechos y una regla:

```text
padre(juan, ana).
padre(juan, pedro).
edad(ana, 41).
abuelo(X, Z) :- padre(X, Y), padre(Y, Z).
```

```prolog
?- leer_terminos(archivos('hechos.txt'), T).
T = [padre(juan, ana), padre(juan, pedro), edad(ana, 41), (abuelo(_A, _B):-padre(_A, _C), padre(_C, _B))].
```

Leer un término no lo agrega al programa: la regla es un dato más, un término
con el functor `:-`, y sus variables son variables nuevas, sin los nombres
del archivo. La opción `variable_names(V)` de `read_term/3` devuelve esos
nombres: al leer la regla, `V = ['X'=_A, 'Z'=_B, 'Y'=_C]`. Otras opciones
devuelven la posición del término en el archivo o sus comentarios. Para que
el texto se ejecute, en lugar de leerse como datos, está `consult/1`.

Un archivo que no tiene sintaxis de Prolog se lee por **líneas**, con
`read_line_to_string/2`, de `library(readutil)`, que la [sección 25.6](../capitulo-25-errores-y-excepciones/index.md#256-setup_call_cleanup3) usó
para contar líneas: lee una línea sin el salto del final, o devuelve
`end_of_file`:

<!-- ejemplo: capitulo-27/archivos.pl predicado: contar_lineas/2 contar_lineas_de/3 consulta: contar_lineas(archivos('texto.txt'), N). -->
```prolog
%!  contar_lineas(+Archivo, -N:integer) is det.
%
%   N es la cantidad de líneas de Archivo.
contar_lineas(Archivo, N) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    setup_call_cleanup(open(Ruta, read, Stream, [encoding(utf8)]),
                       contar_lineas_de(Stream, 0, N),
                       close(Stream)).

%!  contar_lineas_de(+Stream, +Hasta:integer, -N:integer) is det.
%
%   N es Hasta más las líneas que quedan en Stream.
contar_lineas_de(Stream, Hasta, N) :-
    read_line_to_string(Stream, Linea),
    (   Linea == end_of_file
    ->  N = Hasta
    ;   Siguiente is Hasta + 1,
        contar_lineas_de(Stream, Siguiente, N)
    ).
```

```prolog
?- contar_lineas(archivos('texto.txt'), N).
N = 4.
```

Cuando el archivo cabe en memoria, `read_file_to_string/3` lo lee completo,
de una vez, y los predicados del [capítulo 11](../capitulo-11-texto/index.md#115-dividir-y-unir) lo dividen. `lineas_no_vacias/2` lo
divide con `split_string/4` y descarta las cadenas vacías:

<!-- ejemplo: capitulo-27/archivos.pl predicado: lineas_no_vacias/2 consulta: lineas_no_vacias(archivos('texto.txt'), L). -->
```prolog
%!  lineas_no_vacias(+Archivo, -Lineas:list(string)) is det.
%
%   Lineas son las líneas de Archivo que no están vacías, leídas del archivo
%   completo de una sola vez.
lineas_no_vacias(Archivo, Lineas) :-
    read_file_to_string(Archivo, Texto, [encoding(utf8)]),
    split_string(Texto, "\n", "\r", Todas),
    exclude(==(""), Todas, Lineas).
```

```prolog
?- lineas_no_vacias(archivos('texto.txt'), L).
L = ["hola mundo", "segunda linea", "tercera"].
```

El segundo argumento de `split_string/4` quita el `\r` del final de cada
línea, si el archivo se escribió en Windows: las líneas de un archivo de texto
terminan con `\n` en Linux y con `\r\n` en Windows, y un programa que lee
archivos de las dos procedencias tiene que aceptar las dos.
`read_line_to_string/2` ya lo hace.

!!! question "Actividad"
    Escribir `nombre('Ana María')` en un archivo con `open/3`, sin opciones,
    y después con `open/4` y `encoding(utf8)`. Leer los bytes de cada archivo
    con `read_file_to_codes(Archivo, Bytes, [type(binary)])`, que da el
    contenido del archivo como una lista de códigos. ¿Con cuántos bytes queda
    la `í` en cada caso? ¿Qué ocurre al leer con `encoding(utf8)`
    el archivo escrito sin la opción?

## 27.3 Escribir

Los predicados de escritura del [capítulo 11](../capitulo-11-texto/index.md#117-escribir-terminos) tienen todos una versión con un
stream: `write/2`, `writeq/2`, `print/2`, `portray_clause/2`, `format/3`. Para
escribir datos que el programa volverá a leer, sirven los que escriben el
término de manera que se lea igual: `writeq/2` seguido de un punto, o
`portray_clause/2`, que agrega el punto y el salto de línea:

<!-- ejemplo: capitulo-27/archivos.pl predicado: escribir_terminos/2 consulta: leer_terminos(archivos('hechos.txt'), Terminos). -->
```prolog
%!  escribir_terminos(+Archivo, +Terminos:list) is det.
%
%   Escribe Terminos en Archivo, uno por línea, en una forma que
%   leer_terminos/2 vuelve a leer. Reemplaza el contenido anterior.
escribir_terminos(Archivo, Terminos) :-
    setup_call_cleanup(open(Archivo, write, Stream, [encoding(utf8)]),
                       forall(member(T, Terminos), portray_clause(Stream, T)),
                       close(Stream)).
```

Con `[nombre('Ana María'), (a :- b ; c), 'hola mundo', "cadena", [1, 2]]`,
el archivo queda así:

```text
nombre('Ana María').
a :-
    (   b
    ;   c
    ).
'hola mundo'.
"cadena".
[1, 2].
```

Cada término vuelve a leerse igual con `leer_terminos/2`: las comillas de
`'Ana María'` y de `'hola mundo'` hacen que se lean como átomos, y las dobles
de `"cadena"`, como una cadena. Con `write/2`, en cambio, el primero
quedaría `nombre(Ana María)`, que no es un término válido.

Para un informe, que lee una persona, las columnas de `format/3` de la
[sección 11.3](../capitulo-11-texto/index.md#113-format2-en-detalle) alinean los datos:

<!-- ejemplo: capitulo-27/formatos.pl predicado: tabla/1 consulta: tabla([101-ana-8.5, 104-diego-8]). -->
```prolog
%!  tabla(+Filas:list) is det.
%
%   Escribe Filas, términos Legajo-Nombre-Promedio, como una tabla con
%   columnas alineadas y un encabezado.
tabla(Filas) :-
    format("~w~t~8|~w~t~20|~t~w~30|~n", ['Legajo', 'Nombre', 'Promedio']),
    forall(member(Legajo-Nombre-Promedio, Filas),
           format("~w~t~8|~w~t~20|~t~2f~30|~n",
                  [Legajo, Nombre, Promedio])).
```

```prolog
?- tabla([101-ana-8.5, 104-diego-8]).
Legajo  Nombre        Promedio
101     ana               8.50
104     diego             8.00
true.
```

`~8|` es una marca de columna en la posición 8, y `~t` indica dónde van los
espacios que faltan para llegar a ella: después del texto en las dos primeras
columnas, que quedan alineadas a la izquierda, y antes en la tercera, que
queda alineada a la derecha, como se alinean los números. El mismo `format/3`
con un stream de archivo escribe el informe en el archivo.

## 27.4 Archivos y directorios

Un programa no debería depender del directorio desde el que se lo ejecuta.
Un **alias de ruta** da un nombre a un directorio: `archivos('hechos.txt')`
es `hechos.txt` dentro del directorio que `file_search_path(archivos, Dir)`
declara. `archivos.pl` lo declara al cargarse, a partir de su propio
directorio:

<!-- ejemplo: capitulo-27/archivos.pl fragmento: :- multifile user:file_search_path/2. .. asserta(user:file_search_path(archivos, Dir)). consulta: leer_terminos(archivos('hechos.txt'), Terminos). -->
```prolog
:- multifile user:file_search_path/2.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, archivos, Dir),
   asserta(user:file_search_path(archivos, Dir)).
```

`prolog_load_context(directory, Aqui)` es el directorio del archivo que se
está cargando. SWI-Prolog define sus propios alias de la misma forma:
`library(csv)` es `csv.pl` en alguno de los directorios del alias `library`.

La biblioteca tiene un predicado para cada operación con archivos y
directorios:

| Predicado | Hace |
|---|---|
| `absolute_file_name/3` | la ruta completa de un nombre o un alias; con `access(read)`, exige que exista y se pueda leer |
| `exists_file/1`, `exists_directory/1` | se cumple si existe |
| `directory_files/2` | los nombres de un directorio, incluidos `.` y `..` |
| `directory_file_path/3` | une un directorio y un nombre, o los separa |
| `file_base_name/2`, `file_directory_name/2` | el nombre y el directorio de una ruta |
| `file_name_extension/3` | separa o une el nombre y la extensión |
| `size_file/2`, `time_file/2` | el tamaño en bytes y la fecha de modificación |
| `delete_file/1`, `rename_file/2` | borra o renombra un archivo |
| `make_directory/1`, `delete_directory/1` | crea o borra un directorio vacío |
| `tmp_file/2` | un nombre de archivo temporal, que no existe todavía |

`archivos_del_directorio/1` usa varios:

<!-- ejemplo: capitulo-27/archivos.pl predicado: archivos_del_directorio/1 consulta: archivos_del_directorio(N). -->
```prolog
%!  archivos_del_directorio(-Nombres:list(atom)) is det.
%
%   Nombres son los archivos del directorio archivos/, en orden alfabético.
archivos_del_directorio(Nombres) :-
    absolute_file_name(archivos('.'), Directorio, [file_type(directory)]),
    directory_files(Directorio, Todos),
    exclude([N]>>sub_atom(N, 0, _, _, '.'), Todos, SinPuntos),
    sort(SinPuntos, Nombres).
```

```prolog
?- archivos_del_directorio(N).
N = ['ajustes.cfg', 'alumnos.csv', 'hechos.txt', 'materias.json', 'texto.txt'].

?- file_name_extension(Base, Ext, 'alumnos.csv').
Base = alumnos,
Ext = csv.
```

Las pruebas que escriben usan `tmp_file/2` en su `setup` y `delete_file/1` en
su `cleanup`: cada prueba escribe en un archivo propio, que no queda después.
Es la prueba `ida_y_vuelta` de `archivos.plt`, que escribe una lista de
términos y verifica que se leen iguales.

Leer un archivo, transformarlo y escribir otro es la forma de muchos
programas. `numerar_lineas/2` copia un archivo con cada línea numerada:

<!-- ejemplo: capitulo-27/archivos.pl predicado: numerar_lineas/2 numerar_desde/3 consulta: contar_lineas(archivos('texto.txt'), N). -->
```prolog
%!  numerar_lineas(+Entrada, +Salida) is det.
%
%   Escribe en Salida las líneas de Entrada, cada una precedida por su
%   número. Los dos streams se cierran aunque se produzca un error.
numerar_lineas(Entrada, Salida) :-
    absolute_file_name(Entrada, Ruta, [access(read)]),
    setup_call_cleanup(
        open(Ruta, read, In, [encoding(utf8)]),
        setup_call_cleanup(
            open(Salida, write, Out, [encoding(utf8)]),
            numerar_desde(In, Out, 1),
            close(Out)),
        close(In)).

%!  numerar_desde(+In, +Out, +N:integer) is det.
%
%   Copia las líneas que quedan en In a Out, numeradas desde N.
numerar_desde(In, Out, N) :-
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  true
    ;   format(Out, "~t~d~3|  ~s~n", [N, Linea]),
        Siguiente is N + 1,
        numerar_desde(In, Out, Siguiente)
    ).
```

Aplicado a `texto.txt`, escribe:

```text
  1  hola mundo
  2  segunda linea
  3
  4  tercera
```

Los dos `setup_call_cleanup/3` están anidados: el de afuera cierra la entrada,
el de adentro la salida, y cada uno se cierra aunque falle el otro.

!!! example "Patrón 36 — Leer, procesar, escribir"
    **Problema.** Un programa transforma un archivo en otro, y tiene que
    cerrar los dos en cualquier caso, sin mezclar la transformación con el
    manejo de los archivos.

    **Versión ingenua.** Abrir los dos archivos, recorrer y escribir en el
    mismo predicado, y cerrarlos al final: un error en el medio los deja
    abiertos.

    **Patrón.** Dos `setup_call_cleanup/3` anidados, uno por archivo, con
    `encoding(utf8)` en los dos. El trabajo va en un predicado aparte que
    recibe los dos streams, y la transformación de cada dato en otro
    predicado, puro, que no usa streams y se prueba sin archivos.

    **Cuándo no usarlo.** Cuando la entrada cabe en memoria y la
    transformación necesita verla completa, como para ordenarla: se lee todo
    con `read_file_to_string/3` o con una lista de términos, se transforma, y
    se escribe todo.

## 27.5 Una gramática sobre un archivo

Las gramáticas del [capítulo 21](../capitulo-21-gramaticas-dcg/index.md) se aplican a una lista de códigos.
`phrase_from_file/3`, de `library(pio)`, las aplica a un archivo, sin leerlo
entero antes: los códigos se leen a medida que la gramática los pide.

<!-- ejemplo: capitulo-27/archivos.pl predicado: palabras_del_archivo/2 palabras//1 consulta: palabras_del_archivo(archivos('texto.txt'), P). -->
```prolog
%!  palabras_del_archivo(+Archivo, -Palabras:list(string)) is det.
%
%   Palabras son las palabras de Archivo, leídas con una gramática sobre el
%   archivo, sin cargarlo entero en memoria.
palabras_del_archivo(Archivo, Palabras) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    phrase_from_file(palabras(Palabras), Ruta, [encoding(utf8)]).

%!  palabras(-Palabras:list(string))// is det.
%
%   Las palabras del texto, separadas por blancos.
palabras([P|Ps]) -->
    blanks,
    nonblanks(Codigos),
    { Codigos \== [] },
    !,
    { string_codes(P, Codigos) },
    palabras(Ps).
palabras([]) -->
    blanks.
```

```prolog
?- palabras_del_archivo(archivos('texto.txt'), P).
P = ["hola", "mundo", "segunda", "linea", "tercera"].
```

`blanks//0` y `nonblanks//1` son de `library(dcg/basics)`, presentada en la
[sección 21.6](../capitulo-21-gramaticas-dcg/index.md#216-librarydcgbasics-y-librarydcghigh_order). La condición `Codigos \== []` evita que la
primera regla acepte una palabra vacía al final del texto, donde
`nonblanks//1` también se cumple. La gramática es la misma que se aplicaría a
una cadena con `phrase/2`, y se prueba así, sin archivos; `phrase_from_file/3`
solo cambia de dónde vienen los códigos.

## 27.6 CSV

Un archivo **CSV** tiene una fila por línea y los valores separados por comas.
`alumnos.csv` tiene los alumnos del proyecto, con una fila de encabezado:

```text
legajo,nombre,carrera,ingreso
101,ana,sistemas,2023
102,bruno,sistemas,2024
103,carla,civil,2023
…
```

`csv_read_file/3`, de `library(csv)`, lee el archivo como una lista de
términos, uno por fila. Por omisión son `row(...)`; con las opciones
`functor(alumno)` y `arity(4)`, son `alumno/4`, la misma forma de los hechos
del proyecto:

<!-- ejemplo: capitulo-27/formatos.pl predicado: alumnos_csv/2 consulta: alumnos_csv(archivos('alumnos.csv'), Alumnos). -->
```prolog
%!  alumnos_csv(+Archivo, -Alumnos:list) is det.
%
%   Alumnos son los términos alumno(Legajo, Nombre, Carrera, Ingreso) de las
%   filas de Archivo, un CSV con una fila de encabezado, que se descarta.
alumnos_csv(Archivo, Alumnos) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    csv_read_file(Ruta, [_Encabezado|Alumnos],
                  [functor(alumno), arity(4), encoding(utf8)]).
```

```prolog
?- alumnos_csv(archivos('alumnos.csv'), [A|_]).
A = alumno(101, ana, sistemas, 2023).
```

Los valores que parecen números se leen como números, y los demás como
átomos. El encabezado también se lee como una fila, `alumno(legajo, nombre,
carrera, ingreso)`, y el patrón `[_Encabezado|Alumnos]` lo descarta. Las
comillas, las comas dentro de un valor y los saltos de línea dentro de
comillas los resuelve la biblioteca, que es la razón para no leer un CSV
dividiendo líneas por comas.

`csv_write_file/3` hace lo inverso: recibe una lista de términos `row(...)` y
escribe una fila por término, con comillas donde hacen falta.
`notas_csv/2`, de `formatos.pl`, convierte cada término `Legajo-Materia-Nota`
en `row(Legajo, Materia, Nota)` y escribe el archivo con un encabezado:

<!-- ejemplo: capitulo-27/formatos.pl predicado: notas_csv/2 fila_nota/2 consulta: alumnos_csv(archivos('alumnos.csv'), Alumnos). -->
```prolog
%!  notas_csv(+Archivo, +Notas:list) is det.
%
%   Escribe en Archivo un CSV con una fila de encabezado y una fila por cada
%   término Legajo-Materia-Nota de Notas.
notas_csv(Archivo, Notas) :-
    maplist(fila_nota, Notas, Filas),
    csv_write_file(Archivo, [row(legajo, materia, nota)|Filas],
                   [encoding(utf8)]).

%!  fila_nota(+Nota, -Fila) is det.
%
%   Fila es la fila de CSV del término Legajo-Materia-Nota.
fila_nota(Legajo-Materia-Nota, row(Legajo, Materia, Nota)).
```

## 27.7 JSON

Un archivo **JSON** tiene objetos entre llaves, listas entre corchetes,
cadenas, números, `true`, `false` y `null`. `materias.json` tiene las
materias del proyecto:

```json
[
  {"codigo": "am1", "nombre": "analisis_1", "anio": 1},
  {"codigo": "alg", "nombre": "algebra", "anio": 1},
  …
  {"codigo": "bd", "nombre": "bases_de_datos", "anio": 3}
]
```

`json_read_dict/3`, de `library(http/json)`, lee un objeto de JSON como un
dict, el término de la [sección 22.7](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#227-dicts); una lista, como una lista; un
número, como un número. Las cadenas se leen como cadenas de Prolog; con la
opción `value_string_as(atom)`, como átomos:

```prolog
?- atom_json_dict('{"a": [1, 2.5, "x", true, null]}', D, []).
D = _{a:[1, 2.5, "x", true, null]}.

?- atom_json_dict('{"a": [1, 2.5, "x", true, null]}', D, [value_string_as(atom)]).
D = _{a:[1, 2.5, x, true, null]}.
```

`atom_json_dict/3` hace lo mismo con un texto en lugar de un stream. Las
materias se leen como dicts y se convierten en `materia/3`:

<!-- ejemplo: capitulo-27/formatos.pl predicado: materias_json/2 objeto_materia/2 consulta: materias_json(archivos('materias.json'), Materias). -->
```prolog
%!  materias_json(+Archivo, -Materias:list) is det.
%
%   Materias son los términos materia(Codigo, Nombre, Anio) de los objetos
%   de Archivo, un JSON con una lista de objetos.
materias_json(Archivo, Materias) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    setup_call_cleanup(open(Ruta, read, Stream, [encoding(utf8)]),
                       json_read_dict(Stream, Objetos,
                                      [value_string_as(atom)]),
                       close(Stream)),
    maplist(objeto_materia, Objetos, Materias).

%!  objeto_materia(+Objeto:dict, -Materia) is det.
%
%   Materia es el término materia/3 con los datos de Objeto.
objeto_materia(Objeto, materia(Codigo, Nombre, Anio)) :-
    _{codigo: Codigo, nombre: Nombre, anio: Anio} :< Objeto.
```

```prolog
?- materias_json(archivos('materias.json'), [M|_]).
M = materia(am1, analisis_1, 1).
```

`:<` es la **unificación parcial** de dicts: se cumple si cada clave del dict
de la izquierda está en el de la derecha y sus valores unifican. Un objeto con
un campo de más, como `"horas": 6`, se lee igual; uno al que le falta
`"anio"` hace fallar `objeto_materia/2`. El ejercicio 9 convierte esa falla en
un error. La escritura es la conversión inversa, con un dict construido en la
cabeza:

<!-- ejemplo: capitulo-27/formatos.pl predicado: materia_objeto/2 materias_a_json/2 consulta: materias_a_json([materia(am1, analisis_1, 1)], T). -->
```prolog
%!  materia_objeto(+Materia, -Objeto:dict) is det.
%
%   Objeto es el dict con los datos del término materia/3 Materia.
materia_objeto(materia(Codigo, Nombre, Anio),
               _{codigo: Codigo, nombre: Nombre, anio: Anio}).

%!  materias_a_json(+Materias:list, -Texto:string) is det.
%
%   Texto es la lista de Materias, términos materia/3, escrita como JSON.
materias_a_json(Materias, Texto) :-
    maplist(materia_objeto, Materias, Objetos),
    atom_json_dict(Texto, Objetos, [as(string), width(0)]).
```

```prolog
?- materias_a_json([materia(am1, analisis_1, 1)], T).
T = "[ {\"anio\":1,\"codigo\":\"am1\",\"nombre\":\"analisis_1\"} ]".
```

Las claves se escriben en orden alfabético, porque un dict las guarda así; en JSON,
el orden de las claves de un objeto no importa.

`alumnos_csv/2` y `materias_json/2` hacen lo mismo con dos formatos
distintos: convierten lo que llega en los términos que usa el resto del
programa, apenas llega. Ningún otro predicado ve una fila de CSV ni un dict de
JSON:

!!! example "Patrón 37 — Convertir en el borde"
    **Problema.** Los datos llegan en un formato ajeno a Prolog —filas de
    CSV, objetos de JSON, cadenas— y el programa los necesita como términos.

    **Versión ingenua.** Pasar los dicts o las filas a los predicados del
    programa, y extraer los campos donde se usan: cada predicado depende del
    formato, y un cambio en el archivo obliga a cambiarlos todos.

    **Patrón.** Un predicado de conversión por formato, en el borde del
    programa, que produce los términos limpios del
    [Patrón 4](../patrones.md#4-datos-limpios) —`alumno/4`, `materia/3`— y
    rechaza lo que no puede convertir. Para escribir, la conversión inversa.
    El núcleo trabaja solo con términos, y se prueba sin archivos.

    **Cuándo no usarlo.** Cuando el programa solo pasa los datos de un lado a
    otro sin examinarlos, como un servicio que reenvía un JSON: convertirlos no
    agrega nada.

!!! question "Actividad"
    Agregar a `materias.json` una materia sin el campo `"anio"`, y ejecutar
    `materias_json/2`. ¿Qué responde? ¿Qué predicado falla, y por qué la
    respuesta no dice cuál de las materias es la incorrecta?

## 27.8 YAML, en una nota

**YAML** es otro formato de datos, frecuente en archivos de configuración.
`library(yaml)` lo lee con `yaml_read/2` y lo escribe con `yaml_write/2`, con
la misma representación que JSON: dicts para los objetos, listas para las
listas. La forma de trabajo es la de JSON: leer, convertir en el borde,
escribir. El ejercicio 10 escribe las materias en YAML.

## 27.9 Ajustes: `library(settings)`

Un **ajuste** es un valor que cambia el comportamiento del programa sin
cambiar su código: la nota mínima para aprobar, un directorio, un límite.
`library(settings)` los declara con un tipo, un valor por omisión y una
descripción:

<!-- ejemplo: capitulo-27/formatos.pl fragmento: :- setting(nota_minima .. 'Nota mínima para aprobar'). consulta: setting(nota_minima, N). -->
```prolog
:- setting(nota_minima, between(1, 10), 6, 'Nota mínima para aprobar').
```

<!-- ejemplo: capitulo-27/formatos.pl predicado: aprueba/1 consulta: aprueba(6). -->
```prolog
%!  aprueba(+Nota:integer) is semidet.
%
%   Nota alcanza la nota mínima, que es un ajuste del programa.
aprueba(Nota) :-
    setting(nota_minima, Minima),
    Nota >= Minima.
```

```prolog
?- setting(nota_minima, N).
N = 6.

?- set_setting(nota_minima, 7), aprueba(6).
false.

?- set_setting(nota_minima, 11).
ERROR: Type error: `between(1,10)' expected, found `11' (an integer)
ERROR: In:
ERROR:   [17] throw(error(type_error(...,11),_190))
```

`set_setting/2` verifica el tipo declarado: un valor fuera de rango es un
error, no un ajuste incorrecto que aparece más tarde. `load_settings/1` lee
los ajustes de un archivo, con un término `setting(Modulo:Nombre, Valor)` por
ajuste, y `save_settings/1` los escribe. `list_settings/0` muestra todos, con
su valor y su descripción. `restore_setting/1` devuelve un ajuste a su valor
por omisión; las pruebas que cambian un ajuste lo llaman en su `cleanup`.
Como los ajustes se declaran en un módulo, desde otro se nombran con el
módulo: el proyecto declara `nota_minima` en `datos`, y su archivo de ajustes
dice `setting(datos:nota_minima, 7)`.

## 27.10 Hechos que se guardan solos: `library(persistency)`

La [sección 20.10](../capitulo-20-base-de-datos-dinamica/index.md#2010-persistir-hechos) guardaba los hechos dinámicos escribiéndolos con
`listing/1`. `library(persistency)` lo automatiza: cada `assert` y cada
`retract` se agrega a un archivo en el momento, y al volver a abrir el
programa los hechos se recuperan.

<!-- ejemplo: capitulo-27/persistencia.pl fragmento: :- persistent .. nota_guardada(legajo:integer, materia:atom, nota:between(1, 10)). consulta: notas(N). -->
```prolog
:- persistent
    nota_guardada(legajo:integer, materia:atom, nota:between(1, 10)).
```

La directiva `persistent/1` declara el predicado con el tipo de cada
argumento, y genera `assert_nota_guardada/3`, `retract_nota_guardada/3` y
`retractall_nota_guardada/3`, que modifican los hechos y registran el cambio.
`db_attach/2` asocia el archivo y carga lo que tenga; `db_detach/0` lo
cierra. `persistencia.pl` los llama desde `abrir_notas/1` y `cerrar_notas/0`:

<!-- ejemplo: capitulo-27/persistencia.pl predicado: registrar/3 notas/1 consulta: notas(N). -->
```prolog
%!  registrar(+Legajo:integer, +Materia:atom, +Nota:integer) is det.
%
%   Guarda la nota del alumno Legajo en Materia, y reemplaza la anterior si
%   había una. Produce un error de tipo si algún argumento no es del tipo
%   declarado.
registrar(Legajo, Materia, Nota) :-
    retractall_nota_guardada(Legajo, Materia, _),
    assert_nota_guardada(Legajo, Materia, Nota).

%!  notas(-Notas:list) is det.
%
%   Notas son los términos Legajo-Materia-Nota guardados, en orden.
notas(Notas) :-
    findall(L-M-N, nota_guardada(L, M, N), Todas),
    sort(Todas, Notas).
```

Después de `registrar(101, am1, 8)`, `registrar(101, am1, 9)` y
`registrar(102, log, 6)`, el archivo tiene el historial de los cambios, no el
estado final:

```text
created(1790307907.304751).
assert(nota_guardada(101,am1,8)).
retractall(nota_guardada(101,am1,_),1).
assert(nota_guardada(101,am1,9)).
assert(nota_guardada(102,log,6)).
```

Al volver a asociarlo, `db_attach/2` repite los cambios en orden, y
`notas(N)` da `[101-am1-9, 102-log-6]`. Registrar un cambio es agregar una
línea al final, rápido aunque la base sea grande; `db_sync(gc)` reescribe el
archivo con solo el estado final, cuando el historial crece demasiado. Los
tipos se verifican al registrar: `registrar(101, am1, 11)` produce un error
de tipo, y el archivo no cambia.

`abrir_notas/1` existe por un detalle de los módulos: `db_attach/2` asocia el
archivo a los predicados persistentes del módulo que la llama, y una prueba se
ejecuta en el módulo de su unidad. Llamada desde `persistencia.pl`, la
asociación es siempre la correcta.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C6 | en el proyecto, un solo módulo, `intercambio`, lee y escribe archivos; los demás no cambian, y siguen probándose sin archivos |
    | C5 | un archivo que falta produce un `existence_error`, no una falla (`archivo_inexistente` en `archivos.plt`); un ajuste o una nota fuera de rango, un error de tipo; un archivo sin estado, un `domain_error` |

## 27.11 El proyecto: el borde con los archivos

*Inscripciones* recibe su sexto módulo, `intercambio`, el único que usa
archivos. Los otros cinco no cambian, salvo `datos`, donde la nota mínima pasa
a ser un ajuste:

<!-- ejemplo: capitulo-27/inscripciones/datos.pl fragmento: :- setting(nota_minima .. setting(nota_minima, N). consulta: nota_minima(N). -->
```prolog
:- setting(nota_minima, between(1, 10), 6,
           'Nota mínima para aprobar una materia').

%!  nota_minima(-N:integer) is det.
%
%   N es la nota mínima para aprobar una materia: el valor del ajuste
%   nota_minima, que un archivo de ajustes puede cambiar.
nota_minima(N) :-
    setting(nota_minima, N).
```

Los demás módulos siguen llamando a `nota_minima/1`, que ahora consulta el
ajuste: la interfaz es la misma, y ninguno de ellos cambia. El módulo
nuevo exporta nueve predicados: `importar_alumnos/2`, `importar_materias/2`,
`alumnos_distintos/2`, `cargar_ajustes/1`, `guardar_estado/1`,
`cargar_estado/1`, `exportar_notas/1`, `escribir_ranking/1` y
`exportar_ranking/1`.

Importar alumnos y materias es lo de las secciones [27.6](#276-csv) y [27.7](#277-json), con los
mismos predicados. Con los datos importados, `alumnos_distintos/2` compara el
CSV con los hechos del programa, y encuentra las filas que no coinciden:

<!-- ejemplo: capitulo-27/inscripciones/intercambio.pl predicado: alumnos_distintos/2 es_alumno/1 consulta: alumnos_distintos(archivos('alumnos.csv'), D). -->
```prolog
%!  alumnos_distintos(+Archivo, -Distintos:list) is det.
%
%   Distintos son los alumnos de Archivo, un CSV, que no coinciden con
%   ningún hecho alumno/4 del programa.
alumnos_distintos(Archivo, Distintos) :-
    importar_alumnos(Archivo, Alumnos),
    exclude(es_alumno, Alumnos, Distintos).

%!  es_alumno(+Alumno) is semidet.
%
%   Alumno, un término alumno/4, coincide con un hecho del programa.
es_alumno(alumno(Legajo, Nombre, Carrera, Ingreso)) :-
    alumno(Legajo, Nombre, Carrera, Ingreso).
```

```prolog
?- alumnos_distintos(archivos('alumnos.csv'), D).
D = [].
```

El estado del programa ya era un término: `estado/1` y `restaurar/1`, del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#2011-el-proyecto-inscribir-y-dar-de-baja), lo usaban para que cada prueba dejara la base como
estaba. Guardarlo en un archivo es escribir ese término, y recuperarlo es
leerlo:

<!-- ejemplo: capitulo-27/inscripciones/intercambio.pl predicado: guardar_estado/1 cargar_estado/1 consulta: escribir_ranking(user_output). -->
```prolog
%!  guardar_estado(+Archivo) is det.
%
%   Escribe en Archivo el estado del programa, las inscripciones, las
%   vacantes y el contador de operaciones, como un solo término.
guardar_estado(Archivo) :-
    estado(Estado),
    setup_call_cleanup(open(Archivo, write, Stream, [encoding(utf8)]),
                       portray_clause(Stream, Estado),
                       close(Stream)).

%!  cargar_estado(+Archivo) is det.
%
%   Reemplaza el estado del programa por el guardado en Archivo con
%   guardar_estado/1.
%
%   @error domain_error(archivo_de_estado, Archivo) si Archivo no tiene un
%          estado guardado.
cargar_estado(Archivo) :-
    setup_call_cleanup(open(Archivo, read, Stream, [encoding(utf8)]),
                       read_term(Stream, Estado, []),
                       close(Stream)),
    (   Estado = estado(_, _, _)
    ->  restaurar(Estado)
    ;   domain_error(archivo_de_estado, Archivo)
    ).
```

`cargar_estado/1` verifica la forma de lo que lee antes de reemplazar el
estado: un archivo que no es un estado guardado produce un error de dominio,
y el estado anterior queda intacto. El informe en columnas es el ranking
del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#2212-el-proyecto-el-ranking-y-un-indice-por-alumno), con los nombres:

<!-- ejemplo: capitulo-27/inscripciones/intercambio.pl predicado: escribir_ranking/1 consulta: escribir_ranking(user_output). -->
```prolog
%!  escribir_ranking(+Stream) is det.
%
%   Escribe en Stream el ranking como una tabla: legajo, nombre y promedio,
%   en columnas alineadas.
escribir_ranking(Stream) :-
    ranking(Ranking),
    format(Stream, "~w~t~8|~w~t~20|~t~w~30|~n",
           ['Legajo', 'Nombre', 'Promedio']),
    forall(member(Legajo-Promedio, Ranking),
           ( alumno(Legajo, Nombre, _, _),
             format(Stream, "~w~t~8|~w~t~20|~t~2f~30|~n",
                    [Legajo, Nombre, Promedio]) )).
```

```prolog
?- escribir_ranking(user_output).
Legajo  Nombre        Promedio
101     ana               8.50
104     diego             8.00
103     carla             6.00
106     facundo           4.50
102     bruno             4.00
true.
```

`escribir_ranking/1` recibe el stream: `user_output` para la terminal, el de
un archivo para `exportar_ranking/1`. La prueba `exportar_ranking` de
`intercambio.plt` verifica que los dos escriben lo mismo. Con los ajustes del
archivo `ajustes.cfg`, la nota mínima es 7:

```prolog
?- cargar_ajustes(archivos('ajustes.cfg')), setting(datos:nota_minima, N).
N = 7.
```

La batería completa, con las once pruebas de `intercambio.plt`, tiene 97
pruebas. Las que escriben usan archivos temporales, y las que cambian el
estado o un ajuste lo restauran en su `cleanup`.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Escribir `contar_terminos/2`, la cantidad de términos de un
   archivo.
2. **(1)** Escribir `agregar_termino/2`, que agrega un término al final de un
   archivo sin borrar lo que tiene.
3. ★ **(2)** Escribir `copiar_en_mayusculas/2`, que copia un archivo de texto
   con cada línea en mayúsculas, con el [Patrón 36](../patrones.md#36-leer-procesar-escribir).
4. **(2)** Escribir `linea_mas_larga/2`: la línea más larga de un archivo.
5. ★ **(2)** Escribir `frecuencias/2`: los pares `Palabra-Cantidad` de las
   palabras de un archivo, de la más frecuente a la menos frecuente.
6. **(1)** Escribir `archivos_con_extension/2`: los archivos del directorio
   `archivos/` con una extensión dada.
7. **(2)** Escribir `numeros_del_archivo/2`, con una gramática y
   `phrase_from_file/3`: los enteros que aparecen en un archivo, en orden.
8. ★ **(2)** Escribir `alumnos_a_csv/2`, la inversa de `alumnos_csv/2`, y una
   prueba que escriba los alumnos y los vuelva a leer.
9. **(2)** Escribir `materias_json_validado/2`, que produce un error de
   dominio con el objeto incorrecto cuando a una materia le falta un campo.
10. **(1)** Escribir las materias de `materias.json` en YAML con
    `yaml_write/2`.
11. **(2)** Declarar un ajuste `ancho`, el ancho de la primera columna de
    `tabla/1`, y escribir la tabla con ese ancho. Cambiarlo y guardarlo con
    `save_settings/1`. ¿Qué contiene el archivo?
12. ★ **(3)** En el proyecto, escribir `guardar_hechos/1` y `cargar_hechos/1`,
    que guardan el estado como hechos, uno por línea —`inscripcion(...)`,
    `vacantes(...)`, `operaciones(...)`—, en lugar de un solo término.
13. **(2)** En el proyecto, escribir `exportar_inscriptos/2`: un CSV con los
    inscriptos en una materia, su nombre y su estado.
14. ★ **(2)** En el proyecto, escribir `importar_notas/1`, que lee un CSV
    `legajo,materia,nota` y registra cada nota, con un error si el alumno o la
    materia no existen.
15. **(3)** En el proyecto, escribir `escribir_materias/1`: una tabla con el
    código, el nombre, el año, la cantidad de inscriptos y el promedio de cada
    materia.

## Resumen

| | |
|---|---|
| `user_input`, `user_output`, `user_error` | los tres streams de la terminal |
| `open/4`, `close/1` | abrir y cerrar un archivo; modos `read`, `write`, `append`; `encoding(utf8)` |
| `with_output_to/2` | la salida de un objetivo, en una cadena |
| `read_term/3` | el término siguiente; `end_of_file` al final; `variable_names/1` |
| `read_line_to_string/2`, `read_file_to_string/3` | una línea, o el archivo completo |
| `portray_clause/2`, `writeq/2`, `format/3` | escribir para volver a leer, y para una persona |
| `file_search_path/2`, `absolute_file_name/3`, `prolog_load_context/2` | alias de rutas; el directorio del archivo que se carga |
| `directory_file_path/3`, `file_directory_name/2`, `file_name_extension/3` | unir y separar directorio, nombre y extensión |
| `tmp_file/2`, `delete_file/1` | un archivo temporal para una prueba, y su borrado |
| `phrase_from_file/3` | una gramática sobre un archivo |
| `csv_read_file/3`, `csv_write_file/3` | CSV como términos |
| `json_read_dict/3`, `atom_json_dict/3`, `:<` | JSON como dicts |
| `yaml_read/2`, `yaml_write/2` | YAML, con la misma representación |
| `setting/4`, `set_setting/2`, `load_settings/1`, `restore_setting/1`, `list_settings/0` | ajustes con tipo y valor por omisión; volver al valor por omisión; listarlos |
| `persistent/1`, `db_attach/2`, `db_detach/0`, `db_sync/1` | hechos que persisten en un archivo |
| `directory_files/2` | los nombres de las entradas de un directorio, incluidos `.` y `..` |
| `read_file_to_codes/3` | el contenido de un archivo como lista de códigos; con `type(binary)`, sus bytes |
| `save_settings/1` | escribe los ajustes en un archivo |
| `string_upper/2` | una cadena en mayúsculas (en las soluciones) |
| **Patrones 36, 37** | leer, procesar, escribir; convertir en el borde |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Argumentos de la línea de comandos: qué archivos leer | [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) |
| Leer del teclado: `user_input` | [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) |
| JSON entre Python y Prolog | [capítulo 29](../capitulo-29-prolog-desde-python/index.md) |
| JSON en las respuestas de un servicio web | [capítulo 30](../capitulo-30-servicios-web-rest/index.md) |
