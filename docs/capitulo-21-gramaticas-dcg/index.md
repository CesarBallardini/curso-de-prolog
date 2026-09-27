# Capítulo 21 — Gramáticas (DCG)

Un programa recibe texto: un comando escrito por una persona, una fecha, un
archivo con un formato propio. Leerlo es decidir si tiene la forma esperada y,
si la tiene, extraer lo que dice. El [capítulo 11](../capitulo-11-texto/index.md) lo hizo con `sub_atom/5` y
`split_string/4`, que alcanzan para textos simples. Para textos con estructura
—partes que se repiten, partes opcionales, partes anidadas—, Prolog tiene una
notación propia: las **gramáticas de cláusulas definidas**, o DCG por su sigla
en inglés.

Este capítulo presenta la notación `-->`, la forma de usarla con `phrase/2`, los
argumentos que construyen un resultado mientras se analiza, las bibliotecas
`dcg/basics` y `dcg/high_order`, el problema de la recursión a izquierda y el
pushback. Una misma gramática sirve para analizar un texto y para generarlo. El
proyecto agrega un lenguaje de comandos: «inscribir a 104 en sintaxis».

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- escribir una gramática con `-->`, usarla con `phrase/2` y `phrase/3`, y leer
  su traducción a cláusulas;
- agregar argumentos que construyen un resultado, y usar la misma gramática
  para analizar y para generar;
- analizar números, fechas y listas separadas con `dcg/basics` y
  `dcg/high_order`;
- reconocer una recursión a izquierda y reescribirla con un acumulador;
- mirar el próximo elemento de la entrada sin consumirlo, con pushback.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:00 h**.
    Resolver los 7 ejercicios marcados con ★: **2:28 h**.
    Resolver los 16 ejercicios del final: **5:15 h**.

## 21.1 Una gramática es un conjunto de cláusulas

Una gramática describe las secuencias válidas de un lenguaje. La de este
ejemplo describe oraciones sobre la familia, escritas como listas de palabras:
`[juan, es, el, padre, de, ana]`.

<!-- ejemplo: capitulo-21/gramatica.pl predicado: oracion//1 relacion//3 nombre//1 consulta: phrase(oracion(Hecho), [juan, es, el, padre, de, ana]). -->
```prolog
%!  oracion(?Hecho)// is nondet.
%
%   Una oración que afirma Hecho: «juan es el padre de ana» afirma
%   padre(juan, ana).
oracion(Hecho) -->
    nombre(A),
    [es],
    relacion(A, B, Hecho),
    [de],
    nombre(B).

%!  relacion(?A, ?B, ?Hecho)// is nondet.
%
%   El artículo y el sustantivo de una relación, con el Hecho que forma
%   entre A y B.
relacion(A, B, padre(A, B)) --> [el, padre].
relacion(A, B, madre(A, B)) --> [la, madre].

%!  nombre(?P)// is nondet.
%
%   El nombre de una persona conocida.
nombre(P) -->
    [P],
    { persona(P) }.
```

Cada regla se lee «una oración es un nombre, seguido de la palabra `es`, …». A
la izquierda de `-->` está un **no terminal**, algo que se define con otras
reglas; a la derecha, una secuencia de no terminales y de **terminales**, las
palabras escritas entre corchetes, que deben aparecer tal cual en la entrada.

Al cargar el archivo, Prolog traduce cada regla a una cláusula común con dos
argumentos más: la lista de entrada y lo que queda de ella después de
reconocer el no terminal. `listing/1` muestra la traducción:

```text
oracion(Hecho, C, D) :-
    nombre(A, C, E),
    E=[es|F],
    relacion(A, B, Hecho, F, G),
    G=[de|H],
    nombre(B, H, D).
```

