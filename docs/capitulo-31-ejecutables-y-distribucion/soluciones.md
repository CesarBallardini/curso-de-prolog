# Soluciones del capítulo 31 — Ejecutables y distribución

El código de esta página está en `ejemplos/capitulo-31/`: `soluciones.pl`,
`soluciones_contar.pl`, `materias.pl`, `soluciones_construir.pl`,
`soluciones_proyecto.pl` y, en `buscaminas/`, `soluciones_buscaminas.pl`, el
`Dockerfile` y `buscaminas.service`, con sus pruebas. Las que construyen
programas lo hacen en un directorio temporal, y ejecutan lo construido como
se ejecuta en cada sistema: con `swipl -x` en Windows, directamente en Linux.

## 1

`construir.pl` escribe, para cada programa, lo que se entrega:

| | Windows | Linux |
|---|---|---|
| `contar.pl` | `contar.state` y `contar.bat` | `contar` |
| `refranes.pl` | `refranes.state` y `refranes.bat` | `refranes` |

`refranes.txt` no se copia: sus líneas son hechos del programa guardado. Los
archivos que `contar` cuenta tampoco forman parte de la entrega: los recibe
como argumento quien lo ejecuta.

En Windows, la otra máquina necesita SWI-Prolog 9.2.9 instalado y `swipl` en
el `PATH`, que es lo que llama el lanzador. En Linux, el ejecutable autónomo
no necesita `swipl` en el `PATH`, pero sí la biblioteca compartida
`libswipl.so` y las que ella usa: en la práctica, SWI-Prolog 9.2.9
instalado, o un contenedor con la imagen `swipl:9.2.9`.

## 2

`swipl` toma cada argumento terminado en `.pl` que sigue al primero como
otro archivo que debe cargar. `contar.pl` se carga en el mismo proceso que
`construir.pl`, y sus predicados reemplazan a los del constructor: aparecen
las advertencias de procedimientos redefinidos —`opt_type/3`, `opt_help/2`,
`main/1`, `codigo_de_error/2`—, y el `main/1` que se ejecuta es el de
`contar.pl`, que no recibe ningún argumento, porque `contar.pl` ya se usó
como archivo:

```text
$ swipl construir.pl contar.pl
Warning: …/contar.pl:22:
Warning:    Redefined static procedure opt_type/3
…
ERROR: Falta el nombre de un archivo (-h para ver la ayuda)
```

El mensaje es de `contar.pl`, no de `construir.pl`. Con
`swipl construir.pl -- contar.pl`, `contar.pl` llega a `main/1` como
argumento.

## 3

<!-- ejemplo: capitulo-31/soluciones_contar.pl fragmento: % version(Version) .. version('1.0.0'). -->
```prolog
% version(Version): la versión del programa, mayor.menor.corrección.
version('1.0.0').
```

<!-- ejemplo: capitulo-31/soluciones_contar.pl predicado: correr/2 -->
```prolog
%!  correr(+Archivos:list, +Opciones:list) is det.
%
%   Escribe la versión si Opciones la pide; si no, cuenta Archivos.
correr(_, Opciones) :-
    option(version(true), Opciones),
    !,
    version(Version),
    format("contar ~w~n", [Version]).
correr(Archivos, Opciones) :-
    contar_archivos(Archivos, Opciones).
```

La opción se declara con `opt_type(version, version, boolean)` y su ayuda
con `opt_help/2`, y `main/1` llama a `correr/2` en lugar de
`contar_archivos/2`. Con `--version`, el programa no necesita archivos: la
opción se examina antes de contar, y `contar --version` no es un error de
uso.

```text
$ swipl soluciones_contar.pl --version
contar 1.0.0
```

## 4

