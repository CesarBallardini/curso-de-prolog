# Capítulo 66 — Proyecto: evidencia y árboles de decisión

El sistema experto que identifica animales, escrito como datos en el
[capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md) y
explicado por un metaintérprete en el
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md),
razona con certezas: una observación está o no está en la lista, y una
regla que se cumple prueba su conclusión sin reservas. Dos limitaciones
quedan a la vista cuando se lo usa como se usaría un sistema de
diagnóstico. La primera es que las observaciones reales son inciertas y
las reglas también: unas manchas vistas al atardecer no son tan seguras
como las de una fotografía, y un mamífero que come carne es carnívoro en la
mayoría de los casos, no en todos. La segunda es el costo de la consulta:
el encadenamiento hacia atrás busca, retrocede y, al retroceder, hace
preguntas que no pueden cambiar el resultado.

Este capítulo resuelve las dos con un programa que crece en cinco
versiones. La primera agrega a cada regla una **fuerza** y a cada
observación un **grado**, y calcula el grado de cada conclusión
combinando los números con uno de tres métodos. La segunda usa dos de esos
métodos como **cotas** del grado verdadero y mide cómo falla cada uno. La
tercera **colapsa** las reglas: despliega las conclusiones intermedias
hasta que cada hipótesis queda definida solo por preguntas. La cuarta
construye con las reglas colapsadas un **árbol de preguntas** y compara
tres criterios para elegir la pregunta de cada nodo. La quinta **compila**
el árbol en cláusulas al cargar el archivo y lo consulta con las
respuestas de una lista o del usuario. La página
[Cinco ampliaciones](ampliaciones.md) trata después lo que las fuentes
cubren y las versiones dejan afuera: la regla de Bayes, la conjunción de
entropía máxima, la evidencia en contra con los factores de certeza con
signo, el aprendizaje del árbol a partir de ejemplos con ID3, y el
reticulado que comparte los subárboles repetidos. El proyecto completo
carga dos módulos:

<!-- ejemplo: capitulo-66/proyecto.pl archivo -->
```prolog
:- use_module(cotas).
:- use_module(compilado).
```

```prolog
?- estimaciones([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8, manchas_oscuras-0.6, rayas_negras-0.3], E).
E = [guepardo-e(0.0, 0.1851, 0.6), tigre-e(0.0, 0.098, 0.3)].

?- caso(3, Os), identificar_compilado(Os, H).
Os = [tiene_plumas, no_vuela, peso(90)],
H = avestruz.
```

La primera consulta describe un animal visto con poca luz: pelo casi
seguro, manchas dudosas, rayas poco probables. El grado de guepardo con el
método independiente es 0,1851, el de tigre 0,098; pero las cotas dicen
que el grado de guepardo puede estar en cualquier punto entre 0 y 0,6, y
el de tigre entre 0 y 0,3, así que el orden entre los dos depende de una
suposición que el programa no puede comprobar. La segunda consulta
identifica el avestruz del caso 3 recorriendo un árbol compilado, sin
buscar reglas; `estimaciones/2` está en `cotas.pl` e
`identificar_compilado/2`, en `compilado.pl`.

El proyecto parte del libro de Neil C. Rowe *Artificial Intelligence
through Prolog* (Prentice Hall, 1988), que el autor publica completo en
[su sitio](https://faculty.nps.edu/ncrowe/book/book.html). Su capítulo
«Representing uncertainty in rule-based systems» da las probabilidades en
las reglas y en los hechos, la combinación de la conjunción y de la
disyunción suponiendo independencia, las fórmulas conservadora y liberal
con su justificación por diagramas de Venn, el tratamiento de la negación
como complemento y los criterios que debe cumplir una fórmula de
combinación. El apartado «Decision lattices: a compilation of a rule-based
system» del capítulo sobre el control de los sistemas de reglas da el
colapso de las reglas y la elección de la pregunta que mejor reparte las
reglas restantes. Los factores de certeza de MYCIN, tal como los
implementa el *shell* Clam de Dennis Merritt en *Building Expert Systems in
Prolog*, y el *shell* CONMAN de Covington, Nute y Vellino en *Prolog
Programming in Depth*, con la crítica que ese libro hace de los números de
confianza, dan la comparación con la práctica de los sistemas expertos. La
lista completa, con lo que se toma de cada fuente, está en las
[Referencias](#referencias).

El capítulo no copia el sistema experto: lo carga del
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md),
con sus reglas `regla/2`, sus hipótesis, sus casos, `observable/1` y el
intérprete `demostrar/4`. Retoma también el despliegue y la evaluación
parcial del
[capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md),
y la tabulación del [capítulo 39](../capitulo-39-tabulacion/index.md) en un
ejercicio. Los archivos de las cinco versiones son módulos que cargan el
sistema experto de otro capítulo, y se ejecutan en una instalación local,
no en SWISH; tres de las ampliaciones no cargan nada y se ejecutan en
SWISH.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- agregar grados a las reglas y a las observaciones de un sistema de
  reglas sin cambiar las reglas, y calcular el grado de una conclusión;
- combinar grados con los métodos independiente, conservador y liberal,
  y explicar qué supone cada uno sobre la relación entre las evidencias;
- usar los métodos conservador y liberal como cotas, y reconocer cuándo el
  orden entre dos hipótesis depende del método;
- colapsar una base de reglas en reglas sobre preguntas, y comprobar que
  prueban lo mismo;
- construir un árbol de preguntas con una estrategia elegida, medirlo y
  comprobarlo contra el sistema original sobre todos los casos posibles;
- compilar el árbol en cláusulas al cargarlo y consultarlo con respuestas
  de una lista o del usuario;
- obtener una probabilidad con la regla de Bayes, combinar evidencia a
  favor y en contra, aprender un árbol de ejemplos con ID3, y guardar un
  árbol como reticulado.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:20 h**.
    Resolver los 5 ejercicios marcados con ★: **1:35 h**.
    Resolver los 14 ejercicios del final: **4:15 h**.

## 66.1 El problema

`identificar/2` del
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica)
recibe una lista de observaciones y da cada hipótesis que se prueba con
ellas. La respuesta es de todo o nada: con las cuatro observaciones del
caso 1 el animal es un guepardo, y con tres de ellas no es nada.

