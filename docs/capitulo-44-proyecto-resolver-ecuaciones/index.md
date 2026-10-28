# Capítulo 44 — Proyecto: resolver ecuaciones

Resolver una ecuación `Izq = Der` en una incógnita `x` es transformarla,
con pasos que conservan sus soluciones, hasta llegar a `x = E`, con `E` sin
`x`. La tarea es simbólica: la ecuación es un término, y cada paso es una
reescritura de ese término. Este capítulo construye un programa que la hace
con cuatro métodos que se prueban en orden, como los aplica quien estudia
álgebra: el **aislamiento**, cuando la incógnita aparece una sola vez; la
**colección**, que reduce la cantidad de apariciones; la **atracción**, que
las acerca entre sí; y el método del **polinomio**, que lleva la ecuación a
una forma normal. Cuando ningún método simbólico da una solución, el
programa busca raíces numéricas con el **método de Newton**.

![Dos páginas manuscritas en árabe, con dos diagramas de cuadrados y rectángulos trazados en rojo al pie](al-juarismi.jpg)

Dos páginas de una copia de 1342 del *Compendio de cálculo por restauración y
oposición* de al-Juarismi (siglo IX), con las soluciones geométricas de dos
ecuaciones cuadráticas. *Al-jabr*, la «restauración», pasa un término al otro
lado de la ecuación, el paso que el aislamiento repite en cada nivel; de esa
palabra viene «álgebra». Imagen: Muhammad ibn Musa al-Juarismi, Bodleian
Libraries (MS. Huntington 214, fol. 4v–5r), dominio público
([PD-Art](https://commons.wikimedia.org/wiki/Template:PD-Art)), vía
[Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Bodleian_MS._Huntington_214_roll332_frame36.jpg).

Una ecuación que necesita tres de esos métodos, uno detrás de otro, recorre
este camino; cada flecha es un método, y la última solución se descarta al
comprobarla en la ecuación original:

```mermaid
flowchart LR
    E0["log(x + 1) + log(x - 1) = 3"] -- "atracción" --> E1["log((x + 1) * (x - 1)) = 3"]
    E1 -- "colección" --> E2["log(x ^ 2 - 1 * 1) = 3"]
    E2 -- "aislamiento" --> S1["x = sqrt(exp(3) + 1)"]
    E2 -- "aislamiento" --> S2["x = -sqrt(exp(3) + 1)<br/>(no cumple la ecuación)"]
```

El programa crece en cinco versiones, una por sección, y cada una termina con
una ecuación que no puede resolver y que motiva la siguiente. Reutiliza, sin
copiarlos, el simplificador, `apariciones/3`, `evaluar/3` y `derivar/3` del
[capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md); escribe las reglas de colección y de atracción como datos que
`term_expansion/2`, del [capítulo 36](../capitulo-36-transformacion-de-programas-y-compilacion/index.md), convierte en cláusulas al cargarlas; y
usa como forma normal de un polinomio la suma asociada a izquierda que el
ejercicio 13 del [capítulo 35](../capitulo-35-estructuras-incompletas-y-listas-diferencia/index.md) construye. Cumple así los anuncios de esos
tres capítulos. Todos los archivos del capítulo son módulos que cargan otros
módulos, y por eso se ejecutan en una instalación local, no en SWISH.

El proyecto parte principalmente de cuatro libros. El capítulo «An Equation Solver», el 23,
de *The Art of Prolog* de Leon Sterling y Ehud Shapiro
([préstamo en el Internet Archive](https://archive.org/details/artofprologadvan00ster)),
presenta una versión simplificada de PRESS, el programa de Alan Bundy y Bob
Welham en Edimburgo: de él vienen la idea de probar los métodos en orden, la
posición de la incógnita como una lista de números de argumento, los axiomas
de aislamiento con una solución por axioma, la forma normal de un polinomio
como lista de coeficientes y grados, y los métodos de factorización y de
homogeneización que los ejercicios agregan. La colección y la atracción son
otros dos métodos de PRESS, descritos en el artículo de Bundy y Welham (1981)
y en la presentación de PRESS de Sterling, Bundy, Byrd, O'Keefe y Silver
(1982), que Sterling y Shapiro citan; la homogeneización del ejercicio 5
sigue a Bundy y Silver (1981). El capítulo «Case Study: Term Rewriting», el
sexto, de *Clause and Effect* de William Clocksin aporta la etapa de forma normal
antes de reescribir: llevar la negación hacia adentro y dejar la
simplificación a un paso separado. El apartado 7.11, «Symbolic
Differentiation», de *Programming in Prolog* de Clocksin y Mellish, es el
origen de la derivada que el [capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md) escribió y que el método de Newton
usa. El apartado 7.13, «Solving equations numerically», de *Prolog
Programming in Depth* de Michael Covington
([PDF del autor](https://www.covingtoninnovations.com/books/PPID.pdf)) resuelve
ecuaciones buscando un cero de `Izq - Der` y enumera las formas en que esa
búsqueda falla. Los programas del capítulo están escritos para el curso.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- representar una ecuación como un término y resolverla con reescrituras que
  conservan sus soluciones;
- aislar una incógnita que aparece una vez, con su posición como una lista de
  números de argumento y un axioma por operación;
- escribir reglas de reescritura como datos, cargarlas como cláusulas con
  `term_expansion/2` y aplicarlas a un subtérmino cualquiera;
- asegurar que una cadena de reescrituras termina con una medida que cada
  paso debe reducir: la cantidad de apariciones o la distancia entre ellas;
- llevar un polinomio a una forma normal con pares, `keysort/2` y
  `group_pairs_by_key/2`, y resolver los de grado 1 y 2;
- usar el método de Newton como respaldo numérico, y comprobar cada
  solución en la ecuación original;
- extender el programa con axiomas, reglas y métodos nuevos sin modificar
  sus archivos;
- agregar métodos de PRESS que trabajan sobre la forma de la ecuación: la
  homogeneización, el intercambio de funciones, el emparejamiento
  conmutativo, los intervalos y las desigualdades.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **3:35 h**.
    Resolver los 5 ejercicios marcados con ★: **1:35 h**.
    Resolver los 14 ejercicios del capítulo: **4:20 h**.

## 44.1 El programa terminado

La versión final está en `ecuaciones.pl`. `resolver(Ecuacion, X, Solucion)`
da una solución por respuesta, y `valores(Ecuacion, X, Vs)` los valores
numéricos de las que cumplen la ecuación original:

<!-- ejemplo: capitulo-44/ecuaciones.pl predicado: resolver/3 -->
```prolog
%!  resolver(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = E, una solución de la Ecuacion cerrada en la
%   incógnita X: E sin X, si la da un método simbólico; si ninguno la da,
%   E es un número, una raíz hallada con el método de Newton.
resolver(Ecuacion, X, Solucion) :-
    (   resolver_simbolico(Ecuacion, X, Solucion)
    *-> true
    ;   resolver_numerico(Ecuacion, X, Solucion)
    ).
```

```prolog
?- resolver(1 - 2 * sin(x) = 0, x, S).
S = (x=asin(1/2)) ;
S = (x=pi-asin(1/2)) ;
false.

?- resolver(log(x + 1) + log(x - 1) = 3, x, S).
S = (x=sqrt(exp(3)+1)) ;
S = (x= -sqrt(exp(3)+1)) ;
false.

?- valores(log(x + 1) + log(x - 1) = 3, x, Vs).
Vs = [4.591899054115592].

?- resolver(x ^ 3 - 2 * x - 5 = 0, x, S).
S = (x=2.0945514815423265).

?- valores(x ^ 4 - 5 * x ^ 2 + 4 = 0, x, Vs).
Vs = [-2.0, -1, 1, 2.0].
```

`log/1` es el logaritmo natural. La primera ecuación se resuelve por
aislamiento, y sus dos respuestas son las dos soluciones del seno entre
$-\pi/2$ y $3\pi/2$. La segunda necesita atraer los dos logaritmos en uno
solo y colectar el producto que queda; da dos soluciones simbólicas, pero la
negativa no cumple la ecuación, porque el logaritmo de un número negativo no
tiene valor real, y `valores/3` la descarta. La tercera es un polinomio de
grado 3, que ningún método simbólico del programa resuelve: la respuesta es
numérica. La cuarta, de grado 4, también.

El programa está repartido en siete módulos, cada uno sobre los anteriores:

| Archivo | Sección | Agrega |
|---|---|---|
| `capitulo33.pl` | 44.2 | los predicados del [capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md), cargados en un módulo |
| `aislar.pl` | 44.2 | versión 1: la posición de la incógnita y el aislamiento |
| `reescribir.pl` | 44.3 | la notación de las reglas y su aplicación a un subtérmino |
| `colectar.pl` | 44.3 | versión 2: la colección |
| `atraer.pl` | 44.4 | versión 3: la atracción |
| `polinomio.pl` | 44.5 | versión 4: la forma normal y el polinomio |
| `ecuaciones.pl` | 44.6 | versión 5: Newton y la comprobación |

## 44.2 Versión 1: el aislamiento

Los archivos del [capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md) no son módulos, y dos de ellos definen
`simplificar/2` de dos formas distintas: `simplificar.pl`, el de la
[sección 33.7](../capitulo-33-inspeccion-de-terminos/index.md#337-un-simplificador-de-expresiones), y `soluciones_simplificar.pl`, que agrega las reglas del
ejercicio 11 y define `derivar/3`. Cargarlos juntos reemplazaría una
definición por la otra. `capitulo33.pl` los carga en módulos separados con
`load_files/2` y el nombre del módulo delante del archivo, `Modulo:Archivo`,
que carga en ese módulo un archivo que no declara el suyo:

<!-- ejemplo: capitulo-44/capitulo33.pl fragmento: :- module(capitulo33, .. derivadas33:derivar(E, X, D). -->
```prolog
:- module(capitulo33,
          [ simplificar/2,
            apariciones/3,
            derivar/3,
            evaluar/3
          ]).

:- load_files(capitulo33:'../capitulo-33/simplificar', []).
:- load_files(capitulo33:'../capitulo-33/soluciones', []).
:- load_files(derivadas33:'../capitulo-33/soluciones_simplificar', []).

%!  derivar(+E, +X:atom, -D) is det.
%
%   D es la derivada simplificada de la expresión cerrada E respecto de X,
%   calculada por derivar/3 del capítulo 33: E usa +, -, * y ^ con
%   exponente numérico, y cualquier otra operación produce un error de
%   dominio.
derivar(E, X, D) :-
    derivadas33:derivar(E, X, D).
```

Una ecuación es un término `Izq = Der` y la incógnita es un átomo. Si la
incógnita aparece una sola vez, su **posición** es la lista de números de
argumento que lleva de la ecuación hasta ella. `posicion/3` la calcula con
`arg/3`, que con el número libre recorre los argumentos:

<!-- ejemplo: capitulo-44/aislar.pl predicado: posicion/3 -->
```prolog
%!  posicion(+S, +T, -Camino:list(integer)) is nondet.
%
%   Camino es la lista de números de argumento que lleva de T a un
%   subtérmino idéntico (==) a S. Hay una respuesta por aparición.
posicion(S, T, []) :-
    T == S.
posicion(S, T, [N|Camino]) :-
    compound(T),
    arg(N, T, A),
    posicion(S, A, Camino).
```

```prolog
?- posicion(x, 1 - 2 * sin(x) = 0, P).
P = [1, 2, 2, 1] ;
false.
```

El primer número dice de qué lado está la incógnita: el lado 1, el
izquierdo. Los siguientes dicen qué argumento seguir en cada nivel: el 2 de
`1 - 2 * sin(x)`, el 2 de `2 * sin(x)` y el 1 de `sin(x)`. Cada número elige
un **axioma de aislamiento**, que pasa al lado derecho la operación de la
raíz del lado izquierdo, con su inversa:

<!-- ejemplo: capitulo-44/aislar.pl predicado: axioma/3 -->
```prolog
%!  axioma(+N:integer, +Ecuacion0, -Ecuacion) is nondet.
%
%   Ecuacion es equivalente a Ecuacion0, con la operación de la raíz del
%   lado izquierdo pasada al lado derecho; la incógnita está en el
%   argumento N de esa operación. Hay una respuesta por cada solución que
%   el axioma separa. Es multifile: otro archivo puede agregar axiomas.
axioma(1, -U = W, U = -W).
axioma(1, U + V = W, U = W - V).
axioma(2, U + V = W, V = W - U).
axioma(1, U - V = W, U = W + V).
axioma(2, U - V = W, V = U - W).
axioma(1, U * V = W, U = W / V) :-
    V \== 0.
axioma(2, U * V = W, V = W / U) :-
    U \== 0.
axioma(1, U ^ 2 = W, U = sqrt(W)).
axioma(1, U ^ 2 = W, U = -sqrt(W)).
axioma(1, U ^ N = W, U = W ^ (1 / N)) :-
    N \== 2.
axioma(2, A ^ U = W, U = log(W) / log(A)).
axioma(1, sqrt(U) = W, U = W ^ 2).
axioma(1, exp(U) = W, U = log(W)).
axioma(1, log(U) = W, U = exp(W)).
axioma(1, sin(U) = W, U = asin(W)).
axioma(1, sin(U) = W, U = pi - asin(W)).
axioma(1, cos(U) = W, U = acos(W)).
axioma(1, cos(U) = W, U = -acos(W)).
axioma(1, tan(U) = W, U = atan(W)).
```

Las operaciones son funciones de `is/2`: `sin/1`, `cos/1` y `tan/1` toman el
ángulo en radianes, y `asin/1`, `acos/1` y `atan/1`, sus inversas, dan un
solo valor; `acos(0)` vale π/2.

Tres detalles de los axiomas. El primer argumento es el número del argumento
que contiene la incógnita, y por eso la resta y el producto tienen un axioma
por argumento. Un axioma que divide exige que el divisor no sea 0, porque
dividir por 0 no es una transformación que conserve las soluciones. Y una
operación cuya inversa tiene más de un valor, como `sin/1`, `cos/1` o el
cuadrado, tiene un axioma por solución: el retroceso da las dos. El
aislamiento orienta la ecuación con la incógnita a la izquierda y aplica un
axioma por cada número de la posición:

<!-- ejemplo: capitulo-44/aislar.pl predicado: aislar/3 orientar/3 aislar_camino/3 -->
```prolog
%!  aislar(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es la Ecuacion con X, que aparece una sola vez, aislada a la
%   izquierda. Falla si X no aparece o aparece más de una vez.
aislar(Ecuacion, X, Solucion) :-
    apariciones(Ecuacion, X, 1),
    posicion(X, Ecuacion, [Lado|Camino]),
    orientar(Lado, Ecuacion, Ecuacion1),
    aislar_camino(Camino, Ecuacion1, Solucion).

%!  orientar(+Lado:integer, +Ecuacion, -Orientada) is det.
%
%   Orientada es la Ecuacion con el lado número Lado a la izquierda.
orientar(1, Izq = Der, Izq = Der).
orientar(2, Izq = Der, Der = Izq).

%!  aislar_camino(+Camino:list(integer), +Ecuacion, -Aislada) is nondet.
%
%   Aislada resulta de aplicar a la Ecuacion un axioma por cada número de
%   Camino, la posición de la incógnita en el lado izquierdo.
aislar_camino([], Ecuacion, Ecuacion).
aislar_camino([N|Camino], Ecuacion0, Ecuacion) :-
    axioma(N, Ecuacion0, Ecuacion1),
    aislar_camino(Camino, Ecuacion1, Ecuacion).
```

`resolver/3` verifica los argumentos, aísla y simplifica el resultado con el
simplificador del [capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md):

<!-- ejemplo: capitulo-44/aislar.pl predicado: resolver/3 -->
```prolog
%!  resolver(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = E, con E sin X, una solución de la Ecuacion cerrada
%   Izq = Der en la incógnita X, simplificada. Hay una respuesta por
%   solución; falla si X no aparece exactamente una vez.
resolver(Ecuacion, X, X = E) :-
    must_be(ground, Ecuacion),
    must_be(atom, X),
    aislar(Ecuacion, X, X = E0),
    simplificar(E0, E).
```

```prolog
?- resolver(1 - 2 * sin(x) = 0, x, S).
S = (x=asin(1/2)) ;
S = (x=pi-asin(1/2)) ;
false.

?- resolver(3 * x + 2 = 11, x, S).
S = (x=9/3) ;
false.

?- resolver(2 ^ (x + 1) = 16, x, S).
S = (x=log(16)/log(2)-1) ;
false.
```

La solución de la primera ecuación pasa por `2 * sin(x) = 1 - 0`,
`sin(x) = (1 - 0) / 2` y `x = asin((1 - 0) / 2)`; el simplificador reduce
`1 - 0`, pero no tiene reglas para `/`, y `9 / 3` queda sin evaluar. La
solución es una expresión, no un número: `x = 9/3` es exacta, y su valor se
obtiene con `is/2` cuando hace falta.

!!! question "Actividad"
    Predecir la posición de `x` en `2 ^ (x + 1) = 16` y la secuencia de
    ecuaciones por la que pasa el aislamiento, y cuántas respuestas da
    `resolver(cos(x) = 1, x, S)`. Comprobarlo, y explicar por qué las dos
    respuestas de la segunda tienen el mismo valor.

El aislamiento exige una sola aparición:

```prolog
?- resolver(2 * x + 3 * x = 10, x, S).
false.

?- posicion(x, 2 * x + 3 * x = 10, P).
P = [1, 1, 2] ;
P = [1, 2, 2] ;
false.
```

Con dos apariciones hay dos posiciones, y aislar una deja la otra del lado
derecho. Hace falta un método que reduzca las apariciones antes de aislar.

## 44.3 Versión 2: reglas de reescritura y colección

La **colección** reescribe un subtérmino de la ecuación en otro con menos
apariciones de la incógnita: `U * W + V * W` pasa a ser `(U + V) * W` cuando
`W` contiene la incógnita y `U` y `V` no. Cada regla es un par de patrones y
una condición sobre qué contiene la incógnita. Escritas como cláusulas, las
reglas repiten la incógnita como argumento en cada condición; escritas como
datos, se leen como en un libro de álgebra. `reescribir.pl` define la
notación `Izq ~> Der si Condicion`, donde `con(T)` exige que `T` contenga la
incógnita y `libre(T)` que no, y el predicado que la convierte en una
cláusula de `regla/3`, con la incógnita como primer argumento:

<!-- ejemplo: capitulo-44/reescribir.pl predicado: expandir_regla/2 condicion/3 -->
```prolog
%!  expandir_regla(+Regla, -Clausula) is semidet.
%
%   Clausula es la cláusula de regla/3 que corresponde a la Regla, escrita
%   Izq ~> Der si Condicion o Izq ~> Der. Falla con cualquier otro término.
expandir_regla((Izq ~> Der si Condicion), (regla(X, Izq, Der) :- Cuerpo)) :-
    condicion(Condicion, X, Cuerpo).
expandir_regla((Izq ~> Der), regla(_, Izq, Der)).

%!  condicion(+Condicion, ?X, -Cuerpo) is det.
%
%   Cuerpo es la Condicion con la incógnita X agregada a con/1 y libre/1.
condicion((A, B), X, (CA, CB)) :-
    !,
    condicion(A, X, CA),
    condicion(B, X, CB).
condicion(con(T), X, con(X, T)) :-
    !.
condicion(libre(T), X, libre(X, T)) :-
    !.
condicion(Objetivo, _, Objetivo).
```

Los operadores `~>` y `si` se exportan con el módulo, como en la
[sección 25.2](../capitulo-25-modulos-y-organizacion/index.md#252-module2-y-use_module12): quien carga `reescribir.pl` puede leer las reglas.
`colectar.pl` define `term_expansion/2` con `expandir_regla/2`, y como un
gancho definido en un módulo vale solo para ese módulo
([sección 36.1](../capitulo-36-transformacion-de-programas-y-compilacion/index.md#361-term_expansion2-y-goal_expansion2-en-swi-prolog)), las reglas que siguen se cargan como
cláusulas y el resto del programa no se ve afectado:

<!-- ejemplo: capitulo-44/colectar.pl fragmento: term_expansion(Regla, Clausula) :- .. (W + U) * (W - U) -->
```prolog
term_expansion(Regla, Clausula) :-
    expandir_regla(Regla, Clausula).

% regla(X, Izq, Der): las reglas de abajo, cargadas como cláusulas. Es
% multifile: otro archivo puede agregar reglas.
:- multifile regla/3.

W * W ~> W ^ 2 si con(W).
U * W + V * W ~> (U + V) * W si con(W), libre(U), libre(V).
W * U + W * V ~> W * (U + V) si con(W), libre(U), libre(V).
U * W - V * W ~> (U - V) * W si con(W), libre(U), libre(V).
U * W + W ~> (U + 1) * W si con(W), libre(U).
W + W ~> 2 * W si con(W).
(W + U) * (W - U) ~> W ^ 2 - U * U si con(W), libre(U).
```

```prolog
?- listing(colectar:regla(_, _ * _, _)).
:- multifile regla/3.

regla(A, W*W, W^2) :-
    con(A, W).
regla(A, (W+U)*(W-U), W^2-U*U) :-
    con(A, W),
    libre(A, U).

true.
```

La cabeza de cada cláusula es el patrón de la regla, y la indexación elige
las reglas por su primer argumento distinto. `regla/3` es `multifile` para
que otro archivo agregue reglas sin modificar este. Una regla se aplica a
un subtérmino cualquiera: `reescribir/4` prueba la raíz y después cada
argumento, con el recorrido del [Patrón 43](../patrones.md#43-recorrido-generico-de-un-termino):

<!-- ejemplo: capitulo-44/reescribir.pl predicado: reescribir/4 -->
```prolog
%!  reescribir(:Regla, +X:atom, +E0, -E) is nondet.
%
%   E es E0 con un subtérmino reescrito por call(Regla, X, S0, S): primero
%   la raíz, después cada argumento de izquierda a derecha. Hay una
%   respuesta por cada subtérmino y cada regla que se aplica.
reescribir(Regla, X, E0, E) :-
    call(Regla, X, E0, E).
reescribir(Regla, X, E0, E) :-
    compound(E0),
    compound_name_arguments(E0, Nombre, Args0),
    append(Antes, [A0|Despues], Args0),
    reescribir(Regla, X, A0, A),
    append(Antes, [A|Despues], Args),
    compound_name_arguments(E, Nombre, Args).
```

Una regla puede aplicarse y no reducir nada: `U * W + V * W` con `W` sin la
incógnita, o una regla mal escrita que la aumenta. `colectar/3` acepta la
primera reescritura que reduce la cantidad de apariciones, y es esa
condición la que garantiza que la colección termina: la cantidad es un
número natural que baja en cada paso. El despachador aísla si queda una
aparición, y si no, colecta y vuelve a empezar:

<!-- ejemplo: capitulo-44/colectar.pl predicado: colectar/3 resolver_/3 -->
```prolog
%!  colectar(+Ecuacion0, +X:atom, -Ecuacion) is semidet.
%
%   Ecuacion resulta de reescribir un subtérmino de Ecuacion0 con la
%   primera regla de colección que reduce las apariciones de X.
colectar(Ecuacion0, X, Ecuacion) :-
    apariciones(Ecuacion0, X, N0),
    once(( reescribir(regla, X, Ecuacion0, Ecuacion),
           apariciones(Ecuacion, X, N),
           N < N0 )).

%!  resolver_(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver/3, sin verificar los argumentos ni simplificar: aísla
%   la incógnita si aparece una vez, y si no, colecta y vuelve a empezar.
resolver_(Ecuacion, X, Solucion) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, Solucion)
    ;   colectar(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ).
```

```prolog
?- colectar(2 * sin(x) + 3 * sin(x) = 1, x, E).
E = ((2+3)*sin(x)=1).

?- resolver(2 * sin(x) + 3 * sin(x) = 1, x, S).
S = (x=asin(1/5)) ;
S = (x=pi-asin(1/5)) ;
false.

?- resolver(2 * x + 3 * x = 10, x, S).
S = (x=10/5) ;
false.
```

!!! example "Patrón 56 — Medida que decrece"
    **Problema.** Un programa aplica reglas de reescritura una tras otra
    hasta que ninguna se aplica, y hay que asegurar que esa cadena termina,
    aunque las reglas sean datos que otro archivo puede ampliar.

    **Versión ingenua.** Aceptar cualquier reescritura que se aplique. Con
    una regla y su inversa, como `W * W ~> W ^ 2` y `W ^ 2 ~> W * W`, el
    término vuelve a su forma anterior y la cadena no termina (el
    ejercicio 3 lo muestra).

    **Patrón.** Una medida que asigna un número natural a cada término, y
    cada paso se acepta solo si la reduce: `colectar/3` compara las
    apariciones de la incógnita antes y después, y descarta la reescritura
    que no las baja. Como no hay una cadena infinita de naturales
    decrecientes, la cadena de reescrituras termina, cualquiera que sea el
    conjunto de reglas. Cuando un método no puede bajar la primera medida
    usa una segunda, sin aumentar la primera: la atracción de la
    [sección 44.4](#444-version-3-la-atraccion) baja la distancia entre las
    apariciones.

    **Cuándo no usarlo.** Cuando el paso necesario aumenta toda medida
    sencilla, como distribuir un producto: entonces conviene un cálculo
    recursivo sobre la estructura del término, como la forma normal de la
    [sección 44.5](forma-normal.md#445-version-4-la-forma-normal-de-un-polinomio). Y
    cuando el proceso es numérico, como el método de Newton de la
    [sección 44.6](newton.md#446-version-5-el-metodo-de-newton-y-la-comprobacion):
    ahí no hay un natural que baje, y lo que asegura el final es una cota
    de pasos y una tolerancia.

Hay ecuaciones en las que ninguna regla de colección se aplica, aunque la
incógnita aparezca solo dos veces:

```prolog
?- resolver(log(x + 1) + log(x - 1) = 3, x, S).
false.
```

Las dos apariciones están en logaritmos distintos, y ningún patrón
de colección abarca los dos.

## 44.4 Versión 3: la atracción

La **atracción** no reduce las apariciones: las acerca. `log(U) + log(V)`
pasa a ser `log(U * V)`, y las dos apariciones quedan bajo un mismo producto,
donde una regla de colección puede alcanzarlas. La medida que cada paso debe
reducir es la **distancia**: la suma de las profundidades de las apariciones,
medidas desde el menor subtérmino que las contiene a todas. Ese subtérmino
está en el prefijo común de sus posiciones:

<!-- ejemplo: capitulo-44/atraer.pl predicado: distancia/3 prefijo_comun/3 profundidad_bajo/4 -->
```prolog
%!  distancia(+E, +X:atom, -D:integer) is semidet.
%
%   D es la suma de las profundidades de las apariciones de X en E,
%   medidas desde el menor subtérmino que las contiene a todas. Falla si
%   X no aparece en E.
distancia(E, X, D) :-
    findall(P, posicion(X, E, P), [P1|Ps]),
    foldl(prefijo_comun, Ps, P1, Comun),
    length(Comun, L),
    foldl(profundidad_bajo(L), [P1|Ps], 0, D).

%!  prefijo_comun(+P:list, +Q:list, -R:list) is det.
%
%   R es el prefijo más largo común a P y Q.
prefijo_comun([A|P], [B|Q], R) :-
    A == B,
    !,
    R = [A|R1],
    prefijo_comun(P, Q, R1).
prefijo_comun(_, _, []).

%!  profundidad_bajo(+L:integer, +P:list, +D0:integer, -D:integer) is det.
%
%   D es D0 más la longitud de P menos L.
profundidad_bajo(L, P, D0, D) :-
    length(P, N),
    D is D0 + N - L.
```

```prolog
?- distancia(log(x + 1) + log(x - 1) = 3, x, D).
D = 6.

?- distancia(log((x + 1) * (x - 1)) = 3, x, D).
D = 4.
```

Son las cifras de la descripción de PRESS de Sterling, Bundy, Byrd, O'Keefe
y Silver (1982), que mide la distancia en arcos del árbol de la expresión:
seis entre las dos apariciones de `log(x + 1) + log(x - 1)` y cuatro
después de la atracción.

Las reglas de atracción usan la misma notación, cargadas en `atraer.pl`; el
despachador prueba aislar, colectar y atraer, en ese orden:

<!-- ejemplo: capitulo-44/atraer.pl fragmento: log(U) + log(V) .. A ^ U * A ^ V -->
```prolog
log(U) + log(V) ~> log(U * V) si con(U), con(V).
exp(U) * exp(V) ~> exp(U + V) si con(U), con(V).
A ^ U * A ^ V ~> A ^ (U + V) si libre(A), con(U), con(V).
```

<!-- ejemplo: capitulo-44/atraer.pl predicado: atraer/3 resolver_/3 -->
```prolog
%!  atraer(+Ecuacion0, +X:atom, -Ecuacion) is semidet.
%
%   Ecuacion resulta de reescribir un subtérmino de Ecuacion0 con la
%   primera regla de atracción que reduce la distancia entre las
%   apariciones de X.
atraer(Ecuacion0, X, Ecuacion) :-
    distancia(Ecuacion0, X, D0),
    once(( reescribir(regla, X, Ecuacion0, Ecuacion),
           distancia(Ecuacion, X, D),
           D < D0 )).

%!  resolver_(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver/3, sin verificar los argumentos ni simplificar: aísla,
%   colecta o atrae, en ese orden, y después de colectar o de atraer
%   vuelve a empezar.
resolver_(Ecuacion, X, Solucion) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, Solucion)
    ;   colectar(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ;   atraer(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ).
```

```prolog
?- atraer(log(x + 1) + log(x - 1) = 3, x, E).
E = (log((x+1)*(x-1))=3).

?- resolver(log(x + 1) + log(x - 1) = 3, x, S).
S = (x=sqrt(exp(3)+1)) ;
S = (x= -sqrt(exp(3)+1)) ;
false.
```

Después de la atracción, la regla `(W + U) * (W - U) ~> W ^ 2 - U * U` de la
colección deja una sola aparición, `log(x ^ 2 - 1 * 1) = 3`, y el
aislamiento termina. La cadena termina por las dos medidas juntas: la
colección baja las apariciones, y la atracción baja la distancia sin
aumentar las apariciones.

!!! question "Actividad"
    Predecir, antes de ejecutarlo, qué hace `resolver/3` de `atraer.pl` con
    `exp(x) * exp(x + 2) = 5`: qué regla se aplica primero, qué ecuación
    queda y si alguna regla de colección puede seguir desde ahí. Comprobarlo
    con `atraer/3` y `colectar/3` paso por paso.

La segunda solución, $-\sqrt{e^3 + 1}$, no cumple la ecuación original: el
logaritmo de $x - 1$ no tiene valor real para un $x$ negativo. Los axiomas
conservan las soluciones reales pero pueden agregar otras, porque
`log(U) + log(V) = log(U * V)` vale solo si U y V son positivos. La
versión 5 comprueba cada solución. Queda además lo que la atracción no
alcanza:

```prolog
?- resolver(2 ^ x * 2 ^ (x + 1) = 32, x, S).
false.

?- resolver(x ^ 2 - 3 * x + 2 = 0, x, S).
false.
```

La primera se atrae en `2 ^ (x + (x + 1)) = 32`, pero `x + (x + 1)` no
coincide con ningún patrón de colección, que no conocen la asociatividad.
La segunda es un polinomio: `x ^ 2` y `3 * x` no tienen una forma común que
una regla pueda colectar.

El capítulo continúa en la página
[La forma normal de un polinomio](forma-normal.md#445-version-4-la-forma-normal-de-un-polinomio),
con la versión 4 del programa, que resuelve la segunda ecuación y, a
través de la colección general, la primera.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos. Los
ejercicios que extienden el programa lo hacen desde un archivo propio, con
las cláusulas `multifile` de `axioma/3` y `regla/3`, o con un predicado que
prueba su método y usa `resolver/3` si no se aplica.

1. ★ **(1)** Con `aislar.pl` cargado, predecir la posición de `x`, la
   secuencia de axiomas y las respuestas de `resolver/3` para cada ecuación,
   y comprobarlas: `3 - x = 1` · `cos(2 * x) = 0` · `x ^ 3 = 8` ·
   `x * (x + 1) = 2` · `x / 2 = 5`.
2. **(1)** Agregar a `axioma/3` los axiomas del cociente, uno por argumento,
   y resolver `x / 2 = 5` y `12 / x = 4`. ¿Qué condición necesita el axioma
   del divisor, y qué ecuación la hace necesaria?
3. ★ **(2)** Agregar a las reglas de colección `W ^ 2 ~> W * W si con(W)`.
   Predecir qué hace `resolver/3` de `colectar.pl` con `x * x + x = 6`, y
   explicar por qué la regla nueva nunca se acepta. Escribir después
   `colectar_sin_medida/3`, igual a `colectar/3` sin comparar las
   apariciones, y el despachador que la usa, y mostrar con
   `call_with_inference_limit/3` que no termina.
4. **(2)** Agregar a la colección las reglas que suman exponentes de una
   misma base, `W ^ M * W ^ N` y `W ^ N * W` (en los dos órdenes), y la que
   colecta `W + U * W`. Resolver con `colectar.pl` `sin(x) ^ 2 * sin(x) =
   0.125`, `x ^ 2 * x ^ 3 = 32` y `x + 2 * x = 6`.

## Referencias

- Leon Sterling y Ehud Shapiro, *The Art of Prolog: Advanced Programming
  Techniques*, 2.ª edición, MIT Press, 1994 — «An Equation Solver».
  1.ª edición (1986) en [préstamo en el Internet Archive](https://archive.org/details/artofprologadvan00ster).
  Esta página toma de allí la organización del programa: los métodos
  probados en orden, la posición de la incógnita como lista de números de
  argumento y los axiomas de aislamiento.
- Alan Bundy y Bob Welham, «Using meta-level inference for selective
  application of multiple rewrite rule sets in algebraic manipulation»,
  *Artificial Intelligence* 16, 1981, pp. 189–212.
  [Página de la editorial](https://doi.org/10.1016/0004-3702%2881%2990010-2).
  Describe PRESS; de allí vienen la colección y la atracción, y la idea de
  que cada reescritura reduzca una medida.
- Leon Sterling, Alan Bundy, Lawrence Byrd, Richard O'Keefe y Bernard
  Silver, «Solving symbolic equations with PRESS», en *Computer Algebra
  (EUROCAM '82)*, Lecture Notes in Computer Science 144, Springer, 1982,
  pp. 109–116. [Copia de acceso abierto](https://era.ed.ac.uk/handle/1842/4475).
  Es la descripción de PRESS que Sterling y Shapiro adaptan: los seis
  métodos probados en orden y reiniciados después de cada transformación,
  la colección, la atracción con la distancia medida en arcos del árbol
  (seis antes y cuatro después en `log(x + 1) + log(x - 1)`), la ecuación
  `log(x + 1) + log(x - 1) = 3` resuelta por atracción, colección y
  aislamiento, y el descarte de las raíces espurias.