<!-- ejemplo: capitulo-31/materias.pl predicado: cargar_materias/1 main/1 -->
```prolog
%!  cargar_materias(+Archivo) is det.
%
%   Reemplaza los hechos materia/3 por las materias del arreglo JSON de
%   Archivo, cada una con su código, su nombre y su año.
cargar_materias(Archivo) :-
    retractall(materia(_, _, _)),
    setup_call_cleanup(open(Archivo, read, Stream, [encoding(utf8)]),
                       json_read_dict(Stream, Materias,
                                      [value_string_as(atom)]),
                       close(Stream)),
    forall(member(M, Materias),
           ( _{codigo: Codigo, nombre: Nombre, anio: Anio} :< M,
             assertz(materia(Codigo, Nombre, Anio)) )).

%!  main(+Argv:list) is det.
%
%   Escribe el nombre de la materia de código Argv. Termina con el código 1
%   si no hay una materia con ese código, y con 2 si Argv no es un solo
%   argumento.
main([Codigo]) :-
    !,
    (   materia(Codigo, Nombre, _)
    ->  format("~w~n", [Nombre])
    ;   format(user_error, "No hay una materia con el código ~w.~n",
               [Codigo]),
        halt(1)
    ).
main(_) :-
    format(user_error, "Uso: swipl materias.pl codigo~n", []),
    halt(2).
```

<!-- ejemplo: capitulo-31/materias.pl fragmento: % Se ejecuta al cargar .. cargar_materias(Archivo). -->
```prolog
% Se ejecuta al cargar el archivo, y por lo tanto al construir el programa.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, 'archivos/materias.json', Archivo),
   cargar_materias(Archivo).
```

Es la técnica de `refranes.pl`, con la lectura de JSON del
[capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md): `value_string_as(atom)` lee los códigos como átomos,
que son los que `main/1` recibe, y `:<` toma los tres campos de cada objeto.

## 5

<!-- ejemplo: capitulo-31/soluciones_construir.pl predicado: construir_y_probar/3 probar/2 -->
```prolog
%!  construir_y_probar(+Directorio:atom, +Probar:boolean, +Programa:atom)
%!      is det.
%
%   Construye Programa en Directorio, y lo prueba si Probar es true.
construir_y_probar(Directorio, Probar, Programa) :-
    construir(Directorio, Programa),
    (   Probar == true
    ->  probar(Directorio, Programa)
    ;   true
    ).

%!  probar(+Directorio:atom, +Programa:atom) is det.
%
%   Ejecuta con --help lo que se construyó a partir de Programa en
%   Directorio, como se ejecuta en cada sistema.
%
%   @error prueba(Programa, Estado) si no termina con el código 0.
probar(Directorio, Programa) :-
    file_base_name(Programa, Archivo),
    file_name_extension(Nombre, _, Archivo),
    directory_file_path(Directorio, Nombre, Base),
    sistema(Sistema),
    destino(Sistema, Base, Salida0, _),
    absolute_file_name(Salida0, Salida),
    (   Sistema == windows
    ->  Ejecutable = path(swipl),
        Argumentos = ['-x', Salida, '--', '--help']
    ;   Ejecutable = Salida,
        Argumentos = ['--help']
    ),
    process_create(Ejecutable, Argumentos,
                   [stdout(null), stderr(null), process(Pid)]),
    process_wait(Pid, Estado),
    (   Estado == exit(0)
    ->  format("~w: la prueba pasó~n", [Programa])
    ;   throw(prueba(Programa, Estado))
    ).
```

`construir_todos/3` aplica `construir_y_probar/3` a cada programa, con el
valor de la opción `--probar`, y el mensaje de `prueba/2` se agrega a los de
`prolog:message//1`. Un error de la prueba termina el constructor con el
código 2, como uno de construcción.

La prueba es mínima: comprueba que lo construido arranca, carga lo que
necesita y lee sus argumentos. Con `contar.pl` pasa, porque `argv_options/3`
atiende `--help` y termina con 0. Con `refranes.pl` y `materias.pl` no
pasa: sus `main/1` no usan `argv_options/3`, toman `--help` como un número
de refrán o un código de materia, y terminan con 1. La prueba descubre así
algo cierto: esos dos programas no tienen ayuda.

