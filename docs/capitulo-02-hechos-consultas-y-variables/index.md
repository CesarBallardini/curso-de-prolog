# Capítulo 2 — Hechos, consultas y variables

El capítulo 1 fue un recorrido general. A partir de este capítulo los temas se desarrollan de manera sistemática y en orden.

Este capítulo trata los elementos más simples de Prolog: **hechos** y
**consultas**. No contiene ninguna regla. Con esos dos elementos ya se puede
construir una base de conocimiento y formularle consultas no triviales; además,
se puede establecer con precisión qué significa cada respuesta, incluida
`false.`, cuyo significado no es el que sugiere su nombre.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- escribir hechos que expresen la relación deseada, con un orden de argumentos
  definido de antemano;
- cargar un programa, en el navegador o en una instalación local;
- formular una consulta sobre objetos concretos e interpretar `true.` o
  `false.`;
- distinguir entre "no se puede probar" y "el predicado no existe";
- usar variables para preguntar *quién* o *qué*, y obtener todas las respuestas.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **0:35 h**.
    Resolver los 6 ejercicios marcados con ★: **1:25 h**.
    Resolver los 16 ejercicios del final: **3:55 h**.

## 2.1 Objetos y relaciones

Un programa Prolog describe **objetos** y **relaciones** entre ellos.

Los objetos son las entidades sobre las que trata el programa: personas,
números, ciudades, materias, etcétera. En el ejemplo de este capítulo son
personas: `juan`, `ana`, `pedro`.

Las relaciones son los vínculos entre esos objetos. "Juan es el padre de Ana" es
una relación entre dos objetos. "Ana es mujer" no vincula a Ana con otro objeto:
enuncia algo sobre ella sola. Ambas se escriben de la misma manera en Prolog, y
ambas se denominan relaciones, aunque a la segunda le corresponde más
propiamente el nombre de propiedad.

Para cada relación se deben tomar dos decisiones, preferentemente antes de
escribir el programa:

- **cuántos objetos participan.** "Ser padre" involucra dos. "Ser mujer"
  involucra uno. "Dar un regalo" involucra tres: quién regala, qué regala y a quién.
- **en qué orden se escriben.** `padre(juan, ana)` puede significar que juan es
  el padre de ana, o que ana es padre de juan. Ambas lecturas son posibles, y
  Prolog no dispone de información para determinar cuál es la deseada. Se elige
  una, se la documenta y se la usa de manera consistente.

## 2.2 Hechos

Un **hecho** afirma que una relación se cumple entre objetos determinados. La
siguiente es una base de conocimiento formada exclusivamente por hechos:

<!-- ejemplo: capitulo-02/hechos.pl consulta: padre(juan, ana). -->
```prolog
% varon(P): P es varón.
varon(juan).
varon(pedro).
varon(luis).

% mujer(P): P es mujer.
mujer(marta).
mujer(ana).
mujer(eva).
mujer(sofia).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% madre(M, H): M es la madre de H.
madre(marta, ana).
madre(marta, pedro).
madre(eva, sofia).
```

Cada línea tiene la misma estructura:

- el nombre de la relación, en minúscula, que se denomina **predicado**;
- los objetos entre paréntesis, separados por comas, que se denominan
  **argumentos**;
- un **punto** final.

El punto es obligatorio, y su omisión es el error más frecuente al comenzar. Sin
el punto, Prolog continúa leyendo la línea siguiente como parte de la misma
cláusula, por lo tanto, el error que se informa puede resultar confuso.

Dado que estos mensajes aparecen desde los primeros programas, a continuación se
muestran los tres más frecuentes, tal como los emite SWI-Prolog 9. Conviene
conocerlos de antemano para reconocerlos cuando aparezcan.

**Falta el punto.** El número de línea informado corresponde a la línea
*siguiente*, porque la lectura continuó hasta ese punto:

```text
ERROR: familia.pl:2:17: Syntax error: Operator expected
```

**Hay una coma en el lugar del punto.** El mensaje sugiere la causa: pregunta si
faltó terminar la cláusula con un punto:

```text
ERROR: familia.pl:2:
ERROR:    Full stop in clause-body?  Cannot redefine ,/2
```

**Hay un espacio entre el nombre y el paréntesis** —`padre (juan, ana).`—, que
para Prolog es una construcción sintáctica diferente:

```text
ERROR: familia.pl:2:6: Syntax error: Operator expected
```

En los tres casos el programa **no se cargó**. Se debe corregir el error y
cargar el programa nuevamente.

