# Capítulo 38 — Semántica de los programas lógicos

El [capítulo 5](../capitulo-05-como-responde-prolog/index.md) describió cómo Prolog busca una respuesta, el
[capítulo 10](../capitulo-10-negacion-como-falla/index.md) qué hace `\+` y el [capítulo 12](../capitulo-12-prolog-y-la-logica/index.md) cómo se lee una cláusula como
una fórmula. Este capítulo reúne las tres cosas y las enuncia con precisión:
qué afirma un programa, qué átomos son sus consecuencias, cuándo las
encuentra la resolución, y qué significa un programa con negación, incluso
uno en el que un predicado depende de su propia negación. Es el capítulo de
teoría de la parte III, y precede a la tabulación del
[capítulo 39](../capitulo-39-tabulacion/index.md), que calcula exactamente lo que aquí se define.

Cada definición viene acompañada de un evaluador pequeño escrito en Prolog,
con sus pruebas, que trabaja sobre un programa leído como datos con
`clause/2`, como en el [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md): uno verifica si una interpretación es
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
[referencias](#referencias). La última sección
aplica el verificador de estratos a las reglas del sistema experto de los
capítulos [19](../capitulo-19-operadores-y-reglas-como-datos/index.md) y [33](../capitulo-33-introspeccion-y-metainterpretes/index.md). El capítulo cumple tres anuncios: la forma
clausal de fórmulas cualesquiera y la relación entre las consecuencias de un
programa y las respuestas de Prolog, del [capítulo 12](../capitulo-12-prolog-y-la-logica/index.md); lo que conservan
el despliegue y el plegado, del [capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md); y la estratificación de un
programa leído como datos, de los capítulos [32](../capitulo-32-inspeccion-de-terminos/index.md) y [33](../capitulo-33-introspeccion-y-metainterpretes/index.md).

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
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:10 h**.
    Resolver los 6 ejercicios marcados con ★: **1:35 h**.
    Resolver los 15 ejercicios del final: **4:30 h**.

## 38.1 Modelos y consecuencia lógica

Un programa sin negación, un **programa definido**, es un conjunto de
cláusulas de Horn con una conclusión cada una
([sección 12.4](../capitulo-12-prolog-y-la-logica/index.md#124-clausulas-de-horn)). Para decir qué afirma, se fijan los
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

<!-- ejemplo: capitulo-38/semantica.pl predicado: llueve/0 calle_mojada/0 -->
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
`contar_lineas_de/3` en la [sección 27.2](../capitulo-27-archivos-streams-y-formatos/index.md#272-leer-terminos-y-lineas): la que termina en `_de` recibe
la lista de cláusulas y hace el trabajo; la otra, `es_modelo/2`, recibe el
nombre del programa, obtiene sus cláusulas con `clausulas/2` y llama a
`es_modelo_de/2`. Un argumento es siempre un nombre o siempre una lista, nunca una
cosa o la otra, como pide la representación limpia de la
[sección 32.6](../capitulo-32-inspeccion-de-terminos/index.md#326-representaciones-limpias):

<!-- ejemplo: capitulo-38/semantica.pl predicado: es_modelo_de/2 es_modelo/2 cumple/3 -->
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
evalúan los literales negados; hasta la [sección 38.3](#383-negacion-como-falla-la-complecion-de-clark-y-sldnf) no hace falta, y es la
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
lo calcula, con el procedimiento de la [sección 38.6](#386-evaluacion-de-abajo-hacia-arriba), y `consecuencia/2`
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

<!-- ejemplo: capitulo-38/semantica.pl predicado: arco/2 camino/2 -->
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
  [ejercicio 17 del capítulo 12](../capitulo-12-prolog-y-la-logica/soluciones.md#17), no tiene ningún literal positivo: tiene
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
general, que el [capítulo 62](../capitulo-62-proyecto-demostrador-teoremas/index.md) construye.

### Lo que conservan el despliegue y el plegado

El despliegue de la [sección 35.3](../capitulo-35-transformacion-de-programas-y-compilacion/index.md#353-desplegar-y-plegar) reemplaza un objetivo por los
cuerpos de las cláusulas que lo resuelven: el programa transformado tiene el
**mismo modelo mínimo** que el original. El plegado lo conserva bajo una
condición, enunciada por Hisao Tamaki y Taisuke Sato en 1984: la cláusula
que se pliega debe provenir de un despliegue. El plegado de la definición
con ella misma, que aquella sección muestra, no la cumple, y el resultado
tiene un modelo mínimo menor: no contiene ningún par de consecutivos.

## 38.2 Resolución SLD

Un paso de resolución SLD elige un átomo de la consulta con una **regla de
selección**, lo unifica con la cabeza de una cláusula renombrada y lo
reemplaza por el cuerpo. La página
[Resolución SLD y SLDNF](resolucion.md#resolucion-sld) escribe ese paso en
Prolog, `paso/4`, recorre con `arbol_sld/5` el árbol SLD de una consulta con
la regla de la izquierda, la de Prolog, y con la de la derecha, y enuncia
los tres teoremas que ordenan lo observado: la resolución SLD es correcta,
es completa, y sus respuestas no dependen de la regla de selección, que sí
cambia la forma y la finitud del árbol.

## 38.3 Negación como falla: la compleción de Clark y SLDNF

Para leer el éxito de `\+ A` como $\lnot A$ hace falta agregar al programa
lo que calla: que sus cláusulas son todas las razones por las que un átomo
es verdadero. Es la **compleción de Clark**, y la misma página, en
[Negación como falla](resolucion.md#negacion-como-falla-la-complecion-de-clark-y-sldnf),
la construye con `complecion/3`, presenta la resolución SLDNF con una regla
de selección segura, `sldnf/2`, que responde bien donde `\+` con una variable
libre responde mal, y muestra el programa `circular`, cuya compleción no tiene
modelos: `r :- \+ r`.

## 38.4 Estratificación

Un programa es **estratificado** si ningún ciclo de su grafo de dependencias
pasa por una negación: entonces se evalúa en capas, cada una sobre las
anteriores ya completas, y tiene un modelo privilegiado, el **modelo
estándar**. La página [Estratificación y semántica bien fundada](negacion.md#estratificacion)
construye el grafo con `dependencias/2`, calcula los estratos con
`estratos/2`, localiza los ciclos que los impiden con `ciclos_negativos/2` y
evalúa por estratos con `modelo_estandar/2`.

## 38.5 La semántica bien fundada

La **semántica bien fundada** asigna a cada átomo de cualquier programa uno
de tres valores: verdadero, falso o indefinido. La misma página, en
[La semántica bien fundada](negacion.md#la-semantica-bien-fundada), la
calcula con el punto fijo alternado, `bien_fundado/3`, sobre el juego de
posiciones ganadoras de Nilsson y Małuszyński, donde las posiciones de empate
quedan indefinidas, y enuncia que coincide con el modelo mínimo y con el
modelo estándar donde estos existen.

## 38.6 Evaluación de abajo hacia arriba

El **operador de consecuencia inmediata** $T_P$ lleva una interpretación a
los átomos que el programa concluye en un paso a partir de ella:

$$T_P(I) = \{\, A \mid A \leftarrow B_1, \dots, B_n \text{ es una instancia sin variables de una cláusula de } P, \; B_1, \dots, B_n \in I \,\}$$

Maarten van Emden y Robert Kowalski demostraron en 1976 que el modelo mínimo
es el menor punto fijo de $T_P$, y que se alcanza aplicándolo desde la
interpretación vacía: $M_P = \bigcup_{k \ge 0} T_P^k(\varnothing)$
(Nilsson y Małuszyński, apartado 2.4; Hein, *Prolog Experiments*, apartado
10.1). Los hechos entran en el primer paso, lo que se deduce de ellos en el
segundo, y así sucesivamente. `consecuencias_de/3` es $T_P$:

<!-- ejemplo: capitulo-38/semantica.pl predicado: consecuencias_de/3 derivar/4 -->
```prolog
%!  consecuencias_de(+Clausulas:list, +I:list, -T:list) is det.
%
%   T es T_P(I), el conjunto ordenado de las consecuencias inmediatas de I:
%   las cabezas de las cláusulas cuyo cuerpo es verdadero en I.
consecuencias_de(Clausulas, I, T) :-
    derivar(Clausulas, I, I, Cabezas),
    sort(Cabezas, T).

%!  derivar(+Clausulas:list, +I:list, +J:list, -Cabezas:list) is det.
%
%   Cabezas son las cabezas de las cláusulas cuyo cuerpo es verdadero con
%   I y J (cumple/3), una por cada forma de hacerlo verdadero, con
%   repeticiones. Error de instanciación si una cabeza queda con variables.
derivar(Clausulas, I, J, Cabezas) :-
    findall(Cabeza,
            ( member(Cabeza :- Cuerpo, Clausulas),
              cumple(Cuerpo, I, J),
              must_be(ground, Cabeza) ),
            Cabezas).
```

```prolog
?- consecuencias(lluvia, [], T1), consecuencias(lluvia, T1, T2), consecuencias(lluvia, T2, T3).
T1 = [llueve],
T2 = T3, T3 = [calle_mojada, llueve].
```

`T2 = T3` es el punto fijo. La **evaluación ingenua** repite ese paso hasta
que la interpretación no cambia; `ingenua_de/4` agrega cada vez $T_P(I)$ a I,
lo que da lo mismo para un programa definido y permite empezar desde una
interpretación dada, como hace `modelo_estandar_de/2` con cada estrato. Cuenta
las aplicaciones de $T_P$ y las **derivaciones**, cada cabeza obtenida de una
instancia de una cláusula:

<!-- ejemplo: capitulo-38/semantica.pl predicado: ingenua_de/4 -->
```prolog
%!  ingenua_de(+Clausulas:list, +I0:list, -M:list, -Costo) is det.
%
%   Evaluación ingenua: M es el primer I que no cambia en la sucesión que
%   empieza en I0 y agrega en cada paso T_P(I). Costo es costo(Pasos,
%   Derivaciones): cuántas veces se aplicó T_P, y cuántas cabezas derivaron
%   todas esas aplicaciones, contando las repetidas.
ingenua_de(Clausulas, I0, M, Costo) :-
    ingenua_de(Clausulas, I0, M, costo(0, 0), Costo).
```

La evaluación de abajo hacia arriba termina siempre en un programa sin
functores, como los del capítulo, porque la base de Herbrand es finita: es
lo que se llama **Datalog**. La recursión a la izquierda y los ciclos de
`caminos`, que impiden terminar a Prolog, no le afectan. Su defecto es otro:
cada paso vuelve a derivar todo lo que ya derivaron los anteriores. En el
paso k, `camino(X, Y) :- camino(X, Z), arco(Z, Y)` recombina todos los
caminos conocidos, aunque solo los del paso k − 1 puedan dar algo nuevo.

La **evaluación semi-ingenua** evita esa repetición: después del primer
paso, una cláusula se usa solo con al menos un átomo del cuerpo tomado de
los **nuevos** del paso anterior, y los demás del conjunto completo
(Nilsson y Małuszyński, apartado 15.2):

<!-- ejemplo: capitulo-38/semantica.pl predicado: semi_ingenua_de/4 derivar_con_nuevos/4 -->
```prolog
%!  semi_ingenua_de(+Clausulas:list, +I0:list, -M:list, -Costo) is det.
%
%   Evaluación semi-ingenua: el mismo M que ingenua_de/4. Después del primer
%   paso, cada cláusula se evalúa solo con al menos un átomo del cuerpo
%   tomado de los nuevos del paso anterior. Costo, como en ingenua_de/4.
semi_ingenua_de(Clausulas, I0, M, Costo) :-
    derivar(Clausulas, I0, I0, Cabezas),
    length(Cabezas, D),
    sort(Cabezas, T),
    ord_subtract(T, I0, Nuevos),
    ord_union(I0, Nuevos, I1),
    semi_ingenua_de(Clausulas, I1, Nuevos, M, costo(1, D), Costo).

%!  derivar_con_nuevos(+Clausulas:list, +I:list, +Nuevos:list,
%!                     -Cabezas:list) is det.
%
%   Cabezas son las de derivar/4 con I, restringidas a las derivaciones que
%   toman de Nuevos el átomo de alguna posición del cuerpo; los demás
%   literales se evalúan con I. Una derivación que usa dos átomos nuevos
%   aparece dos veces.
derivar_con_nuevos(Clausulas, I, Nuevos, Cabezas) :-
    findall(Cabeza,
            ( member(Cabeza :- Cuerpo, Clausulas),
              conjuncion_lista(Cuerpo, Literales),
              append(Antes, [Literal|Despues], Literales),
              atomo(Literal),
              member(Literal, Nuevos),
              cumple_todos(Antes, I),
              cumple_todos(Despues, I),
              must_be(ground, Cabeza) ),
            Cabezas).
```

```prolog
?- ingenua(caminos, [], _, C1), semi_ingenua(caminos, [], _, C2).
C1 = costo(5, 60),
C2 = costo(5, 20).
```

Los dos métodos dan el mismo modelo en los mismos cinco pasos; el
semi-ingenuo hace un tercio de las derivaciones. La diferencia crece con el
programa. `cadena(N, Cs)` arma las cláusulas de `camino/2` sobre N arcos en
fila, de 0 a N, y `generado/2` las registra como el programa `cadena(N)`:
`clausulas/2` busca en él los nombres que no están en `programa/2`, y otros
archivos le agregan programas, porque está declarado `multifile`, como
`prolog:message//1` en la [sección 25.7](../capitulo-25-errores-y-excepciones/index.md#257-mensajes-para-el-usuario):

<!-- ejemplo: capitulo-38/semantica.pl predicado: generado/2 -->
```prolog
%!  generado(+Programa, -Clausulas:list) is semidet.
%
%   Clausulas son las del programa Programa, construido como datos: aquí,
%   cadena(N), el de cadena/2. Falla con otro nombre.
generado(cadena(N), Clausulas) :-
    cadena(N, Clausulas).
```


```text
?- time(ingenua(cadena(40), [], _, C)).
% 15,935,580 inferences, 1.609 CPU in 1.612 seconds (100% CPU, 9901720 Lips)
C = costo(42, 24640).

?- time(semi_ingenua(cadena(40), [], _, C)).
% 483,874 inferences, 0.047 CPU in 0.048 seconds (97% CPU, 10322645 Lips)
C = costo(42, 860).
```

El modelo tiene 860 átomos, 40 arcos y 820 caminos, y la evaluación
semi-ingenua deriva cada uno exactamente una vez: cada camino de i a j se
obtiene solo del camino de i a j − 1 y del arco de j − 1 a j. La ingenua
hace casi treinta veces más derivaciones, y tarda más de treinta veces
más.

Queda un defecto en los dos métodos: calculan el modelo entero, aunque la
consulta pregunte solo por los caminos que salen de un nodo. La
**transformación mágica** (Nilsson y Małuszyński, apartado 15.3) reescribe el
programa para que la evaluación de abajo hacia arriba derive solo lo que la
consulta necesita. La tabulación del [capítulo 39](../capitulo-39-tabulacion/index.md) llega al mismo
lugar desde el otro lado: parte de la consulta, como Prolog, y guarda las
respuestas de cada subobjetivo en una tabla que completa hasta el punto
fijo. Y la cláusula `WITH RECURSIVE` de SQL, del
[capítulo 42](../capitulo-42-prolog-y-sql/index.md), es una evaluación semi-ingenua: cada iteración une
la tabla con las filas nuevas de la iteración anterior. Flach escribe en
Prolog un evaluador de abajo hacia arriba para cláusulas generales, que
construye modelos (*Simply Logical*, apartado 5.4).

!!! question "Actividad"
    Predecir `costo(Pasos, Derivaciones)` de las dos evaluaciones con
    el programa `cadena(10)`, y comprobarlo. ¿Cuántos pasos da cada una, y
    por qué las derivaciones de la semi-ingenua son tantas como los átomos
    del modelo?

## 38.7 Las reglas del sistema experto

Las reglas del sistema experto del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md#337-el-sistema-experto-explica) son términos
`si Condiciones entonces Conclusion`, y su [ejercicio 13](../capitulo-33-introspeccion-y-metainterpretes/soluciones.md#13) les agregó la
negación `no`: r11 concluye `pinguino` de `ave y no vuela y nada`, y r12
`avestruz` de `ave y no vuela y peso(P) y P > 50`. `experto.pl` tiene esas
reglas y las convierte en cláusulas de Prolog, con `,` en lugar de `y` y
`\+` en lugar de `no`, para que los evaluadores de `semantica.pl`, que carga
con `ensure_loaded/1`, las examinen como a cualquier programa:

<!-- ejemplo: capitulo-38/experto.pl predicado: base/2 regla_clausula/2 condiciones_cuerpo/2 -->
```prolog
%!  base(+Version:atom, -Clausulas:list) is det.
%
%   Clausulas son las reglas de la base, más las que agrega Version
%   (original, vuela o puede_volar), como cláusulas Conclusion :- Cuerpo.
base(Version, Clausulas) :-
    must_be(oneof([original, vuela, puede_volar]), Version),
    findall(R, regla(_, R), Reglas),
    findall(R, agregada(Version, _, R), Agregadas),
    append(Reglas, Agregadas, Todas),
    maplist(regla_clausula, Todas, Clausulas).

%!  regla_clausula(+Regla, -Clausula) is det.
%
%   Clausula es Regla, si Condiciones entonces Conclusion, escrita como la
%   cláusula Conclusion :- Cuerpo.
regla_clausula(si Condiciones entonces Conclusion, Conclusion :- Cuerpo) :-
    condiciones_cuerpo(Condiciones, Cuerpo).

%!  condiciones_cuerpo(+Condiciones, -Cuerpo) is det.
%
%   Cuerpo es Condiciones con , en lugar de y, y \+ en lugar de no.
condiciones_cuerpo(Condiciones, Cuerpo) :-
    (   Condiciones = (A y B)
    ->  Cuerpo = (CuerpoA, CuerpoB),
        condiciones_cuerpo(A, CuerpoA),
        condiciones_cuerpo(B, CuerpoB)
    ;   Condiciones = (no A)
    ->  Cuerpo = (\+ A)
    ;   Cuerpo = Condiciones
    ).
```

El programa de cada versión se llama `base(Version)`: `experto.pl` lo agrega
a `generado/2`, y los evaluadores lo reciben por ese nombre:

```prolog
?- regla(r12, R), regla_clausula(R, C).
R = (si ave y no vuela y peso(_A)y _A>50 entonces avestruz),
C = (avestruz:-ave, \+vuela, peso(_A), _A>50).

?- estratos(base(original), [_|Superiores]).
Superiores = [1-[avestruz/0, pinguino/0]].
```

La base es estratificada: `vuela` es una observación, sin reglas, y
`pinguino` y `avestruz`, que la usan negada, quedan en el estrato 1; todos
los demás predicados están en el 0. El significado de la base es claro, y el
intérprete del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) lo calcula.

Una regla natural de agregar es la de las aves que vuelan: «un ave que no es
pingüino ni avestruz vuela». Flach analiza una regla de este tipo, con sus
excepciones, como razonamiento por defecto (*Simply Logical*, apartados 8.1
y 8.2). La versión `vuela` de la base agrega r13, `si ave y no pinguino y no
avestruz entonces vuela`:

```prolog
?- estratos(base(vuela), E).
false.

?- ciclos_negativos(base(vuela), P).
P = [avestruz/0-vuela/0, pinguino/0-vuela/0, vuela/0-avestruz/0, vuela/0-pinguino/0].
```

r13 crea dos clases de ciclos. Con r4, `si vuela y pone_huevos entonces
ave`, crea uno **positivo**, `ave` → `vuela` → `ave`, que no afecta al
significado: la evaluación de abajo hacia arriba lo recorre sin problema,
aunque el intérprete del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md), que resuelve de arriba hacia
abajo, entra en él y agota la pila con cualquier caso, también el del
guepardo. Con r11 y r12 crea dos ciclos **negativos**: `pinguino` depende de
no `vuela`, y `vuela` de no `pinguino`. Esos no los resuelve ninguna
evaluación. `diagnostico/3` agrega las observaciones como hechos, con el
programa `con_hechos(base(Version), Observaciones)` que `generado/2` define
en `experto.pl`, y calcula el modelo bien fundado:

<!-- ejemplo: capitulo-38/experto.pl predicado: generado/2 diagnostico/3 -->
```prolog
%!  generado(+Programa, -Clausulas:list) is semidet.
%
%   Los programas de este archivo: base(Version), las cláusulas de base/2,
%   y con_hechos(Programa, Hechos), las del programa Programa más un hecho
%   por cada uno de Hechos.
generado(base(Version), Clausulas) :-
    base(Version, Clausulas).
generado(con_hechos(Programa, Hechos), Clausulas) :-
    clausulas(Programa, Reglas),
    findall(H :- true, member(H, Hechos), Nuevas),
    append(Reglas, Nuevas, Clausulas).

%!  diagnostico(+Version:atom, +Observaciones:list, -Resultado) is det.
%
%   Resultado es resultado(Verdaderas, Indefinidas): las hipótesis
%   verdaderas y las indefinidas en el modelo bien fundado de la base de
%   Version con Observaciones como hechos.
diagnostico(Version, Observaciones, resultado(Verdaderas, Indefinidas)) :-
    bien_fundado(con_hechos(base(Version), Observaciones), V, I),
    findall(H, ( hipotesis(H), ord_memberchk(H, V) ), Verdaderas),
    findall(H, ( hipotesis(H), ord_memberchk(H, I) ), Indefinidas).
```

```prolog
?- diagnostico(original, [tiene_plumas, nada, peso(30)], R).
R = resultado([pinguino], []).

?- diagnostico(vuela, [tiene_plumas, nada, peso(30)], R).
R = resultado([], [pinguino]).

?- diagnostico(vuela, [tiene_plumas, peso(90)], R).
R = resultado([], [avestruz]).
```

Con la base original, un ave que nada y pesa 30 es un pingüino. Con r13, el
mismo caso queda indefinido: el ave es un pingüino que no vuela, o un ave que
vuela y no es pingüino, y las reglas no deciden entre las dos lecturas. Una
base de reglas con negación a través de la recursión no tiene un
significado claro: el sistema no da una respuesta falsa, pero tampoco una
respuesta.

La corrección es romper el ciclo: que r13 concluya algo que r11 y r12 no
usan. La versión `puede_volar` concluye `puede_volar`, y deja `vuela` como
observación:

```prolog
?- estratos(base(puede_volar), [_|Superiores]).
Superiores = [1-[avestruz/0, pinguino/0], 2-[puede_volar/0]].

?- diagnostico(puede_volar, [tiene_plumas, nada, peso(30)], R).
R = resultado([pinguino], []).
```

La base vuelve a ser estratificada, con un estrato más, y cada caso tiene
una respuesta. La verificación es estática: `estratos/2` y
`ciclos_negativos/2` leen las reglas, no las ejecutan, y se pueden aplicar a
cada versión de la base antes de usarla. El [capítulo 39](../capitulo-39-tabulacion/index.md) lleva el
intérprete a la tabulación, donde el ciclo positivo de r4 y r13 termina, y
el [capítulo 65](../capitulo-65-proyecto-razonamiento-rebatible/index.md) trata las reglas con excepciones como razonamiento
rebatible.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada evaluador declara modos y determinación: `estratos/2` y `modelo_estandar/2` son `semidet` y fallan solo si el programa no es estratificado; `bien_fundado/3`, `ingenua/4`, `semi_ingenua/4` y `arbol_sld/5` son `det`, y sus pruebas no declaran `nondet` |
    | C2, C5 | `clausulas/2` produce un error de instanciación con el programa libre y uno de existencia con un nombre desconocido, también con una lista de cláusulas pasada en lugar de un nombre; `cumple/3` produce un error de instanciación con una negación que tiene variables, y `derivar/4` con una cabeza que el cuerpo no liga: un programa que no es Datalog permitido no da un modelo incorrecto sin aviso |
    | C6 | los evaluadores `_de` son puros: reciben las cláusulas como una lista y devuelven conjuntos ordenados; las formas que reciben el nombre solo agregan `clausulas/2`, y el único contacto con el programa es `clause/2`, dentro de ella |
    | C7 | 103 pruebas en tres archivos, que prueban cada evaluador por su nombre y con una lista; cada evaluador se compara con otro que calcula lo mismo por otro camino: `ingenua/4` con `semi_ingenua/4`, `modelo_estandar/2` con `modelo_minimo/2` en un programa definido, y `bien_fundado/3` con `modelo_estandar/2` en uno estratificado |

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
3. ★ **(2)** `modelo_minimo/2` sobre `circular` responde `M = [p, q, r,
   s]`. Verificar con `es_modelo/2` si esa interpretación es un modelo,
   buscar uno menor, y explicar por qué la sucesión de $T_P$ deja de crecer
   de manera ordenada cuando el programa tiene negación.
4. **(1)** Escribir, como la tabla de la
   [sección 12.5](../capitulo-12-prolog-y-la-logica/index.md#125-como-prueba-prolog), los resolventes de la refutación de
   `conexion(a, c)` con la regla de la izquierda, y comprobarlos con
   `paso/4`.
5. ★ **(2)** Predecir cuántas respuestas, nodos y ramas cortadas da
   `arbol_sld/5` con la consulta `[abuelo(A, luis)]` y cada regla de
   selección, y comprobarlo. ¿Cuál de las dos reglas conviene para esa
   consulta, y qué orden de los objetivos de `abuelo/2` daría a Prolog el
   mismo árbol?
6. **(2)** Escribir `refutacion_de(Seleccion, Clausulas, Metas, Limite,
   Resolventes)`: la lista de los resolventes de cada refutación de Metas de
   largo Limite o menor, uno por paso, empezando por Metas; y
   `refutacion/5`, que recibe el nombre del programa.
7. ★ **(2)** Escribir la compleción de `gana/2` y de `mueve/3`, del
   programa `juego`, y compararla con la de `complecion/3`. Explicar por
   qué la compleción de `gana/2` no decide `gana(j2, a)`, y por qué la de
   `r/0` no tiene ningún modelo.
8. **(1)** Escribir `mostrar_complecion(Programa)`, que escribe la
   compleción de cada predicado de un programa de `sld.pl`, uno por línea.
9. ★ **(2)** Determinar a mano si cada programa es estratificado y, si lo
   es, sus estratos; comprobarlo con `estratos_de/2` y
   `ciclos_negativos_de/2`, que reciben la lista de cláusulas:
   (a) `a :- \+ b.` `b :- c.` `c :- \+ d.` (b) `a :- b, \+ c.`
   `c :- \+ a.` (c) `a :- \+ b.` `b :- a.`
10. **(2)** El programa `par(N) :- sigue(M, N), \+ par(M).` con los hechos
    `sigue(0, 1)`, `sigue(1, 2)`, …, `sigue(5, 6)` y `par(0)` no es
    estratificado. Calcular su modelo bien fundado, y explicar por qué es
    total aunque `par/1` dependa de su propia negación.
11. **(2)** Escribir `alternancia_de(Clausulas, Pasos)`, que da la sucesión
    de pares $V_i$-$P_i$ del punto fijo alternado, y `alternancia/2`, que
    recibe el nombre del programa, y seguirla con el juego j2:
    en qué paso se sabe que c gana, y en cuál que d pierde.
12. **(3)** Un modelo M es **estable** si M es igual al modelo reducido del
    programa con las negaciones evaluadas contra M, `reducido(Cs, M, M)`.
    Escribir `estables_de(Clausulas, Modelos)`, que prueba como candidatos
    los subconjuntos de lo posible, `reducido(Cs, [], P)`, y `estables/2`,
    que recibe el nombre del programa. ¿Cuántos modelos
    estables tienen `p :- \+ q.` `q :- \+ p.`, el programa `circular` y el
    juego j2?
13. **(2)** Escribir el programa `alcanza(Y)`, los nodos alcanzables desde
    0 en la fila del programa `cadena(N)`, y comparar el costo de su
    evaluación semi-ingenua con la de `camino/2` para 40 arcos. ¿Qué parte del modelo
    de `camino/2` hacía falta para responder `camino(0, Y)`?
14. **(3)** Escribir `semi_ingenua_estricta_de/4`, y su forma por nombre
    `semi_ingenua_estricta/4`, que en cada paso evalúa los
    literales anteriores al nuevo con la interpretación del paso anterior, y
    los posteriores con la actual, de modo que ninguna derivación se cuente
    dos veces. Compararla con `semi_ingenua/4` en un programa donde una
    cláusula tiene dos literales recursivos:
    `camino(X, Y) :- camino(X, Z), camino(Z, Y).`
15. ★ **(2)** Agregar a la versión `puede_volar` de la base r14, `si
    mamifero y no carnivoro entonces herbivoro`, y r15, `si herbivoro y
    no tiene_cascos entonces carnivoro`. Decidir si la base sigue siendo
    estratificada, dar los ciclos negativos, y calcular con `valor/3` los
    valores de `carnivoro` y de `herbivoro` cuando la única observación es
    `tiene_pelo`. Proponer una corrección.

## Resumen

| | |
|---|---|
| **base de Herbrand** | los átomos sin variables que se construyen con los símbolos del programa |
| **modelo** | una interpretación que hace verdadera cada instancia de cada cláusula |
| **modelo mínimo** | la intersección de los modelos de un programa definido: sus consecuencias lógicas |
| **forma clausal** | toda fórmula se escribe como conjunción de cláusulas; las de Horn con conclusión tienen modelo mínimo |
| **resolución SLD** | regla de selección, cláusula renombrada, unificador más general; correcta, completa, independiente de la regla |
| **compleción de Clark** | cada predicado definido con «si y solo si»; justifica la negación como falla finita |
| **SLDNF** | SLD con negación como falla; un literal negado se elige solo sin variables |
| **estratificación** | ningún ciclo de dependencias pasa por una negación; el modelo estándar se calcula por estratos |
| **semántica bien fundada** | tres valores; coincide con el modelo mínimo y con el estándar donde existen |
| **$T_P$** | el operador de consecuencia inmediata; su menor punto fijo es el modelo mínimo |
| **evaluación semi-ingenua** | cada paso usa al menos un átomo nuevo del paso anterior |
| `clausulas/2` | las cláusulas de un programa por su nombre: de `programa/2`, leídas con `clause/2`, o de `generado/2` |
| `generado/2` | los programas construidos como datos, como `cadena(N)`; `multifile`, para que otros archivos agreguen los suyos |
| `modelo_minimo/2` y `modelo_minimo_de/2` | las dos formas de cada evaluador: la primera recibe el nombre del programa, la terminada en `_de` la lista de sus cláusulas |
| `es_modelo/2`, `consecuencias/3`, `modelo_minimo/2` | verificar un modelo, aplicar $T_P$, calcular el modelo mínimo |
| `consecuencia/2` | los átomos del modelo mínimo, uno por respuesta |
| `ingenua/4`, `semi_ingenua/4` | las dos evaluaciones, con su costo en pasos y derivaciones |
| `estratos/2`, `ciclos_negativos/2`, `modelo_estandar/2` | los estratos, los ciclos que los impiden y el modelo estándar |
| `bien_fundado/3`, `valor/3` | el modelo bien fundado y el valor de un átomo en él |
| `paso/4`, `arbol_sld/5` | un paso SLD y el árbol SLD con una regla de selección |
| `sldnf/2`, `complecion/3` | la resolución SLDNF con la regla segura, y la definición completada |
| `unify_with_occurs_check/2` | la unificación con verificación de ocurrencia |
| `ord_subset/2` | un conjunto ordenado está contenido en otro; en las soluciones, para elegir los modelos minimales |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La semántica bien fundada en SWI-Prolog: `tnot/1` y las respuestas indefinidas | [capítulo 39](../capitulo-39-tabulacion/index.md) |
| El intérprete del sistema experto con tablas, donde los ciclos positivos terminan | [capítulo 39](../capitulo-39-tabulacion/index.md) |
| La resolución general, sobre cláusulas que no son de Horn | [capítulo 62](../capitulo-62-proyecto-demostrador-teoremas/index.md) |
| Las reglas con excepciones, como razonamiento rebatible | [capítulo 65](../capitulo-65-proyecto-razonamiento-rebatible/index.md) |
| Un motor Datalog con evaluación semi-ingenua y transformación mágica | [capítulo 85](../capitulo-85-proyecto-motor-datalog/index.md) |
| `WITH RECURSIVE`, la evaluación semi-ingenua de SQL | [capítulo 42](../capitulo-42-prolog-y-sql/index.md) |

## Referencias

- Ulf Nilsson y Jan Małuszyński, *Logic, Programming and Prolog*, 2.ª
  edición, John Wiley & Sons, 1995 — capítulo «Definite Logic Programs»
  (apartados «The Least Herbrand Model» y «Construction of Least Herbrand
  Models»), capítulo «SLD-Resolution» (apartados «Soundness of
  SLD-resolution» y «Completeness of SLD-resolution»), capítulo «Negation
  in Logic Programming» (apartados «The Completed Program»,
  «SLDNF-resolution for Definite Programs», «General Logic Programs» y
  «Well-founded Semantics») y capítulo «Query-answering in Deductive
  Databases» (apartados «Semi-naive Evaluation» y «Magic Transformation»).
  [Edición en línea de los autores](https://www.ida.liu.se/~ulfni53/lpp/).
  El capítulo toma de allí el orden de la exposición, los enunciados de los
  teoremas que cita sin demostrar, el juego de las posiciones ganadoras y
  las evaluaciones ingenua y semi-ingenua.
- Michael Spivey, *An Introduction to Logic Programming through Prolog*,
  Prentice Hall, 1996 — apartado «Completeness» del capítulo «Inference
  rules», y apartado «Semantics of negation» del capítulo «Negation as
  failure».
  [Edición del autor](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf).
  De allí vienen la lectura del supuesto de mundo cerrado como la elección
  del modelo mínimo y la construcción del modelo de un programa
  estratificado capa por capa.
- Peter Flach, *Simply Logical: Intelligent Reasoning by Example*, John
  Wiley & Sons, 1994 — apartados «The relation between clausal logic and
  Predicate Logic»
  ([en línea](https://book.simply-logical.space/src/text/1_part_i/2.5.html)),
  «Forward chaining»
  ([en línea](https://book.simply-logical.space/src/text/2_part_ii/5.4.html)),
  «Default reasoning»
  ([en línea](https://book.simply-logical.space/src/text/3_part_iii/8.1.html))
  y «The semantics of incomplete information»
  ([en línea](https://book.simply-logical.space/src/text/3_part_iii/8.2.html)).
  El capítulo toma los pasos de la forma clausal, el evaluador de abajo
  hacia arriba que construye modelos y la lectura de una regla con
  excepciones como razonamiento por defecto.
- James L. Hein, *Prolog Experiments in Discrete Mathematics, Logic, and
  Computability*, Portland State University, 2009 — apartado «The
  Immediate Consequence Operator» del capítulo «Logic Programming
  Theory». Es la presentación de $T_P$ y de su sucesión desde la
  interpretación vacía que sigue la [sección 38.6](#386-evaluacion-de-abajo-hacia-arriba).
- Los artículos originales que el capítulo nombra, citados a través de los
  libros anteriores: Maarten van Emden y Robert Kowalski, «The semantics
  of predicate logic as a programming language», *Journal of the ACM*
  23(4), 1976 ($T_P$ y el menor punto fijo); Keith Clark, «Negation as
  failure», en *Logic and Data Bases*, Plenum Press, 1978 (la compleción);
  Hisao Tamaki y Taisuke Sato, «Unfold/fold transformation of logic
  programs», 1984 (la condición del plegado); Krzysztof Apt, Howard Blair
  y Adrian Walker, «Towards a theory of declarative knowledge», 1988, y
  Allen Van Gelder, «Negation as failure using tight derivations for
  general logic programs», 1988 (la estratificación); Michael Gelfond y
  Vladimir Lifschitz, «The stable model semantics for logic programming»,
  1988 (los modelos estables); y Allen Van Gelder, Kenneth Ross y John
  Schlipf, «The well-founded semantics for general logic programs»,
  *Journal of the ACM* 38(3), 1991 (la semántica bien fundada).

Los programas del capítulo son propios, escritos para el curso: las
fuentes aportan las definiciones, los teoremas y los ejemplos, como el
juego de Nilsson y Małuszyński, pero no código; los evaluadores sobre
listas de cláusulas, el punto fijo alternado con `reducido/3`, el conteo de
derivaciones y el verificador de estratos por rondas son del curso.
