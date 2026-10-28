# Capítulo 52 — Proyecto: autómatas y expresiones regulares

Un autómata finito es una quíntupla M = (Q, Σ, δ, q₀, F): un conjunto finito
de estados, un alfabeto, una función (o relación) de transición, un estado
inicial y un conjunto de estados finales. Cada componente es una relación
finita, y en Prolog se escribe con hechos. Sobre esa descripción, un
programa corto decide si una palabra pertenece al lenguaje del autómata, y
otros programas, igual de cortos, construyen autómatas nuevos a partir de
otros: el determinista equivalente, el complemento, la intersección, el
mínimo, el autómata de una expresión regular. Con esas piezas se deciden
preguntas sobre lenguajes infinitos —si dos expresiones describen el mismo
lenguaje, y si no, cuál es la palabra más corta que las distingue— y se
escribe un analizador léxico.

El proyecto crece en ocho versiones. La primera escribe los autómatas como
hechos y los ejecuta con un intérprete de tres cláusulas; la segunda los
convierte en un módulo, con la clausura ε tabulada; la tercera y la cuarta
construyen el determinista, el complemento, la intersección y el mínimo; la
quinta traduce expresiones regulares a autómatas, y autómatas a
expresiones; la sexta es un analizador léxico; la séptima agrega los
transductores, autómatas que escriben mientras leen, con las máquinas de
Mealy y de Moore, y la octava los autómatas de pila, las máquinas de
Turing de una y de varias cintas, y dos modelos que reescriben palabras:
los algoritmos de Markov y los sistemas de Post.
El programa terminado carga los módulos:

<!-- ejemplo: capitulo-52/proyecto.pl archivo -->
```prolog
:- use_module(lexico).
:- use_module(secuencial).
```

```prolog
?- acepta(er("(a|b)*abb"), [a, b, a, b, b]).
true.

?- numero_estados(er("(a|b)*abb"), N1), numero_estados(det(er("(a|b)*abb")), N2), numero_estados(min(er("(a|b)*abb")), N3).
N1 = 20,
N2 = 5,
N3 = 4.

?- contraejemplo(er("(ab)*"), er("a*b*"), W).
W = [a].

?- transducir(plural, W, [l, u, c, e, s]).
W = [l, u, z] ;
W = [l, u, c, e] ;
W = [l, u, c].
```

La primera consulta verifica que abab**b** termina en abb. La segunda
cuenta los estados de tres autómatas del mismo lenguaje: el que la
construcción de Thompson obtiene de la expresión, el determinista que se
obtiene de él y el mínimo. La tercera encuentra la palabra más corta que una
expresión acepta y la otra no: a está en el lenguaje de a\*b\* y no en el de
(ab)\*. La cuarta usa un transductor de `transductores.pl` en sentido inverso: las palabras cuyo
plural se escribe *luces* son *luz* y, para la ortografía sola, *luce* y
*luc*.

![Autómata con transiciones ε construido por fragmentos: un estado inicial q y uno final f; arriba, un fragmento que pasa sin leer nada; abajo, el fragmento de a*, con un ciclo que lee a, seguido del fragmento que lee b; cada fragmento está rodeado por una elipse de color](thompson.png){ style="background-color: white" }

El autómata de la expresión (ε|a\*b) por la construcción de Thompson: cada
subexpresión es un fragmento, marcado con una elipse, con un estado de
entrada y uno de salida, y los fragmentos se unen con transiciones ε. Es
la construcción que las consultas anteriores aplican a (a|b)\*abb, y la
que da sus 20 estados. Imagen: Arthur Milchior,
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/), vía
[Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Small-thompson-example.svg).

