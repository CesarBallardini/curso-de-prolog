# Patrones

Las [plantillas](plantillas.md) de la parte I son las formas de los predicados:
recorrer una lista, acumular, generar y probar. Los patrones de la parte II son
las formas del trabajo profesional: cómo se escribe un predicado que otros van a
llamar, cómo se reúnen respuestas, cómo se aísla el estado, cómo se prueba y se
entrega un programa. Los de la parte III, desde el 43, son las técnicas de
un programador avanzado: los términos y los programas como datos, las
estructuras incompletas, la transformación de programas, las interfaces, la
concurrencia, la tabulación y la búsqueda. Los de la parte IV, del 56 al 103,
son las decisiones de diseño que aparecen al construir programas completos: la
representación del problema, la forma del intérprete, la búsqueda y su
verificación.

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
para consultarlos y compararlos.

## Criterios de calidad

Todo el código de las partes II a IV se revisa con estos siete criterios. El
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
cambio, y repetir algunas consultas una por una.

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
[16](capitulo-16-rendimiento/index.md)).

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
condición y la salida en la cabeza, como `categoria/2` del [capítulo 9](capitulo-09-backtracking-y-corte/index.md).

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
bucle por falla deshace las ligaduras en cada iteración, y lo único que queda
son los efectos. Para calcular, una recursión o las herramientas del
[capítulo 17](capitulo-17-todas-las-soluciones/index.md), que presenta además `forall/2`, la forma declarativa de este mismo
recorrido.

