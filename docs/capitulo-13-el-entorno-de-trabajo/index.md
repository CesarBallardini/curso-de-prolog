# Capítulo 13 — El entorno de trabajo

La parte I se pudo seguir entera en SWISH, sin instalar nada. La parte II trata
del trabajo profesional con Prolog, y ese trabajo ocurre en una instalación
local: un programa repartido en archivos, un editor que señala los errores
mientras se escribe, un toplevel abierto durante toda la sesión, pruebas que se
ejecutan en cada cambio y una revisión antes de entregar.

Este capítulo arma ese entorno. Presenta el toplevel de SWI-Prolog como
herramienta de trabajo, configura dos editores —Visual Studio Code y Emacs— con
el mismo servidor de lenguaje, muestra cómo se verifica un programa antes de
entregarlo, y crea el proyecto que acompaña a toda la parte II: *Inscripciones*,
un sistema de inscripción a las materias de una carrera.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- instalar SWI-Prolog 9.2.9 en Windows o en Linux, y configurar el arranque con
  `init.pl`;
- usar el toplevel como herramienta: recargar con `make/0`, consultar el código
  con `listing/1`, buscar en el manual con `apropos/1` y `help/1`;
- configurar Visual Studio Code o Emacs para programar en Prolog, con
  diagnósticos del servidor de lenguaje;
- verificar un programa antes de entregarlo con `run_tests/0` y `check/0`, y
  automatizar esa verificación con un gancho de git.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:06 h**.
    Resolver los 6 ejercicios marcados con ★: **1:12 h**.
    Resolver los 12 ejercicios del final: **3:05 h**.

## 13.1 El toplevel como herramienta

### Instalación

El curso usa **SWI-Prolog 9.2.9**, la versión con la que se verificaron todos
los ejemplos:

- **Windows**: el instalador `swipl-9.2.9-1.x64.exe`, de la sección *Download* del
  sitio de SWI-Prolog (versiones anteriores de la rama estable). Durante la
  instalación conviene aceptar la opción que agrega `swipl` a la variable `PATH`.
- **Linux**: Ubuntu 26.04 la trae en sus repositorios. `sudo apt install
  swi-prolog` instala la versión completa; `swi-prolog-nox`, la versión sin
  interfaz gráfica.

La versión instalada se comprueba desde una terminal con `swipl --version`.

### Recargar sin salir

En la parte I cada ejemplo se cargaba una vez y se consultaba. En el trabajo
diario el toplevel queda abierto mientras el programa cambia, y la forma de
incorporar los cambios es `make/0`: recarga **solo** los archivos modificados
desde la última carga, sin perder la sesión.

Un archivo se carga con `consult/1` o con su forma abreviada entre corchetes;
la extensión `.pl` se puede omitir:

<!-- ejemplo: capitulo-13/revision.pl predicado: abuelo/2 nieto/2 consulta: abuelo(juan, Quien). -->
```prolog
%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

%!  nieto(?N, ?A) is nondet.
%
%   N es nieto de A, y es una persona registrada.
nieto(N, A) :-
    abuelo(A, N),
    persona(N).
```

```prolog
?- [revision].
```

```prolog
?- abuelo(juan, Quien).
Quien = luis ;
Quien = eva.
```

Si en el editor se agrega al final del archivo el hecho `padre(ana, sofia).` y se
guarda, `make.` lo incorpora. La salida resume lo que hizo:

```prolog
?- make.
```

```text
Warning: .../revision.pl:30:
Warning:    Clauses of padre/2 are not together in the source-file
Warning:    Earlier definition at .../revision.pl:12
Warning:    Current predicate: nieto/2
Warning:    Use :- discontiguous padre/2. to suppress this message
% .../revision compiled 0.00 sec, 1 clauses
Warning: The predicates below are not defined. If these are defined
Warning: at runtime using assert/1, use :- dynamic Name/Arity.
Warning:
Warning: persona/1, which is referenced by
Warning:        .../revision.pl:29:4: 1-st clause of nieto/2
true.
```

