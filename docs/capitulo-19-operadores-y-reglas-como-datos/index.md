# Capítulo 19 — Operadores y reglas como datos

Un programa profesional recibe a veces su conocimiento de personas que no
programan: las condiciones para inscribirse en una materia, los síntomas que
identifican una falla, los criterios de una evaluación. Ese conocimiento se
escribe mejor en una notación pensada para quien lo escribe, y el programa lo
lee como **datos**. Este capítulo presenta `op/3`, que permite definir esa
notación con operadores propios, y escribe el intérprete que prueba las reglas
así escritas y explica cómo llegó a cada conclusión.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- declarar operadores con `op/3` y leer un término escrito con ellos en su
  forma canónica;
- explicar la precedencia y la asociatividad, y elegirlas para que una
  notación se lea como se escribe;
- representar reglas como términos y escribir el intérprete que las prueba,
  con una cláusula por cada forma de condición;
- construir el árbol de una prueba y responder con él la pregunta «¿cómo?»;
- decidir cuándo las reglas conviene escribirlas como datos y cuándo como
  cláusulas de Prolog.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **0:50 h**.
    Resolver los 6 ejercicios marcados con ★: **1:41 h**.
    Resolver los 12 ejercicios del final: **3:41 h**.

## 19.1 Operadores propios

