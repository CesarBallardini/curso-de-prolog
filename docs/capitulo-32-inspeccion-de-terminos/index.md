# Capítulo 32 — Inspección de términos

Los programas de las partes I y II conocen la forma de los términos que
manejan, y los descomponen por unificación con un patrón escrito en la cabeza,
como en la [plantilla 7](../plantillas.md#7-extraer-un-componente-de-un-termino). Muchos programas no la conocen: un intérprete
recibe objetivos de cualquier predicado, un simplificador recibe expresiones de
cualquier tamaño. Esos programas preguntan durante la ejecución qué clase de
término tienen, cuál es su nombre y cuántos argumentos tiene, y lo recorren sin
saber de antemano su forma.

Este capítulo presenta esas herramientas: las pruebas de tipo y sus límites,
`functor/3`, `arg/3` y `=..`, un recorrido que sirve para cualquier término,
las variables tratadas como datos, y la representación de los datos que evita
las pruebas de tipo. Termina con un simplificador de expresiones aritméticas,
que el [capítulo 43](../capitulo-43-proyecto-resolver-ecuaciones/index.md) usa para resolver ecuaciones. Cumple dos anuncios de
la parte I: la inspección de un término cuya forma no se conoce de antemano,
del [capítulo 4](../capitulo-04-terminos-y-unificacion/index.md), y la verificación del tipo de un término antes de
compararlo, del [capítulo 10](../capitulo-10-negacion-como-falla/index.md). Sigue «Structure Inspection» y «Meta-Logical
Predicates» de *The Art of Prolog* de Sterling y Shapiro, y «Prolog Data Structures» de *The Power
of Prolog* de Markus Triska; las demás fuentes están en las [referencias](#referencias).

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- clasificar un término con las pruebas de tipo, y explicar por qué una prueba
  de tipo no es una relación;
- elegir entre una prueba de tipo, `must_be/2` y una restricción para verificar
  un argumento antes de compararlo;
- construir y descomponer términos de forma desconocida con `functor/3`,
  `arg/3`, `=..` y `compound_name_arguments/3`;
- escribir un recorrido que sirve para cualquier término, y usar los de
  `library(terms)`;
- copiar, comparar y nombrar las variables de un término, y representar los
  datos de modo que cada caso se reconozca por su functor.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:30 h**.
    Resolver los 6 ejercicios marcados con ★: **1:35 h**.
    Resolver los 13 ejercicios del final: **4:05 h**.

## 32.1 Qué clase de término es

Una **prueba de tipo** es un predicado predefinido que tiene éxito cuando su
argumento, **en el momento de la llamada**, pertenece a una clase de término:

| Prueba | Tiene éxito si el argumento es |
|---|---|
| `var/1`, `nonvar/1` | una variable libre; cualquier otra cosa |
| `integer/1`, `float/1`, `number/1` | un entero; un número de punto flotante; un número |
| `atom/1`, `string/1` | un átomo; una cadena |
| `atomic/1` | un número, un átomo, una cadena o `[]` |
| `compound/1` | un término compuesto |
| `callable/1` | un átomo o un término compuesto |
| `is_list/1` | una lista completa, terminada en `[]` |
| `ground/1` | un término sin variables libres |

`clase/2` las combina para clasificar cualquier término:

<!-- ejemplo: capitulo-32/tipos.pl predicado: clase/2 consulta: clase(f(a, B), Clase). -->
```prolog
%!  clase(@Termino, -Clase) is det.
%
%   Clase es la clase de Termino en su estado actual: variable, entero,
%   flotante, atomo, cadena, lista_vacia o compuesto(Nombre/Aridad).
%   Termino no se modifica.
clase(T, Clase) :-
    (   var(T)
    ->  Clase = variable
    ;   integer(T)
    ->  Clase = entero
    ;   float(T)
    ->  Clase = flotante
    ;   atom(T)
    ->  Clase = atomo
    ;   string(T)
    ->  Clase = cadena
    ;   T == []
    ->  Clase = lista_vacia
    ;   compound_name_arity(T, Nombre, Aridad),
        Clase = compuesto(Nombre/Aridad)
    ).
```

```prolog
?- clase(f(a, B), Clase).
Clase = compuesto(f/2).
```

`[]` es una constante propia, no un átomo, y `clase([a], C)` da
`C = compuesto('[|]'/2)`: una lista no vacía es un término compuesto. `compound_name_arity/3` da el nombre y la aridad
de un compuesto. El signo `@` del encabezado, del
[capítulo 14](../capitulo-14-estilo-y-documentacion/index.md), indica que el predicado examina el término sin ligar sus
variables. Esa es la particularidad de todas las pruebas de tipo, y su límite:
responden sobre el estado **actual** del término, no sobre lo que puede llegar
a ser.

```prolog
?- atom(X), X = ana.
false.

?- X = ana, atom(X).
X = ana.
```

Como relación, `atom(X)` debería tener una respuesta por cada átomo; responde
`false.`, y la conjunción cambia de respuesta al invertir el orden de sus
objetivos, aunque la conjunción lógica es conmutativa. Una prueba de tipo no es
una relación, y un predicado que la aplica a un argumento que puede llegar
libre hereda el problema.

!!! question "Actividad"
    Predecir y comprobar: `integer(3.0)` · `atomic("hola")` · `callable(f(X))` ·
    `is_list([a|T])` · `T = [], is_list([a|T])`. ¿En cuáles decide el orden de
    los objetivos?

### Verificar el tipo antes de comparar

El [capítulo 10](../capitulo-10-negacion-como-falla/index.md) separó `=`, `==` y `=:=`; falta decidir qué hacer cuando
un dato puede no ser del tipo que la comparación necesita. En `tipos.pl` la
edad de eva no se conoce, y el hecho lo registra con un átomo. La comparación
sola produce un error al llegar a ese dato:

```prolog
?- desconocida >= 18.
ERROR: Arithmetic: `desconocida/0' is not a function
ERROR: In:
ERROR:   [12] desconocida>=18
```

La primera corrección verifica el tipo antes de comparar:

<!-- ejemplo: capitulo-32/tipos.pl predicado: edad/2 mayor_de_edad/1 consulta: edad(P, E), mayor_de_edad(E). -->
```prolog
% edad(P, E): la edad registrada de P; desconocida si no se sabe.
edad(ana, 41).
edad(luis, 12).
edad(eva, desconocida).
edad(juan, 68).

%!  mayor_de_edad(@E) is semidet.
%
%   E es un entero de 18 o más. Falla con cualquier otro término, incluida
%   una variable libre.
mayor_de_edad(E) :-
    integer(E),
    E >= 18.
```

```prolog
?- mayor_de_edad(E).
false.
```

Como filtro de datos ya ligados, `mayor_de_edad/1` hace lo esperado:
`edad(P, E), mayor_de_edad(E)` da ana y juan. Pero la consulta más general responde
`false.`, que se lee «no existe ninguna edad mayor de edad»: es la falla del
criterio C2 de la [sección 14.8](../capitulo-14-estilo-y-documentacion/index.md#148-criterios-de-calidad), una respuesta incorrecta sin aviso. Dos
alternativas la evitan. `mayor_de_edad_verificado/1` empieza con
`must_be(integer, E)`, del [capítulo 25](../capitulo-25-errores-y-excepciones/index.md), que distingue los dos casos con dos
errores; `mayor_de_edad_restringido/1` usa una restricción de `library(clpfd)`,
del [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md), que responde también con la variable libre:

<!-- ejemplo: capitulo-32/tipos.pl predicado: mayor_de_edad_restringido/1 consulta: mayor_de_edad_restringido(E). -->
```prolog
%!  mayor_de_edad_restringido(?E:integer) is semidet.
%
%   E es un entero de 18 o más. Con E libre, la respuesta es la restricción
%   E #>= 18, sin elegir un valor. Produce un error de dominio si E no es
%   un entero ni una expresión de clpfd.
mayor_de_edad_restringido(E) :-
    E #>= 18.
```

```prolog
?- mayor_de_edad_verificado(desconocida).
ERROR: Type error: `integer' expected, found `desconocida' (an atom)
ERROR: In:
ERROR:   [16] throw(error(type_error(integer,desconocida),_51800))

?- mayor_de_edad_restringido(E).
E in 18..sup.
```

`mayor_de_edad_verificado(E)` con E libre produce un error de instanciación.
Las cuatro formas tienen cada una su lugar:

| Versión | Con un átomo | Con una variable libre | Cuándo |
|---|---|---|---|
| comparación sola | error de evaluación | error de instanciación | con datos de tipo seguro |
| prueba de tipo | falla | falla | para filtrar datos ya ligados |
| `must_be/2` | error de tipo | error de instanciación | el argumento es una entrada |
| restricción | error de dominio | responde la restricción | el predicado debe ser una relación |

`is_of_type(Tipo, X)` es la prueba de tipo que corresponde a `must_be/2`: conoce
los mismos tipos —`integer`, `positive_integer`, `list(atom)`…— y falla donde
`must_be/2` produce un error, también con una variable libre.

## 32.2 Nombre, aridad y argumentos

`functor(T, Nombre, Aridad)` obtiene durante la ejecución el nombre y la aridad
de un término, y `arg(N, T, A)` da su argumento N:

```prolog
?- functor(fecha(2026, 9, 27), Nombre, Aridad).
Nombre = fecha,
Aridad = 3.

?- arg(N, fecha(2026, 9, 27), X).
N = 1,
X = 2026 ;
N = 2,
X = 9 ;
N = 3,
X = 27.
```

Un término atómico tiene aridad 0 y es su propio nombre. `arg/3` con la
posición libre enumera los argumentos. Con el nombre y la aridad ligados,
`functor/3` construye: `functor(T, fecha, 3)` da `T = fecha(_, _, _)`.
Con esas dos operaciones se escriben predicados que no conocen la forma de lo
que reciben. `cambiar_argumento/4` construye un término con el mismo nombre y
la misma aridad, y `copiar_otros/5`, en el mismo archivo, recorre las
posiciones de 1 a la aridad y copia con `arg/3` todos los argumentos salvo uno:

<!-- ejemplo: capitulo-32/partes.pl predicado: cambiar_argumento/4 consulta: cambiar_argumento(2, fecha(2026, 9, 27), 10, T). -->
```prolog
%!  cambiar_argumento(+N:integer, +Termino0, ?X, -Termino) is semidet.
%
%   Termino es Termino0 con X en el lugar del argumento N. Termino0 no
%   cambia: Termino es un término nuevo, que comparte con Termino0 los
%   demás argumentos. Falla si Termino0 no tiene argumento N.
cambiar_argumento(N, T0, X, T) :-
    functor(T0, Nombre, Aridad),
    functor(T, Nombre, Aridad),
    arg(N, T, X),
    copiar_otros(1, Aridad, N, T0, T).
```

```prolog
?- cambiar_argumento(2, fecha(2026, 9, 27), 10, T).
T = fecha(2026, 10, 27).
```

`fecha(2026, 9, 27)` no cambia: un término no se modifica una vez construido, y
«cambiar un argumento» es construir otro término que comparte con el primero
los argumentos restantes, como `put_assoc/4` en el
[capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md). `partes.pl` tiene además `argumentos/2`, que reúne los
argumentos recorriendo las posiciones de 1 a la aridad.

## 32.3 `=..` y `compound_name_arguments/3`

El operador `=..`, que se lee *univ*, relaciona un término con la lista de su
nombre y sus argumentos. Descompone y construye en un solo paso:

```prolog
?- fecha(2026, 9, 27) =.. L.
L = [fecha, 2026, 9, 27].

?- T =.. [fecha, 2026, 9, 27].
T = fecha(2026, 9, 27).

?- ana =.. L.
L = [ana].
```

Con `=..`, cambiar el nombre de un término —`renombrar/3` en `partes.pl`— o
agregarle un argumento son operaciones sobre la lista:

<!-- ejemplo: capitulo-32/partes.pl predicado: agregar_argumento/3 consulta: agregar_argumento(padre(juan), H, Meta). -->
```prolog
%!  agregar_argumento(+Meta0:callable, ?X, -Meta:callable) is det.
%
%   Meta es Meta0 con X como argumento adicional, al final: la operación que
%   call/2 realiza antes de llamar.
agregar_argumento(Meta0, X, Meta) :-
    Meta0 =.. [Nombre|Args0],
    append(Args0, [X], Args),
    Meta =.. [Nombre|Args].
```

```prolog
?- agregar_argumento(padre(juan), H, Meta).
Meta = padre(juan, H).
```

`agregar_argumento/3` es lo que hace `call/2`, del
[capítulo 18](../capitulo-18-orden-superior/index.md), antes de llamar: `call(padre(juan), H)` llama a `padre(juan, H)`.
`=..` construye una lista por cada término que descompone; cuando interesa un
solo argumento, `arg/3` lo obtiene sin construir nada.
SWI-Prolog admite además términos compuestos **sin argumentos**, como `f()`,
distintos del átomo `f`. `=..` no los representa, porque la lista `[f]` ya
corresponde al átomo. `compound_name_arguments/3` trabaja solo con compuestos,
incluidos esos: `compound_name_arguments(T, f, [])` da `T = f()`, y con un
átomo produce un error de tipo. `=..` y `functor/3` convienen cuando el término
puede ser atómico; `compound_name_arguments/3`, cuando debe ser compuesto.

## 32.4 Recorrer cualquier término

Un **subtérmino** de T es T mismo o un subtérmino de alguno de sus argumentos.
La definición se traduce directamente:

<!-- ejemplo: capitulo-32/recorrer.pl predicado: subtermino_ingenuo/2 consulta: subtermino(S, f(a, g(b))). -->
```prolog
%!  subtermino_ingenuo(?S, +Termino) is nondet.
%
%   S es un subtérmino de Termino: Termino mismo o un subtérmino de alguno de
%   sus argumentos. Compara por unificación, así que liga las variables de
%   Termino.
subtermino_ingenuo(S, S).
subtermino_ingenuo(S, T) :-
    compound(T),
    T =.. [_|Args],
    member(A, Args),
    subtermino_ingenuo(S, A).
```

Con variables en el término, la primera cláusula unifica S con cada
subtérmino, y la unificación **liga** las variables del término examinado:

```prolog
?- subtermino_ingenuo(a, f(X, b)).
X = a ;
false.
```

`a` no aparece en `f(X, b)`; la respuesta dice que aparecería si X fuera `a`.
Para un programa que examina términos es una respuesta incorrecta: la pregunta
era qué contiene el término, no en qué se puede convertir. La corrección separa
las dos tareas: `subtermino/2` solo **enumera**, con S libre, y `contiene/2`
compara con `==`, que no liga nada:

<!-- ejemplo: capitulo-32/recorrer.pl predicado: subtermino/2 contiene/2 consulta: subtermino(S, f(a, g(b))). -->
```prolog
%!  subtermino(-S, +Termino) is multi.
%
%   S es un subtérmino de Termino, en preorden: primero Termino, después los
%   subtérminos de cada argumento, de izquierda a derecha. S debe llegar
%   libre; las variables de Termino se enumeran como subtérminos, sin
%   ligarlas.
subtermino(T, T).
subtermino(S, T) :-
    compound(T),
    arg(_, T, A),
    subtermino(S, A).

%!  contiene(+Termino, @S) is semidet.
%
%   S aparece en Termino: es idéntico (==) a alguno de sus subtérminos.
contiene(T, S) :-
    subtermino(X, T),
    X == S,
    !.
```

```prolog
?- subtermino(S, f(X, b)).
S = f(X, b) ;
S = X ;
S = b ;
false.

?- contiene(f(X, b), a).
false.
```

`subtermino/2` recorre los argumentos con `arg/3` y la posición libre, sin
construir la lista de `=..`. SWI-Prolog tiene la misma relación predefinida,
`sub_term/2`. `sustituir/4` reemplaza cada subtérmino idéntico a uno dado.
Recorre los argumentos con `mapargs/3`, de `library(terms)`: `mapargs(P, T0, T)`
relaciona dos términos del mismo functor cuyos argumentos cumplen P uno a uno,
como `maplist/3` con dos listas.

<!-- ejemplo: capitulo-32/recorrer.pl predicado: sustituir/4 consulta: sustituir(x, 3, x * x + y, T). -->
```prolog
%!  sustituir(@Viejo, ?Nuevo, +Termino0, -Termino) is det.
%
%   Termino es Termino0 con Nuevo en el lugar de cada subtérmino idéntico
%   (==) a Viejo.
sustituir(Viejo, Nuevo, T0, T) :-
    (   T0 == Viejo
    ->  T = Nuevo
    ;   compound(T0)
    ->  mapargs(sustituir(Viejo, Nuevo), T0, T)
    ;   T = T0
    ).
```

```prolog
?- sustituir(x, 3, x * x + y, T).
T = 3*3+y.
```

`sustituir/4`, `contiene/2` y cualquier otra operación sobre términos
arbitrarios repiten una estructura: una variable se deja, un compuesto se
procesa por sus argumentos, y en cada nodo se hace el trabajo propio de la
operación. `transformar/3` escribe esa estructura una sola vez, y recibe el
trabajo por nodo como argumento:

<!-- ejemplo: capitulo-32/recorrer.pl predicado: transformar/3 duplicar/2 consulta: transformar(duplicar, f(1, g(2), a), T). -->
```prolog
%!  transformar(:P, +Termino0, -Termino) is det.
%
%   Termino es Termino0 transformado de abajo hacia arriba: primero se
%   transforman los argumentos, y después se aplica call(P, Nodo, Nuevo) al
%   nodo resultante, y se toma su primer resultado. Donde P falla, el nodo
%   queda como está. Las variables de Termino0 no se transforman.
transformar(P, T0, T) :-
    (   var(T0)
    ->  T = T0
    ;   (   compound(T0)
        ->  mapargs(transformar(P), T0, T1)
        ;   T1 = T0
        ),
        (   call(P, T1, T2)
        ->  T = T2
        ;   T = T1
        )
    ).

%!  duplicar(+N:number, -M:number) is semidet.
%
%   M es el doble de N. Falla si N no es un número.
duplicar(N, M) :-
    number(N),
    M is 2 * N.
```

```prolog
?- transformar(duplicar, f(1, g(2), a), T).
T = f(2, g(4), a).
```

El recorrido es **de abajo hacia arriba**: P recibe cada nodo con sus
argumentos ya transformados, el orden que necesita un simplificador, donde
`x * (1 + 0)` se reduce a `x` después de que `1 + 0` se redujo a `1`. La
directiva `meta_predicate` del [capítulo 24](../capitulo-24-modulos-y-organizacion/index.md) declara que el primer
argumento es un predicado que recibe dos argumentos más. `library(terms)`
ofrece los recorridos frecuentes ya escritos:

| Predicado | Relación |
|---|---|
| `mapargs(P, T0, T)` | los argumentos de T0 y T cumplen P uno a uno |
| `mapsubterms(P, T0, T)` | T es T0 con cada subtérmino S0 para el que `call(P, S0, S)` tiene éxito reemplazado por S, de arriba hacia abajo |
| `foldsubterms(P, T, A0, A)` | A acumula sobre los subtérminos de T con `call(P, S, A0, A1)`; donde P falla, sigue por los argumentos |

`mapsubterms([x, 3]>>true, x * x + y, T)` da `T = 3*3+y`, como `sustituir/4`.
`foldsubterms/4` pliega como `foldl/4` del [capítulo 18](../capitulo-18-orden-superior/index.md); `recorrer.pl`
lo usa en `atomos/2`, que reúne los átomos de un término.

!!! example "Patrón 43 — Recorrido genérico de un término"
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
    [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md), es más clara y aprovecha la indexación.

## 32.5 Variables como datos

Un término con variables puede representar un esquema: una regla, una plantilla,
una función. `variables.pl` representa una función como `fn(X, Cuerpo)`, y la
aplica ligando X. La versión ingenua, `evaluar_en_ingenuo/3`, unifica la función
con `fn(X, Cuerpo)`, liga X al argumento y evalúa el cuerpo: liga la variable de
la función misma. `evaluar_en/3` trabaja sobre una copia con `copy_term(T, C)`:
C es T con **variables nuevas**, que conserva qué posiciones comparten una misma
variable.

<!-- ejemplo: capitulo-32/variables.pl predicado: cuadrado/1 evaluar_en/3 consulta: cuadrado(F), evaluar_en(F, 2, A), evaluar_en(F, 3, B). -->
```prolog
% cuadrado(F): F es la función que eleva al cuadrado.
cuadrado(fn(X, X * X)).

%!  evaluar_en(+F, +A:number, -V:number) is det.
%
%   V es el valor de la función F en A. Aplica una copia de F, así que F no
%   cambia.
evaluar_en(F, A, V) :-
    copy_term(F, fn(X, Cuerpo)),
    X = A,
    V is Cuerpo.
```

```prolog
?- cuadrado(F), evaluar_en_ingenuo(F, 2, A), evaluar_en_ingenuo(F, 3, B).
false.

?- cuadrado(F), evaluar_en(F, 2, A), evaluar_en(F, 3, B).
F = fn(_A, _A*_A),
A = 4,
B = 9.
```

La primera aplicación ingenua deja la función como `fn(2, 2*2)`, y la segunda no
puede ligar X a 3. Prolog hace lo mismo que `evaluar_en/3` con cada cláusula que
usa: la renombra con variables nuevas, como mostró el [capítulo 5](../capitulo-05-como-responde-prolog/index.md); un
intérprete escrito en Prolog, como el del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md), depende de eso.
`term_variables(T, Vs)` da las variables distintas de T, en el orden en que
aparecen: con `f(X, g(Y, X), Z)`, `Vs = [X, Y, Z]`.

`==` compara términos con variables sin ligarlas: dos variables son idénticas
solo si son la misma. `=@=` pregunta si dos términos son **variantes**, iguales
salvo el nombre de las variables: `f(X, Y) =@= f(A, B)` se cumple, y
`f(X, X) =@= f(A, B)` no, porque el primero repite una variable.
En el orden estándar de la [sección 22.2](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#222-el-orden-estandar), las variables van antes que cualquier
otro término, y entre ellas el orden depende de dónde las ubicó el sistema en
la memoria, no de sus nombres: `msort([b, Y, 1, X, a], L)` da
`L = [Y, X, 1, a, b]`. Un programa no debe depender de ese orden.

`numbervars(T, Inicio, Fin)` liga cada variable de T a un término `'$VAR'(N)`,
que `print/1` y `writeq/1` escriben como `A`, `B`, `C`… Sirve para mostrar un
término con nombres legibles, pero **liga** las variables:
`T = f(X), numbervars(T, 0, _), X = ana` falla. La doble negación, `\+ \+ G`,
prueba G y deshace sus ligaduras; con ella, `escribir_con_nombres/1` nombra las
variables solo mientras escribe:

<!-- ejemplo: capitulo-32/variables.pl predicado: escribir_con_nombres/1 consulta: escribir_con_nombres(f(X, g(Y, X))). -->
```prolog
%!  escribir_con_nombres(@Termino) is det.
%
%   Escribe Termino con sus variables nombradas A, B, C… en el orden en que
%   aparecen. Termino no queda ligado: la doble negación deshace las
%   ligaduras de numbervars/3.
escribir_con_nombres(T) :-
    \+ \+ ( numbervars(T, 0, _),
            print(T),
            nl ).
```

```prolog
?- escribir_con_nombres(f(X)), X = ana.
f(A)
X = ana.
```

## 32.6 Representaciones limpias

La [sección 14.6](../capitulo-14-estilo-y-documentacion/index.md#146-representacion-de-los-datos) distinguió las representaciones *por defecto* de las
**limpias** para un dato con varios casos ([Patrón 4](../patrones.md#4-datos-limpios)). En
una estructura recursiva el problema se agrava, porque cada nodo debe decir de
qué clase es. Una lista anidada, `[a, [b, c]]`, es una representación por
defecto de un árbol: una hoja es cualquier cosa que no sea una lista, y el
predicado que la recorre lo pregunta con `is_list/1`:

<!-- ejemplo: capitulo-32/limpia.pl predicado: aplanar_ingenuo/2 consulta: aplanar_ingenuo([a, [b, c]], P). -->
```prolog
%!  aplanar_ingenuo(+Lista:list, -Plana:list) is det.
%
%   Plana tiene los elementos de Lista y de sus listas anidadas, en orden.
%   Un elemento que no es una lista en el momento de la llamada es una hoja.
aplanar_ingenuo([], []).
aplanar_ingenuo([X|Xs], Plana) :-
    (   is_list(X)
    ->  aplanar_ingenuo(X, P1)
    ;   P1 = [X]
    ),
    aplanar_ingenuo(Xs, P2),
    append(P1, P2, Plana).
```

```prolog
?- aplanar_ingenuo([a, X], P), X = [b, c].
X = [b, c],
P = [a, [b, c]].
```

Con X ligada antes, la misma consulta da `[a, b, c]`. La respuesta es
incorrecta: `is_list(X)` decidió con X libre que era
una hoja. Es el problema de `atom/1` de la [sección 32.1](#321-que-clase-de-termino-es), dentro de
una estructura. Hay un segundo problema, de expresividad: una hoja que sea una
lista no se puede representar, porque toda lista se lee como nodo.

La representación limpia marca cada clase de nodo con su propio functor: `h(X)`
es una hoja con el valor X, y `n(Hijos)` un nodo con la lista de sus hijos.
`hojas/2` elige el caso por unificación en la cabeza, sin pruebas de tipo:

<!-- ejemplo: capitulo-32/limpia.pl predicado: hojas/2 consulta: hojas(n([h(a), n([h(b), h(c)])]), H). -->
```prolog
%!  hojas(?Arbol, ?Hojas:list) is nondet.
%
%   Hojas son las hojas de Arbol, de izquierda a derecha. Arbol es h(X), una
%   hoja con el valor X, o n(Hijos), un nodo con la lista de sus hijos.
hojas(h(X), [X]).
hojas(n(Hijos), Hojas) :-
    maplist(hojas, Hijos, Listas),
    append(Listas, Hojas).
```

```prolog
?- hojas(n([h(a), h([b, c])]), H).
H = [a, [b, c]].
```

La hoja cuyo valor es una lista se representa sin ambigüedad, y `hojas/2` da el
mismo resultado sea cual sea el momento en que se ligan sus argumentos. Los
datos que llegan en la forma por defecto se convierten **una vez**, en el
borde, como pide el [Patrón 37](../patrones.md#37-convertir-en-el-borde): `a_arbol/2` aplica `is_list/1` a
una lista que `must_be/2` garantiza sin variables, en `elemento_a_arbol/2`.

<!-- ejemplo: capitulo-32/limpia.pl predicado: a_arbol/2 consulta: a_arbol([a, [b, c]], A). -->
```prolog
%!  a_arbol(+Lista:list, -Arbol) is det.
%
%   Arbol es la lista anidada Lista como árbol limpio: cada lista es un nodo
%   n/1 y cada elemento que no es una lista, una hoja h/1. Lista debe llegar
%   sin variables: la prueba de tipo decide el caso una sola vez.
a_arbol(Lista, n(Hijos)) :-
    must_be(ground, Lista),
    maplist(elemento_a_arbol, Lista, Hijos).
```

```prolog
?- a_arbol([a, [b, c]], A).
A = n([h(a), n([h(b), h(c)])]).
```

La observación se aplica en general: **sobre un término cerrado, una prueba de tipo
responde lo mismo en cualquier momento**, porque el término ya no puede
cambiar. Los problemas aparecen solo cuando el argumento puede tener variables.

!!! example "Patrón 44 — Representación limpia"
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

## 32.7 Un simplificador de expresiones

Un **simplificador** reescribe una expresión aritmética en otra equivalente y
más corta: `x * (1 + 0)` en `x`, `(x * 2) * 3` en `6 * x`. Las expresiones usan
la sintaxis habitual, con los átomos como incógnitas, y son cerradas: es el
caso que el [Patrón 44](../patrones.md#44-representacion-limpia) exceptúa, y las reglas usan `number/1` sin
riesgo. Cada regla reescribe la raíz de una expresión; la primera usa `=..`
para tratar las tres operaciones con una sola cláusula:

<!-- ejemplo: capitulo-32/simplificar_pasada.pl predicado: regla/2 consulta: simplificar_pasada(x * (1 + 0), E). -->
```prolog
%!  regla(+E0, -E) is nondet.
%
%   E es el resultado de reescribir la raíz de la expresión cerrada E0 con
%   una regla: una respuesta por cada regla que se aplica, en el orden de
%   las cláusulas. Los simplificadores usan solo la primera.
regla(E, V) :-
    E =.. [Op, A, B],
    memberchk(Op, [+, -, *]),
    number(A),
    number(B),
    V is E.
regla(0 + X, X).
regla(X + 0, X).
regla(X - 0, X).
regla(X - X, 0).
regla(0 * _, 0).
regla(_ * 0, 0).
regla(1 * X, X).
regla(X * 1, X).
regla(X * N, N * X) :-
    number(N),
    \+ number(X).
regla(N * (M * X), P * X) :-
    number(N),
    number(M),
    P is N * M.
regla(X + X, 2 * X).
regla(_ ^ 0, 1).
regla(X ^ 1, X).
```

Las reglas se superponen —a `0 * 1` se aplican tres, y todas dan `0`—, y los
simplificadores usan la primera que se aplica. Aplicar una regla solo a la raíz
no alcanza: a `x * (1 + 0)` no se aplica ninguna, aunque su argumento `1 + 0`
es simplificable. El primer peldaño útil es el recorrido de abajo hacia arriba
del [Patrón 43](../patrones.md#43-recorrido-generico-de-un-termino), con una regla a lo sumo en cada nodo:

<!-- ejemplo: capitulo-32/simplificar_pasada.pl predicado: simplificar_pasada/2 consulta: simplificar_pasada((x * 2) * 3, E). -->
```prolog
%!  simplificar_pasada(+E0, -E) is det.
%
%   E es E0 simplificada en una pasada de abajo hacia arriba: primero los
%   argumentos, después la raíz, con una regla a lo sumo en cada nodo.
simplificar_pasada(E0, E) :-
    (   compound(E0)
    ->  mapargs(simplificar_pasada, E0, E1)
    ;   E1 = E0
    ),
    (   regla(E1, E2)
    ->  E = E2
    ;   E = E1
    ).
```

!!! question "Actividad"
    Predecir el resultado de `simplificar_pasada((x * 2) * 3, E)` siguiendo el
    recorrido nodo por nodo, y comprobarlo.

```prolog
?- simplificar_pasada((x * 2) * 3, E).
E = 3*(2*x).
```

`x * (1 + 0)` queda en `x`, pero este resultado no está simplificado: `x * 2` pasa a `2 * x`, la raíz
`(2 * x) * 3` pasa a `3 * (2 * x)`, y sobre ese resultado se aplicaría otra
regla, que da `6 * x`. Repetir pasadas completas hasta que una no cambie nada
lo corrige —es `simplificar_repetido/2`, en el mismo archivo—, pero recorre la
expresión entera por un cambio pendiente en un solo nodo. La versión final
simplifica otra vez el resultado en el nodo donde una regla se aplicó, y
verifica **una vez**, con `must_be/2`, que la expresión es cerrada, como pide el
[Patrón 31](../patrones.md#31-validar-al-entrar):

<!-- ejemplo: capitulo-32/simplificar.pl predicado: simplificar/2 simp/2 consulta: simplificar((x * 2) * 3, E). -->
```prolog
%!  simplificar(+E0, -E) is det.
%
%   E es la expresión cerrada E0 simplificada: ninguna regla se aplica a
%   ninguno de sus nodos. Produce un error de instanciación si E0 tiene
%   variables.
simplificar(E0, E) :-
    must_be(ground, E0),
    simp(E0, E).

%!  simp(+E0, -E) is det.
%
%   E es E0 simplificada, como en simplificar/2, sin verificar E0.
simp(E0, E) :-
    (   compound(E0)
    ->  mapargs(simp, E0, E1)
    ;   E1 = E0
    ),
    (   regla(E1, E2)
    ->  simp(E2, E)
    ;   E = E1
    ).
```

```prolog
?- simplificar((x * 2) * 3, E).
E = 6*x.

?- simplificar(2 * x + (y - y) * z + x ^ 1, E).
E = 2*x+x.
```

`2 * x + x` no se reduce a `3 * x` porque ninguna regla agrupa términos
semejantes; el [ejercicio 11](#ejercicios) las agrega. Una expresión con
variables de Prolog produce un error de instanciación: las reglas unifican, y
sobre una variable ligarían en lugar de reconocer.

La verificación está en `simplificar/2` y no en `simp/2`, que se llama a sí
mismo. `simplificar_pasada.pl` tiene `simplificar_verificando/2`, igual a
`simp/2` pero con `must_be(ground, E0)` en cada llamada, y `suma_de_prueba/2`,
que construye una suma de N términos `y * I * 3`. Con `time/1`, del
[capítulo 16](../capitulo-16-rendimiento/index.md), sobre la suma de 5000 términos, `simplificar_verificando/2` y
`simplificar/2` dan:

```text
% 1,040,094 inferences, 0.859 CPU in 0.872 seconds (99% CPU, 1210291 Lips)
% 784,966 inferences, 0.047 CPU in 0.054 seconds (87% CPU, 16745941 Lips)
```

Las inferencias son parecidas y el tiempo es dieciséis veces mayor:
`must_be(ground, E0)` recorre la subexpresión entera en cada nodo y cuenta como
una sola inferencia, porque está escrito en C. Con 20 000 términos la
diferencia es de 16,6 segundos contra 0,45: el costo de verificar en cada nodo
crece con el cuadrado del tamaño. La expresión se verifica en la entrada, y el
trabajo recursivo queda en un predicado que confía en ella.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C2 | una prueba de tipo rompe la consulta más general: `mayor_de_edad(E)` responde `false.` (prueba `mayor_de_edad_libre`), y `aplanar_ingenuo([a, X], P), X = [b, c]` no aplana (prueba `aplanar_ingenuo_ligado_despues`); `mayor_de_edad_restringido(E)` responde `E in 18..sup`, y `hojas/2` da lo mismo con el árbol ligado antes o después (prueba `hojas_ligado_despues`) |
    | C4 | `simplificar/2`, `sustituir/4`, `transformar/3` y `cambiar_argumento/4` no dejan alternativas: sus pruebas no declaran `nondet`; `regla/2` es `nondet`, y los simplificadores toman su primera respuesta con `->` |
    | C5 | `simplificar(x * Y, E)` y `a_arbol([a, X], A)` producen un error de instanciación, y `mayor_de_edad_verificado(desconocida)` un error de tipo; ninguno responde `false.` |
    | C7 | 122 pruebas en los siete archivos del capítulo; las respuestas incorrectas de las versiones ingenuas están fijadas como pruebas |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta y comprobarla:
   `functor(T, punto, 2).` · `arg(N, p(a, b, a), a).` · `X =.. [f].` ·
   `f(a, b) =.. [F|As].` · `atom([]).` · `atomic("hola").`
2. **(1)** Para cada una de `var/1`, `number/1` e `is_list/1`, escribir una
   conjunción de dos objetivos cuya respuesta cambia al invertir su orden, y
   explicar por qué.
3. ★ **(2)** Escribir `aridad_maxima(T, N)`: N es la mayor aridad de los
   subtérminos compuestos de T, o 0 si T no tiene ninguno.
4. **(2)** Escribir `posiciones_iguales(T1, T2, Ps)`: T1 y T2 tienen el mismo
   nombre y la misma aridad, y Ps son las posiciones en las que sus argumentos
   son idénticos.
5. ★ **(2)** Escribir `sustituir_ingenuo/4`, igual a `sustituir/4` pero
   comparando con `=` en lugar de `==`, y encontrar una consulta en la que su
   respuesta es incorrecta. Explicar la diferencia.
6. **(2)** Escribir `profundidad(T, P)`: un término atómico o una variable
   tienen profundidad 0, y un compuesto, uno más que el mayor de sus
   argumentos.
7. ★ **(2)** Escribir el encabezado y el código de `apariciones(T, S, N)`: N es
   la cantidad de subtérminos de T idénticos a S. Justificar cada signo del
   encabezado y la determinación.
8. **(2)** Escribir `variantes(A, B)`, que se cumple si A y B son iguales salvo
   el nombre de las variables, sin usar `=@=`: con `copy_term/2` y
   `numbervars/3`.
9. **(3)** Escribir una representación limpia de las expresiones aritméticas
   —`num(N)`, `inc(X)` y un functor por operación—, `a_limpia/2`, que convierte
   en el borde una expresión escrita con la sintaxis habitual, y
   `valor(E, Valores, V)`, que evalúa una expresión limpia con los valores de
   las incógnitas dados como pares.
10. ★ **(2)** Con las reglas del sistema experto de la
    [sección 19.3](../capitulo-19-operadores-y-reglas-como-datos/index.md#193-reglas-como-datos), escribir `preguntables(Ps)`: los átomos que
    aparecen en las condiciones de alguna regla y no son la conclusión de
    ninguna, es decir, lo que el sistema debe observar.
11. ★ **(2)** Agregar al simplificador las reglas que agrupan términos
    semejantes —`N * X + X`, `X + N * X` y `N * X + M * X`— para que
    `simplificar(2 * x + (y - y) * z + x ^ 1, E)` dé `E = 3*x`. Explicar por
    qué la simplificación sigue terminando.
12. **(2)** Escribir `evaluar(E, Valores, V)`: V es el valor de la expresión E
    con las incógnitas reemplazadas por los valores de la lista de pares
    Valores. Una incógnita sin valor produce `existence_error(incognita, X)`.
13. **(3)** Escribir `derivar(E, X, D)`: D es la derivada de E respecto de la
    incógnita X, para `+`, `-`, `*` y `^` con exponente numérico, simplificada
    con `simplificar/2`.

## Resumen

| | |
|---|---|
| `var/1`, `nonvar/1`, `atom/1`, `number/1`, `integer/1`, `float/1`, `atomic/1`, `compound/1`, `callable/1`, `is_list/1`, `ground/1` | pruebas de tipo: responden sobre el estado actual del término; no son relaciones |
| `is_of_type/2` | prueba de tipo con los tipos de `must_be/2`; falla donde `must_be/2` produce un error |
| `must_be/2` | verificar el tipo antes de comparar: error de instanciación o de tipo |
| `sin/1` | el seno, en radianes, como función de `is/2`; en las soluciones, `derivar/3` rechaza `sin(x)` con un error de dominio |
| `functor/3` | nombre y aridad de un término, o un término nuevo con ese nombre y aridad |
| `arg/3` | el argumento N de un término; con N libre, enumera |
| `=..` | un término y la lista de su nombre y sus argumentos |
| `compound_name_arguments/3`, `compound_name_arity/3` | como `=..` y `functor/3`, solo para compuestos, incluidos los de aridad 0 |
| `sub_term/2` | los subtérminos de un término |
| `max_list/2` | el mayor elemento de una lista de números (en las soluciones) |
| `mapargs/3`, `mapsubterms/3`, `foldsubterms/4` | los recorridos de `library(terms)` |
| `copy_term/2` | una copia con variables nuevas |
| `term_variables/2` | las variables distintas de un término |
| `=@=` | los términos son variantes |
| `numbervars/3` | ligar las variables a `'$VAR'(N)` para escribirlas con nombre |
| **Patrones 43, 44** | recorrido genérico de un término; representación limpia |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Los objetivos de un programa como términos: un intérprete de Prolog en Prolog | [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) |
| Términos con variables que se completan después | [capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md) |
| Cláusulas transformadas como términos al cargar el programa | [capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) |
| Un programa leído como datos para verificar su estratificación | [capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md) |
| El simplificador dentro de un programa que resuelve ecuaciones | [capítulo 43](../capitulo-43-proyecto-resolver-ecuaciones/index.md) |
| La sintaxis abstracta de un lenguaje como representación limpia | [capítulo 45](../capitulo-45-proyecto-compilador/index.md) |

## Referencias

- Leon Sterling y Ehud Shapiro, *The Art of Prolog*, 2.ª ed., MIT Press, 1994 — «Structure Inspection» y
  «Meta-Logical Predicates» ([edición en línea](https://archive.org/details/artofprologadvan00ster)): las pruebas
  de tipo, `functor/3`, `arg/3`, `=..`, la búsqueda y sustitución de subtérminos, `==` y `numbervars/3`.
- Markus Triska, *The Power of Prolog* — «Prolog Data Structures» ([edición en línea](https://www.metalevel.at/prolog/data)):
  la falta de monotonía de las pruebas de tipo y las representaciones limpias y por defecto.
- William F. Clocksin y Christopher S. Mellish, *Programming in Prolog*, 5.ª ed., Springer, 2003 — «Classifying
  Terms», «Constructing and Accessing Components of Structures», «Symbolic Differentiation» y «Mapping Structures
  and Transforming Trees»: el recorrido que transforma cada componente y la derivada del [ejercicio 13](#ejercicios).
- Michael A. Covington, Donald Nute y André Vellino, *Prolog Programming in Depth*, Prentice Hall, 1997 —
  «How to Search or Process Any Structure» ([edición en línea](https://www.covingtoninnovations.com/books/PPID.pdf)):
  el recorrido de un término cualquiera con `=..`.
- Patrick Blackburn, Johan Bos y Kristina Striegnitz, *Learn Prolog Now!*, College Publications, 2006 —
  «Examining Terms» ([edición en línea](https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse39)):
  la presentación de las pruebas de tipo, `functor/3`, `arg/3` y `=..`.
- Paul Brna, *Prolog Programming: A First Course*, notas de curso, 2001 — «Powerful Features»: la tabla
  de las pruebas de tipo y un predicado que clasifica un término, como `clase/2`.

El código del capítulo es propio, escrito para el curso: las fuentes aportan ideas, no código.