<!-- ejemplo: capitulo-66/evidencia.pl predicado: seguras/2 -->
```prolog
%!  seguras(+Observaciones:list, -Grados:list) is det.
%
%   Grados es Observaciones con cada observación segura: el par
%   Hecho-1.0. Convierte los casos del capítulo 19.
seguras(Observaciones, Grados) :-
    maplist(segura, Observaciones, Grados).
```

```prolog
?- caso(1, Os), identificar(Os, A).
Os = [tiene_pelo, come_carne, color_leonado, manchas_oscuras],
A = guepardo ;
false.

?- identificar([tiene_pelo, come_carne, color_leonado], A).
false.
```

La segunda respuesta es correcta con el contenido del programa: sin
manchas, ninguna regla concluye guepardo. Pero quien observa un animal a
la distancia no dice «no tiene manchas»; dice que le pareció ver manchas,
con alguna seguridad. Y la regla r7, «un carnívoro leonado con manchas
oscuras es un guepardo», tampoco es segura: el leopardo cumple las tres
condiciones. Un sistema que razona con evidencias necesita números en los
dos lugares, y una manera de combinarlos.

El segundo problema es el orden de las preguntas. El
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica)
pregunta cada observación la primera vez que el intérprete la necesita, y
las hipótesis se prueban en el orden de `hipotesis/1`. Las preguntas
salen del recorrido de la búsqueda, no de una decisión sobre qué conviene
saber primero.

Los dos problemas se encuentran en un árbol de decisión que lleva números
en las hojas:

![Árbol de decisión sobre la supervivencia de los pasajeros del Titanic, con preguntas por el sexo, la edad y la cantidad de familiares a bordo](arbol-titanic.jpg)

Un árbol de decisión sobre los pasajeros del Titanic. Cada nodo interno
hace una pregunta (el sexo, la edad, `sibsp`, la cantidad de cónyuges y
hermanos a bordo), y cada hoja da una probabilidad de supervivencia y el
porcentaje de los pasajeros que llegan a ella. Imagen: Gilgoldm,
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/deed.es), vía
[Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Decision_Tree.jpg).

Rowe obtiene un árbol así de un conjunto de reglas: colapsa las
conclusiones intermedias, elige la condición que aparece en más reglas y
que las divide de manera más pareja entre el sí y el no, y
reparte las reglas según la respuesta. Con sus siete reglas colapsadas
para las conclusiones `r` a `v`, el resultado es este reticulado, que el
capítulo construye para el sistema experto de los animales en las
versiones 3 a 5:

```mermaid
flowchart TD
    n1{"a"} -- "sí" --> n2{"d"}
    n1 -- "no" --> n3{"c"}
    n2 -- "sí" --> n4{"e"}
    n2 -- "no" --> u1(["u"])
    n4 -- "sí" --> u2(["u"])
    n4 -- "no" --> r(["r"])
    n3 -- "sí" --> n5{"b"}
    n3 -- "no" --> n6{"d"}
    n5 -- "sí" --> t1(["t"])
    n5 -- "no" --> v(["v"])
    n6 -- "sí" --> t2(["t"])
    n6 -- "no" --> s(["s"])
```

## 66.2 Versión 1: probabilidades en las reglas

`evidencia.pl` deja las reglas como están y les agrega una tabla aparte:
la **fuerza** de una regla es la probabilidad de su conclusión cuando todas
sus condiciones son seguras. Las observaciones pasan a ser pares
`Hecho-Grado`; `seguras/2`, de la sección anterior, convierte los casos del
[capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md), que
son seguros, a esa forma.

<!-- ejemplo: capitulo-66/evidencia.pl predicado: fuerza/2 -->
```prolog
% fuerza(Regla, F): F es la probabilidad de la conclusión de Regla cuando
% todas sus condiciones son seguras.
fuerza(r1,  0.9).
fuerza(r2,  0.95).
fuerza(r3,  1.0).
fuerza(r4,  0.7).
fuerza(r5,  0.8).
fuerza(r6,  0.9).
fuerza(r7,  0.85).
fuerza(r8,  0.9).
fuerza(r9,  0.9).
fuerza(r10, 0.85).
fuerza(r11, 0.8).
fuerza(r12, 0.9).
```

Los números son supuestos: r1, «tiene pelo, luego es mamífero», tiene
fuerza 0,9; r4, «vuela y pone huevos, luego es ave», solo 0,7, porque
también vuelan y ponen huevos los insectos. Con la tabla aparte, las reglas
siguen siendo las del sistema original, y otra tabla de fuerzas es otro
archivo, no otra base de reglas.

Rowe distingue tres problemas. La **combinación de la conjunción**: una
regla con varias condiciones inciertas necesita un grado para todas
juntas. La **combinación de la disyunción**: varias reglas que concluyen
lo mismo son alternativas, y la evidencia de todas debe sumarse de algún
modo. Y la **fuerza de la regla**, que Rowe trata como una condición más,
oculta, unida a las otras con la misma conjunción. Hay tres métodos
clásicos, según lo que se suponga sobre la relación entre las evidencias:

| Método | $p(A \wedge B)$ | $p(A \vee B)$ | Supone |
|---|---|---|---|
| independiente | $p_A\,p_B$ | $p_A + p_B - p_A\,p_B$ | que una evidencia no cambia la probabilidad de la otra |
| conservador | $\max(0,\ p_A + p_B - 1)$ | $\max(p_A, p_B)$ | lo peor: el menor valor compatible con $p_A$ y $p_B$ |
| liberal | $\min(p_A, p_B)$ | $\min(1,\ p_A + p_B)$ | lo mejor: el mayor valor compatible con $p_A$ y $p_B$ |