Cada no terminal pasa lo que sobra al siguiente: es la técnica de las **listas
de diferencia**, que el [capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md) trata en general. La notación `//`
en los encabezados —`oracion//1`— indica un no terminal de un argumento, que
es el predicado `oracion/3`. Por eso un no terminal no puede tener el mismo
nombre que un predicado del programa con dos argumentos más: el proyecto de la
[sección 21.10](#2110-el-proyecto-un-lenguaje-de-comandos) no puede llamar `materia//1` a un no terminal, porque ya existe
`materia/3`.

## 21.2 `phrase/2` y `phrase/3`

`phrase(NoTerminal, Lista)` se cumple si `Lista` completa es una secuencia del
no terminal. `phrase(NoTerminal, Lista, Resto)` permite que sobre algo, y lo
devuelve en `Resto`.

```prolog
?- phrase(oracion(Hecho), [juan, es, el, padre, de, ana]).
Hecho = padre(juan, ana) ;
false.

?- phrase(oracion(Hecho), [juan, es, padre, de, ana]).
false.
```

`phrase/2` es la forma de llamar a una gramática: se podría llamar
`oracion(H, Lista, [])` directamente, pero `phrase/2` no depende de cómo se
traduce la regla, y acepta también un cuerpo de gramática compuesto, como se
verá en la sección 20.8.

## 21.3 Terminales y `double_quotes`

Cuando la entrada es texto, los terminales son **códigos** de caracteres. Entre
comillas dobles, dentro de una regla, un texto es la lista de sus códigos:

<!-- ejemplo: capitulo-21/gramatica.pl predicado: saludo//0 consulta: phrase(saludo, `hola`). -->
```prolog
%!  saludo// is semidet.
%
%   Los códigos del texto hola.
saludo --> "hola".
```

```prolog
?- phrase(saludo, `hola`).
true.
```

Fuera de las reglas, en cambio, SWI-Prolog lee las comillas dobles como una
**cadena**, un tipo propio que no es una lista, como explicó el
[capítulo 11](../capitulo-11-texto/index.md). `phrase(saludo, "hola")` produce un error de tipo: `phrase/2`
espera una lista. Hay dos formas de pasar el texto: las comillas invertidas,
que SWI-Prolog lee como una lista de códigos (`` `hola` ``), o convertir la
cadena con `string_codes/2`. Los programas que reciben texto de afuera usan la
segunda.

## 21.4 Argumentos adicionales

Un no terminal puede tener argumentos, como cualquier predicado. `oracion//1`
tiene uno, `Hecho`, que construye el término que la oración afirma mientras la
analiza. Como la traducción es una cláusula común, la gramática es una
relación, y funciona también en el otro sentido: dado el hecho, genera la
oración.

```prolog
?- phrase(oracion(madre(marta, pedro)), Palabras).
Palabras = [marta, es, la, madre, de, pedro].
```

!!! example "Patrón 20 — Una gramática para analizar y generar"
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

## 21.5 `{}`: objetivos comunes dentro de una regla

Entre llaves, dentro de una regla, va un objetivo común que no consume
entrada. `nombre//1` lo usa para aceptar solo personas conocidas:
`[P], { persona(P) }`. La traducción deja el objetivo tal cual, entre los
otros.

La gramática decide la **forma** de la oración, no su verdad:

```prolog
?- phrase(oracion(Hecho), [juan, es, la, madre, de, juan]).
Hecho = madre(juan, juan).
```

Para aceptar solo oraciones verdaderas, un objetivo entre llaves al final de la
regla comprueba el hecho; es el ejercicio 5.

!!! question "Actividad"
    ¿Cuántas oraciones genera `phrase(oracion(H), P)`? Calcularlo antes de
    contarlas con `aggregate_all(count, phrase(oracion(_), _), N)`: cuatro
    personas pueden ocupar cada uno de los dos lugares, y hay dos relaciones.

## 21.6 `library(dcg/basics)` y `library(dcg/high_order)`

`library(dcg/basics)` tiene los no terminales que casi toda gramática de texto
necesita: `integer//1`, `number//1`, `digits//1`, `blanks//0` (cero o más
blancos), `blank//0`, `csym//1` (una palabra de letras, dígitos y guiones
bajos), `string//1`, `remainder//1` y `eos//0` (el fin de la entrada), entre
otros. `library(dcg/high_order)` tiene no terminales que reciben otros no
terminales, como `maplist/3` recibe predicados: `sequence//3` reconoce una
lista de elementos separados.

<!-- ejemplo: capitulo-21/fechas.pl predicado: fecha//1 fechas//1 consulta: string_codes("24/09/2026", Cs), phrase(fecha(F), Cs). -->
```prolog
%!  fecha(?F)// is semidet.
%
%   El texto Dia/Mes/Anio de la fecha F = fecha(Anio, Mes, Dia). Al analizar,
%   admite ceros a la izquierda; al generar, no los escribe.
fecha(fecha(Anio, Mes, Dia)) -->
    integer(Dia),
    "/",
    integer(Mes),
    "/",
    integer(Anio),
    { fecha_valida(Anio, Mes, Dia) }.

%!  fechas(?Fs:list)// is semidet.
%
%   Una lista de fechas separadas por una coma y un espacio.
fechas(Fs) -->
    sequence(fecha, ", ", Fs).
```

```prolog
?- string_codes("24/09/2026", Cs), phrase(fecha(F), Cs).
Cs = [50, 52, 47, 48, 57, 47, 50, 48, 50|...],
F = fecha(2026, 9, 24).

?- phrase(fecha(fecha(2026, 9, 24)), Cs), atom_codes(A, Cs).
Cs = [50, 52, 47, 57, 47, 50, 48, 50, 54],
A = '24/9/2026'.

?- phrase(fecha(F), `29/2/2027`).
false.

?- phrase(fechas(Fs), `29/2/2028, 1/10/2026`).
Fs = [fecha(2028, 2, 29), fecha(2026, 10, 1)].
```

`integer//1` analiza y genera: la misma gramática lee la fecha y la escribe,
aunque al escribirla no pone el cero de «09». La validación, entre llaves,
rechaza el 29 de febrero de un año no bisiesto; `fecha_valida/3` y
`bisiesto/1` son predicados comunes, en el mismo archivo.

`sequence(Elemento, Separador, Lista)` reconoce cero o más elementos con el
separador entre ellos. Una vez que reconoce un separador, exige que siga un
elemento: un texto con un separador sobrante al final no se acepta. Con un
separador que puede ser vacío, como `blanks//0`, no conviene usarlo; el
proyecto escribe su propia recursión para separar palabras.

!!! example "Patrón 21 — Secuencia con separadores"
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

## 21.7 Recursión a izquierda

Una resta de varios números, como `10-3-2`, se describe naturalmente como «una
resta es una resta, un signo menos y un número». Escrita así, la gramática
empieza por llamarse a sí misma, sin consumir nada de la entrada:

<!-- ejemplo: capitulo-21/expresiones.pl predicado: resta_izquierda//1 consulta: phrase(resta(V), `10-3-2`). -->
```prolog
%!  resta_izquierda(-V:integer)// is nondet.
%
%   La gramática con recursión a izquierda: se llama a sí misma antes de
%   consumir nada, y la consulta no termina.
resta_izquierda(V) -->
    resta_izquierda(V0),
    "-",
    integer(N),
    { V is V0 - N }.
resta_izquierda(V) -->
    integer(V).
```

Prolog prueba los objetivos de izquierda a derecha, y el primer objetivo de
`resta_izquierda//1` es otra vez `resta_izquierda//1`, con la misma entrada: es
la rama infinita del [capítulo 5](../capitulo-05-como-responde-prolog/index.md). La consulta termina con un error de
límite de pila. Una gramática no puede tener **recursión a izquierda**: todo no
terminal recursivo debe consumir algo antes de llamarse.

Poner la recursión después del primer número resuelve la terminación, pero
cambia el significado:

<!-- ejemplo: capitulo-21/expresiones.pl predicado: resta_derecha//1 consulta: phrase(resta_derecha(V), `10-3-2`). -->
```prolog
%!  resta_derecha(-V:integer)// is semidet.
%
%   Sin recursión a izquierda, con la recursión después del primer número:
%   termina, pero agrupa a la derecha, y 10-3-2 vale 10-(3-2) = 9.
resta_derecha(V) -->
    integer(N),
    (   "-"
    ->  resta_derecha(Resto),
        { V is N - Resto }
    ;   { V = N }
    ).
```

```prolog
?- phrase(resta_derecha(V), `10-3-2`).
V = 9.
```

`resta_derecha//1` calcula `10-(3-2)`: agrupa a la derecha. La resta agrupa a
la izquierda, `(10-3)-2`, y vale 5. La solución es un argumento acumulador,
como en el [capítulo 8](../capitulo-08-aritmetica/index.md): el primer número es el valor inicial, y cada
«-N» se resta del acumulado.

<!-- ejemplo: capitulo-21/expresiones.pl predicado: resta//1 restas//2 consulta: phrase(resta(V), `10-3-2`). -->
```prolog
%!  resta(-V:integer)// is semidet.
%
%   Sin recursión a izquierda y con acumulador: el primer número es el valor
%   inicial, y cada "-N" se resta del acumulado. 10-3-2 vale (10-3)-2 = 5.
resta(V) -->
    integer(N),
    restas(N, V).

%!  restas(+Hasta:integer, -V:integer)// is det.
%
%   V es Hasta menos cada uno de los números que siguen, en orden.
restas(Hasta, V) -->
    "-",
    !,
    integer(N),
    { Ahora is Hasta - N },
    restas(Ahora, V).
restas(V, V) -->
    [].
```

```prolog
?- phrase(resta(V), `10-3-2`).
V = 5.
```

El corte en `restas//2`, después de reconocer el signo, dice que un signo
menos no puede ser otra cosa: no quedan alternativas pendientes, y `resta//1`
es determinista.

!!! example "Patrón 22 — Gramática con argumento acumulador"
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

## 21.8 Secuencias cualesquiera: `seq//1`

A veces interesa una parte del texto rodeada de cualquier cosa. `seq//1`
reconoce una secuencia cualquiera, y la entrega:

<!-- ejemplo: capitulo-21/gramatica.pl predicado: seq//1 menciona/2 consulta: menciona(ana, [juan, es, el, padre, de, ana]). -->
```prolog
%!  seq(?L:list)// is nondet.
%
%   Cualquier secuencia de elementos, L, en la entrada.
seq([]) --> [].
seq([E|Es]) -->
    [E],
    seq(Es).

%!  menciona(?Palabra, +Oracion:list) is nondet.
%
%   Palabra aparece en la lista Oracion: hay una secuencia antes y otra
%   después.
menciona(Palabra, Oracion) :-
    phrase(( seq(_), [Palabra], seq(_) ), Oracion).
```

```prolog
?- phrase((seq(Antes), [de], seq(Despues)), [juan, es, el, padre, de, ana]).
Antes = [juan, es, el, padre],
Despues = [ana] ;
false.
```

`phrase/2` recibe aquí un cuerpo compuesto, entre paréntesis. `seq//1` prueba
primero la secuencia vacía, después la de un elemento, y así: la primera
respuesta es la que encuentra el primer `de`. Para texto,
`library(dcg/basics)` tiene `string//1`, que hace lo mismo con códigos. El
curso *The Power of Prolog*, de Markus Triska, usa `seq//1` como herramienta
general.

## 21.9 Pushback

Una regla puede devolver elementos a la entrada: lo que se escribe después de
una coma, a la izquierda de `-->`, se agrega adelante de lo que sobra. Sirve
para **mirar** el próximo elemento sin consumirlo:

<!-- ejemplo: capitulo-21/gramatica.pl predicado: siguiente//1 palabra_o_numero//1 consulta: phrase(saludo, `hola`). -->
```prolog
%!  siguiente(-C)// is semidet.
%
%   C es el próximo elemento de la entrada, que no se consume: se devuelve a
%   la entrada con el pushback.
siguiente(C), [C] --> [C].

%!  palabra_o_numero(-T)// is semidet.
%
%   T es numero si el próximo código es un dígito, o palabra si no. Mira el
%   código con siguiente//1, sin consumirlo.
palabra_o_numero(T) -->
    siguiente(C),
    { code_type(C, digit) -> T = numero ; T = palabra }.
```

```prolog
?- phrase(palabra_o_numero(T), `42x`, Resto), atom_codes(A, Resto).
T = numero,
Resto = [52, 50, 120],
A = '42x'.
```

`siguiente//1` consume un código y lo devuelve: su traducción es
`siguiente(A, [A|B], [A|B])`. `palabra_o_numero//1` decide qué hay adelante,
y el resto queda intacto para la regla que siga. El pushback se usa poco; casi
siempre alcanza con ordenar bien las reglas, y una gramática que lo usa en
muchos lugares es difícil de leer.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C2 | las gramáticas funcionan en los dos sentidos: `oracion//1`, `fecha//1` y `comando//1` analizan y generan; las pruebas `generar`, `generar_fechas` y `generar_comando` lo verifican |
    | C4 | `resta//1` y `palabras//1` cortan después de reconocer lo que no admite alternativa, y sus pruebas no declaran `nondet`; `oracion//1`, que tiene alternativas reales, las declara |

## 21.10 El proyecto: un lenguaje de comandos

La versión de *Inscripciones* de este capítulo agrega `ejecutar/2`, que recibe
un comando en texto y lo ejecuta con las operaciones del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md). El análisis tiene dos etapas, cada una con su gramática.