Los nombres en minúscula, como `juan` o `prolog`, se denominan **átomos**. Un
átomo es un objeto identificado únicamente por su nombre: no tiene componentes
ni valor asociado.

Los **números** son objetos de otra clase. Se escriben tal como son —`68`,
`3.5`— y no llevan comillas. A diferencia de un átomo, un número sí tiene un
valor con el que se puede operar, y de eso se ocupa el capítulo 8; por ahora
alcanza con saber que un número puede ocupar la posición de un argumento, como
en `edad(juan, 68)`.

Un nombre que no comienza con minúscula, o que contiene espacios u otros
caracteres, se escribe **entre comillas simples**: `'Ana'`, `'mi amigo'`. Sigue
siendo un átomo, y las comillas solo indican dónde comienza y dónde termina.
Sin ellas, `Ana` no sería un átomo sino una variable, que es el tema de la
sección 2.6.

### El nombre no tiene significado para Prolog

El nombre `padre` no tiene ningún significado para el sistema. Si se reemplazara
`padre` por `hgx` en todo el programa, las respuestas serían exactamente las
mismas. El nombre está destinado a quienes escriben y leen el programa, y por
eso conviene elegirlo con cuidado.

Lo mismo se aplica al orden de los argumentos. `padre(juan, ana)` significa
"juan es el padre de ana" porque así se lo definió y se lo documentó en un
comentario previo. Los comentarios comienzan con `%` y se
extienden hasta el fin de la línea; Prolog los ignora.

### Aridad

Un predicado se identifica por su nombre y su **aridad**, que es la cantidad de
argumentos, separados por una barra: `padre/2`, `mujer/1`. Esta notación se usa
en todo el curso y, lo que es más relevante, en los mensajes de error de Prolog.

Dos predicados con el mismo nombre y distinta aridad son predicados
**distintos**, sin ninguna relación entre sí. `padre/1` y `padre/2` serían tan
independientes como dos predicados con nombres diferentes.

## 2.3 Cómo se carga un programa

Los hechos se escriben en un archivo, no en la casilla de consultas. Aunque
parece un detalle operativo, es la causa de la primera dificultad de la mayoría
de quienes comienzan.

**En SWISH**, el entorno al que apuntan los enlaces de este curso, la pantalla
tiene dos partes: arriba a la izquierda, el **programa**; abajo, la casilla de
**consultas**. Los hechos y las reglas se escriben en el panel superior; las
consultas, en el inferior.

**En una instalación local**, los hechos se escriben en un archivo de texto con
extensión `.pl`, que se carga al iniciar el intérprete:

```text
swipl familia.pl
```

o desde el intérprete, con `consult/1`:

```prolog
?- consult('familia.pl').
true.
```

Si el archivo contiene acentos o eñes —por ejemplo, en los comentarios—, conviene
que su primera línea sea la siguiente; todos los ejemplos del curso la incluyen:

```prolog
:- encoding(utf8).
```

Sin esa línea, SWI-Prolog en Windows lee el archivo con la codificación del
sistema, y un carácter acentuado produce un error de sintaxis que impide cargar
el archivo completo.

### Por qué no se pueden escribir hechos en la casilla de consultas

Un hecho escrito en la casilla de consultas no se agrega al programa: Prolog
**lo interpreta como una consulta**. Como el predicado todavía no está definido,
informa un error:

```prolog
?- gusta(ana, prolog).
ERROR: Unknown procedure: gusta/2 (DWIM could not correct goal)
```

La confusión es frecuente: la intención es cargar datos, pero lo que se ejecuta
es una consulta sobre datos que no se cargaron.

### Una consulta sin punto final

En este caso no se produce ningún error. Prolog no rechaza la consulta: queda en
espera, porque considera que la consulta no ha terminado. En una instalación
local aparece `|:` al comienzo de la línea nueva, que indica que el intérprete
espera el resto de la entrada. Al ingresar el punto y presionar Enter, la
consulta se ejecuta.

!!! question "Actividad"
    Abrir cualquier ejemplo del capítulo en SWISH y escribir un hecho nuevo en la
    casilla inferior, la de consultas. Después, moverlo al panel superior,
    ejecutar nuevamente y comparar los resultados.

## 2.4 Consultas

Una **consulta** pregunta si una relación se cumple. Se escribe igual que un
hecho; la única diferencia es el lugar donde se la escribe. El `?- ` de los
ejemplos es el indicador que Prolog muestra cuando espera una consulta; no forma
parte de lo que se ingresa.

