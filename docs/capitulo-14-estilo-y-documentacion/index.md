# Capítulo 14 — Estilo y documentación

Un predicado se escribe una vez y se llama muchas: desde otros predicados, desde
las pruebas, desde programas que escribe otra persona. Quien lo llama no
debería tener que leer su código para saber qué argumentos pasarle, qué va a
responder y qué ocurre si lo llama de otra manera. Esa información es el
**contrato** del predicado, y este capítulo trata de cómo escribirlo y cómo
verificar que el código lo cumple.

La parte I ya usa los elementos básicos: el encabezado PlDoc con los signos
`+`, `-` y `?` y la cantidad de respuestas ([sección 2.8](../capitulo-02-hechos-consultas-y-variables/index.md#28-como-se-documenta-el-uso-de-un-predicado)). Este capítulo
completa el vocabulario, agrega las convenciones de nombres y de disposición,
muestra cómo SWI-Prolog verifica la determinación declarada, y presenta los
siete criterios de calidad con los que se revisa todo el código de la parte II.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- nombrar predicados y variables, y disponer las cláusulas, según las
  convenciones del curso;
- escribir un encabezado PlDoc completo: los ocho signos de modo, los seis
  valores de determinación y los tipos;
- verificar lo que un encabezado promete, con una prueba por modo y con
  `det/1`;
- escribir predicados estables y elegir una representación de datos limpia;
- revisar un predicado con los siete criterios de calidad.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **0:41 h**.
    Resolver los 6 ejercicios marcados con ★: **1:53 h**.
    Resolver los 15 ejercicios del final: **4:45 h**.

## 14.1 Nombres

**Los predicados nombran relaciones.** Un predicado es una relación entre sus
argumentos, y su nombre dice qué relación es: `padre/2`, `aprobada/3`,
`correlativa/2`. Un nombre como `calcular_aprobadas` describe una acción, y
sugiere un sentido de uso que la relación no tiene: `aprobada/3` también
comprueba, y también enumera.

**El nombre se lee con los argumentos en orden.** `padre(P, H)` se lee «P es
padre de H», y `correlativa(Materia, Requisito)` se lee «Materia tiene como
correlativa a Requisito». La descripción del encabezado escribe esa lectura, y
el orden de los argumentos no debería necesitar ninguna otra explicación.

**Minúsculas con guion bajo** para predicados y átomos (`nota_minima`,
`bases_de_datos`); **palabras con mayúscula inicial** para las variables
(`Legajo`, `Materia`, `Resto`). Una variable se nombra por su papel, no por su
tipo: `Requisito` y no `M2`.

**Las variables que no se usan** se escriben `_`. Cuando conviene documentar qué
representa esa posición, se escribe un nombre que empieza con guion bajo:
`_Estado` no produce la advertencia de variable única, y dice qué se ignora. El
guion bajo inicial declara que la variable aparece **una** vez; si aparece dos,
SWI-Prolog lo advierte:

```prolog
repite(L) :-
    inscripcion(L, _M, _M).
```

```text
Warning:    Singleton-marked variable appears more than once: _M
```

## 14.2 Disposición

Las convenciones de disposición del curso son las de todos los ejemplos desde el
[capítulo 1](../capitulo-01-la-primera-hora/index.md):

- la cabeza en una línea, y cada objetivo del cuerpo en su propia línea, con
  una sangría de cuatro espacios;
- las cláusulas de un predicado, juntas y en el orden en que se prueban, con una
  línea en blanco entre un predicado y el siguiente;
- el encabezado inmediatamente antes de la primera cláusula;
- ninguna línea de más de 80 caracteres;
- los hechos de una tabla, alineados en columnas cuando eso facilita la
  lectura, como los de `inscripciones.pl`.

La segunda convención tiene una verificación automática: SWI-Prolog advierte
cuando las cláusulas de un predicado están separadas, como mostró la
[sección 13.1](../capitulo-13-el-entorno-de-trabajo/index.md#131-el-toplevel-como-herramienta). Si la separación es intencional, se la declara con
`:- discontiguous padre/2.` antes de la primera cláusula, y la advertencia
desaparece.

## 14.3 El encabezado completo

El encabezado de la [sección 2.8](../capitulo-02-hechos-consultas-y-variables/index.md#28-como-se-documenta-el-uso-de-un-predicado) tiene tres partes: los modos, la cantidad de
respuestas y la descripción. Las tres admiten más precisión que la que la parte
I necesitaba.

**Los modos.** SWI-Prolog usa ocho signos:

| Signo | El argumento… | Ejemplo |
|---|---|---|
| `++` | llega completamente instanciado: el término y todo lo que contiene | la lista de números de `suma_lista/2` |
| `+` | llega instanciado en su forma principal; puede contener variables | la lista de `largo/2`, que no examina los elementos |
| `-` | es de salida; puede llegar ligado, y entonces se comprueba | la suma de `suma_lista/2` |
| `--` | debe llegar libre; ligado, el predicado no cumple lo que promete | el múltiplo de `primer_multiplo/3` |
| `?` | puede llegar ligado o libre | los argumentos de `padre/2` |
| `@` | no se instancia más de lo que llega | los argumentos de `mismo_termino/2` |
| `:` | es un objetivo o un predicado que se va a llamar | el primer argumento de `once/1` |
| `!` | es un término que el predicado modifica | se usa en la parte III |

La diferencia entre `-` y `--` es la del [capítulo 9](../capitulo-09-backtracking-y-corte/index.md). Un argumento `-` puede
llegar ligado, y el predicado comprueba el valor. Un argumento `--` no: el
predicado usa un corte rojo, y con el argumento ligado el corte deja de
proteger la respuesta. Los comentarios del [capítulo 9](../capitulo-09-backtracking-y-corte/index.md) lo decían en palabras
—«N debe llegar libre»—; `--` lo dice en el modo.

**La determinación.** A las cuatro de la parte I se agregan dos:

| | Respuestas |
|---|---|
| `det` | exactamente una |
| `semidet` | una o ninguna |
| `nondet` | cualquier cantidad, incluida ninguna |
| `multi` | una o más |
| `failure` | ninguna: siempre falla |
| `erroneous` | ninguna: siempre produce un error |

`failure` y `erroneous` son raros en un programa, pero describen predicados de
la biblioteca: `fail/0` es `failure`, y `throw/1` es `erroneous`.

**Los tipos.** Cada argumento puede llevar su tipo después de dos puntos:
`+L:list`, `-N:integer`, `++L:list(number)`. El tipo documenta; SWI-Prolog no lo
verifica a partir del encabezado. La verificación de tipos en la ejecución es
tema del [capítulo 25](../capitulo-25-errores-y-excepciones/index.md).

Los tres predicados de `encabezados.pl` usan los signos que la parte I no
necesitaba:

<!-- ejemplo: capitulo-14/encabezados.pl predicado: suma_lista/2 primer_multiplo/3 mismo_termino/2 consulta: suma_lista([3, 1, 4], S). -->
```prolog
%!  suma_lista(++L:list(number), -S:number) is det.
%
%   S es la suma de los números de L. L debe llegar completa: la lista y
%   todos sus elementos, porque is/2 no puede sumar una variable.
suma_lista([], 0).
suma_lista([X|Resto], S) :-
    suma_lista(Resto, Faltan),
    S is Faltan + X.

%!  primer_multiplo(+De:integer, +Desde:integer, --N:integer) is semidet.
%
%   N es el primer múltiplo de De a partir de Desde; falla si no hay ninguno
%   hasta 200. N debe llegar libre: con N ligado, el corte no tiene nada que
%   podar, y el predicado aceptaría un múltiplo que no es el primero.
primer_multiplo(De, Desde, N) :-
    between(Desde, 200, N),
    0 =:= N mod De,
    !.

%!  mismo_termino(@A, @B) is semidet.
%
%   A y B son el mismo término, sin ligar ninguna variable de ninguno de los
%   dos.
mismo_termino(A, B) :-
    A == B.
```

`suma_lista/2` declara `++L` porque no le alcanza con que la lista esté: sus
elementos también deben tener valor, porque `is/2` no puede sumar una variable.
`largo/2` del [capítulo 7](../capitulo-07-listas/index.md), en cambio, cuenta los elementos sin mirarlos, y le
alcanza con `+`.

```prolog
?- suma_lista([3, 1, 4], S).
S = 8.

?- suma_lista([3, X], S).
ERROR: Arguments are not sufficiently instantiated
```

## 14.4 Lo que el encabezado promete

Un encabezado es una afirmación sobre el código, y como toda afirmación puede
ser falsa: el código cambia y el comentario queda. Hay dos formas de
verificarlo.

**Una prueba por modo.** Cada línea de modo del encabezado es un uso que el
predicado admite, y cada uno requiere su prueba. `suma_lista(++L, -S) is det`
declara un modo; `pegar/3` del [capítulo 7](../capitulo-07-listas/index.md) declara dos. Las pruebas de
`encabezados.plt` siguen esa regla, y agregan las que documentan qué ocurre
fuera de los modos declarados:

```prolog
% suma_lista(++L, -S) is det: una respuesta, sin alternativas pendientes.
% Una prueba sin nondet advierte si quedan puntos de elección.
test(suma_de_tres, true(S == 8)) :-
    suma_lista([3, 1, 4], S).

% Fuera del modo: un elemento sin valor produce un error, no una respuesta.
test(suma_con_un_elemento_libre, [error(instantiation_error)]) :-
    suma_lista([3, _], _).
```

La primera prueba verifica también la determinación. plunit advierte cuando
una prueba que no se declaró `nondet` termina con alternativas pendientes:

```text
Warning:     test v:esta: Test succeeded with choicepoint
```

!!! example "Patrón 2 — Encabezado que se cumple"
    **Problema.** El encabezado promete un modo o una cantidad de respuestas
    que el código ya no cumple, y nadie lo nota hasta que alguien lo usa así.

    **Versión ingenua.** Escribir el encabezado una vez, al crear el
    predicado, y probar solo el uso más frecuente.

    **Patrón.** Una prueba por cada línea de modo del encabezado, sin `nondet`
    cuando el modo es `det`; y una prueba por cada uso fuera de los modos que el
    texto menciona, con el resultado que corresponde: `[fail]`, `error(...)`, o
    la respuesta equivocada que el signo advierte. Un modo `semidet` cuya
    implementación deja una alternativa pendiente lleva `[nondet]` en la prueba,
    con un comentario que lo explica, hasta que se la quite (capítulos [15](../capitulo-15-control/index.md) y
    [16](../capitulo-16-rendimiento/index.md)).

    **Cuándo no usarlo.** En los hechos: una tabla de hechos no tiene modos
    que verificar, y se prueba con pruebas de coherencia de los datos, como
    las de la [sección 13.7](../capitulo-13-el-entorno-de-trabajo/index.md#137-el-proyecto-inscripciones).

**`det/1` y `$`.** SWI-Prolog puede verificar la determinación en cada llamada.
La directiva `:- det(suma_lista/2).` declara que el predicado es `det`: si una
llamada falla o termina con alternativas pendientes, se produce un error.
Aplicada al `ultimo/2` del [capítulo 7](../capitulo-07-listas/index.md), que deja una alternativa pendiente:

```text
ERROR: Deterministic procedure ultimo/2 succeeded with a choicepoint
```

`det/1` verifica la **implementación**, que es más estricta que el conteo
lógico de la parte I: `ultimo/2` tiene una sola respuesta, pero la forma en que
Prolog la encuentra deja una alternativa, y para `det/1` eso es un error. Por
eso se usa donde la implementación es determinista, como en
`suma_lista/2`, que distingue la lista vacía de la no vacía por el primer
argumento. Dentro de una cláusula, `$` actúa como el corte y además exige que
lo que sigue sea determinista; `$(Objetivo)` exige lo mismo de un objetivo. El
[capítulo 16](../capitulo-16-rendimiento/index.md) vuelve sobre las alternativas pendientes y su costo.

## 14.5 Orden de los argumentos y estabilidad

**El orden.** La convención de la biblioteca de SWI-Prolog es escribir primero
los argumentos de entrada y después los de salida: `atom_length(+Atom, -Length)`,
`suma_lista(++L, -S)`. En una relación genuina, donde cualquier argumento puede
ser de entrada, el orden es el de la lectura del nombre, como en `padre/2`.

**La estabilidad.** Un predicado es **estable** (*steadfast*) si responde lo
mismo con un argumento de salida ligado que con ese argumento libre y comparado
después. `mal_maximo/3` no lo es:

<!-- ejemplo: capitulo-14/estilo.pl predicado: mal_maximo/3 maximo/3 consulta: maximo(3, 1, M). -->
```prolog
%!  mal_maximo(+X, +Y, -M) is det.
%
%   M pretende ser el mayor de X e Y. Es incorrecta: mal_maximo(3, 1, 1) se
%   cumple, porque la salida se unifica en la cabeza, antes del corte.
mal_maximo(X, Y, X) :-
    X >= Y,
    !.
mal_maximo(_, Y, Y).

%!  maximo(+X, +Y, -M) is det.
%!  maximo(+X, +Y, +M) is semidet.
%
%   M es el mayor de X e Y. La salida se liga después del corte, de modo que
%   el resultado es el mismo con M ligado o libre.
maximo(X, Y, M) :-
    X >= Y,
    !,
    M = X.
maximo(_, Y, Y).
```

```prolog
?- maximo(3, 1, M).
M = 3.

?- mal_maximo(3, 1, 1).
true.

?- maximo(3, 1, 1).
false.
```

`mal_maximo(3, 1, 1)` responde `true.` La primera cláusula no se elige, porque
su cabeza exige que el tercer argumento sea igual al primero; el corte, que
estaba ahí para descartar la segunda cláusula, nunca se ejecuta; y la segunda
cláusula responde que 1 es el mayor. El defecto es la ubicación de la salida:
la cabeza la compromete antes de que la condición y el corte decidan cuál es el
caso. `maximo/3` la liga **después** del corte, con `M = X`, y entonces el
tercer argumento no influye en qué cláusula se elige.

!!! example "Patrón 3 — Salida después del compromiso"
    **Problema.** Un predicado con corte responde algo falso cuando el
    argumento de salida llega ligado.

    **Versión ingenua.** Escribir el valor de salida en la cabeza de la
    cláusula que lo calcula: `mal_maximo(X, Y, X) :- X >= Y, !.`

    **Patrón.** La cabeza usa una variable nueva para la salida, y la cláusula
    la liga después del corte: `maximo(X, Y, M) :- X >= Y, !, M = X.` La
    plantilla 14 del [capítulo 9](../capitulo-09-backtracking-y-corte/index.md) lo pedía en palabras («el argumento de salida
    debe llegar libre»); con este patrón deja de ser una restricción.

    **Cuándo no usarlo.** En los predicados sin corte, cuyas cláusulas se
    distinguen por unificación: `aprobada/3` y `padre/2` ya son estables.

## 14.6 Representación de los datos

En la versión del [capítulo 13](../capitulo-13-el-entorno-de-trabajo/index.md), el tercer argumento de `inscripcion/3` es un
número o el átomo `null`. Es la traducción directa de la tabla SQL del
[capítulo 42](../capitulo-42-prolog-y-sql/index.md), y obliga a toda regla que trabaje con notas a preguntar qué
tipo de valor recibió. La regla de aprobación que usa ese capítulo lo muestra:

```prolog
aprobada(L, M, N) :-
    inscripcion(L, M, N), integer(N), N >= 6.
```

`integer/1` es una prueba de tipo: tiene éxito cuando su argumento es un número
entero y falla con cualquier otro término, incluida una variable libre. En esta
regla, `integer(N)` no dice nada sobre aprobar: está para excluir `null` antes
de la comparación, que con un átomo produciría un error. Una representación así se
llama *por defecto* (*defaulty*): un caso tiene forma de valor y el otro es un
valor especial, y cada regla debe distinguirlos con una prueba de tipo.

La alternativa es una representación **limpia**, en la que cada caso tiene su
propio functor: `cursando` y `nota(N)`. Las reglas seleccionan el caso por
unificación, que es el mecanismo propio de Prolog, y no necesitan preguntar el
tipo:

<!-- ejemplo: capitulo-14/inscripciones.pl predicado: aprobada/3 cursa/2 consulta: aprobada(101, Materia, Nota). -->
```prolog
%!  aprobada(?Legajo:integer, ?Materia:atom, ?Nota:integer) is nondet.
%
%   El alumno Legajo aprobó Materia con Nota. Con Legajo y Materia ligados
%   hay una respuesta o ninguna; con Nota ligada, además, se comprueba la
%   nota.
aprobada(Legajo, Materia, Nota) :-
    inscripcion(Legajo, Materia, nota(Nota)),
    nota_minima(Minima),
    Nota >= Minima.

%!  cursa(?Legajo:integer, ?Materia:atom) is nondet.
%
%   El alumno Legajo está cursando Materia, todavía sin nota.
cursa(Legajo, Materia) :-
    inscripcion(Legajo, Materia, cursando).
```

`inscripcion(Legajo, Materia, nota(Nota))` no unifica con las inscripciones en
curso, y `cursa/2` no unifica con las que tienen nota: cada regla ve solo su
caso. La representación limpia tiene además una ventaja de rendimiento, que el
[capítulo 16](../capitulo-16-rendimiento/index.md) explica: el functor del argumento permite a SWI-Prolog elegir
las cláusulas sin probarlas una por una.

!!! example "Patrón 4 — Datos limpios"
    **Problema.** Un valor tiene varios casos, y un caso se representa con un
    valor especial —`null`, `0`, `[]`, `ninguno`— del mismo tipo que los
    demás.

    **Versión ingenua.** Distinguir los casos en cada regla con pruebas de
    tipo o comparaciones: `integer(N)`, `N \== null`.

    **Patrón.** Un functor por caso —`cursando`, `nota(N)`—, y reglas que
    seleccionan su caso por unificación en la cabeza o en el primer objetivo.

    **Cuándo no usarlo.** Cuando los datos llegan de afuera con otra forma, como
    una tabla SQL o un archivo CSV: la conversión a la forma limpia se hace una
    sola vez, en el borde del programa ([capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md)).

## 14.7 Documentación generada

Los encabezados `%!` no son solo comentarios: PlDoc, el sistema de
documentación de SWI-Prolog, los lee y genera páginas con el índice de los
predicados de cada archivo. Hay dos formas de verlas, las dos solo en una
instalación local:

- `doc_server(4000)` inicia un servidor de documentación; `doc_browser/0` abre
  el navegador en él, con la documentación de todos los archivos cargados.
- `doc_save/2` escribe la documentación en archivos HTML. PlDoc debe estar
  activo **antes** de cargar el programa, porque recoge los comentarios
  durante la carga:

```prolog
?- use_module(library(pldoc)), use_module(library(doc_files)).
?- consult(recorrer).
?- doc_save('.', [doc_root(html)]).
```

El resultado es un directorio `html/` con una página por archivo cargado, y una
página índice que los reúne. Por ejemplo, la documentación de los ejemplos de
este capítulo —`estilo.pl`, `encabezados.pl` e `inscripciones.pl`— se puede ver
en [este enlace](pldoc/index.html){ target=_blank }: cada predicado aparece con
su primera línea, con los modos, los tipos y la determinación, y con su
descripción. Los hechos no aparecen: sus comentarios de una línea empiezan con
`%` y no con `%!`, y PlDoc solo lee los segundos.

La descripción se escribe en el formato de PlDoc, que admite, entre otras
cosas, nombres de predicados como enlaces (`esta_en/2` en la descripción se
convierte en un enlace a su documentación) y listas con guiones.

## 14.8 Criterios de calidad

Las pruebas verifican que el código hace lo que se espera; los criterios de
calidad verifican que el predicado se puede usar **sin leer su código**. Son
siete, y se aplican a todo el código de la parte II. Cada capítulo posterior
indica en un recuadro cuáles ejercita y cómo se comprueba cada uno. La
[página de patrones](../patrones.md#criterios-de-calidad) los reúne.

| | Criterio | Qué se comprueba |
|---|---|---|
| C1 | Interfaz declarada | cada predicado tiene su encabezado, con los modos y la determinación que la prueba por modo confirma ([Patrón 2](../patrones.md#2-encabezado-que-se-cumple)) |
| C2 | Consulta más general | con todos los argumentos libres, el predicado responde, produce un error de instanciación, o el encabezado declara la restricción; nunca responde algo incorrecto sin aviso |
| C3 | Estabilidad | el resultado es el mismo con un argumento de salida ligado o libre ([Patrón 3](../patrones.md#3-salida-despues-del-compromiso)) |
| C4 | Sin puntos de elección sobrantes | un predicado `det` no deja alternativas pendientes: plunit lo advierte, y `det/1` lo verifica en cada llamada |
| C5 | Error, no falla silenciosa | los tipos incorrectos y los datos faltantes producen un error, no un `false.` que se confunda con «no»; hasta el [capítulo 25](../capitulo-25-errores-y-excepciones/index.md), el encabezado declara la restricción |
| C6 | Núcleo puro, bordes impuros | la lógica no escribe, no lee y no modifica la base de datos; esas tareas quedan en unos pocos predicados de borde |
| C7 | Probado | cada predicado tiene sus pruebas: una por modo, y las de los casos límite |

C2 y C5 miran el mismo problema desde dos lados. C2 pregunta qué hace el
predicado cuando recibe menos información que la esperada; C5, qué hace cuando
recibe información equivocada. En los dos casos, la respuesta aceptable es una
respuesta correcta o un error explícito, nunca un `false.` que el que llama
interprete como «no».

## 14.9 El proyecto: el modelo de datos

La versión de *Inscripciones* de este capítulo cambia la representación de las
notas ([sección 14.6](#146-representacion-de-los-datos)) y agrega las dos primeras reglas, `aprobada/3` y `cursa/2`,
con sus encabezados completos y una prueba por modo. La nota mínima para aprobar
queda en un hecho propio, `nota_minima/1`, en lugar de un `6` escrito dentro de
la regla: es un dato del reglamento, y si cambia, cambia en un solo lugar.

```prolog
?- aprobada(101, Materia, Nota).
Materia = am1,
Nota = 8 ;
Materia = alg,
Nota = 9 ;
Materia = log,
Nota = 10 ;
Materia = am2,
Nota = 7 ;
false.

?- cursa(Legajo, Materia).
Legajo = 101,
Materia = pp ;
Legajo = 103,
Materia = am2 ;
Legajo = 105,
Materia = am1.
```

!!! success "Criterios de calidad"
    | Criterio | En `aprobada/3` y `cursa/2` |
    |---|---|
    | C1 | Encabezados con modos, tipos y determinación; `inscripciones.plt` tiene una prueba por modo de `aprobada/3`: todo libre, legajo y materia ligados, todo ligado |
    | C2 | `aprobada(L, M, N)` con todo libre enumera las diez aprobadas, y la prueba `todas_las_aprobadas` las lista |
    | C3 | `aprobada(101, log, 9)` falla, y `aprobada(101, log, N)` responde `N = 10`: el tercer argumento no cambia qué se elige |
    | C4 | Las dos reglas son `nondet`; no hay predicados `det` que verificar todavía, salvo `nota_minima/1`, un hecho |
    | C5 | `aprobada(101, log, diez)` falla en lugar de producir un error: es una restricción que el encabezado declara con el tipo `integer`, y que el [capítulo 25](../capitulo-25-errores-y-excepciones/index.md) convierte en error |
    | C6 | Ningún predicado escribe ni modifica datos |
    | C7 | 11 pruebas: las cuatro de datos del [capítulo 13](../capitulo-13-el-entorno-de-trabajo/index.md), adaptadas al estado nuevo, y siete de las reglas |

Las pruebas de datos del [capítulo 13](../capitulo-13-el-entorno-de-trabajo/index.md) cambian con la representación: la que
verificaba las notas ahora verifica que todo estado sea `cursando` o `nota(N)`
con `N` entero de 1 a 10.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Para cada predicado, elegir el signo de cada argumento entre los
   ocho de la [sección 14.3](#143-el-encabezado-completo) y justificarlo: `atom_length(Atomo, Largo)` ·
   `msort(Lista, Ordenada)` · `==(A, B)` · `once(Objetivo)` ·
   `between(Desde, Hasta, N)` con `N` de salida.
2. **(1)** Indicar la determinación de cada uno: `fail/0` · `true/0` ·
   `member(X, L)` con `L` ligada · `between(1, 5, N)` · `throw(error)` ·
   `repeat/0`.
3. ★ **(2)** Escribir el encabezado completo, con tipos, de `sacar/3` del
   [capítulo 7](../capitulo-07-listas/index.md), y las pruebas que corresponden a cada línea de modo.
4. **(2)** Renombrar las variables y el predicado del siguiente fragmento
   según las convenciones de la [sección 14.1](#141-nombres), y escribir su encabezado:

    ```prolog
    calc(X, Y) :- f(X, Z), f(Z, Y).
    f(ana, luis).
    f(luis, eva).
    ```

5. ★ **(2)** El predicado siguiente no es estable. Mostrar una consulta con el
   segundo argumento ligado que responda algo falso, y corregirlo con el
   [Patrón 3](../patrones.md#3-salida-despues-del-compromiso):

    ```prolog
    %!  signo(+N, -S) is det.
    %
    %   S es negativo, cero o positivo, según N.
    signo(N, negativo) :- N < 0, !.
    signo(0, cero) :- !.
    signo(_, positivo).
    ```

6. **(2)** Agregar `:- det(signo/2).` a la versión corregida del ejercicio 5 y
   ejecutar `signo(5, S).` ¿Qué ocurre, y qué dice eso sobre la implementación?
7. ★ **(2)** Escribir `aprobadas_de(Legajo, Materia)` sobre la versión de
   *Inscripciones* de este capítulo, con su encabezado, y las pruebas de cada
   modo. ¿Qué criterios de la [sección 14.8](#148-criterios-de-calidad) se pueden verificar sobre él?
8. **(2)** Representar el estado de un préstamo de biblioteca, que puede estar
   en curso, devuelto en una fecha o vencido desde una fecha, primero con una
   representación por defecto y después con una limpia. Escribir con cada una
   la regla `vencido(Prestamo)`.
9. ★ **(3)** Revisar `sin_repetidos/2` de la [solución 10 del capítulo 9](../capitulo-09-backtracking-y-corte/soluciones.md#10) con los
   siete criterios. Para cada uno, indicar si lo cumple y cómo se comprueba.
10. **(2)** Generar con `doc_save/2` la documentación de `inscripciones.pl` y
    abrirla en el navegador. ¿Qué información del encabezado aparece, y cuál no?
11. **(1)** Explicar por qué `suma_lista/2` declara `++L` y `largo/2` declara
    `+L`. ¿Qué responde cada uno con la lista `[a, b]`?
12. ★ **(2)** `mismo_termino/2` declara sus argumentos con `@`. Escribir una
    versión con `=` en lugar de `==` y mostrar con una consulta por qué no
    le corresponde `@`.
13. **(3)** Agregar `:- det(primero_y_ultimo/3).` a `primero_y_ultimo/3` del
    [capítulo 7](../capitulo-07-listas/index.md) y consultarlo con `[a, b, c]`, con `[]` y con la lista libre.
    Explicar cada resultado, y por qué el encabezado declara `nondet` aunque con
    la lista ligada `det/1` no produzca ningún error.
14. **(3)** Escribir `materia_de_anio(Anio, Materias)`: `Materias` es la lista
    de las materias de ese año, ordenada según aparecen en la base. Con las
    herramientas de la parte I no se puede escribir sin repetir los datos
    ([sección 10.8](../capitulo-10-negacion-como-falla/index.md#108-prescindir-de)): escribir el encabezado que debería tener, las pruebas que lo
    verificarían, y explicar qué elemento del [capítulo 17](../capitulo-17-todas-las-soluciones/index.md) lo resuelve.
15. **(2)** El predicado siguiente no tiene un nombre que diga qué relación
    define, ni encabezado:

    ```prolog
    p(A, [A|B], C, [C|B]).
    p(A, [D|B], C, [D|E]) :-
        p(A, B, C, E).
    ```

    Describir la relación que define, primero leyendo solo el código y después
    sabiendo que se usa en el modo `p(+, +, +, -)`: los tres primeros
    argumentos ligados y el cuarto libre. Comprobar la segunda descripción con
    la consulta `p(b, [a, b, c, b], z, L)`. Después, nombrar el predicado y sus
    variables según la [sección 14.1](#141-nombres), escribir su encabezado completo y
    compararlo con `select/4` de la biblioteca.

## Resumen

| | |
|---|---|
| nombres | los predicados nombran relaciones; se leen con los argumentos en orden |
| `_Nombre` | variable que se usa una vez, con nombre que documenta; advertida si aparece dos veces |
| `:- discontiguous` | declara que las cláusulas de un predicado están separadas a propósito |
| `++`, `--`, `@`, `:`, `!` | completo, libre, no se instancia, objetivo, modificable |
| `multi`, `failure`, `erroneous` | una o más respuestas; ninguna; siempre un error |
| `+L:list(number)` | el tipo de un argumento, en el encabezado |
| `integer/1` | prueba de tipo: tiene éxito si el argumento es un entero |
| `det/1`, `$`, `$/1` | verifican la determinación de la implementación en cada llamada |
| estabilidad | el resultado no depende de que la salida llegue ligada o libre |
| representación limpia | un functor por caso, seleccionado por unificación |
| `doc_server/1`, `doc_save/2` | la documentación generada a partir de los encabezados |
| C1–C7 | los criterios de calidad de la parte II |
| **Patrones 2, 3, 4** | encabezado que se cumple; salida después del compromiso; datos limpios |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| `->` y `;`: casos que no se superponen sin corte rojo | [capítulo 15](../capitulo-15-control/index.md) |
| Alternativas pendientes, indexación y su costo | [capítulo 16](../capitulo-16-rendimiento/index.md) |
| Reunir respuestas en una lista: `materia_de_anio/2` | [capítulo 17](../capitulo-17-todas-las-soluciones/index.md) |
| El modo `:` y los predicados que reciben objetivos | [capítulo 18](../capitulo-18-orden-superior/index.md) |
| Módulos: la interfaz de un programa, no solo de un predicado | [capítulo 24](../capitulo-24-modulos-y-organizacion/index.md) |
| Tipos verificados en la ejecución: `must_be/2`; el criterio C5 | [capítulo 25](../capitulo-25-errores-y-excepciones/index.md) |
| Convertir los datos de afuera a una representación limpia | [capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) |
