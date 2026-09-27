# Patrones

Las [plantillas](plantillas.md) de la parte I son las formas de los predicados:
recorrer una lista, acumular, generar y probar. Los patrones de la parte II son
las formas del trabajo profesional: cómo se escribe un predicado que otros van a
llamar, cómo se reúnen respuestas, cómo se aísla el estado, cómo se prueba y se
entrega un programa.

Cada patrón se presenta en el capítulo donde se lo necesita, con el ejemplo que
lo motiva. Aquí figura el texto completo de cada recuadro, copiado del capítulo,
para consultarlos y compararlos; la página se amplía a medida que avanza la
parte II.

## Criterios de calidad

Todo el código de la parte II se revisa con estos siete criterios. El
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

**Patrón.** `( Generador, Efecto, fail ; true )` para recorrer respuestas;
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
versión directa es más clara.

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
los reúne, como el par `Cantidad-Suma` de la [sección 18.8](capitulo-18-orden-superior/index.md#188-el-proyecto-informes-genericos).

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
cuando `:- table` resuelve lo mismo ([capítulo 38](capitulo-38-tabulacion/index.md)).

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
una heurística que guíe la búsqueda, como en el [capítulo 39](capitulo-39-busqueda-y-juegos/index.md); o
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