```prolog
?- padre(juan, ana).
true.

?- padre(juan, luis).
false.

?- mujer(eva).
true.
```

`true.` indica que la consulta **se deduce** del contenido del programa. En este
caso la deducción es directa: el hecho está escrito de manera literal.

El orden de los argumentos es significativo:

```prolog
?- padre(ana, juan).
false.
```

`padre(juan, ana)` está en el programa; `padre(ana, juan)` no. Son dos consultas
distintas, y por eso es necesario documentar el significado de cada posición.

## 2.5 Lo que no se puede probar

El significado de `false.` requiere una explicación detallada, porque no es el
que sugiere su nombre.

La base de conocimiento no indica quién es el padre de `sofia`: contiene
`madre(eva, sofia)` y ningún otro hecho sobre ella. Por lo tanto:

```prolog
?- padre(juan, sofia).
false.
```

Sofía tiene un padre; lo que ocurre es que **esa información no está en el
programa**. La respuesta de Prolog no significa "la afirmación es falsa":
significa "la afirmación no se puede probar con el contenido del programa". La
diferencia es fundamental.

Este criterio se denomina **supuesto de mundo cerrado**: Prolog opera como si el
programa contuviera toda la información relevante, y considera no cierto todo lo
que no se puede deducir de él. El supuesto tiene consecuencias más profundas,
que se tratan en el capítulo 10.

### Un segundo resultado negativo, de naturaleza distinta

Existe otra forma en que una consulta puede no tener éxito, que no se debe
confundir con la anterior:

```prolog
?- hermano(ana, pedro).
ERROR: Unknown procedure: hermano/2 (DWIM could not correct goal)
```

Esta respuesta no es `false.`. Prolog informa algo más básico: **el programa no
define ninguna relación llamada `hermano/2`**. No se trata de que no pueda
probar que ana y pedro son hermanos; se trata de que el predicado consultado no
existe.

Las dos respuestas se distinguen de la siguiente manera:

| Respuesta | Significado |
|---|---|
| `false.` | La relación está definida, y la consulta no se puede probar |
| `ERROR: Unknown procedure: ...` | La relación no está definida |

La distinción tiene importancia práctica, porque el segundo caso corresponde
casi siempre a un error de quien programa. Las causas posibles son:

1. **El archivo no se cargó**, o se lo modificó después de cargarlo y no se lo
   volvió a cargar.
2. **El nombre está mal escrito en la consulta**: se consultó `padres/2` y el
   programa define `padre/2`.
3. **El nombre está mal escrito en el programa**, en todas sus cláusulas. El
   predicado existe, pero con otro nombre, y la consulta correcta no lo
   encuentra.
4. **La aridad no coincide**: se definió `padre/2` y se consultó `padre/3`, o a
   la inversa. Por eso el mensaje informa siempre `nombre/aridad` y no solo el
   nombre: la aridad es parte de la identificación del predicado.
5. **El hecho se escribió en la casilla de consultas**, que es el caso de la
   sección 2.3.
6. **El predicado todavía no se escribió.**

!!! note "Diferencias con otros textos"
    Clocksin y Mellish, el libro que sigue este capítulo, indica que una consulta
    sobre un predicado desconocido responde *no*. Ese era el comportamiento de
    las implementaciones de Prolog de esa época. SWI-Prolog 9 informa un error,
    lo que resulta más útil para detectar el problema. Quien consulte otro
    material en paralelo debe esperar esa diferencia, y también una diferencia en
    el indicador de consultas, que en los textos más antiguos suele ser `| ?-` en
    lugar de `?-`.

### Cuando el nombre es similar a uno existente

Si el predicado consultado es similar a uno que existe, SWI-Prolog, en una
instalación local, propone la corrección antes de informar el error:

```prolog
?- padres(juan, ana).
Correct to: "padre(juan,ana)"?
```

Se responde `y` o `n`. Si se rechaza la corrección:

```text
ERROR: Unknown procedure: padres/2
ERROR:   However, there are definitions for:
ERROR:         padre/2
```

Esta asistencia es propia del intérprete local. **En SWISH no está
disponible**: se muestra directamente el error. La diferencia no es relevante;
lo importante es reconocer, en ambos entornos, que el problema está en el
nombre.

## 2.6 Variables

Las consultas anteriores se refieren siempre a objetos concretos. Una
**variable** es una posición que se deja sin especificar para que Prolog le
asigne un valor.

