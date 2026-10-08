# Capítulo 31 — Ejecutables y distribución

Hasta aquí, cada programa del curso se ejecuta con `swipl` delante:
`swipl contar.pl archivo.txt` carga el fuente, lo compila y recién entonces
lo ejecuta. Quien lo usa necesita SWI-Prolog instalado, el fuente completo y
sus archivos de datos, en los lugares donde el programa los busca. Este
capítulo convierte el programa en algo que se entrega: un **programa
guardado**, que ya está compilado y se ejecuta con un comando; un servicio que
el sistema operativo arranca y vuelve a arrancar; una **imagen de
contenedor**, que lleva el sistema de Prolog con el programa; y un **pack**,
la forma en que se distribuye una biblioteca de SWI-Prolog.

El proyecto se entrega de las tres primeras maneras, y el Buscaminas, armado
con las piezas de los capítulos anteriores, queda completo: se juega en la
terminal, se ofrece como servicio y se construye como programa. El capítulo
cierra la parte II.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- construir un programa guardado en Windows y en Linux, y decir qué necesita
  para ejecutarse en otra máquina;
- construir todos los programas de un proyecto con un solo comando, y
  probar lo construido;
- incluir en el programa los datos que necesita;
- ejecutar un servicio con systemd y dentro de un contenedor de Docker;
- numerar las versiones de un programa y distribuir una biblioteca como pack.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:04 h**.
    Resolver los 6 ejercicios marcados con ★: **1:53 h**.
    Resolver los 12 ejercicios del final: **3:22 h**.

## 31.1 Qué es un programa guardado

Cuando `swipl` carga un programa, lo compila a una representación interna:
las cláusulas, los módulos, los ajustes, las bibliotecas que el programa usa.
Un **programa guardado** —*saved state*, en la documentación de SWI-Prolog—
es esa representación escrita en un archivo. Ejecutarlo no vuelve a leer el
fuente: el sistema carga el archivo y llama al objetivo de arranque, el
`main` que declara `:- initialization(main, main)`.

`swipl -o Salida -c Programa` carga `Programa` y guarda el resultado en
`Salida`; por debajo, llama a `qsave_program/2`. El `contar.pl` del
[capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md), sin cambios, se construye así:

```text
$ swipl -q -o contar.state -c contar.pl --stand_alone=false
$ swipl -x contar.state -- archivos/texto.txt
       4       5  archivos/texto.txt
```

La opción `-x` le indica a `swipl` que cargue un programa guardado en lugar
del sistema predeterminado, y `--` separa los argumentos de `swipl` de los del
programa. El resultado es el mismo que el del fuente, y también los códigos
de salida: sin argumentos, el programa guardado termina con el código 1, como
`contar.pl`.

La opción `--stand_alone` decide qué lleva el archivo:

| `--stand_alone` | El archivo lleva | Se ejecuta con |
|---|---|---|
| `false` | el programa | `swipl -x programa.state -- argumentos` |
| `true` | el programa y el ejecutable de `swipl` | `./programa argumentos`, directamente |

Un programa guardado lleva el programa y las bibliotecas de Prolog que
cargó, pero no lleva:

- los archivos que el programa lee al ejecutarse: los que recibe como
  argumento, los de datos que abre con `open/3`;
- las bibliotecas compiladas en C que usan algunas bibliotecas de Prolog,
  como las de HTTP, de SSL o de expresiones regulares: son archivos `.dll` o
  `.so` de la instalación, que se cargan cuando el programa las necesita;
- con `--stand_alone=true`, la biblioteca compartida de SWI-Prolog,
  `libswipl`, y las que ella usa.

Un programa guardado es además propio de la versión de SWI-Prolog que lo
construyó: otra versión de `swipl` no lo carga. Las secciones siguientes
muestran qué consecuencias tiene cada punto en Windows y en Linux.

## 31.2 Windows

En Windows, `swipl -o contar -c contar.pl` produce `contar.exe`, un
ejecutable autónomo. Se ejecuta sin `swipl` delante, pero sigue necesitando
las bibliotecas de SWI-Prolog —`libswipl.dll` y las que ella usa—, que
están en el directorio `bin` de la instalación: funciona en una máquina con
SWI-Prolog instalado y en el `PATH`, o copiando esas bibliotecas junto al
ejecutable.