## 6

<!-- ejemplo: capitulo-31/materias.plt fragmento: test(sin_el_archivo .. correr(Programa, [log], S, E). -->
```prolog
test(sin_el_archivo, [ setup(( tmp_file(construido, D), make_directory(D) )),
                       cleanup(delete_directory_and_contents(D)),
                       true(S-E == ["logica"]-exit(0)) ]) :-
    construir_sin_datos(D, Programa),
    correr(Programa, [log], S, E).
```

`make_directory/1` crea el directorio temporal de la prueba, y
`delete_directory_and_contents/1` lo borra con todo lo que contiene.
`construir_sin_datos/2`, en `materias.plt`, copia `materias.pl` y su archivo
JSON a un directorio temporal, construye allí y borra la copia del JSON:
el archivo original queda en su lugar, y las demás pruebas lo siguen usando.
La prueba `codigo_desconocido` ejecuta lo construido con `xyz` y verifica el
código 1. Es la misma estructura que las pruebas de `refranes.plt`.

## 7

<!-- ejemplo: capitulo-31/buscaminas/Dockerfile fragmento: FROM swipl .. CMD -->
```dockerfile
FROM swipl:9.2.9

WORKDIR /app
COPY *.pl ./

EXPOSE 8080
CMD ["swipl", "buscaminas.pl", "--servicio", "--puerto=8080", "--publico"]
```

El comando necesita tres opciones: `--servicio`, porque en un contenedor no
hay nadie que juegue en la terminal; `--puerto=8080`, porque sin la opción
el servicio elige un puerto libre, y `docker run -p` necesita saber cuál
publicar; y `--publico`, porque dentro del contenedor `localhost` es el
propio contenedor, y los pedidos que Docker reenvía llegan por otra
interfaz. La imagen se construye desde `buscaminas/`, que tiene todos los
módulos:

```text
$ docker build -t buscaminas .
$ docker run --rm -p 8080:8080 buscaminas
```

## 8

<!-- ejemplo: capitulo-31/buscaminas/buscaminas.service fragmento: [Unit] .. WantedBy=multi-user.target -->
```ini
[Unit]
Description=Buscaminas, el juego del curso de Prolog como servicio web
After=network.target

[Service]
Type=simple
User=buscaminas
WorkingDirectory=/opt/buscaminas
ExecStart=/usr/bin/swipl buscaminas.pl --servicio --puerto=8081
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Cambian cuatro líneas: `Description`, el usuario, el directorio de trabajo y
`ExecStart`, que ejecuta `buscaminas.pl` con `--servicio` y el puerto 8081.
El resto —arrancar después de la red, volver a arrancar ante un error,
arrancar con la máquina— es igual para cualquier servicio. Sin `--publico`,
el servicio solo acepta pedidos de la misma máquina: detrás de un servidor
web como nginx, que reenvía los pedidos desde la misma máquina, es lo que
conviene.

## 9

<!-- ejemplo: capitulo-31/soluciones.pl predicado: bisiesto/1 -->
```prolog
%!  bisiesto(+Anio:integer) is semidet.
%
%   Anio es bisiesto: es múltiplo de 4, salvo los múltiplos de 100 que no
%   lo son de 400.
%
%   @error type_error(integer, Anio) si Anio no es un entero.
bisiesto(Anio) :-
    must_be(integer, Anio),
    (   Anio mod 400 =:= 0
    ->  true
    ;   Anio mod 100 =\= 0,
        Anio mod 4 =:= 0
    ).
```

En el pack, `bisiesto/1` se agrega a la lista de exportación del módulo
`fechas_castellano`. La entrega nueva agrega algo y no cambia nada de lo que
ya había: es la versión `1.1.0`, y `pack.pl` dice `version('1.1.0')`. Un
programa escrito para la `1.0.0` funciona igual con la `1.1.0`.

Cambiar el orden de los argumentos de `dias_entre/3`, en cambio, hace que
los programas que ya la llaman calculen otra cosa, o fallen: es un cambio
incompatible, y la versión pasa a `2.0.0`.

## 10

En el toplevel, desde `ejemplos/capitulo-31`, `qcompile(contar)` escribe
`contar.qlf` junto al fuente. Comparado con el programa guardado:

| | `contar.qlf` | `contar.state` |
|---|---|---|
| Contiene | `contar.pl` compilado, solo ese archivo | el programa completo, con las bibliotecas que cargó |
| Tamaño | unos 2 KB | unos 830 KB |
| Se ejecuta con | `swipl contar.qlf archivos/texto.txt` | `swipl -x contar.state -- archivos/texto.txt` |
| Necesita | SWI-Prolog, con las bibliotecas que el programa usa, `library(main)` y `library(readutil)` | SWI-Prolog, en la misma versión |

Los dos se cargan sin el fuente, y los dos solo los carga la versión de
SWI-Prolog que los produjo. El `.qlf` es una parte del programa, que se
carga como se cargaría el `.pl`: las bibliotecas salen de la instalación,
cuando el programa las pide. El programa guardado es el programa completo.

`qcompile/1` carga el archivo para compilarlo. Desde el toplevel, la
directiva `initialization(main, main)` no se ejecuta; en cambio, con
`swipl -g "qcompile(contar)"` sí, y `contar` escribe su error de uso antes
de terminar. El `.qlf` se escribe igual.

## 11

<!-- ejemplo: capitulo-31/soluciones_proyecto.pl predicado: ejecutar_construido/5 -->
```prolog
%!  ejecutar_construido(+Directorio:atom, +Nombre:atom, +Argumentos:list,
%!                      -Salida:list(string), -Estado) is det.
%
%   Ejecuta el programa Nombre construido en Directorio con Argumentos:
%   con swipl -x en Windows, directamente en Linux. Salida son las líneas
%   que escribe, y Estado, exit(Codigo).
ejecutar_construido(Directorio, Nombre, Argumentos, Salida, Estado) :-
    sistema(Sistema),
    destino(Sistema, Nombre, Archivo, _),
    directory_file_path(Directorio, Archivo, Construido),
    (   Sistema == windows
    ->  Programa = path(swipl),
        Todos = ['-x', Construido, '--'|Argumentos]
    ;   Programa = Construido,
        Todos = Argumentos
    ),
    process_create(Programa, Todos,
                   [stdout(pipe(Out)), stderr(null), process(Pid)]),
    read_string(Out, _, Texto),
    close(Out),
    process_wait(Pid, Estado),
    split_string(Texto, "\n", "\r", Lineas),
    exclude(==(""), Lineas, Salida).
```

<!-- ejemplo: capitulo-31/soluciones_proyecto.plt fragmento: test(estado_conservado, .. [Opcion, listar, algebra] -->
```prolog
test(estado_conservado,
     [ setup(( tmp_file(construido, D), make_directory(D) )),
       cleanup(delete_directory_and_contents(D)),
       true(E1-S2 == exit(0)-["Inscriptos: 101, 102, 103, 104, 105."]) ]) :-
    source_file(user:ejecutar_construido(_, _, _, _, _), Solucion),
    file_directory_name(Solucion, Capitulo),
    directory_file_path(Capitulo, 'inscripciones/principal.pl', Programa),
    with_output_to(string(_), construir(D, Programa)),
    directory_file_path(D, 'estado.txt', Archivo),
    atom_concat('--estado=', Archivo, Opcion),
    ejecutar_construido(D, principal, [Opcion, inscribir, a, '105', en,
                                       algebra], _, E1),
    ejecutar_construido(D, principal, [Opcion, listar, algebra], S2, _).
```

`soluciones_proyecto.pl` carga `construir.pl`, y usa `construir/2` para
construir y `destino/4` para saber qué se construyó en cada sistema. La
prueba `sin_estado` hace las mismas dos ejecuciones sin `--estado`, y
verifica que el alumno 105 no aparece: cada ejecución empieza de los datos
del programa. Juntas, las dos pruebas muestran qué viaja dentro de lo
construido —los datos del proyecto— y qué queda afuera: el estado que el
programa cambia.

## 12

<!-- ejemplo: capitulo-31/buscaminas/soluciones_buscaminas.pl fragmento: % nivel(Nivel, .. nivel(experto, -->
```prolog
% nivel(Nivel, Filas, Columnas, Minas): el tablero de cada nivel.
nivel(principiante,  9,  9, 10).
nivel(intermedio,   16, 16, 40).
nivel(experto,      16, 30, 99).
```

<!-- ejemplo: capitulo-31/buscaminas/soluciones_buscaminas.pl predicado: correr/3 jugar/5 -->
```prolog
%!  correr(+Posicionales:list, +Opciones:list, -Codigo:integer) is det.
%
%   Hace lo que piden los argumentos.
%
%   @error uso(argumentos) si no son tres números, ni un nivel, ni
%          --servicio.
correr(_, Opciones, 0) :-
    option(servicio(true), Opciones),
    !,
    option(puerto(Puerto), Opciones, _),
    (   option(publico(true), Opciones)
    ->  Alcance = publico
    ;   Alcance = local
    ),
    iniciar_servicio(Puerto, Alcance),
    format("Buscaminas en http://localhost:~w/~n", [Puerto]),
    flush_output,
    thread_get_message(_).
correr([], Opciones, Codigo) :-
    option(nivel(Nivel), Opciones),
    !,
    nivel(Nivel, Filas, Columnas, Minas),
    jugar(Filas, Columnas, Minas, Opciones, Codigo).
correr([F, C, M], Opciones, Codigo) :-
    !,
    maplist(numero, [F, C, M], [Filas, Columnas, Minas]),
    jugar(Filas, Columnas, Minas, Opciones, Codigo).
correr(_, _, _) :-
    throw(uso(argumentos)).

%!  jugar(+Filas:integer, +Columnas:integer, +Minas:integer,
%!        +Opciones:list, -Codigo:integer) is det.
%
%   Juega en la terminal una partida de Filas por Columnas con Minas, con
%   la semilla de Opciones. Codigo es 0 si la partida se gana y 1 si se
%   pierde.
jugar(Filas, Columnas, Minas, Opciones, Codigo) :-
    option(semilla(Semilla), Opciones, 0),
    nueva_partida(Filas, Columnas, Minas, Semilla, Partida),
    prompt(_, ''),
    jugar_en_terminal(user_input, Partida, Estado),
    (   Estado == gano
    ->  Codigo = 0
    ;   Codigo = 1
    ).
```

Como el servicio del [capítulo 30](../capitulo-30-servicios-web-rest/index.md), el programa espera con `thread_get_message/1` mientras los hilos del servidor atienden los pedidos; el [capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md) presenta los hilos y sus colas de mensajes.

La opción se declara con el tipo
`oneof([principiante, intermedio, experto])`: `argv_options/3` rechaza
cualquier otro valor con su propio mensaje, y el programa no necesita
validarlo. Los tableros son hechos, `nivel/4`, y no casos dentro de
`correr/3`: agregar un nivel es agregar un hecho y su nombre en el tipo. La
partida misma, que antes estaba en la cláusula de los tres números, pasa a
`jugar/5`, que las dos cláusulas comparten.

```text
$ swipl soluciones_buscaminas.pl --nivel=experto
$ swipl soluciones_buscaminas.pl --nivel=facil
ERROR: Option --nivel=facil requires one of principiante, intermedio, experto (found facil)
```
