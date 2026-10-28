# Capítulo 39 — Semántica de los programas lógicos

El [capítulo 5](../capitulo-05-como-responde-prolog/index.md) describió cómo Prolog busca una respuesta, el
[capítulo 10](../capitulo-10-negacion-como-falla/index.md) qué hace `\+` y el [capítulo 13](../capitulo-13-prolog-y-la-logica/index.md) cómo se lee una cláusula como
una fórmula. Este capítulo reúne las tres cosas y las enuncia con precisión:
qué afirma un programa, qué átomos son sus consecuencias, cuándo las
encuentra la resolución, y qué significa un programa con negación, incluso
uno en el que un predicado depende de su propia negación. Es el capítulo de
teoría de la parte III, y precede a la tabulación del
[capítulo 40](../capitulo-40-tabulacion/index.md), que calcula exactamente lo que aquí se define.

Cada definición viene acompañada de un evaluador pequeño escrito en Prolog,
con sus pruebas, que trabaja sobre un programa leído como datos con
`clause/2`, como en el [capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md): uno verifica si una interpretación es
un modelo, otro calcula el modelo mínimo de abajo hacia arriba, otro da un
paso de resolución con una regla de selección elegida, otro decide si un
programa es estratificado y otro calcula la semántica bien fundada, con tres
valores de verdad. El capítulo no demuestra ningún teorema: los enuncia, y
cita dónde están las demostraciones, en *Logic, Programming and Prolog* de
Ulf Nilsson y Jan Małuszyński ([edición en línea de los autores](https://www.ida.liu.se/~ulfni53/lpp/)),
*An Introduction to Logic Programming through Prolog* de Michael Spivey
([edición del autor](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf)),
*Simply Logical* de Peter Flach
([edición en línea](https://book.simply-logical.space/)) y *Prolog
Experiments in Discrete Mathematics, Logic, and Computability* de James
Hein; la lista completa, con los apartados que se usan, está en las
[referencias](#referencias) de cada página. La última sección
aplica el verificador de estratos a las reglas del sistema experto de los
capítulos [20](../capitulo-20-operadores-y-reglas-como-datos/index.md) y [34](../capitulo-34-introspeccion-y-metainterpretes/index.md). El capítulo cumple tres anuncios: la forma
clausal de fórmulas cualesquiera y la relación entre las consecuencias de un
programa y las respuestas de Prolog, del [capítulo 13](../capitulo-13-prolog-y-la-logica/index.md); lo que conservan
el despliegue y el plegado, del [capítulo 36](../capitulo-36-transformacion-de-programas-y-compilacion/index.md); y la estratificación de un
programa leído como datos, de los capítulos [33](../capitulo-33-inspeccion-de-terminos/index.md) y [34](../capitulo-34-introspeccion-y-metainterpretes/index.md).

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- definir interpretación, modelo y consecuencia lógica para un programa, y
  calcular su modelo mínimo;
- describir una derivación SLD con su regla de selección, y distinguir lo
  que la regla cambia —la forma del árbol— de lo que no cambia —las
  respuestas—;
- escribir la compleción de Clark de un predicado, y reconocer cuándo una
  derivación SLDNF no puede seguir porque solo quedan negaciones con
  variables;
- decidir si un programa es estratificado, calcular sus estratos y su
  modelo estándar;
- calcular el modelo bien fundado de un programa cualquiera, con sus
  átomos verdaderos, falsos e indefinidos;
- evaluar un programa de abajo hacia arriba, con el método ingenuo y el
  semi-ingenuo, y medir la diferencia;
- verificar si una base de reglas con negación tiene un significado claro.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **3:00 h**.
    Resolver los 6 ejercicios marcados con ★: **1:35 h**.
    Resolver los 15 ejercicios del capítulo: **4:30 h**.

## 39.1 Modelos y consecuencia lógica

Un programa sin negación, un **programa definido**, es un conjunto de
cláusulas de Horn con una conclusión cada una
([sección 13.5](../capitulo-13-prolog-y-la-logica/index.md#135-clausulas-de-horn)). Para decir qué afirma, se fijan los
objetos de los que habla y los hechos posibles sobre ellos:

- el **universo de Herbrand** $U_P$ son los términos sin variables que se
  construyen con las constantes y los functores del programa;
- la **base de Herbrand** $B_P$ son los átomos sin variables que se
  construyen con los predicados del programa y los términos de $U_P$;
- una **interpretación** es un subconjunto $I \subseteq B_P$: los átomos
  que declara verdaderos, y todos los demás son falsos;
- una interpretación es un **modelo** de P, $I \models P$, si hace verdadera
  cada instancia sin variables de cada cláusula: cuando el cuerpo de una
  instancia está en I, también su cabeza.

`semantica.pl` tiene los programas del capítulo como cláusulas comunes, y
`programa/2` nombra los predicados de cada uno. `clausulas/2` los lee con
`clause/2` y los devuelve como una lista de términos `Cabeza :- Cuerpo`: el
programa pasa a ser un dato, y los evaluadores del capítulo trabajan sobre
esa lista. El primero es el programa `lluvia`:

<!-- ejemplo: capitulo-39/semantica.pl predicado: llueve/0 calle_mojada/0 -->
```prolog
% llueve: llueve.
llueve.

%!  calle_mojada is semidet.
%
%   La calle está mojada si llueve o si se riega.
calle_mojada :-
    llueve.
calle_mojada :-
    riego.
```

```prolog
?- clausulas(lluvia, Cs).
Cs = [(llueve:-true), (calle_mojada:-llueve), (calle_mojada:-riego)].
```

`riego/0` no tiene cláusulas: el archivo lo declara dinámico para que exista.
La base de Herbrand tiene tres átomos, `llueve`, `riego` y `calle_mojada`, y
hay ocho interpretaciones. `es_modelo_de/2` verifica una sobre la lista de
cláusulas, y usa `cumple/3`, que decide si un cuerpo es verdadero en una
interpretación y liga sus variables con los átomos que encuentra en ella.
Cada evaluador del capítulo tiene dos formas, como `contar_lineas/2` y
`contar_lineas_de/3` en la [sección 28.2](../capitulo-28-archivos-streams-y-formatos/index.md#282-leer-terminos-y-lineas): la que termina en `_de` recibe
la lista de cláusulas y hace el trabajo; la otra, `es_modelo/2`, recibe el
nombre del programa, obtiene sus cláusulas con `clausulas/2` y llama a
`es_modelo_de/2`. Un argumento es siempre un nombre o siempre una lista, nunca una
cosa o la otra, como pide la representación limpia de la
[sección 33.6](../capitulo-33-inspeccion-de-terminos/index.md#336-representaciones-limpias):

<!-- ejemplo: capitulo-39/semantica.pl predicado: es_modelo_de/2 es_modelo/2 cumple/3 -->
```prolog
%!  es_modelo_de(+Clausulas:list, +I:list) is semidet.
%
%   I, una lista de átomos sin variables, es un modelo de Clausulas: no hay
%   una cláusula con el cuerpo verdadero en I y la cabeza fuera de I.
es_modelo_de(Clausulas, I0) :-
    sort(I0, I),
    \+ ( member(Cabeza :- Cuerpo, Clausulas),
         cumple(Cuerpo, I, I),
         \+ ord_memberchk(Cabeza, I) ).

%!  es_modelo(+Programa, +I:list) is semidet.
%
%   I es un modelo del programa llamado Programa: es_modelo_de/2 sobre sus
%   cláusulas.
es_modelo(Programa, I) :-
    clausulas(Programa, Clausulas),
    es_modelo_de(Clausulas, I).

%!  cumple(+Cuerpo, +I:list, +J:list) is nondet.
%
%   Cuerpo es verdadero con los átomos de la interpretación I; un literal
%   negado \+ A es verdadero si A no está en la interpretación J. Una
%   respuesta por cada forma de hacerlo verdadero, con las variables del
%   cuerpo ligadas. Las comparaciones aritméticas se evalúan con Prolog.
%   Error de instanciación si un literal negado tiene variables.
cumple(true, _, _).
cumple((A, B), I, J) :-
    cumple(A, I, J),
    cumple(B, I, J).
cumple(\+ A, _, J) :-
    must_be(ground, A),
    \+ ord_memberchk(A, J).
cumple(C, _, _) :-
    comparacion(C),
    comparar(C).
cumple(A, I, _) :-
    atomo(A),
    member(A, I).
```

El tercer argumento de `cumple/3` es la interpretación contra la que se
evalúan los literales negados; hasta la [sección 39.3](resolucion.md#393-negacion-como-falla-la-complecion-de-clark-y-sldnf) no hace falta, y es la
misma. Las consultas usan la forma que recibe el nombre del programa:

```prolog
?- es_modelo(lluvia, [llueve, calle_mojada]).
true.

?- es_modelo(lluvia, [llueve, riego, calle_mojada]).
true.

?- es_modelo(lluvia, [llueve]).
false.
```

La tercera no es un modelo: la instancia `calle_mojada :- llueve` tiene el
cuerpo verdadero y la cabeza falsa. Los dos modelos difieren en `riego`, que
el programa no afirma ni niega. Un átomo A es **consecuencia lógica** de P,
$P \models A$, si es verdadero en todos los modelos de P. `calle_mojada` lo
es; `riego` no, porque el primer modelo lo hace falso.

Para un programa definido, la intersección de todos sus modelos es también
un modelo, el **modelo mínimo de Herbrand**, y sus átomos son exactamente las
consecuencias lógicas del programa que están en la base:

$$M_P = \bigcap \{\, I \subseteq B_P \mid I \models P \,\} = \{\, A \in B_P \mid P \models A \,\}$$

Es el significado del programa: lo que afirma, y nada más. `modelo_minimo/2`
lo calcula, con el procedimiento de la [sección 39.6](negacion.md#396-evaluacion-de-abajo-hacia-arriba), y `consecuencia/2`
da sus átomos, uno por respuesta:

```prolog
?- modelo_minimo(lluvia, M).
M = [calle_mojada, llueve].

?- consecuencia(caminos, camino(a, Y)).
Y = a ;
Y = b ;
Y = c ;
Y = d ;
false.

?- consecuencia(caminos, camino(d, Y)).
false.
```

El programa `caminos` tiene `camino/2` con la recursión a la izquierda sobre
un grafo con un ciclo:

<!-- ejemplo: capitulo-39/semantica.pl predicado: arco/2 camino/2 -->
```prolog
% arco(X, Y): hay un arco de X a Y.
arco(a, b).
arco(b, c).
arco(c, a).
arco(c, d).

%!  camino(?X, ?Y) is nondet.
%
%   Hay un camino de X a Y. Con la recursión a la izquierda y el ciclo de
%   a, b y c, Prolog no termina: el programa se evalúa de abajo hacia
%   arriba.
camino(X, Y) :-
    arco(X, Y).
camino(X, Y) :-
    camino(X, Z),
    arco(Z, Y).
```

Prolog no termina con `camino(a, Y)`: después de las respuestas, la rama de
la segunda cláusula se llama a sí misma sin fin. El modelo mínimo, en
cambio, es finito y está bien definido: tiene los 4 arcos y los 12 caminos.
**Lo que el programa significa no depende de cómo se lo ejecuta**; la
ejecución puede alcanzarlo o no, y las secciones siguientes dicen cuándo.

Para un átomo sin variables, la relación entre las respuestas de Prolog y el
modelo es la siguiente: si la consulta responde `true`, el átomo está en
$M_P$; si responde `false.`, el átomo no está en $M_P$, y es falso en el
modelo mínimo, pero no es falso en todos los modelos. $\lnot A$ no es
consecuencia lógica de un programa definido, porque $B_P$ entero es siempre
un modelo. Tomar $M_P$ como la única interpretación que interesa es el
**supuesto de mundo cerrado** de la [sección 10.1](../capitulo-10-negacion-como-falla/index.md#101-el-supuesto-de-mundo-cerrado); Spivey lo
formula así (*An Introduction to Logic Programming through Prolog*,
apartado 5.3), y Nilsson y Małuszyński demuestran la existencia del modelo
mínimo en los apartados 2.3 y 2.4.

### Fórmulas que no son cláusulas de Horn

Toda fórmula de la lógica de primer orden se lleva a **forma clausal**: se
eliminan las implicaciones, se mueven las negaciones hasta los átomos, los
cuantificadores existenciales se reemplazan por funciones nuevas (la
*skolemización*), y lo que queda se escribe como una conjunción de
disyunciones de literales. Flach describe cada paso (*Simply Logical*,
apartado 2.5). El resultado es un conjunto de cláusulas, pero no
necesariamente de Horn:

- $\lnot \mathit{remar} \lor \lnot \mathit{llueve}$, la restricción del
  [ejercicio 16 del capítulo 13](../capitulo-13-prolog-y-la-logica/soluciones.md#16), no tiene ningún literal positivo: tiene
  la forma de una consulta negada, y como parte de un programa es una
  **restricción de integridad**, que prohíbe modelos en lugar de afirmar
  átomos;
- $\mathit{frio} \lor \mathit{calor}$ tiene dos literales positivos: es una
  **cláusula indefinida**. Tiene dos modelos mínimos, $\{ \mathit{frio} \}$ y
  $\{ \mathit{calor} \}$, y ninguno está contenido en el otro: no hay un
  modelo mínimo, y ninguno de los dos átomos es consecuencia lógica.

Un conjunto de cláusulas de Horn con conclusión tiene siempre modelo mínimo,
y es la razón por la que Prolog se limita a ellas: la respuesta a una
consulta sin variables es un sí o un no sobre un único modelo. Un programa
con fórmulas cualesquiera necesita otra forma de probar, la resolución
general, que el [capítulo 63](../capitulo-63-proyecto-demostrador-teoremas/index.md) construye.

### Lo que conservan el despliegue y el plegado

El despliegue de la [sección 36.3](../capitulo-36-transformacion-de-programas-y-compilacion/index.md#363-desplegar-y-plegar) reemplaza un objetivo por los
cuerpos de las cláusulas que lo resuelven: el programa transformado tiene el
**mismo modelo mínimo** que el original. El plegado lo conserva bajo una
condición, enunciada por Hisao Tamaki y Taisuke Sato en 1984: la cláusula
que se pliega debe provenir de un despliegue. El plegado de la definición
con ella misma, que aquella sección muestra, no la cumple, y el resultado
tiene un modelo mínimo menor: no contiene ningún par de consecutivos.

El capítulo continúa en la página
[Resolución SLD y SLDNF](resolucion.md#392-resolucion-sld), con la
resolución SLD enunciada con precisión y la negación como falla, con la
compleción de Clark y la resolución SLDNF. Antes, los
[ejercicios](#ejercicios) de esta página practican la
[sección 39.1](#391-modelos-y-consecuencia-logica).

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** El programa `lluvia` tiene ocho interpretaciones. Predecir
   cuáles son modelos, y comprobarlo con `es_modelo/2`. ¿Cuál es la
   intersección de los modelos, y qué relación tiene con
   `modelo_minimo/2`?
2. **(2)** Escribir `base_herbrand_de(Clausulas, Base)`: los átomos sin
   variables que se construyen con los predicados y las constantes de un
   programa sin functores, y `base_herbrand/2`, que recibe el nombre del
   programa. ¿Cuántos átomos tiene la base de `caminos`, y qué
   fracción de ellos está en el modelo mínimo?

## Referencias

- Ulf Nilsson y Jan Małuszyński, *Logic, Programming and Prolog*, 2.ª
  edición, John Wiley & Sons, 1995 — capítulo «Definite Logic Programs»
  (apartados «The Least Herbrand Model» y «Construction of Least Herbrand
  Models»).
  [Edición en línea de los autores](https://www.ida.liu.se/~ulfni53/lpp/).
  El capítulo toma de allí el orden de la exposición y los enunciados de
  los teoremas que esta página cita sin demostrar.
- Michael Spivey, *An Introduction to Logic Programming through Prolog*,
  Prentice Hall, 1996 — apartado «Completeness» del capítulo «Inference
  rules».
  [Edición del autor](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf).
  De allí viene la lectura del supuesto de mundo cerrado como la elección
  del modelo mínimo.
- Peter Flach, *Simply Logical: Intelligent Reasoning by Example*, John
  Wiley & Sons, 1994 — apartado «The relation between clausal logic and
  Predicate Logic»
  ([en línea](https://book.simply-logical.space/src/text/1_part_i/2.5.html)).
  Esta página toma los pasos de la forma clausal.
- El artículo original que esta página nombra, citado a través de los
  libros anteriores: Hisao Tamaki y Taisuke Sato, «Unfold/fold
  transformation of logic programs», 1984 (la condición del plegado).
