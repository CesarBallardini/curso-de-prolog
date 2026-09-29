# Capítulo 49 — Proyecto: diagnóstico por abducción

El [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md) simula un circuito: dadas las entradas, calcula las
salidas. Este capítulo resuelve el problema inverso. Dadas las entradas que
se aplicaron a un circuito y las salidas que se midieron, y cuando las
salidas no son las que el circuito debería dar, busca qué compuertas
pueden estar fallando y de qué manera. Una respuesta es un **diagnóstico**:
un conjunto de compuertas, cada una con el estado de falla que se le supone,
con el que el circuito reproduce todo lo que se midió.

Buscar las suposiciones que, agregadas a una teoría, permiten deducir una
observación es **abducción**. La deducción va de la teoría y los hechos a
las conclusiones; la abducción va de la teoría y una conclusión observada a
los hechos que la explicarían. Aquí la teoría es la descripción del
circuito y la conducta de cada compuerta en cada estado; la observación, las
entradas y salidas medidas; y los hechos que se suponen, los estados de las
compuertas. Solo se admiten suposiciones de una forma fijada de antemano,
los **abducibles**: la explicación de un acarreo equivocado no puede ser
«el acarreo es 1», tiene que ser «esta compuerta da siempre 1».

El programa crece en cinco versiones. La primera diagnostica por
simulación: prueba cada falla posible y conserva las que reproducen la
observación. La segunda escribe un intérprete abductivo, que construye la
explicación mientras prueba la observación. La tercera se queda con los
diagnósticos mínimos, y poda la búsqueda con un presupuesto de fallas. La
cuarta compara el modelo de fallas, que dice qué hace una compuerta que
falla, con una conducta desconocida. La quinta elige la próxima medición:
la entrada que mejor separa los diagnósticos que quedan. El programa
terminado carga los cinco módulos:

<!-- ejemplo: capitulo-49/diagnostico.pl archivo -->
```prolog
:- use_module(fallas).
:- use_module(abduccion).
:- use_module(minimos).
:- use_module(modelos).
:- use_module(medicion).
```

```prolog
?- simular(sumador, [0, 0, 1], Ss).
Ss = [1, 0] ;
false.

?- mas_simples(fuerte, sumador, [[0, 0, 1]-[0, 1]], Ds).
Ds = [[[m1, x1]-invertida], [[m1, x1]-pegada(1)]].

?- localizar(sumador3, [[s1, m2, x1]-pegada(1)], [[1, 1, 0, 1, 0, 1]-[0, 1, 0, 1]], Obs, Ds).
Obs = [[0, 0, 0, 0, 1, 0]-[0, 1, 0, 0], [0, 1, 0, 0, 1, 0]-[0, 1, 1, 0], [1, 1, 0, 1, 0|...]-[0, 1, 0, 1]],
Ds = [[[s1, m2, x1]-pegada(1)]].
```

El sumador completo del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md), con las entradas 0, 0 y 1, debería dar
suma 1 y acarreo 0; la segunda consulta supone que se midió lo contrario,
suma 0 y acarreo 1, y encuentra que una sola compuerta lo explica: la XOR
del primer semisumador, `[m1, x1]`, pegada a 1 o invertida. La tercera
consulta es el ciclo completo sobre el sumador de tres bits: con 3 + 5 da
10 en lugar de 8, el programa elige dos entradas más que aplicar, las mide
sobre un circuito con una avería oculta, y termina con un solo diagnóstico,
la compuerta XOR que calcula el bit s1, pegada a 1.

El proyecto parte del apartado 8.3, «Abduction and diagnostic reasoning»,
de *Simply Logical: Intelligent Reasoning by Example* de Peter Flach
([edición en línea del autor](https://book.simply-logical.space/)). De él
toma la definición de la abducción y de los abducibles, la idea de un
intérprete que agrega a la explicación cada abducible que la prueba
necesita, sin repetirlo, el sumador completo con un **modelo de fallas**
en el que la salida de una compuerta queda pegada a 0 o a 1, la
observación de las entradas 0, 0 y 1 con las salidas 0 y 1, y la selección
de los diagnósticos mínimos descartando los que contienen a otro, con la
advertencia de que ese filtro es cuadrático en la cantidad de diagnósticos,
que crece en forma exponencial con la de compuertas. Los apartados 8.1 y
8.2, sobre el razonamiento por defecto y la compleción, dan el contexto. El
libro se publica con una licencia no comercial: el texto y los programas de
este capítulo son propios, escritos sobre los circuitos del capítulo
anterior.

El capítulo reutiliza, sin copiarlos, tres módulos de capítulos
anteriores: el módulo `circuitos` del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md), cuyo intérprete
`simular/4` recibe la conducta de cada compuerta como argumento; el
intérprete vainilla del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md), al que agrega una clase de
objetivos; y el diccionario incompleto del [capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md), que guarda
los supuestos. Todos los archivos son módulos que cargan otros módulos, y se
ejecutan en una instalación local, no en SWISH.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- describir un problema de diagnóstico como abducción: una teoría, una
  observación y los abducibles que pueden explicarla;
- escribir un modelo de fallas como una conducta de compuerta y
  diagnosticar por simulación, con una falla y con varias;
- extender un intérprete vainilla con abducibles, guardados en un
  diccionario incompleto que comparten todas las compuertas y todas las
  observaciones;
- obtener los diagnósticos mínimos, por filtro y con un presupuesto de
  fallas que poda la búsqueda, y medir la diferencia;
- distinguir un modelo de fallas fuerte de uno débil por lo que cada uno
  puede explicar y descartar;
- elegir la próxima medición como la que mejor separa los diagnósticos
  posibles, y reconocer los que ninguna medición en las entradas separa.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:40 h**.
    Resolver los 5 ejercicios marcados con ★: **1:20 h**.
    Resolver los 11 ejercicios del final: **3:30 h**.

## 49.1 El problema

Un circuito funciona si cada compuerta cumple su tabla de verdad. Esa es la
lectura que hace `simular/3` del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md): la conducta `normal/4`
da a cada compuerta su tabla, y con las entradas ligadas la simulación
tiene una sola respuesta. Si el circuito real, con esas entradas, da otras
salidas, la teoría del circuito sano **no puede explicar la observación**:

