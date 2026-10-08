# Soluciones del capítulo 13 — El entorno de trabajo

El código de esta página está en `ejemplos/capitulo-13/soluciones.pl` y pasa sus
pruebas. Varios ejercicios de este capítulo se resuelven con el entorno y no con
código: sus soluciones describen qué muestra cada herramienta.

## 1

`check.` informa que falta `persona/1`, que la llama la primera cláusula de
`nieto/2`, en la línea 29 de `revision.pl`, columna 4. La corrección es agregar
los hechos de la familia:

<!-- ejemplo: capitulo-13/soluciones.pl predicado: persona/1 nieto/2 consulta: nieto(luis, Quien). -->
```prolog
% persona(P): P es una de las personas de la familia.
persona(juan).
persona(ana).
persona(pedro).
persona(luis).
persona(eva).

%!  nieto(?N, ?A) is nondet.
%
%   N es nieto de A, y es una persona registrada.
nieto(N, A) :-
    abuelo(A, N),
    persona(N).
```

```prolog
?- nieto(luis, Quien).
Quien = juan ;
false.
```

Con los hechos agregados, `check.` recorre sus revisiones sin ninguna
advertencia. El programa ya funcionaba para `abuelo/2`; el defecto estaba en un
predicado que ninguna consulta había ejecutado todavía, y por eso ninguna
prueba manual lo había encontrado.

## 2

```prolog
?- apropos(last).
```

```text
% LIB last/2                 Succeeds when Last is the last element of List.
...
```

El predicado es `last/2`, de `library(lists)`. La primera línea de su entrada en
el manual es `last(?List, ?Last)`: los dos argumentos pueden llegar ligados o
libres. Es la misma declaración que el [capítulo 7](../capitulo-07-listas/index.md) da a los predicados que,
como `ultimo/2`, generan listas cuando la lista llega libre.

## 3

```prolog
?- listing(correlativa/2).
```

```text
correlativa(am2, am1).
correlativa(am2, alg).
correlativa(pp, log).
correlativa(ssl, log).
correlativa(ssl, alg).
correlativa(bd, pp).
correlativa(bd, ssl).

true.
```

Los hechos aparecen en el orden en que están en el archivo, que es el orden en
que se cargaron. Es también el orden en que Prolog los prueba, como mostró el
[capítulo 5](../capitulo-05-como-responde-prolog/index.md): `listing/1` muestra el programa tal como lo va a recorrer la
búsqueda. `listing/1` no conserva el formato del archivo: alinea los argumentos
con su propia disposición y quita los espacios que el archivo usaba para encolumnar.

## 4

`make.` recarga el archivo y advierte que las cláusulas de `alumno/4` no están
juntas: la nueva quedó al final, después de los hechos de `inscripcion/3`, lejos
de las otras de `alumno/4`. La advertencia existe porque ese orden suele ser un
error; el programa igual funciona, y `alumno(108, Nombre, _, _)` responde
`hernan`.

La corrección es mover el hecho junto a los demás alumnos, después de
`alumno(107, …)`, y volver a ejecutar `make.`, que ya no advierte nada. Si las
cláusulas separadas son intencionales, la directiva `:- discontiguous
alumno/4.` que sugiere el mensaje lo declara; en un archivo de datos como este
no lo son.

## 5

El archivo se abre en la línea 20 de `revision.pl`, la de la primera cláusula de
`abuelo/2`: `edit/1` busca dónde está definido el predicado y pasa esa línea a
`--goto`.

Sin `--wait`, el comando `code` terminaría enseguida: Visual Studio Code abre el
archivo en una ventana y devuelve el control. `edit/1` interpretaría que la
edición terminó y ejecutaría `make/0` antes de que se modifique nada; los
cambios que se hagan después quedarían sin recargar hasta el siguiente `make.`

## 6

El editor subraya `P` y `Q`, y al cargar el archivo SWI-Prolog muestra la misma
advertencia:

```text
Warning:    Singleton variables: [P,Q]
```

Es una advertencia, no un error: la regla se carga y se ejecuta. Pero indica un
defecto de la regla. Una variable que aparece una sola vez no relaciona nada con
nada: la regla dice «A tiene algún padre, B tiene algún padre, y son distintos»,
de modo que cualquier par de hijos de la base serían hermanos. Lo que pretendía
decir es que tienen **el mismo** padre, y eso se escribe con la misma variable
en los dos objetivos:

<!-- ejemplo: capitulo-13/soluciones.pl predicado: hermano/2 consulta: hermano(ana, Quien). -->
```prolog
%!  hermano(?A, ?B) is nondet.
%
%   A y B son hermanos: tienen el mismo padre y son personas distintas.
hermano(A, B) :-
    padre(P, A),
    padre(P, B),
    A \== B.
```

```prolog
?- hermano(ana, Quien).
Quien = pedro.
```

La advertencia de variable única señala, en la mayoría de los casos, un nombre
mal escrito o una relación que falta.

## 7

