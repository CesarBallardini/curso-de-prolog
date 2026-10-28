# Un editor de cláusulas

Esta página continúa la página
[Comparación con prolog_xref](xref.md#606-comparacion-con-libraryprolog_xref) del
[capítulo 60](index.md), con la [sección 60.7](#607-un-editor-de-clausulas): el
primero de los tres programas del apéndice de Kluźniak y Szpakowicz, un editor
de las cláusulas de un predicado, escrito con lo que SWI-Prolog ofrece hoy. El
ejemplo es `editor.pl`, en `ejemplos/capitulo-60/`, con sus pruebas; lee
comandos de un stream y cambia la base dinámica, y se ejecuta localmente.

## 60.7 Un editor de cláusulas

El editor del libro se invoca con `edit(Nombre/Aridad)` y trabaja sobre las
cláusulas que el intérprete tiene en memoria. Cada invocación tiene un
**cursor**, el número de una cláusula, que empieza en 0, antes de la primera.
Los comandos mueven el cursor (`+`, `-`, `t` al principio, `b` al final),
listan el predicado (`l`), borran la cláusula del cursor (`d`), insertan
después de ella las cláusulas que se escriben a continuación (`i`, hasta
`end.`) o las de un archivo, abren otra instancia del editor para otro
predicado (`e`), abren un intérprete anidado (`p`) y terminan (`x`). El libro
lee los comandos carácter por carácter, con primitivas de su intérprete, y
borra e inserta cláusulas por su número, con primitivas que SWI-Prolog no
tiene.

La versión del curso separa el estado del editor de la base de datos. El
estado es un término `editor(PI, Cursor, Clausulas)`, con las cláusulas del
predicado como una lista de términos `Cabeza :- Cuerpo`, y cada comando que lo
cambia es una cláusula de `comando/3`, una relación pura entre el estado
anterior y el siguiente:

<!-- ejemplo: capitulo-60/editor.pl predicado: comando/3 -->
```prolog
%!  comando(+Comando, +Estado0, -Estado) is semidet.
%
%   Estado es Estado0 después del Comando. b borra la cláusula del cursor,
%   que queda en la siguiente, o en la nueva última si borró la última; con
%   el cursor en 0 no borra nada. i(Cs) inserta Cs después del cursor, que
%   queda en la última insertada. Falla si Comando no es un comando que
%   cambia el estado.
comando(s, editor(PI, C0, Cs), editor(PI, C, Cs)) :-
    length(Cs, N),
    C is min(C0 + 1, N).
comando(a, editor(PI, C0, Cs), editor(PI, C, Cs)) :-
    C is max(C0 - 1, 0).
comando(p, editor(PI, _, Cs), editor(PI, 0, Cs)).
comando(u, editor(PI, _, Cs), editor(PI, N, Cs)) :-
    length(Cs, N).
comando(b, editor(PI, C0, Cs0), editor(PI, C, Cs)) :-
    (   C0 > 0
    ->  nth1(C0, Cs0, _, Cs),
        length(Cs, N),
        C is min(C0, N)
    ;   C = C0,
        Cs = Cs0
    ).
comando(i(Nuevas), editor(PI, C0, Cs0), editor(PI, C, Cs)) :-
    length(Antes, C0),
    append(Antes, Despues, Cs0),
    append([Antes, Nuevas, Despues], Cs),
    length(Nuevas, K),
    C is C0 + K.
```

Los comandos son términos de Prolog leídos con `read_term/3`, de modo que cada
uno termina con un punto. Por eso las letras reemplazan a los símbolos del
libro: `+.` no se lee como el átomo `+` seguido del punto final, sino como el
átomo `'+.'`, porque `+` y `.` son los dos caracteres simbólicos y se
agrupan en un solo nombre. Quedan `s` y `a` para la cláusula siguiente y la
anterior, `p` y `u` para el principio y la última, `b` para borrar, y `l`,
`i`, `e(PI)` y `x` como en el libro. `abrir/2` arma el estado con `clause/2`,
y `grabar/1` escribe la lista en la base:

<!-- ejemplo: capitulo-60/editor.pl predicado: grabar/1 -->
```prolog
%!  grabar(+Estado) is det.
%
%   Reemplaza en la base las cláusulas del predicado del Estado por las del
%   Estado, en una sola transacción.
grabar(editor(Nombre/Aridad, _, Clausulas)) :-
    functor(Cabeza, Nombre, Aridad),
    transaction(( retractall(Cabeza),
                  forall(member(C, Clausulas), assertz(C)) )).
```

`transaction/1`, presentado en la
[sección 38.3](../capitulo-38-concurrencia-y-paralelismo/index.md#383-estado-compartido),
hace que el reemplazo sea atómico: si una aserción fallara, las cláusulas
viejas seguirían en su lugar, y otro hilo nunca ve el predicado a medio
cambiar. La sesión lee un comando, lo ejecuta y muestra el cursor con
`portray_clause/1`, que escribe una cláusula como la escribiría `listing/1`.
`editar/1` lee de la entrada estándar; `editar_texto/2` lee los comandos de
un texto, y sirve para mostrar una sesión completa. La consulta
`editar_texto("s. s. b. l. i. nota(rosa, 10). end. x.", nota/2)` escribe, y
después responde `true`:

```text
nota/2 0: (antes de la primera)
nota/2 1: nota(ana, 7).
nota/2 2: nota(luis, 5).
nota/2 2: nota(eva, 8).
   1  nota(ana, 7).
>  2  nota(eva, 8).
nota/2 2: nota(eva, 8).
nota/2 3: nota(rosa, 10).
```

El cursor avanza a `luis`, el comando `b` lo borra y queda en `eva`, que
ocupa ahora su lugar; `l` lista el predicado con el cursor marcado, e `i`
inserta `nota(rosa, 10)` después de `eva` y deja el cursor en ella. Al
terminar, `nota/2` tiene las cláusulas de `ana`, `eva` y `rosa`, en ese
orden. Un comando `e(PI)` abre un editor anidado sobre el mismo stream; al
volver, el editor de afuera relee su predicado, porque el anidado pudo
cambiarlo, y deja el cursor donde estaba, o en la última cláusula si ahora
hay menos: es la regla del libro, «el cursor queda en su lugar salvo que el
procedimiento se modifique en una instancia anidada».

El intérprete anidado del libro, el comando `p`, no hace falta: el editor se
llama desde el toplevel de SWI-Prolog, que sigue disponible. Y para los
programas que están en archivos, SWI-Prolog ya trae lo que el editor del
libro suplía: `edit/1` abre el archivo en la línea de la primera cláusula
del predicado, y `make/0` vuelve a cargar lo que cambió, como explica la
[sección 14.1](../capitulo-14-el-entorno-de-trabajo/index.md#141-el-toplevel-como-herramienta).
El editor de cláusulas sirve para lo que no está en un archivo: los
predicados dinámicos que un programa construye mientras se ejecuta. El
[ejercicio 12](#ejercicios) agrega el comando del libro que inserta
las cláusulas de un archivo.

!!! question "Actividad"
    Predecir lo que escribe `editar_texto("u. a. b. b. b. l. x.", nota/2)`
    con los tres hechos originales de `nota/2`: dónde queda el cursor después
    de cada `b`, y qué hace el tercero. Comprobarlo, y volver a cargar
    `editor.pl` para recuperar los hechos.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; la revisión de estilo de la cuarta versión verifica el encabezado de cada predicado, y los once archivos de *Inscripciones* y los del capítulo pasan sin avisos |
    | C4 | `llamadas_de/3` con el predicado ligado no deja alternativas pendientes: usa `memberchk/2` en lugar de `member/2`, y las pruebas sin `nondet` lo verifican |
    | C6 | los análisis que terminan en `_de` son puros sobre listas de cláusulas y de términos leídos, y las formas que reciben el nombre del programa solo agregan `clausulas/2` y `raices/2`; leen archivos solo `leer_archivo/2` y `leer_programa/3`, escriben solo `escribir_arbol_de/2`, `informe_de/1` y `referencias_de/2`, y solo el intérprete de `perfil.pl` y `grabar/1` del editor modifican la base de datos; los comandos del editor son puros sobre su estado |
    | C7 | 137 pruebas en trece archivos, más una prueba de carga por cada archivo de la copia de *Inscripciones*; cada resultado se compara con otra fuente: el intérprete con la fórmula $n(n+1)/2$, las variables singulares con `read_term/3`, los predicados sin llamadas con `prolog_xref` |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

12. **(1)** El editor del libro tiene un comando que inserta después del
    cursor las cláusulas de un archivo. Escribir
    `insertar_archivo(+Archivo, +Estado0, -Estado)` con `comando/3` y
    `grabar/1` del editor, y explicar cómo se agrega a la sesión como el
    comando `f(Archivo)`.

## Resumen

| | |
|---|---|
| **programa como datos** | una lista de cláusulas `Cabeza :- Cuerpo`, o de términos leídos con su posición, sus nombres de variables y sus comentarios |
| **metas de un cuerpo** | se atraviesan las construcciones de control y se entra en los argumentos de las metallamadas, con los argumentos que cada una agrega |
| **grafo de llamadas** | un arco `P-Q` si una cláusula de `P` llama a `Q`; en `library(ugraphs)`, pares `Vertice-Sucesores` |
| **indefinido** | se llama, no se define y no es predefinido |
| **no usado** | definido y no alcanzable desde los puntos de entrada; distinto de «nadie lo llama» |
| **componente fuertemente conexa** | los predicados que se alcanzan entre sí; con un ciclo, recursión propia o mutua |
| **puntos de entrada** | lo que exporta cada módulo, las directivas como `'<carga>'/0`, las cláusulas para otro módulo y los ganchos de las bibliotecas |
| **conocimiento del sistema** | predefinidos y metallamadas, primero como tablas y después según el módulo `externo`; lo que falta produce falsos positivos |
| **árbol de llamadas** | preorden desde una raíz, un número por predicado y `(ver N)` para las repeticiones |
| **revisión de estilo** | singulares, repetidas, cláusulas separadas, encabezados y comentarios |
| **perfil** | un metaintérprete que cuenta las llamadas y escribe las de los predicados espiados |
| **dos formas de cada análisis** | la que termina en `_de` recibe la lista de cláusulas; la otra, el nombre del programa, y obtiene sus cláusulas y sus puntos de entrada con `clausulas/2` y `raices/2` |
| `metas/2`, `llamadas_de/3`, `llama_de/3`, `arcos/2` | la primera versión |
| `grafo/2`, `indefinidos_de/2`, `no_usados_de/3`, `componentes_de/2`, `arbol/3` | la segunda |
| `leer_archivo/2`, `programa/3`, `leer_programa/3`, `termino_leido/2` | la tercera |
| `revisar/2`, `revisar_archivos/2`, `revisar_texto_de/2` | la cuarta |
| `perfil/3`, `espiar/1`, `no_espiar/1` | la quinta |
| `informe_de/1`, `referencias_de/2` | el programa terminado |
| `vertices_edges_to_ugraph/3`, `vertices/2`, `edges/2`, `neighbours/3`, `reachable/3`, `transitive_closure/2`, `top_sort/2` | `library(ugraphs)` |
| `read_term/3`, `stream_position_data/3`, `dcg_translate_rule/2`, `open_string/2`, `set_module/1` | leer un programa sin cargarlo, y el módulo `externo` |
| `xref_source/2`, `xref_defined/3`, `xref_exported/2`, `xref_called/3` | `library(prolog_xref)` |
| `comando/3`, `grabar/1`, `editar/1` | el editor de cláusulas: el estado y sus comandos, la base y la sesión |
| `xref_clean/1` | descarta lo que `xref_source/2` registró de un archivo; en las pruebas |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Un intérprete de Prolog sobre una máquina con pila de metas y puntos de elección, que ejecuta los programas que este capítulo lee | [capítulo 62](../capitulo-62-proyecto-maquina-prolog/index.md) |
| El grafo de dependencias de un programa Datalog y sus componentes, para evaluarlo por estratos | [capítulo 86](../capitulo-86-proyecto-motor-datalog/index.md) |

## Referencias

- Feliks Kluźniak y Stanisław Szpakowicz, con Janusz S. Bień, *Prolog for
  Programmers*, Academic Press, 1985 — apéndice «Three Useful Programs»: «A
  simple editor».
  [Edición en línea en el sitio del coautor](https://www.site.uottawa.ca/~szpak/pub/P4P/Prolog_for_Programmers_neat.pdf).
  Del editor, la [sección 60.7](#607-un-editor-de-clausulas) toma el cursor, sus
  comandos, la inserción hasta `end.` y la instancia anidada que relee el
  predicado al volver.

El código del capítulo es propio, escrito para el curso: los programas del
apéndice dependen de primitivas del intérprete Toy-Prolog del libro, y se
tomaron de ellos las ideas y el formato del árbol de llamadas, no el código.
