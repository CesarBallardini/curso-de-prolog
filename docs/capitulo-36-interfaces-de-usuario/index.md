# Capítulo 36 — Interfaces de usuario

Un programa del curso ya tiene dos interfaces: la línea de comandos del
[capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md), que lee una orden por línea, y el servicio REST del
[capítulo 30](../capitulo-30-servicios-web-rest/index.md), que responde JSON. Este capítulo agrega tres más sobre los
mismos dos programas, *Inscripciones* y el Buscaminas del
[capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md): la pantalla completa de la terminal, con recuadros, un cursor
y teclas; una ventana con botones y menús, hecha con XPCE; y páginas web
generadas por Prolog. En los tres casos el núcleo es el mismo que ya pasa sus
pruebas, y la interfaz es una capa delgada que lo llama.

La dificultad de una interfaz no está en dibujar, sino en probar lo que se
dibuja. El capítulo separa, en cada nivel, lo que se puede comprobar con
plunit —qué líneas se muestran, qué hace cada tecla, qué etiqueta tiene cada
botón, qué HTML se envía— de lo poco que solo se verifica a la vista. El
capítulo cumple dos anuncios: las interfaces de pantalla completa y con
ventanas, del [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md), y la interfaz web sobre los servicios de
*Inscripciones* y del Buscaminas, de los capítulos [30](../capitulo-30-servicios-web-rest/index.md) y
[31](../capitulo-31-ejecutables-y-distribucion/index.md). Ningún ejemplo corre en SWISH, que no tiene terminal, ni
ventanas, ni permite abrir puertos.

La fuente principal es el manual de SWI-Prolog: la terminal, la guía de
XPCE y `library(http/html_write)`. El bucle que lee una orden y la aplica
para obtener una versión nueva del estado es el del apartado «Interactive
Programs» de Sterling y Shapiro, *The Art of Prolog*, cuyo editor de líneas
guarda el texto antes y después del cursor; las ventanas como objetos que
responden a mensajes enviados por un único predicado son las del capítulo
«User Interface» de Merritt, *Building Expert Systems in Prolog*. Las
referencias completas están al final del capítulo.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- escribir una interfaz de pantalla completa con secuencias de escape ANSI,
  `get_single_char/1` y `tty_size/2`, y leer las teclas especiales;
- separar una interfaz en un modelo de pantalla puro, una transición pura
  por tecla y un único predicado que lee y escribe, y probar los dos
  primeros con plunit;
- construir ventanas con XPCE —`frame`, `dialog`, `button`, `menu`,
  `label`, `browser`— cuyos mensajes llaman a predicados del núcleo, y
  probarlas sin abrirlas;
- servir páginas HTML generadas con `html//1` junto a un servicio REST, o
  como cliente de uno, y probarlas con pedidos HTTP reales;
- decidir en qué entorno corre cada interfaz: la terminal, `swipl-win`, el
  navegador, la integración continua.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:35 h**.
    Resolver los 6 ejercicios marcados con ★: **1:55 h**.
    Resolver los 14 ejercicios del final: **4:10 h**.

## 36.1 El núcleo y las interfaces