La primera, `palabras//1`, trabaja sobre los códigos del texto: separa las
palabras y los números, y descarta los blancos.

<!-- ejemplo: capitulo-21/inscripciones.pl predicado: palabras//1 palabra//1 consulta: ejecutar("inscribir a 104 en sintaxis", Respuesta). -->
```prolog
%!  palabras(-Palabras:list)// is det.
%
%   Palabras son las palabras y los números del texto, separados por
%   blancos. Una palabra es un átomo; un número, un entero.
palabras([P|Ps]) -->
    blanks,
    palabra(P),
    !,
    palabras(Ps).
palabras([]) -->
    blanks.

%!  palabra(-P)// is semidet.
%
%   P es un entero, si el texto empieza con dígitos, o un átomo formado por
%   letras, dígitos y guiones bajos.
palabra(N) -->
    integer(N),
    !.
palabra(A) -->
    csym(A).
```

La segunda, `comando//1`, trabaja sobre la lista de palabras, y la relaciona
con un término:

<!-- ejemplo: capitulo-21/inscripciones.pl predicado: comando//1 legajo//1 materia_por_nombre//1 consulta: ejecutar("inscribir a 104 en sintaxis", Respuesta). -->
```prolog
%!  comando(?Comando)// is nondet.
%
%   La lista de palabras de Comando: inscribir(Legajo, Materia),
%   baja(Legajo, Materia), listar(Materia) o promedio(Legajo). Las materias
%   se escriben con su nombre, no con su código.
comando(inscribir(L, M)) -->
    [inscribir, a], legajo(L), [en], materia_por_nombre(M).
comando(baja(L, M)) -->
    [dar, de, baja, a], legajo(L), [en], materia_por_nombre(M).
comando(listar(M)) -->
    [listar], materia_por_nombre(M).
comando(promedio(L)) -->
    [promedio, de], legajo(L).

%!  legajo(?L)// is semidet.
%
%   El legajo de un alumno.
legajo(L) -->
    [L],
    { alumno(L, _, _, _) }.

%!  materia_por_nombre(?Codigo)// is semidet.
%
%   El nombre de la materia de código Codigo.
materia_por_nombre(Codigo) -->
    [Nombre],
    { materia(Codigo, Nombre, _) }.
```