El proyecto parte de dos libros. De *Programming in Tabled Prolog* de David
S. Warren ([copia de archivo de la página del autor](https://web.archive.org/web/20240628211257/https://www3.cs.stonybrook.edu/~warren/xsbbook/book.html)),
del capítulo «Automata Theory in XSB», toma la representación de
un autómata con relaciones que llevan su nombre como primer argumento, las
construcciones escritas como reglas sobre nombres compuestos —el
determinista de M se llama `det(M)` y sus transiciones se definen con
reglas—, la aceptación y la clausura ε con tabulación, la construcción de
subconjuntos limitada a los estados alcanzables, el complemento, la
minimización por estados distinguibles y el esbozo de la conversión de un
autómata en una expresión regular, que el capítulo completa; el programa
de Warren está escrito para XSB, y aquí se reescribe con la tabulación de SWI-Prolog del
[capítulo 40](../capitulo-40-tabulacion/index.md). De *Prolog Experiments in
Discrete Mathematics, Logic, and Computability* de James L. Hein ([edición en línea](https://samples.jbpub.com/9780763772062/PrologLabBook09.pdf)), del
capítulo «Computability» y de los apartados «Lambda Closure» y
«Transforming an NFA into a DFA», toma los intérpretes de autómatas finitos,
de máquinas de Mealy y de Moore, de autómatas de pila y de máquinas de
Turing, de algoritmos de Markov y de sistemas de Post, dos experimentos
que propone (la aceptación por pila vacía y las máquinas de varias
cintas), y el cálculo de la clausura λ como paso de la conversión. El código, los
autómatas de ejemplo y el texto son propios. Dos observaciones del capítulo
son sobre esos programas: la clausura de Hein no termina si las
transiciones λ forman un ciclo, y la construcción de Warren que nombra los
estados por la subexpresión confunde dos subexpresiones iguales
([sección 52.5](expresiones.md#525-expresiones-regulares)).

El capítulo usa las gramáticas del
[capítulo 22](../capitulo-22-gramaticas-dcg/index.md) para leer expresiones
regulares, los conjuntos ordenados del
[capítulo 23](../capitulo-23-estructuras-de-datos-de-la-biblioteca/index.md),
la idea de intérprete del
[capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md) y la
tabulación del [capítulo 40](../capitulo-40-tabulacion/index.md), cuyo anuncio
cumple: la clausura ε de un autómata, tabulada. Cumple también el del
[capítulo 49](../capitulo-49-proyecto-circuitos-logicos/index.md): un
circuito secuencial es un autómata finito, y la
[sección 52.7](transductores.md#527-transductores) carga sus módulos para ejecutarlo como
una máquina de Mealy. El analizador léxico produce los mismos componentes
que el del compilador del
[capítulo 46](../capitulo-46-proyecto-compilador/index.md). La notación es la
de un curso de autómatas y lenguajes formales; el capítulo no demuestra los
teoremas que usa, y los enuncia cuando los necesita. La primera versión y,
de la octava, `maquinas.pl` y `reescritura.pl` corren en SWISH; las demás
son módulos o cargan otros archivos, y se ejecutan localmente.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- escribir un autómata finito, determinista o no, como un conjunto de
  hechos, y ejecutarlo con un intérprete que decide si acepta una palabra y
  que genera las palabras que acepta;
- calcular la clausura ε con una relación tabulada, que termina aunque las
  transiciones ε formen ciclos;
- definir construcciones sobre autómatas como nombres compuestos cuyas
  transiciones se calculan con reglas: el determinista por la construcción
  de subconjuntos, el complemento, la intersección, la unión y el mínimo;
- decidir la inclusión y la equivalencia de dos lenguajes regulares, y
  obtener la palabra más corta que los distingue;
- traducir una expresión regular a un autómata con una gramática y con la
  construcción de Thompson, y usarla en un analizador léxico con la regla
  de la coincidencia más larga;
- describir transductores y máquinas de Mealy con pares de palabras, y
  consultarlos en los dos sentidos, y convertir una máquina de Moore en una
  de Mealy;
- obtener la expresión regular de un autómata con una relación tabulada;
- ejecutar autómatas de pila, con las dos maneras de aceptar, y máquinas de
  Turing de una y de varias cintas, y reconocer qué lenguajes separan a
  cada modelo del anterior;
- ejecutar algoritmos de Markov y sistemas de Post, dos modelos de cómputo
  que reescriben palabras.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **3:50 h**.
    Resolver los 7 ejercicios marcados con ★: **1:55 h**.
    Resolver los 16 ejercicios del capítulo: **5:15 h**.

## 52.1 Autómatas finitos como hechos

`finitos.pl` describe cada componente de la quíntupla con una relación cuyo
primer argumento es el nombre del autómata: `inicial(M, Q0)`, `final(M, Q)`,
`delta(M, Q, S, Q1)` para las transiciones con un símbolo, y
`epsilon(M, Q, Q1)` para las que no leen nada. El nombre permite describir
varios autómatas en el mismo programa. Una palabra es una lista de símbolos.

El primer autómata es determinista: lee un número binario, el bit más
significativo primero, y acepta los múltiplos de 3. Cada estado es el resto
de dividir por 3 el número leído hasta ese momento; leer el bit B desde el
resto R lleva al resto de 2R + B.

```mermaid
flowchart LR
    ini@{ shape: sm-circ } --> r0
    r0(((r0))) -- "0" --> r0
    r0 -- "1" --> r1((r1))
    r1 -- "1" --> r0
    r1 -- "0" --> r2((r2))
    r2 -- "0" --> r1
    r2 -- "1" --> r2
```

<!-- ejemplo: capitulo-52/finitos.pl fragmento: delta(multiplo3, r0, 0, r0). .. delta(multiplo3, r2, 1, r2). -->
```prolog
delta(multiplo3, r0, 0, r0).
delta(multiplo3, r0, 1, r1).
delta(multiplo3, r1, 0, r2).
delta(multiplo3, r1, 1, r0).
delta(multiplo3, r2, 0, r1).
delta(multiplo3, r2, 1, r2).
```

El intérprete recorre la palabra: con la lista vacía, el estado tiene que
ser final; con un símbolo, sigue una transición y lee el resto; una
transición ε cambia de estado sin consumir nada.

<!-- ejemplo: capitulo-52/finitos.pl predicado: acepta/2 lee/3 -->
```prolog
%!  acepta(+M, ?W:list) is nondet.
%
%   El autómata M acepta la palabra W: hay un camino desde el estado
%   inicial hasta uno final que lee W. Da una respuesta por camino, y no
%   termina si M tiene un ciclo de transiciones ε.
acepta(M, W) :-
    inicial(M, Q0),
    lee(M, Q0, W).

%!  lee(+M, +Q, ?W:list) is nondet.
%
%   Desde el estado Q, el autómata M lee W y termina en un estado final.
lee(M, Q, []) :-
    final(M, Q).
lee(M, Q, [S|W]) :-
    delta(M, Q, S, Q1),
    lee(M, Q1, W).
lee(M, Q, W) :-
    epsilon(M, Q, Q1),
    lee(M, Q1, W).
```

```prolog
?- acepta(multiplo3, [1, 1, 0]).
true ;
false.

?- acepta(multiplo3, [1, 1, 1]).
false.

?- length(W, 3), acepta(multiplo3, W).
W = [0, 0, 0] ;
W = [0, 1, 1] ;
W = [1, 1, 0] ;
false.
```

6 es múltiplo de 3 y 7 no lo es. La tercera consulta usa el mismo
intérprete para generar: las palabras de tres bits que el autómata acepta
son 0, 3 y 6. Con la longitud libre, `acepta(multiplo3, W)` no daría las
palabras en orden de longitud, porque la búsqueda en profundidad seguiría
sin fin la primera rama; fijar la longitud con `length/2` antes, como en la
profundización iterativa del
[capítulo 34](../capitulo-34-introspeccion-y-metainterpretes/index.md#345-limites-de-profundidad-y-profundizacion-iterativa),
da una búsqueda que avanza por longitudes.

El segundo autómata no es determinista: acepta las palabras sobre {a, b} que
terminan en ab. En q0, al leer una a, tiene dos transiciones: quedarse en
q0 o apostar a que esa a es la penúltima letra. Prolog no necesita que el
autómata sea determinista: prueba una alternativa y, si no lleva a un
estado final, retrocede y prueba la otra. La palabra se acepta si **algún**
camino lleva a un estado final.

```mermaid
flowchart LR
    ini@{ shape: sm-circ } --> q0
    q0((q0)) -- "a, b" --> q0
    q0 -- "a" --> q1((q1))
    q1 -- "b" --> q2(((q2)))
```

```prolog
?- acepta(termina_ab, [a, b, a, b]).
true ;
false.
```

El tercer autómata, `ciclo`, acepta a\*b, y tiene dos estados unidos por
transiciones ε en los dos sentidos, s0 → s1 y s1 → s0. Un ciclo así es
inofensivo para el lenguaje, y aparece en los autómatas que se construyen
a partir de expresiones como (a\*)\*; para el intérprete no lo es. Para
rechazar la palabra a, el intérprete prueba todos los caminos, y el ciclo
ε da infinitos:

```prolog
?- call_with_inference_limit(acepta(ciclo, [a]), 100000, R).
R = inference_limit_exceeded.

?- aggregate_all(count, limit(5, acepta(ciclo, [a, b])), N).
N = 5.
```

La primera consulta agota el límite de inferencias sin decidir nada; la
segunda muestra que una palabra aceptada tiene infinitas demostraciones,
una por cada vuelta al ciclo. El intérprete de Hein para autómatas no
deterministas tiene la misma forma y el mismo límite, que el libro
advierte en sus experimentos.

!!! question "Actividad"
    Predecir, sin ejecutarlas, cuántas respuestas dan
    `acepta(termina_ab, [a, a, b])`, `length(W, 2), acepta(termina_ab, W)`
    y `acepta(ciclo, [b])` —esta con `limit(3, …)`—, y cuál de ellas no
    terminaría sin el límite. Comprobarlo.

## 52.2 La clausura ε, tabulada

`automatas.pl` es un módulo con las mismas relaciones y un alfabeto
explícito, `alfabeto(M, Sigma)`, que el complemento necesitará: el lenguaje
complementario depende del alfabeto sobre el que se lo toma. Las cinco
relaciones están declaradas `multifile`, como `circuito/3` en el
[capítulo 49](../capitulo-49-proyecto-circuitos-logicos/index.md#492-el-circuito-como-dato):
otros archivos agregan autómatas con cláusulas `automatas:delta(…)`.

El problema de la versión 1 es la relación «se llega de Q0 a Q con cero o
más transiciones ε», la **clausura ε**: es la clausura reflexiva y
transitiva de un grafo que puede tener ciclos. Es el camino del
[capítulo 40](../capitulo-40-tabulacion/index.md#401-table-recursion-a-la-izquierda-y-ciclos),
y tiene la misma solución:

<!-- ejemplo: capitulo-52/automatas.pl fragmento: :- table clausura/3. .. epsilon(M, Q1, Q). -->
```prolog
:- table clausura/3.

%!  clausura(+M, +Q0, ?Q) is nondet.
%
%   Q está en la clausura ε de Q0 en el autómata M: se llega de Q0 a Q con
%   cero o más transiciones ε. Tabulada: cada estado aparece una vez, y la
%   consulta termina aunque las transiciones ε formen un ciclo.
clausura(_M, Q, Q).
clausura(M, Q0, Q) :-
    clausura(M, Q0, Q1),
    epsilon(M, Q1, Q).
```

```prolog
?- clausura(ciclo, s0, Q).
Q = s1 ;
Q = s0.
```

La tabla termina con los dos estados, cada uno una vez; el orden es el de
la tabla y puede cambiar de un proceso a otro, por eso las pruebas comparan
las respuestas ordenadas. La clausura de Hein, en «Lambda Closure», calcula
lo mismo con una relación de alcance por transiciones λ sin tabla, y no
termina con un ciclo como el de `ciclo`.

Con la clausura, el autómata ya no necesita probar caminos uno por uno. Se
puede llevar, al leer la palabra, el **conjunto** de estados en los que el
autómata puede estar: el inicial con su clausura, y después de cada
símbolo, los estados a los que se llega desde alguno del conjunto, con su
clausura.

<!-- ejemplo: capitulo-52/automatas.pl predicado: clausura_conjunto/3 mover/4 acepta/2 -->
```prolog
%!  clausura_conjunto(+M, +Qs:list, -D:list) is det.
%
%   D es la clausura ε del conjunto de estados Qs, como lista ordenada.
clausura_conjunto(M, Qs, D) :-
    findall(Q, ( member(Q0, Qs), clausura(M, Q0, Q) ), Todos),
    sort(Todos, D).

%!  mover(+M, +S, +D:list, -D1:list) is det.
%
%   D1 es el conjunto de estados al que M llega desde alguno de los
%   estados de D leyendo S, con su clausura ε. Si ninguno tiene una
%   transición con S, D1 es el conjunto vacío. Los argumentos siguen el
%   orden de foldl/4: el símbolo, el conjunto anterior y el siguiente.
mover(M, S, D, D1) :-
    findall(Q1, ( member(Q, D), delta(M, Q, S, Q1) ), Qs),
    clausura_conjunto(M, Qs, D1).

%!  acepta(+M, +W:list) is semidet.
%
%   El autómata M acepta la palabra W. Recorre W una vez, llevando el
%   conjunto de estados en los que M puede estar.
acepta(M, W) :-
    inicial(M, Q0),
    clausura_conjunto(M, [Q0], D0),
    foldl(mover(M), W, D0, D),
    member(Q, D),
    final(M, Q),
    !.
```

```prolog
?- acepta(ciclo, [a, a, b]).
true.

?- acepta(ciclo, [a]).
false.

?- mover(termina_ab, a, [q0], D).
D = [q0, q1].
```

`acepta/2` recorre la palabra una sola vez con `foldl/4`, y responde sin
alternativas pendientes; el ciclo ε ya no afecta. Para generar, el módulo
conserva la lectura relacional, `reconoce/2`, con la clausura tabulada
entre dos símbolos, y `palabras/3`, que reúne las palabras de una longitud
dada:

```prolog
?- reconoce(ciclo, [a, b]).
true ;
false.

?- palabras(termina_ab, 3, Ws).
Ws = [[a, a, b], [b, a, b]].
```

Una sola demostración de ab, donde la versión 1 daba infinitas. El módulo
termina con dos herramientas que las versiones siguientes usan todo el
tiempo. `alcanzable/2`, tabulada, da los estados a los que se llega desde el
inicial, con cualquier transición; `tabla/2` numera esos estados en el
orden de un recorrido en anchura, el inicial primero, y da el autómata como
`automata(N, Finales, Transiciones)`, una forma legible cuando los estados
son términos grandes:

```prolog
?- estados(ciclo, Qs).
Qs = [s0, s1, s2].

?- tabla(multiplo3, T).
T = automata(3, [0], [0-0-0, 0-1-1, 1-0-2, 1-1-0, 2-0-1, 2-1-2]).
```

## 52.3 Construcciones: el determinista, el complemento, la intersección

`mover/4` es, sin nombrarla, la **construcción de subconjuntos** de Rabin
y Scott (1959): el
autómata determinista equivalente a M tiene por estados los conjuntos de
estados de M cerrados por ε, y su transición con S es `mover/4`. Warren la
escribe como otro autómata, con un nombre compuesto: `det(M)`. Sus
relaciones no son hechos, sino reglas que las calculan a partir de las de
M. `construcciones.pl` las agrega a las relaciones multifile del módulo
`automatas`:

<!-- ejemplo: capitulo-52/construcciones.pl fragmento: automatas:alfabeto(det(M), Sigma) :- .. mover(M, S, D, D1). -->
```prolog
automatas:alfabeto(det(M), Sigma) :-
    alfabeto(M, Sigma).
automatas:inicial(det(M), D0) :-
    inicial(M, Q0),
    clausura_conjunto(M, [Q0], D0).
automatas:final(det(M), D) :-
    alcanzable(det(M), D),
    once(( member(Q, D), final(M, Q) )).
automatas:delta(det(M), D, S, D1) :-
    alfabeto(M, Sigma),
    member(S, Sigma),
    mover(M, S, D, D1).
```

Los estados de `det(M)` no se enumeran de antemano: son los que
`alcanzable/2` encuentra desde el inicial, y un estado final es uno que
contiene un final de M. Como `det(M)` es un autómata más, todo lo que se
define para autómatas se aplica a él:

```prolog
?- delta(det(termina_ab), [q0, q1], S, D).
S = a,
D = [q0, q1] ;
S = b,
D = [q0, q2].

?- tabla(det(termina_ab), T).
T = automata(3, [2], [0-a-1, 0-b-0, 1-a-1, 1-b-2, 2-a-1, 2-b-0]).

?- estados(det(ciclo), Ds).
Ds = [[], [s0, s1], [s2]].
```

```mermaid
flowchart LR
    ini@{ shape: sm-circ } --> d0
    d0(("{q0}")) -- "b" --> d0
    d0 -- "a" --> d1(("{q0, q1}"))
    d1 -- "a" --> d1
    d1 -- "b" --> d2((("{q0, q2}")))
    d2 -- "a" --> d1
    d2 -- "b" --> d0
```

En el determinista de `termina_ab` cada conjunto recuerda lo último que se
leyó: nada útil, una a, o ab. El de `ciclo` muestra el **conjunto vacío**
como un estado más: es aquel al que se llega cuando ningún estado tiene una
transición con el símbolo leído, y de él no se sale. Es el estado
**sumidero**, y gracias a él `det(M)` es **completo**: tiene una transición
para cada estado y cada símbolo del alfabeto. Warren agrega el sumidero con
una construcción aparte; aquí aparece solo.

Un autómata determinista y completo acepta el **complemento** de su
lenguaje si se intercambian sus estados finales con los no finales: cada
palabra lleva a un único estado, y ese estado decide. Las dos condiciones
son necesarias: en un autómata no determinista una palabra puede llegar a un
estado final y a uno que no lo es, y en uno incompleto puede no llegar a
ninguno. `complemento(M)` se define entonces sobre `det(M)`, y solo cambia
`final/2`:

<!-- ejemplo: capitulo-52/construcciones.pl fragmento: automatas:final(complemento(M), D) :- .. \+ final(det(M), D). -->
```prolog
automatas:final(complemento(M), D) :-
    alcanzable(det(M), D),
    \+ final(det(M), D).
```

La **intersección** y la **unión** son el autómata producto: sus estados
son pares de estados de los deterministas de M1 y M2, cada componente
avanza en su autómata con el mismo símbolo, y un par es final si lo son
los dos componentes, para la intersección, o alguno, para la unión.
`termina_b`, en el mismo archivo, acepta las palabras que terminan en b:

```prolog
?- palabras(complemento(termina_b), 2, Ws).
Ws = [[a, a], [b, a]].

?- palabras(interseccion(termina_ab, termina_b), 2, Ws).
Ws = [[a, b]].
```

Con estas construcciones, preguntas sobre lenguajes infinitos se
convierten en preguntas sobre grafos finitos. Un autómata acepta alguna
palabra si alguno de sus estados alcanzables es final; L₁ ⊆ L₂ si la
intersección de L₁ con el complemento de L₂ es vacía; dos lenguajes son
iguales si cada uno está incluido en el otro. Y si no lo son, la palabra
más corta de la diferencia simétrica es un **contraejemplo**:

<!-- ejemplo: capitulo-52/construcciones.pl predicado: vacio/1 incluido/2 equivalentes/2 contraejemplo/3 -->
```prolog
%!  vacio(+M) is semidet.
%
%   M no acepta ninguna palabra: ningún estado alcanzable es final.
vacio(M) :-
    \+ ( alcanzable(M, Q),
         final(M, Q) ).

%!  incluido(+M1, +M2) is semidet.
%
%   Toda palabra que acepta M1 la acepta M2.
incluido(M1, M2) :-
    vacio(interseccion(M1, complemento(M2))).

%!  equivalentes(+M1, +M2) is semidet.
%
%   M1 y M2 aceptan el mismo lenguaje.
equivalentes(M1, M2) :-
    incluido(M1, M2),
    incluido(M2, M1).

%!  contraejemplo(+M1, +M2, -W:list) is semidet.
%
%   W es una de las palabras más cortas que acepta uno solo de M1 y M2.
%   Falla si son equivalentes.
contraejemplo(M1, M2, W) :-
    palabra_mas_corta(union(interseccion(M1, complemento(M2)),
                            interseccion(M2, complemento(M1))),
                      W).
```

```prolog
?- incluido(termina_ab, termina_b).
true.

?- incluido(termina_b, termina_ab).
false.

?- contraejemplo(termina_ab, termina_b, W).
W = [b].

?- equivalentes(ciclo, det(ciclo)).
true.
```

Las construcciones se componen sin límite de anidamiento:
`contraejemplo/3` busca la palabra más corta que acepta
`union(interseccion(M1, complemento(M2)), interseccion(M2, complemento(M1)))`,
un autómata que nunca se escribe como hechos. `palabra_mas_corta/2`
verifica primero con `vacio/1` que existe alguna, y después prueba las
longitudes 0, 1, 2…; sin esa verificación, la búsqueda de una palabra que
no existe no terminaría.

!!! question "Actividad"
    Predecir cuántos estados alcanzables tiene
    `interseccion(termina_ab, multiplo3)` y si su lenguaje es vacío: los dos
    autómatas tienen alfabetos distintos. Comprobarlo con `estados/2` y
    `vacio/1`, y explicar qué estados del producto contienen el conjunto
    vacío.

## 52.4 El autómata mínimo

Dos estados de un autómata determinista son **distinguibles** si alguna
palabra lleva a uno a un estado final y al otro a uno que no lo es. Los que
no son distinguibles aceptan las mismas palabras, y se pueden fundir en uno:
el resultado es el autómata determinista completo con menos estados que
acepta el mismo lenguaje, único salvo el nombre de los estados. La relación
se define, como en los experimentos de Moore (1956) sobre máquinas
secuenciales, por inducción sobre la palabra —la vacía distingue un final de un
no final, y un símbolo delante distingue dos estados si los lleva a dos
distinguibles—, y es otra relación recursiva sobre un grafo con ciclos.
`minimizar.pl` la tabula:

<!-- ejemplo: capitulo-52/minimizar.pl predicado: distinguible/3 predecesor/4 -->
```prolog
%!  distinguible(+A, ?P, ?Q) is nondet.
%
%   Los estados alcanzables P y Q del autómata determinista y completo A
%   son distinguibles: una palabra lleva a uno a un estado final y al otro
%   no. La primera cláusula es la palabra vacía; la segunda agrega un
%   símbolo delante de una palabra que distingue los estados siguientes.
distinguible(A, P, Q) :-
    alcanzable(A, P),
    alcanzable(A, Q),
    (   final(A, P)
    ->  \+ final(A, Q)
    ;   final(A, Q)
    ).
distinguible(A, P, Q) :-
    distinguible(A, P1, Q1),
    predecesor(A, P1, S, P),
    predecesor(A, Q1, S, Q).

%!  predecesor(+A, +P1, ?S, ?P) is nondet.
%
%   El autómata A pasa de P a P1 leyendo S, y P es alcanzable. Tabulada:
%   para cada P1, las transiciones que llegan a él se buscan una vez.
predecesor(A, P1, S, P) :-
    arcos(A, Arcos),
    member(P-S-P1, Arcos).
```

La segunda cláusula va **hacia atrás**: a partir de un par ya distinguido,
busca los pares que llegan a él con el mismo símbolo. `predecesor/4`,
tabulada, reúne una vez las transiciones que llegan a cada estado. La
primera forma que se escribe es la que va hacia adelante, que por cada par
nuevo recorre todas las transiciones de todos los estados; el archivo la
conserva como `distinguible_directo/3`. Sobre el determinista del registro
de desplazamiento de cuatro etapas del [capítulo 49](../capitulo-49-proyecto-circuitos-logicos/index.md), con 17 estados, las dos
calculan los 272 pares distinguibles, pero la directa necesita unos 60
millones de inferencias y 11 segundos, y la que usa los predecesores,
470 000 inferencias y 0,06 segundos.

`pares_a` acepta las palabras con una cantidad par de a, contando las a
módulo 4: e0 y e2 son equivalentes, y también e1 y e3. `min(M)` tiene por
estados las **clases** de estados indistinguibles del determinista de M:

<!-- ejemplo: capitulo-52/minimizar.pl fragmento: automatas:alfabeto(min(M), Sigma) :- .. clase(det(M), D1, C1). -->
```prolog
automatas:alfabeto(min(M), Sigma) :-
    alfabeto(M, Sigma).
automatas:inicial(min(M), C0) :-
    inicial(det(M), D0),
    clase(det(M), D0, C0).
automatas:final(min(M), C) :-
    alcanzable(min(M), C),
    C = [D|_],
    final(det(M), D).
automatas:delta(min(M), [D|_], S, C1) :-
    delta(det(M), D, S, D1),
    clase(det(M), D1, C1).
```

```prolog
?- distinguible(det(pares_a), [e0], [e2]).
false.

?- distinguibles(det(pares_a), [e1], [e2], W).
W = [].

?- estados(min(pares_a), Cs).
Cs = [[[e0], [e2]], [[e1], [e3]]].

?- tabla(min(pares_a), T).
T = automata(2, [0], [0-a-1, 0-b-0, 1-a-0, 1-b-1]).
```

`distinguibles/4` da, además, la palabra más corta que distingue dos
estados: e1 y e2 los distingue la palabra vacía, porque uno es final y el
otro no. El estado e4, que es final pero no alcanzable, no aparece: la
minimización trabaja sobre los estados alcanzables, y los demás no
cambian el lenguaje.

El capítulo continúa en la página
[Expresiones regulares y un analizador léxico](expresiones.md#525-expresiones-regulares),
con las expresiones regulares, que describen los mismos lenguajes que los
autómatas. Las páginas siguientes la continúan con los transductores y con
los autómatas de pila y las máquinas de Turing, hasta la
[sección 52.8](pila-y-turing.md#528-automatas-de-pila-y-maquinas-de-turing).
Antes, los [ejercicios](#ejercicios) de esta página practican
las secciones 52.1 a 52.4.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y el [capítulo 54](../capitulo-54-proyecto-morfologia-castellano/index.md)
los da por hechos.

1. ★ **(1)** Con `automatas.pl` y `construcciones.pl` cargados, predecir
   la respuesta de cada consulta, incluido si termina en `.` o en
   `false.`, y comprobarlo: `acepta(termina_ab, [])` ·
   `reconoce(termina_ab, [X, b])` · `estados(det(multiplo3), Ds)` ·
   `palabras(complemento(multiplo3), 2, Ws)` ·
   `incluido(det(termina_ab), termina_ab)`.
2. **(1)** Describir con hechos, en otro archivo, un autómata determinista
   `par_par` que acepte las palabras sobre {a, b} con una cantidad par de
   a y una cantidad par de b. Verificar con `palabras/3` las palabras de
   longitud 4, y con `equivalentes/2` que es la intersección de dos
   autómatas más chicos, uno para cada letra.
3. **(2)** El autómata no determinista que acepta las palabras sobre
   {a, b} cuya letra n-ésima desde el final es a tiene n + 1 estados.
   Escribir `enesima(N)` como un nombre de autómata definido con reglas, y
   tabular, para n de 1 a 6, la cantidad de estados de `det(enesima(N))`
   y de `min(enesima(N))`. Explicar el crecimiento.

## Referencias

- David S. Warren, *Programming in Tabled Prolog*, borrador distribuido
  con el sistema XSB, 1999 — «Automata Theory in XSB». [Copia de archivo de la página del autor](https://web.archive.org/web/20240628211257/https://www3.cs.stonybrook.edu/~warren/xsbbook/book.html). Esta página toma
  de allí ideas y la representación: los autómatas como relaciones con el
  nombre del autómata como primer argumento, las construcciones como
  reglas sobre nombres compuestos (el determinista, el complemento, el
  mínimo), la clausura ε y los estados alcanzables con tabulación, y la
  minimización por estados distinguibles; el código de XSB se reescribió
  para la tabulación de SWI-Prolog.
- James L. Hein, *Prolog Experiments in Discrete Mathematics, Logic, and
  Computability*, Jones and Bartlett, 2009 ([edición en línea](https://samples.jbpub.com/9780763772062/PrologLabBook09.pdf)) — «Computability» (autómatas
  finitos deterministas y no deterministas) y los apartados «Lambda
  Closure» y «Transforming an NFA into a DFA». Esta página toma de allí la
  forma del intérprete de los autómatas finitos, y la clausura λ como paso
  de la conversión, con otra representación y otros ejemplos.
- James L. Hein, *Discrete Structures, Logic, and Computability*, Jones
  and Bartlett, 3.ª edición, 2010 — los capítulos de lenguajes regulares y
  de autómatas. Es el libro de texto al que acompaña el de experimentos de
  Hein: allí está la conversión de un autómata no determinista en uno
  determinista que los experimentos programan. No tiene edición en línea
  gratuita.
- Michael O. Rabin y Dana Scott, «Finite automata and their decision
  problems», *IBM Journal of Research and Development* 3 (2), 1959,
  págs. 114–125. Introduce los autómatas no deterministas, la construcción
  de subconjuntos y la decisión del vacío y de la equivalencia, que la
  [sección 52.3](#523-construcciones-el-determinista-el-complemento-la-interseccion)
  programa. No tiene edición en línea gratuita.
- Edward F. Moore, «Gedanken-experiments on sequential machines», en
  *Automata Studies*, Princeton University Press, 1956. De Moore vienen los
  estados que ningún experimento distingue, en los que se basa la
  minimización de la [sección 52.4](#524-el-automata-minimo). No tiene
  edición en línea gratuita.