Hay además un obstáculo práctico: muchos antivirus bloquean los ejecutables
que produce SWI-Prolog. El archivo es el ejecutable de `swipl` con el
programa agregado al final, y no está firmado: para un antivirus, es un
programa desconocido que se modificó. El resultado habitual es que el
archivo desaparece apenas se construye, enviado a cuarentena.

Por eso este curso, en Windows, construye programas guardados con
`--stand_alone=false` y los acompaña de un **lanzador**, un archivo `.bat` de
una línea que ejecuta `swipl -x` con los argumentos que recibe:

```text
@swipl -x "%~dp0contar.state" -- %*
```

`%~dp0` es el directorio del propio `.bat`, y `%*`, sus argumentos: el
lanzador funciona desde cualquier directorio. Con `contar.bat` y
`contar.state` en un directorio del `PATH`, el programa se ejecuta como
cualquier otro:

```text
C:\curso> contar archivos\texto.txt
       4       5  archivos\texto.txt
```

Lo que se entrega son los dos archivos, y la máquina que los ejecuta
necesita SWI-Prolog instalado, en la misma versión.

## 31.3 Linux

En Linux, `swipl -o contar -c contar.pl` produce `contar`, un archivo
ejecutable que empieza con unas líneas de `sh`: un script que llama al `swipl`
instalado con el programa guardado que sigue a esas líneas. Con
`--stand_alone=true`, en cambio, el archivo es un ejecutable del sistema, que
lleva el de `swipl` adentro:

```text
$ swipl -q -o contar -c contar.pl --stand_alone=true
$ ./contar archivos/texto.txt
       4       5  archivos/texto.txt
```