<!-- ejemplo: capitulo-66/evidencia.pl predicado: y/4 o/4 combinar/4 -->
```prolog
%!  y(+Metodo, +P1:float, +P2:float, -P:float) is det.
%
%   P es el grado de la conjunción de dos hechos de grados P1 y P2, según
%   Metodo.
y(independiente, P1, P2, P) :-
    P is P1 * P2.
y(conservador, P1, P2, P) :-
    P is max(0.0, P1 + P2 - 1).
y(liberal, P1, P2, P) :-
    P is min(P1, P2).

%!  o(+Metodo, +P1:float, +P2:float, -P:float) is det.
%
%   P es el grado de la disyunción de dos hechos de grados P1 y P2, según
%   Metodo.
o(independiente, P1, P2, P) :-
    P is P1 + P2 - P1 * P2.
o(conservador, P1, P2, P) :-
    P is max(P1, P2).
o(liberal, P1, P2, P) :-
    P is min(1.0, P1 + P2).

%!  combinar(+Operacion, +Metodo, +Grados:list, -P:float) is det.
%
%   P combina Grados con Operacion, y u o, según Metodo. Las fórmulas son
%   asociativas, así que alcanza con aplicar la binaria de a una. La lista
%   vacía da el neutro: 1.0 para y, 0.0 para o.
combinar(y, Metodo, Grados, P) :-
    foldl(y(Metodo), Grados, 1.0, P).
combinar(o, Metodo, Grados, P) :-
    foldl(o(Metodo), Grados, 0.0, P).
```

Las seis fórmulas son conmutativas y asociativas, y por eso `combinar/4`
aplica la binaria de a una con `foldl/4`, empezando por el **neutro**: 1,0
para la conjunción, 0,0 para la disyunción. La prueba `asociativas` de
`evidencia.plt` lo verifica sobre una grilla de valores. Una conclusión sin
nada que la apoye queda con grado 0,0, la disyunción de ninguna evidencia.

El grado de una meta reúne todo lo que la apoya y lo combina con la
disyunción. Cada apoyo es una observación de la lista, o una regla cuya
conclusión es la meta: el grado de sus condiciones combinado, con la
conjunción, con la fuerza de la regla.

<!-- ejemplo: capitulo-66/evidencia.pl predicado: grado/4 apoyo/4 condicion/4 -->
```prolog
%!  grado(+Meta, +Observaciones:list, +Metodo, -P:float) is det.
%
%   P es el grado de Meta: la combinación con o de todo lo que la apoya,
%   redondeada a cuatro decimales. Sin nada que la apoye, P es 0.0.
grado(Meta, Observaciones, Metodo, P) :-
    findall(P1, apoyo(Meta, Observaciones, Metodo, P1), Ps),
    combinar(o, Metodo, Ps, P0),
    P is round(P0 * 10000) / 10000.0.

%!  apoyo(+Meta, +Observaciones:list, +Metodo, -P:float) is nondet.
%
%   P es lo que aporta a Meta una observación, o una regla que la concluye
%   y cuyas condiciones tienen algún grado: la fuerza de la regla combinada
%   con y con el grado de las condiciones.
apoyo(Meta, Observaciones, _, P) :-
    observable(Meta),
    member(Meta-P, Observaciones).
apoyo(Meta, Observaciones, Metodo, P) :-
    regla(Regla, si Condiciones entonces Meta),
    condicion(Condiciones, Observaciones, Metodo, PC),
    fuerza(Regla, F),
    y(Metodo, F, PC, P).

%!  condicion(+Condicion, +Observaciones:list, +Metodo, -P:float) is nondet.
%
%   P es el grado de Condicion: una conjunción, una comparación, que vale
%   1.0 si se cumple, o una meta. Una meta con variables da una respuesta
%   por cada observación que la liga.
condicion(A y B, Observaciones, Metodo, P) :-
    condicion(A, Observaciones, Metodo, PA),
    condicion(B, Observaciones, Metodo, PB),
    y(Metodo, PA, PB, P).
condicion(Comparacion, _, _, 1.0) :-
    comparacion(Comparacion),
    call(Comparacion).
condicion(Meta, Observaciones, _, P) :-
    observable(Meta),
    member(Meta-P, Observaciones).
condicion(Meta, Observaciones, Metodo, P) :-
    Meta \= (_ y _),
    \+ comparacion(Meta),
    \+ observable(Meta),
    grado(Meta, Observaciones, Metodo, P).
```

