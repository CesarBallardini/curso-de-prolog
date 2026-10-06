# Capítulo 28 — Programas de línea de comandos

Todos los programas del curso se usaron desde el toplevel: se cargan, se
consultan, y la sesión sigue abierta. Una herramienta se usa de otra forma: se
ejecuta desde la terminal con sus argumentos, hace su trabajo y termina, y
quien la ejecutó —una persona, otro programa, un script— sabe por el código de
salida si terminó bien.

Este capítulo convierte un programa de Prolog en esa herramienta: un programa
que empieza y termina, que lee opciones y argumentos, que escribe mensajes para
el usuario y termina con un código de salida. Agrega lo que una herramienta
suele necesitar —leer del teclado, ejecutar otros programas, trabajar con
fechas— y las diferencias entre Windows y Linux que hay que tener en cuenta. El
proyecto se ejecuta desde la terminal, con una orden o con un bucle que lee
órdenes del teclado.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- escribir un programa que se ejecuta con `swipl programa.pl argumentos` y
  termina con un código de salida;
- declarar las opciones de un programa, con su tipo y su ayuda;
- escribir mensajes de error, advertencias e información, separados de la
  salida;
- leer y validar respuestas del teclado;
- ejecutar otro programa y leer su salida;
- calcular con fechas, y escribir un programa que funciona igual en Windows y
  en Linux.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:22 h**.
    Resolver los 6 ejercicios marcados con ★: **1:53 h**.
    Resolver los 14 ejercicios del final: **3:53 h**.

## 28.1 Un programa que empieza y termina

`contar.pl` cuenta las líneas y las palabras de los archivos que recibe, como
el programa `wc` de Unix:

```text
$ swipl contar.pl archivos/texto.txt archivos/otro.txt
       4       5  archivos/texto.txt
       2       4  archivos/otro.txt
```

Tres líneas lo convierten en un programa de línea de comandos:

<!-- ejemplo: capitulo-28/contar.pl fragmento: :- use_module(library(main)). .. :- initialization(main, main). consulta: contar_texto("uno dos\ntres\n", Lineas, Palabras). -->
```prolog
:- use_module(library(main)).
:- use_module(library(readutil)).

:- initialization(main, main).
```

La directiva `initialization(main, main)` dice que, al ejecutar el archivo con
`swipl contar.pl …`, después de cargarlo se llama a `main/0`, **en lugar del
toplevel**, y el proceso termina cuando `main/0` termina. `library(main)`
define `main/0`: toma los argumentos que siguen al nombre del archivo y llama a
`main/1` con la lista. El programa define `main/1`:

<!-- ejemplo: capitulo-28/contar.pl predicado: main/1 codigo_de_error/2 consulta: contar_texto("uno dos\ntres\n", Lineas, Palabras). -->
```prolog
%!  main(+Argv:list) is det.
%
%   El programa: cuenta cada archivo de Argv y termina con el código 0; con
%   1 si no recibe ningún archivo; con 2 si se produce otro error, como un
%   archivo que no existe. Cada error se escribe como un mensaje.
main(Argv) :-
    argv_options(Argv, Archivos, Opciones),
    catch(( contar_archivos(Archivos, Opciones),
            Codigo = 0 ),
          Error,
          ( print_message(error, Error),
            codigo_de_error(Error, Codigo) )),
    halt(Codigo).

%!  codigo_de_error(+Error, -Codigo:integer) is det.
%
%   Codigo es el código de salida del programa para Error: 1 para un error
%   de uso, 2 para cualquier otro.
codigo_de_error(uso(_), 1) :-
    !.
codigo_de_error(_, 2).
```

`main/1` es la única parte del programa que depende de la línea de
comandos: lee los argumentos, llama al resto, convierte los errores en
mensajes y termina con `halt/1`. El trabajo de verdad lo hace
`contar_texto/3`, que recibe un texto y da dos números:

<!-- ejemplo: capitulo-28/contar.pl predicado: contar_texto/3 consulta: contar_texto("uno dos\ntres\n", Lineas, Palabras). -->
```prolog
%!  contar_texto(+Texto:string, -Lineas:integer, -Palabras:integer) is det.
%
%   Lineas es la cantidad de saltos de línea de Texto, y Palabras la de sus
%   palabras, separadas por blancos.
contar_texto(Texto, Lineas, Palabras) :-
    aggregate_all(count, sub_string(Texto, _, _, _, "\n"), Lineas),
    split_string(Texto, " \t\r\n", " \t\r\n", Partes),
    exclude(==(""), Partes, Todas),
    length(Todas, Palabras).
```

```prolog
?- contar_texto("uno dos\ntres\n", Lineas, Palabras).
Lineas = 2,
Palabras = 3.
```