La [sección 4.6](../capitulo-04-terminos-y-unificacion/index.md#46-los-operadores-tambien-son-terminos) mostró que `2 + 3` es el término `+(2, 3)` escrito de
otra forma. `op/3` permite declarar operadores propios con la misma idea:

<!-- ejemplo: capitulo-19/operadores.pl fragmento: op(700, xfx, es_padre_de) .. H es_padre_de N. consulta: juan es_padre_de Hijo. -->
```prolog
:- op(700, xfx, es_padre_de).
:- op(700, xfx, es_abuelo_de).

% P es_padre_de H: P es el padre de H.
juan es_padre_de ana.
juan es_padre_de pedro.
pedro es_padre_de luis.
pedro es_padre_de eva.

%!  es_abuelo_de(?A, ?N) is nondet.
%
%   A es abuelo de N: el padre de uno de sus padres.
A es_abuelo_de N :-
    A es_padre_de H,
    H es_padre_de N.
```

```prolog
?- juan es_padre_de Hijo.
Hijo = ana ;
Hijo = pedro.

?- Quien es_abuelo_de eva.
Quien = juan ;
false.

?- X = (juan es_padre_de ana), write_canonical(X), nl.
es_padre_de(juan,ana)
X = (juan es_padre_de ana).

?- current_op(P, T, es_padre_de).
P = 700,
T = xfx.
```

`op(Precedencia, Tipo, Nombre)` declara que `Nombre` se puede escribir como
operador. `op/3` cambia la **sintaxis**, no el término: `juan es_padre_de ana`
es la estructura `es_padre_de(juan, ana)`, como lo muestra
`write_canonical/1`, que escribe todo término en la forma sin operadores. La
declaración vale para todo lo que se lee después de ella; por eso va al
principio del archivo, antes de las cláusulas que la usan. Hasta la cabeza de
una regla se puede escribir con el operador. `current_op/3` consulta las
declaraciones vigentes, las propias y las predefinidas.

## 19.2 Precedencia y asociatividad

**El tipo** indica la posición del operador —`xfx`, `xfy` y `yfx` son infijos;
`fx` y `fy`, prefijos; `xf` y `yf`, sufijos— y cómo se asocia. **La
precedencia**, entre 1 y 1200, indica qué operador queda como principal: en
`a + b * c`, `+` tiene 500 y `*` 400, y el término es `+(a, *(b, c))`; el
operador de mayor precedencia es el principal. En el tipo, `x` exige un
argumento de precedencia **menor** que la del operador, e `y` admite una
**menor o igual**. De ahí resulta la asociatividad:

```prolog
?- X = a - b - c, X = A - B.
X = a-b-c,
A = a-b,
B = c.

?- X = 2^3^2, X = A^B.
X = 2^3^2,
A = 2,
B = 3^2.
```

`-` es `yfx`: a la izquierda admite otro `-`, y `a - b - c` se lee
`(a - b) - c`. `^` es `xfy`: a la derecha admite otro `^`, y `2^3^2` se lee
`2^(3^2)`. `es_padre_de` es `xfx`: ninguno de sus lados admite otro
`es_padre_de`, y `a es_padre_de b es_padre_de c` es un error de sintaxis.

Los operadores predefinidos que este capítulo usa como referencia son cinco
precedencias; `current_op/3` da la lista completa:

| Precedencia | Tipo | Operadores |
|---|---|---|
| 1200 | `xfx` | `:-` `-->` |
| 1000 | `xfy` | `,` |
| 700 | `xfx` | `=` `\=` `==` `is` `<` `=<` `=:=` |
| 500 | `yfx` | `+` `-` |
| 400 | `yfx` | `*` `/` `//` `mod` |

La tabla explica dos decisiones de la sección anterior. `es_padre_de` se
declara en 700, la precedencia de `=` y de `is`: sus argumentos son términos
de datos, que tienen precedencia menor, y el operador queda por debajo de la
coma, que separa objetivos. Y una cláusula entera es un término: `:-` tiene
la precedencia máxima, y por eso cualquier operador propio cabe a los dos
lados.

!!! question "Actividad"
    Predecir la respuesta de `X = (a :- b, c), X = (H :- B).` y lo que
    escriben `write_canonical((p :- q ; r, s))` y `write_canonical(- 1 + 2)`.
    Ejecutarlas y explicar cada agrupamiento con la tabla.

Una declaración nueva puede cambiar un operador existente, y por eso se eligen
nombres propios. La coma no se puede redefinir:

```prolog
?- op(700, xfx, ',').
ERROR: No permission to modify operator `',''
```

Otros operadores predefinidos, como `->`, sí se pueden redefinir, con un
efecto que alcanza a todo el programa que se lee después. Los operadores de
Prolog no se redefinen; el [ejercicio 6](#ejercicios) muestra qué deja de
leerse cuando se hace.

## 19.3 Reglas como datos

Un **sistema experto** resuelve problemas de un dominio a partir de reglas que
escribe alguien que conoce ese dominio, y explica cómo llegó a cada conclusión.
Las reglas no se escriben como cláusulas de Prolog sino como **datos**, en un
lenguaje pensado para quien las escribe. Un programa pequeño, el **intérprete**,
las lee y las prueba.

El ejemplo identifica animales, un caso clásico de la bibliografía de sistemas
expertos. Las reglas se escriben con tres operadores propios, `si`, `entonces`
e `y`:

<!-- ejemplo: capitulo-19/experto_atras.pl fragmento: op(800, xfx, entonces) .. entonces avestruz). consulta: caso(1, Obs), identificar(Obs, Animal). -->
```prolog
:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(780, xfy, y).

% regla(Nombre, si Condiciones entonces Conclusion): las Condiciones, unidas
% con y, permiten concluir Conclusion.
regla(r1,  si tiene_pelo entonces mamifero).
regla(r2,  si da_leche entonces mamifero).
regla(r3,  si tiene_plumas entonces ave).
regla(r4,  si vuela y pone_huevos entonces ave).
regla(r5,  si mamifero y come_carne entonces carnivoro).
regla(r6,  si mamifero y tiene_cascos entonces ungulado).
regla(r7,  si carnivoro y color_leonado y manchas_oscuras entonces guepardo).
regla(r8,  si carnivoro y color_leonado y rayas_negras entonces tigre).
regla(r9,  si ungulado y cuello_largo y manchas_oscuras entonces jirafa).
regla(r10, si ungulado y rayas_negras entonces cebra).
regla(r11, si ave y no_vuela y nada entonces pinguino).
regla(r12, si ave y no_vuela y peso(P) y P > 50 entonces avestruz).
```

El archivo `experto_atras.pl` tiene además `hipotesis/1`, las conclusiones
finales que el sistema busca —los seis animales—, y `caso/2`, las
observaciones de cinco animales de ejemplo:

<!-- ejemplo: capitulo-19/experto_atras.pl predicado: caso/2 consulta: caso(1, Obs), identificar(Obs, Animal). -->
```prolog
% caso(N, Observaciones): las observaciones de un animal de ejemplo.
caso(1, [tiene_pelo, come_carne, color_leonado, manchas_oscuras]).
caso(2, [da_leche, tiene_cascos, rayas_negras]).
caso(3, [tiene_plumas, no_vuela, peso(90)]).
caso(4, [tiene_plumas, no_vuela, nada, peso(30)]).
caso(5, [tiene_pelo, tiene_cascos]).
```

Las precedencias se eligen para que la regla se lea como se escribe: `y`
(780) es menor que `si` (790), que es menor que `entonces` (800). Así,
`si a y b entonces c` es `entonces(si(y(a, b)), c)`: `entonces` es el
operador principal, y su primer argumento es el término `si` con toda la
conjunción adentro. Con `y` en una precedencia mayor que la de `si`, la misma
regla se leería `y(si(a), …)`, y el intérprete no encontraría el término que
espera. La regla r12 tiene una comparación entre sus condiciones: `P` se liga
con la observación `peso(P)` y se compara después. Las reglas son términos, y
nada más: hasta aquí el programa no puede probar ninguna.

## 19.4 El intérprete y la pregunta «¿cómo?»

El intérprete razona **hacia atrás**: para probar una conclusión busca una
regla que la tenga como consecuencia y prueba sus condiciones, que a su vez
pueden ser conclusiones de otras reglas, hasta llegar a las observaciones. Es
la misma estrategia con la que Prolog prueba sus propios objetivos, escrita
para otro lenguaje:

<!-- ejemplo: capitulo-19/experto_atras.pl predicado: prueba/3 identificar/2 consulta: caso(1, Obs), identificar(Obs, Animal). -->
```prolog
%!  prueba(+Meta, +Observaciones:list, -Arbol) is nondet.
%
%   Meta se prueba a partir de Observaciones y de las reglas; Arbol es la
%   prueba: observado(M), una comparación que se cumple, deducido(M, Regla,
%   ArbolDeLasCondiciones), o dos árboles unidos con y. Una respuesta por
%   cada prueba distinta.
prueba(A y B, Observaciones, ArbolA y ArbolB) :-
    prueba(A, Observaciones, ArbolA),
    prueba(B, Observaciones, ArbolB).
prueba(X > Y, _, X > Y) :-
    X > Y.
prueba(X < Y, _, X < Y) :-
    X < Y.
prueba(Meta, Observaciones, observado(Meta)) :-
    member(Meta, Observaciones).
prueba(Meta, Observaciones, deducido(Meta, Regla, Arbol)) :-
    regla(Regla, si Condiciones entonces Meta),
    prueba(Condiciones, Observaciones, Arbol).

%!  identificar(+Observaciones:list, -Animal) is nondet.
%
%   Animal es una de las hipótesis que se prueban a partir de Observaciones.
%   once/1 deja una sola prueba por animal: basta con que exista.
identificar(Observaciones, Animal) :-
    hipotesis(Animal),
    once(prueba(Animal, Observaciones, _)).
```

```prolog
?- caso(1, Obs), identificar(Obs, Animal).
Obs = [tiene_pelo, come_carne, color_leonado, manchas_oscuras],
Animal = guepardo ;
false.

?- caso(5, Obs), identificar(Obs, Animal).
false.
```

Cada cláusula de `prueba/3` trata una forma de condición: una conjunción, una
comparación, una observación, o una conclusión que se deduce con una regla. El
tercer argumento construye el **árbol de la prueba**: qué regla se usó para
cada conclusión y en qué condiciones se apoyó. Con ese árbol, el sistema
responde la pregunta «¿cómo?»:

<!-- ejemplo: capitulo-19/experto_atras.pl predicado: como/2 consulta: caso(1, Obs), como(Obs, guepardo). -->
```prolog
%!  como(+Observaciones:list, +Animal) is semidet.
%
%   Escribe cómo se llega a Animal a partir de Observaciones: una línea por
%   conclusión, observación o comparación, con las condiciones de cada regla
%   sangradas debajo de su conclusión. Falla si Animal no se prueba.
como(Observaciones, Animal) :-
    once(prueba(Animal, Observaciones, Arbol)),
    explicar(Arbol, 0).
```

```prolog
?- caso(1, Obs), como(Obs, guepardo).
guepardo: por r7
  carnivoro: por r5
    mamifero: por r1
      tiene_pelo: observado
    come_carne: observado
  color_leonado: observado
  manchas_oscuras: observado
Obs = [tiene_pelo, come_carne, color_leonado, manchas_oscuras].
```

`explicar/2` recorre el árbol con una cláusula por cada forma de nodo, como
`prueba/3`, y escribe cada conclusión sangrada según su profundidad.
Escribirlo es el [ejercicio 7](#ejercicios); `experto_atras.pl` contiene una
versión, que `como/2` usa.

!!! question "Actividad"
    Consultar `prueba(mamifero, [tiene_pelo, da_leche], Arbol).` y pedir todas
    las respuestas. Explicar por qué hay más de una, y por qué `identificar/2`
    llama a `prueba/3` dentro de `once/1`.

El intérprete evalúa las comparaciones con sus propias cláusulas, una por
operador, en lugar de ejecutar cualquier condición con `call/1`. La diferencia
importa cuando las reglas vienen de afuera del programa —un archivo, un
formulario—: con `call/1`, una regla podría ejecutar cualquier objetivo,
incluso uno que borra archivos. El sandbox de SWISH aplica el mismo criterio y
rechaza `call/1` sobre un objetivo que no puede conocer de antemano; esta
versión corre en SWISH.

!!! example "Patrón 16 — Intérprete de reglas"
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

El intérprete general de Prolog escrito en Prolog, que lee las cláusulas del
propio programa con `clause/2`, es el tema del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md). El
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md) escribe el sistema complementario, que razona hacia adelante: de
las observaciones a todas sus consecuencias.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | `prueba(+Meta, +Observaciones, -Arbol) is nondet` declara una respuesta por prueba distinta, y `motivos_de_rechazo/3` declara en su encabezado que el alumno y la materia deben existir |
    | C2 | `identificar/2` responde `false` cuando ninguna hipótesis se prueba (prueba `caso_5`), y `motivos_de_rechazo/3` responde `[]` cuando la inscripción se acepta (prueba `sin_motivos`) |
    | C4 | `identificar/2` da cada animal una sola vez gracias a `once/1` (prueba `una_respuesta_por_animal`); `motivos_de_rechazo/3` es `det` porque reúne las pruebas con `findall/3` |
    | C7 | 106 pruebas en los seis archivos del capítulo; `coinciden_con_inscripcion_posible` compara las reglas con `inscripcion_posible/3` para cada par alumno-materia |

## 19.5 El proyecto: los motivos de rechazo como reglas

`inscripcion_posible/3`, de la [sección 15.10](../capitulo-15-control/index.md#1510-el-proyecto-las-validaciones-de-una-inscripcion), decide con un condicional
encadenado y responde el **primer** motivo por el que se rechaza una
inscripción. La versión de *Inscripciones* de este capítulo escribe esos
motivos como reglas, en el lenguaje de la [sección 19.3](#193-reglas-como-datos), y reúne
**todos** los motivos de un rechazo:

<!-- ejemplo: capitulo-19/inscripciones.pl fragmento: regla(v1, .. regla(v4, si vacantes(0) entonces rechazada(sin_vacantes)). consulta: motivos_de_rechazo(102, am2, Motivos). -->
```prolog
regla(v1, si materia(M) y aprobada(M) entonces rechazada(ya_aprobada)).
regla(v2, si materia(M) y cursando(M) entonces rechazada(ya_la_cursa)).
regla(v3, si requisito(R) y no aprobada(R) entonces rechazada(falta(R))).
regla(v4, si vacantes(0) entonces rechazada(sin_vacantes)).
```

Las reglas hablan de la **situación** del alumno frente a la materia:
`materia(M)` es la materia pedida, `aprobada(M)` y `cursando(M)` son las
materias que el alumno aprobó y cursa, `requisito(R)` es cada correlativa de
la materia pedida, y `vacantes(N)` los lugares que quedan. `situacion/3`
traduce la base de datos a ese vocabulario: reúne con `findall/3` las
observaciones de `observacion/3`, un predicado con una cláusula por cada
forma. La regla v3 usa la negación `no`, un operador más, `op(770, fy, no)`,
y `prueba/3` es el de la [sección 19.4](#194-el-interprete-y-la-pregunta-como) con una cláusula para ella:

<!-- ejemplo: capitulo-19/inscripciones.pl fragmento: prueba(no Meta, Observaciones, no Meta) :- .. \+ prueba(Meta, Observaciones, _). consulta: motivos_de_rechazo(102, am2, Motivos). -->
```prolog
prueba(no Meta, Observaciones, no Meta) :-
    \+ prueba(Meta, Observaciones, _).
```

`no Meta` se cumple cuando `Meta` no se puede probar, en el sentido del
[capítulo 10](../capitulo-10-negacion-como-falla/index.md): la condición `no aprobada(R)` pregunta si `aprobada(R)` no está
entre las observaciones, con `R` ya ligada por `requisito(R)`. Sobre esas
reglas, un predicado reúne los motivos:

<!-- ejemplo: capitulo-19/inscripciones.pl predicado: motivos_de_rechazo/3 consulta: motivos_de_rechazo(102, am2, Motivos). -->
```prolog
%!  motivos_de_rechazo(+Legajo:integer, +Materia:atom, -Motivos:list) is det.
%
%   Motivos son todos los motivos por los que se rechaza la inscripción del
%   alumno Legajo en Materia, uno por cada prueba de rechazada(Motivo) con
%   las reglas; la lista vacía si se acepta. inscripcion_posible/3 da solo
%   el primero. Supone que el alumno y la materia existen: esas dos
%   condiciones las verifica inscripcion_posible/3 antes que cualquier regla.
motivos_de_rechazo(Legajo, Materia, Motivos) :-
    situacion(Legajo, Materia, Observaciones),
    findall(Motivo, prueba(rechazada(Motivo), Observaciones, _), Motivos).
```

```prolog
?- inscripcion_posible(102, am2, R).
R = rechazada(falta(am1)).

?- motivos_de_rechazo(102, am2, Motivos).
Motivos = [falta(am1), falta(alg)].

?- motivos_de_rechazo(101, log, Motivos).
Motivos = [ya_aprobada, sin_vacantes].
```

bruno no aprobó ninguno de los dos requisitos de análisis 2, y ana no puede
inscribirse en lógica por dos motivos independientes; `inscripcion_posible/3`
informa uno solo en cada caso. Las dos versiones deben coincidir: la prueba
`coinciden_con_inscripcion_posible` verifica, para cada alumno y cada materia,
que el primer motivo está entre los motivos y que sin motivos la inscripción
se acepta. Las seis pruebas nuevas de `inscripciones.plt` cubren
`situacion/3`, `motivos_de_rechazo/3` y el árbol de una prueba con `no`.

!!! question "Actividad"
    Consultar `situacion(103, am2, Obs).` y decidir, con la lista y las cuatro
    reglas a la vista, qué motivos da `motivos_de_rechazo(103, am2, M)`.
    Comprobarlo.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(2)** Con las declaraciones `:- op(300, xfx, [son, es_un]).`,
   `:- op(300, fx, gusta_de).`, `:- op(200, xfy, y).` y
   `:- op(100, fy, famoso).`, decir cuáles de estas expresiones son términos
   válidos y cuál es su forma canónica: `X es_un mago` ·
   `ana y luis y eva son amigos` · `ana es_un maga y gusta_de ajedrez` ·
   `merlin es_un famoso mago`. Comprobarlo con `write_canonical/1`.
2. **(2)** Con `:- op(800, xfx, es).`, `:- op(400, yfx, de).` y el hecho
   `el_auto de la_hermana de ana es rojo.`, predecir las respuestas de
   `X es rojo.`, `X de Y es rojo.` y `el_auto de X es rojo.` ¿Qué cambia si `de`
   se declara `xfy`?
3. **(2)** Declarar los operadores `no`, `y`, `o` e `implica` para escribir
   fórmulas de la lógica proposicional, y escribir `valor(Formula, V)`, que da
   el valor de verdad, `v` o `f`, de una fórmula sin variables.
4. ★ **(2)** Agregar al sistema experto la disyunción `o`: la declaración del
   operador, con una precedencia que permita escribir
   `si a y b o c entonces d`, y las cláusulas del intérprete. Unir las reglas
   r1 y r2 en una sola.
5. **(3)** Hacer que el intérprete reciba la base de reglas como argumento, un
   predicado de dos argumentos, y escribir una segunda base: por qué un auto
   no arranca. Usar el mismo intérprete con las dos bases.
6. ★ **(2)** Predecir qué ocurre después de `op(700, xfx, ->)` al leer
   `( X > 0 -> t ; e )` y `( a, b -> c ; d )`, y comprobarlo con
   `term_string/2` y `write_canonical/1`. Restaurar la declaración,
   `op(1050, xfy, ->)`, y explicar por qué los operadores de Prolog no se
   redefinen.
7. ★ **(2)** Escribir `explicar(Arbol, Sangria)`, que escribe el árbol de una
   prueba como lo muestra la [sección 19.4](#194-el-interprete-y-la-pregunta-como): una cláusula por cada forma
   de nodo, y las condiciones de cada regla dos columnas más adentro que su
   conclusión. `~t~*|` en `format/2` completa con espacios hasta la columna
   que recibe como argumento.
8. ★ **(2)** Agregar al intérprete de los animales la negación `no` de la
   [sección 19.5](#195-el-proyecto-los-motivos-de-rechazo-como-reglas), y reescribir r11 y r12 con `no vuela` en lugar de la
   observación `no_vuela`. ¿Qué observaciones necesita ahora el caso 3? ¿Qué
   supone el sistema sobre un animal del que nadie observó si vuela?
9. ★ **(1)** Predecir la forma canónica de `a = b = c`, `1 + 2 * 3 ^ 2` y
   `- 1 + 2`, y comprobarlo. Con `current_op/3`, listar los operadores de
   precedencia 700 y decir qué tienen en común sus tipos.
10. **(2)** Escribir `por_que(Legajo, Materia)` para el proyecto: escribe,
    con el `explicar/2` del ejercicio 7, la prueba de cada motivo de rechazo.
    Agregar a `explicar/2` la cláusula para los nodos `no`.
11. **(2)** Agregar al proyecto la regla `v5`, que concluye `aceptada` cuando
    ningún rechazo se puede probar, y `se_acepta(Legajo, Materia)`, que la
    usa. Explicar qué pregunta `no rechazada(_)` con la variable libre, y por
    qué la regla v5 no se aplica a sí misma.
12. **(2)** Declarar un operador `requiere` para escribir las correlativas del
    proyecto como `am2 requiere am1 y alg.`, y redefinir `correlativa/2` a
    partir de esos hechos, de modo que `correlativa(am2, R)` responda `am1` y
    `alg`, una por vez.

## Resumen

| | |
|---|---|
| `op/3` | declara un operador: precedencia, tipo y nombre; vale para lo que se lee después |
| `current_op/3` | consulta los operadores declarados, propios y predefinidos |
| precedencia | de 1 a 1200; el operador de mayor precedencia es el principal del término |
| tipo | `xfx`, `xfy`, `yfx`, `fx`, `fy`, `xf`, `yf`: la posición, y con `y` el lado que admite la misma precedencia |
| `write_canonical/1` | escribe un término sin operadores, para ver su estructura |
| `term_string/2` | lee un término de una cadena con los operadores vigentes, o lo escribe en ella (en las soluciones) |
| reglas como datos | términos con operadores propios, que un intérprete lee y prueba |
| `prueba/3` | una cláusula por cada forma de condición; el tercer argumento es el árbol de la prueba |
| `no` en el intérprete | una condición se cumple cuando no se puede probar, con `\+` |
| **[Patrón 16](../patrones.md#16-interprete-de-reglas)** | intérprete de reglas |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| El sistema experto que razona hacia adelante, con reglas como hechos | [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md) |
| `meta_predicate` y los módulos, para un intérprete que recibe la base de reglas | [capítulo 24](../capitulo-24-modulos-y-organizacion/index.md) |
| Un diálogo que pregunta las observaciones que faltan | [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) |
| El intérprete de Prolog en Prolog, con `clause/2` | [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) |
| La búsqueda en un espacio de estados, con el árbol como camino | [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) |
