# Capítulo 15 — Control

En el [capítulo 9](../capitulo-09-backtracking-y-corte/index.md) el corte era la única herramienta para decidir entre casos, y
tenía un costo: un corte rojo hace que el programa responda de acuerdo con el
orden de sus cláusulas y no con lo que ellas afirman. En el trabajo diario, la
mayor parte de esas decisiones se escriben con otra construcción, el
**condicional**, que dice explícitamente qué condición elige cada caso.

Este capítulo trata del control de la búsqueda: cuándo un predicado debe dar
una respuesta y cuándo varias, cómo se evita dejar alternativas pendientes que
nadie va a usar, cómo se recorren las respuestas de un objetivo por sus efectos,
y qué se pierde cuando el control reemplaza a la lógica. Termina con un
condicional que no pierde nada de la lógica, `if_/3`, y con las validaciones de
una inscripción en el proyecto.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- escribir `( Condicion -> Entonces ; Si_no )` y explicar qué alternativas poda;
- reescribir con el condicional los cortes del [capítulo 9](../capitulo-09-backtracking-y-corte/index.md), obteniendo
  predicados estables y sin alternativas pendientes;
- usar `once/1` e `ignore/1`, y ubicarlos en el borde de un programa;
- escribir un bucle por falla con `between/3` o `repeat`, y reconocer cuándo no
  corresponde;
- distinguir un predicado puro de uno impuro, y usar `if_/3` cuando se requiere
  un condicional que conserve la pureza.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:08 h**.
    Resolver los 7 ejercicios marcados con ★: **2:11 h**.
    Resolver los 17 ejercicios del final: **5:10 h**.

## 15.1 `;` en el cuerpo

La disyunción `;` se puede escribir dentro del cuerpo de una cláusula: `( A ; B )`
se cumple si se cumple `A` o si se cumple `B`, y al volver atrás prueba las dos.
Equivale a escribir dos cláusulas, una con `A` y otra con `B`, y conviene usarla
cuando esas cláusulas repetirían todo lo demás.

La disposición del curso escribe la disyunción con los paréntesis y el `;`
alineados al comienzo de la línea, de modo que cada alternativa se lea como un
bloque:

```prolog
    (   A
    ;   B
    )
```

Una disyunción larga en el cuerpo suele indicar que el predicado tiene dos
relaciones mezcladas. Si las alternativas no comparten nada más que la cabeza,
dos cláusulas expresan la disyunción sin repetir el resto del cuerpo.

## 15.2 `->` y lo que poda

El **condicional** `( Condicion -> Entonces ; Si_no )` prueba `Condicion`. Si se
cumple, ejecuta `Entonces`; si falla, ejecuta `Si_no`. Tiene dos podas, y las dos
son las del corte:

- de `Condicion` se usa **solo la primera** respuesta;
- elegida una rama, la otra se descarta.

```prolog
?- ( member(X, [a, b]) -> Y = X ; Y = ninguno ).
X = Y, Y = a.

?- ( member(X, []) -> Y = X ; Y = ninguno ).
Y = ninguno.
```

La primera consulta responde una vez: `member(X, [a, b])` tiene dos respuestas,
pero el condicional usa la primera y no vuelve atrás sobre la condición. En
cambio, las alternativas de `Entonces` y de `Si_no` se conservan: el condicional
poda la condición, no lo que viene después.

Sin la rama `Si_no`, `( Condicion -> Entonces )` falla cuando la condición falla:

```prolog
?- ( member(X, []) -> Y = X ).
false.
```

Existe una variante, `*->`, que no poda la condición: con `( member(X, [a, b])
*-> Y = X ; Y = ninguno )` se obtienen las dos respuestas, y `Si_no` se ejecuta
solo si la condición no tiene ninguna. Se usa poco; el condicional habitual es
`->`.

!!! question "Actividad"
    Predecir cuántas respuestas tiene cada consulta y comprobarlo:
    `( member(X, [a, b]) -> member(Y, [1, 2]) ; true ).` ·
    `( member(X, [a, b]), X \== a -> Y = X ; Y = ninguno ).`
    ¿Qué alternativas conserva cada una, y por qué?

## 15.3 Los casos del capítulo 9, reescritos

