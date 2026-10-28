# Otras generalizaciones e incorporar las reglas

Esta página continúa la página
[Explicar un ejemplo y generalizar la explicación](explicacion.md#696-version-6-generalizar-la-explicacion)
del [capítulo 69](index.md), con la sección
[69.7](#697-version-7-otras-generalizaciones-e-incorporar-las-reglas): las
partes del capítulo «Machine Learning Algorithms in Prolog» de Luger y
Stubblefield que las versiones 1 a 6 no cubren. Los ejemplos están en
`generalizaciones.pl` e `incorporar.pl`, en `ejemplos/capitulo-69/`, con
sus pruebas; cargan archivos de otros capítulos y se ejecutan localmente.

## 69.7 Versión 7: otras generalizaciones e incorporar las reglas

Luger y Stubblefield enumeran cuatro operaciones de
generalización: reemplazar una constante por una variable, quitar
condiciones de una conjunción, agregar un disyunto y subir en una
jerarquía de clases. Las versiones 1 a 4 usan solo la primera; esta
página escribe las otras tres sobre las mismas piezas. Quitar
condiciones de una conjunción resulta ser la misma operación vista de
otra manera; subir en una jerarquía de clases agrega conceptos
intermedios, como `redondeada`, y permite aprender un concepto con el que
el espacio de la
[sección 69.3](index.md#693-version-3-eliminacion-de-candidatos) colapsa;
agregar un disyunto hace que todo conjunto de ejemplos tenga un concepto
consistente, a costa de no generalizar. Al final de la
sección sobre la generalización basada en la explicación, los autores
proponen además que el programa agregue a la base cada regla que
aprende; la última parte de la página lo hace y cuenta cuántos objetos
se reconocen con las reglas guardadas y cuántos necesitan la teoría.

### Quitar condiciones

Un concepto se puede leer como una conjunción de condiciones
`Atributo = Valor`, una por cada atributo que no está libre.
`condiciones_de/2` traduce un concepto o una instancia a esa lectura, y
`comunes/3` generaliza dos conjunciones quitando de la primera las
condiciones que la segunda no tiene:

<!-- ejemplo: capitulo-69/generalizaciones.pl predicado: condiciones_de/2 condicion/4 comunes/3 esta_en/2 -->
```prolog
%!  condiciones_de(+C, -Cs:list) is det.
%
%   Cs es el concepto o la instancia C como lista de condiciones
%   Atributo = Valor, sin las de los atributos libres.
condiciones_de(C, Cs) :-
    C =.. [pieza|Valores],
    findall(A, atributo(A, _), Atributos),
    foldl(condicion, Atributos, Valores, Cs, []).

%!  condicion(+A, +V, ?Cs0:list, ?Cs:list) is det.
%
%   Cs0 es Cs con la condición A = V al frente si V no es una variable.
condicion(A, V, Cs0, Cs) :-
    (   var(V)
    ->  Cs0 = Cs
    ;   Cs0 = [A = V|Cs]
    ).

%!  comunes(+Cs1:list, +Cs2:list, -Cs:list) is det.
%
%   Cs son las condiciones de Cs1 que también están en Cs2: la
%   generalización que quita de una conjunción las condiciones que el
%   otro ejemplo no cumple.
comunes(Cs1, Cs2, Cs) :-
    include(esta_en(Cs2), Cs1, Cs).

%!  esta_en(+Cs:list, +C) is semidet.
%
%   La condición C está en Cs.
esta_en(Cs, C) :-
    memberchk(C, Cs).
```

```prolog
?- condiciones_de(pieza(esfera, rojo, chico, madera), Cs).
Cs = [forma=esfera, color=rojo, tamano=chico, material=madera].

?- comunes([forma=esfera, color=rojo, tamano=chico, material=madera], [forma=esfera, color=rojo, tamano=grande, material=metal], Cs).
Cs = [forma=esfera, color=rojo].
```

El resultado es la lectura de `pieza(esfera, rojo, _, _)`, el mismo
concepto que da `generalizacion/3` de la
[sección 69.2](index.md#692-version-2-una-sola-direccion) con las dos
instancias. No es una coincidencia: en un lenguaje donde cada atributo
es un valor o una variable propia, reemplazar un valor por una variable
y quitar la condición sobre ese atributo son la misma operación vista de
dos maneras. Una de las pruebas de `generalizaciones.plt` lo verifica
para cuatro pares de instancias. Las dos operaciones se separan en
lenguajes más ricos, como las cláusulas del
[capítulo 68](../capitulo-68-proyecto-aprender-reglas-ejemplos/index.md),
donde quitar un literal del cuerpo no equivale a reemplazar una
constante.

### Subir en una jerarquía de clases

Entre un valor y la variable que admite cualquier valor puede haber
clases intermedias. La jerarquía de este ejemplo agrupa las formas en
redondeadas y poliedros, y los colores en cálidos y fríos:

```mermaid
flowchart TD
    F["cualquier forma"] --> R[redondeada]
    F --> P[poliedro]
    R --> esfera
    R --> cilindro
    P --> cubo
    C["cualquier color"] --> K[calido]
    C --> W[frio]
    K --> rojo
    W --> verde
    W --> azul
```

<!-- ejemplo: capitulo-69/generalizaciones.pl predicado: clase/2 -->
```prolog
% clase(V, K): el valor V pertenece a la clase K.
clase(esfera, redondeada).
clase(cilindro, redondeada).
clase(cubo, poliedro).
clase(rojo, calido).
clase(verde, frio).
clase(azul, frio).
```

Generalizar dos valores es ahora subir hasta el nodo más bajo que los
tiene a los dos debajo: el valor mismo si son iguales, la clase común si
la hay, una variable si no. El primer valor puede ser ya una clase,
porque el borde específico se generaliza con cada positivo nuevo:

<!-- ejemplo: capitulo-69/generalizaciones.pl predicado: subir/3 clase_o_valor/2 generalizacion_jerarquia/3 -->
```prolog
%!  subir(+V1, +V2, -G) is det.
%
%   G es la generalización mínima de los valores V1 y V2 en la jerarquía:
%   el valor mismo si son iguales, la clase común si la tienen, una
%   variable si no. V1 puede ser ya una clase o una variable.
subir(V1, V2, G) :-
    (   var(V1)
    ->  true
    ;   V1 == V2
    ->  G = V1
    ;   clase_o_valor(V1, K),
        clase(V2, K)
    ->  G = K
    ;   true
    ).

%!  clase_o_valor(+V, -K) is semidet.
%
%   K es la clase de V si V es un valor, o V si V ya es una clase.
clase_o_valor(V, K) :-
    (   clase(V, K0)
    ->  K = K0
    ;   clase(_, V)
    ->  K = V
    ).

%!  generalizacion_jerarquia(+S, +I, -S1) is det.
%
%   S1 es la generalización mínima del concepto S que cubre la instancia
%   I, subiendo cada atributo en la jerarquía: I misma si S es vacio.
generalizacion_jerarquia(S, I, S1) :-
    (   S == vacio
    ->  S1 = I
    ;   S =.. [pieza|Vs],
        I =.. [pieza|Ws],
        maplist(subir, Vs, Ws, Gs),
        S1 =.. [pieza|Gs]
    ).
```

Un concepto con clases cubre una instancia si cada atributo es una
variable, el mismo valor o la clase del valor:

<!-- ejemplo: capitulo-69/generalizaciones.pl predicado: cubre_jerarquia/2 cubre_valor/2 -->
```prolog
%!  cubre_jerarquia(@C, +I) is semidet.
%
%   El concepto C, con valores, clases o variables, cubre la instancia I.
cubre_jerarquia(C, I) :-
    C \== vacio,
    C =.. [pieza|Vs],
    I =.. [pieza|Ws],
    maplist(cubre_valor, Vs, Ws).

%!  cubre_valor(@V, +W) is semidet.
%
%   V es una variable, el valor W o la clase de W.
cubre_valor(V, W) :-
    (   var(V)
    ->  true
    ;   V == W
    ->  true
    ;   clase(W, V)
    ).
```

La secuencia `redondas_rojas` describe las piezas rojas de forma
redondeada, con dos positivos (una esfera y un cilindro) y dos negativos
(un cubo rojo y una esfera verde). Sin la jerarquía, la generalización
de los dos positivos libera la forma, y el concepto resultante cubre el
cubo rojo, que es negativo:

```prolog
?- generalizacion(pieza(esfera, rojo, chico, madera), pieza(cilindro, rojo, grande, madera), S), cubre_jerarquia(S, pieza(cubo, rojo, chico, madera)).
S = pieza(_, rojo, _, madera).
```

El espacio de versiones de la
[sección 69.3](index.md#693-version-3-eliminacion-de-candidatos) colapsa
con esta secuencia: el concepto no es expresable en el lenguaje. Con la
jerarquía, la forma sube solo hasta `redondeada`:

```prolog
?- generalizacion_jerarquia(pieza(esfera, rojo, chico, madera), pieza(cilindro, rojo, grande, madera), S).
S = pieza(redondeada, rojo, _, madera).
```

`especifico_jerarquia/2` es la búsqueda de lo específico a lo general
de la versión 2 con esta generalización: recorre los positivos y
verifica al final que el concepto no cubra ningún negativo.

<!-- ejemplo: capitulo-69/generalizaciones.pl predicado: subir_con/3 especifico_jerarquia/2 -->
```prolog
%!  subir_con(+I, +S, -S1) is det.
%
%   generalizacion_jerarquia/3 con la instancia primero, para foldl/4.
subir_con(I, S, S1) :-
    generalizacion_jerarquia(S, I, S1).

%!  especifico_jerarquia(+Nombre, -S) is det.
%
%   S es el concepto más específico que cubre los positivos de la
%   secuencia Nombre, con la jerarquía, o colapso si cubre un negativo.
especifico_jerarquia(Nombre, S) :-
    ejemplos_de(Nombre, Ejs),
    findall(I, member(pos(I), Ejs), Pos),
    foldl(subir_con, Pos, vacio, S0),
    (   member(neg(N), Ejs),
        cubre_jerarquia(S0, N)
    ->  S = colapso
    ;   S = S0
    ).
```

```prolog
?- especifico_jerarquia(redondas_rojas, S).
S = pieza(redondeada, rojo, _, madera).

?- especifico_jerarquia(rojo_o_esfera, S).
S = colapso.
```

La jerarquía amplía el lenguaje, pero no lo vuelve capaz de expresar
cualquier concepto: la secuencia `rojo_o_esfera` de la
[sección 69.3](index.md#693-version-3-eliminacion-de-candidatos) sigue
colapsando, porque «rojo o esfera» no es una clase de la jerarquía. Cada
clase agregada es una decisión de quien escribe el lenguaje, y es el
**sesgo** del aprendiz: lo que puede aprender está fijado de antemano
por los conceptos que puede representar.

### Agregar un disyunto

La operación más fuerte es la disyunción: un concepto pasa a ser una
lista de conceptos, y cubre una instancia si alguno de ellos la cubre.
Con disyunciones, todo conjunto de ejemplos sin contradicciones tiene un
concepto consistente. `disyuncion_de/2` procesa los positivos en orden:
cada uno se generaliza con el primer disyunto con el que el resultado
sigue sin cubrir ningún negativo, o se agrega como un disyunto nuevo:

<!-- ejemplo: capitulo-69/generalizaciones.pl predicado: disyuncion/2 disyuncion_de/2 agregar_positivo/4 cubre_disyuncion/2 -->
```prolog
%!  disyuncion(+Nombre, -D:list) is det.
%
%   D es una disyunción de conceptos que cubre los positivos de la
%   secuencia Nombre y ningún negativo: cada positivo se generaliza con el
%   primer disyunto con el que la generalización sigue siendo consistente,
%   o se agrega como un disyunto nuevo.
disyuncion(Nombre, D) :-
    ejemplos_de(Nombre, Ejs),
    disyuncion_de(Ejs, D).

%!  disyuncion_de(+Ejs:list, -D:list) is det.
%
%   D es la disyunción de disyuncion/2 para la lista de ejemplos Ejs.
disyuncion_de(Ejs, D) :-
    findall(N, member(neg(N), Ejs), Negs),
    findall(I, member(pos(I), Ejs), Pos),
    foldl(agregar_positivo(Negs), Pos, [], D).

%!  agregar_positivo(+Negs:list, +I, +D0:list, -D:list) is det.
%
%   D es la disyunción D0 extendida para cubrir la instancia I sin cubrir
%   ningún ejemplo de Negs.
agregar_positivo(Negs, I, D0, D) :-
    (   append(Antes, [C|Despues], D0),
        generalizacion(C, I, C1),
        \+ ( member(N, Negs),
             cubre(C1, N) )
    ->  append(Antes, [C1|Despues], D)
    ;   append(D0, [I], D)
    ).

%!  cubre_disyuncion(+D:list, +I) is semidet.
%
%   Algún disyunto de D cubre la instancia I.
cubre_disyuncion(D, I) :-
    member(C, D),
    cubre(C, I),
    !.
```

```prolog
?- disyuncion(rojo_o_esfera, D).
D = [pieza(esfera, verde, chico, madera), pieza(cubo, rojo, chico, madera)].

?- disyuncion(esferas_y_cubos_verdes, D).
D = [pieza(esfera, _, _, _), pieza(cubo, verde, grande, metal)].
```

Con `rojo_o_esfera` la disyunción no generaliza nada: los dos positivos
quedan como disyuntos sin variables, y la disyunción solo cubre los
ejemplos vistos. Es el riesgo de la operación: sin otra restricción,
la disyunción de los positivos es siempre consistente y no clasifica
ninguna instancia nueva. Con `esferas_y_cubos_verdes` la esfera roja y
la esfera azul se generalizan en `pieza(esfera, _, _, _)`, y el cubo
verde queda aparte. El resultado depende del orden de los positivos,
como muestra el [ejercicio 13](#ejercicios). Cuando el concepto
es conjuntivo, la disyunción tiene un solo disyunto, y coincide con el
borde específico de la versión 2; una de las pruebas lo verifica con
`esfera_roja`.

Las secuencias nuevas se agregan a las de `espacio.pl` con
`ejemplos_de/2`:

<!-- ejemplo: capitulo-69/generalizaciones.pl predicado: ejemplos_de/2 secuencia7/2 -->
```prolog
%!  ejemplos_de(+Nombre, -Ejs:list) is semidet.
%
%   Ejs es la secuencia Nombre: una de las de espacio.pl o una de este
%   archivo.
ejemplos_de(Nombre, Ejs) :-
    (   secuencia(Nombre, Ejs0)
    ->  Ejs = Ejs0
    ;   secuencia7(Nombre, Ejs)
    ).

% secuencia7(Nombre, Ejs): una secuencia de ejemplos de esta versión.
% redondas_rojas: las piezas rojas de forma redondeada.
secuencia7(redondas_rojas,
           [ pos(pieza(esfera, rojo, chico, madera)),
             pos(pieza(cilindro, rojo, grande, madera)),
             neg(pieza(cubo, rojo, chico, madera)),
             neg(pieza(esfera, verde, chico, madera))
           ]).
% esferas_y_cubos_verdes: un concepto que no es conjuntivo.
secuencia7(esferas_y_cubos_verdes,
           [ pos(pieza(esfera, rojo, chico, madera)),
             pos(pieza(cubo, verde, grande, metal)),
             pos(pieza(esfera, azul, grande, metal)),
             neg(pieza(cubo, rojo, chico, madera)),
             neg(pieza(cilindro, verde, chico, metal))
           ]).
```

### Incorporar las reglas aprendidas

La versión 6 aprende una regla de cada ejemplo, pero no la guarda: cada
taza nueva se explica otra vez con la teoría. Luger y Stubblefield
proponen, como ejercicio, que el programa agregue cada regla aprendida a
la base. `reconocer/3` prueba primero las reglas aprendidas; si ninguna
reconoce el objeto, lo explica con la teoría, generaliza la explicación
con `ebg/5` y guarda la regla con `assertz/1`:

<!-- ejemplo: capitulo-69/incorporar.pl predicado: olvidar/1 aprendidas/2 reconocer/3 -->
```prolog
%!  olvidar(+T) is det.
%
%   Quita las reglas aprendidas de la teoría T.
olvidar(T) :-
    retractall(aprendida(T, _)).

%!  aprendidas(+T, -Rs:list) is det.
%
%   Rs son las reglas aprendidas de la teoría T, en el orden en que se
%   aprendieron.
aprendidas(T, Rs) :-
    findall(R, aprendida(T, R), Rs).

%!  reconocer(+T, +Objeto, -Como) is det.
%
%   Objeto es un par O-Hechos. Como es regla si una regla aprendida de T
%   reconoce a O como taza, teoria si hizo falta la teoría (y la regla
%   que se aprende de la explicación queda guardada), y no si O no es una
%   taza.
reconocer(T, O-Hs, Como) :-
    Meta = taza(O),
    (   aprendida(T, R),
        aplicar(T, R, Hs, Meta)
    ->  Como = regla
    ;   operacionales(T, Ops),
        once(ebg(T, Ops, Hs, Meta, R))
    ->  assertz(aprendida(T, R)),
        Como = teoria
    ;   Como = no
    ).
```

`recorrer/2` empieza sin reglas y reconoce, en orden, los 48 objetos de
la población de la versión 6:

<!-- ejemplo: capitulo-69/incorporar.pl predicado: recorrer/2 -->
```prolog
%!  recorrer(+T, -Usos:list) is det.
%
%   Olvida las reglas de T y reconoce, en orden, los objetos de la
%   población. Usos es la lista de pares Como-Cantidad: cuántos objetos se
%   reconocieron con una regla, cuántos con la teoría y cuántos no son
%   tazas.
recorrer(T, Usos) :-
    olvidar(T),
    poblacion(Os),
    maplist(reconocer(T), Os, Comos),
    findall(C-N, ( member(C, [regla, teoria, no]),
                   aggregate_all(count, member(C, Comos), N) ),
            Usos).
```

```prolog
?- recorrer(taza, Usos).
Usos = [regla-2, teoria-2, no-44].
```

De las cuatro tazas, dos necesitan la teoría y dos se reconocen con una
regla que ya estaba guardada. La primera taza de la población es liviana
por el peso: la teoría la explica y deja la regla de la taza de 150
gramos. La segunda, de cartón y 150 gramos, la reconoce esa regla. La
tercera pesa 900 gramos y es liviana por el material: la regla del peso
no la reconoce, la teoría sí, y queda una segunda regla, la del cartón.
La cuarta, de cartón y sin peso registrado, la reconoce la segunda
regla. Al terminar hay dos reglas, las mismas que la versión 6 aprende
de `taza1` y `taza2`.

La teoría solo se usa con las tazas que lo son por una razón nueva, pero
los 44 objetos que no son tazas se prueban primero contra las reglas y
después contra la teoría, porque el programa no puede saber que no son
tazas sin agotar las dos. El [ejercicio 14](#ejercicios) mide lo
que eso cuesta.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; los que calculan bordes y reglas son `det` o `semidet`, y `explicar/4` y `ebg/5` son `nondet`, una respuesta por prueba |
    | C2 | los conceptos, los ejemplos, las teorías y las descripciones son datos; la teoría y la descripción de cada ejemplo están separadas, y las reglas de la familia se leen del [capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md), sin copiarlas |
    | C4 | `cubre/2` y `generaliza/2` no ligan los conceptos: comparan con `subsumes_term/2`; `con_extra/2` quita los atributos agregados aunque la medición falle |
    | C7 | 143 pruebas en los diez archivos del programa y 46 en las soluciones; los bordes de las versiones 2 y 3 se comparan con los de la enumeración en cada prefijo, el aprendiz activo con los 144 conceptos, y las reglas aprendidas con la teoría en la población |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

13. **(2)** Escribir `disyunciones(Nombre, Ds)`, las disyunciones
    distintas que da `disyuncion_de/2` de la
    [sección 69.7](#agregar-un-disyunto) con cada
    orden de los positivos de la secuencia Nombre, seguidos de los
    negativos. Aplicarlo a `esferas_y_cubos_verdes` y a `rojo_o_esfera`,
    y explicar de qué depende que el orden cambie el resultado.
14. **(2)** Medir con `inferencias/2` el costo de `recorrer(taza, _)`,
    el de `clasificar_con_teoria(taza, _)` y el de una segunda pasada de
    `reconocer/3` por la población, con las reglas que dejó la primera.
    Explicar por qué guardar las reglas no abarata el reconocimiento en
    esta población, y en qué población lo abarataría.

## Resumen

| | |
|---|---|
| **instancia, concepto** | una pieza sin variables; un término con valores y variables, o `vacio` |
| **orden de generalidad** | G es al menos tan general como E si cubre todo lo que E cubre: la θ-subsunción |
| **espacio de versiones** | los conceptos consistentes con los ejemplos vistos |
| **bordes S y G** | los conceptos mínimos y máximos del espacio de versiones |
| **generalización mínima** | la lgg de un concepto y una instancia |
| **especialización mínima** | fijar un atributo libre en un valor distinto del del negativo |
| **eliminación de candidatos** | mantener S y G juntos, cada uno podado por el otro |
| **convergencia, colapso** | S y G iguales y únicos; un borde vacío |
| **aprendiz activo** | elige la instancia que divide el espacio en partes parecidas y pide su clase |
| **teoría del dominio** | reglas que definen el concepto a partir de predicados operacionales |
| **criterio de operacionalidad** | los predicados en los que se detiene la generalización de la prueba |
| **generalización basada en la explicación** | la prueba del ejemplo y la de su copia general, con las mismas reglas |
| `varnumbers/2` | el inverso de `numbervars/3`: cada `'$VAR'(N)` pasa a ser una variable nueva |
| `atributo/2`, `concepto/1`, `cubre/2`, `generaliza/2`, `version/2`, `minimos/2`, `maximos/2` | la versión 1 |
| `generalizacion/3`, `especializacion/3`, `especifico/2`, `general/2` | la versión 2 |
| `actualizar/3`, `eliminar/2`, `entre_bordes/2` | la versión 3 |
| **[Patrón 67](../patrones.md#67-bordes-en-lugar-del-conjunto)** | bordes en lugar del conjunto |
| `clasificar/3`, `votos/4`, `mejor_pregunta/2`, `activo/3`, `pasivo/3` | la versión 4 |
| `regla/2`, `operacionales/2`, `explicar/4`, `como/3` | la versión 5 |
| `ebg/5`, `aprender/4`, `aprender_con/5`, `aplicar/4`, `reconocidas/3` | la versión 6 |
| **sesgo del lenguaje** | lo que un aprendiz puede aprender queda fijado por los conceptos que puede representar |
| `condiciones_de/2`, `comunes/3`, `clase/2`, `generalizacion_jerarquia/3`, `cubre_jerarquia/2`, `especifico_jerarquia/2`, `disyuncion/2`, `disyuncion_de/2` | la versión 7: otras generalizaciones |
| `reconocer/3`, `recorrer/2`, `aprendidas/2`, `olvidar/1` | la versión 7: incorporar las reglas |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Aprender un concepto ajustando números en lugar de buscar en un espacio de términos | [capítulo 70](../capitulo-70-proyecto-perceptron/index.md) |

## Referencias

- George F. Luger y William A. Stubblefield, *AI Algorithms, Data
  Structures, and Idioms in Prolog, Lisp, and Java*, Pearson
  Addison-Wesley, 2009 — capítulo «Machine Learning Algorithms in Prolog»,
  secciones «Machine Learning: Version Space Search» y «Explanation Based
  Learning in Prolog».
  [Edición en línea del autor](https://www.cs.unm.edu/~luger/ai-final2/CH7_Machine%20Learning%20Algorithms%20in%20Prolog.pdf).
  Esta página toma de allí las otras tres operaciones de generalización
  (quitar condiciones, subir en una jerarquía de clases, agregar un
  disyunto) y el ejercicio de agregar a la base las reglas aprendidas.

El código del capítulo es propio, escrito para el curso: de Luger y
Stubblefield se toman las ideas y la estructura de los algoritmos, no el
código. Son del curso las piezas y sus atributos, el concepto `vacio`, la
comparación de los bordes con la enumeración, la medición con atributos
extra, el aprendiz activo, la teoría separada de la descripción del
ejemplo, el árbol de prueba del [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md), la teoría de la familia leída
del [capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md), la medición del costo de las reglas aprendidas, y la jerarquía
de clases, las secuencias y la disyunción voraz de la versión 7.