`ejecutar/2` une las dos etapas y llama a `realizar/2`, que ejecuta el comando
y arma la respuesta:

<!-- ejemplo: capitulo-21/inscripciones.pl predicado: ejecutar/2 consulta: ejecutar("inscribir a 104 en sintaxis", Respuesta). -->
```prolog
%!  ejecutar(+Texto:string, -Respuesta) is det.
%
%   Analiza el comando Texto y lo ejecuta. Respuesta es el resultado:
%   aceptada o rechazada(Motivo) para una inscripción, baja o
%   rechazada(no_la_cursa) para una baja, inscriptos(Legajos) para un
%   listado, promedio(P) o sin_notas para un promedio, y no_entendido si el
%   texto no es un comando.
ejecutar(Texto, Respuesta) :-
    string_codes(Texto, Codigos),
    (   phrase(palabras(Palabras), Codigos),
        phrase(comando(Comando), Palabras)
    ->  realizar(Comando, Respuesta)
    ;   Respuesta = no_entendido
    ).
```

```prolog
?- ejecutar("inscribir a 104 en sintaxis", Respuesta).
Respuesta = aceptada.

?- ejecutar("listar analisis_1", Respuesta).
Respuesta = inscriptos([101, 102, 103, 105, 106]).

?- ejecutar("inscribir 104 sintaxis", Respuesta).
Respuesta = no_entendido.

?- phrase(comando(baja(105, am1)), Palabras).
Palabras = [dar, de, baja, a, 105, en, analisis_1].
```