`condicion/4` recorre las condiciones con la forma que tienen en las
reglas: una conjunción con `y`, una comparación, que vale 1,0 cuando se
cumple y no aporta nada cuando no, o una meta. Una observación con
variables, como `peso(P)`, da una respuesta por cada observación que la
liga; una conclusión intermedia, como `mamifero`, se evalúa con `grado/4`,
así que la disyunción de sus reglas se hace antes de usarla. El redondeo a
cuatro decimales es para leer los resultados; la
[sección 66.3](#663-version-2-cotas-conservadora-y-liberal) muestra que no
cambia el orden de los métodos.

```prolog
?- grado(mamifero, [tiene_pelo-0.9], independiente, P).
P = 0.81.

?- caso(1, Os), seguras(Os, Gs), grado(guepardo, Gs, independiente, P).
Os = [tiene_pelo, come_carne, color_leonado, manchas_oscuras],
Gs = [tiene_pelo-1.0, come_carne-1.0, color_leonado-1.0, manchas_oscuras-1.0],
P = 0.612.
```

Con las observaciones seguras, el grado de guepardo es el producto de las
fuerzas de la cadena r1, r5, r7: $0{,}9 \cdot 0{,}8 \cdot 0{,}85 = 0{,}612$.
La certeza del sistema original es el caso particular en que todas las
fuerzas valen 1. Dos reglas para la misma conclusión se suman:

```prolog
?- grado(mamifero, [tiene_pelo-0.6, da_leche-0.6], independiente, P).
P = 0.8022.
```

r1 aporta $0{,}9 \cdot 0{,}6 = 0{,}54$ y r2 aporta $0{,}95 \cdot 0{,}6 =
0{,}57$; la disyunción independiente da
$1 - (1 - 0{,}54)(1 - 0{,}57) = 0{,}8022$. `ranking/3` ordena las hipótesis
con grado:

<!-- ejemplo: capitulo-66/evidencia.pl predicado: ranking/3 -->
```prolog
%!  ranking(+Observaciones:list, +Metodo, -Ranking:list) is det.
%
%   Ranking tiene un par P-Hipotesis por cada hipótesis de grado mayor que
%   0, de mayor a menor grado.
ranking(Observaciones, Metodo, Ranking) :-
    findall(P-H,
            ( hipotesis(H),
              grado(H, Observaciones, Metodo, P),
              P > 0 ),
            Pares),
    sort(1, @>=, Pares, Ranking).
```

```prolog
?- ranking([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8, manchas_oscuras-0.6, rayas_negras-0.3], independiente, R).
R = [0.1851-guepardo, 0.098-tigre].
```

!!! question "Actividad"
    Predecir, antes de ejecutar la consulta, el grado de `carnivoro` con las
    observaciones `[tiene_pelo-0.8, come_carne-0.5]` y el método
    independiente: primero el de `mamifero`, después el de la regla r5.
    Comprobarlo con `grado/4` y repetir con los métodos conservador y
    liberal.

## 66.3 Versión 2: cotas conservadora y liberal

El método independiente da un número, y el número parece más de lo que es.
Las dos observaciones del ejemplo anterior, pelo y leche con grado 0,6,
vienen de la misma mirada al mismo animal: si el observador se equivocó
con una, probablemente se equivocó con la otra. No son independientes, y
sumarlas como si lo fueran cuenta dos veces la misma evidencia. Rowe
describe los otros dos métodos como los extremos: el **conservador** da el
menor grado compatible con los grados de las partes, sean cuales sean sus
relaciones, y el **liberal**, el mayor. `cotas.pl` los usa como las cotas
de un intervalo.

<!-- ejemplo: capitulo-66/cotas.pl predicado: intervalo/4 estimaciones/2 -->
```prolog
%!  intervalo(+Meta, +Observaciones:list, -Inf:float, -Sup:float) is det.
%
%   Inf y Sup son los grados de Meta con los métodos conservador y liberal:
%   las cotas de lo que puede valer su grado.
intervalo(Meta, Observaciones, Inf, Sup) :-
    grado(Meta, Observaciones, conservador, Inf),
    grado(Meta, Observaciones, liberal, Sup).

%!  estimaciones(+Observaciones:list, -Filas:list) is det.
%
%   Filas tiene un término H-e(Inf, P, Sup) por cada hipótesis H con cota
%   superior mayor que 0: sus dos cotas y, entre ellas, su grado con el
%   método independiente. Están de mayor a menor P.
estimaciones(Observaciones, Filas) :-
    findall(P-(H-e(Inf, P, Sup)),
            ( hipotesis(H),
              intervalo(H, Observaciones, Inf, Sup),
              Sup > 0,
              grado(H, Observaciones, independiente, P) ),
            Pares),
    sort(1, @>=, Pares, Ordenados),
    pairs_values(Ordenados, Filas).
```

```prolog
?- intervalo(mamifero, [tiene_pelo-0.6, da_leche-0.6], I, S).
I = 0.55,
S = 1.0.
```

La disyunción conservadora se queda con la mejor evidencia, 0,57 de r2,
reducida por la conjunción conservadora con la fuerza: $0{,}95 + 0{,}6 - 1
= 0{,}55$. La liberal suma y llega al tope. El 0,8022 de la independencia
es uno entre muchos valores posibles; decir cuál es el correcto exige
saber cómo se relacionan las dos observaciones, y el programa no tiene ese dato.

Las tres conjunciones y las tres disyunciones están ordenadas:
$\max(0, a + b - 1) \le ab \le \min(a, b)$ y
$\max(a, b) \le a + b - ab \le \min(1, a + b)$ para grados entre 0 y 1. Como
todas son crecientes en sus dos argumentos, el orden se conserva al
componerlas a lo largo de las reglas: la estimación independiente de
cualquier conclusión queda siempre entre las dos cotas. La prueba
`entre_cotas` de `cotas.plt` lo verifica para todas las conclusiones con
tres grados de observación, y `estimaciones/2` muestra las tres cifras
juntas, como en la introducción.

Las cadenas de reglas muestran la segunda falla. Con las cuatro
observaciones del guepardo en 0,7:

```prolog
?- member(M, [independiente, conservador, liberal]), grado(guepardo, [tiene_pelo-0.7, come_carne-0.7, color_leonado-0.7, manchas_oscuras-0.7], M, P).
M = independiente,
P = 0.1469 ;
M = conservador,
P = 0.0 ;
M = liberal,
P = 0.7.
```

La conjunción independiente multiplica: cada regla de la cadena y cada
condición agregan un factor menor que 1, y una conclusión que está tres
reglas más arriba que las observaciones queda con un grado bajo aunque
toda la evidencia la apoye. La conservadora resta: cada condición de grado
$g$ quita $1 - g$, y con cuatro condiciones de 0,7 el grado llega a 0. La
liberal toma el mínimo y no ve la longitud de la cadena: cuatro
observaciones de 0,7 valen lo mismo que una. El
[ejercicio 2](#ejercicios) tabula las tres para varios grados.

Que el intervalo sea ancho no es un defecto del programa, es lo que dicen
los datos. Lo que sí se puede decir con seguridad es cuándo una hipótesis
supera a otra con cualquier método: cuando la cota inferior de la primera
pasa la superior de la segunda.

<!-- ejemplo: capitulo-66/cotas.pl predicado: domina/3 -->
```prolog
%!  domina(+Observaciones:list, ?H1, ?H2) is nondet.
%
%   La hipótesis H1 tiene más grado que H2 con cualquier método: la cota
%   inferior de H1 es mayor que la cota superior de H2.
domina(Observaciones, H1, H2) :-
    hipotesis(H1),
    intervalo(H1, Observaciones, Inf1, _),
    Inf1 > 0,
    hipotesis(H2),
    H2 \== H1,
    intervalo(H2, Observaciones, _, Sup2),
    Inf1 > Sup2.
```

```prolog
?- domina([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8, manchas_oscuras-0.6, rayas_negras-0.3], H1, H2).
false.

?- caso(2, Os), seguras(Os, Gs), domina(Gs, cebra, H).
Os = [da_leche, tiene_cascos, rayas_negras],
Gs = [da_leche-1.0, tiene_cascos-1.0, rayas_negras-1.0],
H = guepardo ;
Os = [da_leche, tiene_cascos, rayas_negras],
Gs = [da_leche-1.0, tiene_cascos-1.0, rayas_negras-1.0],
H = tigre ;
Os = [da_leche, tiene_cascos, rayas_negras],
Gs = [da_leche-1.0, tiene_cascos-1.0, rayas_negras-1.0],
H = jirafa ;
Os = [da_leche, tiene_cascos, rayas_negras],
Gs = [da_leche-1.0, tiene_cascos-1.0, rayas_negras-1.0],
H = pinguino ;
Os = [da_leche, tiene_cascos, rayas_negras],
Gs = [da_leche-1.0, tiene_cascos-1.0, rayas_negras-1.0],
H = avestruz.
```

Con el animal del atardecer, la ventaja de guepardo sobre tigre depende
del método; con observaciones seguras, la cebra domina a todas las demás.

Los *shells* de sistemas expertos no eligen uno de los tres métodos: los
mezclan. Clam, el *shell* con factores de certeza de Merritt, que sigue el
modelo de Shortliffe y Buchanan para MYCIN, toma el mínimo para la conjunción de las premisas y acumula las
reglas con la fórmula de la independencia; CONMAN, el de Covington, Nute y
Vellino, toma el mínimo para la conjunción y el máximo para la
disyunción, que es la mejor regla sola. El [ejercicio 3](#ejercicios) los
agrega como métodos nuevos, con cláusulas `multifile` de `metodo/1`, `y/4`
y `o/4`. Rowe propone cuatro condiciones para aceptar una fórmula propia:
que no salte ante cambios pequeños de los grados, que quede entre las
cotas, y que sea conmutativa y asociativa. Covington y sus coautores
cierran su capítulo con tres objeciones a todos estos números: los dan
los expertos a pedido, no salen de estadísticas; una base grande exige
reajustarlos cada vez que se agrega una regla; y no representan
excepciones como «las aves vuelan, salvo los pingüinos», que el
[capítulo 65](../capitulo-65-proyecto-razonamiento-rebatible/index.md)
trata con reglas rebatibles y sin números.

!!! question "Actividad"
    Predecir si `domina/3` encuentra algún par con las observaciones
    `[tiene_plumas-0.9, no_vuela-0.9, nada-0.9, peso(90)-0.9]`, sabiendo que
    esas observaciones prueban tanto pingüino como avestruz. Comprobarlo, y
    mostrar los intervalos de las dos hipótesis con `intervalo/4`.

## 66.4 Versión 3: colapsar las reglas

La segunda mitad del capítulo vuelve a las observaciones seguras y se
ocupa de cuáles preguntar. Para elegir la primera pregunta hay que ver,
de cada hipótesis, qué respuestas la prueban. En la base de reglas eso
no está a la vista: guepardo depende de carnívoro, que depende de
mamífero, que depende de pelo o de leche. Rowe llama **colapsar** las
reglas a reemplazar cada conclusión intermedia por el cuerpo de una de sus
reglas, hasta que solo quedan observaciones; una intermedia con dos
reglas duplica la regla que la usa. Es el **despliegue** de la
[sección 35.3](../capitulo-35-transformacion-de-programas-y-compilacion/index.md#353-desplegar-y-plegar),
aplicado a las reglas como datos.

<!-- ejemplo: capitulo-66/colapsar.pl predicado: colapsada/2 desplegar/2 agrupar/2 -->
```prolog
%!  colapsada(?Hipotesis, -Preguntas:list) is nondet.
%
%   Una regla colapsada prueba Hipotesis cuando se cumplen todas las
%   Preguntas. Una respuesta por cada combinación de reglas que prueba
%   Hipotesis.
colapsada(Hipotesis, Preguntas) :-
    hipotesis(Hipotesis),
    regla(_, si Condiciones entonces Hipotesis),
    desplegar(Condiciones, Literales),
    agrupar(Literales, Preguntas).

%!  desplegar(+Condicion, -Literales:list) is nondet.
%
%   Literales son las observaciones y comparaciones que prueban Condicion,
%   con cada conclusión intermedia reemplazada por el cuerpo de una de sus
%   reglas.
desplegar(A y B, Literales) :-
    desplegar(A, LA),
    desplegar(B, LB),
    append(LA, LB, Literales).
desplegar(Comparacion, [Comparacion]) :-
    comparacion(Comparacion).
desplegar(Meta, [Meta]) :-
    observable(Meta).
desplegar(Meta, Literales) :-
    regla(_, si Condiciones entonces Meta),
    desplegar(Condiciones, Literales).

%!  agrupar(+Literales:list, -Preguntas:list) is det.
%
%   Preguntas es Literales con cada comparación unida con y a la
%   observación que la precede: peso(P) y P > 50 es una sola pregunta.
agrupar([], []).
agrupar([A|Resto], Preguntas) :-
    (   Resto = [C|Resto1],
        comparacion(C)
    ->  agrupar([A y C|Resto1], Preguntas)
    ;   Preguntas = [A|Preguntas1],
        agrupar(Resto, Preguntas1)
    ).
```

`agrupar/2` resuelve el único caso que no es una observación sola: en la
regla r12, `peso(P) y P > 50`, la comparación no se puede preguntar sin el
peso. Unida a la observación que liga su variable, forma una sola
pregunta.

```prolog
?- colapsada(guepardo, Ps).
Ps = [tiene_pelo, come_carne, color_leonado, manchas_oscuras] ;
Ps = [da_leche, come_carne, color_leonado, manchas_oscuras] ;
false.

?- aggregate_all(count, colapsada(_, _), N).
N = 12.

?- preguntas(Ps), length(Ps, N).
Ps = [tiene_pelo, come_carne, color_leonado, manchas_oscuras, da_leche, rayas_negras, tiene_cascos, cuello_largo, tiene_plumas|...],
N = 14.
```

Cada una de las seis hipótesis usa una de las dos conclusiones intermedias
con dos reglas, mamífero o ave, y queda con dos reglas colapsadas; en
total doce reglas sobre catorce preguntas distintas. `preguntas/1`
compara las preguntas con `=@=`, porque `peso(P) y P > 50` aparece en dos
reglas con variables distintas.

<!-- ejemplo: capitulo-66/colapsar.pl predicado: se_cumple/2 -->
```prolog
%!  se_cumple(+Pregunta, +Observaciones:list) is semidet.
%
%   Pregunta se prueba con Observaciones, con demostrar/4 del capítulo 33.
%   No liga las variables de Pregunta: la misma pregunta sirve para otras
%   observaciones.
se_cumple(Pregunta, Observaciones) :-
    \+ \+ demostrar(Pregunta, lista(Observaciones), [], _).
```

`se_cumple/2` responde una pregunta con una lista de observaciones usando
`demostrar/4` del
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica),
dentro de una doble negación para no ligar las variables de la pregunta:
el mismo término `peso(P) y P > 50` sirve después para otro animal. Con
él, la prueba `equivalentes` comprueba que colapsar no cambia nada: para
cada caso y cada hipótesis, la hipótesis se prueba si y solo si alguna de
sus reglas colapsadas tiene todas sus preguntas con respuesta afirmativa.

El colapso tiene un costo que en esta base es chico: una regla con $k$
conclusiones intermedias de dos reglas cada una se convierte en $2^k$
reglas. Rowe advierte además que colapsar pierde los niveles
intermedios, que agrupan conceptos y dan dónde explicar; el árbol que
sigue decide bien, pero ya no puede responder «¿por qué?» con una regla.

## 66.5 Versión 4: el árbol de preguntas

La cuarta versión construye, con las reglas colapsadas, un árbol que hace
una pregunta en cada nodo y da una hipótesis, o ninguna, en cada hoja.
Compara tres estrategias para elegir la pregunta de cada nodo —el orden
del encadenamiento hacia atrás, la pregunta más frecuente y la ganancia de
información de ID3 sobre una población de prototipos— y las mide en
tamaño y en preguntas por consulta, contra el mínimo que da una búsqueda
exhaustiva. Está en la página
[El árbol de preguntas y su compilación](arbol.md#version-4-el-arbol-de-preguntas).

## 66.6 Versión 5: el árbol compilado

La quinta versión convierte el árbol en cláusulas al cargar el archivo,
con `term_expansion/2`, lo consulta con las respuestas de una lista o del
usuario, y lo compara con el encadenamiento hacia atrás del
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) en
preguntas y en inferencias. Está en la página
[El árbol de preguntas y su compilación](arbol.md#version-5-el-arbol-compilado).

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `grado/4`, `arbol/2` y `nodo/3` son `det` |
    | C2 | las reglas son las del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md), cargadas y no copiadas; las fuerzas son una tabla aparte y los métodos, cláusulas `multifile` que otro archivo puede extender |
    | C4 | `se_cumple/2` no liga las preguntas y no deja alternativas; el árbol se consulta con `->/2` |
    | C7 | 171 pruebas en catorce archivos; los tres árboles y el compilado se comparan con el sistema original sobre los 24 576 animales posibles, y la estimación independiente con las dos cotas |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

1. ★ **(1)** Predecir, con `proyecto.pl` cargado, qué responde cada
   consulta, y comprobarlo:
   `grado(ave, [tiene_plumas-0.5, vuela-0.8, pone_huevos-0.8], M, P)` con
   cada uno de los tres métodos ·
   `colapsada(pinguino, Ps).` ·
   `consulta(frecuente, [tiene_plumas, no_vuela, nada], H, Ps).`
2. ★ **(2)** Escribir `atenuacion(G, Filas)`: para mamifero, carnivoro y
   guepardo, sus grados con los tres métodos cuando las cuatro
   observaciones del caso 1 tienen grado G. Tabular G = 1,0, 0,9 y 0,7 y
   explicar, con las fórmulas, por qué cada método se comporta así con la
   longitud de la cadena.
3. ★ **(2)** Agregar los métodos `mycin` y `conman` de la
   [sección 66.3](#663-version-2-cotas-conservadora-y-liberal), con
   cláusulas `multifile` de `evidencia`, y calcular con ellos el grado de
   mamífero con pelo y leche de 0,6. Verificar que los dos quedan entre
   las cotas.
4. ★ **(2)** Rowe advierte que `\+` no sirve con evidencias: una regla
   «A y no B» falla con cualquier evidencia de B, por débil que sea.
   Escribir `y_no(Metodo, PA, PB, P)`, que usa $1 - p_B$ como grado de no
   B, calcularlo para $p_A = 0{,}9$ y $p_B = 0{,}2$ con los tres métodos, y
   explicar qué da la versión con `\+`.
5. **(1)** Una conclusión a tiene dos reglas: una da 0,6 cuando b es
   seguro, la otra da el grado de c. Con b seguro y c de 0,8, calcular el
   grado de a con los tres métodos, a mano y con `y/4` y `combinar/4`.
6. **(1)** Escribir `mas_probable(Observaciones, Metodo, H)`, la hipótesis
   de mayor grado, con su encabezado de PlDoc. Justificar los modos y la
   determinación, y decidir qué hace cuando ninguna hipótesis tiene grado.
7. **(3)** `vuela` y `no_vuela` son preguntas distintas para el árbol, que
   puede preguntar las dos. Declarar `excluyentes/2` y escribir
   `arbol_excluyentes(Estrategia, Arbol)`, que después de un sí descarta
   las reglas con la pregunta excluida. Medir el árbol `orden` y
   comprobarlo contra el sistema original sobre los animales que no
   tienen las dos observaciones.
8. ★ **(3)** Escribir `costo_minimo(C)`: la menor suma de preguntas sobre
   los doce prototipos que alcanza algún árbol, probando en cada nodo todas
   las preguntas posibles, con `:- table` para no repetir los subárboles.
   Comparar el resultado con los árboles de las tres estrategias.
9. **(2)** Suponer que de cada cien animales consultados 10 son guepardos,
   10 tigres, 5 jirafas, 15 cebras, 40 pingüinos y 20 avestruces. Escribir
   `promedio_ponderado(Arbol, P)`, la media de preguntas sobre los
   prototipos con esos pesos, y decidir qué estrategia conviene.
10. **(2)** Escribir `escribir_arbol(Archivo)`, que guarda las cláusulas
    de `nodo/3` y un `responde/2` para listas de observaciones en un
    archivo que no carga nada, y comprobar que ese archivo, cargado solo,
    identifica la cebra del caso 2.
11. **(3)** Unir las dos mitades del capítulo: escribir
    `consultar_con_grado(Arbol, Observaciones, Umbral, H, P)`, que recorre
    el árbol respondiendo que sí a las observaciones de grado al menos
    Umbral y da el grado de la hipótesis de la hoja. Aplicarlo al animal
    del atardecer con umbrales 0,5 y 0,7 y explicar el resultado.
12. **(1)** Una fuerza se puede estimar con datos: la fracción $F$ de los
    casos en que, cumplidas las condiciones, se cumplió la conclusión, con
    error estándar $\sqrt{F(1 - F)/N}$. Escribir
    `fuerza_estimada(Exitos, Total, F, Error)` y aplicarlo a 200 de 500, 7
    de 20 y 2 de 2000. Decidir en cuáles se puede confiar, con el criterio
    de Rowe: no, si el error es comparable a $F$.
13. **(2)** Merritt propone que una regla pueda tener su propio umbral,
    que reemplaza al general. Declarar `umbral_regla(Regla, U)` para c1
    (0,4) y r7 (0,5), y escribir
    `factor_con_umbrales(Meta, Observaciones, General, F)`, como
    `factor/4` de la
    [sección 66.9](ampliaciones.md#669-evidencia-a-favor-y-en-contra) con
    el umbral de cada regla. Calcularlo para el guepardo del atardecer, y
    con rayas de grado 0,5, y explicar los resultados.
14. **(2)** Agregar a los sábados de la
    [sección 66.10](ampliaciones.md#6610-aprender-el-arbol-de-ejemplos) un
    atributo `dia`, el número del ejemplo. Calcular su ganancia y su razón
    de ganancia, decidir qué atributo elige cada criterio para la raíz, y
    explicar qué ocurre al clasificar un sábado nuevo.

## Resumen

| | |
|---|---|
| **fuerza de una regla** | la probabilidad de la conclusión cuando las condiciones son seguras; se combina como una condición más |
| **grado de una observación** | la seguridad con que se observó un hecho: el par `Hecho-Grado` |
| **combinación de la conjunción y de la disyunción** | cómo se juntan los grados de las condiciones de una regla, y los de las reglas que concluyen lo mismo |
| **método independiente** | producto para la conjunción; $p_A + p_B - p_A p_B$ para la disyunción |
| **métodos conservador y liberal** | los grados menor y mayor compatibles con los de las partes; las cotas de cualquier otro método |
| **atenuación** | la pérdida de grado a lo largo de una cadena de reglas: fuerte con la independencia, total con el conservador, nula con el liberal |
| **regla colapsada** | una regla de hipótesis cuyas condiciones son solo preguntas, sin conclusiones intermedias |
| **árbol de preguntas** | una pregunta por nodo y una hipótesis, o ninguna, por hoja |
| **ganancia de información** | lo que una respuesta reduce la entropía de las hipótesis de una población |
| `fuerza/2`, `y/4`, `o/4`, `combinar/4`, `grado/4`, `ranking/3` | la evidencia combinada |
| `intervalo/4`, `estimaciones/2`, `domina/3` | las cotas y la ventaja segura |
| `colapsada/2`, `preguntas/1`, `se_cumple/2` | las reglas colapsadas |
| `arbol/2`, `consultar/4`, `medir/4`, `prototipo/2` | el árbol, su consulta y sus medidas |
| `identificar_compilado/2`, `consulta_interactiva/1`, `preguntas_encadenando/2` | el árbol compilado y la comparación con el encadenamiento |
| **regla de Bayes** | $p(A \mid B) = p(B \mid A) \, p(A) / p(B)$: una probabilidad condicional a partir de la inversa |
| **entropía máxima** | la estimación que menos información agrega; para la conjunción, el producto de la independencia |
| **factor de certeza** | un número entre $-1$ y $1$ que reúne evidencia a favor y en contra; la premisa debe llegar a un umbral |
| **razón de ganancia** | la ganancia dividida por la información del valor del atributo; corrige el sesgo hacia los atributos con muchos valores |
| **ventana** | la parte de los ejemplos de la que ID3 aprende, que crece con los que el árbol clasifica mal |
| **reticulado de decisión** | un árbol en el que los subárboles iguales se guardan una vez |
| **[Patrón 65](../patrones.md#65-una-tabla-de-valores-como-conjunto-de-nodos-compartidos)** | una tabla de valores como conjunto de nodos compartidos |
| `bayes/4`, `posterior/3`, `y_maxima_entropia/3` | la regla de Bayes, la probabilidad de cada animal, y la conjunción de entropía máxima |
| `balance/4`, `factor/4`, `cf_combinar/3` | la evidencia a favor menos la en contra, y los factores de certeza con signo |
| `id3/4`, `ventana/5`, `reticulado/3` | el árbol aprendido de ejemplos, el esquema de la ventana, y el reticulado |
| `transpose_pairs/2` | invierte cada par `Clave-Valor` y ordena por la clave nueva |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Aprender las reglas a partir de ejemplos en lugar de escribirlas | [capítulo 67](../capitulo-67-proyecto-aprender-reglas-ejemplos/index.md) |
| Ajustar números con datos, en lugar de pedirlos a un experto | [capítulo 69](../capitulo-69-proyecto-perceptron/index.md) |

## Referencias

- Neil C. Rowe, *Artificial Intelligence through Prolog*, Prentice Hall,
  1988 — el capítulo «Representing uncertainty in rule-based systems» y el
  apartado «Decision lattices: a compilation of a rule-based system» del
  capítulo sobre el control de los sistemas de reglas.
  [Edición en línea del autor](https://faculty.nps.edu/ncrowe/book/book.html).
  El capítulo toma de allí las probabilidades en las reglas y en los
  hechos, la fuerza de la regla como una condición oculta, las fórmulas
  independiente, conservadora y liberal con sus casos de uso, la negación
  como complemento, los criterios para aceptar una fórmula, la estimación
  de las fuerzas con su error estándar, y el colapso de las reglas y la
  elección de la pregunta que las reparte. La
  [página de ampliaciones](ampliaciones.md) toma además, del primero, la
  regla de Bayes con sus desigualdades de consistencia, la conjunción de
  entropía máxima y la resta de la evidencia en contra, y del segundo,
  junto con el apartado «Decision lattices» del capítulo sobre el
  control, el reticulado
  y sus ventajas y desventajas.
- Dennis Merritt, *Building Expert Systems in Prolog*, Springer, 1989 —
  «Backward Chaining with Uncertainty».
  [Edición en línea de Amzi!](https://www.amzi.com/ExpertSystemsInProlog/03backwarduncertainty.php).
  De allí vienen los factores de certeza de MYCIN, con el mínimo para las
  premisas y la acumulación de las reglas, que el ejercicio 3 compara con
  los tres métodos; la página de ampliaciones agrega los factores
  negativos, la combinación de tres casos según los signos y el umbral de
  la premisa, y el ejercicio 13, el umbral por regla de su ejercicio 3.4.
- Michael A. Covington, Donald Nute y André Vellino, *Prolog Programming in
  Depth*, Prentice Hall, 1997 — «An Expert System Shell with Uncertainty».
  [Edición en línea](https://www.covingtoninnovations.com/books/PPID.pdf).
  El capítulo toma las reglas de combinación de CONMAN y las objeciones de
  su apartado «No confidence in "confidence"».
- J. Ross Quinlan, «Induction of decision trees», *Machine Learning* 1,
  1986, pp. 81–106.
  [Página de la editorial](https://doi.org/10.1007/BF00116251).
  De allí viene la ganancia de información de la estrategia
  `informacion` (apartado «ID3»), y la presentación de ID3 como
  descendiente del *Concept Learning System*. La página de ampliaciones
  toma los catorce sábados de su tabla 1, el árbol de su figura 2, la
  ventana, el ruido con la prueba de chi-cuadrado (apartado «Noise») y la
  razón de ganancia (apartado «The selection criterion»).
- Claude E. Shannon, «A Mathematical Theory of Communication», *Bell
  System Technical Journal* 27 (3), 1948, págs. 379–423.
  [DOI 10.1002/j.1538-7305.1948.tb01338.x](https://doi.org/10.1002/j.1538-7305.1948.tb01338.x).
  La entropía que la ganancia de información de Quinlan resta antes y
  después de cada pregunta.
- Earl B. Hunt, Janet Marin y Philip J. Stone, *Experiments in Induction*,
  Academic Press, 1966. El *Concept Learning System*, que construye un
  árbol de decisión partiendo los ejemplos por un atributo en cada nodo;
  Quinlan lo cita como el origen de ID3.
- Edward H. Shortliffe y Bruce G. Buchanan, «A Model of Inexact Reasoning
  in Medicine», *Mathematical Biosciences* 23, 1975, págs. 351–379.
  [DOI 10.1016/0025-5564(75)90047-4](https://doi.org/10.1016/0025-5564(75)90047-4).
  Los factores de certeza de MYCIN que Merritt implementa en Clam y que el
  ejercicio 3 agrega como método.

El código del capítulo es propio, escrito para el curso sobre el sistema
experto del
[capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md): de
las fuentes se toman ideas, fórmulas y ejemplos, no código; las cotas
como intervalo, la comparación de estrategias con su medición y la
consulta del encadenamiento por repetición son del curso, como la
búsqueda numérica de la entropía máxima, la probabilidad de cada animal
con un error de registro, y el reticulado construido numerando los
subárboles.
