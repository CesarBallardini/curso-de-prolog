# Capítulo 44 — Proyecto: una aventura de texto

Una aventura de texto es un juego en el que el jugador recorre un mundo
escribiendo órdenes —«ir a la biblioteca», «tomar la llave», «abrir la
puerta»— y el programa responde con frases que describen lo que pasa. Es un
programa pequeño que reúne casi todo lo que el curso enseñó por separado: un
mundo descrito con hechos, un estado que cambia con cada orden, una gramática
que entiende las órdenes, otra que redacta las respuestas, un bucle que lee de
la terminal y una pantalla que se redibuja. El capítulo lo construye en seis
versiones, cada una en su archivo y con sus pruebas; cada versión carga la
anterior como módulo y corrige lo que esa no podía hacer.

El proyecto parte de dos libros. El principal es *Adventure in Prolog*, de
Dennis Merritt, que enseña Prolog construyendo capítulo a capítulo un juego,
*Nani Search*; Amzi! lo publica en línea sin costo en
<https://www.amzi.com/AdventureInProlog/>. De él se toman la representación
del mundo con hechos de salas, objetos y puertas, y la conexión simétrica
entre salas (capítulos «Facts» y «Rules»); la contención recursiva de un
objeto dentro de otro («Recursion»); el estado del juego en la base dinámica
(«Managing Data»); las condiciones especiales que bloquean una orden, que el
libro llama *puzzles* («Cut»); el bucle de órdenes y la alternativa del estado
en argumentos («Control Structures»); y la interfaz en lenguaje natural, con
verbos que exigen un tipo de complemento, sinónimos, sustantivos de varias
palabras y una lectura que depende de la situación («Natural Language»). El
segundo es *Prolog Programming in Depth*, de Michael Covington, Donald Nute y
André Vellino, publicado por el autor en
<https://www.covingtoninnovations.com/books/PPID.pdf>: de sus apartados 2.13 y
5.5, «Constructing menus», se toma el menú generado a partir de una lista de
opciones, que vuelve a preguntar ante una respuesta que no es una de ellas. El
mundo, los textos y el código del capítulo son propios, en castellano.

El capítulo reutiliza la base de datos dinámica del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md), las
gramáticas del [capítulo 21](../capitulo-21-gramaticas-dcg/index.md), las gramáticas que construyen listas del
[capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md) y el módulo `pantalla` del [capítulo 36](../capitulo-36-interfaces-de-usuario/index.md), que carga sin
copiarlo. Cumple así los anuncios de esos dos últimos capítulos: las
respuestas construidas con gramáticas y la interfaz de pantalla completa. Todos
los ejemplos son módulos que cargan otros archivos, y la versión 6 dibuja en
la terminal: son `% solo-local`, y sus pruebas leen las órdenes de una cadena,
nunca del teclado.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- describir un mundo con hechos y derivar de ellos relaciones como la
  conexión entre salas y lo que está al alcance;
- mantener el estado de un programa detrás de una interfaz de pocos
  predicados, y expresar las reglas del juego como impedimentos y efectos;
- guardar y cargar ese estado como un archivo de hechos que se lee sin
  ejecutarse y se valida antes de usarse;
- escribir una gramática que entiende órdenes en castellano a partir de los
  nombres del mundo, y otra que redacta respuestas con artículos,
  concordancia de género y enumeraciones;
- escribir un bucle de juego y un menú que leen de un stream recibido como
  argumento, y probarlos con cadenas;
- montar una interfaz de pantalla completa sobre el modelo de pantalla del
  [capítulo 36](../capitulo-36-interfaces-de-usuario/index.md).

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:34 h**.
    Resolver los 5 ejercicios marcados con ★: **1:35 h**.
    Resolver los 12 ejercicios del final: **3:34 h**.

## 44.1 El programa terminado

El programa terminado se carga con `swipl ejemplos/capitulo-44/aventura.pl` y
se juega con `aventura.`: primero un menú, después la partida a pantalla
completa. `jugar.`, de la versión 5, juega la misma partida línea por línea.
Así se ve una partida corta en esa versión, con las órdenes tal como la
terminal las muestra al escribirlas. El juego se dirige al jugador en
segunda persona, con «tú» («Estás en el vestíbulo», «Tomas la llave de
bronce»); el texto del curso que lo rodea sigue siendo impersonal:

```text
1. Partida nueva
2. Continuar la partida guardada
3. Salir
Elige una opción, de 1 a 3: 1
Estás en el vestíbulo. Un vestíbulo con baldosas gastadas y olor a humedad. Ves un perchero. Desde aquí puedes ir a la biblioteca y al taller.
> ir a la biblioteca
Estás en la biblioteca. Estantes hasta el techo, casi todos vacíos. Ves un catálogo de estrellas y un escritorio. Desde aquí puedes ir a la cúpula y al vestíbulo.
> mirar en el escritorio
En el escritorio ves una llave de bronce.
> tomar la llave
Tomas la llave de bronce.
> volver al vestíbulo
Estás en el vestíbulo. Un vestíbulo con baldosas gastadas y olor a humedad. Ves un perchero. Desde aquí puedes ir a la biblioteca y al taller.
> abrir la puerta
Abres la puerta del taller.
> entrar en el taller
Estás en el taller. Herramientas oxidadas cuelgan de las paredes. Ves un banco de trabajo. Desde aquí puedes ir al sótano y al vestíbulo.
> tomar el banco
No puedes llevarte el banco de trabajo.
> guardar
Partida guardada en partida.partida.
> salir
Fin de la partida.
```