El nombre de una variable comienza con **mayúscula** o con un guion bajo. Los
caracteres siguientes pueden ser minúsculas, mayúsculas, dígitos o guiones
bajos. `Quien`, `X`, `Persona`, `Cualquier_cosa` y `LoQueSea` son variables; `quien` y `persona`
no lo son: son átomos.

<!-- ejemplo: capitulo-02/variables.pl predicado: gusta/2 consulta: gusta(Quien, prolog). -->
```prolog
% gusta(P, C): a P le gusta C.
gusta(juan, futbol).
gusta(ana, prolog).
gusta(luis, futbol).
gusta(eva, prolog).
gusta(sofia, dibujar).
```

Con ese programa cargado:

```prolog
?- gusta(ana, Que).
Que = prolog.
```

Prolog busca un valor de `Que` que haga cierta la consulta, lo encuentra y lo
informa. Cuando una variable recibe un valor, se dice que queda
**instanciada** o **ligada**.

La misma relación se puede consultar en sentido inverso, con el mismo predicado:

```prolog
?- gusta(Quien, prolog).
Quien = ana ;
Quien = eva.
```

No existe un predicado para buscar gustos y otro para buscar personas. Existe
`gusta/2`, y la consulta determina qué posición queda sin especificar. Es una de
las propiedades más usadas de Prolog, y reaparece en todos los capítulos.

Se pueden dejar las dos posiciones sin especificar:

```prolog
?- gusta(Quien, Que).
Quien = juan,
Que = futbol ;
Quien = ana,
Que = prolog ;
Quien = luis,
Que = futbol ;
...
```

Cuando una respuesta incluye más de una variable, Prolog las muestra una por
línea, separadas por comas.

### La variable anónima

Cuando el valor de una posición no interesa, se escribe `_`, que se denomina
**variable anónima**:

```prolog
?- gusta(_, dibujar).
true.
```

Esta consulta pregunta si a alguien le gusta dibujar, sin solicitar a quién. La
respuesta es `true.`, y no un valor, porque la consulta no solicita ninguno.

Cada aparición de `_` es una variable distinta, aunque se escriban igual. En la
consulta `gusta(_, _)`, las dos posiciones se instancian de manera
independiente.

## 2.7 Todas las respuestas

Cuando una consulta tiene más de una respuesta, Prolog muestra la primera y
queda en espera. El punto y coma de los ejemplos anteriores **lo ingresa el
usuario** para solicitar la respuesta siguiente. La barra espaciadora y la tecla
TAB tienen el mismo efecto.  En general, el entorno de Prolog usado puede tener alguna forma de configurar estas teclas.

Para no solicitar más respuestas se presiona Enter.

La forma en que termina una respuesta aporta información:

- si la respuesta termina en **`;`** y Prolog continúa en espera, puede haber
  más respuestas;
- si termina en **`.`**, Prolog determinó que no queda ninguna.

Por eso la última respuesta de `gusta(Quien, prolog)` fue `Quien = eva.`, con
punto: después de `eva` no quedan hechos por examinar.

Cuando no existe ninguna respuesta, Prolog lo informa:

```prolog
?- gusta(Quien, cocinar).
false.
```

Nuevamente, el significado es que no se puede probar, con el contenido del
programa, que a alguien le guste cocinar.

!!! abstract "Plantilla 1 — Consultar por una respuesta, o por todas"
    **Cuándo**: se conoce una parte de la relación y se necesita la otra.

    ```prolog
    ?- relacion(dato_conocido, Incognita).
    ```

    La primera respuesta se obtiene de manera directa; las siguientes se
    solicitan con `;`. Si solo interesa saber si existe alguna respuesta, y no
    cuál es, se usa `_` en lugar de la variable.

    **En este capítulo se usa en**: `gusta(ana, Que)`, `gusta(Quien, prolog)`
    (2.6), `madre(Quien, pedro)` (ejercicio 4). Todas las plantillas están
    reunidas en [esta página](../plantillas.md).

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. **(1)** Escribir como hechos: "Sofía es mujer", "Marta es la madre de Ana",
   "a Luis le gusta el fútbol". Usar los predicados del capítulo.
2. **(1)** ¿Cuáles de estas líneas no son hechos válidos, y por qué?
   `padre(juan, ana).` · `padre(Juan, ana).` · `padre(juan, ana)` ·
   `Padre(juan, ana).`
3. ★ **(1)** ¿Cuáles de los siguientes son átomos, cuáles son variables y cuáles no
   son ni átomos ni variables? `ana` · `Ana` · `_hijo` · `39` · `mi amigo` ·
   `mi_amigo`