ediprolog escribe las respuestas debajo de la consulta, en el mismo archivo,
como líneas de comentario que empiezan con `%@`. Las respuestas siguientes se
piden como en el toplevel, con `;`, y cada una se agrega como otra línea `%@`.
Como son comentarios, no cambian el programa: el archivo se sigue cargando
igual, y las respuestas quedan como registro de lo que respondió la consulta.

## 8

La prueba busca una correlativa cuyo requisito sea del mismo año o de uno
posterior, y declara con `[fail]` que no debe encontrarla:

<!-- ejemplo: capitulo-13/soluciones.plt fragmento: % Ejercicio 8 .. = Anio. -->
```prolog
% Ejercicio 8: el requisito de toda correlativa es de un año anterior.
test(requisito_de_un_anio_anterior, [fail]) :-
    correlativa(Materia, Requisito),
    materia(Materia, _, Anio),
    materia(Requisito, _, AnioRequisito),
    AnioRequisito >= Anio.
```

Es la forma de las pruebas de datos de `inscripciones.plt`: un contraejemplo
escrito como conjunción, que no debe tener ninguna respuesta. Con los datos del
proyecto la prueba pasa: todos los requisitos son de un año anterior.

## 9

git ejecuta el gancho, `swipl` muestra la prueba que falló —
`toda_inscripcion_es_a_una_materia`— y termina con código 1, y git cancela el
commit sin registrar nada. Para completarlo es necesario corregir el dato y
volver a intentar el commit. El gancho se puede saltear con
`git commit --no-verify`, pero eso anula la razón de tenerlo.

## 10

`[revision].` no advierte nada porque, al cargar, no se puede determinar si
`persona/1` va a existir cuando se ejecute `nieto/2`: el predicado podría estar
en otro archivo que se cargue después, o agregarse durante la ejecución con
`assertz/1`. `check.` revisa el programa **completo** cargado en ese momento,
y por eso puede afirmar que no hay ninguna definición.

La advertencia de `check.` es incorrecta en un programa que agrega los hechos
durante la ejecución: si `persona/1` se crea con `assertz/1` al arrancar, antes
de la primera llamada a `nieto/2`, el programa funciona y `check.` igual advierte.
El mensaje mismo lo anticipa: en ese caso se declara `:- dynamic persona/1.`, y
la advertencia desaparece. El [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md) trata esos predicados.

## 11

<!-- ejemplo: capitulo-13/soluciones.plt fragmento: % Ejercicio 11 .. Nota1 \== Nota2. -->
```prolog
% Ejercicio 11: nadie está inscripto dos veces en la misma materia, con
% notas distintas. Dos hechos idénticos no se detectan así (ver la solución).
test(sin_inscripciones_repetidas, [fail]) :-
    inscripcion(Legajo, Materia, Nota1),
    inscripcion(Legajo, Materia, Nota2),
    Nota1 \== Nota2.
```

La prueba detecta dos inscripciones del mismo alumno a la misma materia con
notas distintas. No detecta dos hechos idénticos: si
`inscripcion(101, am1, 8).` aparece dos veces, la conjunción encuentra el par
formado por el hecho consigo mismo y por el otro, pero en los dos casos las
notas son iguales, y `\==` falla. Con los elementos de la parte I no hay forma
de distinguir un hecho de su copia exacta: los dos son el mismo término.

La herramienta que lo resuelve es contar las respuestas:
`aggregate_all(count, inscripcion(101, am1, _), N)` da 2 cuando el hecho está
repetido. El [capítulo 17](../capitulo-17-todas-las-soluciones/index.md) la presenta.

## 12

Las consultas del encabezado funcionan igual que en la instalación local. `make.`
no tiene efecto útil en SWISH: el programa no está en un archivo que se pueda
recargar, sino en el editor de la página, y se vuelve a enviar con cada
consulta. `set_prolog_flag(editor, code).` es rechazada: SWISH no permite
cambiar banderas del sistema, porque ejecuta los programas de todos sus
usuarios en un entorno restringido. Es la razón de la marca `% solo-local:` de
`init.pl`.

## 13

Antes de modificar el archivo, `listing/1` muestra los cuatro hechos cargados:

```prolog
?- listing(padre/2).
```

```text
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

true.
```

`make.` recarga `revision.pl` y emite dos advertencias. La primera indica que
las cláusulas de `padre/2` no están juntas: el hecho nuevo quedó al final del
archivo, después de `nieto/2`, y la definición anterior empieza en la línea 12.
La segunda es la de `persona/1` sin definir, porque `make/0` repite la revisión
de `list_undefined/0` después de recargar. La segunda consulta muestra el
predicado recargado:

```text
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).
padre(luis, sofia).

true.
```

El hecho nuevo aparece último, en el orden del archivo: `listing/1` no ordena
las cláusulas, escribe las que están cargadas en el orden en que se cargaron.
Lo que muestra es la versión que `make.` acaba de recargar, no el texto del
editor: si el archivo se guardara sin ejecutar `make.`, la segunda consulta
seguiría mostrando cuatro hechos.