Ese ejecutable no necesita `swipl` en el `PATH`, pero sí la biblioteca
compartida `libswipl.so` y las que ella usa —la de enteros grandes, `libgmp`,
entre otras—, y un programa que usa HTTP necesita además las bibliotecas en
C de la instalación. En una máquina sin SWI-Prolog, no arranca. Para llevar
un programa a una máquina que no tiene SWI-Prolog, la forma segura es un
contenedor, en la [sección 31.5](#315-un-contenedor).

Un servicio, como el del [capítulo 30](../capitulo-30-servicios-web-rest/index.md), tiene que estar funcionando
siempre: arrancar cuando arranca la máquina, y volver a arrancar si termina
por un error. En la mayoría de las distribuciones de Linux, eso lo hace
**systemd**, que lee la descripción de cada servicio de un archivo de
**unidad**:

<!-- ejemplo: capitulo-31/inscripciones/inscripciones.service fragmento: [Unit] .. WantedBy=multi-user.target -->
```ini
[Unit]
Description=Inscripciones, el servicio web del curso de Prolog
After=network.target

[Service]
Type=simple
User=inscripciones
WorkingDirectory=/opt/inscripciones/inscripciones
ExecStart=/usr/bin/swipl servicio.pl --puerto=8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

`After=network.target` lo arranca después de la red; `User` lo ejecuta con un
usuario sin privilegios, que no puede modificar el resto del sistema;
`Restart=on-failure` lo vuelve a arrancar si termina con un código distinto
de 0. El servicio no necesita convertirse en demonio ni escribir en un
archivo de registro propio: systemd lo mantiene en ejecución y guarda lo que
escribe, que se consulta con `journalctl -u inscripciones`. Se instala así:

```text
$ sudo cp inscripciones.service /etc/systemd/system/
$ sudo systemctl daemon-reload
$ sudo systemctl enable --now inscripciones
```

### Construir en un comando

Los comandos de construcción son distintos en cada sistema, y los de un
proyecto con varios programas se repiten para cada uno. `construir.pl` los
reúne: recibe los programas y construye cada uno como corresponde al sistema
en que se ejecuta.

<!-- ejemplo: capitulo-31/construir.pl predicado: construir/2 destino/4 lanzador/3 texto_del_lanzador/2 -->
```prolog
%!  construir(+Directorio:atom, +Programa:atom) is det.
%
%   Construye Programa en Directorio y escribe lo que construyó. Lo que el
%   swipl que construye escribe en su salida de errores se repite en la
%   propia, o forma parte del error si la construcción falla.
%
%   @error construccion(Programa, Estado, Mensajes) si el swipl que
%          construye no termina con el código 0.
construir(Directorio, Programa) :-
    make_directory_path(Directorio),
    file_base_name(Programa, Archivo),
    file_name_extension(Nombre, _, Archivo),
    directory_file_path(Directorio, Nombre, Base),
    sistema(Sistema),
    destino(Sistema, Base, Salida, Autonomo),
    format(atom(OpcionAutonomo), "--stand_alone=~w", [Autonomo]),
    process_create(path(swipl), ['-q', '-o', Salida, '-c', Programa,
                                 OpcionAutonomo],
                   [stderr(pipe(Err)), process(Pid)]),
    read_string(Err, _, Mensajes),
    close(Err),
    process_wait(Pid, Estado),
    (   Estado == exit(0)
    ->  format(user_error, "~s", [Mensajes])
    ;   throw(construccion(Programa, Estado, Mensajes))
    ),
    lanzador(Sistema, Base, Nombre),
    format("~w -> ~w~n", [Programa, Salida]).

%!  destino(+Sistema:atom, +Base:atom, -Salida:atom, -Autonomo:boolean)
%!      is det.
%
%   Salida es el archivo que se construye a partir de Base en Sistema, y
%   Autonomo dice si lleva el sistema de Prolog adentro: en Linux, un
%   ejecutable autónomo; en Windows, un estado guardado, Base.state, que se
%   ejecuta con swipl -x.
destino(windows, Base, Salida, false) :-
    atom_concat(Base, '.state', Salida).
destino(unix, Base, Base, true).

%!  lanzador(+Sistema:atom, +Base:atom, +Nombre:atom) is det.
%
%   En Windows, escribe Base.bat, que ejecuta el estado guardado con los
%   argumentos que recibe. En Linux no hace falta.
lanzador(unix, _, _).
lanzador(windows, Base, Nombre) :-
    texto_del_lanzador(Nombre, Texto),
    atom_concat(Base, '.bat', Bat),
    setup_call_cleanup(open(Bat, write, Stream, [encoding(utf8)]),
                       write(Stream, Texto),
                       close(Stream)).

%!  texto_del_lanzador(+Nombre:atom, -Texto:string) is det.
%
%   Texto es el contenido de Nombre.bat: %~dp0 es el directorio del propio
%   .bat, y %* son sus argumentos.
texto_del_lanzador(Nombre, Texto) :-
    format(string(Texto), "@swipl -x \"%~~dp0~w.state\" -- %*~n", [Nombre]).
```

`make_directory_path/1` crea el directorio de destino, con los directorios
intermedios que falten, si todavía no existe.

Cada programa se construye en otro proceso de `swipl`, con
`process_create/3` del [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md): si `construir.pl` cargara los
programas y los guardara él mismo, el constructor quedaría guardado con
ellos. Lo que ese proceso escribe como error se lee de un *pipe* y forma
parte del error de la construcción, de modo que un programa que no carga
produce un mensaje que dice cuál y por qué:

```text
$ swipl construir.pl -- contar.pl refranes.pl
contar.pl -> salida/contar.state
refranes.pl -> salida/refranes.state
$ swipl construir.pl -- noexiste.pl
ERROR: No se pudo construir noexiste.pl: swipl terminó con exit(1)
ERROR: source_sink `'noexiste.pl'' does not exist
```

El `--` después de `construir.pl` es necesario: sin él, `swipl` toma cada
argumento terminado en `.pl` como otro archivo que debe cargar, y carga los
programas junto con el constructor, en lugar de pasárselos.

Las pruebas de `construir.plt` no se limitan a lo que decide `destino/4`:
construyen `contar.pl` en un directorio temporal, ejecutan lo
construido, y verifican que responde lo mismo y termina con el mismo código
que el fuente. La integración continua del curso las ejecuta en Linux, donde
construyen el ejecutable autónomo.

!!! example "Patrón 42 — Construir en un comando"
    **Problema.** Un programa que se entrega tiene que construirse igual cada
    vez, en cada sistema, y lo construido tiene que comportarse como el
    fuente.

    **Versión ingenua.** Escribir uno por uno los comandos de construcción en
    cada máquina, o anotarlos en un archivo de instrucciones, y probar el
    fuente pero nunca lo construido.

    **Patrón.** Un programa, `construir.pl`, recibe los programas y construye
    cada uno en otro proceso de `swipl`, con las opciones que corresponden al
    sistema. Un error de construcción es un error del constructor, con los
    mensajes del proceso que falló. Las pruebas construyen el programa en un
    directorio temporal y ejecutan lo construido con los mismos argumentos
    que el fuente: la batería del proyecto incluye lo que se entrega.

    **Cuándo no usarlo.** Para un programa que solo se ejecuta desde el
    fuente, en la máquina de quien lo escribe: `swipl programa.pl` alcanza.

!!! question "Actividad"
    Construir `contar.pl` con `construir.pl` y ejecutar lo construido desde
    otro directorio. Después, cambiar el texto de ayuda de `contar.pl` y
    ejecutar otra vez lo construido con `-h`: ¿qué ayuda aparece? ¿Qué hace
    falta para que aparezca la nueva?

## 31.4 Recursos dentro del ejecutable

Un programa que necesita datos propios —una tabla, un diccionario, un
texto— tiene que llevarlos consigo: si los lee de un archivo al ejecutarse,
el archivo tiene que viajar con él y estar donde el programa lo busca.
SWI-Prolog tiene un mecanismo para eso, los **recursos**: `resource/2`
declara un archivo que se guarda dentro del programa, y `open_resource/3` lo
abre. En SWI-Prolog 9.2.9, sin embargo, `open_resource/3` produce un error
cuando se ejecuta dentro de un programa guardado, en Windows y en Linux: el
mecanismo funciona desde el fuente, pero no en lo construido, que es donde
se lo necesita.

Hay una forma más simple, que no depende de ese mecanismo: leer los datos
**al cargar** el programa y guardarlos como hechos. Un programa guardado
guarda los hechos con el resto del programa, y el archivo de datos ya no hace
falta. `refranes.pl` lee `archivos/refranes.txt` con una directiva:

<!-- ejemplo: capitulo-31/refranes.pl predicado: cargar_refranes/1 -->
```prolog
%!  cargar_refranes(+Archivo) is det.
%
%   Reemplaza los hechos refran/2 por las líneas no vacías de Archivo,
%   numeradas desde 1.
cargar_refranes(Archivo) :-
    retractall(refran(_, _)),
    read_file_to_string(Archivo, Texto, [encoding(utf8)]),
    split_string(Texto, "\n", "\r", Lineas0),
    exclude(==(""), Lineas0, Lineas),
    forall(nth1(N, Lineas, Linea),
           assertz(refran(N, Linea))).
```

<!-- ejemplo: capitulo-31/refranes.pl fragmento: % Se ejecuta al cargar .. cargar_refranes(Archivo). -->
```prolog
% Se ejecuta al cargar el archivo, y por lo tanto al construir el programa.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, 'archivos/refranes.txt', Archivo),
   cargar_refranes(Archivo).
```

`prolog_load_context(directory, Aqui)` es el directorio del archivo que se
está cargando: el archivo de datos se busca junto al fuente, y no en el
directorio desde el que se ejecuta `swipl`. El `retractall/1` hace que cargar
dos veces no duplique los refranes. Construido, el programa responde sin el
archivo:

```text
$ swipl construir.pl -- refranes.pl
refranes.pl -> salida/refranes.state
$ mv archivos/refranes.txt /tmp/
$ salida/refranes 2
El que busca encuentra.
```

La prueba `sin_el_archivo` de `refranes.plt` hace exactamente eso: construye
en un directorio temporal, borra el archivo de datos y ejecuta lo construido.
La técnica sirve para los datos que forman parte del programa. Los que el
usuario cambia —el estado de las inscripciones, un archivo de ajustes—
siguen siendo archivos externos, que el programa recibe como argumento.

## 31.5 Un contenedor

Un **contenedor** es un proceso que se ejecuta con su propio sistema de
archivos, aislado del resto de la máquina. Ese sistema de archivos sale de
una **imagen**: un sistema operativo mínimo, con lo que el programa
necesita instalado. Docker construye la imagen a partir de un `Dockerfile`,
que parte de otra imagen y agrega archivos y comandos. La imagen oficial
`swipl` trae SWI-Prolog instalado, con todas sus bibliotecas; la del servicio
de *Inscripciones* le agrega el programa:

<!-- ejemplo: capitulo-31/inscripciones/Dockerfile fragmento: FROM swipl .. CMD -->
```dockerfile
FROM swipl:9.2.9

WORKDIR /app
COPY inscripciones/*.pl ./
COPY archivos/ /archivos/

EXPOSE 8080
CMD ["swipl", "servicio.pl", "--puerto=8080", "--publico"]
```

`FROM` elige la imagen de partida, con la misma versión de SWI-Prolog que usa
el curso; `COPY` copia el programa y sus datos; `CMD` es el comando que
ejecuta el contenedor al arrancar. La imagen se construye desde
`ejemplos/capitulo-31`, que tiene el programa y el directorio `archivos`, y
el contenedor se ejecuta publicando su puerto 8080 en el 8080 de la máquina:

```text
$ docker build -t inscripciones -f inscripciones/Dockerfile .
$ docker run --rm -p 8080:8080 inscripciones
% Started server at http://localhost:8080/
Inscripciones en http://localhost:8080/
```

Desde otra terminal, `curl http://localhost:8080/ranking` responde como en el
[capítulo 30](../capitulo-30-servicios-web-rest/index.md). La opción `--publico` es nueva: dentro del contenedor,
`localhost` es el propio contenedor, y un servidor que solo acepta pedidos
de `localhost` no recibe los que Docker reenvía desde afuera. `iniciar_api/2`
elige a qué interfaces se liga el servidor:

<!-- ejemplo: capitulo-31/inscripciones/api.pl predicado: iniciar_api/2 -->
```prolog
%!  iniciar_api(?Puerto:integer, +Alcance:atom) is det.
%
%   Como iniciar_api/1, con Alcance local, que solo acepta pedidos de la
%   misma máquina, o publico, que los acepta de cualquier interfaz de red:
%   el que necesita el servicio dentro de un contenedor.
iniciar_api(Puerto, local) :-
    iniciar_api(Puerto).
iniciar_api(Puerto, publico) :-
    http_server([port(Puerto)]).
```

`port(Puerto)`, sin `localhost:`, acepta pedidos de cualquier interfaz. Fuera
de un contenedor, `--publico` expone el servicio a la red, y conviene no
usarlo sin necesidad.

La imagen ocupa unos 390 MB, casi todos de SWI-Prolog y del sistema
operativo, y se ejecuta igual en cualquier máquina con Docker: Linux,
Windows o macOS. Es la forma más segura de entregar un programa a una máquina
que no tiene SWI-Prolog, y la versión de SWI-Prolog queda fija en la línea
`FROM`.

## 31.6 Versiones y packs

Un programa que se entrega más de una vez necesita un número de **versión**,
para que quien lo usa sepa qué tiene y qué cambió. La convención más usada,
el **versionado semántico**, escribe tres números, `mayor.menor.corrección`:

| Cambia | Cuando la versión nueva | Ejemplo |
|---|---|---|
| corrección | corrige errores, sin cambiar lo que el programa ofrece | `1.0.0` → `1.0.1` |
| menor | agrega algo, y lo anterior sigue funcionando igual | `1.0.1` → `1.1.0` |
| mayor | cambia o quita algo, y quien lo usa puede tener que adaptarse | `1.1.0` → `2.0.0` |

SWI-Prolog numera así sus propias versiones, y las informa con la bandera
`version`, como un entero:

```prolog
?- current_prolog_flag(version, V).
V = 90209.
```

`90209` es la versión 9.2.9. Un programa guardado solo se ejecuta con la
versión que lo construyó, de modo que la versión de SWI-Prolog forma parte
de lo que se entrega: la imagen de Docker la fija en `FROM`, y el lanzador
de Windows, en la instalación de la máquina.

Una biblioteca de Prolog se distribuye como **pack**: un directorio con un
archivo de descripción, `pack.pl`, y los módulos en un subdirectorio
`prolog/`. `paquete/fechas_castellano/` convierte los cálculos con fechas del
[capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) en un pack:

```text
paquete/fechas_castellano/
    pack.pl
    prolog/
        fechas_castellano.pl
```

<!-- ejemplo: capitulo-31/paquete/fechas_castellano/pack.pl fragmento: name(fechas_castellano). .. author( -->
```prolog
name(fechas_castellano).
version('1.0.0').
title('Fechas en castellano: calculos con fechas y nombres propios').
author('Curso de Prolog', 'https://katra.ballardini.com.ar/curso-de-prolog/').
```

`pack.pl` solo admite esos hechos de descripción: `pack_install/2` rechaza
cualquier otro término, incluida la directiva `:- encoding(utf8).`, y por eso
sus textos no llevan tildes. El pack se empaqueta como un archivo
`fechas_castellano-1.0.0.tgz` —el nombre y la versión, separados por un
guion— y se instala desde ese archivo:

```text
$ tar czf fechas_castellano-1.0.0.tgz -C paquete fechas_castellano
$ swipl -g "pack_install('fechas_castellano-1.0.0.tgz', [interactive(false)])" -t halt
```

Instalado, cualquier programa lo carga como una biblioteca de SWI-Prolog, con
`use_module(library(fechas_castellano))`, desde cualquier directorio.
`pack_list_installed/0` muestra los packs instalados, y `pack_remove/1`
quita uno. Los packs publicados en el sitio de SWI-Prolog se instalan por su
nombre, con `pack_install(Nombre)`.

## 31.7 Archivos `.qlf`, en una nota

Entre el fuente y el programa guardado hay un punto intermedio: un archivo
**`.qlf`** —*quick load file*— es un archivo fuente ya compilado, que se
carga más rápido que el `.pl`. `qcompile(contar)` escribe `contar.qlf`, que
se ejecuta como el fuente, con `swipl contar.qlf archivos/texto.txt`. A
diferencia de un programa guardado, un `.qlf` es un solo archivo del
programa, no el programa completo con sus bibliotecas, y como él, solo lo
carga la versión de SWI-Prolog que lo compiló. Conviene para bibliotecas
grandes que se cargan muchas veces; el
[capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) vuelve sobre la compilación de programas.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C5 | un programa que no se puede construir produce un error de `construir.pl`, con los mensajes del `swipl` que falló, y el código de salida 2 |
    | C7 | las pruebas construyen los programas, ejecutan lo construido y lo comparan con el fuente: `contar.pl`, `refranes.pl` sin su archivo de datos y el programa del proyecto |

## 31.8 El proyecto: *Inscripciones* se entrega

*Inscripciones* se entrega de tres maneras. El programa de línea de comandos
del [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md), `principal.pl`, se construye con `construir.pl`, y
se ejecuta sin cargar el fuente:

```text
$ cd inscripciones
$ swipl ../construir.pl --salida=../salida -- principal.pl
principal.pl -> ../salida/principal
$ cd ..
$ salida/principal listar logica
Inscriptos: 101, 102, 104, 106.
```

En Windows, lo construido es `principal.state` con su lanzador,
`principal.bat`. Los datos del proyecto son hechos de sus módulos, y viajan
dentro del programa; el estado que cambia, con `--estado=ARCHIVO`, sigue
siendo un archivo externo. La prueba `proyecto` de `construir.plt` construye
`principal.pl` y verifica que `listar logica` responde lo mismo que el
fuente.

El servicio del [capítulo 30](../capitulo-30-servicios-web-rest/index.md) se entrega como imagen de Docker, con el
`Dockerfile` de la [sección 31.5](#315-un-contenedor), y en una máquina Linux con SWI-Prolog,
como servicio de systemd, con la unidad de la [sección 31.3](#313-linux). `servicio.pl`
suma la opción `--publico`, y `api.plt`, una prueba que arranca el servicio
con alcance público y le hace un pedido.

## 31.9 Buscaminas completo

El Buscaminas se armó por partes a lo largo del curso: el conteo de minas
vecinas en el [capítulo 17](../capitulo-17-todas-las-soluciones/index.md), el recorrido que descubre una región en el
[capítulo 18](../capitulo-18-orden-superior/index.md), el tablero como tabla de búsqueda en el [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md),
la deducción con restricciones en el [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md), los módulos en el
[capítulo 24](../capitulo-24-modulos-y-organizacion/index.md), el juego en la terminal en el [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) y el servicio en el
[capítulo 30](../capitulo-30-servicios-web-rest/index.md). `ejemplos/capitulo-31/buscaminas/` reúne esas piezas en un
programa completo, con un módulo por responsabilidad:

| Módulo | Hace |
|---|---|
| `vecinos` | las celdas vecinas y cuántas minas hay entre ellas |
| `tablero` | el tablero como assoc, con minas elegidas al azar con una semilla |
| `descubrir` | descubrir una región |
| `resolver` | deducir qué celdas ocultas son seguras |
| `partida` | el estado de una partida y sus jugadas, con errores ISO |
| `terminal` | el juego en la terminal, con el pedido de ayuda `?` |
| `servicio` | el juego por HTTP, con la ruta de la sugerencia |
| `buscaminas.pl` | el programa: lee los argumentos y elige |

El código completo, con sus pruebas, está en
[la página del Buscaminas completo](buscaminas.md). El núcleo —`vecinos`,
`tablero`, `descubrir`, `resolver`, `partida`— no escribe ni lee: la terminal
y el servicio son dos bordes sobre el mismo núcleo, y la deducción con restricciones del
[capítulo 23](../capitulo-23-programacion-con-restricciones/index.md) da, en los dos, la sugerencia de una celda segura. El programa
juega en la terminal, y termina con el código 0 si la partida se gana y con
1 si se pierde:

```text
$ swipl buscaminas.pl --semilla=7 3 3 1
     1  2  3
  1  #  #  #
  2  #  #  #
  3  #  #  #
Minas sin marcar: 1
Jugada (d F C, m F C, ?): d 1 1
     1  2  3
  1  .  1  *
  2  .  1  1
  3  .  .  .
Minas sin marcar: 1
Todas las celdas libres están descubiertas: partida ganada.
```

Con `--servicio`, ofrece el mismo juego por HTTP, y `cliente.py` juega contra
él desde Python. Construido con `construir.pl`, se ejecuta sin el fuente, en
la terminal y como servicio:

```text
$ cd buscaminas
$ swipl ../construir.pl -- buscaminas.pl
buscaminas.pl -> salida/buscaminas
$ salida/buscaminas --semilla=7 9 9 10
```

Las pruebas de `buscaminas.plt` ejecutan el fuente como proceso: juegan una
partida ganada y una perdida, verificando el código de salida de cada una, y
arrancan el servicio y le hacen un pedido.

!!! question "Actividad"
    Jugar una partida de 9 × 9 con 10 minas, pidiendo la sugerencia con `?`
    cada vez que no haya una jugada evidente. ¿En qué situaciones el
    módulo `resolver` no encuentra ninguna celda segura? ¿Significa eso que no la
    hay?

## 31.10 Cierre de la parte II

Con este capítulo termina la segunda parte del curso. La parte I enseñó el
lenguaje; la parte II, a escribir con él programas que otros usan. Los
contenidos cubiertos son:

- el entorno de trabajo: el toplevel, `make/0`, las pruebas con plunit, la
  depuración y la documentación con PlDoc;
- la escritura profesional de predicados: el estilo, el control, el
  rendimiento, los siete criterios de calidad y cuarenta y dos patrones;
- todas las soluciones, el orden superior, los operadores y las reglas como
  datos, la base de datos dinámica, las gramáticas y las estructuras de
  datos de la biblioteca;
- la programación con restricciones;
- los módulos, los errores y las excepciones, y el trabajo con archivos,
  streams y formatos;
- los programas de línea de comandos, Prolog desde Python, los servicios web
  y la entrega de programas.

*Inscripciones* recorrió ese camino completo: empezó como un archivo de
hechos y termina como un sistema en módulos, probado, que se usa desde la
línea de comandos, desde Python y por HTTP, y que se entrega construido, como
servicio y en un contenedor.

La parte III, «Lo avanzado», va del [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md) al
[42](../capitulo-42-prolog-y-sql/index.md). Los capítulos [32](../capitulo-32-inspeccion-de-terminos/index.md) a [35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) tratan los términos y los
programas como datos: la inspección de términos, la introspección y los
metaintérpretes, las estructuras incompletas y las listas diferencia, y la
transformación de programas y la compilación. El [36](../capitulo-36-interfaces-de-usuario/index.md) y el [37](../capitulo-37-concurrencia-y-paralelismo/index.md)
llevan los programas a las interfaces de usuario y a varios hilos. El [38](../capitulo-38-semantica-de-los-programas-logicos/index.md)
define la semántica de los programas lógicos y el [39](../capitulo-39-tabulacion/index.md) presenta la
tabulación. El [40](../capitulo-40-busqueda-y-planificacion/index.md) y el [41](../capitulo-41-juegos/index.md) tratan la búsqueda, la planificación y
los juegos, y el [42](../capitulo-42-prolog-y-sql/index.md) relaciona Prolog con SQL. Cada uno parte de lo que
las partes I y II dan por conocido.

La parte IV, «Proyectos», va del [capítulo 43](../capitulo-43-proyecto-resolver-ecuaciones/index.md) al [87](../capitulo-87-proyecto-preguntas-en-castellano/index.md):
cada capítulo construye un proyecto completo con las prácticas de esta
parte, y el 87 cierra el curso.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Construir `contar.pl` y `refranes.pl` con `construir.pl`.
   ¿Qué archivos deben copiarse a otra máquina para ejecutar cada uno, en
   Windows y en Linux? ¿Qué tiene que estar instalado en esa máquina?
2. **(1)** ¿Qué ocurre con `swipl construir.pl contar.pl`, sin el `--`? ¿Por
   qué el mensaje de error no es el de `construir.pl`?
3. ★ **(2)** Agregar a `contar.pl` la opción `--version`, que escribe
   `contar 1.0.0` y termina con el código 0. La versión es un hecho,
   `version/1`, y no un texto dentro de `main/1`.
4. ★ **(2)** Escribir `materias.pl`, que al cargarse lee
   `archivos/materias.json` y guarda cada materia como un hecho
   `materia(Codigo, Nombre, Anio)`. El programa recibe un código y escribe el
   nombre de la materia; con un código desconocido, termina con el código 1.
   Construido, tiene que funcionar sin el archivo JSON.
5. **(2)** Agregar a `construir.pl` la opción `--probar`: después de
   construir cada programa, lo ejecuta con `--help` y lanza un error si no
   termina con el código 0.
6. ★ **(2)** Escribir la prueba de plunit que construye `materias.pl` en un
   directorio temporal, borra la copia del archivo JSON y ejecuta lo
   construido con un código conocido y con uno desconocido.
7. **(2)** Escribir un `Dockerfile` para el Buscaminas como servicio. ¿Qué
   opciones de `buscaminas.pl` necesita el comando del contenedor, y por qué?
8. **(1)** Escribir la unidad de systemd del servicio del Buscaminas, en el
   puerto 8081. ¿Qué líneas cambian respecto de `inscripciones.service`?
9. ★ **(2)** Agregar al pack `fechas_castellano` el predicado `bisiesto/1`.
   ¿Qué número de versión corresponde a la entrega nueva? ¿Y a una entrega
   que cambiara el orden de los argumentos de `dias_entre/3`?
10. **(1)** Compilar `contar.pl` con `qcompile/1` y comparar `contar.qlf` con
    `contar.state`: ¿qué contiene cada uno, y qué necesita cada uno para
    ejecutarse?
11. ★ **(3)** En el proyecto, escribir la prueba de plunit que construye
    `principal.pl` y lo ejecuta dos veces con el mismo `--estado=ARCHIVO`:
    la primera inscribe a un alumno en una materia, y la segunda verifica,
    con `listar`, que la inscripción se conservó.
12. **(3)** Agregar a `buscaminas.pl` la opción `--nivel`, con los valores
    `principiante` (9 × 9 con 10 minas), `intermedio` (16 × 16 con 40) y
    `experto` (16 × 30 con 99), como alternativa a los tres números.

## Resumen

| | |
|---|---|
| `swipl -o Salida -c Programa` | construir un programa guardado; por debajo, `qsave_program/2` |
| `--stand_alone=true`, `false` | con o sin el ejecutable de `swipl` adentro |
| `swipl -x programa.state -- argumentos` | ejecutar un programa guardado |
| lanzador `.bat` | el programa guardado como comando, en Windows |
| unidad de systemd | un servicio que arranca con la máquina y se vuelve a arrancar |
| datos leídos al cargar | los datos del programa viajan dentro de lo construido |
| `resource/2`, `open_resource/3` | los recursos de SWI-Prolog; en 9.2.9 no funcionan dentro de un programa guardado |
| `Dockerfile`, `docker build`, `docker run` | una imagen con SWI-Prolog y el programa |
| `mayor.menor.corrección` | el versionado semántico |
| `pack.pl`, `pack_install/2` | una biblioteca como pack |
| `qcompile/1`, `.qlf` | un archivo fuente ya compilado |
| `jugar/4` | una jugada del Buscaminas sobre una partida ([el módulo `partida`](buscaminas.md#partida)) |
| **[Patrón 42](../patrones.md#42-construir-en-un-comando)** | construir en un comando |
| `make_directory_path/1` | crea un directorio y los intermedios que falten |
| `make_directory/1`, `delete_directory_and_contents/1`, `exists_directory/1` | crear un directorio, borrarlo con su contenido, saber si existe; en las pruebas |
| `assoc_to_list/2` | los pares `Clave-Valor` de un assoc, ordenados por clave; en las pruebas |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La compilación de programas y la expansión de términos | [capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) |
| Una interfaz web sobre el servicio del Buscaminas | [capítulo 36](../capitulo-36-interfaces-de-usuario/index.md) |
| Los hilos que atienden los pedidos de un servicio | [capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md) |
| El Buscaminas como problema de búsqueda | [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) |
