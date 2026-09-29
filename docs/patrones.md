# Patrones

Las [plantillas](plantillas.md) de la parte I son las formas de los predicados:
recorrer una lista, acumular, generar y probar. Los patrones de la parte II son
las formas del trabajo profesional: cómo se escribe un predicado que otros van a
llamar, cómo se reúnen respuestas, cómo se aísla el estado, cómo se prueba y se
entrega un programa. Los de la parte III, desde el 43, son las técnicas de
un programador avanzado: los términos y los programas como datos, las
estructuras incompletas, la transformación de programas, las interfaces, la
concurrencia, la tabulación y la búsqueda.

La idea de enseñar Prolog a través de técnicas con nombre tiene un antecedente
en P. Brna, A. Bundy, T. Dodd, M. Eisenstadt, C. K. Looi, H. Pain, D.
Robertson, B. Smith y M. van Someren, «Prolog programming techniques»,
*Instructional Science* 20 (2-3), 1991, pp. 111–133. El artículo reúne técnicas
como el bucle por falla, la construcción de estructuras en la cabeza de la
cláusula y el par de acumuladores, y propone que el estudiante aprenda a
reconocer tanto sus aplicaciones correctas como las defectuosas, y cuándo usar
cada técnica y cuándo no. Esos dos aspectos corresponden a los campos «Versión
ingenua» y «Cuándo no usarlo» de cada recuadro de esta página.

Cada patrón se presenta en el capítulo donde se lo necesita, con el ejemplo que
lo motiva. Aquí figura el texto completo de cada recuadro, copiado del capítulo,
para consultarlos y compararlos; la página se amplía a medida que avanza la
parte III.

## Criterios de calidad

Todo el código de las partes II y III se revisa con estos siete criterios. El
[capítulo 14](capitulo-14-estilo-y-documentacion/index.md) los presenta en detalle; cada capítulo posterior indica, en un
recuadro, cuáles ejercita su código y cómo se comprueba cada uno.

| | Criterio | Se comprueba |
|---|---|---|
| C1 | Interfaz declarada | cada predicado tiene su encabezado PlDoc, con modos y determinación |
| C2 | Consulta más general | con todos los argumentos libres, el predicado responde, produce un error de instanciación o declara la restricción; nunca responde algo incorrecto sin aviso |
| C3 | Estabilidad | el resultado es el mismo con un argumento de salida ligado o libre |
| C4 | Sin puntos de elección sobrantes | un predicado `det` no deja alternativas pendientes |
| C5 | Error, no falla silenciosa | los tipos incorrectos y los datos faltantes producen términos de error ISO |
| C6 | Núcleo puro, bordes impuros | el estado, la entrada y salida y los efectos laterales quedan en una capa delgada |
| C7 | Probado | cada predicado tiene sus pruebas de plunit, una por modo |

## 1 — Editar, recargar, probar

**Problema.** Después de modificar un archivo, el toplevel sigue ejecutando
la versión anterior, y un error se descubre recién cuando alguien usa el
predicado.

**Versión ingenua.** Salir de `swipl` y volver a entrar después de cada
cambio, y probar a mano algunas consultas.

**Patrón.** El toplevel queda abierto toda la sesión. Cada cambio sigue el
mismo ciclo: editar y guardar; `make.`; `run_tests.`; y `check.` antes de
entregar.

**Cuándo no usarlo.** Cuando el programa modifica su propia base de datos
durante la ejecución ([capítulo 20](capitulo-20-base-de-datos-dinamica/index.md)), recargar no restituye los hechos
agregados o quitados; en ese caso se reinicia el toplevel.