El [Patrón 29](../patrones.md#29-nucleo-puro-bordes-impuros) separa el núcleo, que consulta y calcula, de los bordes,
que leen, escriben y guardan estado. Una interfaz de usuario es un borde más:
recibe lo que la persona hace, llama a los predicados públicos del núcleo y
muestra lo que responden. Los dos programas del capítulo tienen ese núcleo
escrito y probado: el módulo `partida` del Buscaminas, con `jugar/4`,
`filas/3` y `sugerencia/2`
([capítulo 31](../capitulo-31-ejecutables-y-distribucion/buscaminas.md#partida)), y los módulos `datos`, `reglas` e
`informes` de *Inscripciones*, con `inscribir/3`, `inscriptos/2` y
`ranking/1`. Las interfaces de este capítulo los cargan desde
`ejemplos/capitulo-31/` sin copiarlos ni cambiarlos:

| Interfaz | Buscaminas | *Inscripciones* | Llama a |
|---|---|---|---|
| Línea de comandos (28) | `terminal.pl` | `consola.pl` | `jugar/4`; `ejecutar/2` |
| Pantalla completa (36.2–36.3) | `texto/buscaminas_pantalla.pl` | `texto/menu_inscripciones.pl` | `jugar/4`, `filas/3`; `inscriptos/2` |
| Ventanas (36.4–36.5) | `ventanas/buscaminas_xpce.pl` | `ventanas/inscripciones_xpce.pl` | `jugar/4`; `inscribir/3`, `ranking/1` |
| Web (36.6) | `web/tablero_web.pl` | `web/paginas_inscripciones.pl` | el servicio JSON; `inscribir/3` |

El [ejercicio 13 del capítulo 29](../capitulo-29-prolog-desde-python/soluciones.md#13) organizó una interfaz de Python como
**puertos y adaptadores**: las reglas del juego no conocen la interfaz, y la
interfaz depende de ellas. Aquí la forma es la misma con módulos de Prolog:
cada interfaz es un módulo que importa el núcleo, y ningún módulo del núcleo
importa una interfaz. Cambiar de interfaz no cambia una sola regla.

Cada interfaz necesita un entorno distinto, y ese dato decide dónde se puede
usar y dónde se puede probar:

| Interfaz | Corre en | Sus pruebas corren en |
|---|---|---|
| Pantalla completa | una terminal que interpreta las secuencias ANSI; verificado en una terminal de Linux | `swipl`, en cualquier sistema y en la integración continua |
| Ventanas XPCE | `swipl-win` en Windows; en Linux, un SWI-Prolog con XPCE y una pantalla gráfica | el núcleo, en todas partes; la ventana, solo en `swipl-win` o con XPCE |
| Web | el navegador, con el servidor en `swipl` | `swipl`, con pedidos HTTP a un puerto libre |

## 36.2 Pantalla completa en la terminal

Una terminal no dibuja recuadros ni mueve el cursor por sí sola: interpreta
ciertas secuencias de caracteres, que empiezan con el carácter de escape
(código 27, escrito `\e` en una cadena de Prolog), como órdenes. Las que usa
el capítulo son pocas:

| Secuencia | Efecto |
|---|---|
| `\e[2J` | borra la pantalla |
| `\e[H` | lleva el cursor a la fila 1, columna 1 |
| `\e[F;CH` | lleva el cursor a la fila F, columna C |
| `\e[?25l`, `\e[?25h` | oculta y muestra el cursor |
| `\e[31m`, `\e[0m` | texto rojo; vuelve a los atributos normales |

SWI-Prolog no trae una biblioteca para dibujar en la terminal, así que el
curso escribe un módulo pequeño, `pantalla`, con `format/2`. Los predicados
que escriben son tres, y solo `dibujar/1` los combina:

<!-- ejemplo: capitulo-36/texto/pantalla.pl predicado: limpiar/0 ir_a/2 dibujar/1 -->
```prolog
%!  limpiar is det.
%
%   Borra la pantalla y lleva el cursor a la esquina superior izquierda.
limpiar :-
    format("\e[2J\e[H").

%!  ir_a(+Fila:integer, +Columna:integer) is det.
%
%   Lleva el cursor a Fila y Columna, contadas desde 1.
ir_a(Fila, Columna) :-
    format("\e[~d;~dH", [Fila, Columna]).

%!  dibujar(+Lineas:list(string)) is det.
%
%   Borra la pantalla y escribe Lineas desde la primera fila, cada una en
%   su fila.
dibujar(Lineas) :-
    limpiar,
    forall(nth1(Fila, Lineas, Linea),
           ( ir_a(Fila, 1),
             write(Linea) )),
    flush_output.
```

Lo que escriben es texto, y `with_output_to/2` lo captura como a cualquier
otra salida ([capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md)); así se prueban. El toplevel muestra el
carácter de escape con su código Unicode:

```prolog
?- with_output_to(string(S), ir_a(3, 10)).
S = "\u001B[3;10H".
```

Los recuadros se arman antes de escribirlos. `caja/3` recibe un título y las
líneas del contenido, y devuelve las líneas del recuadro, con los caracteres
Unicode de dibujo de cajas; no escribe nada:

<!-- ejemplo: capitulo-36/texto/pantalla.pl predicado: caja/3 -->
```prolog
%!  caja(+Titulo:string, +Lineas:list(string), -Caja:list(string)) is det.
%
%   Caja son las líneas de un recuadro con Titulo en el borde superior y
%   Lineas adentro, alineadas a la izquierda.
caja(Titulo, Lineas, [Arriba|Medio]) :-
    string_length(Titulo, LargoTitulo),
    maplist(string_length, Lineas, Largos),
    Minimo is LargoTitulo + 1,
    max_list([Minimo|Largos], Ancho),
    borde_superior(Titulo, LargoTitulo, Ancho, Arriba),
    maplist(interior(Ancho), Lineas, Interiores),
    Relleno is Ancho + 2,
    repetir("─", Relleno, Raya),
    string_concat("└", Raya, Abajo0),
    string_concat(Abajo0, "┘", Abajo),
    append(Interiores, [Abajo], Medio).
```

```prolog
?- caja("Hola", ["uno", "dos largo"], L).
L = ["┌─ Hola ────┐", "│ uno       │", "│ dos largo │", "└───────────┘"].
```

**Las teclas.** `get_single_char/1` lee una tecla sin esperar Enter, como en
la [sección 28.5](../capitulo-28-programas-de-linea-de-comandos/index.md#285-leer-del-teclado). Una letra llega como su código; una flecha llega como
una secuencia de escape de tres códigos: en una terminal de Linux, la flecha
hacia arriba es 27, 91 y 65, es decir `\e[A`. Leer una tecla es entonces leer
uno, dos o tres códigos. `leer_tecla/2` recibe como argumento el predicado
que da el código siguiente: en el programa, `get_single_char`; en las
pruebas, `get_code(In)` sobre un stream abierto con `open_string/2`, que
contiene las teclas escritas de antemano; `get_code/2` da el código del
carácter siguiente de un stream:

<!-- ejemplo: capitulo-36/texto/pantalla.pl predicado: leer_tecla/2 tecla/3 flecha/3 -->
```prolog
%!  leer_tecla(:Siguiente, -Tecla) is det.
%
%   Tecla es la tecla que llega por Siguiente, un predicado que da un
%   código por llamada: arriba, abajo, izquierda, derecha, enter, espacio,
%   letra(L), fin si la entrada se terminó, u otra.
leer_tecla(Siguiente, Tecla) :-
    call(Siguiente, Codigo),
    tecla(Codigo, Siguiente, Tecla).

%!  tecla(+Codigo:integer, :Siguiente, -Tecla) is det.
%
%   Tecla es la que empieza con Codigo; una secuencia de escape pide dos
%   códigos más a Siguiente.
tecla(27, Siguiente, Tecla) :-
    !,
    call(Siguiente, C1),
    call(Siguiente, C2),
    (   flecha(C1, C2, Flecha)
    ->  Tecla = Flecha
    ;   Tecla = otra
    ).
tecla(13, _, enter) :-
    !.
tecla(10, _, enter) :-
    !.
tecla(32, _, espacio) :-
    !.
tecla(-1, _, fin) :-
    !.
tecla(Codigo, _, letra(L)) :-
    code_type(Codigo, graph),
    !,
    char_code(L, Codigo).
tecla(_, _, otra).

% flecha(C1, C2, Tecla): la secuencia ESC C1 C2 es la flecha Tecla.
flecha(0'[, 0'A, arriba).
flecha(0'[, 0'B, abajo).
flecha(0'[, 0'C, derecha).
flecha(0'[, 0'D, izquierda).
```

```text
?- open_string("\e[Am", In), leer_tecla(get_code(In), T1), leer_tecla(get_code(In), T2).
In = <stream>(0000026514814d10),
T1 = arriba,
T2 = letra(m).
```

El número del stream cambia de una ejecución a otra. Para un código visible,
que `code_type/2` clasifica como `graph`, `char_code/2` da el carácter: el
átomo de un solo carácter que lleva la tecla `letra/1`.

El código −1 es el fin de la entrada: el de un stream que se terminó, y el
que `get_single_char/1` devuelve cuando no queda nada que leer. Convertirlo en
la tecla `fin` permite que un programa termine en lugar de esperar para
siempre, y que una prueba con pocas teclas no quede bloqueada.

!!! question "Actividad"
    Antes de ejecutarlo, predecir qué códigos escribe, en la terminal que se
    usa habitualmente, `swipl -g "forall(between(1, 4, _), (get_single_char(C), writeln(C)))" -t halt`
    al pulsar una flecha y la tecla Inicio. Comprobarlo. ¿Qué pasaría con
    `leer_tecla/2` si la terminal enviara otra secuencia?

**El tamaño.** `tty_size/2` da las filas y las columnas de la terminal. Si la
salida no es una terminal —un pipe, un archivo, plunit—, produce el error
`not_implemented(procedure, tty_size/2)`; `tamanio/2` lo convierte en el
tamaño clásico de 24 filas por 80 columnas:

<!-- ejemplo: capitulo-36/texto/pantalla.pl predicado: tamanio/2 -->
```prolog
%!  tamanio(-Filas:integer, -Columnas:integer) is det.
%
%   Filas y Columnas son el tamaño de la terminal, o 24 y 80 si la salida
%   no es una terminal.
tamanio(Filas, Columnas) :-
    catch(tty_size(Filas, Columnas), error(_, _),
          ( Filas = 24, Columnas = 80 )).
```

Por último, `con_pantalla/1` oculta el cursor mientras corre un objetivo y lo
vuelve a mostrar al terminar, de cualquier manera: con `setup_call_cleanup/3`
([capítulo 25](../capitulo-25-errores-y-excepciones/index.md)), un error o un Control-C no dejan la terminal sin
cursor.

!!! example "Patrón 51 — Modelo de pantalla"
    **Problema.** Una interfaz de pantalla completa escribe en la terminal y
    lee del teclado. Si calcula y dibuja en el mismo paso, lo que muestra
    solo se verifica mirándolo, y la lógica de las teclas no se puede probar.

    **Versión ingenua.** Un bucle que consulta el estado, escribe cada parte
    de la pantalla con `format/2` a medida que la calcula, lee una tecla y
    decide en el mismo predicado qué hacer con ella.

    **Patrón.** Tres predicados. El modelo, `pantalla(+Estado, -Lineas)`,
    puro: da las líneas que se ven. La transición, `paso(+Tecla, +Estado0,
    -Estado)`, pura: da el estado después de una tecla. Y un único bucle
    impuro que dibuja las líneas y lee las teclas de una fuente que recibe
    como argumento. Las pruebas comparan líneas, aplican listas de teclas con
    `foldl/4` y hacen correr el bucle con teclas escritas en una cadena.

    **Cuándo no usarlo.** En una interfaz de una pregunta y una respuesta,
    como la de la [sección 28.5](../capitulo-28-programas-de-linea-de-comandos/index.md#285-leer-del-teclado): no hay pantalla que modelar. Y
    cuando la pantalla es enorme y cambia poco: redibujarla entera en cada
    tecla es lento, y conviene comparar el modelo nuevo con el anterior y
    escribir solo las líneas distintas.

## 36.3 El Buscaminas y el menú de *Inscripciones* a pantalla completa

El estado del Buscaminas a pantalla completa es `juego(Partida, Cursor,
Pedido)`: la partida del módulo `partida`, la celda `Fila-Columna` donde está
el cursor, y `jugar` o `salir`. La transición traduce cada tecla en un
movimiento del cursor o en una jugada del núcleo:

<!-- ejemplo: capitulo-36/texto/buscaminas_pantalla.pl predicado: paso/3 mover/4 -->
```prolog
%!  paso(+Tecla, +Juego0, -Juego) is det.
%
%   Juego es Juego0 después de Tecla: las flechas mueven el cursor, la
%   barra descubre la celda, m la marca, q y el fin de la entrada salen; las
%   demás teclas no cambian nada.
paso(arriba, Juego0, Juego) :-
    !,
    mover(-1, 0, Juego0, Juego).
paso(abajo, Juego0, Juego) :-
    !,
    mover(1, 0, Juego0, Juego).
paso(izquierda, Juego0, Juego) :-
    !,
    mover(0, -1, Juego0, Juego).
paso(derecha, Juego0, Juego) :-
    !,
    mover(0, 1, Juego0, Juego).
paso(espacio, juego(P0, Celda, Pedido), juego(P, Celda, Pedido)) :-
    !,
    jugar(descubrir, Celda, P0, P).
paso(letra(m), juego(P0, Celda, Pedido), juego(P, Celda, Pedido)) :-
    !,
    jugar(marcar, Celda, P0, P).
paso(letra(q), juego(P, Celda, _), juego(P, Celda, salir)) :-
    !.
paso(fin, juego(P, Celda, _), juego(P, Celda, salir)) :-
    !.
paso(_, Juego, Juego).

%!  mover(+DF:integer, +DC:integer, +Juego0, -Juego) is det.
%
%   Mueve el cursor DF filas y DC columnas, sin salir del tablero.
mover(DF, DC, juego(P, F0-C0, Pedido), juego(P, F-C, Pedido)) :-
    dimensiones(P, Filas, Columnas),
    F is max(1, min(Filas, F0 + DF)),
    C is max(1, min(Columnas, C0 + DC)).
```

`paso/3` no conoce las reglas del juego: una celda descubierta, marcada o con
una mina la resuelve `jugar/4`. El modelo arma dos recuadros con
`filas/3`, que ya da un carácter por celda, y encierra entre corchetes la
celda del cursor:

<!-- ejemplo: capitulo-36/texto/buscaminas_pantalla.pl predicado: pantalla/2 -->
```prolog
%!  pantalla(+Juego, -Lineas:list(string)) is det.
%
%   Lineas es la pantalla de Juego: el tablero en una caja, con el cursor
%   entre corchetes, el estado en otra y una línea de ayuda.
pantalla(juego(Partida, Cursor, Pedido), Lineas) :-
    estado(Partida, Estado),
    (   Estado == sigue
    ->  Minas = false
    ;   Minas = true
    ),
    filas(Partida, Minas, Filas),
    foldl(fila_con_cursor(Cursor), Filas, Tablero, 1, _),
    caja("Buscaminas", Tablero, Caja1),
    minas_restantes(Partida, Restantes),
    format(string(Linea1), "Minas sin marcar: ~d", [Restantes]),
    mensaje(Estado, Pedido, Linea2),
    caja("Estado", [Linea1, Linea2], Caja2),
    Ayuda = "Flechas: mover  Espacio: descubrir  m: marcar  q: salir",
    append([Caja1, Caja2, [Ayuda]], Lineas).
```

`fila_con_cursor/5` y `celda/6` numeran las filas y las columnas con
`foldl/6` ([capítulo 18](../capitulo-18-orden-superior/index.md)). Con una mina en 1-1, el cursor en 2-2 y ninguna
celda descubierta, el modelo da estas líneas, que son exactamente las que la
terminal muestra:

```text
┌─ Buscaminas ┐
│  #  #  #    │
│  # [#] #    │
│  #  #  #    │
└─────────────┘
┌─ Estado ────────────┐
│ Minas sin marcar: 1 │
│ En juego            │
└─────────────────────┘
Flechas: mover  Espacio: descubrir  m: marcar  q: salir
```

El bucle es el único predicado que escribe y lee. Dibuja, termina si la
partida terminó o se pidió salir, y si no, lee una tecla, aplica `paso/3` y
sigue; `buscaminas/4` lo llama con `get_single_char` dentro de
`con_pantalla/1`:

<!-- ejemplo: capitulo-36/texto/buscaminas_pantalla.pl predicado: bucle/3 buscaminas/4 -->
```prolog
%!  bucle(:Siguiente, +Juego0, -Juego) is det.
%
%   Dibuja Juego0 y, si no terminó, lee una tecla de Siguiente, la aplica y
%   sigue con el juego que resulta. Juego es el juego terminado.
bucle(Siguiente, Juego0, Juego) :-
    pantalla(Juego0, Lineas),
    dibujar(Lineas),
    (   terminado(Juego0)
    ->  Juego = Juego0
    ;   leer_tecla(Siguiente, Tecla),
        paso(Tecla, Juego0, Juego1),
        bucle(Siguiente, Juego1, Juego)
    ).

%!  buscaminas(+Filas:integer, +Columnas:integer, +Minas:integer,
%!             +Semilla:integer) is det.
%
%   Juega en la terminal una partida nueva con las teclas.
buscaminas(Filas, Columnas, Minas, Semilla) :-
    nueva_partida(Filas, Columnas, Minas, Semilla, Partida),
    con_pantalla(bucle(get_single_char, juego(Partida, 1-1, jugar), _)).
```

Se juega con `swipl buscaminas_pantalla.pl` y, en el intérprete,
`buscaminas(9, 9, 10, 7).`. El programa se ejecutó en una terminal de Linux
(una pseudoterminal, con `script`) enviándole flecha a la derecha, flecha
abajo, `m` y `q`: lo que escribió fueron las secuencias `\e[2J\e[H` y una
`\e[F;1H` por línea, con las líneas del modelo, el cursor en `[M]` sobre la
celda 2-2 y el estado «Partida abandonada». En Windows, un programa que
escribe las mismas secuencias con `format/2`, ejecutado en una pseudoconsola
del sistema (ConPTY, sobre la que funciona Windows Terminal), leyó bien la
tecla con `get_single_char/1`, pero las secuencias de borrado y de posición
del cursor no llegaron a la salida, y todo el texto quedó en una línea: en
Windows, estos programas no se dan por verificados.

!!! question "Actividad"
    Predecir el cursor y las filas de `filas/3` después de las teclas
    `[abajo, abajo, derecha, derecha, espacio]` sobre la partida de 3×3 con
    una mina en 1-1, empezando en 1-1. Comprobarlo con `foldl(paso, Teclas,
    juego(P, 1-1, jugar), J)`.

**El menú de *Inscripciones*.** El mismo esquema, con otro estado:
`menu(N, Vista)`, donde N es la materia elegida y Vista es `materias`,
`inscriptos` o `salir`. En la lista, las flechas mueven la selección, Enter
abre los inscriptos de la materia y `q` sale; en los inscriptos, Enter o `q`
vuelven. `pantalla_menu/2` consulta `materia/3`, `inscriptos/2` y
`promedio_de_materia/2`, y da estas dos pantallas para la tercera materia:

```text
┌─ Materias ────────────────┐
│   am1 analisis_1        5 │
│   alg algebra           4 │
│ > log logica            4 │
│   am2 analisis_2        2 │
│   pp  paradigmas        2 │
│   ssl sintaxis          0 │
│   bd  bases_de_datos    0 │
└───────────────────────────┘
Flechas: elegir  Enter: inscriptos  q: salir
```

```text
┌─ Inscriptos en logica ┐
│ 101 ana       nota 10 │
│ 102 bruno     nota 6  │
│ 104 diego     nota 9  │
│ 106 facundo   nota 3  │
│                       │
│ Promedio: 7.00        │
└───────────────────────┘
Enter o q: volver
```

Una sola cláusula `pantalla_menu(menu(N, Vista), Lineas)` llama a
`pantalla_vista(Vista, N, Lineas)`, con una cláusula por vista. Con dos
cláusulas `pantalla_menu(menu(N, materias), …)` y
`pantalla_menu(menu(N, inscriptos), …)`, el primer argumento de las dos
tiene el mismo functor, `menu/2`, y la indexación no las distingue: la
llamada deja una alternativa pendiente, que plunit informa. Con la vista
como primer argumento, la indexación elige la cláusula
([capítulo 16](../capitulo-16-rendimiento/index.md)).

## 36.4 Ventanas con XPCE

XPCE es la biblioteca gráfica de SWI-Prolog, la misma que dibuja el
depurador de la [sección 26.4](../capitulo-26-pruebas-y-depuracion/index.md#264-gtrace0). En Windows se carga en
`swipl-win`, la versión de SWI-Prolog con ventana propia, y no en la consola
`swipl`: allí `library(pce)` no existe. En Linux viene con los paquetes de
escritorio de SWI-Prolog, no con `swi-prolog-nox`, y necesita una pantalla
gráfica. Tres predicados manejan todos sus objetos:

- `new(Objeto, Descripcion)` crea un objeto: `new(V, frame('Buscaminas'))`
  crea una ventana y liga V a su referencia, un término `@(Numero)`;
- `send(Objeto, Metodo, Argumentos…)` le pide una acción:
  `send(V, append, new(D, dialog))` agrega a la ventana un diálogo nuevo;
- `get(Objeto, Metodo, Argumentos…, Valor)` le pide un valor:
  `get(Boton, label, E)` liga E a la etiqueta de un botón.

Una ventana es un `frame` que contiene ventanas; un `dialog` ordena
elementos: `button`, `menu` (de opciones, `choice`, o desplegable,
`cycle`), `text_item` para escribir, `label` para mostrar un texto y
`menu_bar` con `popup` para los menús de arriba. Un `browser` muestra una
lista de líneas. Cada elemento recibe un nombre, y
`get(Dialogo, member, Nombre, Elemento)` lo encuentra.

**Los mensajes.** Un botón tiene un mensaje que se ejecuta con el clic:
`message(@(prolog), pulsar, V, 2, 3)` llama al predicado de Prolog
`pulsar(V, 2, 3)`. `@(prolog)` es el objeto que representa a Prolog dentro de
XPCE. La mayoría de los programas escriben `@prolog`, con `@` como operador
prefijo; ese operador lo define `library(pce)`, y los archivos del capítulo
usan la forma `@(prolog)`, que se lee también donde XPCE no está. Esa
llamada es la frontera de la interfaz: el predicado que recibe el clic lee
la ventana, llama al núcleo y escribe en la ventana lo que el núcleo
responde.

**Crear sin abrir.** `send(V, open)` muestra la ventana, y desde ese momento
XPCE atiende los clics en su propio ciclo de eventos. Pero todo lo anterior
—crear la ventana, agregar elementos, poner etiquetas, leerlas, ejecutar el
mensaje de un botón con `send(Boton, execute)`— funciona sin abrirla. Así se
prueba una ventana: se la crea, se ejecutan sus botones y se leen sus
etiquetas con `get/3`, y no aparece nada en la pantalla. `send(V, create)`
calcula además la disposición de los elementos sin mostrarla, y permite
consultar sus posiciones.

Los archivos de `ventanas/` cargan XPCE solo donde existe:

```prolog
:- if(exists_source(library(pce))).
:- use_module(library(pce)).
:- endif.
```

En `swipl` sin XPCE, el archivo se carga igual: los predicados que crean la
ventana quedan sin poder usarse, y los del núcleo de la interfaz se prueban.
Las pruebas de la ventana llevan la opción `condition(hay_xpce)`, y plunit las
omite donde la condición falla.

## 36.5 El Buscaminas con botones; la ventana de *Inscripciones*

La ventana del Buscaminas tiene dos diálogos: arriba, `controles`, con el
menú *Juego* —los tres niveles y *Salir*—, el menú *Acción* —descubrir o
marcar— y el rótulo del estado; abajo, `tablero`, con un botón por celda:

<!-- ejemplo: capitulo-36/ventanas/buscaminas_xpce.pl predicado: ventana_con_partida/2 agregar_boton/4 -->
```prolog
%!  ventana_con_partida(+Partida, -Ventana) is det.
%
%   Ventana es un frame de XPCE, todavía sin abrir, que muestra Partida:
%   arriba, el diálogo controles, con el menú Juego, la acción y el rótulo;
%   abajo, el diálogo tablero, con un botón por celda.
ventana_con_partida(Partida, Ventana) :-
    new(Ventana, frame('Buscaminas')),
    send(Ventana, append, new(Controles, dialog)),
    send(Controles, name, controles),
    send(Controles, append, new(Barra, menu_bar)),
    send(Barra, append, new(Juego, popup(juego))),
    forall(nivel(Nivel, _, _, _),
           send(Juego, append,
                menu_item(Nivel,
                          message(@(prolog), nuevo, Ventana, Nivel)))),
    send(Juego, append,
         menu_item(salir, message(@(prolog), cerrar, Ventana))),
    send(Controles, append, new(Accion, menu(accion, choice))),
    send_list(Accion, append, [descubrir, marcar]),
    send(Controles, append, label(estado, ''), right),
    send(new(Tablero, dialog), below, Controles),
    send(Tablero, name, tablero),
    dimensiones(Partida, Filas, Columnas),
    forall(( between(1, Filas, F), between(1, Columnas, C) ),
           agregar_boton(Tablero, Ventana, F, C)),
    assertz(partida_de(Ventana, Partida)),
    send(Ventana, done_message, message(@(prolog), cerrar, Ventana)),
    mostrar(Ventana, Partida).

%!  agregar_boton(+Tablero, +Ventana, +F:integer, +C:integer) is det.
%
%   Agrega a Tablero el botón de la celda F-C, en su lugar de la grilla.
agregar_boton(Tablero, Ventana, F, C) :-
    nombre_de_boton(F, C, Nombre),
    new(B, button(Nombre, message(@(prolog), pulsar, Ventana, F, C), '')),
    celda_en_pixeles(Ancho, Alto),
    X is (C - 1) * Ancho,
    Y is (F - 1) * Alto,
    send(Tablero, display, B, point(X, Y)).
```

Los botones se ubican con `display` en un punto calculado, y no con
`append`: un diálogo alinea en columnas los elementos que se le agregan con
`append`, y con 81 botones debajo de un menú el primero quedó a 2754
píxeles del borde izquierdo; las posiciones se leyeron con `get(B, x, X)`
después de `send(V, create)`. Con `display`, la ventana del nivel experto,
de 16 por 30 celdas, mide 980 píxeles de ancho.

El clic en un botón llama a `pulsar/3`, que lee la acción del menú, aplica
`clic/4` a la partida guardada y muestra la partida nueva:

<!-- ejemplo: capitulo-36/ventanas/buscaminas_xpce.pl predicado: pulsar/3 clic/4 -->
```prolog
%!  pulsar(+Ventana, +F:integer, +C:integer) is det.
%
%   Responde al clic en la celda F-C: aplica clic/4 con la acción elegida
%   en el menú y muestra la partida que resulta.
pulsar(Ventana, F, C) :-
    get(Ventana, member, controles, Controles),
    get(Controles, member, accion, Menu),
    get(Menu, selection, Accion),
    retract(partida_de(Ventana, Partida0)),
    clic(Accion, F-C, Partida0, Partida),
    assertz(partida_de(Ventana, Partida)),
    mostrar(Ventana, Partida).

%!  clic(+Accion:atom, +Celda:pair, +Partida0, -Partida) is det.
%
%   Partida es Partida0 después de un clic con Accion en Celda; un clic en
%   una partida terminada no cambia nada.
clic(Accion, Celda, Partida0, Partida) :-
    (   estado(Partida0, sigue)
    ->  jugar(Accion, Celda, Partida0, Partida)
    ;   Partida = Partida0
    ).
```

`clic/4` y `vista/2`, que traduce cada carácter de `filas/3` en la etiqueta
de un botón y si admite clics, son puros, y se prueban en cualquier
Prolog. `mostrar/2` pone esas etiquetas en los botones. Un cambio de
etiqueta devuelve el botón a su ancho por omisión, 80 píxeles, y por eso
`mostrar/2` fija el ancho después de cada etiqueta; y el rótulo recibe un
átomo, porque un texto de Prolog pasado como cadena queda en XPCE como un
objeto `string`, y `get/3` devuelve después su referencia en lugar del
texto. Las dos cosas las mostraron las pruebas, no la pantalla.

La partida de cada ventana se guarda en `partida_de/2`, con la referencia de
la ventana como clave. *Nuevo* cierra la ventana y abre otra;
*Salir* y el botón de cierre del sistema llaman a `cerrar/1`, que olvida la
partida. Con `swipl-win buscaminas_xpce.pl` y
`abrir_buscaminas(principiante).` la ventana se abre.

**La ventana de *Inscripciones*.** Un formulario —el legajo en un
`text_item`, la materia en un `menu` desplegable y el botón *Inscribir*—, un
rótulo con el resultado y el ranking en un `browser`. El menú *Archivo*
exporta el ranking con `exportar_ranking/1`, del
[capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md), y cierra la ventana. El botón lee el formulario y delega
en un predicado que no conoce XPCE:

<!-- ejemplo: capitulo-36/ventanas/inscripciones_xpce.pl predicado: inscribir_desde/1 mensaje_de_inscripcion/3 -->
```prolog
%!  inscribir_desde(+Ventana) is det.
%
%   Responde al botón Inscribir: lee el formulario, llama a
%   mensaje_de_inscripcion/3 y muestra el mensaje.
inscribir_desde(Ventana) :-
    get(Ventana, member, dialog, D),
    get(D, member, legajo, Campo),
    get(Campo, selection, Legajo),
    get(D, member, materia, Menu),
    get(Menu, selection, Materia),
    mensaje_de_inscripcion(Legajo, Materia, Mensaje),
    mostrar_resultado(Ventana, Mensaje).

%!  mensaje_de_inscripcion(+Legajo:atom, +Materia:atom, -Mensaje:string)
%!      is det.
%
%   Inscribe al alumno Legajo, escrito como texto, en Materia con
%   inscribir/3, y Mensaje dice el resultado. Un legajo que no es un número
%   no llega a inscribir/3.
mensaje_de_inscripcion(Legajo, Materia, Mensaje) :-
    (   atom_number(Legajo, L),
        integer(L)
    ->  inscribir(L, Materia, Resultado),
        texto_del_resultado(Resultado, L, Materia, Mensaje)
    ;   format(string(Mensaje), "El legajo '~w' no es un número", [Legajo])
    ).
```

`text_item` entrega el legajo como átomo, `'104'`, y un legajo que no es un
número no llega a `inscribir/3`, que produciría un error de tipo
([capítulo 25](../capitulo-25-errores-y-excepciones/index.md)). Las pruebas de la ventana llenan el formulario con
`send/3`, ejecutan el botón y leen el rótulo:

```prolog
test(ventana, [ condition(hay_xpce),
                cleanup(send(V, destroy)),
                true(X == [5, '101  ana        8.50', 'Inscripción aceptada: \c
                                                   104 en ssl']) ]) :-
    ventana_inscripciones(V),
    get(V, member, ranking, Lista),
    get(Lista, members, Filas),
    get(Filas, size, N),
    get(Filas, head, Primera),
    get(Primera, key, Texto),
    elemento(V, legajo, Campo),
    send(Campo, selection, '104'),
    elemento(V, materia, Menu),
    send(Menu, selection, ssl),
    elemento(V, inscribir, Boton),
    sin_cambios(send(Boton, execute)),
    elemento(V, resultado, Rotulo),
    get(Rotulo, selection, R),
    X = [N, Texto, R].
```

!!! question "Actividad"
    Ejecutar `ventanas/buscaminas_xpce.plt` con `swipl` y con `swipl-win`.
    Predecir cuántas pruebas corre cada uno antes de ejecutarlas, y explicar
    la diferencia.

## 36.6 Páginas web sobre los servicios

El servicio de *Inscripciones* del [capítulo 30](../capitulo-30-servicios-web-rest/index.md) y el del Buscaminas del
[capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md) responden JSON, que un programa lee y una persona no.
`library(http/html_write)` genera HTML a partir de términos: `h1('Materias')`
es un título, `a(href(Url), Texto)` un enlace. La regla `html//1` traduce el
término a fragmentos de HTML, con el texto escapado; `print_html/1` los
escribe, y `reply_html_page/2` responde un pedido con una página entera.

Las páginas del curso siguen el [Patrón 51](../patrones.md#51-modelo-de-pantalla) con otra salida: un
predicado puro arma el término de la página a partir del estado, y el
manejador solo lo envía. Hay dos maneras de ubicarlas. Las de
*Inscripciones* se agregan **junto al servicio**, en el mismo servidor que
`api.pl`, y llaman al núcleo como lo llaman las rutas de JSON. Las del
Buscaminas son un **cliente HTML del servicio**: no cargan el núcleo, piden
el tablero con `http_open/3`, envían cada jugada con `http_post/4` y
responden al navegador con una redirección 303, `http_redirect/3`, para que
recargar la página no repita la jugada. Su única dependencia es el formato
JSON del servicio.

El código de las dos, con sus pruebas, está en
[la página de las páginas web](web.md) del capítulo.

## 36.7 Cómo se prueba una interfaz

Cada nivel se prueba con la herramienta que ya existe para él; lo nuevo es
qué parte de la interfaz queda del lado que se prueba:

| Nivel | Se prueba con plunit | Se verifica a mano |
|---|---|---|
| Pantalla completa | el modelo (líneas exactas), la transición (listas de teclas con `foldl/4`), el bucle con teclas en `open_string/2`, las secuencias capturadas con `with_output_to/2` | que la terminal las interpreta y que el dibujo se ve alineado |
| Ventanas | el núcleo de la interfaz en todas partes; en `swipl-win`, la ventana sin abrir: `send(Boton, execute)`, etiquetas, posiciones y anchos con `get/3` | el aspecto de la ventana abierta y los clics con el ratón |
| Web | el cuerpo como término y como texto; las rutas con pedidos HTTP a un puerto libre ([Patrón 41](../patrones.md#41-servidor-bajo-prueba)); con pytest y Playwright, las páginas en Chromium sin ventana: enlaces, formularios y jugadas | el aspecto, en las capturas de [la página web](web.md) |

La prueba del bucle del menú recorre la interfaz entera con cuatro teclas y
verifica la última pantalla dibujada, que es la última parte de la salida
después del último `\e[2J`:

```prolog
test(recorrido, true(M == menu(2, salir))) :-
    con_teclas("\e[B\rqq", menu(1, materias), M, Salida),
    atomic_list_concat(Pantallas, '\e[2J', Salida),
    last(Pantallas, Ultima),
    once(sub_atom(Ultima, _, _, _, '> alg')).
```

Las pruebas de las ventanas corren en `swipl-win`, que no tiene una salida
que un programa pueda leer: para ejecutarlas desde la línea de comandos, un
programa pequeño abre un archivo, lo usa como `user_output` y `user_error`,
carga el `.pl` y el `.plt`, ejecuta `run_tests/0` y termina; se lo llama como
`swipl-win correr.pl -- ejemplo.pl ejemplo.plt salida.txt`, con rutas
absolutas, porque `swipl-win` no conserva el directorio de trabajo. En la
integración continua del curso, que usa `swipl` sin XPCE, esas pruebas se
omiten, y las del núcleo corren.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C4 | `pantalla/2`, `paso/3`, `pantalla_menu/2` y `vista/2` no dejan alternativas: la prueba de `pantalla_menu/2` las encontró cuando el primer argumento no distinguía las cláusulas |
    | C6 | ninguna interfaz tiene reglas: `paso/3` y `clic/4` delegan en `jugar/4`, el botón *Inscribir* en `inscribir/3`, las páginas del tablero en el servicio; el núcleo de los capítulos [27](../capitulo-27-archivos-streams-y-formatos/index.md) a [31](../capitulo-31-ejecutables-y-distribucion/index.md) no cambió |
    | C7 | 73 pruebas de plunit: 35 de la pantalla completa, 12 del núcleo de las ventanas en cualquier Prolog y 7 más de las ventanas en `swipl-win`, 19 de las páginas con pedidos HTTP; y 6 pruebas de las páginas en un navegador, con Playwright. Lo que no se prueba es el aspecto |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta y comprobarla, con
   `pantalla.pl` cargado: `caja("", ["ab"], L).` ·
   `with_output_to(string(S), dibujar(["a", "b"])).` ·
   `open_string("\r \e[C", In), leer_tecla(get_code(In), T1),
   leer_tecla(get_code(In), T2), leer_tecla(get_code(In), T3).`
2. **(2)** Si una línea del modelo incluye una secuencia de color, como
   `"\e[31m*\e[0m"`, el borde derecho de `caja/3` se desplaza. Explicar por
   qué, y escribir `largo_visible/2`, que no cuenta las secuencias
   `\e[…m`, para que `caja/3` alinee esas líneas.
3. ★ **(2)** Agregar a `leer_tecla/2` las teclas Inicio (`\e[H`), Fin
   (`\e[F`) y Suprimir (`\e[3~`), que tiene un código más que las otras.
   Probar las tres con `open_string/2`, seguidas de una letra.
4. **(2)** Escribir `lado_a_lado(+Caja1, +Caja2, -Lineas)`, que pone dos
   recuadros uno al lado del otro, con dos espacios entre ellos, aunque
   tengan distinta cantidad de líneas, y usarlo para mostrar el estado del
   Buscaminas a la derecha del tablero.
5. ★ **(2)** Agregar al Buscaminas de pantalla completa la tecla `?`, que
   lleva el cursor a la celda que da `sugerencia/2` y deja todo igual si no
   hay ninguna segura. Solo cambia `paso/3`; escribir las pruebas.
6. ★ **(3)** Agregar al menú de *Inscripciones* un formulario: en la vista de
   inscriptos, la tecla `i` abre un recuadro «Inscribir en *materia*» con el
   legajo que se escribe con los dígitos y se corrige con la tecla de
   borrar; Enter llama a `inscribir/3`, y el resultado queda en una línea de
   estado debajo de la lista. El modelo y la transición siguen puros; la
   inscripción es el único efecto de la transición.
7. **(1)** Clasificar como núcleo o interfaz, y como puro o impuro, estos
   predicados del capítulo: `paso/3`, `pantalla/2`, `bucle/3`,
   `leer_tecla/2`, `clic/4`, `pulsar/3`, `mostrar/2`, `cuerpo_materia/2`,
   `pagina_materia/2`, `mensaje_de_inscripcion/3`. ¿Cuáles se prueban en la
   integración continua?
8. ★ **(2)** Agregar al menú *Juego* de la ventana del Buscaminas el ítem
   *Sugerencia*, que escribe en el rótulo la celda segura de
   `sugerencia/2`, o que no hay ninguna. Separar el texto del rótulo en un
   predicado puro y probar los dos lados.
9. **(2)** En la ventana de *Inscripciones*, mostrar en una segunda lista
   los inscriptos de la materia elegida, y actualizarla al cambiar la
   materia del menú y después de cada inscripción aceptada.
10. **(2)** Escribir la prueba que inscribe desde la ventana al alumno 103
    en `ssl` y verifica el rechazo en el rótulo, sin cambiar los datos.
    ¿Qué pasa con esa prueba en `swipl`?
11. ★ **(2)** Agregar a las [páginas de *Inscripciones*](web.md#junto-al-servicio-inscripciones) la ruta
    `/pagina/alumnos/{legajo}`: el nombre, la carrera, las materias con su
    estado y el promedio, o 404 si el alumno no existe. Probarla con pedidos
    HTTP.
12. **(2)** Hacer que el formulario de inscripción responda con una
    redirección 303 a la página de la materia, con el resultado en un
    parámetro `mensaje` que esa página muestra. Explicar qué cambia al
    recargar la página en el navegador.
13. **(3)** Agregar a la [página del tablero](web.md#como-cliente-del-servicio-el-buscaminas) un botón *Sugerencia*, que pide
    `/partidas/{id}/sugerencia` al servicio y muestra la celda, o que no hay
    ninguna segura cuando el servicio responde 404.
14. **(1)** Las tres interfaces del Buscaminas de este capítulo y la de
    línea de comandos del [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) se prueban de maneras
    distintas. Para cada una, decir qué entrada reciben sus pruebas y cómo
    leen el resultado.

## Resumen

| | |
|---|---|
| secuencias de escape ANSI | `\e[2J` borra, `\e[F;CH` ubica el cursor, `\e[?25l` y `\e[?25h` lo ocultan y lo muestran, `\e[31m` y `\e[0m` cambian los atributos |
| `get_single_char/1` | lee una tecla sin esperar Enter; una flecha llega como tres códigos, y el fin de la entrada como −1 |
| `tty_size/2` | las filas y columnas de la terminal; un error si la salida no es una terminal |
| `char_code/2` | el carácter de un código, como átomo de un carácter |
| `atomics_to_string/2` | la cadena que une, en orden y sin separador, los átomos, cadenas y números de una lista (en las soluciones) |
| `exists_source/1` | el archivo o la biblioteca existe; con `:- if/1`, carga algo solo donde está |
| `new/2` | crea un objeto de XPCE y da su referencia, `@(N)` |
| `send/2`, `send/3`, `send/4` | pide a un objeto de XPCE una acción: `append`, `open`, `execute`, `label`, `selection` |
| `send_list/3` | la misma acción con cada elemento de una lista |
| `get/3`, `get/4` | pide a un objeto de XPCE un valor: `label`, `selection`, `member` |
| XPCE | `frame`, `dialog`, `button`, `menu`, `text_item`, `label`, `browser`, `menu_bar`, `popup`; `message(@(prolog), P, …)` llama a un predicado |
| `html//1` | traduce un término a HTML, con el texto escapado |
| `print_html/1` | escribe los fragmentos de `html//1` |
| `reply_html_page/2` | responde un pedido con una página: título y cuerpo |
| `http_redirect/3` | responde con una redirección; `see_other` es la 303 |
| `http_404/2` | responde que la dirección no existe |
| **[Patrón 51](../patrones.md#51-modelo-de-pantalla)** | modelo de pantalla: modelo puro, transición pura, un solo bucle que lee y escribe |
| `get_code/2` | el código del carácter siguiente de un stream; en las pruebas, las teclas desde un texto |
| `random_between/3` | un entero al azar entre dos límites: la semilla de una partida nueva |
| `tmp_file_stream/3`, `uri_components/2` | un archivo temporal abierto para escribir; las partes de una dirección; en las pruebas |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Un servidor que atiende a varios clientes a la vez, con sus hilos | [capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md) |
| El Buscaminas como problema de búsqueda: jugadas seguras | [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) |
| Un tablero en la terminal, redibujado en cada jugada | [capítulo 41](../capitulo-41-juegos/index.md) |
| La interfaz de pantalla completa de una aventura de texto | [capítulo 44](../capitulo-44-proyecto-aventura-de-texto/index.md) |
| Preguntas en castellano sobre *Inscripciones*, desde una interfaz | [capítulo 87](../capitulo-87-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- El manual de SWI-Prolog: `tty_size/2`
  ([en línea](https://www.swi-prolog.org/pldoc/man?predicate=tty_size/2)),
  `get_single_char/1`
  ([en línea](https://www.swi-prolog.org/pldoc/man?predicate=get_single_char/1)),
  la guía de XPCE, *Programming in XPCE/Prolog*
  ([en línea](https://www.swi-prolog.org/packages/xpce/UserGuide/)), y
  `library(http/html_write)`
  ([en línea](https://www.swi-prolog.org/pldoc/man?section=htmlwrite)). El
  capítulo toma de ahí los predicados, los objetos de XPCE y la
  representación de HTML como términos.
- Ecma International, *ECMA-48: Control Functions for Coded Character
  Sets*, 5.ª edición, 1991
  ([en línea](https://ecma-international.org/publications-and-standards/standards/ecma-48/)).
  Es la norma de las secuencias de escape de la
  [sección 36.2](#362-pantalla-completa-en-la-terminal).
- Leon Sterling y Ehud Shapiro, *The Art of Prolog*, 2.ª edición, MIT
  Press, 1994 — capítulo «Extra-Logical Predicates», apartado «Interactive
  Programs».
  [Edición en línea](https://archive.org/details/artofprologadvan00ster).
  El capítulo toma el bucle que lee una orden y la aplica al estado, y el
  estado de un editor partido en lo que está antes y después del cursor.
- Dennis Merritt, *Building Expert Systems in Prolog*, Springer, 1989;
  edición en línea de Amzi!, 2000 — capítulo «User Interface».
  [Edición en línea](https://www.amzi.com/ExpertSystemsInProlog/09userinterface.php).
  El capítulo toma la idea de ventanas, menús y formularios como objetos que
  responden a mensajes enviados por un único predicado, que en XPCE son
  `send/2` y `get/3`.
- Playwright para Python
  ([documentación](https://playwright.dev/python/)), con el que se prueban
  las páginas en un navegador.

El código del capítulo es propio, escrito para el curso sobre los módulos
del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md): las fuentes aportan predicados, normas e ideas, no
código copiado ni adaptado.