La salida tiene tres partes. La primera advertencia es consecuencia de la
edición: el hecho nuevo quedó lejos de los otros hechos de `padre/2`, y
SWI-Prolog lo señala porque las cláusulas de un predicado separadas suelen ser
un error de tipeo. La línea con `%` informa que se recompiló el archivo. La
última advertencia no tiene que ver con la edición: al terminar, `make/0`
revisa los predicados que se llaman y no están definidos en ninguna parte, y
encuentra `persona/1`, que `nieto/2` llama. La [sección 13.5](#135-verificar-antes-de-entregar) vuelve sobre esa
revisión.

### Ver el código cargado

`listing/1` escribe las cláusulas de un predicado tal como están cargadas, con
la disposición de `portray_clause/1` del [capítulo 11](../capitulo-11-texto/index.md):

```prolog
?- listing(abuelo/2).
```

```text
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

true.
```

Sirve para confirmar qué versión de un predicado está cargada después de varios
`make.`, y para ver los hechos agregados durante la ejecución, que no están en
ningún archivo.

### Buscar en el manual

El manual de SWI-Prolog está disponible desde el toplevel. `apropos/1` busca por
palabra en los nombres y las descripciones; `help/1` muestra la entrada de un
predicado:

```prolog
?- apropos(atom_length).
```

```text
% ISO atom_length/2          True if Atom is an atom of Length characters.
% ISO atom_chars/2           Similar to atom_codes/2, but CharList is a list ...
% ISO number_chars/2         Similar to atom_chars/2, but converts between a ...
...
true.
```

```prolog
?- help(atom_length/2).
```

```text
atom_length(+Atom, -Length)                                            [ISO]
    True if Atom is  an atom  of Length  characters. The  SWI-Prolog version
    accepts all atomic types, as well as code-lists and character-lists.
    ...
true.
```

La primera línea de la entrada usa la notación de modos de la
[sección 2.8](../capitulo-02-hechos-consultas-y-variables/index.md#28-como-se-documenta-el-uso-de-un-predicado): `atom_length(+Atom, -Length)` dice que el átomo debe llegar ligado y
que la longitud es de salida. Es la misma notación que usan todos los
encabezados del curso.

### El archivo de inicio

Al arrancar, SWI-Prolog carga un archivo de inicio si existe:
`%APPDATA%\swi-prolog\init.pl` en Windows y `~/.config/swi-prolog/init.pl` en
Linux. Es el lugar de las preferencias personales, que no pertenecen a ningún
programa.

Una preferencia útil es el editor que abre `edit/1`. `edit(abuelo)` abre el
archivo donde está definido `abuelo/2`, en la línea de su primera cláusula, y
al cerrarse el editor ejecuta `make/0`. Por defecto usa el editor de la
variable de entorno `EDITOR`, o el Bloc de notas en Windows. El siguiente
`init.pl` lo cambia por Visual Studio Code:

<!-- ejemplo: capitulo-13/init.pl archivo -->
```prolog
:- set_prolog_flag(editor, code).

:- multifile prolog_edit:edit_command/2.

%!  prolog_edit:edit_command(+Editor, -Comando) is nondet.
%
%   Comando es la línea de comandos que abre Editor en un archivo y una
%   línea: %e es el editor, %f el archivo y %d la línea. --wait hace que
%   edit/1 espere a que el archivo se cierre antes de ejecutar make/0.
prolog_edit:edit_command(code, '"%e" --wait --goto "%f:%d"').
```

`edit/1` no conoce la línea de comandos de Visual Studio Code, y el archivo se
la indica agregando una cláusula a `prolog_edit:edit_command/2`, un predicado
de la biblioteca de edición declarado para eso. `--goto` abre el archivo en la
línea del predicado, y `--wait` hace que el comando espere a que se cierre el
archivo: sin esa opción, `edit/1` ejecutaría `make/0` inmediatamente, antes de
cualquier cambio.

!!! question "Actividad"
    Cargar `revision.pl`, ejecutar `listing(padre/2).` y después `make.` sin
    haber modificado nada. Predecir antes qué informa `make.` en ese caso, y
    explicar por qué vuelve a aparecer la advertencia sobre `persona/1`.

## 13.2 Visual Studio Code

Visual Studio Code no trae soporte para Prolog, y además asocia la extensión
`.pl` a Perl. La configuración tiene tres partes: un perfil propio, la extensión
cliente y el servidor de lenguaje.

**Un perfil para Prolog.** Un perfil de Visual Studio Code es un conjunto
separado de extensiones y de preferencias. Conviene crear uno para Prolog
(*Archivo › Preferencias › Perfiles › Nuevo perfil*, con el nombre `Prolog`),
de modo que la configuración de este capítulo no se mezcle con la de otros
lenguajes. Todo lo que sigue se hace con ese perfil activo.

**La extensión.** El cliente es la extensión `prolog-lsp`, publicada junto con
el servidor de lenguaje `lsp_server` en su repositorio de GitHub
(`jamesnvc/lsp_server`, sección *Releases*), como archivo
`prolog-lsp-2.2.7.vsix`. Se instala desde la vista de extensiones, con
*Instalar desde VSIX…*, o desde una terminal:

```text
code --profile Prolog --install-extension prolog-lsp-2.2.7.vsix
```

La extensión no tiene opciones: arranca `swipl` desde el `PATH` y le pide que
cargue `library(lsp_server)`.

**La asociación de archivos.** En las preferencias del perfil (*Preferencias:
abrir configuración de usuario (JSON)*) se declara que `.pl` y `.plt` son
Prolog, y no Perl:

```json
{
    "files.associations": {
        "*.pl": "prolog",
        "*.plt": "prolog"
    }
}
```

**El servidor de lenguaje.** `lsp_server` es un paquete (*pack*) de
SWI-Prolog, que se instala desde el toplevel. La versión 3.17.0, la más reciente
al escribir este capítulo, no funciona con SWI-Prolog 9.2.9: usa una biblioteca
de JSON que recién existe en versiones posteriores. La versión 3.16.0 funciona,
y se instala indicando su dirección:

```prolog
?- pack_install(lsp_server, [url('https://github.com/jamesnvc/lsp_server/archive/refs/tags/v3.16.0.zip')]).
```

El mismo servidor atiende a Visual Studio Code, a Emacs y a otros editores. Con
él, el editor subraya las variables que aparecen una sola vez en una cláusula
—la advertencia *singleton variables* que la [sección 3.4](../capitulo-03-reglas-y-conjunciones/index.md#34-el-alcance-de-una-variable-es-la-clausula) mostraba al cargar—
mientras se escribe, y ofrece ir a la definición de un predicado, buscar sus
usos, mostrar su documentación al pasar el cursor y completar nombres.

**La terminal integrada.** Visual Studio Code incluye una terminal (*Ver ›
Terminal*). Con `swipl` abierto en ella, el ciclo de trabajo queda en una sola
ventana: editar arriba, `make.` abajo.

!!! question "Actividad"
    En una copia de `revision.pl`, cambiar la variable `N` de la cabeza de
    `abuelo/2` por `Nieto`, sin cambiarla en el cuerpo. Antes de guardar,
    observar qué subraya el editor, y comparar el mensaje con la advertencia que
    muestra `[revision].` al cargar la copia.

## 13.3 Emacs

Emacs ofrece tres modos para Prolog, de menor a mayor integración:

- **`prolog-mode`**, incluido en Emacs: coloreo y sangría.
- **sweep** (paquete `sweeprolog`): SWI-Prolog cargado *dentro* de Emacs, como
  una biblioteca. Colorea con el analizador de SWI-Prolog, muestra la
  documentación, marca los errores, y ofrece un toplevel dentro de Emacs
  (`M-x sweeprolog-top-level`). Requiere Emacs 27 o posterior y el módulo
  `sweep-module`, que se distribuye con SWI-Prolog: el instalador de Windows y
  los paquetes de Ubuntu lo incluyen.
- **ediprolog**: evalúa, desde el archivo fuente, las consultas escritas en
  comentarios que empiezan con `%?-`, y escribe las respuestas debajo. Los
  ejemplos del curso llevan esas consultas en su encabezado.

El siguiente archivo de configuración instala los dos paquetes la primera vez
que se inicia Emacs, asocia `.pl` y `.plt` a `sweeprolog-mode` —Emacs también
los asocia a Perl de fábrica— y asigna la tecla F10 a ediprolog. Va en
`~/.emacs.d/init.el`:

```elisp
;; Paquetes de GNU ELPA y de NonGNU ELPA, donde está sweeprolog. Emacs 28 y
;; posteriores ya incluyen NonGNU ELPA; la línea add-to-list hace falta en 27.
(require 'package)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
(package-initialize)
(dolist (paquete '(sweeprolog ediprolog))
  (unless (package-installed-p paquete)
    (unless package-archive-contents (package-refresh-contents))
    (package-install paquete)))

;; sweep: SWI-Prolog dentro de Emacs. Los archivos .pl y .plt se abren en
;; sweeprolog-mode, y no en perl-mode, que Emacs asocia a .pl de fábrica.
(require 'sweeprolog)
(add-to-list 'auto-mode-alist '("\\.plt?\\'" . sweeprolog-mode))

;; ediprolog: F10 sobre una línea %?- evalúa la consulta y escribe las
;; respuestas debajo, en el mismo archivo.
(require 'ediprolog)
(global-set-key [f10] 'ediprolog-dwim)
```

Para los diagnósticos del servidor de lenguaje, el mismo `lsp_server` de la
sección anterior se conecta con el paquete `lsp-mode`; la configuración está en
el `README` del servidor. Con sweep no es necesario: el análisis lo hace el
propio SWI-Prolog cargado en Emacs.

## 13.4 Otros editores

!!! note "Vim, Neovim y otros"
    Cualquier editor con cliente del protocolo LSP puede usar `lsp_server`. El
    `README` del servidor trae la configuración para Neovim (un archivo
    `lsp/prolog.lua` y `vim.lsp.enable({'prolog'})`); para Vim, los complementos
    de LSP aceptan el mismo comando que usa la extensión de Visual Studio Code:
    `swipl -g "use_module(library(lsp_server))." -g lsp_server:main -t halt
    -- stdio`. Sin servidor de lenguaje, cualquier editor sirve con el ciclo
    de la sección siguiente.

## 13.5 Verificar antes de entregar

Un programa que carga sin errores puede tener todavía dos clases de defectos:
los que las pruebas detectan, y los que solo una revisión del código completo
encuentra.

**Las pruebas.** Los archivos `.plt` del curso se cargan junto con el programa,
en la misma llamada a `consult/1`, y `run_tests/0` los ejecuta:

<!-- ejemplo: capitulo-13/inscripciones.pl predicado: alumno/4 consulta: alumno(Legajo, Nombre, sistemas, _). -->
```prolog
% alumno(Legajo, Nombre, Carrera, Ingreso): el alumno de ese legajo cursa esa
% carrera desde el año de ingreso.
alumno(101, ana,      sistemas,   2023).
alumno(102, bruno,    sistemas,   2024).
alumno(103, carla,    civil,      2023).
alumno(104, diego,    sistemas,   2024).
alumno(105, elena,    civil,      2025).
alumno(106, facundo,  industrial, 2024).
alumno(107, gabriela, industrial, 2025).
```

```prolog
?- [inscripciones, 'inscripciones.plt'].
```

```prolog
?- run_tests.
```

```text
% [1/6] inscripciones:las_materias_de_ana ........... passed (0.009 sec)
% [2/6] inscripciones:req..s_de_bases_de_datos ...... passed (0.000 sec)
...
% All 6 tests passed in 0.021 seconds (0.031 cpu)
true.
```

Cargar el `.plt` por separado, con `load_test_files/1`, no alcanza en estos
programas: las pruebas no ven los predicados del programa, y fallan con
*Unknown procedure*. El [capítulo 24](../capitulo-24-modulos-y-organizacion/index.md) muestra por qué, y cómo lo resuelven los
módulos.

**La revisión.** `check/0` recorre todo el programa cargado y busca defectos que
la carga no detecta. El más frecuente es el que muestra `revision.pl`: `nieto/2`
llama a `persona/1`, que no existe. La carga no lo advierte, porque la llamada
recién ocurre al ejecutar `nieto/2`, y el predicado podría estar definido en
otro archivo que todavía no se cargó:

```prolog
?- check.
```

```text
% Checking undefined predicates ...
Warning: The predicates below are not defined. If these are defined
Warning: at runtime using assert/1, use :- dynamic Name/Arity.
Warning:
Warning: persona/1, which is referenced by
Warning:        .../revision.pl:29:4: 1-st clause of nieto/2
% Checking trivial failures ...
% Checking format/2,3 and debug/3 templates ...
% Checking redefined system and global predicates ...
% Checking predicates with declarations but without clauses ...
% Checking predicates that need autoloading ...
true.
```

La advertencia indica el archivo, la línea y la columna de la llamada, y la
cláusula que la contiene. `list_undefined/0` hace solo la primera de esas
revisiones, que es la que `make/0` repite al terminar.

!!! example "Patrón 1 — Editar, recargar, probar"
    **Problema.** Después de modificar un archivo, el toplevel sigue ejecutando
    la versión anterior, y un error se descubre recién cuando alguien usa el
    predicado.

    **Versión ingenua.** Salir de `swipl` y volver a entrar después de cada
    cambio, y probar a mano algunas consultas.

    **Patrón.** El toplevel queda abierto toda la sesión. Cada cambio sigue el
    mismo ciclo: editar y guardar; `make.`; `run_tests.`; y `check.` antes de
    entregar.

    **Cuándo no usarlo.** Cuando el programa modifica su propia base de datos
    durante la ejecución ([capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md)), recargar no restituye los hechos
    agregados o quitados; en ese caso se reinicia el toplevel.

Las pruebas y `check/0` verifican que el programa funciona. El
[capítulo 14](../capitulo-14-estilo-y-documentacion/index.md) agrega una tercera verificación, que se aplica en toda la parte
II: los criterios de calidad de la [página de patrones](../patrones.md#criterios-de-calidad),
que preguntan si cada predicado se puede usar sin leer su código.

!!! question "Actividad"
    Cargar `revision.pl` y consultar `nieto(luis, Quien).` Explicar el mensaje
    de error a partir de lo que informa `check.` Después agregar al archivo los
    hechos `persona/1` necesarios, ejecutar `make.` y repetir la consulta.

## 13.6 Compartir

SWISH, el entorno del navegador que usó la parte I, sigue siendo la forma más
directa de compartir un programa: cada ejemplo del curso tiene un enlace que lo
abre en SWISH con el código incluido en la dirección. Para compartir un
programa propio, se lo pega en SWISH y se guarda; el programa guardado tiene
una dirección permanente.

SWISH ejecuta los programas en un entorno restringido: no permite leer ni
escribir archivos, ni cambiar banderas del sistema, ni llamar a predicados que
no estén definidos. Por eso algunos ejemplos de la parte II llevan en su
encabezado la marca `% solo-local:`, con la razón por la que no funcionan en
SWISH. `init.pl`, de este capítulo, es el primero: cambia una bandera del
sistema.

## 13.7 El proyecto: Inscripciones

La parte II desarrolla un proyecto a lo largo de sus capítulos:
*Inscripciones*, el sistema con el que los alumnos de una carrera se inscriben
en sus materias. Cada capítulo le agrega lo que enseña —validaciones, informes,
un lenguaje de comandos, módulos, errores, archivos, un servicio web— y cada
uno tiene la versión completa del proyecto en ese punto, de modo que se puede
leer sin haber seguido los anteriores.

Los datos son los mismos que el [capítulo 40](../capitulo-40-prolog-y-sql/index.md) traduce desde una base de datos
relacional: alumnos, materias, correlatividades e inscripciones. En este
capítulo el proyecto consiste solo en esos hechos, sin ninguna regla:

<!-- ejemplo: capitulo-13/inscripciones.pl archivo -->
```prolog
% alumno(Legajo, Nombre, Carrera, Ingreso): el alumno de ese legajo cursa esa
% carrera desde el año de ingreso.
alumno(101, ana,      sistemas,   2023).
alumno(102, bruno,    sistemas,   2024).
alumno(103, carla,    civil,      2023).
alumno(104, diego,    sistemas,   2024).
alumno(105, elena,    civil,      2025).
alumno(106, facundo,  industrial, 2024).
alumno(107, gabriela, industrial, 2025).

% materia(Codigo, Nombre, Anio): la materia de ese código es del año indicado.
materia(am1, analisis_1,     1).
materia(alg, algebra,        1).
materia(log, logica,         1).
materia(am2, analisis_2,     2).
materia(pp,  paradigmas,     2).
materia(ssl, sintaxis,       2).
materia(bd,  bases_de_datos, 3).

% correlativa(Materia, Requisito): para cursar Materia es necesario aprobar
% Requisito.
correlativa(am2, am1).
correlativa(am2, alg).
correlativa(pp,  log).
correlativa(ssl, log).
correlativa(ssl, alg).
correlativa(bd,  pp).
correlativa(bd,  ssl).

% inscripcion(Legajo, Materia, Nota): el alumno cursó o cursa la materia;
% Nota es null mientras la cursa y todavía no tiene nota.
inscripcion(101, am1, 8).
inscripcion(101, alg, 9).
inscripcion(101, log, 10).
inscripcion(101, am2, 7).
inscripcion(101, pp,  null).
inscripcion(102, am1, 4).
inscripcion(102, log, 6).
inscripcion(102, alg, 2).
inscripcion(103, am1, 7).
inscripcion(103, alg, 5).
inscripcion(103, am2, null).
inscripcion(104, log, 9).
inscripcion(104, alg, 7).
inscripcion(104, pp,  8).
inscripcion(105, am1, null).
inscripcion(106, log, 3).
inscripcion(106, am1, 6).
```

```prolog
?- inscripcion(101, Materia, Nota).
Materia = am1,
Nota = 8 ;
Materia = alg,
Nota = 9 ;
Materia = log,
Nota = 10 ;
Materia = am2,
Nota = 7 ;
Materia = pp,
Nota = null.

?- correlativa(bd, Requisito).
Requisito = pp ;
Requisito = ssl.
```

La nota `null` indica que la alumna todavía cursa la materia. Es un átomo más:
Prolog no le da ningún significado especial, y cualquier regla que calcule con
las notas debe tenerlo en cuenta. El [capítulo 14](../capitulo-14-estilo-y-documentacion/index.md) cambia esa
representación por una que distingue los dos casos en la estructura del término.

Todavía no hay reglas que probar, pero sí hechos que deben ser coherentes entre
sí: toda inscripción debe corresponder a un alumno y a una materia existentes,
y toda nota debe ser un entero de 1 a 10 o `null`. `inscripciones.plt` lo
verifica con las herramientas de la parte I: cada prueba busca un
contraejemplo, y declara con `[fail]` que no debe encontrarlo.

```prolog
% Ninguna inscripción nombra un legajo que no existe.
test(toda_inscripcion_es_de_un_alumno, [fail]) :-
    inscripcion(Legajo, _, _),
    \+ alumno(Legajo, _, _, _).
```

**El directorio del proyecto.** El proyecto vive en su propio directorio, bajo
control de versiones con git:

```text
inscripciones/
├── inscripciones.pl
├── inscripciones.plt
└── .git/hooks/pre-commit
```

**Un gancho de git.** Un gancho (*hook*) es un programa que git ejecuta en un
momento determinado. El gancho `pre-commit` se ejecuta antes de cada commit, y
si termina con un código distinto de cero, git cancela el commit. Este ejecuta
las pruebas; `swipl` termina con código 1 cuando alguna falla:

```sh
#!/bin/sh
# Gancho de git: ejecuta las pruebas de Inscripciones antes de cada commit.
# Si alguna falla, swipl termina con código 1 y git cancela el commit.
swipl -q -g "consult(['inscripciones.pl', 'inscripciones.plt'])" -g run_tests -t halt
```

Se guarda como `.git/hooks/pre-commit` dentro del directorio del proyecto. En
Linux, además, se le da permiso de ejecución con `chmod +x
.git/hooks/pre-commit`; en Windows, git lo ejecuta con el intérprete de
comandos que instala Git for Windows. Con el gancho instalado, un error en los
datos no llega al historial: la verificación de la [sección 13.5](#135-verificar-antes-de-entregar) deja de
depender de que alguien la recuerde.

Los tres archivos de configuración de este capítulo —el `settings.json` de
Visual Studio Code, el `init.el` de Emacs y el gancho `pre-commit`— están en
`ejemplos/capitulo-13/configuracion/`.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Cargar `revision.pl` y ejecutar `check.` Identificar en la
   advertencia el predicado que falta, el archivo, la línea y la cláusula que
   lo llama. Corregir el programa agregando los hechos `persona/1` de la
   familia, y comprobar que `check.` ya no advierte nada.
2. **(1)** Con `apropos/1`, encontrar el predicado predefinido que relaciona una
   lista con su último elemento. Con `help/1`, leer su primera línea: ¿qué
   argumentos deben llegar ligados?
3. ★ **(1)** Cargar `inscripciones.pl` y ejecutar `listing(correlativa/2).` ¿En
   qué orden aparecen los hechos, y de qué depende ese orden?
4. ★ **(2)** Con `inscripciones.pl` cargado, agregar en el editor el alumno
   `alumno(108, hernan, civil, 2025).` **al final** del archivo, y ejecutar
   `make.` Predecir antes qué advierte `make.`, y después corregir el archivo
   para que no lo advierta.
5. **(2)** Instalar el `init.pl` del capítulo y ejecutar `edit(abuelo).` con
   `revision.pl` cargado. ¿En qué línea se abre el archivo? Explicar qué
   ocurriría si el comando no tuviera `--wait`.
6. ★ **(2)** Con el editor configurado, escribir en un archivo nuevo la regla
   `hermano(A, B) :- padre(P, A), padre(Q, B), A \== B.` ¿Qué señala el editor
   antes de guardar? ¿Es un error del programa o solo una advertencia, y qué
   dice sobre lo que la regla pretendía?
7. **(2)** En Emacs con ediprolog, abrir `inscripciones.pl`, ubicar el cursor
   en la línea `%?- correlativa(bd, Requisito).` del encabezado y presionar F10.
   ¿Dónde quedan las respuestas, y cómo se piden las siguientes?
8. ★ **(2)** Escribir una prueba para `inscripciones.plt` que verifique que el
   requisito de toda correlativa es de un año anterior al de la materia. Como
   las demás pruebas de datos, debe buscar un contraejemplo.
9. **(2)** Instalar el gancho `pre-commit` en un repositorio con los dos
   archivos del proyecto. Agregar una inscripción a una materia que no existe e
   intentar el commit. ¿Qué muestra git, y qué se debe hacer para completarlo?
10. ★ **(1)** ¿Por qué `[revision].` no advierte que `persona/1` no existe, y
    `check.` sí? Dar un ejemplo de programa en el que la advertencia de
    `check.` sería incorrecta.
11. **(3)** Escribir una prueba que verifique que ningún alumno está inscripto
    dos veces en la misma materia. ¿Detecta dos hechos idénticos? Explicar por
    qué, y qué herramienta de un capítulo posterior lo resolvería.
12. **(2)** Abrir `inscripciones.pl` en SWISH desde su enlace y ejecutar las
    consultas del encabezado. Después intentar allí `make.` y
    `set_prolog_flag(editor, code).` y explicar las respuestas.

## Resumen

| | |
|---|---|
| `consult/1`, `[archivo]` | carga uno o varios archivos |
| `make/0` | recarga los archivos modificados y advierte los predicados sin definir |
| `listing/1` | escribe las cláusulas cargadas de un predicado |
| `apropos/1`, `help/1` | buscan en el manual, y muestran la entrada de un predicado con sus modos |
| `edit/1` | abre el editor en la definición de un predicado y recarga al cerrarlo |
| `init.pl` | el archivo de preferencias que SWI-Prolog carga al arrancar |
| `lsp_server` | el servidor de lenguaje: diagnósticos, definiciones y documentación en el editor |
| `run_tests/0` | ejecuta las pruebas de plunit cargadas |
| `check/0`, `list_undefined/0` | revisan el programa completo; la primera, con varias revisiones |
| gancho `pre-commit` | ejecuta las pruebas antes de cada commit y lo cancela si fallan |
| **[Patrón 1](../patrones.md#1-editar-recargar-probar)** | editar, recargar, probar |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Los criterios de calidad y el encabezado completo | [capítulo 14](../capitulo-14-estilo-y-documentacion/index.md) |
| La representación de la nota `null` | [capítulo 14](../capitulo-14-estilo-y-documentacion/index.md) |
| Módulos, y por qué las pruebas no ven el programa al cargarse por separado | [capítulo 24](../capitulo-24-modulos-y-organizacion/index.md) |
| plunit en detalle, el depurador y `gtrace/0` | [capítulo 26](../capitulo-26-pruebas-y-depuracion/index.md) |
| Los datos de Inscripciones como tablas de una base de datos | [capítulo 40](../capitulo-40-prolog-y-sql/index.md) |