Cargado con `consult/1` o con `[contar]`, el archivo no ejecuta `main`: sus
predicados se consultan y se prueban como los de cualquier otro archivo. Solo
`swipl contar.pl …` lo ejecuta como programa. En Linux, una primera línea
`#!/usr/bin/env swipl` y el permiso de ejecución permiten escribir
`./contar.pl archivo` directamente.

## 28.2 Argumentos

`argv_options/3` separa la lista de argumentos en los **posicionales** —los
nombres de archivo— y las **opciones**, que empiezan con `-` o con `--`. Cada
opción se declara con `opt_type/3`: su nombre, la clave con la que llega a la
lista de opciones, y su tipo; `opt_help/2` da su descripción:

<!-- ejemplo: capitulo-28/contar.pl fragmento: opt_type(lineas, .. opt_help(help(usage), " [opciones] archivo..."). consulta: contar_texto("uno dos\ntres\n", Lineas, Palabras). -->
```prolog
opt_type(lineas,   lineas,   boolean).
opt_type(l,        lineas,   boolean).
opt_type(palabras, palabras, boolean).
opt_type(w,        palabras, boolean).

% opt_help(Clave, Texto): la ayuda de cada opción, para -h y --help.
opt_help(lineas,      "Escribe solo la cantidad de líneas").
opt_help(palabras,    "Escribe solo la cantidad de palabras").
opt_help(help(usage), " [opciones] archivo...").
```

Con `-l archivos/texto.txt`, `Archivos` es `['archivos/texto.txt']` y
`Opciones` es `[lineas(true)]`; `option/2`, de la
[sección 22.8](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#228-libraryoption), las consulta en `columnas/4`. Las opciones
`-h` y `--help` escriben la ayuda, armada con las declaraciones; la primera
línea nombra el ejecutable de SWI-Prolog de la máquina:

```text
$ swipl contar.pl --help
Usage:  C:\Program Files\swipl\bin\swipl.exe contar.pl [opciones] archivo...

Options:
-h, -?, --help Show this help message and exit
-l, --lineas   Escribe solo la cantidad de líneas
-w, --palabras Escribe solo la cantidad de palabras
```

El tipo se verifica al leer los argumentos: una opción declarada `integer`
con un valor que no es un número, o una opción que no está declarada, termina
el programa con un mensaje y el código 1, sin llegar a `main/1`. Los tipos
posibles son los de `must_be/2` —`integer`, `nonneg`, `atom`, `boolean`,
`oneof(Lista)`, …— y una opción `boolean` no lleva valor: `-l` es
`lineas(true)`.

## 28.3 Mensajes

Un programa de línea de comandos escribe dos clases de texto: su **salida**,
el resultado que se le pidió, y sus **mensajes**, que informan sobre la
ejecución. La salida va a `user_output`; los mensajes, a `user_error`. Así, la
salida puede redirigirse a un archivo o a otro programa sin arrastrar los
avisos, y los avisos siguen apareciendo en la terminal.

`print_message/2`, del [capítulo 25](../capitulo-25-errores-y-excepciones/index.md#257-mensajes-para-el-usuario), escribe un mensaje con un **nivel**:

| Nivel | Se escribe | Con `swipl -q` |
|---|---|---|
| `error` | `ERROR: …` | sí |
| `warning` | `Warning: …` | sí |
| `informational` | `% …` | no |
| `silent` | nada | no |

El texto de un mensaje propio se define con `prolog:message//1`, como en el
proyecto desde el capítulo 24. `contar.pl` define el de su error de uso:

<!-- ejemplo: capitulo-28/contar.pl fragmento: :- multifile prolog:message//1. .. [ 'Falta el nombre de un archivo (-h para ver la ayuda)' ]. consulta: contar_texto("uno dos\ntres\n", Lineas, Palabras). -->
```prolog
:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto de los mensajes propios del programa.
prolog:message(uso(sin_archivos)) -->
    [ 'Falta el nombre de un archivo (-h para ver la ayuda)' ].
```

Los errores de la biblioteca ya tienen texto: un archivo que no existe se
escribe `source_sink `'no.txt'' does not exist`, sin definir nada. Los
mensajes para quien desarrolla el programa, que el usuario no necesita ver,
son los de `debug/3`, del [capítulo 26](../capitulo-26-pruebas-y-depuracion/index.md#265-debug3-y-assertion1): se activan con `debug(Tema)` y no
aparecen en una ejecución normal.

`library(ansi_term)` escribe con colores en la terminal: `ansi_format([fg(red)],
"~w", [Texto])` escribe `Texto` en rojo. Cuando la salida no es una terminal
—un archivo, una tubería, una cadena de `with_output_to/2`—, escribe el texto
sin colores, y las pruebas no ven los códigos de color.

## 28.4 Códigos de salida

Un programa que termina devuelve un número al sistema: 0 si todo salió bien,
otro número si no. `halt(Codigo)` termina con ese código. Si `main/1` falla o
produce un error que nadie captura, SWI-Prolog termina con 1 o con 2,
respectivamente, y escribe el error con el archivo y la línea de la
directiva. `contar.pl` captura los errores en `main/1` para elegir el código
y escribir un mensaje limpio:

| Código | En `contar.pl` |
|---|---|
| 0 | se contaron todos los archivos |
| 1 | error de uso: ningún archivo, una opción desconocida o con un valor incorrecto |
| 2 | cualquier otro error, como un archivo que no existe |

```text
$ swipl contar.pl
ERROR: Falta el nombre de un archivo (-h para ver la ayuda)
$ echo $?
1
$ swipl contar.pl no.txt
ERROR: source_sink `'no.txt'' does not exist
$ echo $?
2
```

En la terminal de Linux o en Git Bash, `$?` es el código del último programa;
en PowerShell, `$LASTEXITCODE`. Otro programa, o un script, lo usa para
decidir qué hacer después: `swipl contar.pl x.txt && echo listo` escribe
`listo` solo si el código fue 0.

!!! example "Patrón 38 — Programa de línea de comandos"
    **Problema.** Un programa de Prolog tiene que usarse desde la terminal o
    desde un script: con argumentos, con mensajes claros y con un código de
    salida que diga si terminó bien.

    **Versión ingenua.** Leer `current_prolog_flag(argv, …)` a mano en cada
    predicado que necesita un argumento, llamar a `halt/1` desde donde se
    detecta un problema, y dejar que los errores lleguen al usuario con la pila
    de llamadas.

    **Patrón.** `:- initialization(main, main)` y `main/1`, el único
    predicado que depende de la línea de comandos: lee las opciones con
    `argv_options/3` y `opt_type/3`, llama al núcleo, captura los errores con
    un solo `catch/3`, los escribe con `print_message/2` y elige el código de
    salida, y termina con un solo `halt/1`. El núcleo no escribe mensajes ni
    termina el programa: lanza errores, y se prueba desde plunit como
    cualquier otro predicado.

    **Cuándo no usarlo.** En un programa que se usa solo desde el toplevel,
    o desde otro programa de Prolog: ahí `main/1` no agrega nada.

!!! question "Actividad"
    Ejecutar `contar.pl` sin argumentos, con un archivo que no existe, con
    `--bytes` y con `-l` y un archivo que existe, y ver el código de salida de
    cada ejecución (`$?` o `$LASTEXITCODE`). ¿Cuál de los cuatro mensajes
    escribe `contar.pl`, y cuáles SWI-Prolog?

## 28.5 Leer del teclado

El teclado es el stream `user_input`, y se lee con los predicados del
[capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md#272-leer-terminos-y-lineas): `read_line_to_string/2` para una línea, `read_term/2` para un
término de Prolog. Una persona escribe respuestas equivocadas, y un programa
que pregunta tiene que validarlas y volver a preguntar:

<!-- ejemplo: capitulo-28/preguntar.pl predicado: preguntar/3 preguntar_si_no/3 si_no/2 consulta: open_string("tal vez\nS\n", In), preguntar_si_no(In, "¿Seguir?", R). -->
```prolog
%!  preguntar(+In, +Pregunta:string, -Respuesta:string) is det.
%
%   Escribe Pregunta y lee una línea de In, sin los blancos de los extremos.
%
%   @error existence_error(respuesta, Pregunta) si In se terminó.
preguntar(In, Pregunta, Respuesta) :-
    format("~w ", [Pregunta]),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  existence_error(respuesta, Pregunta)
    ;   normalize_space(string(Respuesta), Linea)
    ).

%!  preguntar_si_no(+In, +Pregunta:string, -Respuesta) is det.
%
%   Respuesta es si o no. Acepta s, si, sí, n y no, en mayúsculas o en
%   minúsculas, y repite la pregunta ante cualquier otra respuesta.
preguntar_si_no(In, Pregunta, Respuesta) :-
    format(string(Completa), "~w (s/n)", [Pregunta]),
    preguntar(In, Completa, Texto),
    string_lower(Texto, Minusculas),
    (   si_no(Minusculas, R)
    ->  Respuesta = R
    ;   format("Responder s o n.~n"),
        preguntar_si_no(In, Pregunta, Respuesta)
    ).

%!  si_no(+Texto:string, -Respuesta) is semidet.
%
%   Texto es una forma de responder si o no.
si_no("s",  si).
si_no("si", si).
si_no("sí", si).
si_no("n",  no).
si_no("no", no).
```

Una sesión con el teclado, después de `preguntar_si_no(user_input,
"¿Seguir?", R)`:

```text
¿Seguir? (s/n) tal vez
Responder s o n.
¿Seguir? (s/n) S
R = si.
```

`string_lower(Texto, Minusculas)` pasa una cadena a minúsculas; por eso
`si_no/2` enumera solo las formas en minúsculas.

Los predicados reciben el stream de entrada como argumento, en lugar de leer
siempre de `user_input`. En el programa es `user_input`; en las pruebas, un
stream sobre una cadena, creado con `open_string/2`, que contiene las
respuestas escritas de antemano, y `with_output_to/2` captura lo que el
predicado escribió:

```prolog
test(repetir, true(R-S == si-"¿Seguir? (s/n) Responder s o n.\n\c
                                ¿Seguir? (s/n) ")) :-
    responder("tal vez\nsí\n", In, preguntar_si_no(In, "¿Seguir?", R), S).
```

`flush_output/0`, en `preguntar/3`, hace que la pregunta aparezca antes de
esperar la respuesta: sin un salto de línea, la salida puede quedar en un
búfer. En la terminal, SWI-Prolog escribe además su propio indicador, `|: `,
al leer de `user_input`; `prompt(_, '')` lo quita. `get_single_char/1` lee una
sola tecla, sin esperar Enter, y sirve para preguntas de una letra.
`preguntar_numero/5`, del mismo archivo, repite la pregunta hasta recibir un
entero dentro de un rango: `number_string/2` falla con un texto que no es un
número, y no produce un error.

## 28.6 Procesos externos

`process_create/3`, de `library(process)`, ejecuta otro programa en un proceso
nuevo. Sus opciones conectan la entrada y la salida del proceso con streams
del programa: `stdout(pipe(Out))` da un stream para leer lo que el proceso
escribe. `process_wait/2` espera que termine y da su estado:

<!-- ejemplo: capitulo-28/procesos.pl predicado: salida_de/4 consulta: salida_de(swipl, ['-g', 'halt(3)'], Salida, Estado). -->
```prolog
%!  salida_de(+Programa:atom, +Argumentos:list, -Salida:string, -Estado)
%!      is det.
%
%   Ejecuta Programa, que se busca en el PATH, con Argumentos, y espera que
%   termine. Salida es lo que escribió en su salida, y Estado, exit(Codigo)
%   con su código de salida.
%
%   @error existence_error(source_sink, path(Programa)) si Programa no está
%          en el PATH.
salida_de(Programa, Argumentos, Salida, Estado) :-
    setup_call_cleanup(
        process_create(path(Programa), Argumentos,
                       [stdout(pipe(Out)), process(Pid)]),
        read_string(Out, _, Salida),
        close(Out)),
    process_wait(Pid, Estado).
```

```prolog
?- salida_de(swipl, ['-g', 'write(hola)', '-t', 'halt'], Salida, Estado).
Salida = "hola",
Estado = exit(0).

?- salida_de(swipl, ['-g', 'halt(3)'], Salida, Estado).
Salida = "",
Estado = exit(3).
```

`read_string(Out, _, Salida)` lee lo que queda en el stream `Out`, hasta el
final, como una cadena; el segundo argumento, libre, queda ligado a su
longitud. `path(swipl)` busca el programa en los directorios del `PATH`, en
Windows y en Linux. Los argumentos van en una lista, cada uno por separado, y no pasan por
el intérprete de comandos del sistema: un nombre con espacios o con comillas
llega intacto. `shell/2` ejecuta, en cambio, una línea completa con el
intérprete de comandos —`cmd.exe` en Windows, `sh` en Linux—, y la misma línea
se comporta distinto en cada uno; conviene reservarlo para usos
interactivos.

Ejecutar un programa en otro proceso es también la forma de probarlo
completo, con sus argumentos, su salida y su código de salida. `contar.plt`
tiene un predicado auxiliar que ejecuta `swipl contar.pl` con los argumentos
de cada prueba. La ruta de `contar.pl` la da `source_file/2`, que relaciona un
predicado cargado con el archivo que lo define:

```prolog
test(sin_archivos, true(E == exit(1))) :-
    correr([], [], Errores, E),
    once(sub_string(Errores, _, _, _, "Falta el nombre de un archivo")).
```

## 28.7 Fecha y hora

`get_time/1` da el momento actual como un número de segundos desde el 1 de
enero de 1970, un **timestamp**. `stamp_date_time/3` lo convierte en un
término `date/9`, en una zona horaria, y `format_time/3` lo escribe con un
formato:

```text
?- get_time(T), stamp_date_time(T, D, local).
T = 1790310177.72796,
D = date(2026, 9, 25, 1, 22, 57.72796010971069, 10800, 'Hora estándar de Argentina', false).

?- get_time(T), format_time(atom(A), '%A %d de %B de %Y, %H:%M', T).
T = 1790310177.728177,
A = 'viernes 25 de septiembre de 2026, 01:22'.
```

Las respuestas cambian con cada ejecución, y por eso el capítulo las muestra
sin verificarlas. El séptimo argumento de `date/9` es la diferencia con la
hora universal, en segundos hacia el oeste: 10 800 son tres horas. Los nombres
de `%A` y de `%B` dependen de la configuración regional del sistema: en otra
máquina, el mismo formato escribe `Friday` y `September`.

Las cuentas con fechas se hacen con timestamps. `fecha.pl` representa una
fecha como `date(Anio, Mes, Dia)`, y convierte a días:

<!-- ejemplo: capitulo-28/fecha.pl predicado: dia_absoluto/2 dias_entre/3 sumar_dias/3 consulta: dias_entre(date(2026, 3, 1), date(2026, 9, 25), Dias). -->
```prolog
%!  dia_absoluto(+Fecha, -N:integer) is det.
%
%   N es la cantidad de días desde el 1 de enero de 1970 hasta Fecha.
dia_absoluto(date(Anio, Mes, Dia), N) :-
    date_time_stamp(date(Anio, Mes, Dia, 0, 0, 0, 0, -, -), Segundos),
    N is round(Segundos / 86400).

%!  dias_entre(+Desde, +Hasta, -Dias:integer) is det.
%
%   Dias es la cantidad de días de Desde a Hasta: negativa si Hasta es
%   anterior.
dias_entre(Desde, Hasta, Dias) :-
    dia_absoluto(Desde, N1),
    dia_absoluto(Hasta, N2),
    Dias is N2 - N1.

%!  sumar_dias(+Fecha, +Dias:integer, -Resultado) is det.
%
%   Resultado es la fecha Dias días después de Fecha, o antes si Dias es
%   negativo. date_time_stamp/2 acepta un día fuera del mes, como el 61 de
%   enero, y lo convierte en la fecha que corresponde.
sumar_dias(date(Anio, Mes, Dia), Dias, date(A, M, D)) :-
    Dia1 is Dia + Dias,
    date_time_stamp(date(Anio, Mes, Dia1, 0, 0, 0, 0, -, -), Segundos),
    stamp_date_time(Segundos, date(A, M, D, _, _, _, _, _, _), 'UTC').
```

```prolog
?- dias_entre(date(2026, 3, 1), date(2026, 9, 25), Dias).
Dias = 208.

?- sumar_dias(date(2026, 1, 31), 30, F).
F = date(2026, 3, 2).
```

`round(X)` es la función aritmética que da el entero más cercano a `X`:
`dia_absoluto/2` la usa porque la división `/` da un número de punto
flotante. El día 61 de enero no existe, y `date_time_stamp/2` lo acepta igual: lo
convierte en el 2 de marzo, contando los días de febrero de ese año. Los años
bisiestos y los cambios de mes y de año quedan a cargo de la biblioteca. Para
que los nombres no dependan del sistema, `fecha.pl` los toma de tablas
propias:

<!-- ejemplo: capitulo-28/fecha.pl predicado: dia_de_la_semana/2 fecha_texto/2 consulta: fecha_texto(date(2026, 9, 25), Texto). -->
```prolog
%!  dia_de_la_semana(+Fecha, -Nombre:atom) is det.
%
%   Nombre es el día de la semana de Fecha, en castellano.
dia_de_la_semana(Fecha, Nombre) :-
    day_of_the_week(Fecha, N),
    nth1(N, [lunes, martes, miércoles, jueves, viernes, sábado, domingo],
         Nombre).

%!  fecha_texto(+Fecha, -Texto:string) is det.
%
%   Texto es Fecha escrita en castellano: "viernes 25 de septiembre de
%   2026".
fecha_texto(date(Anio, Mes, Dia), Texto) :-
    dia_de_la_semana(date(Anio, Mes, Dia), NombreDelDia),
    nombre_del_mes(Mes, NombreDelMes),
    format(string(Texto), "~w ~d de ~w de ~d",
           [NombreDelDia, Dia, NombreDelMes, Anio]).
```

```prolog
?- fecha_texto(date(2026, 9, 25), Texto).
Texto = "viernes 25 de septiembre de 2026".

?- fecha_iso(F, "2026-09-25").
F = date(2026, 9, 25).
```

`day_of_the_week/2` da el número del día de la semana de una fecha, desde
1, el lunes, hasta 7, el domingo.

`hoy/1` es el único predicado de `fecha.pl` que depende del reloj; los demás
dan siempre el mismo resultado, y se prueban con fechas fijas. Su prueba solo
verifica la forma de la respuesta.

!!! question "Actividad"
    Ejecutar `format_time(atom(A), '%A %d de %B', date(2026, 9, 25))` en la
    máquina propia. ¿En qué idioma están los nombres? ¿Qué escribe
    `fecha_texto/2` con la misma fecha?

## 28.8 Windows y Linux

SWI-Prolog funciona igual en los dos sistemas, pero el entorno no es el
mismo. Las diferencias que un programa de línea de comandos encuentra:

| Tema | Windows | Linux | En el programa |
|---|---|---|---|
| Separador de rutas | `\`, y también acepta `/` | `/` | escribir las rutas con `/`, o armarlas con `directory_file_path/3` |
| Fin de línea | `\r\n` | `\n` | leer con `read_line_to_string/2`, o quitar el `\r` con `split_string/4` |
| Codificación de archivos | la regional, si no se indica | UTF-8 | `encoding(utf8)` en cada `open/4` ([capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md#271-streams)) |
| Codificación de la terminal | la regional: las tildes pueden verse mal en algunas terminales | UTF-8 | en la salida, sin tildes lo que deba leerse en cualquier terminal |
| Nombres de días y meses | los de la configuración regional | los de la configuración regional | tablas propias, como en `fecha.pl` |
| Intérprete de comandos | `cmd.exe`, PowerShell | `sh`, `bash` | `process_create/3`, no `shell/2` |
| Ejecutar el programa | `swipl programa.pl` | `swipl programa.pl`, o `./programa.pl` con `#!` | documentar la primera forma, que sirve en los dos |
| Código de salida | `$LASTEXITCODE` | `$?` | — |

`current_prolog_flag(windows, true)` se cumple en Windows, y
`current_prolog_flag(unix, true)` en Linux y macOS; `sistema/1`, en
`procesos.pl`, las usa. Un programa que necesita distinguir los dos sistemas
debería hacerlo en un solo predicado, como `sistema/1`, y no en cada lugar
donde aparece la diferencia.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C6 | `main/1` es el borde: lee los argumentos, llama al núcleo y convierte el resultado en un código de salida; `contar_texto/3`, `ejecutar/2` y las cuentas de `fecha.pl` no dependen de la terminal, y se prueban sin ella |
    | C5 | cada error llega al usuario como un mensaje y un código de salida distinto de 0; las pruebas de `contar.plt` y de `principal.plt` verifican los códigos ejecutando el programa en otro proceso |

## 28.9 El proyecto: *Inscripciones* en la terminal

*Inscripciones* se ejecuta ahora desde la terminal. Las órdenes son las del
lenguaje de comandos del [capítulo 21](../capitulo-21-gramaticas-dcg/index.md#2110-el-proyecto-un-lenguaje-de-comandos), escritas como argumentos:

```text
$ swipl principal.pl listar logica
Inscriptos: 101, 102, 104, 106.
$ swipl principal.pl inscribir a 105 en logica
Rechazada: sin_vacantes.
$ echo $?
1
```

Sin argumentos, el programa lee las órdenes del teclado, una por línea, hasta
`salir`:

```text
$ swipl principal.pl
inscripciones> promedio de 101
Promedio: 8.50.
inscripciones> ranking
Legajo  Nombre        Promedio
101     ana               8.50
104     diego             8.00
103     carla             6.00
106     facundo           4.50
102     bruno             4.00
inscripciones> salir
```

El módulo nuevo, `consola`, escribe las respuestas para una persona, elige el
código de salida de cada una, y tiene el bucle:

<!-- ejemplo: capitulo-28/inscripciones/consola.pl predicado: responder/2 codigo_de_salida/2 bucle/1 consulta: responder("listar logica", Respuesta). -->
```prolog
%!  responder(+Orden:text, -Respuesta) is det.
%
%   Ejecuta Orden y escribe su respuesta. Además de los comandos de
%   ejecutar/2, acepta ranking, que escribe el ranking, y ayuda, que
%   escribe las órdenes posibles.
responder(Orden, Respuesta) :-
    normalize_space(string(Texto), Orden),
    (   Texto == "ranking"
    ->  current_output(Salida),
        escribir_ranking(Salida),
        Respuesta = ranking
    ;   Texto == "ayuda"
    ->  escribir_ayuda,
        Respuesta = ayuda
    ;   ejecutar(Texto, Respuesta),
        escribir_respuesta(Respuesta)
    ).

%!  codigo_de_salida(+Respuesta, -Codigo:integer) is det.
%
%   Codigo es el código de salida del programa después de Respuesta: 0 si el
%   pedido se cumplió, 1 si se rechazó o no se entendió, 2 si produjo un
%   error.
codigo_de_salida(rechazada(_), 1) :-
    !.
codigo_de_salida(no_entendido, 1) :-
    !.
codigo_de_salida(error(_), 2) :-
    !.
codigo_de_salida(_, 0).

%!  bucle(+In) is det.
%
%   Lee órdenes de In, una por línea, y responde cada una, hasta leer salir
%   o hasta que In se termine. Las líneas vacías se ignoran.
bucle(In) :-
    format("inscripciones> "),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  nl
    ;   normalize_space(string(Orden), Linea),
        (   Orden == "salir"
        ->  true
        ;   Orden == ""
        ->  bucle(In)
        ;   responder(Orden, _),
            bucle(In)
        )
    ).
```

`responder("listar logica", R)` escribe `Inscriptos: 101, 102, 104, 106.` y
da `R = inscriptos([101, 102, 104, 106])`, la respuesta de `ejecutar/2`, que
`codigo_de_salida/2` convierte en 0. `responder/2` usa `ejecutar/2`, del [capítulo 21](../capitulo-21-gramaticas-dcg/index.md), sin cambios: la terminal es
una forma más de llegar al mismo núcleo. El bucle lee de un stream, y sus
pruebas le dan las órdenes en una cadena. `principal.pl` es el programa:

<!-- ejemplo: capitulo-28/inscripciones/principal.pl predicado: main/1 correr/3 consulta: responder("listar logica", Respuesta). -->
```prolog
%!  main(+Argv:list) is det.
%
%   Ejecuta la orden de Argv, o el bucle si no hay ninguna, y termina con el
%   código de salida de la respuesta. Un error que nadie capturó se escribe
%   como mensaje, y el código es 2.
main(Argv) :-
    argv_options(Argv, Palabras, Opciones),
    catch(correr(Palabras, Opciones, Codigo),
          Error,
          ( print_message(error, Error),
            Codigo = 2 )),
    halt(Codigo).

%!  correr(+Palabras:list, +Opciones:list, -Codigo:integer) is det.
%
%   Carga los ajustes y el estado que piden Opciones, ejecuta la orden
%   formada por Palabras o el bucle, y guarda el estado.
correr(Palabras, Opciones, Codigo) :-
    (   option(ajustes(Ajustes), Opciones)
    ->  cargar_ajustes(Ajustes)
    ;   true
    ),
    (   option(estado(Archivo), Opciones),
        exists_file(Archivo)
    ->  cargar_estado(Archivo)
    ;   true
    ),
    (   Palabras == []
    ->  prompt(_, ''),
        bucle(user_input),
        Codigo = 0
    ;   atomic_list_concat(Palabras, ' ', Orden),
        responder(Orden, Respuesta),
        codigo_de_salida(Respuesta, Codigo)
    ),
    (   option(estado(Archivo), Opciones)
    ->  guardar_estado(Archivo)
    ;   true
    ).
```

Con `--estado=ARCHIVO`, el programa carga el estado guardado antes de
ejecutar la orden, si `exists_file/1` confirma que el archivo existe, y lo guarda al terminar, con los predicados del
[capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md#2711-el-proyecto-el-borde-con-los-archivos). Así, una inscripción hecha en una ejecución se ve en la
siguiente:

```text
$ swipl principal.pl --estado=estado.txt inscribir a 104 en sintaxis
Inscripción aceptada.
$ swipl principal.pl --estado=estado.txt listar sintaxis
Inscriptos: 104.
```

Con `--ajustes=archivos/ajustes.cfg`, la nota mínima es 7, y `inscribir a 102
en paradigmas` se rechaza con `falta(log)`, porque el 6 de lógica ya no
aprueba. Las pruebas de `principal.plt` ejecutan el programa en otro proceso,
como en la [sección 28.6](#286-procesos-externos): una orden aceptada, una rechazada, los ajustes, un
archivo de ajustes que no existe, el estado entre dos ejecuciones y el bucle.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Agregar a `contar.pl` la opción `-c`, `--caracteres`, que escribe
   la cantidad de caracteres.
2. **(1)** ¿Con qué código termina `contar.pl` con la opción `--lineas=3`? ¿Y
   con `-l` y dos archivos, el segundo inexistente? ¿Qué se escribe en cada
   caso?
3. ★ **(2)** Escribir `eco.pl`, un programa que escribe sus argumentos en orden
   inverso, uno por línea, y termina con el código 1 si no recibe ninguno.
4. **(2)** Escribir `preguntar_opcion/4`, que muestra una lista numerada de
   opciones y lee el número de la elegida, repitiendo la pregunta hasta que
   sea válido.
5. ★ **(2)** Dar al sistema experto de animales del [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md) un
   diálogo: cada dato que falta se pregunta al usuario con
   `preguntar_si_no/3`.
6. **(2)** Escribir `primera_linea_de/3`: la primera línea que escribe un
   programa con ciertos argumentos, como `swipl --version`.
7. **(2)** Escribir `codigo_de/3`, que ejecuta un archivo de Prolog con
   argumentos y da su código de salida, y usarlo para probar `eco.pl`.
8. ★ **(2)** Escribir `edad_en/3`: la edad, en años cumplidos, de una persona
   nacida en una fecha, en otra fecha.
9. **(2)** Escribir `proximo_habil/2`: el primer día después de una fecha que
   no es sábado ni domingo.
10. **(1)** Escribir `fecha_corta/2`, que escribe una fecha como `vie 25/09`,
    sin depender de la configuración regional.
11. **(2)** Escribir `directorio_de_datos/2`: el directorio donde un programa
    guarda sus datos, `%APPDATA%\Programa` en Windows y
    `~/.local/share/programa` en Linux, con `getenv/2`.
12. ★ **(2)** En el proyecto, agregar la opción `--salida=ARCHIVO`: la
    respuesta de la orden se escribe en el archivo, no en la terminal.
13. **(2)** En el proyecto, hacer que el bucle cuente las órdenes que
    ejecutó, y escriba la cantidad al salir, sin usar la base dinámica.
14. ★ **(3)** Escribir el Buscaminas para la terminal: `swipl buscaminas.pl 9 9
    10` crea un tablero de 9 × 9 con 10 minas al azar, lo muestra, y lee
    jugadas —`d 3 4` descubre la celda de la fila 3 y la columna 4, `m 3 4`
    la marca— hasta que se descubre una mina o todas las celdas libres. Usar
    el tablero del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#2211-buscaminas-el-tablero-como-tabla-de-busqueda) y la forma de descubrir una región
    del [capítulo 18](../capitulo-18-orden-superior/index.md).

## Resumen

| | |
|---|---|
| `:- initialization(main, main)` | ejecutar `main/0` en lugar del toplevel, y terminar |
| `library(main)`, `main/1` | los argumentos del programa, como una lista |
| `argv_options/3`, `opt_type/3`, `opt_help/2` | opciones con tipo, y la ayuda de `-h` |
| `halt/1` | terminar con un código de salida |
| `print_message/2`, `prolog:message//1` | mensajes con nivel, en `user_error` |
| `ansi_format/3` | colores en la terminal |
| `user_input`, `read_line_to_string/2`, `prompt/2`, `get_single_char/1` | leer del teclado |
| `string_lower/2`, `writeln/1` | una cadena en minúsculas; escribir un término y un salto de línea |
| `process_create/3`, `process_wait/2`, `read_string/3` | ejecutar otro programa y leer su salida |
| `exists_file/1`, `file_base_name/2`, `source_file/2` | si existe un archivo; el último componente de una ruta; el archivo que define un predicado |
| `get_time/1`, `stamp_date_time/3`, `date_time_stamp/2`, `format_time/3`, `round/1` | fecha y hora; `round/1`, el entero más cercano, en `is/2` |
| `ord_del_element/3` | quitar un elemento de un conjunto ordenado (solución 14) |
| `current_prolog_flag(windows, true)` | distinguir el sistema, en un solo lugar |
| **[Patrón 38](../patrones.md#38-programa-de-linea-de-comandos)** | programa de línea de comandos |
| `day_of_the_week/2`, `parse_time/3` | el día de la semana de una fecha, de 1 a 7; leer una fecha escrita en ISO 8601 |
| `getenv/2`, `prolog_to_os_filename/2` | el valor de una variable de entorno; convertir una ruta entre la forma de Prolog y la del sistema (solución 11) |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Interfaces de pantalla completa y con ventanas | [capítulo 36](../capitulo-36-interfaces-de-usuario/index.md) |
| El mismo núcleo, llamado desde Python | [capítulo 29](../capitulo-29-prolog-desde-python/index.md) |
| El mismo núcleo, como servicio web | [capítulo 30](../capitulo-30-servicios-web-rest/index.md) |
| El programa como ejecutable, sin `swipl` delante | [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md) |
| El Buscaminas completo | [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md) |