Capítulo 13, [sección 13.5](capitulo-13-el-entorno-de-trabajo/index.md#135-verificar-antes-de-entregar).

## 2 — Encabezado que se cumple

**Problema.** El encabezado promete un modo o una cantidad de respuestas
que el código ya no cumple, y nadie lo nota hasta que alguien lo usa así.

**Versión ingenua.** Escribir el encabezado una vez, al crear el
predicado, y probar solo el uso más frecuente.

**Patrón.** Una prueba por cada línea de modo del encabezado, sin `nondet`
cuando el modo es `det`; y una prueba por cada uso fuera de los modos que el
texto menciona, con el resultado que corresponde: `[fail]`, `error(...)`, o
la respuesta equivocada que el signo advierte. Un modo `semidet` cuya
implementación deja una alternativa pendiente lleva `[nondet]` en la prueba,
con un comentario que lo explica, hasta que se la quite (capítulos [15](capitulo-15-control/index.md) y
16).

**Cuándo no usarlo.** En los hechos: una tabla de hechos no tiene modos
que verificar, y se prueba con pruebas de coherencia de los datos, como
las de la [sección 13.7](capitulo-13-el-entorno-de-trabajo/index.md#137-el-proyecto-inscripciones).

Capítulo 14, [sección 14.4](capitulo-14-estilo-y-documentacion/index.md#144-lo-que-el-encabezado-promete).

## 3 — Salida después del compromiso

**Problema.** Un predicado con corte responde algo falso cuando el
argumento de salida llega ligado.

**Versión ingenua.** Escribir el valor de salida en la cabeza de la
cláusula que lo calcula: `mal_maximo(X, Y, X) :- X >= Y, !.`

**Patrón.** La cabeza usa una variable nueva para la salida, y la cláusula
la liga después del corte: `maximo(X, Y, M) :- X >= Y, !, M = X.` La
plantilla 14 del [capítulo 9](capitulo-09-backtracking-y-corte/index.md) lo pedía en palabras («el argumento de salida
debe llegar libre»); con este patrón deja de ser una restricción.

**Cuándo no usarlo.** En los predicados sin corte, cuyas cláusulas se
distinguen por unificación: `aprobada/3` y `padre/2` ya son estables.

Capítulo 14, [sección 14.5](capitulo-14-estilo-y-documentacion/index.md#145-orden-de-los-argumentos-y-estabilidad).

## 4 — Datos limpios

**Problema.** Un valor tiene varios casos, y un caso se representa con un
valor especial —`null`, `0`, `[]`, `ninguno`— del mismo tipo que los
demás.

**Versión ingenua.** Distinguir los casos en cada regla con pruebas de
tipo o comparaciones: `integer(N)`, `N \== null`.

**Patrón.** Un functor por caso —`cursando`, `nota(N)`—, y reglas que
seleccionan su caso por unificación en la cabeza o en el primer objetivo.

**Cuándo no usarlo.** Cuando los datos llegan de afuera con otra forma, como
una tabla SQL o un archivo CSV: la conversión a la forma limpia se hace una
sola vez, en el borde del programa ([capítulo 27](capitulo-27-archivos-streams-y-formatos/index.md)).

Capítulo 14, [sección 14.6](capitulo-14-estilo-y-documentacion/index.md#146-representacion-de-los-datos).

## 5 — Casos con condicional

**Problema.** Un predicado distingue casos que no se superponen, y la
versión con corte depende del orden de las cláusulas y no es estable.

**Versión ingenua.** Una cláusula por caso, con un corte después de la
condición y la salida en la cabeza, como `categoria/2` del capítulo 9.

**Patrón.** Una cláusula con un condicional encadenado: cada condición
elige su rama, y cada rama liga la salida.

```prolog
p(X, S) :-
    (   condicion_1(X)
    ->  S = caso_1
    ;   condicion_2(X)
    ->  S = caso_2
    ;   S = caso_restante
    ).
```

**Cuándo no usarlo.** Cuando los casos se distinguen por la forma de un
argumento: una cláusula por forma, seleccionada por unificación ([Patrón 4](patrones.md#4-datos-limpios)),
evita la condición explícita y aprovecha la indexación.

Capítulo 15, [sección 15.3](capitulo-15-control/index.md#153-los-casos-del-capitulo-9-reescritos).

## 6 — Una respuesta en el borde

**Problema.** Quien llama necesita una sola respuesta de un predicado que
tiene varias, y el corte se agrega adentro, donde cambia la relación para
todos los demás usos.

**Versión ingenua.** Agregar un corte al final del predicado, o `once/1`
alrededor de su cuerpo: el predicado deja de enumerar, y ninguna otra
llamada puede pedir las demás respuestas.

**Patrón.** El predicado conserva su relación completa; `once/1` se
escribe en el **borde**, en el predicado que promete una respuesta —el que
atiende una orden, escribe un informe o responde a otro programa—, con un
nombre que lo dice: `primer_mayor_de_edad/1`.

**Cuándo no usarlo.** Cuando el objetivo ya es determinista: `once/1` no
agrega nada, y oculta que el predicado podría dejar de serlo.

Capítulo 15, [sección 15.4](capitulo-15-control/index.md#154-once1-e-ignore1).

## 7 — Bucle por falla

**Problema.** Es necesario ejecutar un efecto —escribir, enviar,
registrar— por cada respuesta de un objetivo, o repetir un ciclo hasta que
llegue una orden de salida.

**Versión ingenua.** Reunir las respuestas en una lista y recorrerla con
una recursión, solo para escribirlas.

**Patrón.** Un bucle por falla (*failure-driven loop*):
`( Generador, Efecto, fail ; true )` para recorrer respuestas;
`repeat, Leer, Ejecutar, Condicion_de_salida, !` para un ciclo.

**Cuándo no usarlo.** Cuando lo que se necesita es un **resultado**: un
bucle por falla deshace las ligaduras en cada vuelta, y lo único que queda
son los efectos. Para calcular, una recursión o las herramientas del
[capítulo 17](capitulo-17-todas-las-soluciones/index.md), que presenta además `forall/2`, la forma declarativa de este mismo
recorrido.

Capítulo 15, [sección 15.7](capitulo-15-control/index.md#157-bucles-por-falla).

## 8 — Recursión en espacio constante

**Problema.** Una recursión que funciona con listas cortas agota la pila
con listas largas.

**Versión ingenua.** La operación después de la llamada recursiva:
`largo([_|R], N) :- largo(R, N0), N is N0 + 1.`

**Patrón.** Un acumulador que lleva el resultado parcial (plantilla 13), la
operación antes de la llamada, y la llamada recursiva como último objetivo,
sin alternativas pendientes.

**Cuándo no usarlo.** Cuando la recursión es naturalmente corta —la
profundidad de un árbol genealógico, los casos de una definición— y la
versión directa es más clara. Tampoco cuando el resultado es una lista que
se construye en la cabeza de la cláusula (plantilla 12): esa recursión ya
corre en espacio constante, y un acumulador daría la lista invertida.

Capítulo 16, [sección 16.2](capitulo-16-rendimiento/index.md#162-la-pila-y-la-recursion).

## 9 — El argumento que indexa primero

**Problema.** Un predicado recursivo deja alternativas pendientes porque
sus cláusulas no se distinguen por el primer argumento.

**Versión ingenua.** Poner primero el argumento que se lee primero —el
legajo, el acumulador— y la lista que se recorre después.

**Patrón.** El argumento que distingue las cláusulas —la lista que se
recorre, el término cuya forma elige el caso— va primero. Si dos cláusulas
solo se distinguen por el resto de la lista, un auxiliar recibe el resto y
el elemento anterior por separado.

**Cuándo no usarlo.** En los predicados cuyo orden de argumentos es una
convención conocida —`member/2`, `append/3`— o cuyas cláusulas ya se
distinguen: cambiar el orden solo complica la lectura.

Capítulo 16, [sección 16.3](capitulo-16-rendimiento/index.md#163-indexacion).

## 10 — Medir antes de cambiar

**Problema.** Un programa es lento, y la causa que parece evidente no es la
que pesa.

**Versión ingenua.** Reescribir la parte que parece costosa, y probar con
los datos del ejemplo.

**Patrón.** Generar datos del tamaño en que el programa se va a usar;
medir con `time/1` o contando inferencias; cambiar una sola cosa; medir de
nuevo. Si la mejora importa, fijarla con una prueba que acote las
inferencias.

**Cuándo no usarlo.** Cuando el programa ya responde a tiempo con los datos
reales: una optimización sin medición complica el código sin beneficio
comprobado.

Capítulo 16, [sección 16.5](capitulo-16-rendimiento/index.md#165-el-orden-de-los-objetivos-medido).

## 11 — Reunir y después procesar

**Problema.** Un cálculo necesita todas las respuestas de un objetivo a la
vez: su cantidad, su orden, compararlas entre sí.

**Versión ingenua.** Repetir los datos en una lista escrita a mano, como en
la [sección 10.8](capitulo-10-negacion-como-falla/index.md#108-prescindir-de), o recorrer las respuestas con un bucle por falla, que no
puede construir un resultado.

**Patrón.** `findall/3` (o `setof/3`, si hacen falta orden y unicidad) para
obtener la lista, y después un predicado de listas del [capítulo 7](capitulo-07-listas/index.md) para
procesarla.

**Cuándo no usarlo.** Cuando el cálculo es un conteo, una suma o un máximo:
`aggregate_all/3` lo hace sin construir la lista ([Patrón 12](patrones.md#12-contar-y-agregar-sin-recorrer)).

Capítulo 17, [sección 17.4](capitulo-17-todas-las-soluciones/index.md#174-cuando-no-hay-respuestas).

## 12 — Contar y agregar sin recorrer

**Problema.** Es necesario contar, sumar o encontrar el máximo de las
respuestas de un objetivo.

**Versión ingenua.** Reunir las respuestas con `findall/3` y recorrer la
lista con un acumulador, o escribir la recursión que cuenta.

**Patrón.** `aggregate_all(count, …)`, `aggregate_all(sum(E), …)`,
`aggregate_all(max(E, Testigo), …)`, comprobando antes el caso sin
respuestas cuando la operación no lo admite.

**Cuándo no usarlo.** Cuando el resultado es la lista misma, o cuando hay
que agrupar por una variable: `bagof/3`, `setof/3` o `aggregate/3`.

Capítulo 17, [sección 17.5](capitulo-17-todas-las-soluciones/index.md#175-aggregate_all3).

## 13 — Comprobar para todos

**Problema.** Es necesario verificar que todas las respuestas de un
objetivo cumplen una condición.

**Versión ingenua.** Una recursión sobre una lista de los datos, o la doble
negación escrita a mano: `\+ (C, \+ A)`.

**Patrón.** `forall(Condicion, Accion)`, con las variables de `Condicion`
ligadas en ella y usadas en `Accion`.

**Cuándo no usarlo.** Cuando se necesita saber **cuál** no cumple:
`forall/2` solo responde sí o no. En ese caso, se busca el contraejemplo con
un objetivo que lo genere, como las pruebas de datos del capítulo 13.

Capítulo 17, [sección 17.6](capitulo-17-todas-las-soluciones/index.md#176-forall2).

## 14 — Recorrido con `maplist`

**Problema.** Hay que aplicar la misma relación a cada elemento de una o
varias listas: comprobar, transformar o procesar cada uno.

**Versión ingenua.** Una recursión escrita a mano, con su caso base y su
caso recursivo, que repite la forma de la plantilla en cada predicado.

**Patrón.** `maplist(Relacion, L1, …)`, con `Relacion` un predicado con
nombre y encabezado propio, o una clausura que fija sus primeros
argumentos.

**Cuándo no usarlo.** Cuando el recorrido debe detenerse en el primer
elemento que cumple una condición ([plantilla 10](plantillas.md#10-buscar-un-elemento-que-cumple-una-condicion)), cuando un elemento
depende de los anteriores ([Patrón 15](patrones.md#15-plegado-con-foldl)), o cuando el resultado no tiene un
elemento por cada elemento de la entrada ([sección 18.4](capitulo-18-orden-superior/index.md#184-include3-exclude3-partition4-convlist3)).

Capítulo 18, [sección 18.2](capitulo-18-orden-superior/index.md#182-maplist25).

## 15 — Plegado con `foldl`

**Problema.** Hay que construir un valor a partir de todos los elementos de
una lista, en un solo recorrido: una suma, un máximo, varios valores a la
vez.

**Versión ingenua.** Un predicado auxiliar con acumulador escrito a mano
([plantilla 13](plantillas.md#13-acumulador)), o varios recorridos, uno por valor.

**Patrón.** `foldl(Paso, Lista, Inicial, Final)`, con `Paso(X, Antes,
Despues)`. Si hacen falta varios valores, el acumulado es un término que
los reúne, como el par `Cantidad-Suma` de la [sección 18.8](capitulo-18-orden-superior/index.md#188-el-proyecto-informes-genericos). Si el
recorrido también produce una lista, con un elemento por cada elemento de
la entrada, `foldl/6` ([sección 18.7](capitulo-18-orden-superior/index.md#187-cuando-no-usar-el-orden-superior)).

**Cuándo no usarlo.** Cuando la biblioteca ya tiene el predicado:
`sum_list/2`, `max_list/2`, `length/2`. Y cuando los valores vienen de las
respuestas de un objetivo y no de una lista: `aggregate_all/3` ([Patrón 12](patrones.md#12-contar-y-agregar-sin-recorrer)).

Capítulo 18, [sección 18.3](capitulo-18-orden-superior/index.md#183-foldl46).

## 16 — Intérprete de reglas

**Problema.** El conocimiento de un dominio cambia más seguido que el
programa, o lo escribe alguien que no programa en Prolog.

**Versión ingenua.** Escribir cada regla del dominio como una cláusula de
Prolog, mezclada con el resto del programa: no se puede explicar cómo se
llegó a una conclusión, ni leer las reglas desde otro lugar.

**Patrón.** Las reglas como términos, escritos con operadores propios; un
intérprete con una cláusula por cada forma de condición, que construye el
árbol de la prueba; y solo las operaciones que el intérprete conoce, sin
`call/1` sobre objetivos que vienen de los datos.

**Cuándo no usarlo.** Cuando las reglas son parte fija del programa y nadie
necesita la explicación: las cláusulas de Prolog son el lenguaje de reglas
más directo.

Capítulo 19, [sección 19.4](capitulo-19-operadores-y-reglas-como-datos/index.md#194-el-interprete-y-la-pregunta-como).

## 17 — Memorización con `assertz`

**Problema.** Un cálculo costoso se repite con los mismos argumentos.

**Versión ingenua.** Recalcularlo cada vez, o guardar los resultados en un
argumento que se pasa por todo el programa.

**Patrón.** Un predicado dinámico con los resultados; el predicado busca
primero allí, y si no encuentra, calcula y guarda con `assertz/1`. Un
predicado que borra la tabla, para las pruebas y para cuando los datos
cambian.

**Cuándo no usarlo.** Cuando el resultado depende de datos que cambian
durante la ejecución y no hay un punto claro donde invalidar lo guardado; y
cuando `:- table` resuelve lo mismo ([capítulo 39](capitulo-39-tabulacion/index.md)).

Capítulo 20, [sección 20.5](capitulo-20-base-de-datos-dinamica/index.md#205-memorizacion).

## 18 — Base de conocimiento que crece

**Problema.** Hay que obtener todas las consecuencias de un conjunto de
hechos y reglas, y conservarlas para consultarlas después.

**Versión ingenua.** Probar cada conclusión posible hacia atrás, cada vez
que se la consulta, repitiendo las mismas pruebas.

**Patrón.** Los hechos en un predicado dinámico; un paso que agrega una
conclusión nueva de una regla cuyas condiciones se cumplen, comprobando con
`\+` que no estaba; repetir hasta el punto fijo. Registrar con cada hecho
la regla que lo produjo.

**Cuándo no usarlo.** Cuando solo interesan unas pocas conclusiones de
muchas posibles: el encadenamiento hacia atrás, o las reglas de Prolog,
calculan solo lo que se pregunta.

Capítulo 20, [sección 20.6](capitulo-20-base-de-datos-dinamica/index.md#206-un-sistema-experto-con-encadenamiento-hacia-adelante).

## 19 — Estado detrás de una interfaz

**Problema.** Un programa necesita estado, y cualquier parte que lo
modifique puede dejarlo inconsistente.

**Versión ingenua.** `assertz/1` y `retract/1` repartidos por el programa y
por las pruebas, cada uno con su propia idea de qué hechos van juntos.

**Patrón.** Los predicados dinámicos se modifican solo en unos pocos
predicados con nombre —iniciar, registrar, reiniciar— que mantienen juntos
los hechos relacionados; el resto consulta. Las pruebas usan esos mismos
predicados para preparar el estado y para restaurarlo.

**Cuándo no usarlo.** Cuando el estado se puede evitar: un valor que se
calcula dentro de una consulta va en un argumento, no en la base.

Capítulo 20, [sección 20.7](capitulo-20-base-de-datos-dinamica/index.md#207-el-agente-del-mundo-del-wumpus).

## 20 — Una gramática para analizar y generar

**Problema.** Un programa lee un formato de texto y también lo escribe: un
comando, una fecha, un archivo de configuración.

**Versión ingenua.** Un analizador y, por separado, un predicado que arma
el texto con `format/2`: dos definiciones del mismo formato, que se
desincronizan al cambiar una.

**Patrón.** Un no terminal con un argumento que es el término: el mismo
no terminal analiza, con el término libre, y genera, con el término
ligado. Una prueba de ida y vuelta verifica que el texto generado se
vuelve a analizar como el mismo término.

**Cuándo no usarlo.** Cuando el formato de salida no es el de entrada
—ceros a la izquierda, espacios alineados, mayúsculas— o cuando el
análisis usa operaciones que no se pueden invertir, como una conversión
aritmética dentro de `{}`.

Capítulo 21, [sección 21.4](capitulo-21-gramaticas-dcg/index.md#214-argumentos-adicionales).

## 21 — Secuencia con separadores

**Problema.** Hay que reconocer una lista de elementos separados por comas,
espacios u otro separador, y obtener la lista de los elementos.

**Versión ingenua.** Una recursión escrita a mano para cada lista, con los
casos del primer elemento, del separador y del final, o `split_string/4`
seguido de una conversión elemento por elemento.

**Patrón.** `sequence(Elemento, Separador, Lista)` de
`library(dcg/high_order)`, con el no terminal de un elemento y el del
separador; `sequence//5` agrega los delimitadores de apertura y cierre.

**Cuándo no usarlo.** Cuando el separador puede ser vacío, o cuando puede
aparecer al final: `sequence//3` se compromete con el separador y no
retrocede.

Capítulo 21, [sección 21.6](capitulo-21-gramaticas-dcg/index.md#216-librarydcgbasics-y-librarydcghigh_order).

## 22 — Gramática con argumento acumulador

**Problema.** Una gramática construye un valor a partir de una secuencia
que se lee de izquierda a derecha: una operación que agrupa a la
izquierda, un total, una lista en orden.

**Versión ingenua.** La regla con recursión a izquierda, que no termina, o
la recursión a la derecha, que termina con el resultado agrupado al revés.

**Patrón.** Un no terminal que reconoce el primer elemento y pasa su valor
como acumulado a otro, que reconoce cada elemento siguiente, actualiza el
acumulado y, al final, lo entrega.

**Cuándo no usarlo.** Cuando el resultado es un árbol que conserva la
estructura del texto, sin evaluarlo: entonces el acumulado es el árbol
parcial, o conviene construir la lista de elementos y procesarla después.

Capítulo 21, [sección 21.7](capitulo-21-gramaticas-dcg/index.md#217-recursion-a-izquierda).

## 23 — Decorar, ordenar, desdecorar

**Problema.** Es necesario ordenar elementos por un valor que no está en
ellos sino que se calcula: una longitud, un promedio, una distancia.

**Versión ingenua.** `predsort/3` con un predicado que calcula el valor en
cada comparación: lo calcula muchas veces para cada elemento, y elimina los
que empatan.

**Patrón.** Calcular el valor una vez por elemento y formar pares
`Valor-Elemento` (`map_list_to_pairs/3`), ordenarlos con `keysort/2` o
`sort/4`, y quedarse con los elementos (`pairs_values/2`).

**Cuándo no usarlo.** Cuando la clave ya es un argumento del término:
`sort/4` ordena por él directamente.

Capítulo 22, [sección 22.4](capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#224-pares-y-keysort2).

## 24 — Tabla de búsqueda con `assoc`

**Problema.** Un programa busca muchas veces valores por una clave: la
celda de un tablero, el alumno de un legajo.

**Versión ingenua.** Una lista de pares y `memberchk/2`, que recorre la
lista en cada búsqueda.

**Patrón.** Construir un assoc una vez, con `list_to_assoc/2`, y buscar con
`get_assoc/3`. Actualizar con `put_assoc/4`, que da un assoc nuevo.

**Cuándo no usarlo.** Con pocas claves, o cuando los datos son hechos del
programa: la indexación de los hechos ya busca por el primer argumento sin
recorrerlos todos.

Capítulo 22, [sección 22.5](capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#225-libraryassoc-y-libraryrbtrees).

## 25 — Búsqueda en un espacio de estados con visitados

**Problema.** Es necesario encontrar una secuencia de acciones que lleva
de un estado inicial a uno final, y las acciones pueden volver a estados ya
vistos.

**Versión ingenua.** Una búsqueda en profundidad que prueba acciones
recursivamente, como la [plantilla 15](plantillas.md#15-generar-y-probar): entra en ciclos, o encuentra
un plan largo antes que uno corto.

**Patrón.** El estado como término normalizado; `sucesor/3` con las
acciones; una cola de estados con su camino, y un conjunto ordenado de
visitados que no se vuelven a encolar. A lo ancho, el primer plan es uno
de los más cortos.

**Cuándo no usarlo.** Cuando el espacio de estados es enorme y hace falta
una heurística que guíe la búsqueda, como en el [capítulo 40](capitulo-40-busqueda-y-planificacion/index.md); o
cuando el problema se modela mejor con restricciones
([capítulo 23](capitulo-23-programacion-con-restricciones/index.md)).

Capítulo 22, [sección 22.10](capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#2210-un-estado-como-termino-el-mundo-de-bloques).

## 26 — Contar con reificación

**Problema.** Un modelo necesita que exactamente, al menos o a lo sumo N de
un conjunto de condiciones se cumplan.

**Versión ingenua.** Generar las combinaciones de condiciones que se
cumplen, o contarlas después de etiquetar, cuando ya no pueden podar la
búsqueda.

**Patrón.** Una variable booleana por condición, `B #<==> Condicion`, y una
restricción sobre su suma: `sum(Bs, #=, N)`. La cuenta participa de la
propagación desde el principio.

**Cuándo no usarlo.** Cuando se cuentan valores y no condiciones:
`global_cardinality/2` lo hace con una sola restricción.

Capítulo 23, [sección 23.6](capitulo-23-programacion-con-restricciones/index.md#236-reificacion).

## 27 — Modelar, restringir, etiquetar

**Problema.** Es necesario encontrar valores para muchas variables que
cumplen muchas condiciones a la vez.

**Versión ingenua.** Generar y probar: producir combinaciones completas y
comprobar cada una ([plantilla 15](plantillas.md#15-generar-y-probar)).

**Patrón.** Tres partes, en este orden: las variables con sus dominios
(`in`, `ins`); todas las restricciones; y el etiquetado al final (`label/1`,
`labeling/2`). El predicado que construye el modelo puede separarse del que
etiqueta, para probar el modelo solo.

**Cuándo no usarlo.** Cuando el problema no es sobre enteros, o cuando se
resuelve con un cálculo directo; y cuando los dominios son enormes y las
restricciones propagan poco: entonces hace falta otra formulación.

Capítulo 23, [sección 23.7](capitulo-23-programacion-con-restricciones/index.md#237-un-criptoaritmo-send-more-money).

## 28 — Interfaz del módulo

**Problema.** Un conjunto de predicados es usado por otras partes del
programa, y cambiar cualquiera de ellos puede romperlas.

**Versión ingenua.** Todo en el módulo `user`, o un módulo que exporta
todos sus predicados: nada distingue lo que se ofrece de lo que es
interno.

**Patrón.** Un módulo por responsabilidad, que exporta solo los predicados
que otros usan, cada uno con su encabezado; los auxiliares quedan
privados. Los meta-predicados de la interfaz se declaran con
`meta_predicate`.

**Cuándo no usarlo.** En un programa de un solo archivo que nadie más
carga, como los ejemplos de los capítulos anteriores: la organización en
módulos cuesta más de lo que ordena.

Capítulo 24, [sección 24.2](capitulo-24-modulos-y-organizacion/index.md#242-module2-y-use_module12).

## 29 — Núcleo puro, bordes impuros

**Problema.** La lógica del programa se mezcla con la entrada y salida,
con el estado y con los servicios externos, y deja de poder probarse como
relación.

**Versión ingenua.** Predicados que calculan y escriben a la vez, o que
consultan y modifican la base en el mismo paso.

**Patrón.** La lógica en módulos que solo consultan y calculan —`informes`,
`horarios`, las reglas de `reglas`—, y la entrada, la salida y el estado en
módulos delgados en los bordes —`datos`, `comandos`—. Los módulos del
núcleo se prueban con consultas; los de los bordes, con pocas pruebas que
restauran lo que modifican.

**Cuándo no usarlo.** En un programa pequeño, o en un guion de un solo uso:
la separación cuesta más que lo que ordena.

Capítulo 24, [sección 24.8](capitulo-24-modulos-y-organizacion/index.md#248-el-proyecto-cinco-modulos).

## 30 — Capturar lo justo y relanzar

**Problema.** Un error esperable —un dato que falta, una conversión que
no se puede hacer— tiene una respuesta razonable, y los demás errores no.

**Versión ingenua.** `catch(Objetivo, _, Recuperacion)`: captura todo,
incluidos los errores de programación y la interrupción con Ctrl-C, y los
convierte en la misma respuesta.

**Patrón.** Un patrón que describe exactamente el error esperado,
`error(existence_error(persona, _), _)`, y ninguna captura para los
demás. Si la recuperación depende de más detalles, capturar con un
patrón más amplio, examinar el término, y relanzar con `throw/1` lo que no
corresponde.

**Cuándo no usarlo.** En el borde más externo de un programa —el bucle
de un servidor, el `main` de una herramienta—, donde capturar todo,
informarlo y seguir es exactamente lo que se quiere.

Capítulo 25, [sección 25.3](capitulo-25-errores-y-excepciones/index.md#253-catch3).

## 31 — Validar al entrar

**Problema.** Un predicado público recibe argumentos de otros módulos o de
otras personas, y un argumento mal formado produce una falla, o un error
lejos de su causa.

**Versión ingenua.** No validar, y dejar que el primer predicado
predefinido que tropiece con el valor produzca un error que habla de
`is/2` o de `atom_length/2`.

**Patrón.** Al principio de cada predicado público, `must_be/2` para cada
argumento de entrada, según el encabezado; `domain_error/2` o
`existence_error/2` para lo que el tipo no alcanza a decir. Los predicados
internos no se validan: confían en el que los llama.

**Cuándo no usarlo.** En los predicados que funcionan en varios modos: una
validación de `+` rompe el modo `-`. Y en las relaciones puras, donde un
tipo incorrecto es simplemente un caso en que la relación no se cumple.

Capítulo 25, [sección 25.4](capitulo-25-errores-y-excepciones/index.md#254-throw1-must_be2-y-libraryerror).

## 32 — Recurso con limpieza garantizada

**Problema.** Un recurso —un archivo, un stream, una conexión, un estado
temporal— se abre, se usa y se cierra, y el uso puede fallar o producir un
error.

**Versión ingenua.** Abrir, usar y cerrar en secuencia: si el uso falla o
produce un error, el cierre no se ejecuta.

**Patrón.** `setup_call_cleanup(Abrir, Usar, Cerrar)`, con `Usar`
envuelto en `once/1` si se espera una sola respuesta, para que el recurso
se cierre al terminar y no quede abierto esperando otra.

**Cuándo no usarlo.** Cuando la biblioteca ya ofrece un predicado que lo
hace: `read_file_to_string/3`, `with_output_to/2`, `phrase_from_file/2`.

Capítulo 25, [sección 25.6](capitulo-25-errores-y-excepciones/index.md#256-setup_call_cleanup3).

## 33 — Una prueba por modo y por caso límite

**Problema.** Es necesario decidir qué pruebas escribir para un predicado,
sin probar al azar ni repetir el mismo caso con otros datos.

**Versión ingenua.** Una prueba con un ejemplo típico, en el modo en que se
escribió el predicado.

**Patrón.** Leer el encabezado: una prueba por cada modo declarado, con
la determinación que el encabezado promete (`all/1` para los `nondet`,
ninguna opción para los `det`); una por cada caso límite —la lista vacía,
el valor mínimo que cumple y el máximo que no, el dato que falta—; y una por
cada error que el encabezado declara (`error/1`). Las pruebas de
rendimiento usan una cota de inferencias, que no depende de la máquina.

**Cuándo no usarlo.** Para propiedades que valen para muchos datos, como
las del azar: se prueban recorriendo los datos con `forall`.

Capítulo 26, [sección 26.2](capitulo-26-pruebas-y-depuracion/index.md#262-la-bateria-completa-y-su-cobertura).

## 34 — Azar reproducible

**Problema.** Un predicado que usa el azar no da siempre el mismo
resultado, y una prueba no lo puede comparar con uno fijo.

**Versión ingenua.** No probarlo, o probar solo que termina.

**Patrón.** El azar en un solo predicado, en el borde. Las pruebas fijan la
semilla con `set_random(seed(N))` en su `setup` y comparan con un resultado
conocido; y recorren muchas semillas con `forall` para verificar las
propiedades que valen para cualquier resultado.

**Cuándo no usarlo.** Cuando el resultado depende de la versión de la
biblioteca de números al azar: una prueba con la semilla fija se rompe al
cambiar de versión, y conviene quedarse solo con las propiedades.

Capítulo 26, [sección 26.2](capitulo-26-pruebas-y-depuracion/index.md#262-la-bateria-completa-y-su-cobertura).

## 35 — Depurar recortando

**Problema.** Una consulta falla y debería cumplirse, o da una respuesta
incorrecta, y el programa es demasiado grande para seguirlo con el
depurador.

**Versión ingenua.** Seguir la ejecución completa con `trace/0`, paso a
paso, hasta reconocer el error entre cientos de puertos.

**Patrón.** Para una respuesta incorrecta, preguntar a los predicados que
la producen, con los valores concretos que reciben, y juzgar cada
respuesta: el error está en el primero que responde mal a partir de
respuestas correctas. Para una respuesta que falta, tachar objetivos con
`*` hasta que la consulta se cumpla.

**Cuándo no usarlo.** Con predicados que modifican el estado o escriben:
preguntarles cambia el estado, y tacharlos cambia lo que ocurre después.

Capítulo 26, [sección 26.6](capitulo-26-pruebas-y-depuracion/index.md#266-depuracion-declarativa).

## 36 — Leer, procesar, escribir

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

Capítulo 27, [sección 27.4](capitulo-27-archivos-streams-y-formatos/index.md#274-archivos-y-directorios).

## 37 — Convertir en el borde

**Problema.** Los datos llegan en un formato ajeno a Prolog —filas de
CSV, objetos de JSON, cadenas— y el programa los necesita como términos.

**Versión ingenua.** Pasar los dicts o las filas a los predicados del
programa, y extraer los campos donde se usan: cada predicado depende del
formato, y un cambio en el archivo obliga a cambiarlos todos.

**Patrón.** Un predicado de conversión por formato, en el borde del
programa, que produce los términos limpios del
[Patrón 4](patrones.md#4-datos-limpios) —`alumno/4`, `materia/3`— y
rechaza lo que no puede convertir. Para escribir, la conversión inversa.
El núcleo trabaja solo con términos, y se prueba sin archivos.

**Cuándo no usarlo.** Cuando el programa solo pasa los datos de un lado a
otro sin mirarlos, como un servicio que reenvía un JSON: convertirlos no
agrega nada.

Capítulo 27, [sección 27.7](capitulo-27-archivos-streams-y-formatos/index.md#277-json).

## 38 — Programa de línea de comandos

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

Capítulo 28, [sección 28.4](capitulo-28-programas-de-linea-de-comandos/index.md#284-codigos-de-salida).

## 39 — Frontera Python–Prolog

**Problema.** Un programa de Python usa reglas de Prolog. Los datos que
cruzan no siempre tienen equivalente del otro lado, y las fallas y los
errores de Prolog no son excepciones de Python.

**Versión ingenua.** Hacer consultas con Janus desde cualquier lugar del
programa de Python, armar el texto de las consultas con los valores de
entrada, y examinar `truth` y `PrologError` en cada llamada.

**Patrón.** Un solo módulo de Python usa Janus, y un solo módulo de Prolog
le responde. El de Prolog convierte las respuestas en datos que cruzan
—dicts con claves fijas, listas, textos— y envuelve en `prolog/1` lo que
Python solo guarda. El de Python pasa los valores como ligaduras,
convierte las fallas y los errores en excepciones propias, y ofrece
funciones comunes al resto del programa.

**Cuándo no usarlo.** En un script de pocas líneas que hace una sola
consulta: la frontera sería más larga que el script.

Capítulo 29, [sección 29.6](capitulo-29-prolog-desde-python/index.md#296-errores).

## 40 — Un endpoint JSON

**Problema.** Una ruta del servicio tiene que leer datos del pedido,
aplicar las reglas y responder, y cada falla de las reglas tiene que
llegar al cliente como un código de estado, no como un 500 ni como un
200 con un mensaje de error.

**Versión ingenua.** Un manejador largo, que valida los datos a mano,
llama a las reglas, examina cada resultado con `->` y escribe la
respuesta en cada rama, con los códigos elegidos en cada lugar.

**Patrón.** Un manejador corto por ruta: lee los parámetros con
`http_parameters/2` o el cuerpo con `http_read_json_dict/3`, llama al
núcleo y responde con `reply_json_dict/2`. Las reglas señalan los
problemas con errores ISO, y un solo predicado, `responder/1`, convierte
cada clase de error en su código: tipo y dominio en 400, existencia en
404. El núcleo no depende de HTTP.

**Cuándo no usarlo.** En una ruta que devuelve un archivo o una página
HTML: no hay JSON que armar, y los errores del servidor alcanzan.

Capítulo 30, [sección 30.4](capitulo-30-servicios-web-rest/index.md#304-codigos-de-estado-y-errores).

## 41 — Servidor bajo prueba

**Problema.** Las pruebas de un servicio tienen que ejercitar las rutas,
los códigos y el JSON de verdad, sin depender de un servidor que alguien
arrancó a mano ni de un puerto que puede estar ocupado.

**Versión ingenua.** Probar solo los predicados del núcleo, o arrancar el
servidor a mano en el puerto 8080 antes de ejecutar las pruebas.

**Patrón.** La unidad de pruebas arranca el servidor en su `setup`, en un
puerto libre de `localhost` —`port(localhost:Puerto)` con `Puerto`
libre—, recuerda el puerto y lo detiene en su `cleanup`. Cada prueba hace
un pedido y verifica el código de estado y el cuerpo. Las pruebas que
cambian datos los restauran, como en el [capítulo 20](capitulo-20-base-de-datos-dinamica/index.md).

**Cuándo no usarlo.** Para la lógica del núcleo: se prueba directamente,
sin HTTP, que es más rápido y señala el error con más precisión.

Capítulo 30, [sección 30.6](capitulo-30-servicios-web-rest/index.md#306-probar-un-servidor).

## 42 — Construir en un comando

**Problema.** Un programa que se entrega tiene que construirse igual cada
vez, en cada sistema, y lo construido tiene que comportarse como el
fuente.

**Versión ingenua.** Escribir a mano los comandos de construcción en cada
máquina, o anotarlos en un archivo de instrucciones, y probar el fuente
pero nunca lo construido.

**Patrón.** Un programa, `construir.pl`, recibe los programas y construye
cada uno en otro proceso de `swipl`, con las opciones que corresponden al
sistema. Un error de construcción es un error del constructor, con los
mensajes del proceso que falló. Las pruebas construyen de verdad en un
directorio temporal y ejecutan lo construido con los mismos argumentos
que el fuente: la batería del proyecto incluye lo que se entrega.

**Cuándo no usarlo.** Para un programa que solo se ejecuta desde el
fuente, en la máquina de quien lo escribe: `swipl programa.pl` alcanza.

Capítulo 31, [sección 31.3](capitulo-31-ejecutables-y-distribucion/index.md#313-linux).

## 43 — Recorrido genérico de un término

**Problema.** Varias operaciones —buscar, reemplazar, contar, simplificar—
se aplican a términos de forma desconocida, y cada una necesita recorrerlos
enteros.

**Versión ingenua.** Una recursión propia en cada operación, con `=..` y
`member/2`, que compara cada nodo por unificación: repite el recorrido en
todas, y liga las variables del término que examina.

**Patrón.** Un solo predicado de recorrido que recibe el trabajo por nodo
como argumento: las variables se dejan como están, los argumentos se
recorren con `mapargs/3`, y en cada nodo se llama al predicado recibido,
que compara con `==`. `library(terms)` ofrece `mapsubterms/3` y
`foldsubterms/4` para los casos frecuentes.

**Cuándo no usarlo.** Cuando la forma del término se conoce: una cláusula
por caso, como en el intérprete de reglas del
[capítulo 19](capitulo-19-operadores-y-reglas-como-datos/index.md), es más clara y aprovecha la indexación.

Capítulo 32, [sección 32.4](capitulo-32-inspeccion-de-terminos/index.md#324-recorrer-cualquier-termino).

## 44 — Representación limpia

**Problema.** Una estructura recursiva —un árbol, una expresión, una lista
anidada— tiene nodos de varias clases, y los predicados que la recorren
deben distinguirlas.

**Versión ingenua.** Distinguir las clases con pruebas de tipo: una hoja es
lo que no es una lista, una incógnita es lo que es un átomo. La respuesta
depende del momento en que se liga el argumento, y un valor con la forma de
otra clase no se puede representar.

**Patrón.** Un functor por clase de nodo —`h(X)`, `n(Hijos)`— y predicados
que eligen el caso por unificación en la cabeza. Los datos que llegan en
otra forma se convierten una vez, en el borde, sobre términos que
`must_be(ground, …)` garantiza cerrados.

**Cuándo no usarlo.** Cuando los términos son cerrados por contrato y
tienen una sintaxis que escriben personas, como las expresiones
aritméticas: sobre un término cerrado las pruebas de tipo son seguras, y
una representación propia obligaría a convertir en cada entrada y salida.

Capítulo 32, [sección 32.6](capitulo-32-inspeccion-de-terminos/index.md#326-representaciones-limpias).

## 45 — Intérprete que absorbe

**Problema.** Observar o cambiar la ejecución de un programa —registrar
cada paso, construir la prueba, limitar la búsqueda— sin reescribir el
motor de Prolog.

**Versión ingenua.** Representar todo lo que hace Prolog: sustituciones
explícitas, una unificación propia, una pila de alternativas. El
intérprete crece a cientos de líneas y es mucho más lento; o, en el otro
extremo, un intérprete que reconoce los objetivos por lo que no son y
produce un error con el primer predefinido.

**Patrón.** Delegar a Prolog lo que no se necesita observar —la
unificación y el retroceso, a través de `clause/2`— y reificar solo lo que
se va a observar o cambiar: la conjunción, el uso de cada cláusula. Los
cuerpos se convierten una vez, al leer la cláusula, a una representación
limpia, con los predefinidos admitidos enumerados.

**Cuándo no usarlo.** Cuando lo que se quiere cambiar es justamente lo
absorbido: una unificación con verificación de ocurrencias, otro orden de
las cláusulas, el corte. Entonces hay que reificarlo, y pagar su costo.

Capítulo 33, [sección 33.2](capitulo-33-introspeccion-y-metainterpretes/index.md#332-el-interprete-vainilla).

## 46 — Extender el intérprete, no el programa

**Problema.** Obtener de un programa algo más que sus respuestas: la
prueba, una traza, un límite, una explicación, el diagnóstico de un
error.

**Versión ingenua.** Agregar a cada predicado del programa un argumento
para la prueba, o una escritura en cada cláusula: el cambio se repite en
todo el programa, se mezcla con su lógica, y hay que deshacerlo después.

**Patrón.** Escribir la extensión una sola vez, en el intérprete: un
argumento más en sus cláusulas —el árbol, la profundidad, la pila de
objetivos, el oráculo— y una cláusula por cada construcción nueva. El
programa objeto no cambia, y cualquier programa obtiene la extensión.

**Cuándo no usarlo.** Cuando el costo del intérprete importa, como en la
ejecución normal de un programa en producción: la extensión se compila en
el programa, como hace el [capítulo 35](capitulo-35-transformacion-de-programas-y-compilacion/index.md), o se usan las herramientas del
sistema, como el depurador y `call_with_depth_limit/3`.

Capítulo 33, [sección 33.6](capitulo-33-introspeccion-y-metainterpretes/index.md#336-un-depurador-en-prolog).

## 47 — Lista diferencia para agregar al final

**Problema.** Construir una lista agregando elementos al final, o
concatenando resultados parciales, como al aplanar un árbol o al generar
una salida por partes.

**Versión ingenua.** Construir cada parte como lista cerrada y unirlas con
`append/3`, que recorre la primera para llegar a su final: con n partes el
costo puede llegar a n².

**Patrón.** Pasar cada parte como un par `L-F`, con F la variable del
final, o como dos argumentos separados. Concatenar es unificar el final de
una con el comienzo de la siguiente, y el resultado se cierra con `[]` una
sola vez, en el predicado de entrada. Cuando la construcción recorre una
estructura, se escribe como gramática, que hace la misma traducción
([sección 34.5](capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#345-las-gramaticas-como-listas-diferencia)).

**Cuándo no usarlo.** Cuando la lista se necesita dos veces o se examina
su final: una lista diferencia se usa una vez, y una prueba de vacía sin
verificación de ocurrencias crea términos cíclicos. En la interfaz de un
predicado, una lista cerrada es más clara; la lista diferencia queda en
los predicados auxiliares.

Capítulo 34, [sección 34.2](capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#342-de-append3-a-la-lista-diferencia).

## 48 — Diccionario incompleto

**Problema.** Asociar valores a claves cuando algunas se usan antes de
conocer su valor: una etiqueta a la que se salta antes de definirla, un
nombre al que se le asigna un número al final.

**Versión ingenua.** Dos pasadas: la primera reúne las claves y calcula
los valores, la segunda reemplaza cada clave por su valor; o una tabla
cerrada que se reconstruye en cada agregado.

**Patrón.** Una lista o un árbol con el final abierto, y un único
predicado de búsqueda que encuentra la clave o la agrega con el valor
libre. Cada uso de una clave comparte la variable de su valor; cuando el
valor se conoce, se liga una vez, y todos los usos lo ven.

**Cuándo no usarlo.** Cuando los valores cambian: una variable se liga
una sola vez, y una tabla que se actualiza necesita `library(assoc)` o
el estado del [capítulo 20](capitulo-20-base-de-datos-dinamica/index.md). Tampoco con claves que no están instanciadas:
la búsqueda unificaría una clave libre con la primera entrada.

Capítulo 34, [sección 34.4](capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#344-diccionarios-incompletos).

## 49 — Expandir al cargar

**Problema.** Un trabajo cuyo resultado se conoce al escribir el programa
se repite en cada ejecución: una llamada a un predicado de acceso, datos
escritos en una forma cómoda de leer pero distinta de la que conviene
consultar.

**Versión ingenua.** Hacer ese trabajo en cada llamada; o escribir a mano
la forma expandida en todos los lugares donde se usa.

**Patrón.** Escribir la forma cómoda y un gancho, `term_expansion/2`
para los términos del programa o `goal_expansion/2` para los objetivos
de los cuerpos, que la reemplaza al cargar. El gancho se define antes que
lo que expande, y el predicado original se conserva para las llamadas
construidas durante la ejecución.

**Cuándo no usarlo.** Cuando la ganancia no se midió; cuando el gancho
de `user` alcanzaría términos ajenos, porque se aplica a todo lo que se
carga después; y cuando lo que se expande cambia durante la ejecución.
Una `goal_expansion/2` cuyo resultado vuelve a coincidir con ella misma,
con otro argumento, no termina.

Capítulo 35, [sección 35.1](capitulo-35-transformacion-de-programas-y-compilacion/index.md#351-term_expansion2-y-goal_expansion2-en-swi-prolog).

## 50 — Especializar el intérprete

**Problema.** Un intérprete —[Patrón 45](patrones.md#45-interprete-que-absorbe),
[Patrón 46](patrones.md#46-extender-el-interprete-no-el-programa)— paga en cada consulta el recorrido
de una estructura que no cambia: los cuerpos de las cláusulas, las
condiciones de las reglas.

**Versión ingenua.** Interpretar siempre; o escribir a mano un compilador
aparte, que hay que mantener de acuerdo con el intérprete.

**Patrón.** Evaluar parcialmente el intérprete respecto del programa: un
evaluador parcial despliega las llamadas del intérprete cuyo argumento de
control se conoce y deja como residuo las que dependen de los datos. El
resultado son cláusulas comunes que hacen lo que el intérprete haría. Un
predicado de control decide qué se despliega y dónde se detiene la
evaluación; con `term_expansion/2`, la especialización ocurre al cargar.

**Cuándo no usarlo.** Cuando el programa interpretado cambia durante la
ejecución: una regla agregada con `assertz/1` a un predicado dinámico la
ve el intérprete y no la versión especializada. Cuando lo que se
despliega tiene cortes o efectos laterales. Y cuando el costo del
intérprete no se midió o no pesa.

Capítulo 35, [sección 35.4](capitulo-35-transformacion-de-programas-y-compilacion/index.md#354-evaluacion-parcial).

## 51 — Modelo de pantalla

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
como la de la [sección 28.5](capitulo-28-programas-de-linea-de-comandos/index.md#285-leer-del-teclado): no hay pantalla que modelar. Y
cuando la pantalla es enorme y cambia poco: redibujarla entera en cada
tecla es lento, y conviene comparar el modelo nuevo con el anterior y
escribir solo las líneas distintas.

Capítulo 36, [sección 36.2](capitulo-36-interfaces-de-usuario/index.md#362-pantalla-completa-en-la-terminal).

## 52 — Estado compartido detrás de un mutex

**Problema.** Varios hilos leen un dato de la base de datos, deciden
según lo leído y lo cambian: un cupo, un contador, un saldo. Cada
operación es atómica, pero la secuencia no, y dos hilos pueden decidir
con el mismo valor.

**Versión ingenua.** La secuencia de un solo hilo, `retract/1` y
`assertz/1`, sin protección: correcta en las pruebas de a una llamada, y
con varios hilos pierde actualizaciones, excede el cupo o falla en un
`retract/1` cuya cláusula ya quitó otro hilo.

**Patrón.** Toda secuencia que lee y cambia el dato pasa por un
predicado que la ejecuta con `with_mutex/2`, siempre con el mismo nombre
de mutex; si los que solo leen no deben ver un cambio a medias, la
secuencia va además dentro de `transaction/1`. Cuando la decisión es
costosa y los conflictos son raros, `transaction/3` con una restricción
que verifica lo leído, repetida hasta que confirma. Las pruebas corren
muchos hilos y comparan cantidades: el invariante, no el orden.

**Cuándo no usarlo.** Cuando el dato puede ser de cada hilo
(`thread_local/1`) o viajar en mensajes (una cola). Cuando solo se
agregan hechos independientes: `assertz/1` ya es atómico. Y no dentro
del mutex la entrada y salida lenta, como leer de la red: todos los
hilos esperarían a ese cliente.

Capítulo 37, [sección 37.3](capitulo-37-concurrencia-y-paralelismo/index.md#373-estado-compartido).

## 53 — Tabular la relación recursiva

**Problema.** Una relación recursiva no termina —recursión a la
izquierda, un grafo con ciclos, una negación a través de la recursión— o
resuelve los mismos subproblemas muchas veces.

**Versión ingenua.** Reordenar las cláusulas y los objetivos hasta que
la consulta de las pruebas termine, llevar una lista de nodos visitados,
o guardar los resultados con `assertz/1` ([Patrón 17](patrones.md#17-memorizacion-con-assertz)): cada una
cambia la definición, deja estado que mantener o pierde respuestas, y
ninguna hace terminar una recursión a la izquierda.

**Patrón.** Dejar las cláusulas como la definición del problema y
declarar `:- table p/N`. Si solo interesa la mejor respuesta, declarar
el modo del argumento (`min`, `max`, `lattice(P/3)`); si la recursión
pasa por una negación, escribirla con `tnot/1`; si las respuestas
dependen de un predicado dinámico, declarar los dos `incremental`. Las
pruebas comparan las respuestas ordenadas, porque la tabla no tiene un
orden fijo.

**Cuándo no usarlo.** Cuando la relación tiene infinitas respuestas
distintas —un recorrido guardado como lista sobre un grafo con ciclos, un
contador que crece—: la tabla no se completa nunca. Cuando el predicado
tiene efectos, que se ejecutarían una vez por tabla y no por llamada.
Cuando hace falta la primera respuesta pronto: una tabla entrega sus
respuestas al completarse. Y en un predicado barato y sin repeticiones,
donde la tabla solo agrega costo ([sección 39.6](capitulo-39-tabulacion/index.md#396-lo-que-cuesta)).

Capítulo 39, [sección 39.2](capitulo-39-tabulacion/index.md#392-memorizacion-sin-estado-escrito-a-mano).

## 54 — La frontera decide la estrategia

**Problema.** Es necesario buscar un plan en un espacio de estados, y
probar más de un orden de búsqueda sin reescribir la búsqueda.

**Versión ingenua.** Una búsqueda recursiva por cada estrategia —la de
Prolog en profundidad, otra para la anchura, otra más para el costo—,
con el problema mezclado en cada una; o una sola búsqueda con la agenda
guardada en la base de datos dinámica.

**Patrón.** El problema como término, descrito por `inicial/2`,
`meta/2` y `sucesor/5`. Un solo bucle que saca un nodo, comprueba la
meta y agrega los hijos; la estrategia es la estructura de datos de la
frontera, que el bucle recibe como argumento: una pila, una cola o un
montículo con la prioridad que corresponda. Los hijos comparten el
camino de su padre.

**Cuándo no usarlo.** Cuando la búsqueda en profundidad de Prolog basta
—un espacio sin ciclos o con la longitud acotada—: la recursión es más
corta y no guarda nada. Cuando el problema se modela mejor con
restricciones ([capítulo 23](capitulo-23-programacion-con-restricciones/index.md)). Y cuando la frontera no
cabe en memoria: la profundización iterativa guarda un solo camino.

Capítulo 40, [sección 40.2](capitulo-40-busqueda-y-planificacion/index.md#402-una-sola-busqueda-varias-estrategias).

## 55 — Poda alfa-beta

**Problema.** Es necesario elegir una jugada con minimax en un juego
cuyo árbol crece exponencialmente con la profundidad, y la búsqueda
completa hasta la profundidad deseada es demasiado lenta.

**Versión ingenua.** Minimax que busca todas las jugadas de cada
posición hasta el límite y recién entonces compara sus valores: visita
posiciones cuyo valor no puede cambiar la jugada elegida.

**Patrón.** Cada posición se busca con dos cotas: alfa, lo que max ya
tiene asegurado, y beta, lo que min ya tiene asegurado. Las jugadas de
una posición se recorren de a una; una jugada que alcanza la cota del
rival corta la búsqueda de las demás, y una que mejora la cota propia la
estrecha para las siguientes. El valor devuelto es exacto dentro del
intervalo y una cota fuera de él; en la raíz, con `-inf` e `inf`, es el
valor minimax, con la misma jugada.

**Cuándo no usarlo.** Cuando el árbol es pequeño y se busca entero una
sola vez: minimax es más simple. Cuando se necesita el valor exacto de
todas las jugadas y no solo de la mejor, para mostrarlas o para
ordenarlas: la poda da cotas. Y cuando las posiciones se repiten mucho
y el juego se busca hasta el final: una tabla de transposición
([sección 41.6](capitulo-41-juegos/index.md#416-tablas-de-transposicion-con-tabulacion)) ahorra
más, y las cotas dificultan reutilizar lo guardado.

Capítulo 41, [sección 41.3](capitulo-41-juegos/index.md#413-la-poda-alfa-beta).

## 56 — Medida que decrece

**Problema.** Un programa aplica reglas de reescritura una tras otra
hasta que ninguna se aplica, y hay que asegurar que esa cadena termina,
aunque las reglas sean datos que otro archivo puede ampliar.

**Versión ingenua.** Aceptar cualquier reescritura que se aplique. Con
una regla y su inversa, como `W * W ~> W ^ 2` y `W ^ 2 ~> W * W`, el
término vuelve a su forma anterior y la cadena no termina (el
ejercicio 3 lo muestra).

**Patrón.** Una medida que asigna un número natural a cada término, y
cada paso se acepta solo si la reduce: `colectar/3` compara las
apariciones de la incógnita antes y después, y descarta la reescritura
que no las baja. Como no hay una cadena infinita de naturales
decrecientes, la cadena de reescrituras termina, cualquiera que sea el
conjunto de reglas. Cuando un método no puede bajar la primera medida
usa una segunda, sin aumentar la primera: la atracción de la
[sección 43.4](capitulo-43-proyecto-resolver-ecuaciones/index.md#434-version-3-la-atraccion) baja la distancia entre las
apariciones.

**Cuándo no usarlo.** Cuando el paso necesario aumenta toda medida
sencilla, como distribuir un producto: entonces conviene un cálculo
recursivo sobre la estructura del término, como la forma normal de la
[sección 43.5](capitulo-43-proyecto-resolver-ecuaciones/index.md#435-version-4-la-forma-normal-de-un-polinomio). Y
cuando el proceso es numérico, como el método de Newton de la
[sección 43.6](capitulo-43-proyecto-resolver-ecuaciones/index.md#436-version-5-el-metodo-de-newton-y-la-comprobacion):
ahí no hay un natural que baje, y lo que asegura el final es una cota
de pasos y una tolerancia.

Capítulo 43, [sección 43.3](capitulo-43-proyecto-resolver-ecuaciones/index.md#433-version-2-reglas-de-reescritura-y-coleccion).

## 57 — Impedimento y efecto

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
[sección 44.5](capitulo-44-proyecto-aventura-de-texto/index.md#445-version-4-ordenes-y-respuestas-en-castellano), elige
la lectura de una orden que ningún impedimento bloquea.

**Cuándo no usarlo.** Cuando lo que impide la orden solo se conoce al
intentarla, como abrir un archivo: ahí decide el sistema, y la
respuesta es un error; lo que sí se comprueba antes es la validez de
los datos ([Patrón 31](patrones.md#31-validar-al-entrar)), como hace
`cargar/1` en la
[sección 44.4](capitulo-44-proyecto-aventura-de-texto/index.md#444-version-3-guardar-y-cargar-una-partida). Y cuando una
orden tiene una sola condición y un solo aviso: un `->` en el propio
predicado alcanza.

Capítulo 44, [sección 44.3](capitulo-44-proyecto-aventura-de-texto/index.md#443-version-2-el-estado-detras-de-una-interfaz).

## 58 — Etiquetas como variables lógicas

**Problema.** Un generador produce saltos a posiciones que todavía no
existen: el destino de un salto hacia adelante se conoce recién cuando
se genera el código que lo sigue.

**Versión ingenua.** Nombrar las etiquetas con un contador que la
generación lleva de una cláusula a otra, y ensamblar en dos pasadas:
la primera anota en una tabla la dirección de cada etiqueta, y la
segunda reemplaza cada nombre por la dirección que la tabla le da.

**Patrón.** Cada etiqueta es una variable nueva, creada por la cláusula
que genera el `si` o el `mientras`, y los saltos la llevan como
argumento. El ensamblador, en una sola pasada, unifica la variable de
cada marca con la dirección actual, y así quedan resueltos todos los
saltos a esa etiqueta, los anteriores y los posteriores; una marca
repetida en otra dirección hace fallar el ensamblado. Las reglas que
reescriben el código simbólico antes de ensamblarlo comparan las
etiquetas con `==`, que no liga nada: una cabeza que repite una
variable las unificaría y juntaría dos etiquetas distintas, como
muestra la página
[Optimización](capitulo-45-proyecto-compilador/optimizacion.md#optimizacion).

**Cuándo no usarlo.** Cuando el código simbólico se reparte en partes
que no forman un solo término, como un archivo con una instrucción por
cláusula o piezas compiladas por separado: una variable vale solo
dentro de su término, y ahí hacen falta nombres. Y cuando una
transformación necesita unificar libremente instrucciones enteras:
conviene aplicarla después de ensamblar, cuando las etiquetas ya son
números y unificarlas es compararlas.

Capítulo 45, [sección 45.4](capitulo-45-proyecto-compilador/index.md#454-la-generacion-de-codigo-y-el-ensamblador).

## 59 — Intérprete con conducta como parámetro

**Problema.** Una misma estructura —un circuito, un programa, una red—
tiene que responder varias preguntas: qué valores da, qué fórmula
calcula, qué pasa si una pieza falla. Cada pregunta da otro significado
a las piezas, pero la forma de combinarlas es siempre la misma.

**Versión ingenua.** Escribir la estructura como reglas, como la
versión 1 de la
[sección 48.1](capitulo-48-proyecto-circuitos-logicos/index.md#481-compuertas-como-tablas-circuitos-como-reglas), que
le dan un solo significado; o escribir un recorrido de la descripción
por cada pregunta, que repite la asociación de cables con variables y
el descenso por la jerarquía, y que hay que corregir en todas las
copias.

**Patrón.** La estructura se describe una vez, como datos
(`circuito/3` y `componente/5`), y un solo intérprete, `simular/4`, la
recorre y recibe como argumento la **conducta** de cada pieza. Cada
significado es una conducta: `normal/4` da los valores, `simbolica/4`
las fórmulas, la de la
[sección 48.4](capitulo-48-proyecto-circuitos-logicos/index.md#484-verificar-con-libraryclpb) una restricción
booleana; el ejercicio 5 agrega una falla y el ejercicio 11, la
profundidad del circuito. Es la misma idea que el ciclo `iterar/4` del
[capítulo 46](capitulo-46-proyecto-metodos-numericos/index.md#462-la-ecuacion-como-termino-y-el-ciclo-de-iteracion),
que recibe el paso de cada método, y que el
[Patrón 43](patrones.md#43-recorrido-generico-de-un-termino), que
recibe el trabajo por nodo: aquí el recorrido sigue una descripción
con nombres y jerarquía, no la forma de un término.

**Cuándo no usarlo.** Cuando la estructura tiene un solo significado:
las reglas de la versión 1 son más directas. Y cuando la pregunta es
sobre la estructura misma y no sobre lo que calcula, como contar las
compuertas o enumerarlas con `compuerta_en/3`: una consulta sobre los
datos basta, sin intérprete.

Capítulo 48, [sección 48.3](capitulo-48-proyecto-circuitos-logicos/index.md#483-que-calcula-un-circuito).

## 60 — Estado como resultado, no como falla

**Problema.** Un paso de un intérprete o de una simulación puede
fallar, y el estado que produce lleva algo que no debe perderse aunque
falle: contadores, medidas, un registro de lo que ocurrió.

**Versión ingenua.** Escribir el paso como un predicado `semidet` que
falla cuando falla la meta. La falla de Prolog deshace todo lo que el
paso calculó, y quien lo llama se queda con el estado de antes: las
cabezas intentadas en una llamada que no encuentra ninguna cláusula
desaparecen de las medidas, y la columna `intentos` cuenta de menos.

**Patrón.** El paso es `det` y devuelve el estado dentro de un término
que dice qué pasó: `sigue(Estado)` o `falla(Estado)`, y la vuelta atrás
`sigue(Estado)` o `fin(Estado)`. Quien lo llama elige el camino por el
functor, con la indexación por el primer argumento, y la falla de la
meta queda como un dato, con el estado al día. Es el mismo principio
que el [Patrón 44](patrones.md#44-representacion-limpia) aplicado al
resultado: un functor por cada clase.

**Cuándo no usarlo.** Cuando el estado de un intento fallido no
importa, la falla de Prolog es más directa y más barata: `usar/5`, que
prueba una sola cabeza, sigue siendo `semidet`. Y cuando el paso tiene
varias soluciones que Prolog debe enumerar, el resultado ya no es
uno solo.

Capítulo 61, [sección 61.4](capitulo-61-proyecto-maquina-prolog/index.md#614-celdas-almacen-y-rastro).

## 61 — Superioridad como parámetro

**Problema.** Un intérprete de reglas con excepciones tiene que decidir
qué regla prevalece cuando dos concluyen cosas contrarias, y hay más de
un criterio razonable: ninguno, la regla más específica, una prioridad
declarada, la anticipación de los rivales. Cada base, y a veces cada
consulta, necesita otro, y conviene comparar lo que decide cada uno.

**Versión ingenua.** Fijar el criterio dentro del intérprete, o
escribir las excepciones dentro de las reglas con `\+`, como en la
[sección 65.1](capitulo-65-proyecto-razonamiento-rebatible/index.md#651-el-problema-excepciones-con-negacion-como-falla): cambiar de criterio obliga a reescribir el intérprete
o la base, y comparar dos criterios sobre la misma base obliga a
mantener dos copias.

**Patrón.** El criterio es un argumento del intérprete, una lista de
fuentes de superioridad, y un solo predicado, `supera/3`, lo consulta.
La base no cambia: la misma consulta con `[]`, `[especificidad]` o
`[declarada, especificidad]` muestra qué decide cada criterio, y un
criterio nuevo, como la anticipación de la
[sección 65.7](capitulo-65-proyecto-razonamiento-rebatible/index.md#657-version-6-la-anticipacion-de-los-rivales), es un elemento más de la lista. Es un caso del
[Patrón 59](patrones.md#59-interprete-con-conducta-como-parametro): allí el argumento es la conducta de cada pieza; aquí, la
política que resuelve los conflictos entre las piezas.

**Cuándo no usarlo.** Cuando las reglas no compiten nunca, o cuando un
solo criterio vale para todo el sistema y no hace falta compararlo con
otros: una prioridad fija, como el orden de las reglas de un sistema de
producción, es más simple. Y cuando la superioridad depende de los
datos, no del razonamiento: entonces es parte de la base, con hechos
`superior/2`, y el parámetro solo dice si se los usa.

Capítulo 65, [sección 65.3](capitulo-65-proyecto-razonamiento-rebatible/index.md#653-version-2-la-regla-mas-especifica).

## 62 — Especializar podando por el ejemplo

**Problema.** Es necesario buscar, en un grafo de especialización,
una cláusula que cubra un ejemplo positivo y ningún negativo, y el
grafo crece exponencialmente con la cantidad de refinamientos.

**Versión ingenua.** Generar todos los refinamientos de cada cláusula
y examinar cada uno hasta el límite de profundidad, aunque ya no
cubra el ejemplo que se quiere explicar: se recorren ramas enteras
en las que ninguna cláusula puede ser la buscada.

**Patrón.** Un refinamiento es una especialización: cubre a lo sumo lo
que cubría la cláusula de la que sale. Se elige un ejemplo positivo,
la semilla, y se descarta todo refinamiento que no lo cubre, antes de
examinar sus propios refinamientos. La prueba de cobertura de la
semilla es barata, un solo ejemplo, y corta ramas completas del grafo.

**Cuándo no usarlo.** Cuando la cobertura no es monótona respecto del
refinamiento: con negación en el cuerpo, o con literales que se
evalúan con efectos, agregar un literal puede hacer cubrir un ejemplo
que antes no se cubría. Y cuando se busca la cláusula que cubre más
ejemplos sin una semilla fija: entonces la cota es la cantidad de
positivos que todavía se cubren, no uno solo.

Capítulo 67, [sección 67.5](capitulo-67-proyecto-aprender-reglas-ejemplos/index.md#675-version-4-induccion-descendente).

## 63 — Bordes en lugar del conjunto

**Problema.** Es necesario mantener el conjunto de las hipótesis
consistentes con los ejemplos vistos, y el conjunto crece
exponencialmente con la cantidad de atributos del lenguaje.

**Versión ingenua.** Enumerar el lenguaje entero y probar cada
concepto contra todos los ejemplos, como `version/2` en la versión 1:
con seis atributos extra son 589 825 conceptos y 7 099 970
inferencias.

**Patrón.** Las hipótesis están ordenadas por generalidad, y el
conjunto queda descrito por sus elementos mínimos y máximos. Se
guardan solo esos dos bordes, `ev(S, G)`, y cada ejemplo los actualiza
con una generalización o una especialización mínima, podando cada
borde con el otro, como hace `actualizar/3`. El conjunto no se
construye nunca: `traza/1` mide que los conceptos entre los bordes son
exactamente los consistentes, y el costo crece 136 inferencias por
atributo.

**Cuándo no usarlo.** Cuando el lenguaje no garantiza una cadena de
generalizaciones mínimas entre dos conceptos comparables: entonces lo
que está entre los bordes puede no ser el conjunto buscado. Cuando los
ejemplos tienen ruido: un solo ejemplo mal clasificado vacía los
bordes. Y cuando el lenguaje es chico y se necesita el conjunto
mismo, para contarlo o recorrerlo: con 145 conceptos la enumeración
cuesta 1 991 inferencias, y los bordes no dan el conjunto sin
reconstruirlo, como hace `conceptos_entre/2` en la versión 4.

Capítulo 68, [sección 68.3](capitulo-68-proyecto-espacios-versiones-generalizacion-explicacion/index.md#683-version-3-eliminacion-de-candidatos).

## 64 — Historia en el estado del ciclo

**Problema.** Un ciclo que se detiene al alcanzar una tolerancia puede
no alcanzarla nunca, y es necesario distinguir un proceso que todavía
no convergió de uno que repite estados y no convergerá.

**Versión ingenua.** Confiar en el límite de pasos, como `entrenar/5`
en la versión 2: después de 1000 épocas `iterar/5` falla, sin la curva
y sin decir si con más épocas se habría terminado. O escribir otro
ciclo, con una lista de estados vistos, que repite el de la
[sección 46.2](capitulo-46-proyecto-metodos-numericos/index.md#462-la-ecuacion-como-termino-y-el-ciclo-de-iteracion).

**Patrón.** El ciclo no cambia; cambia el paso. `iterar/5` pasa de un
paso al siguiente un término cualquiera, y `paso_con_memoria/6` lo usa
para llevar el par `Pesos-Vistos`: agrega los pesos anteriores a los
vistos y da cambio 0 cuando los nuevos ya estaban. Si el paso es una
función del estado, un estado repetido demuestra el ciclo, y
`entrenar_o_ciclo/4` lo informa como `ciclo(Largo, Curva)`.

**Cuándo no usarlo.** Cuando los estados no pertenecen a un conjunto
finito, como los pesos de punto flotante: la repetición exacta no está
garantizada, y el ciclo termina por el límite de pasos como antes.
Cuando el paso no es una función del estado, porque depende de un
orden aleatorio o de un contador: un estado repetido no prueba nada.
Y cuando el ciclo es largo: `memberchk/2` recorre la historia en cada
paso, y una historia de n estados cuesta del orden de n² comparaciones.

Capítulo 69, [sección 69.4](capitulo-69-proyecto-perceptron/index.md#694-version-3-separables-o-en-ciclo).

## 65 — Descripción del mundo como parámetro

**Problema.** Un planificador tiene que servir para más de un mundo
—los cubos, el robot de STRIPS, el mundo con pinza del
[capítulo 40](capitulo-40-busqueda-y-planificacion/index.md)—, y algunos de esos mundos ya están descritos
en otro formato.

**Versión ingenua.** Escribir las acciones del mundo dentro del
planificador, como cláusulas de la regresión, o copiar el planificador
para cada mundo; y, para un mundo que ya existe, reescribir su
descripción a mano en el formato nuevo, con dos copias que hay que
mantener iguales.

**Patrón.** El planificador recibe el nombre del módulo del mundo como
primer argumento de `planificar/5` y solo llama a un conjunto fijo de
predicados descriptivos: `agrega/2`, `borra/2`, `puede/2`,
`imposible/1`, `siempre/1`, `prueba/1` y `dado/2`, siempre como
`Mundo:agrega(H, A)`. Otro mundo es otro módulo con los mismos siete
predicados: `robot.pl` los define en parte con reglas, y el mismo
código planifica en los dos. Una descripción existente se reutiliza con
una traducción pequeña: `pinza.pl` carga los operadores STRIPS del
[capítulo 40](capitulo-40-busqueda-y-planificacion/index.md) en un módulo propio y define `agrega/2`, `borra/2`,
`puede/2` y `dado/2` con una o dos líneas cada uno, sin copiar el
mundo. Se diferencia del
[Patrón 54](patrones.md#54-la-frontera-decide-la-estrategia), en el
que el problema es fijo y la estrategia de búsqueda es el parámetro, y
del [Patrón 59](patrones.md#59-interprete-con-conducta-como-parametro),
en el que la estructura es fija y el parámetro da el significado de sus
piezas: aquí el algoritmo y su significado son fijos, y lo que varía
son los datos sobre los que razona, una descripción de varias
relaciones y no una sola función de sucesores.

**Cuándo no usarlo.** Cuando hay un solo mundo y no se espera otro: la
llamada calificada y la interfaz fija agregan una indirección sin
beneficio. Cuando la traducción deja de ser pequeña: la versión 4 mide
que los operadores sin variables del
[capítulo 40](capitulo-40-busqueda-y-planificacion/index.md) cuestan más del doble
de inferencias que `cubos.pl`, y sin la cota agotan la pila; un mundo
que el planificador recorre mal se describe de nuevo, con variables.
Y cuando el mundo necesita algo que la interfaz no expresa, como
acciones con costo o efectos que dependen del estado: entonces cambia
la interfaz, y con ella todos los mundos.

Capítulo 70, [sección 70.6](capitulo-70-proyecto-planificacion-regresion/index.md#706-version-4-el-mundo-del-capitulo-40).

## 66 — Resultado recordado, sin copiar

**Problema.** Una búsqueda que construye un resultado, como un árbol
solución, encuentra el mismo subproblema muchas veces, y resolverlo
cada vez multiplica el trabajo y el tamaño del resultado.

**Versión ingenua.** Resolver cada aparición por separado, como la
versión 2: la torre de 10 discos expande 1 023 nodos, uno por cada
aparición de `torre(K, De, A)`, aunque solo hay 27 subproblemas
distintos, y el árbol tiene una copia de cada subárbol repetido.

**Patrón.** Un assoc asocia cada subproblema resuelto con su
resultado, y viaja en el estado de la búsqueda junto con la cuenta de
expansiones, como `m(Memoria, K)` en `recordado/5`. Antes de expandir
un nodo se lo busca con `get_assoc/3`; si ya está, se usa **el mismo
término**, sin copiarlo. El resultado es una estructura compartida: el
árbol de la torre de 20 discos describe 1 048 575 movimientos, se
construye con 57 expansiones y ocupa en la memoria un nodo por
subproblema distinto. Se diferencia del
[Patrón 53](patrones.md#53-tabular-la-relacion-recursiva) en dos
cosas: la tabla de `:- table` es global al predicado y entrega cada
respuesta como una copia, de modo que los subárboles repetidos dejan de
ser el mismo término; el assoc es local a una búsqueda, conserva la
compartición y permite contar lo que se expande.

**Cuándo no usarlo.** Cuando el resultado de un nodo depende del camino
por el que se llegó a él, como en el mapa, donde un nodo no puede usar
a sus ancestros: el resultado recordado por un camino es incorrecto por
otro, y el [ejercicio 10](capitulo-71-proyecto-grafos-o/index.md#ejercicios) lo muestra. Cuando los
subproblemas no se repiten, como en un árbol de búsqueda sin nodos
comunes: el assoc solo agrega costo. Y cuando lo que se hace con el
resultado lo recorre entero: `costo/2` visita el millón de hojas del
árbol compartido, y el [ejercicio 7](capitulo-71-proyecto-grafos-o/index.md#ejercicios) pide recordar
también ese cálculo.

Capítulo 71, [sección 71.7](capitulo-71-proyecto-grafos-o/index.md#717-version-5-subproblemas-compartidos).

## 67 — Resultado con garantía

**Problema.** Una búsqueda exacta, como A\* con una heurística
admisible, da el óptimo, pero su costo puede crecer de un caso al
siguiente sin aviso, y es necesario responder siempre dentro de un
presupuesto.

**Versión ingenua.** Ejecutar la búsqueda exacta sin límite, como
`optimo/4`, que en `taller(14)` cuesta casi diez millones de
inferencias; o cortarla con un límite y, si se alcanza, fallar o
devolver una solución heurística sin decir cuánto puede alejarse del
óptimo.

**Patrón.** Empezar por lo barato: una solución rápida, el mejor
calendario por lista, y una **cota inferior** probada, la estimación
admisible en el estado inicial que calcula `cota_inferior/2`. Si
coinciden, la solución es óptima sin buscar. Si no, la búsqueda exacta
corre dentro de `call_with_inference_limit/3`; si termina, su
resultado es óptimo, y si pasa del límite, `planificar/4` devuelve la
solución rápida junto con `entre(Cota, D)`. La respuesta dice qué se
sabe: en `taller(13)`, con un millón de inferencias, un calendario de
28 que no puede mejorarse en más de una unidad; con tres millones,
el de 27, `optima(a_estrella)`. La garantía es un término que el
llamador examina, no un mensaje.

**Cuándo no usarlo.** Cuando no hay una cota inferior barata y
probada: una estimación que no es admisible convierte la garantía en
una afirmación falsa. Cuando la cota es tan débil que el intervalo no
informa nada. Y cuando el costo de la búsqueda exacta está acotado de
antemano, como en los proyectos chicos: el límite y la cota agregan
trabajo a una respuesta que igual llega.

Capítulo 72, [sección 72.7](capitulo-72-proyecto-planificacion-tareas/index.md#727-version-5-el-planificador).

## 68 — Transformación como par de términos

**Problema.** Es necesario aplicar muchas veces una transformación que
reordena las partes de un término de tamaño fijo, como un giro del
cubo, y también componer transformaciones, invertirlas y saber qué
partes cambian.

**Versión ingenua.** Escribir cada transformación como un
procedimiento que lee el término argumento por argumento y construye
otro; su inversa es otro procedimiento, y una secuencia se aplica paso
a paso cada vez: `dos_esquinas`, de 18 giros, aplicada como lista
cuesta 58 002 inferencias en mil aplicaciones.

**Patrón.** La transformación es un par `Antes-Despues` de dos
términos que comparten sus variables, en otro orden, como los hechos
`giro(Cara, Antes, Despues)` de la versión 1. Aplicarla es **una
unificación**: `Antes` con el término, y `Despues` es el resultado.
Componer es aplicarla a un término de variables libres: `compilar/2`
aplica una secuencia a un `c/54` sin ligar y obtiene otro par con la
forma de un giro, que se aplica con `usar/3` en 3 002 inferencias las
mismas mil veces. El mismo hecho, leído en sentido inverso, da la
inversa, como `mover/3` para `-Cara`. Y el par dice qué hace sin
aplicarlo: `efecto/2` compara las variables con `==/2`.

**Cuándo no usarlo.** Cuando la transformación depende de los valores
y no solo de las posiciones, como una que cambia un color según otro:
un par de términos solo reordena, copia o descarta partes. Cuando no es
una permutación: si `Despues` repite una variable o no contiene
alguna, leer el par en sentido inverso no da la inversa, sino una
restricción de igualdad o una parte libre. Y cuando el par no es un
hecho sino un término que viaja en una variable: la primera
aplicación liga sus variables, y cada uso siguiente necesita antes
una copia con `copy_term/2`; por eso `term_expansion/2` guarda cada
macro compilada como un hecho.

Capítulo 74, [sección 74.5](capitulo-74-proyecto-cubo-rubik/index.md#745-version-4-los-macrooperadores).