```prolog
?- simular(sumador, [0, 0, 1], [0, 1]).
false.
```

La respuesta es la de la [sección 38.3](../capitulo-38-semantica-de-los-programas-logicos/index.md#383-negacion-como-falla-la-complecion-de-clark-y-sldnf) leída del otro lado: el
programa dice todo lo que es verdadero de un circuito sano, y la
observación no está entre sus consecuencias. Suponer que las compuertas
funcionan es una suposición por defecto, en el sentido que Flach da a la
expresión en el apartado 8.1: se mantiene mientras nada la contradiga. La
medición la contradice, y el diagnóstico busca qué suposiciones retirar y
por cuáles reemplazarlas.

Las compuertas se identifican por su **ruta**, la lista de identificadores
que lleva hasta ellas desde el circuito exterior, que `compuerta_en/3`
enumera. El sumador tiene cinco: la XOR y la AND de cada semisumador, y la
OR del acarreo.

```prolog
?- compuerta_en(sumador, Ruta, Tipo).
Ruta = [m1, x1],
Tipo = xor ;
Ruta = [m1, y1],
Tipo = and ;
Ruta = [m2, x1],
Tipo = xor ;
Ruta = [m2, y1],
Tipo = and ;
Ruta = [o1],
Tipo = or.
```

El sumador es el mismo circuito que Flach diagnostica: la XOR `[m1, x1]`
calcula el cable t, que el segundo semisumador combina con el acarreo de
entrada, y la OR `[o1]` reúne los dos acarreos parciales. Una
**observación** es un par `Entradas-Salidas`, y un problema de diagnóstico
es una lista de observaciones del mismo circuito, con las mismas fallas.

## 49.2 Versión 1: una falla, por simulación

`fallas.pl` define el **modelo de fallas**: qué hace una compuerta en cada
estado. En el estado `ok` cumple su tabla; `pegada(V)` da siempre el bit V,
sin importar sus entradas; `invertida` da lo contrario de su tabla. Los dos
primeros estados de falla son los del modelo de Flach; el tercero, propio
del capítulo, representa una compuerta que conserva su lógica y niega la
salida.

<!-- ejemplo: capitulo-49/fallas.pl predicado: modelo/4 falla/1 con_fallas/5 -->
```prolog
%!  modelo(?Estado, ?Tipo, ?Entradas:list, ?Salida) is nondet.
%
%   Salida es la salida de una compuerta de tipo Tipo, en el estado Estado,
%   con las Entradas.
modelo(ok, Tipo, Entradas, Salida) :-
    tabla(Tipo, Entradas, Salida).
modelo(pegada(V), _Tipo, _Entradas, V) :-
    bit(V).
modelo(invertida, Tipo, Entradas, Salida) :-
    tabla(Tipo, Entradas, Salida0),
    negacion(Salida0, Salida).

% falla(E): E es un estado de falla del modelo de la versión 1.
falla(pegada(0)).
falla(pegada(1)).
falla(invertida).

%!  con_fallas(+Fallas:list(pair), +Ruta:list, ?Tipo, ?Entradas:list,
%!      ?Salida) is nondet.
%
%   La conducta de un circuito en el que cada compuerta de Fallas, una
%   lista de pares Ruta-Estado, está en su estado, y las demás, en ok.
con_fallas(Fallas, Ruta, Tipo, Entradas, Salida) :-
    (   memberchk(Ruta-Estado, Fallas)
    ->  true
    ;   Estado = ok
    ),
    modelo(Estado, Tipo, Entradas, Salida).
```

`con_fallas/5` es una conducta para `simular/4`: la del [ejercicio 5](../capitulo-48-proyecto-circuitos-logicos/index.md#ejercicios)
del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md), `pegada/2`, generalizada a una lista de fallas y a
cualquier estado. La ruta de cada compuerta decide si está en la lista; si
no está, su estado es `ok`. El intérprete de circuitos no cambia: una
compuerta falla porque su conducta es otra, como anticipa el
[Patrón 59](../patrones.md#59-interprete-con-conducta-como-parametro).

Un conjunto de fallas **explica** las observaciones si el circuito con esas
fallas reproduce todas; el diagnóstico por simulación genera candidatos y
se queda con los que explican. `una_falla/3` prueba cada compuerta con cada
estado de falla, y `k_fallas/4`, cada elección de k compuertas distintas
con un estado para cada una:

<!-- ejemplo: capitulo-49/fallas.pl predicado: explica/3 una_falla/3 k_fallas/4 -->
```prolog
%!  explica(+Circuito, +Observaciones:list(pair), +Fallas:list(pair))
%!      is semidet.
%
%   Circuito con las Fallas reproduce cada observación Entradas-Salidas.
explica(Circuito, Observaciones, Fallas) :-
    forall(member(Entradas-Salidas, Observaciones),
           simular(con_fallas(Fallas), Circuito, Entradas, Salidas)).

%!  una_falla(+Circuito, +Observaciones:list(pair), -Falla) is nondet.
%
%   Falla, un par Ruta-Estado, es una falla de una sola compuerta que
%   explica las Observaciones.
una_falla(Circuito, Observaciones, Ruta-Estado) :-
    compuerta_en(Circuito, Ruta, _),
    falla(Estado),
    explica(Circuito, Observaciones, [Ruta-Estado]).

%!  k_fallas(+Circuito, +Observaciones:list(pair), +K:integer,
%!      -Fallas:list(pair)) is nondet.
%
%   Fallas son K fallas en compuertas distintas, en el orden de
%   compuerta_en/3, que explican las Observaciones.
k_fallas(Circuito, Observaciones, K, Fallas) :-
    findall(Ruta, compuerta_en(Circuito, Ruta, _), Rutas),
    length(Elegidas, K),
    subsecuencia(Elegidas, Rutas),
    maplist(con_estado, Elegidas, Fallas),
    explica(Circuito, Observaciones, Fallas).
```

```prolog
?- una_falla(sumador, [[0, 0, 1]-[0, 1]], F).
F = [m1, x1]-pegada(1) ;
F = [m1, x1]-invertida ;
false.
```

Con las entradas 0, 0 y 1, el cable t debería valer 0; si la XOR que lo
calcula da 1, el segundo semisumador suma 1 y 1, y las dos salidas cambian
a la vez. Es el diagnóstico que Flach destaca: una sola falla explica los
dos errores. Otras observaciones no tienen explicación con una sola falla:

```prolog
?- una_falla(sumador, [[1, 1, 1]-[0, 0]], F).
false.

?- aggregate_all(count, k_fallas(sumador, [[1, 1, 1]-[0, 0]], 2, _), N).
N = 12.
```

!!! question "Actividad"
    Predecir, sin ejecutarla, qué responde
    `una_falla(sumador, [[1, 0, 0]-[1, 1]], F)`: qué compuertas pueden dar
    un acarreo 1 cuando solo una entrada es 1, y con qué estado. Comprobarlo,
    y explicar por qué `[m1, x1]` no aparece.

El método tiene dos límites. El primero es su costo: con n compuertas y
tres estados de falla, las fallas de k compuertas son C(n, k) · 3ᵏ
candidatos, y cada uno se simula desde el principio. El sumador de tres
bits tiene 12 compuertas: 36 candidatos con una falla, 594 con dos, 5 940
con tres. El segundo es que la búsqueda no aprovecha la observación:
propone fallas a ciegas y recién al final comprueba si explican algo. Sobre
el sumador de tres bits, con la entrada 3 + 5 y un acarreo que no llega, la
búsqueda de todas las explicaciones con hasta dos fallas da:

```text
?- time(aggregate_all(count, (between(0, 2, K), k_fallas(sumador3, [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 0]], K, _)), N)).
% 678,935 inferences, 0.109 CPU in 0.108 seconds (101% CPU, 6207406 Lips)
N = 80.
```

## 49.3 Versión 2: el intérprete abductivo

Flach escribe el diagnóstico como una prueba: la observación se demuestra
con las cláusulas del circuito, y cada vez que la prueba necesita un hecho
abducible que no puede demostrar, lo **supone** y lo agrega a la
explicación. `abduccion.pl` hace lo mismo con el intérprete vainilla de la
[sección 33.2](../capitulo-33-introspeccion-y-metainterpretes/index.md#332-el-interprete-vainilla), y le agrega una clase de objetivos: `estado(C, E)`,
que no se prueba con reglas sino que se supone.

<!-- ejemplo: capitulo-49/abduccion.pl predicado: abducir/2 -->
```prolog
%!  abducir(+Meta, ?Supuestos:list) is nondet.
%
%   Meta se prueba con las reglas de la teoría, suponiendo los estados que
%   hagan falta. Supuestos es un diccionario incompleto de pares
%   Componente-Estado: los estados supuestos hasta ahora, y los que la
%   prueba agrega.
abducir(true, _).
abducir((A, B), Supuestos) :-
    abducir(A, Supuestos),
    abducir(B, Supuestos).
abducir(estado(Componente, Estado), Supuestos) :-
    buscar(Componente, Supuestos, Estado).
abducir(Meta, Supuestos) :-
    regla(Meta, Cuerpo),
    abducir(Cuerpo, Supuestos).
```

Los supuestos se guardan en un **diccionario incompleto** de la
[sección 34.4](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#344-diccionarios-incompletos): una lista abierta de pares `Componente-Estado`,
recorrida con `buscar/3`, que el módulo carga del [capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md). Si el
componente ya tiene un estado supuesto, `buscar/3` lo unifica con el que la
prueba pide, y la prueba falla si son distintos; si no lo tiene, lo agrega.
Así se cumplen, con una sola operación, las dos condiciones que el
intérprete de Flach verifica aparte: un supuesto no se repite, y un
componente no puede estar a la vez en dos estados. La explicación no
necesita un par de argumentos acumuladores: el diccionario crece al ligar
su final, y el retroceso deshace esa ligadura junto con la rama que la
hizo.

La teoría son hechos `regla(Cabeza, Cuerpo)`, en la representación limpia
del [Patrón 44](../patrones.md#44-representacion-limpia): un intérprete que solo sigue reglas no llama a
cualquier objetivo. Los hechos que calcula Prolog, las tablas y la negación
de un bit, entran como reglas de cuerpo vacío.

<!-- ejemplo: capitulo-49/abduccion.pl predicado: regla/2 -->
```prolog
%!  regla(?Cabeza, ?Cuerpo) is nondet.
%
%   La teoría: Cabeza es verdadera si lo es Cuerpo. salida(Modelo, Ruta,
%   Tipo, Entradas, Salida) es la salida de la compuerta Ruta; en el modelo
%   fuerte, su estado es ok, pegada(V) o invertida. Los hechos que calcula
%   Prolog, tabla/3 y negacion/2, entran como reglas de cuerpo vacío.
regla(salida(_, Ruta, Tipo, Es, S), (estado(Ruta, ok), tabla(Tipo, Es, S))).
regla(salida(fuerte, Ruta, _, _, V), (bit(V), estado(Ruta, pegada(V)))).
regla(salida(fuerte, Ruta, Tipo, Es, S),
      (estado(Ruta, invertida), tabla(Tipo, Es, S0), negacion(S0, S))).
regla(tabla(Tipo, Es, S), true) :-
    tabla(Tipo, Es, S).
regla(bit(B), true) :-
    bit(B).
regla(negacion(B, N), true) :-
    negacion(B, N).
```

La salida de una compuerta depende de su estado, y el estado es el
abducible. El primer argumento de `salida/5` es el **modelo de fallas**:
`fuerte` es el de la versión 1, y la [sección 49.5](#495-version-4-modelos-de-falla-y-conducta-desconocida) agrega otro. Una
compuerta AND con las entradas 1 y 1 debería dar 1; si dio 0, está pegada
a 0 o invertida:

```prolog
?- abducir(salida(fuerte, [g], and, [1, 1], 0), S).
S = [[g]-pegada(0)|_] ;
S = [[g]-invertida|_] ;
false.
```

La conducta `abductiva/6` convierte a `simular/4` en un intérprete
abductivo del circuito: cada compuerta prueba su salida con `abducir/2`,
todas sobre el mismo diccionario. `explicar/4` recorre las observaciones
con el mismo diccionario, porque las fallas de un circuito son las mismas
en todas las mediciones, y al final lo cierra.

<!-- ejemplo: capitulo-49/abduccion.pl predicado: abductiva/6 explicar/4 observar/4 diagnostico/4 -->
```prolog
%!  abductiva(+Modelo, ?Supuestos:list, +Ruta:list, ?Tipo, ?Entradas:list,
%!      ?Salida) is nondet.
%
%   La conducta abductiva de una compuerta: su salida en el Modelo, con el
%   estado que Supuestos le asigna o que la prueba le supone.
abductiva(Modelo, Supuestos, Ruta, Tipo, Entradas, Salida) :-
    abducir(salida(Modelo, Ruta, Tipo, Entradas, Salida), Supuestos).

%!  explicar(+Modelo, +Circuito, +Observaciones:list(pair),
%!      -Supuestos:list(pair)) is nondet.
%
%   Supuestos asigna un estado a cada compuerta de Circuito, de modo que el
%   circuito reproduce todas las Observaciones Entradas-Salidas.
explicar(Modelo, Circuito, Observaciones, Supuestos) :-
    maplist(observar(Modelo, Circuito, Supuestos), Observaciones),
    cerrar(Supuestos).

%!  observar(+Modelo, +Circuito, ?Supuestos:list, +Observacion:pair)
%!      is nondet.
%
%   Circuito reproduce la Observacion Entradas-Salidas con los Supuestos.
observar(Modelo, Circuito, Supuestos, Entradas-Salidas) :-
    simular(abductiva(Modelo, Supuestos), Circuito, Entradas, Salidas).

%!  diagnostico(+Modelo, +Circuito, +Observaciones:list(pair),
%!      -Fallas:list(pair)) is nondet.
%
%   Fallas son los pares Ruta-Estado de las compuertas que no están en ok
%   en una explicación de las Observaciones, ordenados por ruta.
diagnostico(Modelo, Circuito, Observaciones, Fallas) :-
    explicar(Modelo, Circuito, Observaciones, Supuestos),
    fallas(Supuestos, Fallas).
```

Un diagnóstico es la lista de las compuertas que no están en `ok`. Como el
intérprete prueba las reglas en orden, cada compuerta supone primero que
funciona, y con una observación correcta la primera respuesta es la lista
vacía:

```prolog
?- diagnostico(fuerte, sumador, [[1, 0, 1]-[0, 1]], D).
D = [] ;
D = [[o1]-pegada(1)] ;
D = [[m2, y1]-pegada(0), [o1]-pegada(1)] ;
...
```

La segunda respuesta ya muestra el problema de esta versión: una OR que da
1 cuando debería dar 1 no cambia nada, y sin embargo es una explicación
válida, porque la teoría no la contradice. El intérprete encuentra todas
las asignaciones de estados coherentes con la observación, y son muchas:

```prolog
?- aggregate_all(count, diagnostico(fuerte, sumador, [[0, 0, 1]-[0, 1]], _), N).
N = 256.
```

!!! question "Actividad"
    Predecir cuántas explicaciones tiene la observación correcta
    `[[1, 0, 1]-[0, 1]]` del sumador: cada compuerta puede estar en cuatro
    estados, pero no todas las combinaciones reproducen las salidas.
    Comprobarlo con `aggregate_all/3`, y explicar por qué el número no es
    4⁵ = 1024.

Con las cinco compuertas del sumador, la cantidad es manejable. Con las 12
del sumador de tres bits no lo es: la observación **correcta** de 3 + 5 = 8
tiene más de un millón. Contadas con `aggregate_all/3` bajo `time/1`, son
1 048 576, con 140 185 759 inferencias y 21 segundos de ejecución.

El número es exacto: 4⁸ · 2⁴ = 4¹⁰. Las ocho compuertas cuya salida es un
cable interno pueden estar en cualquiera de sus cuatro estados, porque las
siguientes absorben lo que hagan; cada una de las cuatro que dan una salida
del circuito tiene exactamente dos estados que producen el bit medido: `ok`
o `pegada` a ese bit si su tabla lo da, `invertida` o `pegada` a ese bit si
no lo da. El sumador de la consulta anterior da la misma cuenta, 4³ · 2².
La lista completa no es un diagnóstico útil.

## 49.4 Versión 3: diagnósticos mínimos

Un diagnóstico es **mínimo** si ningún otro supone fallas en un subconjunto
propio de sus compuertas. Si `[[m1, x1]-pegada(1)]` explica la observación,
agregarle otra compuerta en falla no explica nada nuevo. `minimos.pl`
obtiene los mínimos de dos maneras. La primera es la de Flach: generar
todos los diagnósticos y descartar los que contienen a otro.

<!-- ejemplo: capitulo-49/minimos.pl predicado: por_filtro/4 minimo/2 -->
```prolog
%!  por_filtro(+Modelo, +Circuito, +Observaciones:list(pair),
%!      -Minimos:list(list)) is det.
%
%   Minimos son los diagnósticos mínimos de las Observaciones: se generan
%   todos, y se descartan los que contienen a otro.
por_filtro(Modelo, Circuito, Observaciones, Minimos) :-
    findall(D, diagnostico(Modelo, Circuito, Observaciones, D), Ds0),
    sort(Ds0, Ds),
    include(minimo(Ds), Ds, Minimos).

%!  minimo(+Diagnosticos:list(list), +Diagnostico:list) is semidet.
%
%   Ningún diagnóstico de Diagnosticos tiene sus fallas en un subconjunto
%   propio de las compuertas de Diagnostico.
minimo(Diagnosticos, Diagnostico) :-
    rutas(Diagnostico, Rutas),
    \+ ( member(Otro, Diagnosticos),
         rutas(Otro, Otras),
         Otras \== Rutas,
         ord_subset(Otras, Rutas)
       ).
```

```prolog
?- forall(( por_filtro(fuerte, sumador, [[0, 0, 1]-[0, 1]], Ds), member(D, Ds) ), ( print(D), nl )).
[[m1,x1]-invertida]
[[m1,x1]-pegada(1)]
[[m1,y1]-invertida,[m2,x1]-invertida]
[[m1,y1]-invertida,[m2,x1]-pegada(0)]
[[m1,y1]-pegada(1),[m2,x1]-invertida]
[[m1,y1]-pegada(1),[m2,x1]-pegada(0)]
[[m2,x1]-invertida,[m2,y1]-invertida]
[[m2,x1]-invertida,[m2,y1]-pegada(1)]
[[m2,x1]-invertida,[o1]-invertida]
[[m2,x1]-invertida,[o1]-pegada(1)]
[[m2,x1]-pegada(0),[m2,y1]-invertida]
[[m2,x1]-pegada(0),[m2,y1]-pegada(1)]
[[m2,x1]-pegada(0),[o1]-invertida]
[[m2,x1]-pegada(0),[o1]-pegada(1)]
true.
```

De 256 explicaciones quedan 14, y sus conjuntos de compuertas son los cuatro
diagnósticos mínimos de Flach: la XOR del primer semisumador sola, o la XOR
del segundo, que da la suma, junto con una de las tres compuertas del
acarreo. Cada uno aparece con las variantes de estado del modelo de este
capítulo. El filtro necesita, sin embargo, la lista completa, que con el
sumador de tres bits tiene un millón de elementos, y compara cada
diagnóstico con todos los demás.

La segunda manera no genera lo que va a descartar. La conducta `acotada/7`
agrega a la abductiva un **presupuesto**: después de cada compuerta, cuenta
las fallas supuestas, y la rama que supera K falla en ese momento. Es una
extensión del intérprete, no de la teoría, como pide el
[Patrón 46](../patrones.md#46-extender-el-interprete-no-el-programa):

<!-- ejemplo: capitulo-49/minimos.pl predicado: acotada/7 en_falla/2 diagnostico_k/5 -->
```prolog
%!  acotada(+Modelo, +K:integer, ?Supuestos:list, +Ruta:list, ?Tipo,
%!      ?Entradas:list, ?Salida) is nondet.
%
%   La conducta abductiva de la versión 2, con a lo sumo K compuertas en
%   falla entre los Supuestos: la rama que supone más falla en seguida.
acotada(Modelo, K, Supuestos, Ruta, Tipo, Entradas, Salida) :-
    abductiva(Modelo, Supuestos, Ruta, Tipo, Entradas, Salida),
    en_falla(Supuestos, N),
    N =< K.

%!  en_falla(+Supuestos:list, -N:integer) is det.
%
%   N es la cantidad de pares del diccionario incompleto Supuestos cuyo
%   estado no es ok.
en_falla(Supuestos, 0) :-
    var(Supuestos),
    !.
en_falla([_-Estado|Resto], N) :-
    en_falla(Resto, N0),
    (   Estado == ok
    ->  N = N0
    ;   N is N0 + 1
    ).

%!  diagnostico_k(+Modelo, +Circuito, +Observaciones:list(pair),
%!      +K:integer, -Fallas:list(pair)) is nondet.
%
%   Como diagnostico/4, con a lo sumo K compuertas en falla.
diagnostico_k(Modelo, Circuito, Observaciones, K, Fallas) :-
    maplist(observar_k(Modelo, K, Circuito, Supuestos), Observaciones),
    cerrar(Supuestos),
    fallas(Supuestos, Fallas).
```

Con el presupuesto, dos búsquedas son directas. `mas_simples/4` prueba
presupuestos de 0, 1, 2… fallas, como la profundización iterativa de la
[sección 33.5](../capitulo-33-introspeccion-y-metainterpretes/index.md#335-limites-de-profundidad-y-profundizacion-iterativa), y se detiene en el primero que da algún diagnóstico:
son los de menos fallas. `minimos/5` da todos los mínimos con a lo sumo K
fallas: como un subconjunto de un diagnóstico de K fallas tiene menos de K,
el filtro sobre esa lista es exacto.

<!-- ejemplo: capitulo-49/minimos.pl predicado: mas_simples/4 minimos/5 -->
```prolog
%!  mas_simples(+Modelo, +Circuito, +Observaciones:list(pair),
%!      -Diagnosticos:list(list)) is semidet.
%
%   Diagnosticos son los diagnósticos con la menor cantidad de fallas:
%   se prueban presupuestos de 0, 1, 2... fallas, hasta el primero que da
%   alguno. Falla si ningún diagnóstico explica las Observaciones.
mas_simples(Modelo, Circuito, Observaciones, Diagnosticos) :-
    compuertas(Circuito, N),
    between(0, N, K),
    setof(D, diagnostico_k(Modelo, Circuito, Observaciones, K, D),
          Diagnosticos),
    !.

%!  minimos(+Modelo, +Circuito, +Observaciones:list(pair), +K:integer,
%!      -Minimos:list(list)) is det.
%
%   Minimos son los diagnósticos mínimos con a lo sumo K fallas.
minimos(Modelo, Circuito, Observaciones, K, Minimos) :-
    findall(D, diagnostico_k(Modelo, Circuito, Observaciones, K, D), Ds0),
    sort(Ds0, Ds),
    include(minimo(Ds), Ds, Minimos).
```

```prolog
?- mas_simples(fuerte, sumador3, [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 0]], Ds).
Ds = [[[s2, m2, y1]-invertida], [[s2, m2, y1]-pegada(0)], [[s2, o1]-invertida], [[s2, o1]-pegada(0)]].

?- minimos(fuerte, sumador3, [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 0]], 2, Ds), length(Ds, N).
Ds = [[[s1, m2, y1]-invertida, [s2, m1, x1]-invertida], [[s1, m2, y1]-invertida, [s2, m1, x1]-pegada(0)], [[s1, m2, y1]-invertida, [s2, m2, x1]-invertida], [[s1, m2, y1]-invertida, [s2, m2|...]-pegada(0)], [[s1, m2|...]-pegada(0), [s2|...]-invertida], [[s1|...]-pegada(0), [...|...]-pegada(...)], [[...|...]-pegada(...), ... - ...], [... - ...|...], [...|...]|...],
N = 24.
```

La observación es la suma 3 + 5 con el acarreo final en 0. La explicación
más simple es una falla en la última etapa, en la AND o la OR que calculan
ese acarreo: cuatro diagnósticos. Los otros veinte mínimos tienen dos
fallas: el acarreo de la etapa del medio se pierde, en su AND o en su OR,
y una XOR de la última etapa compensa el bit de suma, que sin ella
cambiaría; o las dos XOR de la última etapa fallan a la vez. La medición compara
las dos versiones sobre la misma pregunta que la versión 1, todas las
explicaciones con hasta dos fallas:

```text
?- time(aggregate_all(count, diagnostico_k(fuerte, sumador3, [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 0]], 2, _), N)).
% 182,758 inferences, 0.031 CPU in 0.028 seconds (111% CPU, 5848256 Lips)
N = 80.
```

Las mismas 80 explicaciones, con 3,7 veces menos inferencias que la
simulación de la versión 1. La diferencia viene del retroceso: la
simulación de cada candidato empieza desde la primera compuerta, y el
intérprete abductivo, cuando cambia el estado de una compuerta, conserva lo
que ya calculó para las anteriores. Frente a la versión 2 sin presupuesto,
que sobre este circuito enumera más de un millón de explicaciones, la poda
es la que hace posible el diagnóstico.

!!! question "Actividad"
    Predecir si `minimos(fuerte, sumador3, Obs, 3, Ds)`, con la misma
    observación, tiene más o menos diagnósticos que con K = 2, y si alguno
    de los de K = 2 desaparece. Comprobarlo, y explicar el resultado con la
    definición de diagnóstico mínimo.

## 49.5 Versión 4: modelos de falla y conducta desconocida

El modelo fuerte afirma mucho: una compuerta que falla está pegada o
invertida, y siempre de la misma manera. Flach llama **fuerte** a un modelo
así, que enumera las conductas posibles de una compuerta que falla. El
modelo **débil** no dice nada: una compuerta que falla está en el estado
`desconocida`, y su salida puede ser cualquier bit. `modelos.pl` lo agrega
con una regla más de la teoría, sin tocar el intérprete:

<!-- ejemplo: capitulo-49/modelos.pl fragmento: abduccion:regla(salida(debil, .. (estado(Ruta, desconocida), bit(S))). -->
```prolog
abduccion:regla(salida(debil, Ruta, _, _, S),
                (estado(Ruta, desconocida), bit(S))).
```

`sospechosas/5` reduce los diagnósticos mínimos a sus conjuntos de
compuertas, sin los estados, para comparar los dos modelos:

<!-- ejemplo: capitulo-49/modelos.pl predicado: sospechosas/5 -->
```prolog
%!  sospechosas(+Modelo, +Circuito, +Observaciones:list(pair), +K:integer,
%!      -Conjuntos:list(list)) is det.
%
%   Conjuntos son los conjuntos de rutas de los diagnósticos mínimos con a
%   lo sumo K fallas, sin repetidos: las compuertas sospechosas, sin sus
%   estados.
sospechosas(Modelo, Circuito, Observaciones, K, Conjuntos) :-
    minimos(Modelo, Circuito, Observaciones, K, Minimos),
    maplist(rutas, Minimos, Conjuntos0),
    sort(Conjuntos0, Conjuntos).
```

Con una sola observación del sumador, los dos modelos sospechan de las
mismas compuertas: los cuatro conjuntos de Flach. Con dos, el modelo fuerte
descarta lo que el débil no puede descartar:

```prolog
?- sospechosas(debil, sumador, [[0, 0, 1]-[0, 1], [0, 0, 0]-[1, 0]], 2, Rs).
Rs = [[[m1, x1]], [[m1, y1], [m2, x1]], [[m2, x1], [m2, y1]], [[m2, x1], [o1]]].

?- sospechosas(fuerte, sumador, [[0, 0, 1]-[0, 1], [0, 0, 0]-[1, 0]], 2, Rs).
Rs = [[[m1, x1]]].
```

Con las entradas en 0, la segunda observación tiene la suma en 1. En el
modelo fuerte, eso solo lo explica la XOR `[m1, x1]`, pegada a 1 o
invertida, porque las otras combinaciones tendrían que comportarse distinto
en las dos mediciones. En el modelo débil, cualquier compuerta en falla
puede dar cualquier cosa en cada medición, y los otros tres conjuntos
siguen siendo posibles.

La otra cara es lo que cada modelo puede explicar. Si el mismo circuito,
con las mismas entradas, da dos resultados distintos, ningún estado del
modelo fuerte lo explica, porque todos son deterministas; el débil sí:

```prolog
?- mas_simples(fuerte, sumador, [[0, 0, 1]-[0, 1], [0, 0, 1]-[1, 0]], Ds).
false.

?- mas_simples(debil, sumador, [[0, 0, 1]-[0, 1], [0, 0, 1]-[1, 0]], Ds).
Ds = [[[m1, x1]-desconocida]].
```

Es una **falla intermitente**, que el modelo fuerte no contempla. Un modelo
fuerte discrimina más, pero su respuesta vale solo si la falla real está
entre las que enumera; si no está, el diagnóstico es vacío, o peor,
atribuye la observación a una combinación de fallas que no ocurrió. El
modelo débil no puede equivocarse de ese modo, y paga con diagnósticos
menos precisos. Tiene además una propiedad que el fuerte no tiene: agregar
una compuerta a un diagnóstico da otro diagnóstico, porque una compuerta
desconocida puede comportarse como una sana. Los diagnósticos mínimos
describen entonces todos los demás. La búsqueda también es menor, con dos
estados por compuerta en lugar de cuatro: la observación correcta del
sumador de tres bits tiene 51 664 explicaciones débiles, contra 1 048 576
fuertes.

## 49.6 Versión 5: la próxima medición

Un diagnóstico con varios candidatos pide otra medición. En el modelo
fuerte, cada diagnóstico predice las salidas del circuito para cualquier
entrada, y una entrada separa los candidatos en grupos, uno por salida
predicha. Después de medir queda uno de los grupos, y no se sabe cuál: la
mejor entrada es la que minimiza el tamaño del grupo más grande. `medicion.pl`
elige así:

<!-- ejemplo: capitulo-49/medicion.pl predicado: predecir/4 proxima/4 peor_grupo/4 -->
```prolog
%!  predecir(+Circuito, +Entradas:list, +Fallas:list(pair),
%!      -Salidas:list) is semidet.
%
%   Salidas son las salidas de Circuito con las Entradas y las Fallas del
%   modelo fuerte, que dan una sola respuesta.
predecir(Circuito, Entradas, Fallas, Salidas) :-
    once(simular(con_fallas(Fallas), Circuito, Entradas, Salidas)).

%!  proxima(+Circuito, +Diagnosticos:list(list), -Entradas:list,
%!      -Peor:integer) is semidet.
%
%   Entradas es la combinación de entradas de Circuito que minimiza Peor,
%   la cantidad de Diagnosticos que predicen la salida más predicha; ante
%   un empate, la primera en orden binario.
proxima(Circuito, Diagnosticos, Entradas, Peor) :-
    circuito(Circuito, Nombres, _),
    same_length(Nombres, Es),
    findall(P-Es,
            ( maplist(bit, Es),
              peor_grupo(Circuito, Diagnosticos, Es, P) ),
            Puntajes),
    keysort(Puntajes, [Peor-Entradas|_]).

%!  peor_grupo(+Circuito, +Diagnosticos:list(list), +Entradas:list,
%!      -Peor:integer) is det.
%
%   Peor es el tamaño del grupo más grande de Diagnosticos que predicen
%   las mismas salidas con Entradas.
peor_grupo(Circuito, Diagnosticos, Entradas, Peor) :-
    maplist(predecir(Circuito, Entradas), Diagnosticos, Predichas),
    msort(Predichas, Ordenadas),
    clumped(Ordenadas, Grupos),
    pairs_values(Grupos, Tamanos),
    max_list(Tamanos, Peor).
```

```prolog
?- minimos(fuerte, sumador, [[0, 0, 1]-[0, 1]], 2, Ds), proxima(sumador, Ds, Es, Peor).
Ds = [[[m1, x1]-invertida], [[m1, x1]-pegada(1)], [[m1, y1]-invertida, [m2, x1]-invertida], [[m1, y1]-invertida, [m2, x1]-pegada(0)], [[m1, y1]-pegada(1), [m2|...]-invertida], [[m1|...]-pegada(1), [...|...]-pegada(...)], [[...|...]-invertida, ... - ...], [... - ...|...], [...|...]|...],
Es = [0, 1, 1],
Peor = 5.
```

De los 14 candidatos, la entrada 0, 1, 1 deja a lo sumo 5, sea cual sea la
salida que se mida. `localizar/5` repite el ciclo sobre un circuito con una
avería conocida por el programa pero no por el diagnóstico: calcula los
mínimos, elige la entrada, obtiene la salida de la avería con `predecir/4`,
la agrega a las observaciones y vuelve a empezar, hasta que ninguna entrada
separa a los candidatos que quedan.

<!-- ejemplo: capitulo-49/medicion.pl predicado: localizar/5 -->
```prolog
%!  localizar(+Circuito, +Averia:list(pair), +Observaciones0:list(pair),
%!      -Observaciones:list(pair), -Candidatos:list(list)) is det.
%
%   Partiendo de las Observaciones0 de Circuito, que tiene las fallas
%   Averia, se mide con la próxima entrada mientras separe a los
%   diagnósticos mínimos con a lo sumo dos fallas. Observaciones son todas
%   las mediciones, la última primero, y Candidatos, los diagnósticos que
%   ninguna entrada separa.
localizar(Circuito, Averia, Observaciones0, Observaciones, Candidatos) :-
    minimos(fuerte, Circuito, Observaciones0, 2, Diagnosticos),
    (   proxima(Circuito, Diagnosticos, Entradas, Peor),
        length(Diagnosticos, N),
        Peor < N
    ->  predecir(Circuito, Entradas, Averia, Salidas),
        localizar(Circuito, Averia, [Entradas-Salidas|Observaciones0],
                  Observaciones, Candidatos)
    ;   Observaciones = Observaciones0,
        Candidatos = Diagnosticos
    ).
```

Con la falla simple del sumador de tres bits, la consulta del comienzo del
capítulo se resuelve en dos mediciones más. Con una falla doble del sumador, el ciclo
se detiene antes de llegar a un solo diagnóstico:

```prolog
?- localizar(sumador, [[m1, y1]-pegada(1), [m2, x1]-pegada(0)], [[0, 0, 1]-[0, 1]], Obs, Ds).
Obs = [[0, 0, 0]-[0, 1], [1, 1, 0]-[0, 1], [0, 1, 1]-[0, 1], [0, 0, 1]-[0, 1]],
Ds = [[[m1, y1]-pegada(1), [m2, x1]-pegada(0)], [[m2, x1]-pegada(0), [m2, y1]-pegada(1)], [[m2, x1]-pegada(0), [o1]-pegada(1)]].
```

Los tres candidatos que quedan dan las mismas salidas para las ocho
entradas: con la suma pegada a 0, un acarreo pegado a 1 en cualquiera de
las tres compuertas del acarreo produce el mismo circuito visto desde
afuera. Son **fallas equivalentes**, y ninguna medición en las entradas y
las salidas las distingue; hace falta medir un cable interno, como propone
el [ejercicio 6](#ejercicios). El resultado también muestra el límite de
elegir entre los mínimos: la avería real está entre los candidatos porque
es mínima; una avería que contiene a otro diagnóstico no aparecería.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; el intérprete abductivo es `nondet` porque una observación tiene en general muchas explicaciones |
    | C2 | la teoría es de datos: `regla/2`, y los circuitos, los del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md), sin copiarlos; un modelo de fallas nuevo es una regla más |
    | C6 | el intérprete de circuitos no cambia en ninguna versión: cada una es una conducta nueva para `simular/4` (`con_fallas/5`, `abductiva/6`, `acotada/7`) |
    | C7 | 36 pruebas en seis archivos; cada versión se compara con la anterior: los diagnósticos abductivos explican en la simulación de la versión 1, `mas_simples/4` coincide con `k_fallas/4`, y el filtro de Flach con el presupuesto |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

1. ★ **(1)** Predecir, con `diagnostico.pl` cargado, qué responde cada
   consulta, y comprobarlo: `abducir(salida(fuerte, [g], or, [0, 0], 1), S).`
   · `mas_simples(fuerte, sumador, [[1, 1, 0]-[0, 0]], Ds).` ·
   `mas_simples(debil, sumador, [[1, 1, 0]-[0, 0]], Ds).` ·
   `diagnostico(fuerte, semisumador, [[0, 0]-[0, 0]], D).`
2. ★ **(2)** Diagnosticar el `xor_nand` del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md), las cuatro
   compuertas NAND, con la observación `[1, 0]-[0]`. Obtener los
   diagnósticos más simples en los dos modelos, agregar la observación
   `[0, 0]-[0]` y explicar qué cambia en cada uno.
3. ★ **(2)** Reemplazar, en una copia de `abducir/2`, `buscar/3` por
   `memberchk(Componente-Estado, Supuestos)`. Encontrar un diagnóstico del
   sumador que la copia da y que no es una asignación de estados posible,
   y explicar qué condición del diccionario incompleto deja de cumplirse.
4. ★ **(2)** En el modelo de Flach, una compuerta pegada a V solo se supone
   en falla cuando su tabla daría el otro bit. Agregar a la teoría el
   modelo `flach`, sin el estado invertido y con esa condición, y
   comprobar que la observación de la [sección 49.2](#492-version-1-una-falla-por-simulacion) tiene sus ocho
   diagnósticos, de los que cuatro son mínimos. Explicar por qué el modelo
   deja de ser adecuado con dos observaciones.
5. **(2)** Agregar al modelo fuerte el estado `copia(I)`: la compuerta da el
   valor de su entrada número I, como si un cable la saltara. Diagnosticar
   con él la observación `[[1, 1, 1]-[0, 0]]` y comparar los diagnósticos
   más simples con los de la [sección 49.2](#492-version-1-una-falla-por-simulacion).
6. ★ **(2)** Una **sonda** mide un cable interno. Describir, con
   cláusulas `multifile` de `circuitos`, el circuito `sumador_sondas`: los
   componentes del sumador y, como salidas, s, co, c1 y c2. Diagnosticar
   con él la avería doble de la [sección 49.6](#496-version-5-la-proxima-medicion) y mostrar que las
   sondas separan las tres fallas equivalentes.
7. **(1)** Escribir `sanas(Supuestos, Rutas)`, las rutas que un
   diccionario de supuestos, ya cerrado, asigna al estado `ok`, con su
   encabezado de PlDoc. Justificar los modos y la determinación.
8. **(2)** `abducir/2` no depende de los circuitos. Escribir con
   `regla/2` una teoría de un automóvil que no arranca: el motor arranca si
   la batería, el motor de arranque y el combustible están bien, y las
   luces encienden si la batería está bien. Diagnosticar un automóvil que
   no arranca y tiene las luces encendidas.
9. **(2)** Una compuerta pegada es más probable que una invertida. Con
   probabilidades de falla 0,01 para `pegada(V)` y 0,001 para `invertida`,
   escribir `mas_probables(Circuito, Obs, K, Ds)`, los diagnósticos
   mínimos ordenados de mayor a menor probabilidad, y aplicarlo a la
   observación de la [sección 49.4](#494-version-3-diagnosticos-minimos).
10. **(3)** El **cono** de una salida son las compuertas de las que depende.
    Escribir `cono(Circuito, Salida, Rutas)` recorriendo la descripción
    desde la salida hacia las entradas, y verificar sobre el sumador de
    tres bits que todo diagnóstico mínimo tiene al menos una compuerta en
    el cono de cada salida equivocada.
11. **(3)** Un **conjunto de pruebas** es una lista de entradas que detecta
    toda falla simple del modelo fuerte: para cada compuerta y cada estado
    de falla, alguna entrada da otras salidas. Escribir
    `conjunto_de_pruebas(Circuito, Es)` con el criterio voraz —elegir cada
    vez la entrada que detecta más fallas todavía no detectadas— y
    aplicarlo al sumador y al sumador de tres bits. Informar qué fallas no
    detecta ninguna entrada.

## Resumen

| | |
|---|---|
| **abducción** | buscar los hechos que, agregados a la teoría, permiten deducir la observación |
| **abducible** | la forma de los hechos que se pueden suponer: aquí, `estado(Componente, Estado)` |
| **observación** | un par `Entradas-Salidas`; un problema es una lista, con las mismas fallas en todas |
| **modelo de fallas** | la conducta de una compuerta en cada estado: fuerte (`pegada(V)`, `invertida`) o débil (`desconocida`) |
| **diagnóstico** | las compuertas que no están en `ok` en una explicación, con sus estados |
| **diagnóstico mínimo** | ningún otro tiene sus fallas en un subconjunto propio de sus compuertas |
| **presupuesto de fallas** | la poda que descarta una rama en cuanto supone más de K fallas |
| **fallas equivalentes** | fallas distintas con las mismas salidas para toda entrada; solo una sonda interna las separa |
| `modelo/4`, `con_fallas/5`, `una_falla/3`, `k_fallas/4` | el diagnóstico por simulación |
| `abducir/2`, `regla/2`, `abductiva/6`, `diagnostico/4` | el intérprete abductivo y su teoría |
| `por_filtro/4`, `acotada/7`, `mas_simples/4`, `minimos/5` | los diagnósticos mínimos |
| `sospechosas/5` | los conjuntos de compuertas, para comparar modelos |
| `predecir/4`, `proxima/4`, `localizar/5` | la elección de la próxima medición |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| El razonamiento por defecto, con reglas que admiten excepciones | [capítulo 65](../capitulo-65-proyecto-razonamiento-rebatible/index.md) |
| La inducción, que supone reglas en lugar de hechos | [capítulo 67](../capitulo-67-proyecto-aprender-reglas-ejemplos/index.md) |

## Referencias

- Peter Flach, *Simply Logical: Intelligent Reasoning by Example*, John
  Wiley & Sons, 1994 — apartado 8.3, «Abduction and diagnostic reasoning»,
  con los apartados 8.1 y 8.2, sobre el razonamiento por defecto y la
  compleción, como contexto.
  [Edición en línea](https://book.simply-logical.space/src/text/3_part_iii/8.3.html).
  El capítulo toma la definición de la abducción y de los abducibles, la
  idea del intérprete que agrega a la explicación cada abducible que la
  prueba necesita, el sumador completo con su modelo de fallas y su
  observación de ejemplo, y el filtro de los diagnósticos mínimos con su
  costo.

El código del capítulo es propio, escrito para el curso sobre los circuitos
del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md): de
Flach se toman ideas y el ejemplo, no código; el modelo de falla invertida,
el modelo débil y la elección de la próxima medición son del curso.
