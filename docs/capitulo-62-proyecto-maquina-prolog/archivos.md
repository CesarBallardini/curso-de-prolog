# Los programas de otros capítulos, la negación y los errores

Esta página continúa la página
[Una pila de alternativas, el almacén, el corte y la indexación](alternativas.md#627-el-programa-compilado) del
[capítulo 62](index.md), con las secciones [62.8](#628-los-programas-de-otros-capitulos) y
[62.9](#629-la-negacion-y-los-errores): la máquina terminada sobre archivos de otros
capítulos, y la séptima versión, que agrega la negación y el manejo de
errores. Los ejemplos son `maquina.pl`, que lee archivos, y `negacion.pl`, en
`ejemplos/capitulo-62/`, con sus pruebas; se ejecutan localmente.

## 62.8 Los programas de otros capítulos

La máquina ejecuta también archivos de otros capítulos, leídos sin cargarlos
con el lector del [capítulo 60](../capitulo-60-proyecto-analisis-programas/index.md), y compara sus respuestas con las de Prolog.

### Ejecutar un archivo

`ejecutar_archivo/2` lee un archivo de Prolog con `leer_archivo/2` y
`programa/3` del [capítulo 60](../capitulo-60-proyecto-analisis-programas/index.md), sin cargarlo, descarta las directivas y
ejecuta la consulta en la versión 5:

<!-- ejemplo: capitulo-62/maquina.pl predicado: ejecutar_archivo/2 -->
```prolog
%!  ejecutar_archivo(+Archivo, ?Meta) is nondet.
%
%   Meta se prueba en la versión 5 de la máquina con las cláusulas del
%   Archivo, una especificación como ejemplos('capitulo-06/antepasados'),
%   leídas con leer_archivo/2 y programa/3 del capítulo 60. Las directivas
%   del archivo no se ejecutan.
ejecutar_archivo(Archivo, Meta) :-
    absolute_file_name(Archivo, Ruta,
                       [file_type(prolog), access(read)]),
    leer_archivo(Ruta, Leidos),
    programa(Leidos, Clausulas0, _),
    exclude(directiva, Clausulas0, Clausulas1),
    maplist(con_cuerpo, Clausulas1, Clausulas),
    almacen:resolver_clausulas(indice, Clausulas, Meta).
```

`ejemplos(...)` es una especificación de archivo relativa al directorio de
los ejemplos del curso. Con los predicados de listas del [capítulo 7](../capitulo-07-listas/index.md):

```prolog
?- ejecutar_archivo(ejemplos('capitulo-07/recorrer'), concatenar(X, Y, [a, b])).
X = [],
Y = [a, b] ;
X = [a],
Y = [b] ;
X = [a, b],
Y = [] ;
false.
```

### Comparar con Prolog

`igual_que_prolog/3` compara las respuestas de una versión con las que da
Prolog con el mismo programa cargado en un módulo temporal, en el mismo
orden:

```prolog
?- igual_que_prolog(indice, listas, invertir_hasta(20, _)).
true.

?- igual_que_prolog(compilado, familia, antepasado(_, _)).
true.
```

Las pruebas de cada versión hacen esta comparación con los programas del
capítulo; el [ejercicio 11](#ejercicios) la hace con un archivo del [capítulo 7](../capitulo-07-listas/index.md).

## 62.9 La negación y los errores

Las fuentes describen dos piezas que las seis versiones no tienen. picoProlog
tiene la negación `not`, y Spivey cuenta cómo la implementa: el ciclo del
intérprete se llama otra vez, desde el paso, para la meta negada. Toy, el
intérprete de Kluźniak y Szpakowicz, no detiene la ejecución ante una
llamada errónea: la reemplaza por una llamada a `error/1` con la meta que
la produjo, y el programa decide qué hacer. La séptima versión,
`negacion.pl`, agrega las dos sobre la máquina con corte de la versión 4.

`\+ G` se prueba con una segunda ejecución de la máquina, que empieza con
la resolvente `[G]`, la pila vacía y el almacén del momento. Si da una
respuesta, la negación falla; si termina sin ninguna, la máquina sigue con
el almacén de antes, y las ligaduras que hizo la segunda ejecución
desaparecen con él. Como el almacén es un árbol persistente, volver a él no
necesita el rastro. Un error de un paso se captura con `catch/3`, y si el
programa objeto define `error/1`, la meta que lo produjo se reemplaza por
`error(Meta)`:

<!-- ejemplo: capitulo-62/negacion.pl predicado: paso/5 negar/5 manejar/7 -->
```prolog
%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Como paso/5 de corte.pl, con \+ G y con los errores dirigidos a
%   error/1 cuando el programa objeto lo define.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    (   Meta = (\+ G)
    ->  negar(G, Metas, Tabla, Estado0, Resultado)
    ;   catch(corte:paso(Meta, Metas, Tabla, Estado0, Resultado),
              error(Error, Contexto),
              manejar(Error, Contexto, Meta, Metas, Tabla, Estado0,
                      Resultado))
    ).

%!  negar(+G, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Prueba \+ G con una segunda ejecución de la máquina desde el almacén
%   de Estado0. Resultado es falla(Estado) si G tiene una respuesta, y
%   sigue(Estado), con Metas y el almacén de Estado0, si no tiene
%   ninguna. Estado lleva las medidas y las celdas de las dos ejecuciones.
negar(G, Metas, Tabla, m(Ms, Pila, A, R, L0, M0), Resultado) :-
    once(almacen:ciclo(negacion, Tabla, m([G], [], A, [], L0, M0), Evento)),
    arg(1, Evento, m(_, _, _, _, L, M)),
    (   Evento = fin(_)
    ->  Resultado = sigue(m(Metas, Pila, A, R, L, M))
    ;   Resultado = falla(m(Ms, Pila, A, R, L, M))
    ).

%!  manejar(+Error, +Contexto, +Meta, +Metas:list, +Tabla, +Estado0,
%!          -Resultado) is det.
%
%   Si el programa objeto define error/1, la Meta que produjo el Error se
%   reemplaza por error(Meta); si no, el error se vuelve a lanzar.
manejar(Error, Contexto, Meta, Metas, Tabla, Estado0, Resultado) :-
    (   get_assoc(error/1, Tabla, _)
    ->  Estado0 = m(_, Pila, A, R, L, M),
        Resultado = sigue(m([error(Meta)|Metas], Pila, A, R, L, M))
    ;   throw(error(Error, Contexto))
    ).
```

`objeto/2` de `negacion.pl` guarda dos programas. En `soltero`, la negación
se usa con su argumento ya instanciado; en `desconocido`, la primera
cláusula de `desconocido/1` llama a un predicado sin cláusulas, y
`error(_) :- fail` hace que esa llamada falle en lugar de detener la
máquina:

```prolog
?- resolver(soltero(X)).
X = ana ;
X = eva.

?- resolver(desconocido(X)).
X = b.

?- resolver(siguiente(_, Y)).
false.
```

La tercera consulta evalúa `Y is X + 1` con `X` libre: el error de
instanciación también pasa a `error/1`, que falla. Las medidas cuentan los
pasos de las dos ejecuciones:

```prolog
?- medir_programa(soltero, soltero(_), M).
M = [respuestas-2, pasos-8, intentos-7, metas-2, elecciones-1, rastro-1, celdas-2].
```

Un corte dentro de la meta negada actúa sobre la pila de la segunda
ejecución, que empieza vacía, y no puede quitar los puntos de elección de
la primera ([ejercicio 12](#ejercicios)).

Dos optimizaciones que describen las fuentes quedan fuera. La llamada de
cola con marcos de activación (Spivey, «Tail recursion»; el `trooverlay`
de Toy) no tiene sentido en esta máquina, que no tiene marcos: la
resolvente ya no guarda la cláusula que hizo la llamada, como mostró la
columna `metas` de la [sección 62.6](alternativas.md#626-indexacion-por-el-primer-argumento).
La recolección de basura (Spivey, «Garbage collection», sobre el
algoritmo LISP 2 de Knuth) recuperaría las celdas que ninguna meta ni
ningún punto de elección mencionan; escribirla exige recorrer la
resolvente, cada punto de elección y el almacén entero en cada
recolección, y las medidas de las seis versiones, que el capítulo compara
entre sí, dejarían de ser comparables. Tampoco se agregan `assert/1` ni
`clause/2` sobre el programa objeto, que Toy tiene: la tabla de
procedimientos es un argumento del ciclo, no parte del estado, y
agregarlos cambiaría la firma de todas las versiones.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `resolver/2` es `nondet` en todas las versiones, y las versiones 5 y 6 no dejan alternativas cuando el programa objeto no las tiene |
    | C2 | la clase de una meta y los términos del programa objeto son representaciones limpias, con un functor por clase; la excepción declarada es `'$v'/1`, reservado para las celdas |
    | C4 | el ciclo de la máquina no deja puntos de elección de Prolog: el único es el que entrega cada respuesta, y el último se omite si la pila de la máquina está vacía |
    | C5 | una meta variable produce un error de instanciación, y un predicado sin cláusulas un error de existencia, como en Prolog |
    | C6 | las cinco versiones son puras: el estado es un término que cada paso transforma, y solo `tabla_de_medidas/1` escribe |
    | C7 | 106 pruebas en nueve archivos; cada versión compara sus respuestas con las de Prolog en un módulo temporal |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

11. ★ **(2)** Ejecutar con `ejecutar_archivo/2` las consultas `ultimo([a, b], X)`,
    `concatenar(X, Y, [a])` y `longitud([a, b], N)` sobre
    `ejemplos('capitulo-07/recorrer')`, y comparar las respuestas, y si la
    última termina en punto, con las de SWI-Prolog con el archivo cargado.
    Explicar el resultado a partir de las claves de la
    [sección 62.6](alternativas.md#626-indexacion-por-el-primer-argumento) y de la indexación de la [sección 17.3](../capitulo-17-rendimiento/index.md#173-indexacion).
12. **(2)** En la versión 7, predecir qué responde
    `almacen:resolver_clausulas(negacion, [(p(a) :- true), (p(b) :- true)], (p(X), \+ (p(_), !, fail)))`
    y explicar por qué el corte de la meta negada no quita el punto de
    elección de `p(X)`. Comprobarlo, y decir qué respondería si la
    negación usara la misma pila que la ejecución principal.

## Resumen

| | |
|---|---|
| **resolvente** | la lista de las metas que faltan probar |
| **programa objeto** | el programa que la máquina ejecuta, como una lista de cláusulas |
| **punto de elección** | la meta de una llamada con las cláusulas que quedan, el largo del rastro y la primera celda libre |
| **celda** | una variable del programa objeto, `'$v'(N)`; su valor está en el almacén |
| **almacén** | el árbol de las celdas ligadas y sus valores |
| **desreferenciar** | seguir las ligaduras de una celda hasta un término que no es una celda ligada |
| **rastro** | la lista de las celdas críticas ligadas, que la vuelta atrás desliga |
| **celda crítica** | una celda anterior al último punto de elección, que sobrevive a la vuelta atrás |
| **altura del corte** | el tamaño de la pila al llamar; el corte deja solo esos puntos de elección |
| **clave** | lo que el primer argumento dice de las cláusulas que pueden unificar |
| **compilar** | traducir cada cláusula, una vez, a instrucciones que ya no la examinan al usarla |
| **llamada de cola** | la última meta de un cuerpo; al ejecutarla, la resolvente no guarda nada de la cláusula |
| `clase/2`, `ejecutar/1`, `respuestas_nativas/3` | las clases de meta, los predefinidos y la referencia de Prolog, en `programas.pl` |
| `resolver_metas/2` | la versión 1 |
| `buscar/4`, `expandir/5` | la versión 2 |
| `compilar/2`, `unificar/5`, `llamar/5`, `volver/3`, `ejecutar/5` | la versión 3 |
| `cortar/4`, `purgar/3` | la versión 4 |
| `clave_de/2`, `siguiente/4` | la versión 5 |
| `compilar_clausula_v6/2`, `ejecutar/6` | la versión 6 |
| `negar/5`, `manejar/7` | la versión 7: la negación con una segunda ejecución y los errores dirigidos a `error/1` |
| `resolver/3`, `tabla_de_medidas/1`, `tabla_de_inferencias/1`, `ejecutar_archivo/2`, `igual_que_prolog/3` | la máquina terminada |
| **[Patrón 63](../patrones.md#63-estado-como-resultado-no-como-falla)** | estado como resultado, no como falla |
| `term_size/2` | la cantidad de celdas de memoria que ocupa un término |
| `del_assoc/4` | quita un par de un árbol AVL de `library(assoc)` |
| `map_assoc/3` | aplica un predicado al valor de cada par de un árbol AVL y da el árbol que resulta |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La resolución con cláusulas que no son de Horn, en un demostrador que no depende del orden de Prolog | [capítulo 63](../capitulo-63-proyecto-demostrador-teoremas/index.md) |
| La evaluación de abajo hacia arriba de un programa lógico, sin resolvente ni puntos de elección | [capítulo 86](../capitulo-86-proyecto-motor-datalog/index.md) |

## Referencias

- Michael Spivey, *An Introduction to Logic Programming through Prolog*,
  Prentice Hall International, 1996 — «About picoProlog», «Implementing
  depth-first search», «Representing terms and substitutions», «Implementation
  notes» e «Interpreter optimizations».
  [Edición del autor](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf).
  El capítulo toma la negación `not` como una llamada del ciclo del intérprete
  desde el paso, que la versión 7 escribe, y la llamada de cola y la recolección
  de basura como las dos optimizaciones que completan la indexación, que la
  [sección 62.9](#629-la-negacion-y-los-errores) deja fuera. De picoProlog,
  escrito en otro lenguaje, el capítulo toma las ideas, no el código.
- Feliks Kluźniak y Stanisław Szpakowicz, con Janusz S. Bień, *Prolog for
  Programmers*, Academic Press, 1985 — «Principles of Prolog Implementation» y
  «Toy: An Exercise in Implementation».
  [Edición en línea en el sitio del coautor](https://www.site.uottawa.ca/~szpak/pub/P4P/Prolog_for_Programmers_neat.pdf).
  El capítulo toma, del intérprete Toy, el manejo de errores que reemplaza la
  llamada errónea por una llamada a `error/1`, en la versión 7.

El código del capítulo es propio, escrito para el curso. La versión 2
reescribe con otra representación la búsqueda en profundidad que Spivey
plantea como programa lógico antes de implementarla; las máquinas de las dos
fuentes no están escritas en Prolog, y la representación con celdas en un
árbol AVL, el ciclo con la versión como parámetro y las mediciones no están
en ellas.
