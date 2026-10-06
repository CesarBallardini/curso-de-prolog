# Capítulo 33 — Introspección y metaintérpretes

Un programa Prolog es un conjunto de cláusulas, y una cláusula es un término.
El [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md) mostró cómo examinar un término de forma desconocida; este
capítulo aplica esas herramientas al programa mismo. Con `clause/2`, un
programa lee sus propias cláusulas, y con ellas un intérprete de Prolog
escrito en Prolog —un **metaintérprete**— prueba objetivos igual que el
sistema, en tres cláusulas. Sobre ese intérprete se agrega, sin tocar el
programa que ejecuta, lo que el sistema no ofrece o no deja cambiar: otra
estrategia de búsqueda, el árbol de cada prueba, un límite de profundidad, un
rastreador y un depurador que localiza la cláusula incorrecta.

El [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md) escribió un intérprete para las reglas de un sistema
experto, `prueba/3`, que responde la pregunta «¿cómo?» para las conclusiones
que se prueban. La última sección lo extiende con las técnicas del capítulo:
el sistema pregunta al usuario las observaciones que faltan, explica **por qué** las
pregunta, y explica **por qué no** llegó a una conclusión. El capítulo cumple
tres anuncios: el intérprete de Prolog escrito en Prolog, del
[capítulo 12](../capitulo-12-prolog-y-la-logica/index.md) y del [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md), y el depurador escrito en Prolog, del
[capítulo 26](../capitulo-26-pruebas-y-depuracion/index.md). Sigue «A Couple of Meta-interpreters in Prolog» de Markus Triska e
«Interpreters» de Pereira y Shieber; las demás fuentes están en las [referencias](#referencias).

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- obtener las cláusulas de un predicado con `clause/2` y sus propiedades con
  `predicate_property/2`, y saber qué predicados no se pueden leer;
- escribir el intérprete vainilla, y distinguir lo que un intérprete absorbe
  de Prolog de lo que reifica;
- variar un intérprete en la estrategia de búsqueda, el procedimiento de
  prueba, las construcciones que admite y la información que devuelve;
- construir el árbol de una prueba, limitar la profundidad de la búsqueda y
  buscar con profundización iterativa;
- escribir un rastreador, y localizar con un oráculo la cláusula responsable
  de una respuesta incorrecta y el objetivo responsable de una respuesta que
  falta;
- explicar las conclusiones de un sistema experto y las que no alcanza.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:35 h**.
    Resolver los 6 ejercicios marcados con ★: **1:35 h**.
    Resolver los 14 ejercicios del final: **4:40 h**.

## 33.1 El programa como datos

`clause(Cabeza, Cuerpo)` se cumple si el programa tiene una cláusula que
unifica con `Cabeza :- Cuerpo`. Un hecho tiene el cuerpo `true`, y el cuerpo de
una regla es un término: la conjunción es el operador `,` de aridad 2. En
`programa.pl`, con la familia de los capítulos anteriores:

```prolog
?- clause(abuelo(A, N), Cuerpo).
Cuerpo = (padre(A, _A), padre(_A, N)).
```

Las cláusulas llegan en el orden del programa, una por respuesta, y cada una
con **variables nuevas**: `_A` es la variable P de la regla, renombrada, como
Prolog renombra cada cláusula que usa ([capítulo 5](../capitulo-05-como-responde-prolog/index.md)). La cabeza debe
llegar instanciada al menos hasta su nombre y aridad: con una variable libre,
`clause/2` produce un error de instanciación. `clausulas/2` reúne las
cláusulas de un predicado a partir de su indicador:

<!-- ejemplo: capitulo-33/programa.pl predicado: clausulas/2 consulta: clausulas(antepasado/2, Cs). -->
```prolog
%!  clausulas(+Indicador, -Clausulas:list) is semidet.
%
%   Clausulas son las cláusulas del predicado Nombre/Aridad, en el orden del
%   programa, como términos Cabeza :- Cuerpo; un hecho tiene el cuerpo true.
%   Falla si el predicado no está definido.
clausulas(Nombre/Aridad, Clausulas) :-
    current_predicate(Nombre/Aridad),
    functor(Cabeza, Nombre, Aridad),
    findall(Cabeza :- Cuerpo, clause(Cabeza, Cuerpo), Clausulas).
```

```prolog
?- clausulas(antepasado/2, Cs).
Cs = [(antepasado(_A, _B):-padre(_A, _B)), (antepasado(_C, _D):-padre(_C, _E), antepasado(_E, _D))].
```

`current_predicate(Nombre/Aridad)` se cumple si el predicado está definido; no
carga de la biblioteca los que todavía no se usaron, así que
`current_predicate(append/3)` falla hasta la primera llamada a `append/3`.
`predicate_property(Cabeza, Propiedad)` informa lo que el sistema registra de
un predicado: `dynamic`, `built_in`, `number_of_clauses(N)`, el archivo y la
línea donde está escrito. `describir/2`, en el mismo archivo, las combina, y
para `atom_length/2` responde `predefinido`:

```prolog
?- describir(visita/1, D).
D = dinamico(1).
```

Los predicados predefinidos no tienen cláusulas que se puedan leer: muchos
están escritos en C, y los que están escritos en Prolog son privados.
`clause/2` produce un error de permiso con ellos:

```prolog
?- clause(atom_length(A, L), C).
ERROR: No permission to access private_procedure `atom_length/2'
```

Con un predicado que no existe, en cambio, `clause/2` falla sin error, donde la
llamada produce un error de existencia. Los predicados del programa se pueden
leer, estáticos o dinámicos, salvo que el programa active la opción
`protect_static_code` con `set_prolog_flag/2`: entonces solo los declarados
`dynamic` son legibles, y declararlos así es la forma portable de garantizar
que un intérprete pueda leerlos. SWISH permite `clause/2` sobre el programa
del usuario, y `make swish` lo verifica para todos los intérpretes del
capítulo; no permite `predicate_property/2` sobre una cabeza que se conoce
recién durante la ejecución, y por eso `programa.pl` corre solo en `swipl`.

## 33.2 El intérprete vainilla

Un intérprete de Prolog en Prolog necesita tres casos: `true` se cumple, una
conjunción se prueba probando sus dos partes, y cualquier otro objetivo se
prueba con una cláusula cuya cabeza unifica con él y cuyo cuerpo se prueba a
su vez. Es el **intérprete vainilla**, llamado así porque no agrega nada a lo
que Prolog ya hace:

<!-- ejemplo: capitulo-33/vainilla.pl predicado: resolver/1 consulta: resolver(antepasado(A, eva)). -->
```prolog
%!  resolver(+Meta) is nondet.
%
%   Meta se prueba con las cláusulas del programa: una respuesta por cada
%   prueba. Meta es true, una conjunción o un objetivo de un predicado del
%   programa; con un predicado predefinido, clause/2 produce un error.
resolver(true).
resolver((A, B)) :-
    resolver(A),
    resolver(B).
resolver(Meta) :-
    Meta \= true,
    Meta \= (_, _),
    clause(Meta, Cuerpo),
    resolver(Cuerpo).
```

!!! question "Actividad"
    Predecir en qué orden da `resolver(antepasado(A, eva))` sus respuestas,
    y compararlo con el de `antepasado(A, eva)`.

```prolog
?- resolver(antepasado(A, eva)).
A = luis ;
A = juan ;
A = ana ;
false.
```

El orden es el de Prolog: `resolver/1` no hace la unificación, la hace
`clause/2`. Tampoco hace el retroceso: cuando una prueba falla, Prolog vuelve a
`clause/2`, que da la cláusula siguiente. El intérprete **absorbe** la
unificación y el retroceso: los toma de Prolog sin representarlos. La
conjunción, en cambio, está **reificada**: es un término que el intérprete
examina, y su cláusula decide en qué orden se prueban las partes. Lo absorbido
no se puede observar ni cambiar sin reificarlo; lo reificado, sí. La tercera
cláusula tiene el defecto de las representaciones por defecto de la
[sección 32.6](../capitulo-32-inspeccion-de-terminos/index.md#326-representaciones-limpias): reconoce un objetivo por lo que **no** es, y cualquier objetivo
que no sea `true` ni una conjunción llega a `clause/2`. Con una comparación, el
resultado es el error de permiso de la sección anterior:

```prolog
?- resolver(mayor_que(juan, ana)).
ERROR: No permission to access private_procedure `(>)/2'
```

La corrección es la del [Patrón 44](../patrones.md#44-representacion-limpia): un functor por clase de objetivo.
`limpio.pl` lee cada cláusula con `clausula/2`, que convierte su cuerpo una
sola vez con `limpiar/2` y marca cada objetivo: `prog(G)` para uno del
programa, `sis(G)` para uno predefinido. Los predefinidos admitidos son los
que enumera `predefinido/1`, y `ejecutar/1` los ejecuta con una cláusula para
cada uno, como el intérprete de reglas del [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md): sin `call/1` sobre
un objetivo que llega de los datos, el intérprete corre en SWISH.

```prolog
?- limpiar((edad(A, EA), edad(B, EB), EA > EB), C).
C = (prog(edad(A, EA)), prog(edad(B, EB)), sis(EA>EB)).
```

`limpiar/2` es una conversión en el borde, como pide el [Patrón 37](../patrones.md#37-convertir-en-el-borde): usa
cortes y un caso por defecto, pero sobre un cuerpo ya escrito y una vez por
cláusula. El intérprete elige el caso por unificación en la cabeza:

<!-- ejemplo: capitulo-33/limpio.pl predicado: resolver_cuerpo/1 consulta: resolver(mayor_que(juan, P)). -->
```prolog
%!  resolver_cuerpo(+Cuerpo) is nondet.
%
%   Cuerpo, en la representación limpia, se prueba con las cláusulas del
%   programa y los predefinidos de ejecutar/1.
resolver_cuerpo(true).
resolver_cuerpo((A, B)) :-
    resolver_cuerpo(A),
    resolver_cuerpo(B).
resolver_cuerpo(sis(G)) :-
    ejecutar(G).
resolver_cuerpo(prog(G)) :-
    clausula(G, Cuerpo),
    resolver_cuerpo(Cuerpo).
```

```prolog
?- resolver(mayor_que(juan, P)).
P = ana ;
P = pedro.
```

Cada objetivo interpretado pasa por `resolver_cuerpo/1`, `clausula/2`,
`clause/2` y `limpiar/2` antes de llegar a su cuerpo. `longitud/2`, en
`limpio.pl`, cuenta los elementos de una lista con recursión; con `time/1`,
del [capítulo 16](../capitulo-16-rendimiento/index.md), sobre una lista de 100 000 elementos, la llamada directa y
la interpretada dan:

```text
?- numlist(1, 100000, L), time(longitud(L, N)).
% 200,000 inferences, 0.047 CPU in 0.052 seconds (91% CPU, 4266667 Lips)

?- numlist(1, 100000, L), time(resolver(longitud(L, N))).
% 1,200,005 inferences, 0.219 CPU in 0.254 seconds (86% CPU, 5485737 Lips)
```

Seis veces más inferencias y un tiempo casi cinco veces mayor: el costo de un
intérprete que absorbe casi todo. Uno que reificara también la unificación,
con su propia representación de las sustituciones, pagaría mucho más. El
[capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) elimina este costo especializando el intérprete para un programa
dado.

!!! example "Patrón 45 — Intérprete que absorbe"
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

## 33.3 Variar el intérprete

Peter Flach, en «Meta-programs» de *Simply Logical*, clasifica las variantes de
un intérprete en cuatro clases: otra **estrategia de búsqueda**, otro
**procedimiento de prueba**, **más clases de objetivos** e **información
adicional** sobre la prueba. Cada una cambia unas pocas cláusulas del intérprete
y ninguna cambia el programa. `variantes.pl` tiene una de cada clase.

**La estrategia.** Como la conjunción está reificada, el orden de sus partes
es una decisión del intérprete. `antepasado_izq/2` tiene la recursión a la
izquierda, y Prolog no termina de explorarla ([sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas)):

```text
?- antepasado_izq(A, eva).
A = luis ;
A = ana ;
A = juan ;
ERROR: Stack limit (1.0Gb) exceeded
```

`resolver_der/1` es el intérprete con una sola cláusula distinta, la de la
conjunción, que prueba primero la parte derecha:

<!-- ejemplo: capitulo-33/variantes.pl fragmento: der((A, B)) :- .. der(A). consulta: resolver_der(antepasado_izq(A, eva)). -->
```prolog
der((A, B)) :-
    der(B),
    der(A).
```

`resolver_der(antepasado_izq(A, eva))` da las mismas tres respuestas y
termina con `false.`: con `padre(H, eva)` probado antes que la recursión, H
llega ligada. La estrategia no es mejor en general: con `antepasado/2`,
cuya recursión está a la derecha, `resolver_der/1` no termina después de la
última respuesta. El orden sigue importando; lo que cambió es quién lo decide.

**El procedimiento de prueba.** `resolver_lista/1` trabaja sobre la
**resolvente**, la lista de objetivos pendientes: en cada paso reemplaza el
primero por el cuerpo de una de sus cláusulas, puesto delante de los demás,
como la resolución de la [sección 12.5](../capitulo-12-prolog-y-la-logica/index.md#125-como-prueba-prolog). Es la forma que necesita
cualquier estrategia que guarde varias resolventes a la vez, como la búsqueda
en anchura del [ejercicio 6](#ejercicios).

**Más clases de objetivos.** La negación como falla se agrega con una
conversión, de `\+ G` a `no(C)`, y una cláusula que la prueba con la negación
de Prolog: `resolver_cuerpo(no(C)) :- \+ resolver_cuerpo(C).` Así,
`resolver(sin_hijos(P))` da las personas que no son padres de nadie, pedro y
eva.

**Información adicional.** `resolver_pasos/2` cuenta las cláusulas que usa una
prueba, con un par de argumentos acumuladores como los de la
[sección 8.5](../capitulo-08-aritmetica/index.md#85-acumuladores): `resolver_pasos(antepasado(juan, eva), N)` da `N = 6`, tres usos
de `antepasado/2` y tres hechos de `padre/2`. Los intentos que
fallan no se cuentan, porque el retroceso deshace también la ligadura del
contador: el acumulador describe la prueba, no la búsqueda.

## 33.4 Árboles de prueba

El dato más útil que un intérprete puede devolver es la prueba misma. El
**árbol de prueba** de un objetivo tiene el objetivo en la raíz y, como hijos,
los árboles de los objetivos del cuerpo de la cláusula que lo probó; un hecho
es una hoja. `arbol.pl` lo construye con una gramática del
[capítulo 21](../capitulo-21-gramaticas-dcg/index.md): `pruebas//1` describe la lista de las pruebas de los
objetivos de un cuerpo, y `resolver(Meta, Arbol)` toma la lista de un solo
elemento que corresponde a `prog(Meta)`.

<!-- ejemplo: capitulo-33/arbol.pl predicado: pruebas//1 consulta: resolver(antepasado(juan, luis), Arbol). -->
```prolog
%!  pruebas(+Cuerpo)// is nondet.
%
%   Cuerpo se prueba, y la lista describe las pruebas de sus objetivos, de
%   izquierda a derecha: prueba(G, Hijos) para un objetivo del programa,
%   sis(G) para un predefinido.
pruebas(true) -->
    [].
pruebas((A, B)) -->
    pruebas(A),
    pruebas(B).
pruebas(sis(G)) -->
    { ejecutar(G) },
    [sis(G)].
pruebas(prog(G)) -->
    { clausula(G, Cuerpo),
      phrase(pruebas(Cuerpo), Hijos) },
    [prueba(G, Hijos)].
```

```prolog
?- resolver(antepasado(juan, luis), Arbol).
Arbol = prueba(antepasado(juan, luis), [prueba(padre(juan, ana), []), prueba(antepasado(ana, luis), [prueba(padre(ana, luis), [])])]) ;
false.
```

El árbol es un término, y se recorre con una cláusula por cada forma de nodo.
`mostrar/1` escribe cada objetivo en su línea, con los hijos sangrados, y
`como/1` escribe cada prueba de un objetivo:

```prolog
?- como(mayor_que(juan, ana)).
mayor_que(juan, ana)
  edad(juan, 68)
  edad(ana, 41)
  68>41
true.
```

Cada prueba tiene su árbol: dos pruebas de la misma respuesta dan dos árboles, y
así se distinguen las respuestas repetidas de la [sección 12.6](../capitulo-12-prolog-y-la-logica/index.md#126-lo-que-excede-la-logica). La explicación
de `prueba/3` en el [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md) tenía la misma forma, escrita dentro del
intérprete de un lenguaje de reglas; `resolver/2` la obtiene para cualquier
programa. Un objetivo que falla, en cambio, no tiene árbol, y explicar una falla
requiere otra técnica, la de las secciones [33.6](#336-un-depurador-en-prolog) y [33.7](#337-el-sistema-experto-explica).

## 33.5 Límites de profundidad y profundización iterativa

`camino/3`, en `profundidad.pl`, busca caminos en un grafo cuyas aristas van y
vuelven. La primera arista que sale de `b` vuelve a `a`, y Prolog recorre el
ciclo sin fin:

```text
?- camino(a, c, C).
ERROR: Stack limit (1.0Gb) exceeded
```

La respuesta existe, a la derecha de una rama infinita
([sección 5.6](../capitulo-05-como-responde-prolog/index.md#56-ramas-infinitas)). Un intérprete puede negarse a seguir una rama más allá de
cierta profundidad: `resolver_limite/2` lleva la profundidad que queda como
argumento, y no usa una cláusula cuando llega a cero.

<!-- ejemplo: capitulo-33/profundidad.pl predicado: limite/2 consulta: resolver_limite(camino(a, c, C), 4). -->
```prolog
%!  limite(+Cuerpo, +N:integer) is nondet.
%
%   Cuerpo se prueba sin usar cláusulas a más de N niveles de profundidad.
limite(true, _).
limite((A, B), N) :-
    limite(A, N),
    limite(B, N).
limite(sis(G), _) :-
    ejecutar(G).
limite(prog(G), N) :-
    N > 0,
    N1 is N - 1,
    clausula(G, Cuerpo),
    limite(Cuerpo, N1).
```

```prolog
?- resolver_limite(camino(a, c, C), 4).
C = [a-b, b-c] ;
false.

?- resolver_limite(camino(a, d, C), 3).
false.
```

La búsqueda termina siempre, pero su `false.` perdió el significado: el
segundo no dice que no haya camino de `a` a `d`, sino que no hay uno cuya
prueba quepa en tres niveles. Ningún límite fijo sirve para todas las
consultas. La **profundización iterativa** prueba con límites 0, 1, 2…, que
`length(_, N)` genera uno por respuesta:

<!-- ejemplo: capitulo-33/profundidad.pl predicado: resolver_iterativo_ingenuo/1 consulta: limit(4, resolver_iterativo_ingenuo(camino(a, c, C))). -->
```prolog
%!  resolver_iterativo_ingenuo(+Meta) is nondet.
%
%   Meta se prueba con límites de profundidad crecientes. Cada respuesta se
%   repite en todos los límites mayores que su altura, sin fin.
resolver_iterativo_ingenuo(Meta) :-
    length(_, N),
    resolver_limite(Meta, N).
```

!!! question "Actividad"
    Predecir las cuatro primeras respuestas de
    `limit(4, resolver_iterativo_ingenuo(camino(a, c, C)))` a partir de la
    altura de cada prueba, y comprobarlo.

```prolog
?- limit(4, resolver_iterativo_ingenuo(camino(a, c, C))).
C = [a-b, b-c] ;
C = [a-b, b-c] ;
C = [a-b, b-a, a-b, b-c] ;
C = [a-b, b-c].
```

Una prueba que cabe en el límite N cabe en todos los mayores, y cada respuesta
se repite en cada iteración siguiente. `resolver_iterativo/1` acepta en la
iteración N solo las pruebas de altura exactamente N:
`length(_, N), altura(prog(Meta), N, N)`, donde `altura/3` calcula la altura
de la prueba, la mayor cantidad de cláusulas en una rama.

<!-- ejemplo: capitulo-33/profundidad.pl predicado: altura/3 consulta: limit(3, resolver_iterativo(camino(a, c, C))). -->
```prolog
%!  altura(+Cuerpo, +N:integer, ?H:integer) is nondet.
%
%   Cuerpo se prueba sin pasar de N niveles, y H es la altura de la
%   prueba: la mayor cantidad de cláusulas en una rama.
altura(true, _, 0).
altura((A, B), N, H) :-
    altura(A, N, HA),
    altura(B, N, HB),
    H is max(HA, HB).
altura(sis(G), _, 0) :-
    ejecutar(G).
altura(prog(G), N, H) :-
    N > 0,
    N1 is N - 1,
    clausula(G, Cuerpo),
    altura(Cuerpo, N1, H0),
    H is H0 + 1.
```

```prolog
?- limit(3, resolver_iterativo(camino(a, c, C))).
C = [a-b, b-c] ;
C = [a-b, b-a, a-b, b-c] ;
C = [a-b, b-c, c-b, b-c].
```

Cada prueba aparece una vez, las más cortas primero: la búsqueda es
**completa**, porque cualquier prueba llega en alguna iteración. Lo que no hace
es terminar cuando las respuestas se acaban: la iteración siguiente siempre
puede tener una prueba más. Repetir las iteraciones anteriores parece un
desperdicio, y no lo es cuando la cantidad de ramas crece con la profundidad: la
última iteración tiene más nodos que todas las anteriores juntas. Con `time/1`,
la primera respuesta de `camino(a, f, C)`, de altura 6, por profundización
iterativa y por la sola iteración de altura 6:

```text
?- time(once(resolver_iterativo(camino(a, f, C)))).
% 820 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)

?- time(once(altura(prog(camino(a, f, C)), 6, 6))).
% 382 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
```

Las siete iteraciones, de 0 a 6, cuestan poco más del doble que la última. El
[capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) usa la misma técnica sobre espacios de estados, y el [capítulo 39](../capitulo-39-tabulacion/index.md)
resuelve la recursión a la izquierda de otra manera, con tablas.
`call_with_depth_limit/3` es el límite de profundidad predefinido: ejecuta un
objetivo sin intérprete, y liga su tercer argumento a la profundidad
alcanzada, o a `depth_limit_exceeded` cuando no hay prueba dentro del límite
y la búsqueda llegó a él.

## 33.6 Un depurador en Prolog

El depurador de la [sección 26.3](../capitulo-26-pruebas-y-depuracion/index.md#263-el-depurador-en-la-terminal) muestra los cuatro puertos del modelo de
cajas de la [sección 5.3](../capitulo-05-como-responde-prolog/index.md#53-el-mismo-recorrido-registrado-por-trace). Un intérprete los produce con dos predicados de
dos cláusulas cada uno, que `rastro/2`, en `rastreo.pl`, llama antes de buscar
la cláusula de un objetivo y después de probar su cuerpo. La primera cláusula
de `entrar/2` escribe la llamada; si la búsqueda vuelve atrás hasta ella, el
objetivo no tiene más respuestas, y la segunda escribe la falla y falla.
`salir/2` hace lo mismo con la salida y el reintento:

<!-- ejemplo: capitulo-33/rastreo.pl predicado: entrar/2 salir/2 consulta: rastrear(abuelo(juan, N)). -->
```prolog
%!  entrar(+G, +Nivel:integer) is det.
%
%   Escribe el puerto Call de G. Al volver atrás hasta aquí, G no tiene más
%   respuestas: escribe el puerto Fail y falla.
entrar(G, Nivel) :-
    puerto('Call', G, Nivel).
entrar(G, Nivel) :-
    puerto('Fail', G, Nivel),
    fail.

%!  salir(+G, +Nivel:integer) is det.
%
%   Escribe el puerto Exit de G. Al volver atrás hasta aquí, se busca otra
%   respuesta de G: escribe el puerto Redo y falla.
salir(G, Nivel) :-
    puerto('Exit', G, Nivel).
salir(G, Nivel) :-
    puerto('Redo', G, Nivel),
    fail.
```

!!! question "Actividad"
    Con `padre(juan, ana)`, `padre(juan, pedro)` y `padre(pedro, luis)`,
    predecir las líneas que escribe `rastrear(abuelo(juan, N))` hasta la
    primera respuesta, y compararlas con las de la [sección 5.3](../capitulo-05-como-responde-prolog/index.md#53-el-mismo-recorrido-registrado-por-trace).

```prolog
?- rastrear(abuelo(juan, N)).
Call: (1) abuelo(juan, A)
Call: (2) padre(juan, A)
Exit: (2) padre(juan, ana)
Call: (2) padre(ana, A)
Fail: (2) padre(ana, A)
Redo: (2) padre(juan, ana)
Exit: (2) padre(juan, pedro)
Call: (2) padre(pedro, A)
Exit: (2) padre(pedro, luis)
Exit: (1) abuelo(juan, luis)
N = luis ;
Redo: (1) abuelo(juan, luis)
Redo: (2) padre(pedro, luis)
Fail: (2) padre(pedro, A)
Redo: (2) padre(juan, pedro)
Fail: (2) padre(juan, A)
Fail: (1) abuelo(juan, A)
false.
```

Hasta la primera respuesta, la secuencia es la del depurador del sistema, con
dos diferencias: el reintento muestra el objetivo con las ligaduras de la
salida anterior, y las variables se escriben A, B…, con `numbervars/3` dentro
de una doble negación ([sección 32.5](../capitulo-32-inspeccion-de-terminos/index.md#325-variables-como-datos)). Y este depurador se puede
cambiar: filtrar predicados, detenerse en una profundidad, preguntar.

### Depuración algorítmica

La [sección 26.6](../capitulo-26-pruebas-y-depuracion/index.md#266-depuracion-declarativa) localizó errores preguntando a los predicados por sus
respuestas y juzgándolas a mano. Ehud Shapiro mostró en su tesis doctoral,
*Algorithmic Program Debugging* (1983), que esa búsqueda se puede mecanizar: un
intérprete recorre la prueba y pregunta a un **oráculo**, que conoce el
significado que el programa debería tener, si cada objetivo es verdadero. El
oráculo puede ser una persona o, como en `diagnostico.pl`, un predicado:
`pretendido/1` dice que ordenar una lista es obtener la de `msort/2`.
`ordenar_incorrecto/2` ordena por inserción, y responde mal:

```prolog
?- ordenar_incorrecto([3, 1, 2], S).
S = [1, 3] ;
false.
```

Si la raíz de un árbol de prueba es falsa, o alguno de sus hijos es falso, o
todos son verdaderos. En el segundo caso, la cláusula usada en la raíz tiene el
cuerpo verdadero y la cabeza falsa: es incorrecta, y el error está ahí. En el
primero, se repite el razonamiento con el hijo falso. `clausula_falsa/2` baja
por el árbol de `resolver/2` siguiendo esa regla, y `respuesta_incorrecta/2` la
aplica a la prueba de cada respuesta que el oráculo rechaza:

<!-- ejemplo: capitulo-33/diagnostico.pl predicado: clausula_falsa/2 consulta: respuesta_incorrecta(ordenar_incorrecto([3, 1, 2], S), Clausula). -->
```prolog
%!  clausula_falsa(+Arbol, -Clausula) is det.
%
%   La raíz de Arbol es falsa según el oráculo. Si algún hijo también lo
%   es, la cláusula falsa está debajo de él; si no, es la de la raíz.
clausula_falsa(prueba(G, Hijos), Clausula) :-
    (   member(prueba(H, Nietos), Hijos),
        \+ pretendido(H)
    ->  clausula_falsa(prueba(H, Nietos), Clausula)
    ;   maplist(objetivo, Hijos, Objetivos),
        conjuncion(Objetivos, Cuerpo),
        Clausula = (G :- Cuerpo)
    ).
```

```prolog
?- respuesta_incorrecta(ordenar_incorrecto([3, 1, 2], S), Clausula).
S = [1, 3],
Clausula = (insertar_incorrecto(1, [2], [1]):-1=<2) ;
false.
```

Insertar 1 en `[2]` no da `[1]`, aunque `1 =< 2` sea verdadero: la tercera
cláusula de `insertar_incorrecto/3` pierde el primer elemento de la lista. El
diagnóstico nombra la cláusula y el caso que la refuta, después de consultar
al oráculo por cuatro objetivos y sin examinar una traza.

Una respuesta que **falta** no tiene árbol de prueba. `ordenar_incompleto/2`
falla con cualquier lista no vacía. Si un objetivo es verdadero y el programa
no lo prueba, alguna cláusula debería probarlo: una cuyo cuerpo sea verdadero
según el oráculo. Si una lo tiene, alguno de los objetivos de ese cuerpo es
verdadero y el programa no lo prueba, y la búsqueda sigue por él. Si ninguna
lo tiene, el objetivo **no está cubierto**: falta una cláusula para él, o la
que debería probarlo está mal escrita.

<!-- ejemplo: capitulo-33/diagnostico.pl predicado: no_cubierto/2 consulta: respuesta_faltante(ordenar_incompleto([2, 1], S), Objetivo). -->
```prolog
%!  no_cubierto(+Meta, -Objetivo) is det.
%
%   Meta es verdadero y el programa no lo prueba. Si una cláusula tiene el
%   cuerpo verdadero, alguno de sus objetivos no se prueba, y la búsqueda
%   sigue por él; si ninguna lo tiene, el objetivo es Meta.
no_cubierto(Meta, Objetivo) :-
    (   clausula(Meta, Cuerpo),
        cuerpo_pretendido(Cuerpo),
        no_probado(Cuerpo, G)
    ->  no_cubierto(G, Objetivo)
    ;   Objetivo = Meta
    ).
```

```prolog
?- respuesta_faltante(ordenar_incompleto([2, 1], S), Objetivo).
S = [1, 2],
Objetivo = insertar_incompleto(1, [], [1]).
```

Insertar 1 en la lista vacía es verdadero, y ninguna cabeza de
`insertar_incompleto/3` unifica con ese objetivo: falta la cláusula de la
lista vacía. Aquí el oráculo, además de juzgar, **liga** las variables de los
cuerpos a los valores que deberían tener, como `msort/2` liga la lista
ordenada: `cuerpo_pretendido/1` lo pide para un cuerpo entero, y
`no_probado/2` busca en él el primer objetivo que el programa no prueba.

!!! example "Patrón 46 — Extender el intérprete, no el programa"
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
    el programa, como hace el [capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md), o se usan las herramientas del
    sistema, como el depurador y `call_with_depth_limit/3`.

## 33.7 El sistema experto explica

El sistema experto del [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md) tiene un intérprete propio porque sus
reglas no son cláusulas de Prolog sino términos con los operadores `si`,
`entonces` e `y`. Explica cómo llegó a una conclusión, y nada más: las
observaciones llegan juntas, en una lista, y una hipótesis que no se prueba
da `false.` sin explicación. `experto.pl` conserva las reglas, las hipótesis,
los casos y `explicar/2`, y reemplaza `prueba/3` por `demostrar/4`, con dos
argumentos más. La **fuente** de las observaciones es `lista(Os)`, como en
`prueba/3`, o `usuario`: el sistema pregunta cada observación cuando la
necesita. La **pila** tiene las reglas en curso, cada una con la conclusión
que intenta probar, la más reciente primero. `observable/1` enumera las
condiciones que se observan, las que ninguna regla concluye. Las dos últimas
cláusulas de `demostrar/4` son las que cambian:

<!-- ejemplo: capitulo-33/experto.pl fragmento: demostrar(Meta, Fuente, Pila, observado(Meta)) :- .. preguntar(Meta, Pila). consulta: caso(1, Obs), identificar(Obs, Animal). -->
```prolog
demostrar(Meta, Fuente, Pila, observado(Meta)) :-
    observable(Meta),
    observar(Fuente, Meta, Pila).
demostrar(Meta, Fuente, Pila, deducido(Meta, Regla, Arbol)) :-
    regla(Regla, si Condiciones entonces Meta),
    demostrar(Condiciones, Fuente, [Regla-Meta|Pila], Arbol).

%!  observar(+Fuente, ?Meta, +Pila:list) is nondet.
%
%   Meta se observa según Fuente: está en la lista, o el usuario lo
%   confirma.
observar(lista(Observaciones), Meta, _) :-
    member(Meta, Observaciones).
observar(usuario, Meta, Pila) :-
    preguntar(Meta, Pila).
```

Con la lista, `identificar/2` y `como/2` responden lo mismo que en el
[capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md), con árboles de la misma forma. Con el usuario, la pila responde
la pregunta **«¿por qué?»**: `preguntar/2` lee la respuesta con `read/1`, y
mientras sea `por_que`, escribe el motivo y vuelve a preguntar.

<!-- ejemplo: capitulo-33/experto.pl predicado: motivo/2 consulta: caso(1, Obs), identificar(Obs, Animal). -->
```prolog
%!  motivo(+Meta, +Pila:list) is det.
%
%   Escribe para qué se pregunta Meta: cada conclusión en curso, con su
%   regla, de la más reciente a la hipótesis.
motivo(Meta, Pila) :-
    format("~w se pregunta para probar:~n", [Meta]),
    forall(member(Regla-Conclusion, Pila),
           format("  ~w, con la regla ~w~n", [Conclusion, Regla])).
```

Una sesión con `consultar/1`, en la que el usuario responde `por_que` a la
primera pregunta y `si` a las demás:

```text
?- consultar(Animal).
¿tiene_pelo? por_que.
tiene_pelo se pregunta para probar:
  mamifero, con la regla r1
  carnivoro, con la regla r5
  guepardo, con la regla r7
¿tiene_pelo? si.
¿come_carne? si.
¿color_leonado? si.
¿manchas_oscuras? si.
guepardo: por r7
  carnivoro: por r5
    mamifero: por r1
      tiene_pelo: observado
    come_carne: observado
  color_leonado: observado
  manchas_oscuras: observado
Animal = guepardo .
```

Las respuestas quedan en `respondida/2`, un predicado dinámico, y ninguna
pregunta se repite al pasar a la hipótesis siguiente: la memorización del
[Patrón 17](../patrones.md#17-memorizacion-con-assertz), aplicada a lo que se le pregunta al usuario. A una pregunta con
variables, como `peso(P)`, se responde con el término completo: `peso(90).`
La pregunta **«¿por qué no?»** pide explicar una falla, que no tiene árbol.
`no_se_prueba/3` la explica como `no_cubierto/2` explicaba la respuesta que
faltaba: para cada regla que concluye el objetivo, busca la primera condición
que no se cumple, y baja por ella. En una conjunción, usa las ligaduras de la
primera prueba de las condiciones anteriores:

<!-- ejemplo: capitulo-33/experto.pl predicado: explicacion/3 consulta: caso(1, Obs), por_que_no(Obs, jirafa). -->
```prolog
%!  explicacion(+Condicion, +Observaciones:list, -Explicacion) is det.
%
%   Explicacion dice por qué Condicion, que no se prueba, falla. En una
%   conjunción, explica la primera condición que falla con las ligaduras
%   de la primera prueba de las anteriores.
explicacion(Condicion, Observaciones, Explicacion) :-
    (   Condicion = (A y B)
    ->  (   demostrar(A, lista(Observaciones), [], _)
        ->  explicacion(B, Observaciones, Explicacion)
        ;   explicacion(A, Observaciones, Explicacion)
        )
    ;   comparacion(Condicion)
    ->  Explicacion = no_se_cumple(Condicion)
    ;   observable(Condicion)
    ->  Explicacion = no_observado(Condicion)
    ;   findall(Regla-E,
                ( regla(Regla, si Condiciones entonces Condicion),
                  explicacion(Condiciones, Observaciones, E) ),
                Ramas),
        Explicacion = no_probado(Condicion, Ramas)
    ).
```

```prolog
?- caso(1, Obs), por_que_no(Obs, jirafa).
jirafa: no se prueba
  por r9:
    ungulado: no se prueba
      por r6:
        tiene_cascos: no observado
Obs = [tiene_pelo, come_carne, color_leonado, manchas_oscuras].
```

Con el caso 4, el avestruz no se prueba porque `30 > 50` no se cumple: en r12,
`peso(P)` ya ligó P a 30 cuando la comparación falla. Las tres preguntas usan el
mismo intérprete, y ninguna cambió las reglas: el [Patrón 46](../patrones.md#46-extender-el-interprete-no-el-programa) aplicado a un
lenguaje de reglas propio. El [capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) compila estas reglas a cláusulas de
Prolog para eliminar el costo del intérprete, y el [capítulo 87](../capitulo-87-proyecto-preguntas-en-castellano/index.md) usa las mismas
explicaciones para responder preguntas en castellano.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado de los intérpretes declara sus modos: `resolver(+Meta) is nondet`, una respuesta por prueba; `limpiar/2`, `clausula_falsa/2` y `mostrar/1` son `det` |
    | C4 | `limpiar/2`, `clausula_falsa/2`, `mostrar/1` y `describir/2` no dejan alternativas: sus pruebas no declaran `nondet` |
    | C7 | 141 pruebas en los doce archivos del capítulo; cada intérprete se compara con Prolog sobre el mismo programa (pruebas `antepasado_como_prolog`, `mayor_que_como_prolog`, `como_prolog`) |
    | C2, C3 del programa objeto | se conservan: el intérprete da las mismas respuestas en el mismo orden, así que la consulta más general y la estabilidad del programa no cambian |
    | lo que se pierde | el corte: `resolver(maximo(5, 3, M))` da `M = 5` y `M = 3` (prueba `maximo_interpretado`); el error de existencia, que se vuelve falla, contra C5 (prueba `no_definido_interpretado`); y los efectos laterales se repiten en cada iteración de `resolver_iterativo/1` |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Con `programa.pl`, predecir la respuesta de cada consulta y
   comprobarla: `clause(antepasado(juan, D), C).` ·
   `clause(visita(P), C).` · `clause(X, true).` ·
   `clause(no_definido(X), C).` · `current_predicate(abuelo/A).`
2. **(2)** Escribir `reglas(Indicador, N)`: N es la cantidad de cláusulas del
   predicado que son reglas, es decir, cuyo cuerpo no es `true`.
3. **(1)** Para `resolver/1` de `vainilla.pl`, `resolver_lista/1` y
   `resolver_iterativo/1`, decir qué absorbe cada intérprete de Prolog y qué
   reifica.
4. ★ **(2)** Agregar al intérprete de `limpio.pl` la disyunción `(A ; B)` y
   el condicional `(C -> T ; E)`: la conversión en `limpiar/2` y las
   cláusulas de `resolver_cuerpo/1`. Probarlo con un predicado que use cada
   uno. ¿Por qué el condicional se puede absorber y el corte no?
5. ★ **(2)** Predecir las respuestas de `resolver(maximo(3, 5, M))` y de
   `resolver(maximo(5, 3, M))` con `limpio.pl`, y comprobarlas. Explicar por
   qué ejecutar el corte con `call(!)` en lugar de `true` no cambiaría nada.
6. **(3)** Escribir `resolver_anchura/1`, que prueba en anchura: las
   resolventes forman una cola, y siempre se expande la más antigua.
   Comprobar que encuentra las respuestas de `antepasado_izq(A, eva)` y un
   camino de `a` a `c`.
7. **(2)** Escribir `hechos_usados(Arbol, Hechos)`: los hechos que usa una
   prueba de `arbol.pl`, de izquierda a derecha.
8. ★ **(2)** Escribir `resolver_acotado(Meta, Limite, Resultado)`: Resultado
   es `si` para cada prueba que cabe en el límite, y al final `agotado`, una
   sola vez y sin ligaduras, si alguna rama llegó al límite. Sin pruebas y
   sin llegar al límite, falla.
9. **(3)** Escribir `resolver_sin_ciclos/1`, que abandona una rama cuando un
   objetivo es una variante (`=@=`, [sección 32.5](../capitulo-32-inspeccion-de-terminos/index.md#325-variables-como-datos)) de uno de sus
   antepasados en la prueba. Probarlo con `antepasado_izq(A, eva)` y explicar
   la respuesta que falta.
10. **(2)** Escribir `rastrear_entradas/1`, un rastreador que escribe solo las
    llamadas y las salidas, con dos columnas de sangría por nivel.
11. ★ **(2)** `invertir_mal/2` invierte una lista con un acumulador, y
    `invertir_mal([a, b, c], Ys)` responde `Ys = [c]`. Escribir el oráculo y
    usar la depuración algorítmica para encontrar la cláusula incorrecta.
12. **(3)** Reemplazar el oráculo del ejercicio 11 por el usuario: el
    intérprete pregunta si cada objetivo es correcto, lee `si` o `no`, y no
    repite una pregunta ya respondida.
13. ★ **(2)** Agregar a `experto.pl` la negación `no` del
    [ejercicio 8 del capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/soluciones.md#8), en `demostrar/4` y en la explicación de
    «¿por qué no?», y reescribir r11 y r12 con `no vuela`. ¿Qué explica el
    sistema cuando la condición negada se prueba?
14. **(2)** Cambiar `motivo/2` para que la respuesta a «¿por qué?» muestre
    cada regla en curso completa, con sus condiciones.

## Resumen

| | |
|---|---|
| `clause/2` | las cláusulas de un predicado del programa, una por respuesta, con variables nuevas; error de permiso con un predefinido, falla con un predicado inexistente |
| `current_predicate/1` | el predicado está definido; con argumentos libres, enumera |
| `predicate_property/2` | lo que el sistema registra de un predicado: `dynamic`, `built_in`, `number_of_clauses(N)`… |
| `call_with_depth_limit/3` | ejecutar un objetivo con un límite de profundidad, sin intérprete |
| `read/1` | leer de la entrada actual un término terminado en punto, como la respuesta del usuario |
| intérprete vainilla | `true`, la conjunción, y `clause/2` para lo demás: absorbe la unificación y el retroceso, reifica la conjunción |
| representación limpia de los cuerpos | `prog(G)` y `sis(G)`, convertidos una vez con `limpiar/2`; los predefinidos admitidos, enumerados |
| variantes de un intérprete | estrategia, procedimiento de prueba, más construcciones, información adicional |
| árbol de prueba | `prueba(G, Hijos)`, construido con una gramática |
| profundización iterativa | `length(_, N)` genera los límites; solo las pruebas de altura N en la iteración N |
| depuración algorítmica | un oráculo juzga los objetivos: la cláusula falsa de una respuesta incorrecta, el objetivo no cubierto de una que falta |
| `current_input/1`, `set_input/1` | el stream de la entrada actual, y su cambio; en las pruebas, para responder al sistema experto desde un texto |
| **Patrones 45, 46** | intérprete que absorbe; extender el intérprete, no el programa |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| El intérprete especializado para un programa: las reglas del sistema experto compiladas a cláusulas | [capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) |
| El programa leído como datos para verificar su estratificación | [capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md) |
| La recursión a la izquierda que termina, con tablas en lugar de un intérprete | [capítulo 39](../capitulo-39-tabulacion/index.md) |
| La profundización iterativa y la búsqueda en anchura sobre espacios de estados | [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) |
| El intérprete de un lenguaje propio, antes de compilarlo | [capítulo 45](../capitulo-45-proyecto-compilador/index.md) |
| Las explicaciones de las respuestas, en preguntas en castellano | [capítulo 87](../capitulo-87-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- Markus Triska, *The Power of Prolog* — «A Couple of Meta-interpreters in Prolog» ([edición en línea](https://www.metalevel.at/acomip/)):
  el intérprete vainilla, la absorción y la reificación, los cuerpos limpios, el árbol de prueba y la profundización iterativa.
- Fernando C. N. Pereira y Stuart M. Shieber, *Prolog and Natural-Language Analysis*, CSLI, 1987 — «Interpreters» ([edición digital](http://www.mtome.com/Publications/PNLA/prolog-digital.pdf)):
  la absorción, los árboles de prueba, la búsqueda con profundidad acotada consecutiva y el problema del corte.
- Peter Flach, *Simply Logical*, Wiley, 1994 — «Meta-programs» ([edición en línea](https://book.simply-logical.space/src/text/1_part_i/3.8.html)):
  las cuatro clases de variantes de un intérprete de la [sección 33.3](#333-variar-el-interprete).
- Leon Sterling y Ehud Shapiro, *The Art of Prolog*, 2.ª ed., MIT Press, 1994 — «Interpreters» ([edición en línea](https://archive.org/details/artofprologadvan00ster)):
  el rastreador, el límite de profundidad y la depuración algorítmica.
- Ehud Shapiro, *Algorithmic Program Debugging*, MIT Press, 1983: el oráculo, la cláusula falsa y el objetivo no cubierto.
- Dennis Merritt, *Building Expert Systems in Prolog*, Springer-Verlag, 1989 — «Explanation» ([edición en línea](https://www.amzi.com/ExpertSystemsInProlog/04explanation.php)):
  las preguntas «¿cómo?», «¿por qué?» y «¿por qué no?» de un sistema experto.

El código del capítulo es propio, escrito para el curso: las fuentes aportan ideas, no código.