La `categoria/2` de la [sección 9.4](../capitulo-09-backtracking-y-corte/index.md#94-el-uso-mas-frecuente-casos-que-no-se-superponen) usaba el corte para elegir la primera
categoría que corresponde, y la [sección 9.5](../capitulo-09-backtracking-y-corte/index.md#95-corte-verde-y-corte-rojo) mostró su defecto:
`categoria(sofia, adulto)` responde `true.` Con el condicional, cada categoría
queda asociada a su condición, y la salida se liga dentro de la rama elegida:

<!-- ejemplo: capitulo-15/condicional.pl predicado: categoria/2 consulta: categoria(sofia, C). -->
```prolog
%!  categoria(?P, ?C) is nondet.
%!  categoria(+P, ?C) is semidet.
%
%   C es la categoría de P según su edad: bebe, chico o adulto. Con P ligada
%   hay una respuesta, o ninguna si P no tiene edad registrada.
categoria(P, C) :-
    edad(P, A),
    (   A < 4
    ->  C = bebe
    ;   A < 13
    ->  C = chico
    ;   C = adulto
    ).
```

```prolog
?- categoria(sofia, C).
C = bebe.

?- categoria(sofia, adulto).
false.
```

La segunda consulta responde lo que corresponde. La salida `C` se liga
**después** de que la condición eligió la rama: es el [Patrón 3](../patrones.md#3-salida-despues-del-compromiso) del
[capítulo 14](../capitulo-14-estilo-y-documentacion/index.md), que el condicional aplica sin que haga falta escribirlo. Y el
predicado no deja alternativas pendientes: la respuesta termina en punto.

El mismo cambio corrige el `sacar/3` que el [capítulo 14](../capitulo-14-estilo-y-documentacion/index.md) registraba con una
alternativa pendiente:

<!-- ejemplo: capitulo-15/condicional.pl predicado: sacar/3 consulta: sacar(a, [a, b, a], R). -->
```prolog
%!  sacar(+X, +L:list, -R:list) is semidet.
%
%   R es L sin la primera aparición de X; falla si X no está en L. El
%   condicional elige una de las dos ramas y no deja la otra pendiente.
sacar(X, [Y|Ys], R) :-
    (   X == Y
    ->  R = Ys
    ;   R = [Y|R0],
        sacar(X, Ys, R0)
    ).
```

```prolog
?- sacar(a, [a, b, a], R).
R = [b, a].
```

Las dos cláusulas del [capítulo 7](../capitulo-07-listas/index.md) se convierten en una sola, con las dos ramas del
condicional; la condición `X == Y` elige la rama, y la otra no queda pendiente.

!!! example "Patrón 5 — Casos con condicional"
    **Problema.** Un predicado distingue casos que no se superponen, y la
    versión con corte depende del orden de las cláusulas y no es estable.

    **Versión ingenua.** Una cláusula por caso, con un corte después de la
    condición y la salida en la cabeza, como `categoria/2` del [capítulo 9](../capitulo-09-backtracking-y-corte/index.md).

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
    argumento: una cláusula por forma, seleccionada por unificación ([Patrón 4](../patrones.md#4-datos-limpios)),
    evita la condición explícita y aprovecha la indexación.

!!! question "Actividad"
    Reescribir con el condicional la `clasificar/2` de la solución 14 del
    [capítulo 9](../capitulo-09-backtracking-y-corte/soluciones.md#14). La versión con corte responde `true.` a `clasificar(-3,
    positivo).`; comprobar que la versión nueva responde `false.`

## 15.4 `once/1` e `ignore/1`

`once(Objetivo)` ejecuta `Objetivo` y conserva solo su primera respuesta. Es
`( Objetivo -> true )`, y reemplaza el corte al final de una cláusula que busca
un solo resultado:

<!-- ejemplo: capitulo-15/condicional.pl predicado: primer_mayor_de_edad/1 consulta: primer_mayor_de_edad(P). -->
```prolog
%!  primer_mayor_de_edad(-P) is semidet.
%
%   P es la primera persona mayor de edad de la base, y solo ella.
primer_mayor_de_edad(P) :-
    once(( edad(P, A),
           A >= 18 )).
```

```prolog
?- primer_mayor_de_edad(P).
P = juan.
```

`memberchk/2`, de `library(lists)`, es el caso más usado de la misma idea: se
cumple si el elemento está en la lista, y a lo sumo una vez. `sin_repetidos/2`
la usa como condición, y con eso deja de tener la alternativa pendiente que
la [solución 9 del capítulo 14](../capitulo-14-estilo-y-documentacion/soluciones.md#9) le señalaba:

<!-- ejemplo: capitulo-15/condicional.pl predicado: sin_repetidos/2 sin_los_vistos/3 consulta: sin_repetidos([a, b, a, c, b], R). -->
```prolog
%!  sin_repetidos(++L:list, -R:list) is det.
%
%   R es L sin repetidos; conserva la primera aparición de cada elemento.
sin_repetidos(L, R) :-
    sin_los_vistos(L, [], R).

%!  sin_los_vistos(++L:list, +Vistos:list, -R:list) is det.
%
%   R es L sin los elementos de Vistos y sin repetidos. memberchk/2 se cumple
%   a lo sumo una vez: es member/2 seguido de un corte.
sin_los_vistos([], _, []).
sin_los_vistos([X|Resto], Vistos, R) :-
    (   memberchk(X, Vistos)
    ->  R = R0
    ;   R = [X|R0]
    ),
    sin_los_vistos(Resto, [X|Vistos], R0).
```

`ignore(Objetivo)` ejecuta `Objetivo` y se cumple aunque falle. Es
`( Objetivo -> true ; true )`, y sirve para un paso opcional, casi siempre un
efecto como escribir algo que puede no estar disponible:

<!-- ejemplo: capitulo-15/condicional.pl predicado: presentar/1 consulta: presentar(ana). -->
```prolog
%!  presentar(+P) is det.
%
%   Escribe el nombre de P y, si se conoce, su edad. ignore/1 ejecuta el
%   objetivo opcional y se cumple aunque ese objetivo falle.
presentar(P) :-
    format("~w", [P]),
    ignore(( edad(P, A),
             format(" (~d años)", [A]) )),
    nl.
```

```prolog
?- presentar(ana).
ana (41 años)
true.

?- presentar(marta).
marta
true.
```

!!! example "Patrón 6 — Una respuesta en el borde"
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

## 15.5 `\+`: lo que ya se sabe y lo que falta

El [capítulo 10](../capitulo-10-negacion-como-falla/index.md) presentó `\+` y sus usos para obtener una respuesta
([sección 10.7](../capitulo-10-negacion-como-falla/index.md#107-obtener-una-respuesta-por-negacion)), y la [sección 10.8](../capitulo-10-negacion-como-falla/index.md#108-prescindir-de) lo escribió a mano con corte y
`fail`. Con el condicional, esa definición es más breve: `\+ G` es
`( G -> fail ; true )`.

`\+` no es el único predicado predefinido que da nombre a una técnica que antes
se escribía a mano con corte, `fail` y alternativas. `\+ G` es el corte y falla
de la [sección 10.8](../capitulo-10-negacion-como-falla/index.md#108-prescindir-de); `once/1`, el corte después de la primera respuesta;
`ignore/1`, el paso opcional que se cumple de todos modos; y `forall/2`, que
presenta el [capítulo 17](../capitulo-17-todas-las-soluciones/index.md), el bucle por falla de la [sección 15.7](#157-bucles-por-falla) aplicado a
comprobar una condición en cada respuesta. El artículo de Brna y otros que
cita la introducción de los [patrones](../patrones.md) describe este proceso
como una ampliación del lenguaje: una técnica procedural queda oculta dentro de
una construcción declarativa, y quien lee `\+ G` ya no necesita ver el corte ni
la falla. Al programar se usa el predicado, cuyo nombre dice la intención; la
combinación que reemplaza conviene conocerla igual, y el ejercicio 2 la
escribe.

Lo que el condicional agrega es la posibilidad de usar `\+` como **condición**
de una rama. La validación de una inscripción, en la [sección 15.10](#1510-el-proyecto-las-validaciones-de-una-inscripcion), elige
su primera rama cuando `\+ alumno(Legajo, _, _, _)` se cumple, es decir, cuando
el legajo no existe. La regla de ubicación de la [sección 10.4](../capitulo-10-negacion-como-falla/index.md#104-donde-ubicar) sigue
vigente: las variables del objetivo negado deben llegar con valor, y por eso el
legajo es un argumento `+`.

## 15.6 Puntos de elección

Un **punto de elección** es una alternativa que Prolog guarda para volver a ella
si se le pide otra respuesta. El toplevel lo muestra: una respuesta que termina
en punto no dejó ninguno; una que espera `;` dejó al menos uno, aunque al
pedirlo resulte que no había otra respuesta (el `false.` del [capítulo 5](../capitulo-05-como-responde-prolog/index.md)).

Un punto de elección que nadie va a usar tiene dos costos. Ocupa memoria mientras
el programa sigue, y hace que el predicado no cumpla lo que su encabezado `det`
o `semidet` promete, que es lo que el criterio C4 verifica y lo que plunit
advierte con *Test succeeded with choicepoint*. Las pruebas de
`condicional.plt` no declaran `nondet`: con el condicional, `categoria/2` y
`sacar/3` terminan sin alternativas, y plunit no advierte nada.

Qué alternativas quedan pendientes depende de la **implementación**, no solo
del programa. SWI-Prolog examina el primer argumento de una llamada, y a veces
otros, para descartar de antemano las cláusulas que no pueden unificar; lo que
logra descartar cambia de una versión a otra. `abuelo(juan, luis)`, del
[capítulo 1](../capitulo-01-la-primera-hora/index.md), responde `true ;` y después `false.` con SWI-Prolog 9.2.9, que es la
versión del curso, y `true.` con la 10. Por eso el curso fija una versión, y por
eso la determinación de un predicado se asegura con el código —el condicional,
el corte en el lugar correcto— y no se deja librada a la indexación. El
[capítulo 16](../capitulo-16-rendimiento/index.md) explica cómo funciona la indexación y cómo aprovecharla.

## 15.7 Bucles por falla

Un **bucle por falla** recorre todas las respuestas de un objetivo por sus
efectos, sin reunirlas: ejecuta el efecto para una respuesta y falla, lo que
obliga a Prolog a buscar la siguiente. La alternativa final `; true` hace que el
predicado se cumpla cuando las respuestas se agotan:

<!-- ejemplo: capitulo-15/bucles.pl predicado: listar_edades/0 tabla_de_multiplicar/1 consulta: listar_edades. -->
```prolog
%!  listar_edades is det.
%
%   Escribe una línea por cada persona de la base, con su edad.
listar_edades :-
    (   edad(P, A),
        format("~w: ~d~n", [P, A]),
        fail
    ;   true
    ).

%!  tabla_de_multiplicar(+N:integer) is det.
%
%   Escribe la tabla de multiplicar de N, del 1 al 10.
tabla_de_multiplicar(N) :-
    (   between(1, 10, I),
        P is N * I,
        format("~d x ~d = ~d~n", [N, I, P]),
        fail
    ;   true
    ).
```

```prolog
?- listar_edades.
juan: 68
ana: 41
luis: 12
true.
```

`between/3` convierte el bucle en uno numérico: `tabla_de_multiplicar/1`
recorre los enteros de 1 a 10 sin escribir ninguna recursión.

`repeat` produce infinitas respuestas, todas iguales: cada vez que un objetivo
posterior falla, la ejecución vuelve a `repeat` y el ciclo recomienza. Un corte
lo termina. Es la forma de un programa que lee órdenes hasta recibir una de
salida:

<!-- ejemplo: capitulo-15/menu.pl predicado: menu/1 ejecutar/1 consulta: open_string("edad(ana). salir.", In), menu(In). -->
```prolog
%!  menu(+In) is det.
%
%   Lee órdenes del stream In y ejecuta cada una, hasta leer salir o llegar
%   al final del stream.
menu(In) :-
    repeat,
    read(In, Orden),
    ejecutar(Orden),
    (   Orden == salir
    ;   Orden == end_of_file
    ),
    !.

%!  ejecutar(+Orden) is det.
%
%   Ejecuta una orden del menú. Una orden desconocida se informa y el menú
%   sigue.
ejecutar(edad(P)) :-
    !,
    (   edad(P, A)
    ->  format("~w tiene ~d años~n", [P, A])
    ;   format("~w no está en la base~n", [P])
    ).
ejecutar(salir) :-
    !,
    format("Fin~n").
ejecutar(end_of_file) :-
    !.
ejecutar(Orden) :-
    format("Orden desconocida: ~q~n", [Orden]).
```

`menu/1` lee de un stream que recibe como argumento. Con `menu(user_input)` lee
del teclado; en las pruebas, de un texto abierto con `open_string/2`:
`open_string(Texto, In)` da en `In` un stream que entrega `Texto` como si
alguien lo escribiera en el teclado. Es la forma de probar un programa
interactivo sin escribir nada a mano:

```prolog
?- open_string("edad(ana). edad(sofia). salir.", In), menu(In).
ana tiene 41 años
sofia no está en la base
Fin
In = <stream>(...).
```

!!! example "Patrón 7 — Bucle por falla"
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
    [capítulo 17](../capitulo-17-todas-las-soluciones/index.md), que presenta además `forall/2`, la forma declarativa de este mismo
    recorrido.

## 15.8 Pureza

Un predicado es **puro** si su significado no depende del orden en que se
evalúan sus objetivos ni de qué argumentos llegan instanciados: se puede leer
como una relación, y responde de acuerdo con esa lectura en todos los modos. Los
predicados de la parte I sin corte ni negación son puros.

Las construcciones de este capítulo y del [capítulo 9](../capitulo-09-backtracking-y-corte/index.md) no lo son. El corte, el
condicional, `\+`, `==` y los efectos de entrada y salida preguntan por el
**estado actual** de la ejecución, y su respuesta cambia según qué esté ligado
en ese momento. `sacar/3` lo muestra con la consulta más general:

```prolog
?- sacar(X, [a, b], R).
false.
```

La relación tiene dos respuestas —sacar `a` deja `[b]`, sacar `b` deja `[a]`—, y
`sacar/3` no da ninguna. La condición `X == Y` pregunta si `X` **ya es** `Y`, y
con `X` libre nunca lo es; el predicado recorre toda la lista sin elegir la rama
de sacar y falla. Es la situación que el criterio C2 prohíbe: un `false.` que
se puede leer como «no hay ninguna», cuando las hay. El encabezado lo declara
con `+X`, y esa restricción es aceptable mientras esté escrita.

La pureza no es obligatoria: un programa real tiene efectos, y el criterio C6
pide que queden en el borde. Pero un predicado puro se puede usar en más modos,
se prueba con la consulta más general, y su corrección se razona leyendo sus
cláusulas. Las construcciones impuras se reservan para donde hacen falta, y su
restricción se declara en el encabezado.

## 15.9 `if_/3` y `library(reif)`: el condicional puro

`library(reif)` ofrece un condicional que no pierde la pureza. No viene con
SWI-Prolog: es un paquete (*pack*) que se instala una vez desde el toplevel,
con `pack_install(reif)`, y se carga con `:- use_module(library(reif)).`

`if_(Condicion, Entonces, Si_no)` recibe una condición **reificada**: en lugar
de cumplirse o fallar, la condición decide si es verdadera o falsa, y cuando no
lo puede decidir —porque le faltan valores— considera los dos casos. La
condición más usada es `(=)/3`: `X = Y` dentro de `if_/3` es verdadera si `X` e
`Y` son iguales, falsa si son distintos, y con `X` libre deja las dos
posibilidades abiertas, la segunda con la restricción `dif(X, Y)`.

<!-- ejemplo: capitulo-15/puro.pl predicado: sacar_puro/3 iguales_a/3 consulta: sacar_puro(X, [a, b], R). -->
```prolog
%!  sacar_puro(?X, +L:list, ?R:list) is nondet.
%!  sacar_puro(+X, +L:list, ?R:list) is semidet.
%
%   R es L sin la primera aparición de X. Con X ligado se comporta como
%   sacar/3, sin dejar alternativas; con X libre enumera cada elemento que se
%   puede sacar.
sacar_puro(X, [Y|Ys], R) :-
    if_(X = Y,
        R = Ys,
        ( R = [Y|R0],
          sacar_puro(X, Ys, R0) )).

%!  iguales_a(?X, +L:list, ?Iguales:list) is nondet.
%
%   Iguales son los elementos de L que son iguales a X. tfilter/3 conserva los
%   elementos para los que la condición reificada es verdadera.
iguales_a(X, L, Iguales) :-
    tfilter(=(X), L, Iguales).
```

```prolog
?- sacar_puro(X, [a, b], R).
X = a,
R = [b] ;
X = b,
R = [a] ;
false.

?- iguales_a(a, [a, Y], L).
Y = a,
L = [a, a] ;
L = [a],
dif(Y, a).
```

`sacar_puro/3` da las dos respuestas que `sacar/3` no daba, y con `X` ligado se
comporta como aquel, sin dejar alternativas. `tfilter/3` filtra una lista con
una condición reificada; en `iguales_a(a, [a, Y], L)`, con un elemento sin
valor, responde los dos casos: que `Y` sea `a`, y que no lo sea. `dif(Y, a)` es
una restricción: afirma que `Y` debe ser distinto de `a` cuando reciba un valor.
El [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md) presenta `dif/2` y las demás restricciones.

| Consulta | `sacar/3` (con `->`) | `sacar_puro/3` (con `if_/3`) |
|---|---|---|
| `X` ligado | una respuesta, sin alternativas | una respuesta, sin alternativas |
| `X` libre | `false.` | una respuesta por cada elemento |
| encabezado | `sacar(+X, +L, -R)` | `sacar_puro(?X, +L, ?R)` |

El costo de `if_/3` es el de una biblioteca externa: se instala aparte, no es
parte de ningún estándar, y es algo más lenta que el condicional. Conviene
cuando el predicado se va a usar con argumentos libres, o cuando la consulta más
general debe responder completo; para una validación con todos los argumentos
ligados, como la de la sección siguiente, alcanza con `->`.

## 15.10 El proyecto: las validaciones de una inscripción

La versión de *Inscripciones* de este capítulo decide si un alumno se puede
inscribir en una materia. Las condiciones se evalúan en orden, y el resultado
dice cuál falló: la primera condición que falla es el motivo del rechazo. Se
agrega un dato, las vacantes de cada materia:

```prolog
% vacantes(Materia, N): quedan N lugares en la materia.
vacantes(am1, 30).
vacantes(alg, 30).
vacantes(log, 0).
...
```

<!-- ejemplo: capitulo-15/inscripciones.pl predicado: inscripcion_posible/3 puede_inscribirse/2 consulta: inscripcion_posible(104, ssl, Resultado). -->
```prolog
%!  inscripcion_posible(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Resultado es aceptada si el alumno Legajo se puede inscribir en Materia,
%   o rechazada(Motivo) con el primer motivo que lo impide: alumno_inexistente,
%   materia_inexistente, ya_aprobada, ya_la_cursa, falta(Requisito) o
%   sin_vacantes. Una materia desaprobada se puede volver a cursar.
inscripcion_posible(Legajo, Materia, Resultado) :-
    (   \+ alumno(Legajo, _, _, _)
    ->  Resultado = rechazada(alumno_inexistente)
    ;   \+ materia(Materia, _, _)
    ->  Resultado = rechazada(materia_inexistente)
    ;   aprobada(Legajo, Materia, _)
    ->  Resultado = rechazada(ya_aprobada)
    ;   cursa(Legajo, Materia)
    ->  Resultado = rechazada(ya_la_cursa)
    ;   correlativa(Materia, Requisito),
        \+ aprobada(Legajo, Requisito, _)
    ->  Resultado = rechazada(falta(Requisito))
    ;   vacantes(Materia, 0)
    ->  Resultado = rechazada(sin_vacantes)
    ;   Resultado = aceptada
    ).

%!  puede_inscribirse(+Legajo:integer, +Materia:atom) is semidet.
%
%   El alumno Legajo se puede inscribir en Materia.
puede_inscribirse(Legajo, Materia) :-
    inscripcion_posible(Legajo, Materia, aceptada).
```

```prolog
?- inscripcion_posible(104, ssl, R).
R = aceptada.

?- inscripcion_posible(102, am2, R).
R = rechazada(falta(am1)).

?- inscripcion_posible(105, log, R).
R = rechazada(sin_vacantes).
```

El condicional encadenado es el [Patrón 5](../patrones.md#5-casos-con-condicional) con más ramas. Cada condición supone
que las anteriores fallaron: la de los requisitos solo se evalúa si el alumno
existe, la materia existe y el alumno no la aprobó ni la cursa. La condición de
los requisitos busca una correlativa no aprobada, y como la condición de un `->`
usa solo su primera respuesta, el motivo es el primer requisito que falta.

El resultado es un término limpio —`aceptada` o `rechazada(Motivo)`—, y no un
`true` o `false`: quien llama puede informar por qué se rechazó la inscripción.
`puede_inscribirse/2` es el predicado para quien solo necesita la respuesta.

!!! success "Criterios de calidad"
    | Criterio | En `inscripcion_posible/3` |
    |---|---|
    | C1 | `(+Legajo, +Materia, -Resultado) is det`; una prueba por cada resultado posible |
    | C2 | con el legajo libre, `\+ alumno(Legajo, …)` falla y las ramas siguientes preguntan por algún alumno: la respuesta no se refiere a nadie en particular. Es una restricción declarada con `+Legajo`, que el [capítulo 25](../capitulo-25-errores-y-excepciones/index.md) convierte en un error |
    | C3 | `inscripcion_posible(102, am2, aceptada)` falla: el resultado se liga dentro de cada rama, después de la condición |
    | C4 | las once pruebas del predicado no declaran `nondet`, y plunit no advierte ninguna alternativa pendiente |
    | C7 | 22 pruebas en `inscripciones.plt`: las del [capítulo 14](../capitulo-14-estilo-y-documentacion/index.md) y un caso por cada resultado |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta:
   `( 1 < 2 -> X = si ; X = no ).` · `( member(X, [1, 2, 3]), X > 1 -> Y = X ; Y = 0 ).` ·
   `( fail -> X = a ).` · `( true ; X = b ).`
2. **(1)** Escribir `\+/1`, `once/1` e `ignore/1` con el condicional, con los
   nombres `no/1`, `una_vez/1` e `ignorar/1`. Los tres reciben un objetivo: usar
   `call/1` para ejecutarlo.
3. ★ **(2)** Reescribir con el condicional `maximo/3` del [capítulo 14](../capitulo-14-estilo-y-documentacion/index.md) y
   `descuento/2` de la solución 9 del [capítulo 9](../capitulo-09-backtracking-y-corte/soluciones.md#9). Verificar que las dos
   versiones nuevas son estables.
4. **(2)** Escribir `valor_absoluto(X, A)` con el condicional, con su
   encabezado y una prueba por modo.
5. ★ **(2)** La siguiente definición pretende clasificar un número como `par` o
   `impar`. Predecir qué responde con 4 y con 3, explicar el resultado
   siguiendo la ejecución de la disyunción, y corregirla con el condicional:

    ```prolog
    paridad(N, P) :-
        (   0 =:= N mod 2
        ;   P = impar
        ),
        P = par.
    ```

6. **(2)** Escribir `primera_aprobada(Legajo, Materia)` sobre la versión de
   *Inscripciones* de este capítulo, que da solo la primera materia aprobada.
   ¿Dónde va el `once/1`, y por qué no dentro de `aprobada/3`?
7. ★ **(2)** Escribir `listar_aprobadas(Legajo)`, que escribe una línea por
   cada materia aprobada del alumno con su nota, con un bucle por falla.
8. **(2)** Agregar al menú de `menu.pl` la orden `todas`, que lista todas las
   edades con `listar_edades/0` del ejemplo de bucles.
9. ★ **(2)** Escribir `contar_hasta(N)`, que escribe los números de 1 a `N`,
   primero con un bucle por falla y después con una recursión. ¿Cuál de las
   dos permite escribir `suma_hasta(N, S)` con el mismo esquema?
10. **(3)** Escribir `sin_repetidos/2` con `if_/3` y `memberd_t/3` de
    `library(reif)`, y comparar su consulta más general con la de
    `condicional.pl`.
11. ★ **(2)** La condición de los requisitos en `inscripcion_posible/3` usa
    solo la primera correlativa no aprobada. Escribir
    `requisitos_faltantes(Legajo, Materia, Faltan)` que dé la lista de **todas**
    las que faltan, con una recursión sobre una lista de requisitos. ¿Qué dato
    habría que repetir, y qué capítulo evita esa repetición?
12. **(2)** Agregar a `inscripcion_posible/3` un motivo nuevo: un alumno que
    ingresó en 2025 no puede cursar materias de tercer año. ¿En qué lugar de la
    cadena va la condición, y cómo cambia el resultado de las pruebas?
13. **(1)** ¿Cuáles de estas consultas dejan un punto de elección en SWI-Prolog
    9.2.9? Predecir y comprobar: `categoria(luis, C).` · `sacar(b, [a, b], R).` ·
    `member(a, [a, b]).` · `memberchk(a, [a, b]).`
14. ★ **(3)** ¿Qué hace el menú con la orden `edad(X).`, con `X` libre?
    Explicar la respuesta con la regla de ubicación de la
    [sección 10.4](../capitulo-10-negacion-como-falla/index.md#104-donde-ubicar). Corregir `ejecutar/1` para que informe «orden incompleta», y
    escribir la prueba que lo verifica.
15. **(3)** Escribir `categoria_pura/2` con `if_/3` y una condición reificada
    sobre números, y explicar por qué `library(reif)` no alcanza para las
    comparaciones aritméticas y qué capítulo las resuelve.
16. **(1)** El predicado siguiente, sobre los datos de *Inscripciones* de este
    capítulo, tiene una disyunción en el cuerpo:

    ```prolog
    %!  tomada(?Legajo:integer, ?Materia:atom, ?Anio:integer) is nondet.
    %
    %   El alumno Legajo cursa Materia o ya la aprobó, y Materia es del año Anio.
    tomada(Legajo, Materia, Anio) :-
        (   cursa(Legajo, Materia)
        ;   aprobada(Legajo, Materia, _)
        ),
        materia(Materia, _, Anio).
    ```

    Reescribirlo sin `;`, como dos cláusulas de un predicado `tomada_en_dos/3`,
    como indica la [sección 15.1](#151-en-el-cuerpo), e indicar qué objetivo
    queda repetido. Escribir una prueba que verifique que las dos versiones dan
    las mismas respuestas en el mismo orden. Después, determinar si el orden se
    conservaría con `materia(Materia, _, Anio)` escrito antes de la disyunción.
17. **(2)** El predicado siguiente es un bucle por falla que pretende escribir
    los términos que lee de un stream:

    ```prolog
    %!  eco(+In) is det.
    %
    %   Escribe, uno por línea, los términos que lee del stream In.
    eco(In) :-
        repeat,
        read(In, Termino),
        format("~w~n", [Termino]),
        fail.
    ```

    Predecir qué ocurre con `open_string("a. b.", In), eco(In)`. Comprobarlo
    con `call_with_inference_limit(Objetivo, 200, R)`, que ejecuta `Objetivo`
    con un máximo de 200 inferencias y, si las agota, lo detiene y liga `R` con
    `inference_limit_exceeded` (la [sección 26.8](../capitulo-26-pruebas-y-depuracion/index.md#268-el-proyecto-la-bateria-completa) lo usa en las pruebas).
    Corregir `eco/1` según el [Patrón 7](../patrones.md#7-bucle-por-falla).

## Resumen

| | |
|---|---|
| `( A ; B )` | disyunción en el cuerpo: se cumple si se cumple alguna de las dos |
| `( C -> T ; E )` | si `C` se cumple, `T`; si no, `E`. Usa la primera respuesta de `C` y descarta la rama no elegida |
| `( C -> T )` | sin rama `E`: falla si `C` falla |
| `*->` | como `->`, pero conserva todas las respuestas de la condición |
| `once/1`, `memberchk/2` | la primera respuesta de un objetivo; la pertenencia, una vez |
| `ignore/1` | ejecuta un objetivo opcional y se cumple aunque falle |
| punto de elección | alternativa pendiente; depende de la implementación y de la versión |
| bucle por falla | `( G, Efecto, fail ; true )`; `repeat, …, !` |
| `open_string/2` | un stream que lee un texto como si viniera del teclado: la entrada de las pruebas |
| predicado puro | responde según su lectura lógica en todos los modos |
| `if_/3`, `(=)/3`, `tfilter/3` | condicional puro de `library(reif)` |
| **Patrones 5, 6, 7** | casos con condicional; una respuesta en el borde; bucle por falla |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Indexación: cómo SWI-Prolog descarta cláusulas y qué alternativas deja | [capítulo 16](../capitulo-16-rendimiento/index.md) |
| `forall/2` y reunir respuestas en una lista | [capítulo 17](../capitulo-17-todas-las-soluciones/index.md) |
| `call/N`: objetivos como argumentos | [capítulo 18](../capitulo-18-orden-superior/index.md) |
| `dif/2` y las restricciones aritméticas | [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md) |
| Validar los argumentos con errores en lugar de fallas | [capítulo 25](../capitulo-25-errores-y-excepciones/index.md) |
| Programas de línea de comandos que leen órdenes | [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) |