La versión 6 muestra lo mismo en tres recuadros que se redibujan después de
cada orden: el lugar, el inventario y las ocho últimas líneas de mensajes.
Esta es la pantalla después de tomar la linterna, abrir la trampilla y bajar
al sótano sin encenderla; la línea de abajo espera la orden siguiente:

```text
┌─ Lugar ──────────────────────────────────────────────────────┐
│ Está muy oscuro: no ves nada.                                │
└──────────────────────────────────────────────────────────────┘
┌─ Inventario ─────────────────────────────────────────────────┐
│ Llevas una linterna y una llave de bronce.                   │
└──────────────────────────────────────────────────────────────┘
┌─ Mensajes ───────────────────────────────────────────────────┐
│ paredes. Ves un banco de trabajo. Desde aquí puedes ir al    │
│ sótano y al vestíbulo.                                       │
│ > tomar la linterna                                          │
│ Tomas la linterna.                                           │
│ > abrir la trampilla                                         │
│ Abres la trampilla.                                          │
│ > bajar al sótano                                            │
│ Está muy oscuro: no ves nada.                                │
└──────────────────────────────────────────────────────────────┘
>
```

El mundo es un observatorio abandonado de cinco salas. La partida se gana
poniendo la lente, que está en un baúl cerrado del sótano oscuro, en el
telescopio de la cúpula; para llegar hace falta la llave de bronce del
escritorio, que abre el taller, y la linterna del taller, que alumbra el
sótano. Las secciones siguientes construyen el programa desde los hechos.

| Versión | Archivo | Agrega | Lo que no puede hacer todavía |
|---|---|---|---|
| 1 | `mundo.pl` | el mundo como hechos | nada cambia |
| 2 | `estado.pl` | el estado, las reglas del juego | la partida se pierde al terminar el proceso |
| 3 | `partidas.pl` | guardar y cargar | las órdenes son términos de Prolog |
| 4 | `lenguaje.pl` | órdenes y respuestas en castellano | cada orden es una consulta |
| 5 | `juego.pl` | el bucle y el menú de inicio | el texto se desplaza y se pierde de vista |
| 6 | `aventura.pl` | la pantalla completa | — |

## 44.2 Versión 1: el mundo como hechos

Todo lo que no cambia durante la partida es un hecho. Cada sala, puerta y
objeto tiene un nombre, que es un texto con tildes, y un género, que las
respuestas necesitan para elegir el artículo; el identificador es un átomo
sin tildes. Las salas llevan su descripción, y las puertas, las dos salas que
unen:

<!-- ejemplo: capitulo-44/mundo.pl fragmento: nombre(vestibulo, m, .. puerta(escalera, biblioteca, cupula). -->
```prolog
nombre(vestibulo, m, "vestíbulo").
nombre(biblioteca, f, "biblioteca").
nombre(taller, m, "taller").
nombre(sotano, m, "sótano").
nombre(cupula, f, "cúpula").
nombre(puerta_biblioteca, f, "puerta de la biblioteca").
nombre(puerta_taller, f, "puerta del taller").
nombre(trampilla, f, "trampilla").
nombre(escalera, f, "escalera").
nombre(perchero, m, "perchero").
nombre(escritorio, m, "escritorio").
nombre(llave, f, "llave de bronce").
nombre(catalogo, m, "catálogo de estrellas").
nombre(linterna, f, "linterna").
nombre(banco, m, "banco de trabajo").
nombre(baul, m, "baúl").
nombre(lente, f, "lente").
nombre(telescopio, m, "telescopio").

% sala(S, Descripcion): S es una sala, y Descripcion es lo que se ve en ella.
sala(vestibulo, "Un vestíbulo con baldosas gastadas y olor a humedad.").
sala(biblioteca, "Estantes hasta el techo, casi todos vacíos.").
sala(taller, "Herramientas oxidadas cuelgan de las paredes.").
sala(sotano, "Un sótano bajo, de paredes de piedra.").
sala(cupula, "La cúpula de metal está abierta hacia el cielo.").

% puerta(P, S1, S2): el paso P une las salas S1 y S2, en los dos sentidos.
puerta(puerta_biblioteca, vestibulo, biblioteca).
puerta(puerta_taller, vestibulo, taller).
puerta(trampilla, taller, sotano).
puerta(escalera, biblioteca, cupula).
```

Las propiedades de los objetos son hechos de un argumento: `fijo/1` (no se
puede llevar), `recipiente/1` (contiene otros objetos), `luz/1` (se enciende),
`oscura/1` (una sala sin luz propia) y `llave_de/2` (qué objeto abre qué
puerta). El estado inicial también está escrito con hechos, `inicio/1`, cuyo
argumento es un hecho del estado que la versión 2 guarda en la base: dónde
está el jugador, dónde está cada objeto y qué está cerrado. La meta, lo que
hay que conseguir para ganar, se escribe igual:

<!-- ejemplo: capitulo-44/mundo.pl fragmento: inicio(aqui(vestibulo)). .. meta(esta_en(lente, telescopio)). -->
```prolog
inicio(aqui(vestibulo)).
inicio(esta_en(perchero, vestibulo)).
inicio(esta_en(escritorio, biblioteca)).
inicio(esta_en(llave, escritorio)).
inicio(esta_en(catalogo, biblioteca)).
inicio(esta_en(banco, taller)).
inicio(esta_en(linterna, banco)).
inicio(esta_en(baul, sotano)).
inicio(esta_en(lente, baul)).
inicio(esta_en(telescopio, cupula)).
inicio(cerrada(puerta_taller)).
inicio(cerrada(trampilla)).
inicio(cerrada(baul)).

% meta(H): la partida se gana cuando vale el hecho H.
meta(esta_en(lente, telescopio)).
```

Un objeto está en una sala, dentro de un recipiente o en el inventario; el
lugar `jugador` es el inventario. Un solo predicado, `esta_en/2`, cubre los
tres casos, y la llave está en el escritorio, que está en la biblioteca.

Una puerta escrita una vez se recorre en los dos sentidos. `conecta/3` lo
dice con dos cláusulas, y `objeto/1` define los objetos como lo que tiene
nombre sin ser una sala ni un paso:

<!-- ejemplo: capitulo-44/mundo.pl predicado: conecta/3 objeto/1 -->
```prolog
%!  conecta(?P, ?S1, ?S2) is nondet.
%
%   El paso P lleva de la sala S1 a la sala S2, en cualquiera de los dos
%   sentidos en que está escrito.
conecta(P, S1, S2) :-
    puerta(P, S1, S2).
conecta(P, S1, S2) :-
    puerta(P, S2, S1).

%!  objeto(?O) is nondet.
%
%   O es un objeto: tiene nombre y no es una sala ni un paso.
objeto(O) :-
    nombre(O, _, _),
    \+ sala(O, _),
    \+ puerta(O, _, _).
```

```prolog
?- conecta(P, vestibulo, S).
P = puerta_biblioteca,
S = biblioteca ;
P = puerta_taller,
S = taller ;
false.

?- inicio(esta_en(O, biblioteca)).
O = escritorio ;
O = catalogo.
```

Los predicados de datos se declaran `multifile`: otro archivo puede agregar
salas, puertas u objetos con cláusulas como `mundo:sala(jardin, "…")`, sin
modificar `mundo.pl`. El ejercicio 2 lo usa. `mundo.plt` verifica además que
los datos sean coherentes: que cada puerta una dos salas, que todo lo que
aparece en el estado inicial tenga nombre y que haya un solo lugar inicial.

**Lo que falta.** Los hechos describen el mundo al empezar, pero nada los
cambia: tomar la llave tiene que sacarla del escritorio y ponerla en el
inventario.

## 44.3 Versión 2: el estado detrás de una interfaz

Lo que cambia son cuatro relaciones: `aqui/1`, `esta_en/2`, `cerrada/1` y
`encendido/1`. El módulo `estado` las declara dinámicas y aplica el
[Patrón 19](../patrones.md#19-estado-detras-de-una-interfaz): solo unos pocos predicados con nombre las modifican. `iniciar/0` y
`restablecer/1` cargan un estado entero, y cinco predicados de cambio
—`mover_a/1`, `trasladar/2`, `abrir_cosa/1`, `encender_cosa/1` y
`apagar_cosa/1`— hacen cada uno una modificación. El estado entero se
representa con la misma lista de hechos que usa `inicio/1`:

<!-- ejemplo: capitulo-44/estado.pl predicado: iniciar/0 instantanea/1 restablecer/1 -->
```prolog
%!  iniciar is det.
%
%   Deja el estado de una partida nueva: los hechos de inicio/1.
iniciar :-
    findall(H, inicio(H), Hs),
    restablecer(Hs).

%!  instantanea(-Hechos:list) is det.
%
%   Hechos son los hechos del estado actual, ordenados.
instantanea(Hechos) :-
    findall(H, vale(H), Hs),
    sort(Hs, Hechos).

%!  restablecer(+Hechos:list) is det.
%
%   Reemplaza el estado por Hechos. Produce un error de dominio, sin
%   cambiar nada, si un hecho no es un hecho de estado válido o si Hechos
%   no tiene exactamente un aqui/1.
restablecer(Hechos) :-
    must_be(list, Hechos),
    maplist(validar_hecho, Hechos),
    (   aggregate_all(count, member(aqui(_), Hechos), 1)
    ->  true
    ;   domain_error(estado_con_un_lugar, Hechos)
    ),
    retractall(aqui(_)),
    retractall(esta_en(_, _)),
    retractall(cerrada(_)),
    retractall(encendido(_)),
    maplist(assertz, Hechos).
```

`restablecer/1` valida todos los hechos antes de borrar nada: un hecho que no
es de estado, o que nombra una cosa que el mundo no tiene, produce un error y
deja la partida como estaba. Las pruebas usan `restablecer/1` para preparar
cualquier situación sin recorrer el juego hasta ella.

**Lo que está al alcance.** Un objeto se puede tomar si está en la sala, en el
inventario o dentro de un recipiente abierto que a su vez está al alcance; una
puerta, si es una de las de la sala. Es la contención recursiva de Merritt,
con la condición del recipiente abierto:

<!-- ejemplo: capitulo-44/estado.pl predicado: al_alcance/1 accesible/1 a_oscuras/0 -->
```prolog
%!  al_alcance(?X) is nondet.
%
%   X es un paso de la sala actual, o un objeto que está en la sala, en el
%   inventario o dentro de un recipiente abierto que está al alcance.
al_alcance(X) :-
    aqui(S),
    conecta(X, S, _).
al_alcance(X) :-
    esta_en(X, L),
    accesible(L).

%!  accesible(+L) is semidet.
%
%   Lo que está en L está al alcance.
accesible(jugador).
accesible(S) :-
    aqui(S).
accesible(R) :-
    recipiente(R),
    \+ cerrada(R),
    al_alcance(R).

%!  a_oscuras is semidet.
%
%   La sala actual es oscura y ninguna luz encendida está al alcance.
a_oscuras :-
    aqui(S),
    oscura(S),
    \+ ( luz(L), encendido(L), al_alcance(L) ).
```

**Las reglas del juego.** Una orden es un término: `mirar`, `ir(Sala)`,
`tomar(Objeto)`, `poner(Objeto, Recipiente)`, `abrir(Cosa)`… `realizar/2` la
ejecuta en dos pasos. Primero busca un impedimento; si lo hay, la respuesta es
`no_puede(Motivo)` y el estado no cambia. Si no, aplica el efecto de la orden:

<!-- ejemplo: capitulo-44/estado.pl predicado: realizar/2 -->
```prolog
%!  realizar(+Orden, -Respuesta) is det.
%
%   Ejecuta Orden sobre el estado. Respuesta es no_puede(Motivo) si un
%   impedimento la bloquea, y el resultado de su efecto si no. Produce un
%   error de dominio si Orden no es una orden.
realizar(Orden, Respuesta) :-
    (   es_orden(Orden)
    ->  true
    ;   domain_error(orden, Orden)
    ),
    (   impedimento(Orden, Motivo)
    ->  Respuesta = no_puede(Motivo)
    ;   efecto(Orden, Respuesta)
    ).
```

Los impedimentos son una relación, `impedimento(Orden, Motivo)`, con una
cláusula por regla del juego. Algunas se aplican a una sola orden; otras, a
toda una familia, que un hecho auxiliar describe: `requiere_luz/1` dice qué
órdenes no se pueden hacer a oscuras, y `se_alcanza/2`, qué cosa tiene que
estar al alcance:

<!-- ejemplo: capitulo-44/estado.pl fragmento: impedimento(ir(S), ya_esta(S)) .. impedimento(tomar(O), ya_lo_tiene(O)) -->
```prolog
impedimento(ir(S), ya_esta(S)) :-
    aqui(S).
impedimento(ir(S), no_hay_paso(S)) :-
    aqui(A),
    \+ conecta(_, A, S).
impedimento(ir(S), cerrado(P)) :-
    aqui(A),
    conecta(P, A, S),
    cerrada(P).
impedimento(Orden, oscuro) :-
    requiere_luz(Orden),
    a_oscuras.
impedimento(Orden, no_lo_tiene(O)) :-
    se_lleva(Orden, O),
    \+ esta_en(O, jugador).
impedimento(Orden, no_esta(X)) :-
    se_alcanza(Orden, X),
    \+ al_alcance(X).
impedimento(tomar(O), ya_lo_tiene(O)) :-
```

`realizar/2` usa el primer impedimento, así que el orden de las cláusulas
decide qué aviso se da cuando hay varios: en el sótano a oscuras, «tomar la
lente» responde que está oscuro, no que la lente está dentro de un baúl
cerrado. Es el *puzzle* de Merritt generalizado: allí era un predicado con
cortes que imprimía el aviso; aquí es una relación sin efectos, que se
consulta, se prueba y se extiende con una cláusula. Los efectos, uno por
orden, llaman a los predicados de cambio y dan la respuesta como término:

```prolog
?- iniciar, realizar(mirar, R).
R = vista(vestibulo, [perchero], [biblioteca, taller]).

?- iniciar, realizar(ir(taller), R).
R = no_puede(cerrado(puerta_taller)).

?- iniciar, realizar(ir(biblioteca), _), realizar(tomar(llave), R1), realizar(ir(vestibulo), _), realizar(abrir(puerta_taller), R2), realizar(ir(taller), R3).
R1 = tomado(llave),
R2 = abierto(puerta_taller),
R3 = vista(taller, [banco], [sotano, vestibulo]).
```

Las respuestas son términos y no texto: el núcleo no sabe castellano, y las
pruebas comparan términos. `estado.plt` recorre la partida entera con
dieciséis órdenes y verifica `ganado/0` al final.

!!! example "Patrón 57 — Impedimento y efecto"
    **Problema.** Una orden cambia el estado de un programa, pero solo
    cuando las reglas lo permiten; si no, hay que decir por qué, sin haber
    cambiado nada.

    **Versión ingenua.** Cada orden comprueba sus condiciones dentro del
    mismo predicado que la ejecuta, con cortes que imprimen el aviso y
    cambios del estado intercalados. Las reglas no se pueden consultar sin
    ejecutar la orden, una condición que falla después del primer cambio
    deja el estado a medio modificar, y agregar una regla obliga a tocar
    cada orden a la que se aplica.

    **Patrón.** Las reglas son una relación sin efectos,
    `impedimento(Orden, Motivo)`, con una cláusula por regla; una cláusula
    puede abarcar una familia de órdenes a través de un hecho auxiliar,
    como `requiere_luz/1`. `realizar/2` la consulta primero y, si no hay
    impedimento, aplica un solo efecto, `efecto/2`. El orden de las
    cláusulas decide qué aviso se da cuando hay varios. Como la relación
    no cambia nada, también sirve para otras preguntas: `entender/2`, en la
    [sección 44.5](#445-version-4-ordenes-y-respuestas-en-castellano), elige
    la lectura de una orden que ningún impedimento bloquea.

    **Cuándo no usarlo.** Cuando lo que impide la orden solo se conoce al
    intentarla, como abrir un archivo: ahí decide el sistema, y la
    respuesta es un error; lo que sí se comprueba antes es la validez de
    los datos ([Patrón 31](../patrones.md#31-validar-al-entrar)), como hace
    `cargar/1` en la
    [sección 44.4](#444-version-3-guardar-y-cargar-una-partida). Y cuando una
    orden tiene una sola condición y un solo aviso: un `->` en el propio
    predicado alcanza.

!!! question "Actividad"
    Predecir la respuesta de `realizar(tomar(lente), R)` en tres situaciones,
    preparadas con `restablecer/1`: el jugador en el sótano con la linterna
    apagada en el inventario; con la linterna encendida y el baúl cerrado; y
    con el baúl abierto. Comprobarlo, y explicar cada respuesta con las
    cláusulas de `impedimento/2`.

**Lo que falta.** El estado vive en la base de datos del proceso: al salir de
Prolog, la partida se pierde.

## 44.4 Versión 3: guardar y cargar una partida

La instantánea ya es una lista de hechos, y los hechos se escriben como
cláusulas con `portray_clause/2`. Una partida guardada es un archivo de texto
con un hecho por línea:

```text
aqui(biblioteca).
cerrada(baul).
cerrada(puerta_taller).
cerrada(trampilla).
esta_en(banco, taller).
esta_en(baul, sotano).
esta_en(catalogo, biblioteca).
esta_en(escritorio, biblioteca).
esta_en(lente, baul).
esta_en(linterna, banco).
esta_en(llave, jugador).
esta_en(perchero, vestibulo).
esta_en(telescopio, cupula).
```

Cargarla podría ser consultar el archivo, pero `consult/1` ejecuta lo que
encuentra: una directiva `:- halt.` en un archivo dañado o preparado a
propósito terminaría el programa, y las cláusulas quedarían en el módulo
`user`, no en `estado`. `cargar/1` lee los términos con `read_term/3`, que
solo los analiza, y los pasa a `restablecer/1`, que los valida
([Patrón 31](../patrones.md#31-validar-al-entrar)):

<!-- ejemplo: capitulo-44/partidas.pl predicado: guardar/1 cargar/1 leer_terminos/2 -->
```prolog
%!  guardar(+Archivo) is det.
%
%   Escribe en Archivo los hechos del estado actual, uno por línea.
guardar(Archivo) :-
    instantanea(Hechos),
    setup_call_cleanup(
        open(Archivo, write, Out, [encoding(utf8)]),
        forall(member(H, Hechos), portray_clause(Out, H)),
        close(Out)).

%!  cargar(+Archivo) is det.
%
%   Reemplaza el estado por los hechos de Archivo. Produce un error, y no
%   cambia el estado, si Archivo no existe, no es texto Prolog válido o
%   tiene términos que no son hechos de estado.
cargar(Archivo) :-
    setup_call_cleanup(
        open(Archivo, read, In, [encoding(utf8)]),
        leer_terminos(In, Hechos),
        close(In)),
    restablecer(Hechos).

%!  leer_terminos(+In, -Terminos:list) is det.
%
%   Terminos son los términos que quedan por leer en el stream In.
leer_terminos(In, Terminos) :-
    read_term(In, T, []),
    (   T == end_of_file
    ->  Terminos = []
    ;   Terminos = [T|Ts],
        leer_terminos(In, Ts)
    ).
```

`partidas.plt` escribe archivos temporales con `tmp_file/2` y los borra al
terminar. Una de sus pruebas carga un archivo que empieza con `:- halt.`:

```prolog
test(no_ejecuta_directivas, [ error(domain_error(hecho_de_estado,
                                                 (:- halt))),
                              cleanup(assertion(aqui(vestibulo))) ]) :-
    iniciar,
    con_archivo(A, ( escribir(A, ":- halt.\naqui(cupula).\n"), cargar(A) )).
```

La directiva llega a `restablecer/1` como el término `:-(halt)`, que no es un
hecho de estado; el error sale antes de que nada cambie, y el jugador sigue en
el vestíbulo.

!!! question "Actividad"
    Predecir qué pasa al cargar un archivo que contiene solamente
    `aqui(cupula).`: ¿produce un error? ¿Qué objetos quedan en el mundo, y
    qué responde `realizar(mirar, R)`? Comprobarlo, y proponer qué
    verificación agregaría `restablecer/1` para rechazar ese archivo.

**Lo que falta.** Las órdenes se escriben como términos de Prolog, con
paréntesis y con los identificadores del programa: `realizar(tomar(llave),
R)`, no «tomar la llave de bronce».

## 44.5 Versión 4: órdenes y respuestas en castellano

La versión 4, `lenguaje.pl`, agrega dos gramáticas. La primera entiende las
órdenes: `palabras/2` pasa el texto a minúsculas y sin tildes, y `orden//1`
relaciona las palabras con un término de `realizar/2`. Los verbos son datos,
con sus sinónimos, y los sustantivos salen de los nombres del mundo; el
artículo concuerda con el género, y cada verbo exige su tipo de complemento.
Cuando una orden tiene varias lecturas, como «abrir la puerta» en el
vestíbulo, `entender/2` elige la primera que ningún impedimento bloquea. La
segunda gramática, `respuesta//1`, redacta cada respuesta como una lista de
códigos, con artículos por género, la contracción «al»,
terminaciones que concuerdan y enumeraciones con comas y «y»; es la
construcción de listas con gramáticas de la
[sección 34.5](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#345-las-gramaticas-como-listas-diferencia). `ejecutar/2` une las dos:

<!-- ejemplo: capitulo-44/lenguaje.pl predicado: ejecutar/2 -->
```prolog
%!  ejecutar(+Texto:string, -Salida:string) is det.
%
%   Entiende la orden Texto, la ejecuta y da el texto de la respuesta.
ejecutar(Texto, Salida) :-
    entender(Texto, Orden),
    responder(Orden, Salida).
```

```prolog
?- iniciar, ejecutar("ir al taller", S).
S = "La puerta del taller está cerrada.".
```

La página [Órdenes y respuestas en castellano](lenguaje.md#ordenes-y-respuestas-en-castellano)
desarrolla la versión entera, con una actividad.

**Lo que falta.** Cada orden es una consulta en el intérprete de Prolog. Un
juego necesita un bucle que lea una orden tras otra hasta que la partida
termine.

## 44.6 Versión 5: el bucle del juego y el menú de inicio

`partida/1` lee una línea, la entiende, escribe la respuesta y sigue, hasta que
la orden es `salir`, la partida está ganada o la entrada se termina. El
stream de entrada es un argumento: `jugar/0` le pasa el teclado, y las pruebas,
un stream sobre una cadena abierto con `open_string/2`, como en la
[sección 36.2](../capitulo-36-interfaces-de-usuario/index.md#362-pantalla-completa-en-la-terminal):

<!-- ejemplo: capitulo-44/juego.pl predicado: partida/1 -->
```prolog
%!  partida(+In) is det.
%
%   Lee órdenes de In, una por línea, y escribe sus respuestas, hasta que
%   la orden es salir, la partida está ganada o In se termina.
partida(In) :-
    format("> "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Orden = salir
    ;   entender(Linea, Orden)
    ),
    responder(Orden, Texto),
    format("~w~n", [Texto]),
    (   (   Orden == salir
        ;   ganado
        )
    ->  true
    ;   partida(In)
    ).
```

El bucle es recursivo, y la llamada recursiva es la última: la pila no crece
con la cantidad de órdenes. Merritt escribe su primer bucle con `repeat/0` y
una falla al final ([Patrón 7](../patrones.md#7-bucle-por-falla)); aquí la recursión no cambia nada, porque
el estado está en la base de datos, pero deja abierta la posibilidad de pasar
algo de una orden a la siguiente, como pide el ejercicio 12.

El menú de inicio es el de Covington: `menu/3` recibe una lista de
`opcion(Texto, Valor)`, las muestra numeradas y lee el número de una. Si la
respuesta no es un número de la lista, lo dice y vuelve a preguntar; si la
entrada se termina, elige la última opción, que es salir:

<!-- ejemplo: capitulo-44/juego.pl predicado: menu/3 -->
```prolog
%!  menu(+In, +Opciones:list, -Valor) is det.
%
%   Muestra Opciones, una lista de opcion(Texto, Valor) numeradas desde 1,
%   y lee de In el número de una. Valor es el de la opción elegida; si la
%   respuesta no es un número de la lista, vuelve a preguntar. Si In se
%   termina, Valor es el de la última opción.
menu(In, Opciones, Valor) :-
    forall(nth1(I, Opciones, opcion(Texto, _)),
           format("~d. ~w~n", [I, Texto])),
    length(Opciones, Cantidad),
    format("Elige una opción, de 1 a ~d: ", [Cantidad]),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  last(Opciones, opcion(_, Valor))
    ;   normalize_space(atom(Respuesta), Linea),
        atom_number(Respuesta, N),
        integer(N),
        nth1(N, Opciones, opcion(_, V))
    ->  Valor = V
    ;   format("La respuesta no es una de las opciones.~n"),
        menu(In, Opciones, Valor)
    ).
```

Covington lee una sola tecla y la compara con los códigos de los dígitos; aquí
se lee una línea, porque el resto del juego también lee líneas y porque así el
menú se prueba con la misma cadena que la partida. `jugar/1` une las dos
cosas: el menú, `preparar/2` para la partida nueva o la guardada, y
`partida/1`. Una prueba de `juego.plt` juega con la entrada `"1\nsalir\n"` y
compara las líneas escritas con las esperadas.

**Lo que falta.** Las respuestas se escriben una debajo de otra y se desplazan:
para saber dónde se está o qué se lleva hay que volver a preguntarlo.

## 44.7 Versión 6: pantalla completa

La versión 6 aplica el [Patrón 51](../patrones.md#51-modelo-de-pantalla) con el módulo `pantalla` del
[capítulo 36](../capitulo-36-interfaces-de-usuario/index.md), que carga con `use_module('../capitulo-36/texto/pantalla')`.
El modelo, `pantalla/2`, da las líneas de tres recuadros: el lugar y el
inventario, redactados por la gramática de respuestas, y los últimos mensajes.
No escribe nada, y por eso la prueba `pantalla_inicial` lo compara línea por
línea con la pantalla esperada:

<!-- ejemplo: capitulo-44/aventura.pl predicado: pantalla/2 -->
```prolog
%!  pantalla(+Mensajes:list(string), -Lineas:list(string)) is det.
%
%   Lineas es la pantalla: el lugar y el inventario, con los textos de
%   mirar e inventario, y Mensajes, cada uno en su recuadro.
pantalla(Mensajes, Lineas) :-
    ancho(Ancho),
    responder(mirar, Lugar),
    partir(Lugar, Ancho, Lineas1),
    responder(inventario, Inventario),
    partir(Inventario, Ancho, Lineas2),
    maplist(recuadro(Ancho),
            ["Lugar", "Inventario", "Mensajes"],
            [Lineas1, Lineas2, Mensajes],
            Cajas),
    append(Cajas, Lineas).
```

`responder(mirar, …)` ejecuta una orden, pero `mirar` e `inventario` no tienen
impedimentos ni cambian el estado: el modelo solo consulta. `partir/3` reparte
las palabras de un texto en líneas de sesenta columnas, y `recuadro/4`
completa cada línea con blancos para que los tres recuadros tengan el mismo
ancho.

A diferencia del Buscaminas del [capítulo 36](../capitulo-36-interfaces-de-usuario/index.md), que responde a cada tecla,
aquí las órdenes se escriben enteras y se terminan con Enter: el bucle dibuja,
lleva el cursor a la fila de abajo de los recuadros, escribe `> ` y lee una
línea. Los mensajes son la única información que pasa de una vuelta a la
siguiente, y viajan en un argumento; `agregar_mensajes/4` agrega el eco de la
orden y la respuesta partida en líneas, y conserva las ocho últimas:

<!-- ejemplo: capitulo-44/aventura.pl predicado: bucle/2 -->
```prolog
%!  bucle(+In, +Mensajes:list(string)) is det.
%
%   Dibuja la pantalla con Mensajes, lee una orden de In, la ejecuta y
%   sigue, hasta que la orden es salir, la partida está ganada o In se
%   termina.
bucle(In, Mensajes0) :-
    pantalla(Mensajes0, Lineas),
    dibujar(Lineas),
    length(Lineas, N),
    Fila is N + 1,
    ir_a(Fila, 1),
    format("> "),
    flush_output,
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Orden = salir,
        Eco = "salir"
    ;   entender(Linea, Orden),
        Eco = Linea
    ),
    responder(Orden, Texto),
    agregar_mensajes(Mensajes0, Eco, Texto, Mensajes),
    (   (   Orden == salir
        ;   ganado
        )
    ->  pantalla(Mensajes, Final),
        dibujar(Final),
        nl
    ;   bucle(In, Mensajes)
    ).
```

Las pruebas de `aventura.plt` hacen correr el bucle con las dieciséis órdenes
de la partida en una cadena, capturan lo que escribe con `with_output_to/2`,
separan las pantallas por la secuencia de borrado `\e[2J` y buscan en la
última la orden ganadora y su respuesta. Lo que la terminal muestra al
recibir esas secuencias no lo verifica ninguna prueba; como en el
[capítulo 36](../capitulo-36-interfaces-de-usuario/index.md), en Windows las secuencias de posición del cursor no se dan por
verificadas.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `realizar/2`, `entender/2`, `responder/2` y los no terminales de las respuestas son `det`, y las pruebas, que fallan si queda una alternativa pendiente, lo confirman |
    | C5 | una orden desconocida, un hecho de estado inválido o un archivo de partida dañado producen un error de dominio, de sintaxis o de existencia; `restablecer/1` valida antes de cambiar nada |
    | C6 | el estado cambia solo en `iniciar/0`, `restablecer/1` y los cinco predicados de cambio; `impedimento/2` y los modelos de respuesta y de pantalla no escriben; la lectura y la escritura están en `partida/1`, `menu/3` y `bucle/2`, que reciben el stream como argumento |
    | C7 | 70 pruebas en seis archivos: la coherencia de los datos, cada impedimento, la ida y vuelta de la instantánea y de un archivo, las dos gramáticas en los dos sentidos, el menú y la partida entera con la entrada en una cadena, y la pantalla comparada línea por línea |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios extienden el programa: cada solución es un
archivo que carga los del capítulo, sin modificarlos.

1. ★ **(1)** Predecir el texto que responde `ejecutar/2`, desde una partida
   nueva, a cada orden de esta secuencia, y comprobarlo: «tomar el
   perchero» · «ir al sótano» · «biblioteca» · «abrir el escritorio» ·
   «mirar en el escritorio» · «subir a la cúpula» · «poner el catálogo en el
   telescopio».
2. ★ **(2)** Agregar al mundo un jardín, al que se sale desde el vestíbulo
   por una puerta de vidrio cerrada que no necesita llave, con una regadera
   que se puede llevar. Escribir solo hechos, en un archivo aparte, con
   cláusulas `mundo:…`, y comprobar con `ejecutar/2` que el jardín se
   recorre y la regadera se toma sin cambiar ningún predicado.
3. **(1)** Agregar los sinónimos «recoger» y «levantar» para tomar, y
   «terminar» para salir, en un archivo aparte. ¿Por qué no hace falta
   tocar `orden//1`?
4. **(2)** Hacer que «sacar la lente del baúl» se entienda: una orden de
   tomar puede nombrar, después del objeto, el recipiente de donde sale, con
   «de» o «del». La orden se entiende solo si el objeto está en ese
   recipiente.
5. ★ **(2)** Órdenes compuestas: «tomar la llave y abrir la puerta del
   taller» ejecuta las dos órdenes, en ese orden, y responde con las dos
   respuestas. Si una orden de la secuencia está bloqueada, las siguientes
   no se ejecutan.
6. **(2)** Limitar la partida a una cantidad de órdenes: escribir
   `partida_con_limite(+In, +Maximo)`, un bucle como `partida/1` que lleva
   la cuenta en un argumento y, al llegar a `Maximo` sin ganar, termina con
   el texto «Se terminó el tiempo.».
7. ★ **(2)** Escribir la orden «tomar todo», que toma, en una sola orden,
   cada objeto al alcance que se puede llevar y no está en el inventario, y
   responde con una oración por objeto; si no hay ninguno, responde «No hay
   nada para tomar.».
8. **(1)** El encabezado de `al_alcance/1` declara un solo modo,
   `al_alcance(?X) is nondet`. Escribir la línea del modo con `X`
   instanciado, con su determinación, y justificarla con los datos del
   mundo y las cláusulas de `al_alcance/1` y `accesible/1`.
9. **(2)** Versionar el formato de las partidas: `guardar_con_formato/1`
   escribe primero el hecho `formato(aventura, 1)`, y
   `cargar_con_formato/1` rechaza, con un error de dominio y sin cambiar el
   estado, un archivo que no empieza con ese hecho.
10. ★ **(3)** Escribir el núcleo con el estado en argumentos, como la
    versión de «Control Structures» de Merritt: `paso(+Orden, +Estado0,
    -Estado, -Respuesta)` para `mirar`, `ir/1`, `tomar/1` y `dejar/1`, donde
    el estado es la lista de hechos de `instantanea/1`. Verificar, sobre una
    secuencia de órdenes, que da las mismas respuestas y el mismo estado final
    que `realizar/2`.
11. **(2)** Escribir `menu_por_inicial(+In, +Opciones, -Valor)`, un menú en
    el que se elige escribiendo la inicial de la opción, como propone el
    ejercicio 5.5.3 de Covington. ¿Qué hace si dos opciones empiezan con la
    misma letra?
12. **(3)** Agregar la orden «deshacer», que vuelve al estado anterior a la
    última orden que lo cambió. Escribir un bucle
    `partida_con_deshacer(+In)` que lleva en un argumento la pila de
    instantáneas.

## Resumen

| | |
|---|---|
| **mundo como hechos** | nombres con género, salas, puertas y propiedades; el estado inicial, `inicio/1`, con los mismos términos que el estado del juego |
| **estado detrás de una interfaz** | cuatro predicados dinámicos que solo cambian `iniciar/0`, `restablecer/1` y cinco predicados de cambio ([Patrón 19](../patrones.md#19-estado-detras-de-una-interfaz)) |
| **[Patrón 57](../patrones.md#57-impedimento-y-efecto)** | impedimento y efecto: las reglas del juego como una relación sin efectos, consultada antes de aplicar un solo efecto; el orden de las cláusulas decide el aviso |
| **instantánea** | la lista ordenada de los hechos del estado; sirve para probar, guardar, cargar y deshacer |
| **cargar sin ejecutar** | `read_term/3` analiza los términos; `restablecer/1` los valida antes de cambiar nada |
| **gramática de órdenes** | verbos como datos, sustantivos tomados de los nombres del mundo, tipos de complemento, contracciones y concordancia |
| **lectura según la situación** | entre las lecturas de una orden, la primera que ningún impedimento bloquea |
| **gramática de respuestas** | artículos por género, «al» y «a la», terminaciones de adjetivos y enumeraciones, generados como lista de códigos |
| **bucle y menú** | leen líneas de un stream recibido como argumento; se prueban con `open_string/2` |
| `same_length/2` | dos listas de la misma longitud (en las soluciones) |
| **pantalla completa** | el modelo de pantalla del [capítulo 36](../capitulo-36-interfaces-de-usuario/index.md) con tres recuadros; el bucle lleva los mensajes en un argumento |
| `mundo.pl`, `estado.pl`, `partidas.pl` | el mundo, el estado y las partidas guardadas |
| `lenguaje.pl`, `juego.pl`, `aventura.pl` | el castellano, el bucle y el menú, y la pantalla completa |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Órdenes en castellano traducidas a operaciones con archivos y procesos | [capítulo 56](../capitulo-56-proyecto-ordenes-castellano/index.md) |
| Diálogos en castellano con plantillas de respuesta | [capítulo 55](../capitulo-55-proyecto-dialogos-plantillas/index.md) |
| Preguntas en castellano sobre una base de datos | [capítulo 87](../capitulo-87-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- Dennis Merritt, *Adventure in Prolog*, Springer-Verlag, 1990 — «Facts»,
  «Rules», «Managing Data», «Recursion», «Cut», «Control Structures»,
  «Natural Language» y el apéndice con el juego *Nani Search*.
  [Edición en línea](https://www.amzi.com/AdventureInProlog/), de Amzi!.
  El capítulo toma de allí las ideas y la representación del juego: el
  mundo como hechos de salas, objetos y puertas con una conexión simétrica,
  la contención recursiva, el estado en la base dinámica, las condiciones
  que bloquean una orden (*puzzles*), el bucle de órdenes con su variante de
  estado en argumentos y la interfaz en lenguaje natural con verbos
  tipados, sinónimos y lectura según la situación.
- Michael A. Covington, Donald Nute y André Vellino, *Prolog Programming in
  Depth*, Prentice Hall, 1997 — apartados 2.13 y 5.5, «Constructing menus».
  [Edición en línea](https://www.covingtoninnovations.com/books/PPID.pdf).
  El capítulo toma el menú generado a partir de una lista de opciones, que
  vuelve a preguntar ante una respuesta inválida, y un ejercicio sobre la
  elección por inicial.

El código del capítulo es propio, escrito para el curso: el mundo, los
textos en castellano y los programas son nuevos, y de Merritt y de Covington
se toman ideas y representaciones, no código.