Separar las dos etapas simplifica las dos. `palabras//1` no sabe nada de
comandos: solo sabe qué es un blanco. `comando//1` no sabe nada de códigos: sus
terminales son palabras, y por eso funciona en los dos sentidos —la última
consulta genera las palabras de un comando— y se puede probar con listas, sin
escribir texto. Los no terminales `legajo//1` y `materia_por_nombre//1`
consultan la base con `{}`: un comando con un alumno que no existe no se
entiende, y la materia se escribe con su nombre y se traduce a su código.

`inscripciones.plt` agrega once pruebas del lenguaje de comandos a las del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md); las que ejecutan comandos que modifican la base guardan y
restauran el estado.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta:
   `phrase(oracion(H), [ana, es, la, madre, de, luis]).` ·
   `phrase(saludo, "hola").` · `` phrase(fecha(F), `31/4/2026`). `` ·
   `` phrase(resta(V), `8-2-1`). ``
2. **(1)** Escribir `ab//0`: una o más `a` seguidas de la misma cantidad de
   `b`. Generar las listas de hasta seis elementos.
3. ★ **(2)** Traducir a mano la regla `saludo_a(N) --> "hola ", nombre(N).` a
   una cláusula con dos argumentos más, y comprobar que responde lo mismo que
   la regla.