4. **(1)** Escribir las consultas que preguntan: ¿Juan es varón?; ¿quién es la
   madre de Pedro?; ¿qué le gusta a Eva?.
5. ★ **(1)** Sin ejecutarlas, indicar qué responde cada una con la base de
   `hechos.pl`: `madre(marta, ana).` · `madre(ana, marta).` ·
   `padre(pedro, eva).` · `mujer(pedro).`
6. ★ **(2)** `?- padre(juan, sofia).` responde `false.`, y `?- hermana(ana, eva).`
   produce un error. Explicar en dos líneas por qué son respuestas distintas.
7. **(2)** Definir una relación de tres argumentos y escribir tres hechos con
   ella. Documentar en un comentario el significado de cada posición.
8. **(2)** Con `variables.pl`, escribir una consulta que determine a quiénes les
   gusta el fútbol; y otra que determine si a alguien le gusta el fútbol, sin
   solicitar a quién.
9. ★ **(2)** ¿Qué diferencia hay entre `?- gusta(ana, Que).` y
   `?- gusta(ana, _).`? Ejecutar ambas.
10. **(2)** Agregar a `hechos.pl` los hechos necesarios para que Sofía tenga
    padre. ¿Qué responde ahora `padre(_, sofia).`?
11. **(2)** La base contiene `mujer(eva)` y `madre(eva, sofia)`. ¿Son necesarios
    los dos hechos, o uno se deduce del otro? Responder con los elementos vistos
    hasta este capítulo.
12. **(3)** Escribir una base de conocimiento de cinco o seis líneas sobre un
    dominio conocido que no sea una familia: materias y cuatrimestres, líneas de
    colectivo y barrios, u otro. Después, escribir tres consultas con sentido
    sobre ella: una con respuesta `true.`, una con `false.` y una con variable.
13. ★ **(2)** Representar cada enunciado como uno o más hechos, eligiendo el
    predicado y el orden de los argumentos, y documentando cada predicado en un
    comentario:

    a. "Ana nació en 1985."
    b. "La materia Lógica tiene cuatro horas semanales."
    c. "Ana y Luis son compañeros de trabajo."

    El tercero requiere una decisión que los otros dos no: conviene ejecutar la
    consulta inversa y ver qué ocurre.
14. ★ **(2)** Los tres enunciados siguientes **no** se pueden escribir como
    hechos. Explicar en una línea por qué, en cada caso:

    a. "Ana es mayor que Luis."
    b. "Toda persona tiene madre."
    c. "Ana no tiene hijos."
15. **(1)** Con la base de `hechos.pl`, predecir cuántas respuestas produce cada
    consulta antes de ejecutarla: `mujer(Quien).` · `madre(marta, Quien).` ·
    `padre(Quien, ana).` · `padre(juan, Quien).`
16. **(2)** Con `regala/3` del ejercicio 7, escribir las tres consultas que
    preguntan: qué le regaló juan a ana; quién le regaló algo a luis; y qué
    regalos hubo, sin especificar quiénes participaron. Ejecutarlas.

## Resumen

Términos y construcciones presentados en este capítulo:

| | |
|---|---|
| **hecho** | afirma que una relación se cumple entre objetos determinados |
| **consulta** | pregunta si una relación se cumple; se escribe igual que un hecho |
| **predicado** | el nombre de la relación |
| **argumento** | cada objeto entre paréntesis |
| **aridad** | cantidad de argumentos; se escribe `padre/2` |
| **átomo** | un objeto identificado por su nombre, en minúscula: `ana`, `prolog` |
| **variable** | comienza con mayúscula o `_`; una posición a la que Prolog asigna un valor |
| **variable anónima** | `_`; una posición cuyo valor no interesa |
| **instanciada** | se dice de una variable que ya recibió un valor |
| **mundo cerrado** | lo que no se puede probar se considera no cierto |
| `consult/1` | carga un archivo de programa |
| `%` | comienza un comentario, hasta el fin de la línea |
| `:- encoding(utf8).` | primera línea de todo archivo con caracteres acentuados |

Dos respuestas que no se deben confundir: `false.` significa "no se puede
probar"; `ERROR: Unknown procedure` significa "la relación no está definida".

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Reglas, para deducir en lugar de enumerar | capítulo 3 |
| Átomos, variables y unificación | capítulo 4 |
| El orden en que Prolog busca las respuestas | capítulo 5 |
| El supuesto de mundo cerrado, en detalle | capítulo 10 |
| La lectura de un programa como fórmulas lógicas | capítulo 11 |