Capítulo 15, [sección 15.7](capitulo-15-control/index.md#157-bucles-por-falla).

## 8 — Recursión en espacio constante

**Problema.** Una recursión que funciona con listas cortas agota la pila
con listas largas.

**Versión ingenua.** La operación después de la llamada recursiva:
`largo([_|R], N) :- largo(R, N0), N is N0 + 1.`

**Patrón.** Un acumulador que lleva el resultado parcial ([plantilla 13](plantillas.md#13-acumulador)), la
operación antes de la llamada, y la llamada recursiva como último objetivo,
sin alternativas pendientes.

**Cuándo no usarlo.** Cuando la recursión es naturalmente corta —la
profundidad de un árbol genealógico, los casos de una definición— y la
versión directa es más clara. Tampoco cuando el resultado es una lista que
se construye en la cabeza de la cláusula ([plantilla 12](plantillas.md#12-construir-una-lista-durante-el-recorrido-de-otra)): esa recursión ya
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

**Versión ingenua.** Repetir los datos en una lista escrita de manera
explícita, como en
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
negación escrita de manera explícita: `\+ (C, \+ A)`.

**Patrón.** `forall(Condicion, Accion)`, con las variables de `Condicion`
ligadas en ella y usadas en `Accion`.

**Cuándo no usarlo.** Cuando se necesita saber **cuál** no cumple:
`forall/2` solo responde sí o no. En ese caso, se busca el contraejemplo con
un objetivo que lo genere, como las pruebas de datos del [capítulo 13](capitulo-13-el-entorno-de-trabajo/index.md).

Capítulo 17, [sección 17.6](capitulo-17-todas-las-soluciones/index.md#176-forall2).

## 14 — Recorrido con `maplist`

**Problema.** Es necesario aplicar la misma relación a cada elemento de
una o varias listas: comprobar, transformar o procesar cada uno.

**Versión ingenua.** Una recursión explícita, con su caso base y su caso
recursivo, que repite la forma de la plantilla en cada predicado.

**Patrón.** `maplist(Relacion, L1, …)`, con `Relacion` un predicado con
nombre y encabezado propio, o una clausura que fija sus primeros
argumentos.

**Cuándo no usarlo.** Cuando el recorrido debe detenerse en el primer
elemento que cumple una condición ([plantilla 10](plantillas.md#10-buscar-un-elemento-que-cumple-una-condicion)), cuando un elemento
depende de los anteriores ([Patrón 15](patrones.md#15-plegado-con-foldl)), o cuando el resultado no tiene un
elemento por cada elemento de la entrada ([sección 18.4](capitulo-18-orden-superior/index.md#184-include3-exclude3-partition4-convlist3)).

Capítulo 18, [sección 18.2](capitulo-18-orden-superior/index.md#182-maplist25).

## 15 — Plegado con `foldl`

**Problema.** Es necesario construir un valor a partir de todos los
elementos de una lista, en un solo recorrido: una suma, un máximo, varios
valores a la vez.

**Versión ingenua.** Un predicado auxiliar con acumulador explícito
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

**Problema.** Obtener todas las consecuencias de un conjunto de hechos y
reglas, y conservarlas para consultarlas después.

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

**Problema.** Reconocer una lista de elementos separados por comas, espacios
u otro separador, y obtener la lista de los elementos.

**Versión ingenua.** Una recursión propia para cada lista, con los
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

**Cuándo no usarlo.** Cuando el espacio de estados es demasiado grande
para recorrerlo y hace falta una heurística que guíe la búsqueda, como en
el [capítulo 40](capitulo-40-busqueda-y-planificacion/index.md); o
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

Capítulo 24, [sección 24.9](capitulo-24-modulos-y-organizacion/index.md#249-el-proyecto-cinco-modulos).

## 30 — Capturar lo justo y relanzar

**Problema.** Un error esperable —un dato que falta, una conversión que
no se puede hacer— tiene una respuesta prevista, y los demás errores no.

**Versión ingenua.** `catch(Objetivo, _, Recuperacion)`: captura todo,
incluidos los errores de programación, y los convierte en la misma
respuesta; solo la interrupción con Ctrl-C (`'$aborted'`) se relanza
después de ejecutar la recuperación.

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
predefinido que reciba el valor produzca un error que habla de
`is/2` o de `atom_length/2`.

**Patrón.** Al principio de cada predicado público, `must_be/2` para cada
argumento de entrada, según el encabezado; `domain_error/2` o
`existence_error/2` para lo que el tipo no alcanza a decir. Los predicados
internos no se validan: confían en el que los llama.

**Cuándo no usarlo.** En los predicados que funcionan en varios modos: una
validación de `+` rompe el modo `-`. Y en las relaciones puras, donde un
tipo incorrecto es un caso en que la relación no se cumple.

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
otro sin examinarlos, como un servicio que reenvía un JSON: convertirlos no
agrega nada.

Capítulo 27, [sección 27.7](capitulo-27-archivos-streams-y-formatos/index.md#277-json).

## 38 — Programa de línea de comandos

**Problema.** Un programa de Prolog tiene que usarse desde la terminal o
desde un script: con argumentos, con mensajes claros y con un código de
salida que diga si terminó bien.

**Versión ingenua.** Leer `current_prolog_flag(argv, …)` directamente en
cada predicado que necesita un argumento, llamar a `halt/1` desde donde se
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

**Versión ingenua.** Un manejador largo, que valida los datos uno por uno,
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
los códigos y el JSON reales, sin depender de un servidor arrancado por
separado ni de un puerto que puede estar ocupado.

**Versión ingenua.** Probar solo los predicados del núcleo, o arrancar el
servidor por separado en el puerto 8080 antes de ejecutar las pruebas.

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

**Versión ingenua.** Hacer ese trabajo en cada llamada; o escribir de
manera explícita la forma expandida en todos los lugares donde se usa.

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

**Versión ingenua.** Interpretar siempre; o escribir aparte un compilador
propio, que hay que mantener de acuerdo con el intérprete.

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

## 57 — Extensión por cláusulas multifile

**Problema.** Un programa está hecho de módulos que otros archivos
cargan, y es necesario agregarle casos —una sala, un sinónimo, un
logro, un personaje— sin modificar el archivo que define el
predicado y sin copiarlo.

**Versión ingenua.** Editar `mundo.pl` cada vez que el mundo crece,
con lo que cada variante del juego es una copia del archivo. O
escribir en otro archivo `mundo:sala(jardin, "…")` sin más: si
`sala/2` no es `multifile`, SWI-Prolog avisa `Redefined static
procedure mundo:sala/2`, y la consulta `mundo:sala(S, _)` responde
solo `jardin`; las cinco salas del observatorio desaparecen.

**Patrón.** El módulo declara `multifile`, en su propio archivo, los
predicados que deja abiertos: `mundo.pl` los nueve predicados de
datos, `lenguaje.pl` `forma/2`, `puntaje.pl` `logro/2` y
`personajes.pl` `ruta/2` y `bloquea/3`. Otro archivo carga el módulo
y escribe sus cláusulas con el nombre del módulo delante, como la
solución del ejercicio 2, que agrega el jardín: las salas pasan a ser
seis, y `conecta/3`, `objeto/1` y la gramática las usan sin cambio
alguno. En el
[capítulo 45](capitulo-45-proyecto-compilador/index.md), los
predicados abiertos son las etapas de un compilador —la gramática, el
intérprete, el generador de código y el paso de la máquina—, y
`leer.pl` agrega una sentencia con una cláusula en cada etapa. El
[Patrón 79](patrones.md#79-clausulas-para-un-modulo-cargado)
resuelve el mismo problema cuando el programa cargado no declaró nada:
un archivo puente declara `multifile` antes de cargarlo; aquí el
módulo se escribe desde el principio para ser extendido. Y el
[Patrón 46](patrones.md#46-extender-el-interprete-no-el-programa)
cambia lo que el intérprete calcula, con un argumento más en todas sus
cláusulas, algo que agregar cláusulas no consigue.

**Cuándo no usarlo.** Cuando la cláusula nueva tiene que ir antes que
las originales: las de otro archivo quedan después, y una cláusula
general o un corte del módulo deciden antes de alcanzarlas. Cuando dos
extensiones pueden unificar la misma cabeza: las respuestas de una se
mezclan con las de la otra. Y cuando lo que cambia es la conducta de
una consulta y no el contenido del programa: un argumento, como en el
[Patrón 60](patrones.md#60-interprete-con-conducta-como-parametro),
es más local que cláusulas que valen para todos los que usan el
módulo.

Capítulo 44, [sección 44.2](capitulo-44-proyecto-aventura-de-texto/index.md#442-version-1-el-mundo-como-hechos).

## 58 — Impedimento y efecto

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

## 59 — Etiquetas como variables lógicas

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

## 60 — Intérprete con conducta como parámetro

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

## 61 — Compilar reglas desde una notación declarativa

**Problema.** Un dominio tiene su propia notación para las reglas,
como la de Koskenniemi para la ortografía, y el programa que las
aplica necesita otra representación, como las listas de patrones
prohibidos que la versión 4 convierte en autómatas. La traducción de
una a otra es mecánica, pero larga y fácil de equivocar.

**Versión ingenua.** Hacer la traducción explícita de cada regla, como
la versión 3 escribe `regla/2` con `solo_ante_frontal/2` y
`no_ante_frontal/2`: quien agrega una regla tiene que deducir qué
sucesiones de pares quedan prohibidas, y la regla tal como se enuncia
no aparece en ningún lugar del programa.

**Patrón.** Escribir las reglas en la notación del dominio, como
hechos (`regla_dos_niveles/5`), y un compilador que las traduce a la
representación que el resto del programa ya consume (`compilar/5`,
con `restriccion/4` para `=>` y `coercion/4` para `<=`). Las reglas
compiladas se agregan como cláusulas de `regla/2`, y la versión 4 las
aplica sin cambios. Una regla escrita en las dos formas, `z_k` y `z`,
prueba el compilador: las pruebas verifican que da exactamente los
mismos patrones. Cuándo se compila es una decisión aparte: `kimmo.pl`
compila en cada llamada a `regla/2`, 4 263 veces al generar
«imposible», que cuesta 2 535 280 inferencias; con las reglas
compiladas al cargar, con `term_expansion/2` como en el
[Patrón 49](patrones.md#49-expandir-al-cargar), la misma
generación cuesta 1 006 077. `kimmo_contado.pl` mide la primera
forma y `kimmo_al_cargar.pl` la segunda, que carga `kimmo.pl` sin
la cláusula de `regla/2` que compila en cada llamada: esa cláusula
se probaría, sin éxito, también en las llamadas a las demás reglas.
Las pruebas `kimmo_contado:compilaciones`, `kimmo_contado:costo` y
`kimmo_al_cargar:costo` verifican las compilaciones con su valor
exacto y las inferencias dentro de un 10 %. Aquel patrón describe el
momento de la traducción; este, la separación entre la notación en
que se escriben las reglas y la forma en que se ejecutan.

**Cuándo no usarlo.** Cuando las reglas son pocas y su forma
ejecutable se lee tan bien como la notación: el compilador es un
programa más, con sus propias pruebas. Cuando solo una parte de las
reglas pasa a la notación, como en `kimmo.pl`, donde las nueve reglas
de la versión 3 siguen escritas como patrones: el programa tiene
entonces dos formas de escribir una regla. Y la compilación al cargar
no sirve cuando las reglas se agregan durante la ejecución: una regla
agregada después no se compila.

Capítulo 53, página [«Notación de dos niveles y derivación»](capitulo-53-proyecto-morfologia-castellano/derivacion.md), apartado [«La notación de dos niveles»](capitulo-53-proyecto-morfologia-castellano/derivacion.md#la-notacion-de-dos-niveles).

## 62 — Información de contexto como parámetro

**Problema.** La salida de una relación depende de algo que la
entrada no dice: el inglés *you* no indica si se trata al
destinatario de tú o de usted, y el castellano tiene que elegir. La
relación da varias respuestas correctas, y solo el contexto decide
cuál corresponde.

**Versión ingenua.** Dejar que el traductor dé todas las respuestas,
como `traducciones/2`, que para «You read a book.» da tres, y que
quien lo usa elija. O guardar el trato en un hecho dinámico, o en una
opción global, que la gramática consulta: la traducción depende
entonces de un estado que no aparece en la consulta, dos
traducciones con tratos distintos no pueden convivir, y cada prueba
tiene que fijarlo antes y restablecerlo después.

**Patrón.** El dato del contexto es un argumento más del predicado de
entrada, `traducir_con_trato/3`, que lo pasa a un solo predicado,
`trato/2`. Ese predicado examina el árbol castellano después de la
transferencia y descarta los sujetos que no corresponden al trato:
con `usted`, «You read a book.» da una sola traducción, y con `tu`,
las dos que tutean. Las oraciones cuyo sujeto no fija el trato
admiten los dos, y las gramáticas y la transferencia no cambian. El
parámetro no cambia cómo se calcula, como la conducta del
[Patrón 60](patrones.md#60-interprete-con-conducta-como-parametro)
o el criterio del
[Patrón 64](patrones.md#64-superioridad-como-parametro), ni sobre
qué datos se razona, como el mundo del
[Patrón 69](patrones.md#69-descripcion-del-mundo-como-parametro):
elige, entre las respuestas que la relación ya da, las que el
contexto admite.

**Cuándo no usarlo.** Cuando la entrada ya trae la información: del
castellano al inglés, «tú» y «usted» dan *you*, y el parámetro no
tendría nada que decidir. Cuando el contexto se manifiesta en un
lugar que el filtro no examina: `trato/2` mira solo el árbol
castellano, y el ejercicio 14 muestra que, con el sujeto omitido en
tercera persona, acepta «Come manzanas.» para *you* con el trato de
tú; el filtro tiene que examinar también el sujeto inglés. Y cuando
el contexto cambia muchas decisiones repartidas en la derivación:
filtrar el resultado genera primero todas las variantes, y conviene
pasar el dato a los no terminales que deciden.

Capítulo 54, página [«Interlingua lógica y trato»](capitulo-54-proyecto-traduccion-castellanoingles/interlingua.md), apartado [«Tú y usted»](capitulo-54-proyecto-traduccion-castellanoingles/interlingua.md#tu-y-usted).

## 63 — Estado como resultado, no como falla

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

## 64 — Superioridad como parámetro

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
[Patrón 60](patrones.md#60-interprete-con-conducta-como-parametro): allí el argumento es la conducta de cada pieza; aquí, la
política que resuelve los conflictos entre las piezas.

**Cuándo no usarlo.** Cuando las reglas no compiten nunca, o cuando un
solo criterio vale para todo el sistema y no hace falta compararlo con
otros: una prioridad fija, como el orden de las reglas de un sistema de
producción, es más simple. Y cuando la superioridad depende de los
datos, no del razonamiento: entonces es parte de la base, con hechos
`superior/2`, y el parámetro solo dice si se los usa.

Capítulo 65, [sección 65.3](capitulo-65-proyecto-razonamiento-rebatible/index.md#653-version-2-la-regla-mas-especifica).

## 65 — Una tabla de valores como conjunto de nodos compartidos

**Problema.** Un término grande, como un árbol de decisión, repite
muchas veces los mismos subtérminos, y cada repetición ocupa memoria
aunque describa lo mismo que las demás.

**Versión ingenua.** Guardar el árbol tal como lo construye la
versión 4, con una copia de cada subárbol repetido: el árbol `orden`
tiene 331 nodos. O detectar las repeticiones comparando cada subárbol
con los ya vistos, guardados en una lista, de modo que cada
comparación recorre subárboles enteros.

**Patrón.** Recorrer el término desde las hojas y dar a cada nodo
distinto un número, con una tabla que lleva cada nodo a su número.
Antes de crear un nodo, sus hijos se reemplazan por sus números y el
nodo así reducido se busca en la tabla con `get_assoc/3`: si está, se
usa su número; si no, recibe el siguiente y se agrega con
`put_assoc/4` (`numerar/4`). Como los hijos ya son números, cada
clave tiene tamaño fijo, `pregunta(P, IdSi, IdNo)` u `hoja(H)`, y dos
subárboles iguales dan la misma clave sin compararse enteros. La
tabla, al terminar, es el conjunto de los nodos distintos:
`reticulado/3` guarda el árbol `orden` en 26 nodos, 19 preguntas y 7
hojas, y los de 357 y 419 nodos de las otras dos estrategias en 48 y
46. Se parece al
[Patrón 70](patrones.md#70-resultado-recordado-sin-copiar) del
[capítulo 71](capitulo-71-proyecto-grafos-o/index.md#717-version-5-subproblemas-compartidos),
que también lleva un assoc en el estado y comparte los subárboles
repetidos, pero lo hace durante la búsqueda, para no resolver dos
veces el mismo subproblema; aquí el término ya está construido, y la
tabla, con los nodos como claves
([Patrón 24](patrones.md#24-tabla-de-busqueda-con-assoc)), lo
comprime después.

**Cuándo no usarlo.** Cuando los subtérminos casi no se repiten: la
tabla agrega una búsqueda por nodo y no ahorra nada. Cuando el
resultado se modifica después: un nodo compartido por varios caminos
no se puede cambiar para uno solo de ellos, que es la dificultad de
modificar que señala Rowe. Cuando los nodos contienen variables: dos
subtérminos que solo difieren en el nombre de sus variables dan
claves distintas, y una ligadura posterior cambia una clave ya
guardada. Y cuando lo que importa es la velocidad de la consulta: el
reticulado hace las mismas preguntas que el árbol, y
`consultar_reticulado/4` busca cada nodo con `memberchk/2` en la
lista, en lugar de bajar directamente a un hijo.

Capítulo 66, [sección 66.11](capitulo-66-proyecto-evidencia-arboles-decision/ampliaciones.md#6611-del-arbol-al-reticulado).

## 66 — Especializar podando por el ejemplo

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

## 67 — Bordes en lugar del conjunto

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

## 68 — Historia en el estado del ciclo

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

## 69 — Descripción del mundo como parámetro

**Problema.** Un planificador tiene que servir para más de un mundo
—los cubos, el robot de STRIPS, el mundo con pinza del
[capítulo 40](capitulo-40-busqueda-y-planificacion/index.md)—, y algunos de esos mundos ya están descritos
en otro formato.

**Versión ingenua.** Escribir las acciones del mundo dentro del
planificador, como cláusulas de la regresión, o copiar el planificador
para cada mundo; y, para un mundo que ya existe, reescribir su
descripción, cláusula por cláusula, en el formato nuevo, con dos copias que hay que
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
del [Patrón 60](patrones.md#60-interprete-con-conducta-como-parametro),
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

## 70 — Resultado recordado, sin copiar

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

## 71 — Resultado con garantía

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

## 72 — Verificar una propiedad en todo el espacio de estados de un caso chico

**Problema.** Una propiedad debe valer en todos los estados de un
espacio de búsqueda, o en todas sus transiciones, como la
consistencia de una heurística, y no hay una demostración general,
o la que hay conviene confirmarla con el programa.

**Versión ingenua.** Comprobar la propiedad en algunos estados
elegidos uno por uno, o juzgar la heurística por el resultado de la
búsqueda. Ninguna de las dos cosas detecta el defecto de
`salteada/3`: A\* con ella da en `coffman` la duración óptima, 24,
igual que con `camino/3`, y solo los 52 estados expandidos, contra
26, reflejan las 1 017 transiciones que violan la condición.

**Patrón.** Elegir casos chicos, como los proyectos de ejemplo, y
generar su espacio de estados completo desde el estado inicial, cada
estado una sola vez, con un conjunto de visitados (`alcanzables/2`,
con `library(nb_set)`). Escribir un generador de contraejemplos, que
recorre los estados y sus sucesores y tiene éxito con cada
transición que viola la propiedad (`arista_inconsistente/5`), y
definir la propiedad como su negación (`consistente/2`). Es el
[Patrón 13](patrones.md#13-comprobar-para-todos) aplicado a un
espacio que el programa genera, en la forma que recomienda su
«Cuándo no usarlo»: el generador nombra la transición que falla, y
una prueba de `consistencia.plt` la muestra. El recorrido cubre
1 017 estados en `casa` y 22 685 en `coffman`, y verificar
`combinada/3` en `coffman` cuesta unos 8,5 millones de inferencias
(prueba `consistencia:coffman_combinada`, dentro de un 10 %).
Son las pruebas de una propiedad sobre muchos datos que el
[Patrón 33](patrones.md#33-una-prueba-por-modo-y-por-caso-limite)
deja fuera de sus casos.

**Cuándo no usarlo.** Cuando el espacio es infinito o demasiado
grande para recorrerlo: las siete tareas y los tres procesadores de
`coffman` ya dan 22 685 estados. Cuando se toma el
recorrido por una demostración: cubre los casos recorridos, no
todos, y `camino/3` queda verificada solo en los proyectos de
ejemplo. Y cuando hay un argumento general, como el de `reparto/3`:
el argumento es la garantía, y el recorrido solo lo confirma en los
casos chicos.

Capítulo 72, página [«Anomalías, consistencia y holguras»](capitulo-72-proyecto-planificacion-tareas/extensiones.md), apartado [«Heurísticas consistentes»](capitulo-72-proyecto-planificacion-tareas/extensiones.md#heuristicas-consistentes).

## 73 — Restricción redundante que cuenta

**Problema.** Un modelo de restricciones correcto no termina de probar
que un problema no tiene solución, aunque la causa es una cuenta
simple: hay más pedidos de un recurso escaso que lugares de ese
recurso.

**Versión ingenua.** Confiar en las restricciones que definen el
problema, como el par momento-aula distinto para todas las clases, y
dejar que la búsqueda descubra la falta de lugares. En
`facultad(15)`, 33 clases necesitan una de las dos aulas grandes, que
en quince momentos ofrecen treinta lugares; la poda hacia adelante de
la versión 3 no termina en un minuto, y el modelo simple tampoco: cada
rama elige aulas y momentos hasta tropezar con la falta de lugares,
y las combinaciones que lo hacen son muchísimas.

**Patrón.** Agregar restricciones que **cuentan** el recurso escaso
sin elegir cuál de sus unidades se usa: para cada capacidad de aula,
`global_cardinality/2` limita en cada momento las clases de cupo mayor
a la cantidad de aulas mayores. No excluyen ninguna solución, porque
las implica el modelo, pero se propagan sobre las variables de momento
solas, antes de etiquetar. `conteo/2` las agrega, y con ellas
`facultad(15)` y `facultad(18)` se prueban imposibles con 2,9 y 4,4
millones de inferencias, sin buscar.

**Cuándo no usarlo.** Cuando el problema tiene solución y holgura: las
restricciones agregadas se propagan en cada paso, y en las ofertas
`facultad(6)` a `facultad(14)` el modelo con conteo cuesta entre dos y
tres veces más que el simple. Cuando la cuenta no es redundante sino
nueva: una restricción que excluye soluciones cambia el problema y
debe estar en el modelo, no presentarse como ayuda. Y cuando la
cantidad de cuentas crece con el producto de los recursos, como una
por cada par de aula y docente: su construcción puede costar más que
la búsqueda que ahorra.

Capítulo 73, [sección 73.6](capitulo-73-proyecto-horarios-inscripciones/index.md#736-version-4-el-modelo-de-restricciones).

## 74 — Transformación como par de términos

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

## 75 — Dos representaciones unidas por un hecho que comparte las variables

**Problema.** Un mismo objeto conviene representarlo de dos maneras,
porque cada una facilita operaciones distintas: el término de 54
casillas se gira con una unificación, y en la lista de 26 piezas se
busca dónde está una pieza. El programa necesita pasar de una a otra,
en los dos sentidos.

**Versión ingenua.** Un procedimiento que lee el término con `arg/3`
y arma la lista pieza por pieza, y otro, aparte, que arma el término
a partir de la lista: dos definiciones de la misma correspondencia,
que deben mantenerse de acuerdo. La primera no sirve en sentido
inverso, porque `arg/3` con el término libre lanza un error de
instanciación, y repite el trabajo en cada llamada: el cálculo que
hace `term_expansion/2` al cargar cuesta 475 inferencias para el
cubo resuelto.

**Patrón.** Escribir la correspondencia como un hecho de dos
argumentos con las mismas variables,
`piezas(c(V1, ..., V54), [p(V5), ..., p(V9, V10, V21)])`, generado
una sola vez al cargar
([Patrón 49](patrones.md#49-expandir-al-cargar)). Convertir es
una unificación: con el cubo instanciado, `piezas/2` da la lista, y
con la lista da el cubo. Es el recurso del
[Patrón 74](patrones.md#74-transformacion-como-par-de-terminos)
con otra lectura: allí los dos términos son el cubo antes y después
de un giro; aquí son el mismo cubo en dos representaciones. Como en
el [Patrón 20](patrones.md#20-una-gramatica-para-analizar-y-generar),
una sola definición sirve en los dos sentidos, y una prueba de ida y
vuelta, la que arma el cubo a partir de su lista, la verifica.

**Cuándo no usarlo.** Cuando la segunda representación no reparte
exactamente las partes de la primera: si una casilla no está en
ninguna pieza, el cubo armado desde la lista la deja libre, y si está
en dos, la conversión impone que sean iguales; por eso la otra prueba
verifica que cada casilla está en exactamente una pieza. Cuando la
correspondencia depende de los valores y no solo de las posiciones:
saber dónde está la pieza `DFR` exige comparar colores, y `donde/4`
lo hace con una búsqueda, `buscar/5`, sobre las dos listas que da el
hecho. Y cuando la segunda representación no tiene forma fija, como
una lista de largo variable u ordenada por valor: un hecho solo
relaciona términos de forma fija.

Capítulo 74, página [«Piezas y una ayuda para la búsqueda»](capitulo-74-proyecto-cubo-rubik/piezas.md), apartado [«El cubo como lista de piezas»](capitulo-74-proyecto-cubo-rubik/piezas.md#el-cubo-como-lista-de-piezas).

## 76 — Forma canónica de la clase

**Problema.** Un problema tiene simetrías: transformaciones que llevan
un objeto a otro equivalente, con las mismas soluciones o la misma
medida, como las escrituras de un lazo, los ocho tableros que se
obtienen girando o reflejando uno, o los desarreglos conjugados de
Enigma 1225. Una búsqueda que no las conoce resuelve muchas veces el
mismo caso con otro nombre.

**Versión ingenua.** Resolver cada objeto por separado y, si hace
falta, quitar los duplicados al final con `sort/2`. Los ocho tableros
equivalentes a `csenki1` cuestan así 208 592 inferencias, y buscar
los lazos de `csenki2` desde todas las semillas, 265 millones, para
descartar después 290 de las 300 escrituras.

**Patrón.** Definir una **forma canónica**: una función que elige un
representante único de cada clase, de modo que dos objetos son
equivalentes si y solo si tienen la misma forma canónica, como
`canonica/2` para los lazos, `forma/3` para los tableros y `tipo/2`
para las permutaciones. Después, usarla tan temprano como se pueda:
como clave de un registro de lo ya visto o de una tabla, que resuelve
cada clase una sola vez (`resolver/2`, 23 611 inferencias para los
mismos ocho tableros), o, mejor, para generar solo los
representantes, como la semilla fija o las particiones de la versión
8. Si el resultado se pide para un objeto que no es el representante,
se resuelve el representante y se transforma la respuesta con la
simetría inversa.

**Cuándo no usarlo.** Cuando calcular la forma canónica cuesta más que
resolver el caso, o cuando las clases son casi todas de un solo
elemento: la forma se paga para cada objeto y no ahorra nada. Cuando
la transformación no conserva lo que se busca, por ejemplo si el
tablero tuviera una casilla de partida fija, que un giro movería. Y
filtrar al final no es una aplicación del patrón: fijar el sentido de
un lazo después de buscarlo, en la
[sección 75.4](capitulo-75-proyecto-rompecabezas-simetrias/index.md#754-version-3-cada-lazo-una-sola-vez), quita las
respuestas repetidas pero no el trabajo.

Capítulo 75, [sección 75.6](capitulo-75-proyecto-rompecabezas-simetrias/index.md#756-version-5-las-simetrias-del-tablero).

## 77 — Problema de otro módulo

**Problema.** Una búsqueda escrita como archivo sin módulo llama a
`inicial/2`, `meta/2`, `sucesor/5` y `heuristica/3` con el problema
como primer argumento, y se quiere usarla, sin modificarla, para varios
problemas nuevos, cada uno con sus propios predicados auxiliares.

**Versión ingenua.** Cargar la búsqueda en un módulo y agregarle, por
`multifile`, las cláusulas de cada problema, como hicieron los
capítulos [71](capitulo-71-proyecto-grafos-o/index.md) y
[74](capitulo-74-proyecto-cubo-rubik/index.md). Con un problema
funciona; con los cinco de este capítulo, todas sus cláusulas y sus
auxiliares —`vecina/4`, `costo_paso/3`, `recta/3`, `salto/4`…— viven
en el mismo módulo, donde dos problemas no pueden tener un auxiliar
con el mismo nombre, y el puente crece con cada problema nuevo.

**Patrón.** El puente agrega a cada predicado de la interfaz una sola
cláusula para los problemas escritos `Modulo:Problema`, que pasa la
llamada a ese módulo: `inicial(M:P, E) :- M:inicial(P, E).` Cada
problema define la interfaz en su propio módulo, con sus auxiliares
privados, y se resuelve escribiendo `buscar(E, robot:ruta(…), …)`. El
puente de este capítulo tiene cuatro cláusulas para `puzzle8.pl` y
cuatro para `frontera.pl`, y no cambió al agregar el robot, los giros,
el laberinto, el caballo y los problemas de las soluciones. Se parece
al [Patrón 69](patrones.md#69-descripcion-del-mundo-como-parametro),
en el que el planificador recibe el nombre del módulo del mundo como
argumento propio y lo usa en cada llamada; aquí el programa que busca
no sabe nada de módulos: el módulo viaja dentro del término del
problema, y la delegación la agrega el puente, sin tocar el código
cargado.

**Cuándo no usarlo.** Cuando el programa cargado ya es un módulo que
recibe el módulo del problema como argumento, como el planificador del
[Patrón 69](patrones.md#69-descripcion-del-mundo-como-parametro): basta con pasárselo. Cuando hay un solo problema y no se
espera otro: las cláusulas `multifile` directas son más simples. Y
cuando el programa cargado inspecciona el término del problema más
allá de pasarlo a la interfaz: una cláusula suya que unifica con
`jarras(_, _, _)` no reconoce `m:jarras(…)`.

Capítulo 76, [sección 76.1](capitulo-76-proyecto-robots-laberintos-caballo/index.md#761-las-busquedas-del-capitulo-40-para-otros-modulos).

## 78 — Heurística entera

**Problema.** Los costos del problema son enteros —saltos, pasos—,
pero la heurística admisible natural es un número de punto flotante,
como una distancia en línea recta dividida por √5.

**Versión ingenua.** Usar la heurística tal como sale de la fórmula.
Cada nodo tiene un f distinto, IDA\* sube la cota de a un valor
irracional por vez y repite la búsqueda en cada iteración: de a8 a h1
con `combinada`, 657 nodos expandidos donde alcanzan 35.

**Patrón.** Redondear la heurística hacia arriba, `ceiling/1`. Si h no
supera el costo real c, que es entero, el menor entero mayor o igual
que h tampoco lo supera: la heurística sigue siendo admisible, y es
mejor informada. Las cotas de IDA\* pasan a ser enteras, una por
costo posible, y A\* desempata menos: en el tablero de 50 × 50, de una
esquina a la otra, expande 506 nodos en lugar de 840. En
`estimar/4` es una cláusula, `entera(H)`, que envuelve cualquier otra
heurística.

**Cuándo no usarlo.** Cuando los costos no son enteros, como las
longitudes de una red de caminos medidas en línea recta: el entero
siguiente a h puede pasar el costo real, y la heurística deja de ser
admisible. Cuando la heurística ya da enteros, como `manhattan` en el
plano del robot: no cambia nada. Y cuando todos los costos son
múltiplos de un mismo número, como los 10 y 11 de los giros: el
redondeo a enteros sigue siendo admisible, pero las cotas de IDA\*
siguen siendo muchas, porque los valores de f se distinguen igual.

Capítulo 76, [sección 76.7](capitulo-76-proyecto-robots-laberintos-caballo/index.md#767-version-6-el-caballo-de-una-casilla-a-otra).

## 79 — Cláusulas para un módulo cargado

**Problema.** Un programa de otro capítulo, o de otra persona, llama a
predicados que describen un caso, como la búsqueda del
[capítulo 41](capitulo-41-juegos/index.md) llama a `jugada/4` o a
`fin/3`, y es necesario agregarle casos nuevos sin copiarlo ni
modificarlo.

**Versión ingenua.** Copiar el archivo en cada programa nuevo, como
hacen los ejemplos del [capítulo 41](capitulo-41-juegos/index.md) para correr en SWISH: las 265
líneas de `profundizacion.pl` en `nim.pl` y en `kalah.pl`, con pruebas
que verifiquen que las copias siguen iguales al original. O cargarlo y
escribir las cláusulas nuevas con el módulo delante sin más: SWI-Prolog
avisa `Redefined static procedure capitulo41:inicial/2`, borra las
cláusulas del ta-te-ti y deja solo las del juego nuevo.

**Patrón.** Un archivo puente define el módulo, declara `multifile`
los predicados que el programa cargado deja abiertos, y recién
después lo carga con `load_files/2` dentro de ese módulo. Cada archivo
que agrega un caso escribe sus cláusulas con el nombre del módulo
delante, `capitulo41:jugada(nim(_), …)`, y las distingue de las otras
por el primer argumento o por la forma de la posición. El programa
cargado no cambia, y todos los casos conviven.

**Cuándo no usarlo.** Cuando el programa cargado ya ofrece un
argumento para pasar la conducta, como las estrategias de `partida/5`:
pasarla es más simple y más local que agregar cláusulas a un módulo
ajeno. Cuando los casos nuevos se superponen con los existentes, es
decir, cuando dos juegos pueden unificar la misma cabeza: las
cláusulas de uno dan respuestas al otro. Y cuando el programa cargado
corta en las cláusulas que se extienden, porque el orden de los
archivos decide entonces el resultado.

Capítulo 78, [sección 78.2](capitulo-78-proyecto-kalah-mastermind-nim/index.md#782-el-programa-terminado).

## 80 — Estrategia como argumento

**Problema.** Un mismo juego se juega con varias maneras de elegir la
jugada (la búsqueda tabulada, la suma de Nim, la alfa-beta a cierta
profundidad, una persona), y es necesario enfrentarlas entre sí sin
escribir una partida para cada par.

**Versión ingenua.** Una partida por combinación, o una partida con un
`(   Max == suma -> … ;   Max == tabulada -> … )` que enumera las
estrategias: cada estrategia nueva cambia la partida, y el torneo de
la [sección 78.10](capitulo-78-proyecto-kalah-mastermind-nim/index.md#7810-kalah-version-2-el-jugador-con-alfa-beta),
con cinco profundidades, necesitaría veinte combinaciones.

**Patrón.** Una estrategia es un predicado que recibe el juego y la
posición y devuelve la jugada; se pasa sin sus tres últimos
argumentos, como `nim:tabulada` o `profundidad(4)`, y la partida la
llama con `call/4`. La partida no conoce ninguna estrategia: solo
alterna los turnos, comprueba la jugada con `jugada/4` y termina con
`fin/3`. Es una aplicación del
[patrón 60](patrones.md#60-interprete-con-conducta-como-parametro),
con una diferencia: en el patrón 60 la conducta que se pasa da el
significado de toda la estructura que el intérprete recorre; aquí hay
dos conductas, una por jugador, que se alternan, y cada una decide
una sola jugada por llamada.

**Cuándo no usarlo.** Cuando la estrategia necesita estado propio
entre jugadas, como una tabla que crece o un reloj: la llamada recibe
solo el juego y la posición, y ese estado debe ir en la posición o
fuera de la partida. Y cuando hay una sola manera de elegir la jugada:
el argumento agrega una indirección sin dar nada a cambio.

Capítulo 78, [sección 78.4](capitulo-78-proyecto-kalah-mastermind-nim/index.md#784-nim-version-2-las-posiciones-repetidas-tabuladas).

## 81 — Conocimiento como restricciones de la búsqueda

**Problema.** Un juego o un problema de búsqueda tiene soluciones
demasiado profundas para una búsqueda completa, y quien conoce el
dominio sabe qué metas intermedias perseguir y qué jugadas vale la
pena considerar.

**Versión ingenua.** Buscar sin conocimiento, con todas las jugadas de
los dos bandos hasta la meta final: el mate en 5 jugadas cuesta 106
millones de inferencias, y el más lejano del final está a 16.

**Patrón.** Escribir el conocimiento como datos: metas intermedias,
una condición que debe mantenerse y restricciones sobre las jugadas de
cada bando, ordenadas por preferencia en una tabla. Un intérprete
independiente del dominio busca, con esas restricciones, un árbol
forzante para el primer consejo satisfacible; la búsqueda queda en
pocas jugadas, y una partida entera de 12 jugadas cuesta 130 409
inferencias. Las condiciones elementales y las restricciones
elementales las define el dominio, y el intérprete solo las llama.

**Cuándo no usarlo.** Cuando la búsqueda completa alcanza, o cuando
nadie conoce un plan del dominio: una tabla de consejos no es óptima, y
su corrección hay que verificarla aparte
([Patrón 82](patrones.md#82-verificar-la-estrategia-hacia-atras)).

Capítulo 79, [sección 79.4](capitulo-79-proyecto-lenguaje-consejos-ajedrez/index.md#794-version-4-la-tabla-de-rey-y-torre-contra-rey).

## 82 — Verificar la estrategia hacia atrás

**Problema.** Hay que saber si una estrategia gana desde todas las
posiciones contra cualquier defensa, y las partidas de prueba solo
examinan las respuestas que alguna defensa elige.

**Versión ingenua.** Jugar una partida por posición con unas pocas
defensas: en las 27 352 posiciones normales, dos defensas encuentran
10 ahogados, y las otras 38 posiciones en que la tabla ahoga quedan
ocultas.

**Patrón.** Construir hacia atrás, desde las posiciones terminales
ganadas, el conjunto de las posiciones desde las que la estrategia
gana contra todas las respuestas: una posición entra cuando todas sus
salidas son victorias o posiciones que ya entraron. Si la estrategia
tiene memoria, el paso es todo lo que juega sin volver a decidir, como
un árbol forzante entero. Las posiciones que nunca entran son sus
errores, y las pasadas dan también la partida más larga. Sobre las
175 168 posiciones del final, `verificar/2` tarda dos minutos y medio
y encuentra las 48.

**Cuándo no usarlo.** Cuando el espacio de posiciones no cabe en
memoria o no se puede enumerar: entonces solo queda probar la
estrategia con partidas o demostrar su corrección.

Capítulo 79, [sección 79.7](capitulo-79-proyecto-lenguaje-consejos-ajedrez/index.md#797-version-7-verificar-la-tabla).

## 83 — Restricción como tabla

**Problema.** Varias variables de dominio finito deben tomar, juntas,
una de unas pocas combinaciones permitidas, que no se describen con
una fórmula sino enumerándolas, como las uniones del catálogo de
Huffman y Clowes.

**Versión ingenua.** Dar un valor a cada variable por separado y
comprobar después que cada grupo forma una combinación permitida: es
generar y probar, que en el cubo cuesta 3 842 924 inferencias y en el
bloque en forma de ele, de quince líneas, no termina en minutos.

**Patrón.** Escribir la restricción como una tabla de filas, hechos
como `union_posible/2`, y satisfacerla eligiendo una fila y
unificándola con las variables del grupo, como `elegir/1`. Las
variables compartidas entre grupos propagan cada elección por
unificación, y una contradicción falla en cuanto aparece: el cubo
cuesta 2 089 inferencias. Con `library(clpfd)`, la misma tabla se
pasa a `tuples_in/2`, que además poda los dominios antes de elegir.

**Cuándo no usarlo.** Cuando las combinaciones permitidas son
demasiadas para enumerarlas, o siguen una regla aritmética: entonces
la restricción se escribe como fórmula, con `#=` y las demás
restricciones del [capítulo 23](capitulo-23-programacion-con-restricciones/index.md).
Y cuando el orden de las elecciones no sigue las variables compartidas:
la tabla sola no evita que la vuelta atrás repita trabajo ([Patrón 84](patrones.md#84-filtrar-antes-de-buscar)).

Capítulo 80, [sección 80.5](capitulo-80-proyecto-etiquetado-waltz/index.md#805-version-3-cada-union-es-una-restriccion).

## 84 — Filtrar antes de buscar

**Problema.** Un problema de restricciones entre grupos de variables
que comparten algunas de ellas tiene muchas combinaciones, y una
búsqueda con vuelta atrás descubre una contradicción lejos de la
elección que la causó.

**Versión ingenua.** Elegir una combinación por grupo, en algún orden,
y volver atrás cuando un grupo no tiene combinación posible: la
versión 3 cuesta 342 022 inferencias en la escalera de diez escalones
sin borde y 315 261 953 en la de veinte.

**Patrón.** Dar a cada grupo su dominio de combinaciones posibles y
quitar de cada uno las que ningún grupo vecino admite, con una cola de
los grupos cuyo dominio cambió, hasta que la cola se vacía
(`propagar/5`). Si queda ambigüedad, elegir en el grupo de dominio más
chico y volver a filtrar después de cada elección (`buscar/3`). La
escalera de veinte escalones cuesta 104 489 inferencias, y duplicar el
tamaño duplica el costo.

**Cuándo no usarlo.** Cuando el problema es chico y la unificación ya
poda bien: en el cubo, el filtrado cuesta 7 579 inferencias contra
2 181 de la versión 3. Y no tomar un filtrado sin dominios vacíos como
prueba de que hay solución: el poiuyt pasa el filtrado con 2 073 600
combinaciones y no tiene ninguna interpretación; la búsqueda sigue
siendo necesaria.

Capítulo 80, [sección 80.6](capitulo-80-proyecto-etiquetado-waltz/index.md#806-version-4-el-filtrado-de-waltz).

## 85 — Estado canónico en el sucesor

**Problema.** Un espacio de estados tiene simetrías, y una búsqueda
con registro de visitados expande por separado estados que son
imágenes uno de otro, como las posiciones del triángulo que un
espejo intercambia: el registro compara términos y no reconoce dos
posiciones simétricas como el mismo estado.

**Versión ingenua.** No tratar las simetrías, como el problema
`todas(Vacio)`, que en anchura con el agujero 1 vacío expande 3 012
posiciones; o cambiar la búsqueda, para que compare cada estado
nuevo con las imágenes de los visitados, y escribir así una
búsqueda propia para cada problema con simetrías.

**Patrón.** Dejar la búsqueda sin cambios y llevar la simetría al
problema: `inicial/2` y `sucesor/5` de `formas(Vacio)` devuelven la
forma canónica del estado, calculada por `forma/2`, y el registro
de visitados de `buscar/5` junta las posiciones simétricas sin
saber que existen: 1 541 formas en lugar de 3 012 posiciones. Un
paso entre formas no es un movimiento del tablero real, así que la
acción nombra la forma siguiente, y `en_el_tablero/3` reconstruye
después los saltos reales, uno por paso, desde la posición de
partida. Es la forma canónica del
[Patrón 76](patrones.md#76-forma-canonica-de-la-clase) puesta en
los estados del
[Patrón 25](patrones.md#25-busqueda-en-un-espacio-de-estados-con-visitados).

**Cuándo no usarlo.** Cuando el costo de un paso, la meta o la
heurística dependen de la posición real y no solo de su clase: la
búsqueda sobre formas ya no los ve. Cuando pocas imágenes de cada
estado están en el espacio que se recorre: `forma/2` calcula seis
imágenes por sucesor, y con el agujero 1 vacío el recorrido en
anchura se reduce a la mitad, no a un sexto. Y cuando no hay un modo barato de volver de
las clases a los movimientos: sin `en_el_tablero/3`, la solución
es una secuencia de formas que no se puede jugar.

Capítulo 81, [sección 81.4](capitulo-81-proyecto-coleccion-problemas/index.md#814-version-3-las-simetrias-en-el-registro-de-visitados).

## 86 — El estado como valor, la base de datos como capa

**Problema.** Un programa guarda su estado en la base de datos y lo
cambia con operaciones, como vender y comprar sellos del álbum; cada
operación decide a la vez qué estado resulta y qué hechos se quitan
o se agregan.

**Versión ingenua.** Operaciones que calculan y modifican la base en
el mismo paso, como `vender/1`, `vender_de/2` y `comprar/1` de la
versión 1, con `retract/1` y `assertz/1` en medio del cálculo. Sus
pruebas tienen que guardar el álbum antes y restaurarlo después.

**Patrón.** Escribir cada operación como una relación pura entre un
estado y el siguiente, con el estado como valor: `vender/3` y
`comprar/3` reciben un álbum, una lista de series, y dan otro. La
base de datos queda en una capa de un solo predicado, `operar/1`,
que lee el estado con `album_actual/1`, aplica la relación y lo
guarda con `guardar/1`. Las relaciones se prueban con álbumes
escritos en la prueba, y las pruebas de la capa comprueban solo que
da el mismo álbum que la relación. Es el
[Patrón 29](patrones.md#29-nucleo-puro-bordes-impuros) a la
escala de una operación, y `operar/1` es la interfaz única del
[Patrón 19](patrones.md#19-estado-detras-de-una-interfaz).

**Cuándo no usarlo.** Cuando el estado es grande y cada operación
cambia una parte pequeña: `guardar/1` reescribe todas las series
aunque la venta toque una sola, y una lista se recorre donde la base
de datos indexaría los hechos. Y cuando el estado no tiene que
persistir entre consultas: entonces no hace falta la capa, y el
valor pasa de una relación a otra en los argumentos.

Capítulo 81, página [«Una colección de estampillas»](capitulo-81-proyecto-coleccion-problemas/estampillas.md), apartado [«Versión 2: el álbum como valor»](capitulo-81-proyecto-coleccion-problemas/estampillas.md#version-2-el-album-como-valor).

## 87 — Valor propio o heredado sin corte rojo

**Problema.** Un predicado da los valores de un caso particular, si
los tiene, y si no los de uno más general, como `tiene_valor/3`, que
da los valores propios de una ranura o, a falta de ellos, los
heredados por `es_un`, `parte_de` o `intension`. El valor particular
reemplaza al general: así se escriben las excepciones.

**Versión ingenua.** La de Rowe: una cláusula para los valores
propios que termina en un corte, y después las cláusulas de la
herencia. El corte es rojo y pierde respuestas: una ranura con
varios valores propios da solo el primero, y escrito así,
`tiene_valor(sistema_electrico, tiene_parte, P)` da `bateria` y no
`arranque`. Con el valor ya instanciado y distinto del propio, el
corte no llega a ejecutarse, y la consulta acepta el heredado.

**Patrón.** Un si-entonces-sino cuya condición pregunta si hay algún
valor propio sin ligar cuál, `propio(O, R, _)`, y cuya rama entonces
vuelve a llamar a `propio(O, R, V)` para devolverlos todos; la rama
sino da los heredados. La condición se compromete con la clase de
respuesta, no con una respuesta. Es el condicional del
[Patrón 5](patrones.md#5-casos-con-condicional) con una condición
que no comparte variables con la salida.

**Cuándo no usarlo.** Cuando lo propio y lo heredado se acumulan en
lugar de reemplazarse, como las ranuras de `tiene_ranura/2`, que es
una disyunción. Cuando se quiere un solo valor, el del marco más
cercano: entonces la condición liga el valor y la rama lo devuelve,
como en `tiene_unidades/3`. Y cuando derivar un valor propio es
caro: la condición deriva el primero y la rama vuelve a derivarlo;
conviene reunir los propios una vez con `findall/3` y decidir por la
lista vacía.

Capítulo 81, página [«Reglas de tránsito y marcos»](capitulo-81-proyecto-coleccion-problemas/transito-y-marcos.md), apartado [«Marcos»](capitulo-81-proyecto-coleccion-problemas/transito-y-marcos.md#marcos).

## 88 — Calcular y después comparar

**Problema.** Un predicado obtiene su salida de un predicado de
biblioteca que, con esa salida ya ligada, no falla cuando el valor no
corresponde sino que da un error. El predicado propio hereda ese
comportamiento, y el modo `+` que su encabezado declara no se cumple.

**Versión ingenua.** Pasar el argumento de salida directamente a la
biblioteca, con `crypto_data_hash(Datos, Hex, [algorithm(sha256)])`
como cuerpo de `resumen/2`. Con `Hex` ligado a un resumen que no
corresponde, la consulta termina con
`domain_error(hex_encoding, Hex)` en lugar de responder `false.`

**Patrón.** Llamar a la biblioteca con una variable nueva y unificar
el resultado con la salida en la última meta: `Hex = H` en
`resumen/2` y `resumen_archivo/2`, `Mac = M` en `mac/3`. La
biblioteca trabaja siempre en el único modo que admite, y la
comparación queda a cargo de la unificación, que falla. Es el
movimiento del
[Patrón 3](patrones.md#3-salida-despues-del-compromiso) aplicado a
una llamada que da error en lugar de a un corte; la prueba
`resumen_instanciado_distinto`, con `[fail]`, es la que pide el
[Patrón 2](patrones.md#2-encabezado-que-se-cumple) para el modo
`resumen(+Datos, +Hex) is semidet`.

**Cuándo no usarlo.** Cuando la biblioteca ya es estable con la salida
ligada, como `atom_length/2`: la variable intermedia no agrega nada.
Y cuando el argumento ligado es una entrada que guía a la biblioteca:
`length(L, 2)` da una sola respuesta, pero `length(L, N0), N0 = 2`
enumera longitudes y, al pedir otra respuesta, no termina.

Capítulo 82, [sección 82.3](capitulo-82-proyecto-criptografia/index.md#823-version-1-resumenes-y-manifiestos).

## 89 — Comprobar antes de usar

**Problema.** Unos datos llegan de afuera con un código de
autenticación o una firma. Todo lo que el programa hace con ellos
antes de comprobarlos, interpretarlos, descifrarlos o actuar según lo
que dicen, lo hace con datos que cualquiera pudo fabricar o alterar.

**Versión ingenua.** Interpretar primero y comprobar después, o no
comprobar: `abrir_sin_mac/3`, de la
[versión 6](capitulo-82-proyecto-criptografia/canal.md#canal-version-6-un-secreto-acordado-y-un-canal-cifrado),
descifra sin mirar el código, y un cambio de un dígito hexadecimal en
el cifrado hace leer «Pagar 900 pesos a Ana» donde se envió «Pagar 100
pesos a Ana».

**Patrón.** La comprobación es la primera meta y decide si se ejecuta
el resto. `comprobar_entrega/4` pasa a `verificar_texto/3` el
manifiesto tal como se leyó del archivo, y solo si la firma vale lo
analiza con `texto_manifiesto/2` y compara el pack con `verificar/3`;
si no, responde `firma_invalida` sin abrir ningún archivo del pack.
`abrir/3`, en la versión 6, compara el código con `iguales/2` antes
de descifrar. Para que eso sea posible, el código se calcula sobre
los bytes que viajan, el texto del manifiesto o el cifrado, y no
sobre lo que resulta de interpretarlos. Complementa el
[Patrón 31](patrones.md#31-validar-al-entrar): un manifiesto bien
formado pero escrito por otro pasa cualquier validación de tipos, y
analizarlo ya es procesar datos no autenticados, de modo que la
autenticidad se comprueba antes que la forma.

**Cuándo no usarlo.** Cuando los datos no llevan código porque vienen
del mismo programa o de un canal en el que ya se confía: no hay nada
que comprobar. Cuando el mensaje es demasiado largo para retenerlo
entero antes de usarlo, como un flujo continuo, el código del mensaje
completo se conoce recién al final, y el formato tiene que autenticar
por bloques, cada uno con su código; el patrón se aplica entonces a
cada bloque. Y la separación mínima que ubica el código dentro de los
datos, como la de `atomic_list_concat/3` en `validar/4`, precede
necesariamente a la comprobación.

Capítulo 82, página [«Firmas»](capitulo-82-proyecto-criptografia/firmas.md), apartado [«Firmas, versión 5: la entrega firmada»](capitulo-82-proyecto-criptografia/firmas.md#firmas-version-5-la-entrega-firmada).

## 90 — El autómata como relación de paso

**Problema.** Un programa procesa una secuencia de líneas, y lo que
hace con cada una depende de las anteriores. Si el estado, la lectura
y la escritura quedan en el mismo predicado, el programa no se prueba
sin archivos, y su resultado depende de lo que dejó la ejecución
anterior.

**Versión ingenua.** El programa de Csenki: el estado es un hecho
dinámico `switch/1`, que se cambia con `retractall/1` y `assert/1`,
cada línea se lee con `get_char/1` del archivo de entrada actual y se
escribe en el de salida actual.

**Patrón.** El autómata es una relación pura
`paso(Estado, Entrada, Estado1, Salida)`, `det`, que da el estado
siguiente y lo que se escribe como una lista, vacía o con la línea, en
lugar de escribirlo: `paso/6`, y `paso/7` con el número de línea. Un
recorrido aparte lo aplica a la fuente de las líneas: `cribar/5` a una
lista, en las pruebas, y `cribar_stream/6`, en la
[sección 83.5](capitulo-83-proyecto-procesamiento-textos/index.md#835-el-filtro-version-3-un-programa-para-la-terminal),
a un stream, con el mismo `paso/7`. Cada transición se prueba con una
consulta. La [sección 46.2](capitulo-46-proyecto-metodos-numericos/index.md#462-la-ecuacion-como-termino-y-el-ciclo-de-iteracion)
separa el ciclo del paso al revés: `iterar/4` queda fijo y el paso
cambia con el método; aquí el paso queda fijo y el recorrido cambia
con la fuente. Del
[Patrón 63](patrones.md#63-estado-como-resultado-no-como-falla)
toma que el paso es `det` y devuelve el estado como resultado; agrega
que la salida también es un resultado, de modo que el paso no hace
entrada ni salida.

**Cuándo no usarlo.** Cuando lo que se hace con una línea no depende
de las anteriores: no hay estado, y basta con `include/3` o
`maplist/3` sobre las líneas. Y cuando la decisión sobre una línea
depende de las que siguen, como un bloque cuyo sentido se conoce al
cerrarlo: un paso que consume una sola entrada tendría que guardar
las líneas pendientes en el estado, y una gramática del
[capítulo 21](capitulo-21-gramaticas-dcg/index.md) sobre el texto
completo lo expresa de modo más directo.

Capítulo 83, [sección 83.3](capitulo-83-proyecto-procesamiento-textos/index.md#833-el-filtro-version-1-el-estado-como-argumento).

## 91 — Especificación como dato

**Problema.** Un programa recibe sus instrucciones en un archivo
escrito con la sintaxis de Prolog, como las curvas que tiene que
dibujar. Si los términos se ejecutan, el archivo puede hacer todo lo
que hace un programa, y un término equivocado produce un error que no
dice en qué línea está.

**Versión ingenua.** El programa de Csenki: cada línea se convierte en
término con `term_to_atom/2` y se ejecuta con `apply/2`. Con
`archivos/peligro.curvas`, ese diseño ejecuta la meta
`delete_file('examen.tex')` de la línea 3.

**Patrón.** Leer cada término con `read_term/3`, que lo entrega como
dato junto con la línea en que empieza; unificarlo con las formas que
el lenguaje acepta, aquí solo
`curva(Nombre, Curva, Desde, Hasta, N)`; y verificar cada campo con
una condición con nombre, como hace `especificacion/3` con
`verificar/2`. Una forma desconocida o una condición que no se cumple
lanzan `error(especificacion(Linea, Problema), _)`, y el programa
informa la línea y lo que falló. El término nunca se llama: los
extremos se evalúan con `is/2` solo si son cerrados, y `curva/1`
examina las cláusulas de `punto/3` con `clause/2`, sin ejecutarlas.
Es el [Patrón 31](patrones.md#31-validar-al-entrar) en el borde
del programa, con las condiciones del lenguaje de especificación en
lugar de los tipos de un argumento, y una forma del
[Patrón 37](patrones.md#37-convertir-en-el-borde) en la que el
formato ajeno ya son términos: la tentación es ejecutarlos en lugar
de convertirlos en partes limpias, `curva(Nombre, Puntos)` y
`comentario(Texto)`.

**Cuándo no usarlo.** Cuando el archivo es parte del programa, escrito
por quien lo escribe y cargado como código: verificarlo como dato
repite el trabajo del compilador. Cuando las especificaciones
necesitan reglas o variables compartidas, las formas aceptadas crecen
hasta ser un lenguaje con su propio intérprete. Y la verificación de
la forma no acota el costo de lo que se calcula después: un extremo
`2**(10**9)` es una expresión cerrada y válida, y el desborde de
punto flotante aparece en `muestra/5`, sin número de línea.

Capítulo 83, página [«Las curvas»](capitulo-83-proyecto-procesamiento-textos/curvas.md), apartado [«Las curvas, versión 3: un archivo de especificaciones»](capitulo-83-proyecto-procesamiento-textos/curvas.md#las-curvas-version-3-un-archivo-de-especificaciones).

## 92 — Límites como argumento

**Problema.** Una regla decide si el valor de una métrica es anómalo
comparándolo con un límite, y los límites tienen varios orígenes: se
fijan de manera explícita, se ajustan con días anteriores o con el mismo día
que se examina, o se aprenden de incidentes ya investigados. La
regla, y las que buscan la causa, son las mismas para todos.

**Versión ingenua.** Escribir el límite dentro de la regla, como
`Fallos > 10`, o un predicado de anomalías por cada origen de los
límites: cambiar de límite obliga a reescribir la regla, y comparar
dos orígenes sobre el mismo día obliga a mantener dos copias.

**Patrón.** Las reglas reciben las métricas y un argumento con los
límites, una lista de pares `Metrica-mayor(L)` o `Metrica-menor(L)`:
`anomalia/3` toma un par de la lista y `fuera/2` lo aplica. La lista
dice también qué métricas se examinan, y quien la produce queda
afuera de las reglas: `umbrales_fijos/1` aquí, y
`umbrales_de_referencia/2` y `umbrales_del_dia/3` en la
[sección 84.6](capitulo-84-proyecto-analisis-registros/index.md#846-version-4-umbrales-ajustados-a-partir-de-los-datos).
`anomalias/3` e `informe_anomalias/2` las usan sin cambios, y el
jueves se examina con los tres juegos de límites, una consulta cada
uno. Los pesos del perceptrón de la versión 5 no caben en la forma
`mayor(L)`, porque son una recta sobre dos métricas, pero siguen la
misma idea: `sospechosos/3` los recibe como argumento. Es pariente
del [Patrón 64](patrones.md#64-superioridad-como-parametro), en
el que una lista argumento da el criterio que resuelve los conflictos
entre reglas, y del
[Patrón 69](patrones.md#69-descripcion-del-mundo-como-parametro),
en el que el algoritmo es fijo y lo que varía son los datos sobre los
que razona: aquí lo que varía es la frontera entre lo normal y lo
anómalo.

**Cuándo no usarlo.** Cuando el límite es uno solo y lo fija una
especificación que no cambia, como un tiempo de respuesta acordado:
el argumento agrega una indirección sin beneficio. Y cuando el límite
depende del período, como un tráfico normal distinto a las 8 y a las
15: una sola lista para todas las horas no lo expresa, y los pares
necesitan la hora en la clave, o el argumento pasa a ser un predicado
que da el límite de cada hora.

Capítulo 84, [sección 84.5](capitulo-84-proyecto-analisis-registros/index.md#845-version-3-metricas-por-hora-e-informes).

## 93 — Ajuste robusto

**Problema.** Los límites de lo normal se ajustan con valores
observados, y entre esos valores puede haber los mismos atípicos que
los límites deben detectar: los ataques ya ocurridos en los días de
referencia, o todos los del día cuando el ajuste usa el mismo día que
se examina.

**Versión ingenua.** El modelo de la media y el desvío,
`ajustar(media_desvio(D), …)`: un solo valor extremo desplaza la media
e infla el desvío. En `[1, 1, 2, 2, 4, 6, 900]`, el desvío es 314 y ni
el 900 queda a más de tres desvíos; ajustado con el mismo jueves, el
límite de los fallos sube a 60,6, y de las ocho anomalías que
encuentran los límites de referencia queda una.

**Patrón.** Ajustar con la mediana y la MAD, que un atípico no
desplaza mientras los atípicos sean menos de la mitad:
`ajustar(mediana_mad(Z), …)` calcula las dos con `mad/3` y da la
mediana más o menos Z · MAD / 0,6745, con el 3,5 del NIST. Con el
mismo jueves, encuentra cinco anomalías y pierde solo la caída. Si
más de la mitad de los valores son iguales, la MAD es 0 y el
intervalo se reduce a un punto, como el `entre(0.0, 0.0)` de las rutas
inexistentes de los días de referencia; hace falta una dispersión
mínima, la MAD o un mínimo, la que sea mayor. Con un mínimo de 1, la
resolución de un contador, `ajustar_con_minimo/4` del
[ejercicio 5](capitulo-84-proyecto-analisis-registros/index.md#ejercicios) pone el límite en 5,2.

**Cuándo no usarlo.** Cuando los valores anómalos son la mitad o más,
como un día con media jornada sin servicio: ningún ajuste con esos
datos tiene un normal del que alejarse, y los límites salen de otros
días. Y cuando los valores llegan de a uno o se resumen por partes: la
media y el desvío se actualizan con tres números, la cantidad, la suma
y la suma de los cuadrados, mientras que la mediana necesita todos los
valores o su histograma, como en la
[sección 84.8](capitulo-84-proyecto-analisis-registros/index.md#848-version-6-muchos-dias-en-paralelo).

Capítulo 84, [sección 84.6](capitulo-84-proyecto-analisis-registros/index.md#846-version-4-umbrales-ajustados-a-partir-de-los-datos).

## 94 — Resumen que se combina

**Problema.** Un cálculo sobre muchos valores se reparte en partes,
como los días de referencia leídos cada uno en un hilo, y el resultado
tiene que ser el mismo que con todos los valores juntos.

**Versión ingenua.** Juntar los valores de todas las partes en una
lista y calcular al final, como `referencia/1` de la versión 4 con
`append/2`: cada parte devuelve todos sus valores, y el cálculo que
importa se hace en serie sobre la lista entera. O combinar los
resultados de cada parte, que no siempre se puede: la mediana de dos
conjuntos no se deduce de sus medianas.

**Patrón.** Resumir cada parte en un término que se combina con el de
otra y da el resumen de la unión: `resumir/3` produce
`r(N, Suma, Cuadrados, Histograma)` y `combinar/3` suma los tres
números y mezcla los histogramas con `mezclar/3`. La combinación es
asociativa y conmutativa, así que el orden de las partes no cambia el
resultado: `resumir_en_paralelo/3` resume con
`concurrent_maplist/3` y combina con `foldl/4`, y da el mismo término
que `resumir_en_serie/3`. El valor final sale del resumen, con
`ajustar_resumen/3`: la media y el desvío, de los tres números; la
mediana y la MAD, del histograma, porque necesitan saber cuántas veces
aparece cada valor. Es el acumulado que reúne varios valores del
[Patrón 15](patrones.md#15-plegado-con-foldl), con una condición
más: dos acumulados se combinan entre sí, no solo con un elemento. Y
los hilos no comparten estado, de modo que no hace falta el mutex del
[Patrón 52](patrones.md#52-estado-compartido-detras-de-un-mutex):
cada uno devuelve su resumen.

**Cuándo no usarlo.** Cuando el resumen no es menor que los datos: en
los días de referencia, el histograma de los fallos tiene 12 pares
para 36 horas, pero el de la CPU, con valores de punto flotante, tiene
36, uno por hora; entonces los valores se agrupan en intervalos, a
costa de una mediana aproximada. Cuando hay una sola parte, porque no
hay nada que repartir. Y cuando las partes pueden superponerse: el
resumen no sabe de dónde vino cada valor, y un día combinado dos veces
pesa el doble, como mide el
[ejercicio 9](capitulo-84-proyecto-analisis-registros/index.md#ejercicios).

Capítulo 84, página [«Muchos días en paralelo»](capitulo-84-proyecto-analisis-registros/paralelo.md), apartado [«Versión 6: muchos días en paralelo»](capitulo-84-proyecto-analisis-registros/paralelo.md#version-6-muchos-dias-en-paralelo).

## 95 — Propagar solo lo nuevo

**Problema.** Un cálculo se repite hasta un punto fijo: cada paso
agrega hechos, posiciones o etiquetas que se deducen de los que ya hay,
y termina cuando un paso no agrega nada.

**Versión ingenua.** En cada paso, volver a combinar todo lo conocido:
la evaluación ingenua de la
[sección 38.6](capitulo-38-semantica-de-los-programas-logicos/index.md#386-evaluacion-de-abajo-hacia-arriba)
o las rondas de la tabla de finales del
[capítulo 79](capitulo-79-proyecto-lenguaje-consejos-ajedrez/index.md),
que vuelven a derivar en cada paso lo que derivaron los anteriores.

**Patrón.** Llevar aparte lo que el paso anterior agregó, los
**nuevos**, y hacer que cada paso parta de ellos: una derivación toma
al menos un elemento nuevo, los anteriores al elegido de lo que ya se
sabía y los posteriores de lo actual, para contarse una sola vez
(`iterar/7`). Lo que necesita «todos» en lugar de «alguno» se lleva
con una cuenta que baja con cada novedad (`retrogrado/3`). El cálculo
termina cuando no hay nuevos. En la fila de 40 arcos, cada camino se
deriva una vez: 820 derivaciones, contra 860 del evaluador del
[capítulo 38](capitulo-38-semantica-de-los-programas-logicos/index.md).

**Cuándo no usarlo.** Cuando un paso puede **quitar** lo que otro
agregó: con una negación, o con hechos que se borran, partir de lo
nuevo deja conclusiones que ya no valen, y hace falta otro algoritmo
(DRed) o recalcular. Y cuando el cálculo tiene uno o dos pasos, como
una regla que no es recursiva: llevar los nuevos aparte no ahorra
nada.

Capítulo 85, [sección 85.4](capitulo-85-proyecto-motor-datalog/index.md#854-version-2-relaciones-indexadas-y-la-evaluacion-semi-ingenua).

## 96 — La consulta como semilla

**Problema.** Un cálculo de abajo hacia arriba termina siempre, pero
calcula todo lo que el programa permite deducir, aunque la pregunta
sea por una parte pequeña.

**Versión ingenua.** Calcular el modelo entero y quedarse con lo que
unifica con la consulta (`respuestas/4`), o escribir de manera explícita
una versión del programa especializada para cada forma de la consulta,
como `alcanza/1` en el
[ejercicio 13 del capítulo 38](capitulo-38-semantica-de-los-programas-logicos/soluciones.md#13).

**Patrón.** Reescribir el programa para que cada regla exija que su
cabeza haya sido **pedida**: un predicado nuevo guarda los valores con
que se pediría cada predicado, las reglas mágicas dicen qué pide cada
literal a partir de su cabeza y de los literales anteriores, y la
consulta aporta el primer pedido, la **semilla** (`magico/3`). El
cálculo sigue siendo de abajo hacia arriba, y sigue terminando; solo
deriva lo que alguna llamada pide. La fila de 40 arcos responde
`camino(0, Y)` con 41 derivaciones en lugar de 820.

**Cuándo no usarlo.** Cuando la consulta no liga nada que el programa
pueda aprovechar: con el adorno `ff`, o con la recursión en la
dirección que pierde el argumento ligado, la transformación agrega
hechos mágicos al mismo trabajo (862 contra 820). Y cuando casi todo
lo que la consulta usa está bajo una negación, que necesita la
relación entera: en el Wumpus y en los marcos, la ganancia es pequeña
o nula.

Capítulo 85, página [«La transformación mágica»](capitulo-85-proyecto-motor-datalog/magia.md), apartado [«Los predicados mágicos»](capitulo-85-proyecto-motor-datalog/magia.md#los-predicados-magicos).

## 97 — Una condición, dos metas

**Problema.** Una condición se compila en una meta de Prolog, pero
tiene más resultados que la meta: en SQL es verdadera, falsa o
desconocida, y la falla de una meta no distingue la falsa de la
desconocida.

**Versión ingenua.** Compilar cada condición en una sola meta y la
negación en `\+` de esa meta, como `filtro/3` de la
[versión 4](capitulo-86-proyecto-mini-sql-prolog/index.md#866-version-4-el-compilador-de-toy-sequel). `\+` cuenta
como falsa toda condición que no se prueba: `NOT (nota >= 6)` deja
pasar también las inscripciones sin nota, y la versión escrita directamente
en Prolog de la
[sección 42.4](capitulo-42-prolog-y-sql/index.md#424-donde-difieren-bolsas-conjuntos-y-null)
da siete inscripciones en lugar de cuatro.

**Patrón.** Compilar cada condición con una **polaridad**, `verdadera`
o `falsa`, en la meta que se cumple cuando la condición tiene ese
valor (`condicion/5`). La negación no genera meta: compila su
argumento con la polaridad opuesta (`opuesta/2`). La conjunción falsa
es la disyunción de las falsas, y la disyunción falsa, la conjunción;
una comparación falsa usa el operador contrario (`negar/2`) y exige,
como la verdadera, que sus valores no sean `NULL`. El tercer valor no
necesita meta propia: es el que no cumple ninguna de las dos. La
negación queda empujada hasta las comparaciones, y solo las
subconsultas falsas, `NOT EXISTS` y `NOT IN`, conservan un `\+`. Como el
[Patrón 63](patrones.md#63-estado-como-resultado-no-como-falla),
la falsedad pasa a ser algo que se prueba, y no la falla de una meta.

**Cuándo no usarlo.** Cuando la lógica tiene dos valores y el mundo
es cerrado, como en un lenguaje de consultas sobre hechos sin `NULL`:
`\+` de la meta verdadera ya es la falsa, y la segunda polaridad
duplica el compilador sin cambiar ninguna respuesta.

Capítulo 86, [sección 86.7](capitulo-86-proyecto-mini-sql-prolog/index.md#867-version-5-condiciones-de-tres-valores).

## 98 — La igualdad se unifica solo en la conjunción positiva

**Problema.** Un compilador de consultas traduce las igualdades entre
columnas, o entre una columna y una constante. Compilarlas como
comparaciones que se ejecutan después de los generadores recorre el
producto de las tablas; unificarlas al compilar liga los argumentos
de los generadores, y el índice encuentra las filas sin recorrerlas.

**Versión ingenua.** Unificar toda igualdad, en cualquier lugar de la
condición, como `filtro/3` de Toy-Sequel. Bajo `OR`, la segunda
igualdad sobre la misma columna ya no unifica y se compila como
`fail`: `carrera = 'civil' OR carrera = 'industrial'` pierde a los
alumnos de industrial. Bajo `NOT`, el generador queda restringido a
las filas que la negación rechaza, y `NOT carrera = 'civil'` no da
ninguna fila.

**Patrón.** Resolver al compilar solo las igualdades de la conjunción
de primer nivel de la condición (`igualdades/3`), que toda fila de la
respuesta tiene que cumplir, entre valores del mismo tipo y con una
columna de la consulta que se compila (`unificable/2`). Las que están
bajo `OR` o bajo `NOT` se compilan como comparaciones. Si una de las
columnas unificadas admite `NULL`, queda en la condición el control
`V \== null`. Es la evaluación parcial del
[Patrón 50](patrones.md#50-especializar-el-interprete) restringida
al contexto en que es correcta: la reunión de `numeros(300)` consigo
misma cuesta 910 inferencias en lugar de 270 610.

**Cuándo no usarlo.** Cuando la igualdad del lenguaje no es la
unificación: un entero y un real, `1` y `1.0`, son iguales en SQL y
no unifican, y dos textos comparados sin distinguir mayúsculas
tampoco; unificar daría menos filas. Por eso `igualdad/3` exige el
mismo tipo en las dos columnas. Y cuando las dos columnas son de una
consulta de afuera: la unificación, hecha al compilar la
subconsulta, valdría para toda la consulta de afuera, también donde
la subconsulta está negada; `unificable/2` exige por eso una columna
de la consulta actual.

Capítulo 86, [sección 86.7](capitulo-86-proyecto-mini-sql-prolog/index.md#867-version-5-condiciones-de-tres-valores).

## 99 — El error en el punto más lejano

**Problema.** Una gramática que no reconoce la entrada falla, y la
falla no dice dónde. La vuelta atrás prueba todas las alternativas, y
cuando la última falla, `phrase/2` falla sin ninguna información.

**Versión ingenua.** Informar sobre la entrada entera («sentencia
incorrecta»), o lanzar el error en la primera alternativa que no
reconoce un token. Lo primero no ayuda a corregir; lo segundo lo
lanza demasiado pronto: una alternativa que falla es lo normal en una
gramática con vuelta atrás, y otra alternativa podía reconocer la
entrada.

**Patrón.** Pasar todos los tokens por un único terminal, `t//1`,
que antes de examinar el próximo token anota el resto de la entrada
si es el más corto alcanzado hasta ahora (`anotar/1`), en una
variable global que sobrevive a la vuelta atrás. Si el análisis
entero falla, el resto anotado es el **punto más lejano** al que llegó
alguna alternativa, y el error nombra los tokens que empiezan ahí
(`analizar_tokens/2`). La gramática no cambia: solo su terminal. El
error es un término, `error(sql(sintaxis(Cerca)), _)`, que quien lo
captura examina como en el
[Patrón 30](patrones.md#30-capturar-lo-justo-y-relanzar).

**Cuándo no usarlo.** Cuando la gramática es determinista y no vuelve
atrás, como un analizador que lee la entrada de izquierda a derecha
con un token de anticipación: el punto en que falla ya es el más
lejano, y basta con lanzar el error allí. Y cuando una alternativa
avanza mucho por un camino equivocado antes de fallar: el punto más
lejano es el de ese camino, y el mensaje señala un lugar que no es el
error que quien escribió la sentencia cometió.

Capítulo 86, página [«Los errores de sintaxis y de tipos»](capitulo-86-proyecto-mini-sql-prolog/errores.md), apartado [«Los errores de sintaxis»](capitulo-86-proyecto-mini-sql-prolog/errores.md#los-errores-de-sintaxis).

## 100 — Calcular el estado nuevo antes de cambiar

**Problema.** Una operación cambia muchos hechos de una base dinámica.
Tiene que leer el estado como estaba antes de empezar, aunque sus
condiciones consulten los mismos hechos que cambia, y tiene que
cambiarlos todos o ninguno, aunque un hecho a mitad del recorrido no
cumpla una restricción.

**Versión ingenua.** Retirar y agregar cada hecho dentro del
recorrido, `retract(Viejo), assertz(Nuevo), fail`, como Toy-Sequel. La
vista lógica de actualización protege al recorrido, pero no a una
subconsulta que se vuelve a ejecutar en cada fila y ve la tabla a
medio cambiar; y un error en la fila diez deja cambiadas las nueve
anteriores.

**Patrón.** Calcular primero, con `findall/3` sobre el estado
anterior, todas las filas que la tabla tendrá después (`actualizar/4`);
verificar sobre ese resultado los tipos, `NOT NULL`, los rangos y la
clave (`verificar/4`); y solo entonces reemplazar las filas de la
tabla en un solo paso (`reemplazar/2`). Una restricción violada lanza
el error antes de tocar la base. Es el
[Patrón 86](patrones.md#86-el-estado-como-valor-la-base-de-datos-como-capa)
aplicado a una tabla: la relación entre el estado viejo y el nuevo es
pura, y la base cambia en una sola meta al final.

**Cuándo no usarlo.** Cuando la tabla es grande y la operación cambia
pocas filas: reemplazar la tabla entera cuesta un recorrido por
sentencia, y conviene cambiar solo esas filas y llevar un registro de
los cambios para deshacerlos. Y cuando ninguna condición lee lo que la
operación cambia y un error a mitad del camino no deja la base
inconsistente, como al agregar hechos que no tienen restricciones
entre sí: el bucle de falla es más simple y basta.

Capítulo 86, página [«Las sentencias que cambian las tablas»](capitulo-86-proyecto-mini-sql-prolog/modificaciones.md), apartado [«Las sentencias que cambian las tablas»](capitulo-86-proyecto-mini-sql-prolog/modificaciones.md#las-sentencias-que-cambian-las-tablas).

## 101 — Construir la propiedad antes de aplicarla

**Problema.** En una gramática que construye la forma lógica mientras
analiza, el significado de un sintagma depende de otro: el
cuantificador del sujeto necesita la propiedad que el predicado dice
de él, y el objeto, el átomo del verbo del que es argumento.

**Versión ingenua.** Analizar primero y construir la forma lógica
después, en una segunda pasada sobre el árbol sintáctico que
reordena los cuantificadores; o hacer que cada sintagma nominal dé
solo su variable, y agregar su cuantificador desde afuera, donde ya
no se sabe cuál es su alcance.

**Patrón.** Representar lo que falta como una **propiedad**, el
término `X^P`, y pasarla al sintagma que la aplica: un sintagma
nominal es `(X^P)^F`, y aplicarlo es unificar. Un nombre propio pone
su constante en lugar de X; un determinante pone P como alcance de
su cuantificador. `sv//3` arma el átomo del verbo con `=..` **antes**
de analizar el objeto, que recibe `(Y^A)^F` con la propiedad ya
construida. Construida antes, la propiedad es un término que el
sintagma puede examinar y copiar: la coordinación del
[ejercicio 11](capitulo-87-proyecto-preguntas-en-castellano/soluciones.md#11) la aplica una vez a cada nombre, lo
que no se puede hacer con una variable. Como en el
[Patrón 75](patrones.md#75-dos-representaciones-unidas-por-un-hecho-que-comparte-las-variables),
las variables compartidas unen las dos partes sin ningún paso de
conversión.

**Cuándo no usarlo.** Cuando la propiedad no se puede construir
antes de que se aplique: en `oracion//1` el sujeto se analiza antes
que el verbo, y recibe `X^P` con P todavía libre. La aplicación por
unificación sigue funcionando, pero nada que examine la propiedad:
«¿Ana y diego cursan lógica?» no se analiza. Ahí hace falta un
término que represente la aplicación pendiente, como los árboles de
cuantificadores del apartado 4.1.6 de Pereira y Shieber. Y cuando el
significado de un sintagma no depende de ningún otro, como en las
plantillas de la [versión 1](capitulo-87-proyecto-preguntas-en-castellano/index.md#873-version-1-palabras-clave).

Capítulo 87, [sección 87.5](capitulo-87-proyecto-preguntas-en-castellano/index.md#875-version-2-la-gramatica-y-la-forma-logica).

## 102 — Tabla para lo que la gramática prueba varias veces

**Problema.** Una gramática con vuelta atrás vuelve a examinar las
mismas palabras: cada regla que podría empezar por una palabra la
prueba, como verbo, como nombre, como nombre propio. Si examinar una
palabra es caro, como el análisis morfológico del
[capítulo 53](capitulo-53-proyecto-morfologia-castellano/index.md),
el costo se multiplica por las alternativas.

**Versión ingenua.** Llamar al analizador desde cada regla de la
gramática, o analizar de antemano todas las palabras de la oración en
todas sus lecturas posibles, aunque la gramática use pocas.

**Patrón.** Envolver el cálculo caro en un predicado que solo lo
llama, `analisis/2`, y declararlo `:- table`. La primera llamada con
una palabra la analiza y guarda todas sus respuestas; las siguientes,
en la misma pregunta o en otra de la sesión, las leen de la tabla. La
gramática no cambia. Una pregunta cuesta unas 279 000 inferencias la
primera vez y unas 500 la segunda. Es el
[Patrón 53](patrones.md#53-tabular-la-relacion-recursiva) con otro
motivo: aquí la relación no es recursiva, y la tabla no hace falta
para terminar sino para no repetir, como la memorización del
[Patrón 17](patrones.md#17-memorizacion-con-assertz) sin programarla
de manera explícita.

**Cuándo no usarlo.** Cuando lo que se repite es barato, como una
búsqueda indexada en un hecho: la tabla cuesta más que la llamada.
Y cuando lo que el cálculo consulta cambia durante la sesión, como un
léxico al que se agregan palabras: la tabla conserva el análisis
viejo hasta que se la vacía, o hasta que los predicados de los que
depende se declaran incrementales.

Capítulo 87, página [«Las palabras de la pregunta»](capitulo-87-proyecto-preguntas-en-castellano/palabras.md), apartado [«Las palabras, los lemas y los nombres»](capitulo-87-proyecto-preguntas-en-castellano/palabras.md#las-palabras-los-lemas-y-los-nombres).

## 103 — Una forma lógica, dos evaluadores

**Problema.** Una pregunta se responde de dos maneras: en Prolog, que
además explica la respuesta con los hechos que la prueban, y en un
sistema de bases de datos, que planifica la consulta. Dos
traducciones escritas por separado pueden dar respuestas distintas
sin que nada lo advierta.

**Versión ingenua.** Escribir dos programas a partir del texto: una
gramática que produce metas de Prolog y otra que produce SQL, o un
traductor de SQL a Prolog para la explicación. Cada uno tiene sus
propios errores, y comparar sus resultados exige comparar dos
análisis de la misma pregunta.

**Patrón.** Analizar una sola vez, en una **forma lógica**: un
término con su propio lenguaje pequeño, `cual/2`, `cuantos/2`,
`si_no/1`, `todo/3`, `alguno/3`, `no/1`, `y/2` y los predicados de la
base. Dos evaluadores la leen: `evaluar/2` la interpreta en Prolog, y
`sql/2` la compila a una sentencia que `ejecutar_sql/3` ejecuta y
`respuesta_filas/3` convierte en una respuesta de la misma forma que
la de `evaluar/2`. Lo que depende de la base está en un solo hecho
por predicado en cada evaluador, `definicion/2` y `sql_atomo/4`. Las
pruebas comparan las dos respuestas pregunta por pregunta, y cada
evaluador verifica al otro. Es la
[especificación como dato del Patrón 91](patrones.md#91-especificacion-como-dato)
con más de un intérprete.

**Cuándo no usarlo.** Cuando los dos evaluadores no pueden dar la
misma semántica y la diferencia no se documenta: una presuposición
que no se cumple da en Prolog una advertencia y en SQL «sí», y las
pruebas tienen que separar ese caso en lugar de esconderlo. Y cuando
hay un solo destino: la forma lógica agrega un lenguaje intermedio
que nadie más lee.

Capítulo 87, página [«La forma lógica en SQL»](capitulo-87-proyecto-preguntas-en-castellano/sql.md), apartado [«La sentencia en SQLite»](capitulo-87-proyecto-preguntas-en-castellano/sql.md#la-sentencia-en-sqlite).