4. **(2)** Escribir `frase//0` para oraciones como «el perro ladra» y «los
   perros ladran», con un argumento que haga concordar el sujeto y el verbo en
   número.
5. ★ **(2)** Escribir `oracion_verdadera//1`: como `oracion//1`, pero solo para
   los hechos de `padre/2` y `madre/2` de la base. ¿Qué genera la consulta más
   general?
6. **(2)** ¿Qué genera `phrase(ab, L)` con `L` libre? Escribir
   `ab_invertida//0`, con las dos reglas de `ab//0` en el orden inverso, y
   explicar por qué analiza las mismas listas pero no genera ninguna.
7. ★ **(2)** Escribir `preorden//1`, `simetrico//1` y `postorden//1`, que dan los
   nombres de los nodos de un árbol `nodo(Nombre, Izquierdo, Derecho)` o `nil`
   en los tres órdenes.
8. **(2)** Escribir `balanceado//0`: los paréntesis, corchetes y llaves del
   texto están bien anidados; los demás códigos se ignoran.
9. ★ **(3)** Escribir `expresion//1` para expresiones con enteros, `+`, `-`,
   `*` y `/`, sin paréntesis: `*` y `/` se evalúan antes, y los operadores de
   la misma precedencia, de izquierda a derecha.
10. **(2)** Escribir `fecha_larga//1` para fechas como «24 de septiembre de
    2026», en los dos sentidos.
11. **(2)** Escribir `enumeracion//1` para «ana», «ana y luis» y «ana, luis y
    eva».
12. ★ **(3)** Escribir `problema//1` para preguntas como «cuanto es 5 mas 13 por
    2»: las operaciones se aplican de izquierda a derecha, sin precedencia, y
    el resultado es 36.
13. **(2)** Escribir `lista_de_enteros//1` para listas como `[1, 2, 3]`, con
    `sequence//5`.
14. ★ **(2)** Agregar al lenguaje de comandos «vacantes de logica», que responde
    `vacantes(N)`.
15. **(2)** Escribir `texto_de(Comando, Texto)`, que genera el texto de un
    comando con la misma gramática, y una prueba de ida y vuelta.
16. **(3)** Cuando un texto no es un comando pero empieza con la palabra de uno,
    como «inscribir 104», `ejecutar/2` debe responder `uso(Ejemplo)`, con un
    comando correcto que empieza con esa palabra, generado por la gramática.

## Resumen

| | |
|---|---|
| `Cabeza --> Cuerpo` | una regla de gramática; se traduce a una cláusula con dos argumentos más |
| `nt//N` | un no terminal de N argumentos: el predicado `nt/(N+2)` |
| `phrase/2`, `phrase/3` | usar una gramática sobre una lista, completa o con resto |
| `[a, b]`, `"texto"` | terminales: elementos de la lista, o códigos del texto |
| `{ Objetivo }` | un objetivo común dentro de una regla |
| `dcg/basics` | `integer//1`, `blanks//0`, `csym//1`, `string//1`, `eos//0`, … |
| `sequence//3`, `sequence//5` | elementos con separadores, y con delimitadores |
| recursión a izquierda | no termina; se reescribe con un acumulador |
| `Cabeza, Pushback --> Cuerpo` | devuelve elementos a la entrada |
| **Patrones 20, 21, 22** | analizar y generar; secuencia con separadores; gramática con acumulador |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Ordenar los resultados de un informe con pares y `sort/4` | [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md) |
| Leer un archivo con una gramática: `phrase_from_file/2` | [capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) |
| El lenguaje de comandos desde la línea de comandos | [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) |
| Listas de diferencia, la técnica detrás de la traducción | [capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md) |
