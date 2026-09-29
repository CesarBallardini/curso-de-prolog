# Capítulo 34 — Estructuras incompletas y listas diferencia

Una estructura incompleta es un término que contiene variables libres en
lugares que se completan más tarde, por unificación. Los programas de las
partes I y II ya construyen estructuras así sin nombrarlas: `pegar/3` del
[capítulo 7](../capitulo-07-listas/index.md) arma su resultado como una lista cuyo resto todavía no se
conoce, y cada regla de una gramática del [capítulo 21](../capitulo-21-gramaticas-dcg/index.md) recibe una lista y
devuelve lo que sobra de ella. Este capítulo usa esas variables a propósito:
conservar a mano la variable del final de una lista permite agregar elementos
allí en un paso, y una tabla con el final abierto se consulta y se amplía con
la misma operación.

El capítulo sigue una escalera de versiones. Cada sección presenta un problema
resuelto con listas comunes, muestra el costo de esa versión, lo corrige con
una estructura incompleta y mide la diferencia con `time/1`. Las técnicas son
la lista abierta, la lista diferencia, la cola, el diccionario incompleto y la
traducción de las gramáticas; la última sección las combina en la tabla de
símbolos de un ensamblador, con las técnicas que el [capítulo 45](../capitulo-45-proyecto-compilador/index.md) usa en su compilador. El
capítulo cumple tres anuncios: las listas diferencia, que concatenan sin
recorrer, del [capítulo 7](../capitulo-07-listas/index.md); el agregado al final en un paso, del
[capítulo 16](../capitulo-16-rendimiento/index.md); y la técnica detrás de la traducción de las gramáticas, del
[capítulo 21](../capitulo-21-gramaticas-dcg/index.md). Sigue el capítulo «Difference Lists» de *Prolog Techniques*, de
Attila Csenki, y el apartado «Difference lists» de *An Introduction to Logic
Programming through Prolog*, de Michael Spivey; las demás fuentes están en
las [referencias](#referencias).

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- construir, completar y cerrar una lista abierta, y reconocer qué predicados
  de listas la extienden sin aviso;
- representar una lista como diferencia de dos listas, concatenar en una
  unificación y convertir un recorrido con `append/3` en uno lineal;
- reconocer los dos errores propios de las listas diferencia: usarlas dos
  veces y unificar sin verificación de ocurrencias;
- implementar una cola que agrega y quita en un paso, y usarla en un
  recorrido en anchura;
- escribir un diccionario incompleto, en una lista o en un árbol, cuyos
  valores se ligan cuando se conocen;
- leer la traducción de una gramática como un programa con listas
  diferencia, y medir cuánto se gana con cada técnica.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:25 h**.
    Resolver los 6 ejercicios marcados con ★: **1:36 h**.
    Resolver los 16 ejercicios del final: **5:03 h**.

## 34.1 Listas abiertas

Una lista **cerrada** termina en `[]`: `[a, b]` es `[a|[b|[]]]`. Una lista
**abierta** termina en una variable libre: `[a, b|F]` tiene dos elementos
conocidos y un resto desconocido. Unificar F con `[c|G]` agrega un elemento y
deja la lista abierta; unificarla con `[]` la cierra. En ningún caso se copia
la lista: la variable ya forma parte del término, y ligarla modifica todas las
estructuras que la contienen.

Para agregar al final hace falta llegar a esa variable. `agregar_al_final/2`
recorre los elementos conocidos hasta encontrarla con `var/1`, del
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md), y `cerrar/1` recorre la lista de la misma manera para ligarla a
`[]`:

<!-- ejemplo: capitulo-34/abiertas.pl predicado: agregar_al_final/2 cerrar/1 consulta: L = [a, b|_], agregar_al_final(L, c), agregar_al_final(L, d). -->
```prolog
%!  agregar_al_final(+Abierta:list, +X) is det.
%
%   Abierta es una lista abierta; su variable final queda ligada a [X|_], y
%   la lista sigue abierta. Recorre los elementos conocidos para llegar al
%   final.
agregar_al_final(Final, X) :-
    var(Final),
    !,
    Final = [X|_].
agregar_al_final([_|Resto], X) :-
    agregar_al_final(Resto, X).

%!  cerrar(+Abierta:list) is det.
%
%   Liga la variable final de la lista abierta Abierta a []: la lista queda
%   cerrada, con los elementos que tenía.
cerrar(Final) :-
    var(Final),
    !,
    Final = [].
cerrar([_|Resto]) :-
    cerrar(Resto).
```

```prolog
?- L = [a, b|_], agregar_al_final(L, c), agregar_al_final(L, d).
L = [a, b, c, d|_].

?- L = [a, b|_], agregar_al_final(L, c), cerrar(L).
L = [a, b, c].
```

La variable L no cambia de valor entre una llamada y otra: la lista a la que
L está ligada crece, porque la variable de su final queda ligada. Un predicado
que recorre una lista abierta tiene que detenerse en esa variable sin
ligarla. `conocidos/2`, en el mismo archivo, da los elementos presentes como
una lista cerrada y deja abierta la original.

Los predicados de listas de la biblioteca no hacen esa distinción. Para ellos,
el final libre es un resto que todavía puede ser cualquier lista, y lo ligan
como a cualquier variable. `member/2` encuentra un elemento que no está
agregándolo, y en cada nueva respuesta prueba con una lista más larga;
`length/2` genera las longitudes posibles:

```prolog
?- L = [a, b|_], member(c, L).
L = [a, b, c|_] ;
L = [a, b, _, c|_] ;
L = [a, b, _, _, c|_] ;
...

?- L = [a|T], length(L, N).
L = [a],
T = [],
N = 1 ;
L = [a, _A],
T = [_A],
N = 2 ;
...
```

`memberchk/2`, del [capítulo 15](../capitulo-15-control/index.md), toma la primera respuesta de `member/2`:
con una lista abierta, busca el elemento y, si no lo encuentra, lo agrega al
final. Es un comportamiento útil, y la [sección 34.4](#344-diccionarios-incompletos) lo convierte en un
diccionario; pero en una lista que debería estar cerrada, un `memberchk/2` que
agrega en lugar de fallar es un error difícil de rastrear.

!!! question "Actividad"
    Predecir el valor de L después de
    `L = [a|_], memberchk(b, L), memberchk(a, L), memberchk(c, L).`
    Comprobarlo, y explicar por qué `memberchk(a, L)` no agrega nada.

`agregar_al_final/2` evita la copia de `pegar/3`, pero no el recorrido: para
llegar al final pasa por todos los elementos, y agregar n elementos uno por uno
cuesta del orden de n² pasos. La sección siguiente guarda la variable del
final en otro lugar, para no tener que buscarla.

## 34.2 De `append/3` a la lista diferencia

El problema es aplanar un árbol binario: obtener la lista de sus elementos en
orden, primero los del subárbol izquierdo, después la raíz y después los del
derecho. Un árbol es `vacio` o `n(Izq, X, Der)`. La versión directa aplana los
dos subárboles y los une con `append/3`:

<!-- ejemplo: capitulo-34/diferencia.pl predicado: inorden_app/2 consulta: degenerado(3, A), inorden_app(A, L). -->
```prolog
%!  inorden_app(+Arbol, -Lista:list) is det.
%
%   Lista tiene los elementos de Arbol en orden: los del subárbol izquierdo,
%   la raíz y los del derecho. Arbol es vacio o n(Izq, X, Der). En cada nodo,
%   append/3 recorre la lista del subárbol izquierdo.
inorden_app(vacio, []).
inorden_app(n(Izq, X, Der), Lista) :-
    inorden_app(Izq, LI),
    inorden_app(Der, LD),
    append(LI, [X|LD], Lista).
```

`append(LI, [X|LD], Lista)` recorre LI entera para llegar a su final, como
`pegar/3`. Con un árbol equilibrado, cada elemento se recorre una vez por nivel
del árbol. Con el peor árbol, el que `degenerado/2` construye —cada nodo es el
hijo izquierdo del siguiente—, el `append/3` de la raíz recorre n − 1
elementos, el de su hijo n − 2, y así: en total, del orden de n²/2 pasos.

```text
?- degenerado(2000, A), time(inorden_app(A, _)).
% 2,031,720 inferences, 0.188 CPU in 0.187 seconds (100% CPU, 10835840 Lips)
```

La causa es que la lista de un subárbol se construye cerrada, y para
agregarle algo hay que buscar su final. Si cada llamada devolviera también la
variable del final de su lista, agregar sería ligarla. Un par `L-F`, en el que
F es la variable al final de L, representa la lista de los elementos de L que
están **antes** de F: `[a, b|F]-F` representa `[a, b]`. Es una **lista
diferencia**, porque los elementos que representa son los de L menos los de F.
`-` no calcula nada: es un functor como cualquier otro, elegido porque se lee
bien; `[a, b|F]-F` es el término `-([a, b|F], F)`.

Con esa representación, concatenar dos listas diferencia es una unificación:
si `L-M` representa la primera y `M-F` la segunda, `L-F` representa las dos
seguidas.

<!-- ejemplo: capitulo-34/diferencia.pl predicado: concatenar_dif/3 consulta: concatenar_dif([a, b|X]-X, [c|Y]-Y, L-[]). -->
```prolog
% concatenar_dif(A, B, C): C es la lista diferencia A seguida de B.
concatenar_dif(L-M, M-F, L-F).
```

```prolog
?- concatenar_dif([a, b|X]-X, [c|Y]-Y, L-[]).
X = [c],
Y = [],
L = [a, b, c].
```

La unificación de X con `[c|Y]` pega la segunda lista al final de la primera,
y la de Y con `[]` cierra el resultado. No hay recorrido: el costo es el mismo
con listas de dos elementos o de dos millones. El recorrido del árbol con
listas diferencia usa la misma idea sin llamar a `concatenar_dif/3`: la
lista del subárbol izquierdo termina en `[X|M]`, y M es el comienzo de la del
derecho.

<!-- ejemplo: capitulo-34/diferencia.pl predicado: inorden/2 inorden_dif/2 consulta: inorden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio)), L). -->
```prolog
%!  inorden(+Arbol, -Lista:list) is det.
%
%   La misma relación que inorden_app/2, con listas diferencia.
inorden(Arbol, Lista) :-
    inorden_dif(Arbol, Lista-[]).

%!  inorden_dif(+Arbol, ?Dif) is det.
%
%   Dif, un par L-F, es la lista diferencia de los elementos de Arbol en
%   orden: L tiene esos elementos seguidos de F.
inorden_dif(vacio, L-L).
inorden_dif(n(Izq, X, Der), L-F) :-
    inorden_dif(Izq, L-[X|M]),
    inorden_dif(Der, M-F).
```

```prolog
?- inorden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio)), L).
L = [1, 2, 3].
```

Un árbol vacío produce la lista diferencia vacía, `L-L`, cuyo comienzo ya es
su final. `inorden/2` cierra el resultado con `[]` una sola vez, en el borde.
Cada nodo cuesta una llamada, cualquiera sea la forma del árbol:

```text
?- degenerado(2000, A), time(inorden(A, _)).
% 4,001 inferences, 0.000 CPU in 0.001 seconds (0% CPU, Infinite Lips)
```

`invertir/2`, en el mismo archivo, invierte una lista con la misma técnica:
cada elemento va delante de lo que ya se invirtió, `L-[X|F]`. Es, argumento
por argumento, `dando_vuelta/3` de la [sección 16.6](../capitulo-16-rendimiento/index.md#166-append3-en-un-bucle): un acumulador es una
lista diferencia cuyo final se entrega al comenzar, en lugar de al terminar.

!!! question "Actividad"
    Construir un árbol degenerado hacia la **derecha**, en el que cada nodo
    es el hijo derecho del anterior, y predecir cuántas inferencias usa
    `inorden_app/2` con 2000 nodos. Comprobarlo con `time/1` y explicar la
    diferencia con el árbol de `degenerado/2`.

Una lista diferencia tiene dos usos incorrectos que ningún error señala. El
primero es **usarla dos veces**. Concatenar liga su final; una segunda
concatenación encuentra ese final ya ligado y falla:

```prolog
?- D = [a|X]-X, concatenar_dif(D, [b|Y]-Y, R1), concatenar_dif(D, [c|Z]-Z, R2).
false.
```

Una lista diferencia se consume al usarla: su final se liga una sola vez. Para
usarla dos veces hace falta copiarla antes con `copy_term/2`,
del [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md), y la copia recorre la lista.

El segundo uso incorrecto aparece al preguntar si una lista diferencia está
vacía. `vacia_dif(L-L)` se cumple con `[]-[]` y con `F-F`, pero también con
`[a|T]-T`: unificar T con `[a|T]` debería fallar, porque ningún término finito
es igual a una lista que lo contiene. Prolog no lo verifica: la unificación
de SWI-Prolog omite, por eficiencia, la **verificación de ocurrencias**, que
comprueba que una variable no aparezca dentro del término con el que se liga.
El resultado es un término **cíclico**, infinito:

```prolog
?- vacia_dif([a|T]-T).
T = [a|T].

?- unify_with_occurs_check([a|T]-T, L-L).
false.
```

`unify_with_occurs_check/2` unifica con la verificación, y
`cyclic_term/1` reconoce un término cíclico. La opción `occurs_check`, con
`set_prolog_flag/2`, activa la verificación en todas las unificaciones:
con el valor `true`, la unificación falla; con `error`, produce un error que
señala el punto donde se creó el ciclo, útil para depurar. La solución de
diseño es no depender de la prueba: la [sección 34.3](#343-colas) lleva la cantidad
de elementos junto a la lista diferencia, y pregunta por ella.

!!! example "Patrón 47 — Lista diferencia para agregar al final"
    **Problema.** Construir una lista agregando elementos al final, o
    concatenando resultados parciales, como al aplanar un árbol o al generar
    una salida por partes.

    **Versión ingenua.** Construir cada parte como lista cerrada y unirlas con
    `append/3`, que recorre la primera para llegar a su final: con n partes el
    costo puede llegar a n².

    **Patrón.** Pasar cada parte como un par `L-F`, con F la variable del
    final, o como dos argumentos separados. Concatenar es unificar el final de
    una con el comienzo de la siguiente, y el resultado se cierra con `[]` una
    sola vez, en el predicado de entrada. Cuando la construcción recorre una
    estructura, se escribe como gramática, que hace la misma traducción
    ([sección 34.5](#345-las-gramaticas-como-listas-diferencia)).

    **Cuándo no usarlo.** Cuando la lista se necesita dos veces o se examina
    su final: una lista diferencia se usa una vez, y una prueba de vacía sin
    verificación de ocurrencias crea términos cíclicos. En la interfaz de un
    predicado, una lista cerrada es más clara; la lista diferencia queda en
    los predicados auxiliares.

## 34.3 Colas

Una **cola** agrega por el final y quita por el principio: el primer elemento
que entra es el primero que sale. Con una lista cerrada, quitar es tomar la
cabeza, en un paso, pero agregar recorre la cola entera:

<!-- ejemplo: capitulo-34/cola.pl predicado: encolar_lista/3 consulta: encolar_lista(c, [a, b], C). -->
```prolog
%!  encolar_lista(+X, +Cola:list, -Cola1:list) is det.
%
%   Cola1 es la cola Cola, una lista cerrada, con X agregado al final.
encolar_lista(X, Cola, Cola1) :-
    append(Cola, [X], Cola1).
```

Con una lista diferencia `Frente-Fondo`, las dos operaciones son un paso:
encolar liga el fondo, desencolar toma la cabeza del frente.

<!-- ejemplo: capitulo-34/cola.pl predicado: encolar_dif/3 desencolar_dif/3 consulta: encolar_dif(a, F-F, C1), encolar_dif(b, C1, C2), desencolar_dif(X, C2, C3). -->
```prolog
% encolar_dif(X, C0, C): C es la cola diferencia C0 con X al final.
encolar_dif(X, Frente-[X|Fondo], Frente-Fondo).

% desencolar_dif(X, C0, C): X es el primero de la cola diferencia C0 y C el
% resto; también se cumple con una cola vacía.
desencolar_dif(X, [X|Frente]-Fondo, Frente-Fondo).
```

```prolog
?- encolar_dif(a, F-F, C1), encolar_dif(b, C1, C2), desencolar_dif(X, C2, C3).
F = [a, b|_A],
C1 = [a, b|_A]-[b|_A],
C2 = [a, b|_A]-_A,
X = a,
C3 = [b|_A]-_A.
```

La cola vacía es `F-F`, y ahí `desencolar_dif/3` tiene el defecto de la
sección anterior: desencolar de una cola vacía **se cumple**, porque unificar
el frente libre con `[X|Frente]` es tan posible como en una cola con
elementos. Queda una cola «con un elemento de menos», y el elemento quitado es
el que se encole después:

```prolog
?- C0 = F-F, desencolar_dif(X, C0, C1), encolar_dif(a, C1, C2).
C0 = [a|_A]-[a|_A],
F = [a|_A],
X = a,
C1 = _A-[a|_A],
C2 = _A-_A.
```

Distinguir la cola vacía por su forma exige la verificación de ocurrencias.
La solución es llevar la cantidad de elementos: `cola(N, Frente, Fondo)`.
Desencolar exige N mayor que cero, y la cola vacía se reconoce por el número,
sin comparar el frente con el fondo:

<!-- ejemplo: capitulo-34/cola.pl predicado: cola_vacia/1 encolar/3 desencolar/3 consulta: cola_vacia(C0), encolar(a, C0, C1), desencolar(X, C1, C2). -->
```prolog
% cola_vacia(C): C es la cola con contador sin elementos.
cola_vacia(cola(0, F, F)).

%!  encolar(+X, +Cola, -Cola1) is det.
%
%   Cola1 es Cola con X agregado al final, en un paso.
encolar(X, cola(N, Frente, [X|Fondo]), cola(N1, Frente, Fondo)) :-
    N1 is N + 1.

%!  desencolar(-X, +Cola, -Cola1) is semidet.
%
%   X es el primer elemento de Cola, y Cola1 el resto. Falla si Cola está
%   vacía.
desencolar(X, cola(N, [X|Frente], Fondo), cola(N1, Frente, Fondo)) :-
    N > 0,
    N1 is N - 1.
```

```prolog
?- cola_vacia(C0), desencolar(X, C0, C1).
false.
```

El uso típico de una cola es recorrer en **anchura**: primero la raíz, después
todos sus hijos, después todos sus nietos. `por_niveles/2` pone el árbol en
una cola; cada árbol que sale aporta su raíz a la lista y encola sus dos
subárboles al final, detrás de los que ya esperaban.

<!-- ejemplo: capitulo-34/cola.pl predicado: niveles/2 niveles/3 consulta: por_niveles(n(n(vacio, 2, vacio), 1, n(vacio, 3, n(vacio, 4, vacio))), L). -->
```prolog
%!  niveles(+Cola, -Lista:list) is det.
%
%   Lista tiene, por niveles, los elementos de los árboles de Cola.
niveles(Cola, Lista) :-
    (   desencolar(Arbol, Cola, Cola1)
    ->  niveles(Arbol, Cola1, Lista)
    ;   Lista = []
    ).

%!  niveles(+Arbol, +Cola, -Lista:list) is det.
%
%   Lista tiene la raíz de Arbol, si la tiene, y los elementos del resto
%   del recorrido, con los hijos de Arbol al final de Cola.
niveles(vacio, Cola, Lista) :-
    niveles(Cola, Lista).
niveles(n(Izq, X, Der), Cola, [X|Lista]) :-
    encolar(Izq, Cola, Cola1),
    encolar(Der, Cola1, Cola2),
    niveles(Cola2, Lista).
```

```prolog
?- por_niveles(n(n(vacio, 2, vacio), 1, n(vacio, 3, n(vacio, 4, vacio))), L).
L = [1, 2, 3, 4].
```

`por_niveles_lista/2`, en el mismo archivo, hace el mismo recorrido con la
cola como lista cerrada y `encolar_lista/3`. En un árbol completo, la cola
llega a tener la mitad de los nodos, y cada agregado la recorre entera; la
[sección 34.6](#346-cuanto-se-gana) mide el efecto. El [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) usa esta cola para la
búsqueda en anchura en un espacio de estados.

## 34.4 Diccionarios incompletos

`memberchk/2` sobre una lista abierta busca un elemento y lo agrega si no
está: consultar y ampliar son la misma operación. Con pares `Clave-Valor`, esa
lista es un **diccionario incompleto**. `memberchk/2` no sirve para
recorrerlo, porque compara el par entero: si la clave está con otro valor, no
la reconoce y agrega una entrada repetida.

```prolog
?- D = [a-1|_], memberchk(a-2, D).
D = [a-1, a-2|_].
```

`buscar/3` compara solo la clave. Si la encuentra, unifica el valor; si llega
al final abierto, la cabeza de la cláusula liga ese final a un par nuevo, la
clave unifica con él, y la entrada queda agregada:

<!-- ejemplo: capitulo-34/diccionario.pl predicado: buscar/3 consulta: buscar(c, [a-1, b-2|D], V). -->
```prolog
%!  buscar(+Clave, ?Dic:list, ?Valor) is semidet.
%
%   Dic es un diccionario incompleto: una lista abierta de pares
%   Clave-Valor, con claves distintas. Si Clave está en Dic, Valor unifica
%   con su valor; si no, el par Clave-Valor se agrega al final. Falla si la
%   clave está con otro valor.
buscar(Clave, [Clave0-Valor0|Resto], Valor) :-
    (   Clave = Clave0
    ->  Valor = Valor0
    ;   buscar(Clave, Resto, Valor)
    ).
```

```prolog
?- buscar(b, [a-1, b-2|D], V).
V = 2.

?- buscar(c, [a-1, b-2|D], V).
D = [c-V|_].
```

En la segunda consulta, el valor de la clave nueva queda **libre**. Esa es la
propiedad que distingue un diccionario incompleto de una tabla común: una
entrada se crea antes de conocer su valor, y el valor se liga después, en
cualquier momento, y se ve desde todos los lugares que ya lo usaban.
`codificar/2` da a cada palabra distinta un número, en el orden de su primera
aparición. Primero, `codigos/3` reemplaza cada palabra por el valor de su
entrada, todavía libre:

<!-- ejemplo: capitulo-34/diccionario.pl predicado: codificar/2 codigos/3 consulta: codificar([el, gato, y, el, perro], C). -->
```prolog
%!  codificar(+Palabras:list, -Codigos:list(integer)) is det.
%
%   Codigos tiene, para cada palabra, el número de la primera aparición de
%   esa palabra entre las distintas: 1 para la primera, 2 para la segunda
%   palabra distinta, y así.
codificar(Palabras, Codigos) :-
    codigos(Palabras, Dic, Codigos),
    numerar(Dic, 1).

%!  codigos(+Palabras:list, ?Dic:list, -Codigos:list) is det.
%
%   Codigos tiene el valor de cada palabra en el diccionario incompleto
%   Dic; las palabras nuevas se agregan con el valor libre.
codigos([], _, []).
codigos([P|Ps], Dic, [C|Cs]) :-
    buscar(P, Dic, C),
    codigos(Ps, Dic, Cs).
```

```prolog
?- codigos([el, gato, y, el, perro], D, C).
D = [el-_A, gato-_B, y-_C, perro-_D|_],
C = [_A, _B, _C, _A, _D].

?- codificar([el, gato, y, el, perro], C).
C = [1, 2, 3, 1, 4].
```

Las dos apariciones de `el` comparten la variable `_A`. Cuando
`numerar/2` recorre el diccionario y liga los valores a 1, 2, 3 y 4, cada
código de C recibe su número sin volver a recorrer las palabras.

!!! question "Actividad"
    Predecir la respuesta de
    `buscar(a, D, 1), buscar(b, D, V), buscar(a, D, X), V = 2.`
    y el valor final de D. ¿Qué responde si se agrega `buscar(b, D, 3)` al
    final?

En una lista, cada búsqueda recorre las entradas anteriores: agregar n claves
cuesta del orden de n² comparaciones. Un **árbol binario de búsqueda**
abierto, `t(Clave, Valor, Izq, Der)` con los subárboles libres donde todavía
no hay entradas, reduce cada búsqueda a una rama. `buscar_arbol/3` compara
con `compare/3`, del [capítulo 11](../capitulo-11-texto/index.md), y baja por un lado; un subárbol libre es
el lugar donde se agrega la clave:

<!-- ejemplo: capitulo-34/diccionario.pl predicado: buscar_arbol/3 buscar_en/6 consulta: buscar_arbol(b, A, 2), buscar_arbol(a, A, 1), buscar_arbol(b, A, V). -->
```prolog
%!  buscar_arbol(+Clave, ?Arbol, ?Valor) is semidet.
%
%   Arbol es un diccionario incompleto en forma de árbol binario de
%   búsqueda: t(Clave, Valor, Izq, Der), con los subárboles libres donde
%   todavía no hay entradas. Si Clave está, Valor unifica con su valor; si
%   no, el par se agrega en el lugar libre que le corresponde.
buscar_arbol(Clave, Arbol, Valor) :-
    (   var(Arbol)
    ->  Arbol = t(Clave, Valor, _, _)
    ;   Arbol = t(Clave0, Valor0, Izq, Der),
        compare(Orden, Clave, Clave0),
        buscar_en(Orden, Clave, Valor, Valor0, Izq, Der)
    ).

%!  buscar_en(+Orden, +Clave, ?Valor, ?Valor0, ?Izq, ?Der) is semidet.
%
%   Sigue la búsqueda de Clave según su Orden respecto de la raíz, cuyo
%   valor es Valor0.
buscar_en(=, _, Valor, Valor, _, _).
buscar_en(<, Clave, Valor, _, Izq, _) :-
    buscar_arbol(Clave, Izq, Valor).
buscar_en(>, Clave, Valor, _, _, Der) :-
    buscar_arbol(Clave, Der, Valor).
```

```prolog
?- buscar_arbol(b, A, 2), buscar_arbol(a, A, 1), buscar_arbol(b, A, V).
A = t(b, 2, t(a, 1, _, _), _),
V = 2.
```

La prueba `var/1` es necesaria aquí y no en `buscar/3`: comparar con una
raíz libre daría un orden, porque en el orden estándar una variable precede a
cualquier átomo, y la clave se insertaría en el lugar equivocado. El árbol no
se equilibra: con las claves en orden, degenera en una lista. Para un
diccionario equilibrado y cerrado está `library(assoc)`, del
[capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md); el incompleto conserva lo que aquella no ofrece, el valor que
se liga después.

!!! example "Patrón 48 — Diccionario incompleto"
    **Problema.** Asociar valores a claves cuando algunas se usan antes de
    conocer su valor: una etiqueta a la que se salta antes de definirla, un
    nombre al que se le asigna un número al final.

    **Versión ingenua.** Dos pasadas: la primera reúne las claves y calcula
    los valores, la segunda reemplaza cada clave por su valor; o una tabla
    cerrada que se reconstruye en cada agregado.

    **Patrón.** Una lista o un árbol con el final abierto, y un único
    predicado de búsqueda que encuentra la clave o la agrega con el valor
    libre. Cada uso de una clave comparte la variable de su valor; cuando el
    valor se conoce, se liga una vez, y todos los usos lo ven.

    **Cuándo no usarlo.** Cuando los valores cambian: una variable se liga
    una sola vez, y una tabla que se actualiza necesita `library(assoc)` o
    el estado del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md). Tampoco con claves que no están instanciadas:
    la búsqueda unificaría una clave libre con la primera entrada.

## 34.5 Las gramáticas como listas diferencia

La [sección 21.1](../capitulo-21-gramaticas-dcg/index.md#211-una-gramatica-es-un-conjunto-de-clausulas) mostró que cada regla de una gramática se traduce a una
cláusula con dos argumentos más, y que cada no terminal pasa al siguiente lo
que sobra de la lista. Esos dos argumentos son una lista diferencia, escrita
como dos argumentos en lugar de un par. Una gramática, por eso, sirve también
para **construir** una lista, no solo para reconocerla. `en_orden//1`
describe la lista de los elementos de un árbol en orden:

<!-- ejemplo: capitulo-34/gramatica.pl predicado: en_orden//1 consulta: phrase(en_orden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio))), L). -->
```prolog
%!  en_orden(+Arbol)// is det.
%
%   Los elementos de Arbol en orden: los del subárbol izquierdo, la raíz y
%   los del derecho. Arbol es vacio o n(Izq, X, Der).
en_orden(vacio) -->
    [].
en_orden(n(Izq, X, Der)) -->
    en_orden(Izq),
    [X],
    en_orden(Der).
```

```prolog
?- phrase(en_orden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio))), L).
L = [1, 2, 3].
```

`listing/1` muestra la traducción:

```prolog
?- listing(en_orden//1).
en_orden(vacio, A, B) :-
    A=B.
en_orden(n(Izq, X, Der), A, B) :-
    en_orden(Izq, A, C),
    C=[X|D],
    en_orden(Der, D, B).

true.
```

Es `inorden_dif/2` de la [sección 34.2](#342-de-append3-a-la-lista-diferencia), con cada par `L-F` separado en
dos argumentos y las unificaciones pasadas de la cabeza al cuerpo: el árbol
vacío deja la lista como la recibe, y un terminal `[X]` liga el final de lo
anterior a `[X|D]`. `en_orden_dif/3`, en el mismo archivo, es esa misma
traducción escrita a mano, y da las mismas respuestas.

`phrase/2` cierra la lista diferencia con `[]`; `phrase/3`, de la
[sección 21.2](../capitulo-21-gramaticas-dcg/index.md#212-phrase2-y-phrase3), entrega su final. Con un final instanciado, la lista
construida continúa con él; con uno libre, queda abierta:

```prolog
?- phrase(en_orden(n(vacio, 1, vacio)), L, [fin]).
L = [1, fin].
```

Escribir el recorrido como gramática aplica el [Patrón 47](../patrones.md#47-lista-diferencia-para-agregar-al-final) sin escribir
ningún par `L-F`: la traducción los pone, y los dos errores de la
[sección 34.2](#342-de-append3-a-la-lista-diferencia) no aparecen, porque cada lista diferencia pasa de un no terminal
al siguiente una sola vez y ninguna regla pregunta si está vacía. Por eso, en
el código de las partes siguientes, una salida que se construye por partes se
escribe como gramática. El [capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) escribe el traductor de las
gramáticas, que hace esta transformación al cargar el programa.

## 34.6 Cuánto se gana

Las secciones anteriores cambian recorridos cuadráticos por lineales. La
tabla reúne las mediciones con `time/1` de cada par de versiones, cada una
en una sesión recién iniciada, con tamaños que se duplican. Las cifras son
inferencias, que no dependen de la máquina:

| Programa | n | Versión con listas cerradas | Versión incompleta |
|---|---|---|---|
| `inorden_app/2` · `inorden/2`, árbol de `degenerado/2` | 1000 | 529 220 | 2 001 |
| | 2000 | 2 031 720 | 4 001 |
| | 4000 | 8 036 720 | 8 001 |
| `invertir_app/2` · `invertir/2` | 1000 | 501 642 | 1 001 |
| | 2000 | 2 003 142 | 2 001 |
| | 4000 | 8 006 142 | 4 001 |
| `por_niveles_lista/2` · `por_niveles/2`, árbol de `completo/2` | 1023 | 1 079 389 | 14 334 |
| | 2047 | 4 229 213 | 28 670 |
| | 4095 | 16 820 317 | 57 342 |
| `codigos/3` · `codigos_arbol/3`, claves de `mezcladas/2` | 1000 | 501 500 | 30 392 |
| | 2000 | 2 003 000 | 66 934 |
| | 4000 | 8 006 000 | 148 760 |

Cuando n se duplica, las versiones con listas cerradas cuadruplican sus
inferencias, y las incompletas las duplican; el diccionario en árbol algo más
que las duplica, por la rama más larga que recorre cada búsqueda. El tiempo
sigue a las inferencias: con 8191 nodos, el recorrido por niveles con la cola
cerrada tarda más de cinco segundos, y con la cola diferencia, menos de dos
centésimas.

```text
?- completo(13, A), time(por_niveles_lista(A, _)).
% 67,168,349 inferences, 6.516 CPU in 6.650 seconds (98% CPU, 10308811 Lips)

?- completo(13, A), time(por_niveles(A, _)).
% 114,686 inferences, 0.016 CPU in 0.017 seconds (94% CPU, 7339904 Lips)
```

La ganancia depende de la forma de los datos. `inorden_app/2` con un árbol
equilibrado recorre cada elemento una vez por nivel, del orden de n log n, y
con un árbol degenerado hacia la derecha no paga casi nada, porque cada
`append/3` recibe una lista de un solo elemento. Un diccionario de diez claves
se recorre igual de rápido en una lista que en un árbol. Como pide el
[Patrón 10](../patrones.md#10-medir-antes-de-cambiar), la técnica se elige después de medir con datos del tamaño
real; con una salvedad: escribir la construcción como gramática no cuesta
nada, y es la forma natural de hacerlo aunque los datos sean pequeños.

## 34.7 La tabla de símbolos del compilador

Un compilador traduce un programa a instrucciones numeradas, y un salto hacia
adelante nombra una etiqueta cuyo número todavía no se conoce. Con la tabla de
símbolos como diccionario incompleto y el código como gramática alcanza una
sola pasada: el salto escribe en su instrucción la dirección libre de la
etiqueta, y la marca, al aparecer, la liga.
[La página de la tabla de símbolos](ensamblador.md) presenta `ensamblar/2`, de
`simbolos.pl`, con un programa de ejemplo para una máquina de pila, el error
de una etiqueta que no se marca y el caso de una etiqueta marcada dos veces.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara sus modos; las estructuras incompletas se indican en el texto del encabezado: «Abierta es una lista abierta», «Dif, un par L-F» |
    | C4 | `inorden/2`, `invertir/2`, `por_niveles/2`, `codificar/2` y `ensamblar/2` no dejan alternativas: sus pruebas no declaran `nondet` |
    | C5 | una etiqueta sin marca produce un error de existencia en lugar de una dirección libre (prueba `sin_marca`); la etiqueta repetida falla, y el [ejercicio 13](#ejercicios) la convierte en error |
    | C7 | 85 pruebas en los seis archivos del capítulo; cada versión incompleta se compara con la cerrada sobre los mismos datos (pruebas `degenerado_iguales`, `iguales`, `arbol_como_lista`), y dos pruebas acotan las inferencias (`costo_lineal`, `arbol_menos_inferencias`) |
    | lo que se pierde | la relación en sentido inverso: `agregar_al_final/2`, `conocidos/2` y `buscar_arbol/3` preguntan con `var/1` si llegaron al final, y no tienen modo con la estructura libre; y la verificación de ocurrencias, que la cola con contador hace innecesaria |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta y comprobarla:
   `L = [a, b|F], F = [c|G], conocidos(L, C).` · `length([a|T], 2).` ·
   `concatenar_dif([a|X]-X, [b|Y]-Y, D).` · `vacia_dif([a]-[]).` ·
   `inorden_dif(vacio, D).`
2. **(1)** Escribir `longitud_abierta(Abierta, N)`: N es la cantidad de
   elementos presentes en la lista abierta, que no cambia. ¿Por qué no sirve
   `length/2`?
3. ★ **(2)** Escribir `a_dif(Lista, Dif)`, que convierte una lista cerrada
   en una lista diferencia, y `de_dif(Dif, Lista)`, que hace la conversión
   inversa. Decir cuál de las dos recorre la lista y cuál se hace en un paso,
   y qué ocurre con Dif después de `de_dif/2`.
4. ★ **(2)** La bandera holandesa: escribir `bandera(Bolitas, Ordenadas)`,
   que ordena una lista de `rojo`, `blanco` y `azul` poniendo primero las
   rojas, después las blancas y después las azules, en una sola pasada y sin
   `append/3`.
5. **(2)** Escribir `preorden//1` y `postorden//1`, que dan los elementos de
   un árbol con la raíz antes y después de sus subárboles. ¿Con qué árbol
   degenerado sería cuadrática cada versión con `append/3`?
6. ★ **(2)** Predecir la respuesta de
   `D = [a|X]-X, concatenar_dif(D, [b|Y]-Y, R1), concatenar_dif(D, [c|Z]-Z, R2).`
   Explicarla, y corregir la consulta para que R1 represente `[a, b]` y R2
   represente `[a, c]`.
7. **(2)** Escribir `elementos_cola(Cola, Lista)`: los elementos de una cola
   con contador, del primero al último, como lista cerrada, sin cambiar la
   cola.
8. ★ **(2)** Con la cola diferencia sin contador, se propone reconocer la
   cola vacía con el hecho `es_vacia_dif(F-F)`. Predecir la respuesta de
   `es_vacia_dif([a|X]-X).`, explicarla, y explicar por qué `cola_vacia/1`
   de la cola con contador no tiene el mismo problema.
9. **(1)** Escribir `claves(Dic, Claves)`: las claves de un diccionario
   incompleto en una lista, en su orden, sin cerrar el diccionario.
10. ★ **(2)** Escribir la gramática `pares//1`, que da los pares
    `Clave-Valor` de un diccionario incompleto en árbol en el orden de las
    claves. Un subárbol libre no tiene pares, y debe quedar libre.
11. **(2)** Escribir `hojas//1` para el árbol limpio de la
    [sección 32.6](../capitulo-32-inspeccion-de-terminos/index.md#326-representaciones-limpias), `h(X)` y `n(Hijos)`, y mostrar su traducción con
    `listing/1`. ¿Dónde quedó el terminal de la regla de `h(X)`?
12. **(2)** Medir `invertir_app/2` e `invertir/2` con listas de 1000, 2000 y
    4000 elementos. Calcular la razón entre las inferencias de un tamaño y
    las del anterior, y explicar las dos razones.
13. **(2)** Cambiar `ensamblar/2`, de
    [la página de la tabla de símbolos](ensamblador.md), para que una
    etiqueta marcada dos veces produzca un error de permiso,
    `permission_error(marcar, etiqueta, E)`. Considerar que un salto hacia
    adelante ya puede haber agregado la etiqueta a la tabla.
14. **(3)** Escribir `asignar(Codigo, Codigo1, N)`, que reemplaza el nombre
    de la variable de cada `cargar/1` y `guardar/1` por una dirección de
    memoria —0 para la primera variable que aparece, 1 para la segunda— con
    un diccionario incompleto; N es la cantidad de variables.
15. **(3)** Escribir `nivelar(Arbol, Nivelado)`: Nivelado tiene la misma
    forma que Arbol, un árbol `vacio` o `n(Izq, X, Der)` como el de la
    [sección 34.2](#342-de-append3-a-la-lista-diferencia), y cada uno de sus nodos tiene el máximo de los
    elementos de Arbol. Arbol se recorre una sola vez.
    `nivelar(n(n(vacio, 4, vacio), 3, n(vacio, 9, vacio)), N)` da un árbol con
    9 en los tres nodos, y `nivelar(vacio, N)` da `vacio`. El valor de los
    nodos nuevos no se conoce cuando se construyen: ¿qué estructura de la
    [sección 34.7](#347-la-tabla-de-simbolos-del-compilador) resuelve el mismo problema?
16. **(3)** Escribir `asociar_izquierda(Suma, Normal)`: Normal tiene los
    sumandos de Suma, un término cerrado con `+`, en el mismo orden y
    asociados a izquierda. `(a + b) + (c + d)` y `a + (b + (c + d))` dan
    `a + b + c + d`, que `write_canonical/1` escribe `+(+(+(a,b),c),d)`.
    Escribirlo primero con una lista diferencia de los sumandos y un segundo
    recorrido, y después en una sola pasada, con un acumulador que es la suma
    construida hasta el momento. ¿Con qué valor empieza el acumulador, y por
    qué un átomo como `ninguno` no sirve? Relacionar la forma de distinguir un
    sumando de una suma con el [Patrón 44](../patrones.md#44-representacion-limpia). La forma normal se retoma
    en el [capítulo 43](../capitulo-43-proyecto-resolver-ecuaciones/index.md).

## Resumen

| | |
|---|---|
| lista abierta | una lista que termina en una variable libre: se amplía ligándola, y se cierra con `[]` |
| lista diferencia | un par `L-F`, con F al final de L, que representa los elementos anteriores a F; se concatena en una unificación y se usa una sola vez |
| verificación de ocurrencias | una variable no se liga a un término que la contiene; SWI-Prolog la omite, y sin ella se crean términos cíclicos |
| `unify_with_occurs_check/2` | unificar con la verificación de ocurrencias |
| `cyclic_term/1` | el término es cíclico, infinito |
| opción `occurs_check` | `true` o `error` activan la verificación en todas las unificaciones |
| cola con contador | `cola(N, Frente, Fondo)`: encolar y desencolar en un paso; la cantidad reconoce la cola vacía |
| diccionario incompleto | una lista o un árbol con el final abierto; buscar consulta y agrega, y el valor se liga cuando se conoce |
| gramática y lista diferencia | los dos argumentos de la traducción de una regla son una lista diferencia; una gramática construye listas |
| tabla de símbolos en una pasada | las direcciones de las etiquetas, ligadas cuando aparece la marca |
| **Patrones 47, 48** | lista diferencia para agregar al final; diccionario incompleto |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La traducción de las gramáticas, escrita en Prolog | [capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md) |
| La cola diferencia en la búsqueda en anchura | [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) |
| Las sumas en forma normal, asociadas a izquierda | [capítulo 43](../capitulo-43-proyecto-resolver-ecuaciones/index.md) |
| Las respuestas de una aventura de texto construidas con gramáticas | [capítulo 44](../capitulo-44-proyecto-aventura-de-texto/index.md) |
| La tabla de símbolos de un compilador completo | [capítulo 45](../capitulo-45-proyecto-compilador/index.md) |

## Referencias

- Attila Csenki, *Prolog Techniques*, Ventus Publishing (Bookboon), 2009 —
  capítulo «Difference Lists».
  [Página de la editorial, copia de archivo](https://web.archive.org/web/20220123025207/https://bookboon.com/en/prolog-techniques-applications-of-prolog-ebook?mediaType=ebook).
  El capítulo toma la comparación de un aplanado con `append/3` y con listas
  diferencia, la relación entre una lista diferencia y un acumulador, y el
  problema de la bandera holandesa del [ejercicio 4](#ejercicios).
- Michael Spivey, *An Introduction to Logic Programming through Prolog*,
  Prentice Hall, 1996 — apartado «Difference lists», del capítulo «Parsing».
  [Edición del autor](https://spivey.oriel.ox.ac.uk/wiki/files/logprog/logic.pdf).
  El capítulo toma la lectura de los dos argumentos que agrega la traducción
  de una gramática como una lista diferencia.
- Leon Sterling y Ehud Shapiro, *The Art of Prolog*, 2.ª ed., MIT Press,
  1994 — capítulo «Incomplete Data Structures», apartados
  «Difference-Lists», «Difference-Structures», «Dictionaries» y «Queues»
  ([edición en línea](https://archive.org/details/artofprologadvan00ster)).
  El capítulo toma el diccionario incompleto en lista y en árbol, la cola
  diferencia con su prueba de vacía que falla sin verificación de
  ocurrencias, y la normalización de sumas, que el [ejercicio 16](#ejercicios) hace
  asociando a izquierda.
- Feliks Kluźniak y Stanisław Szpakowicz, *Prolog for Programmers*,
  Academic Press, 1985 — apartados «Open Lists and Trees» y «Difference
  Lists».
  [Edición en línea](https://www.site.uottawa.ca/~szpak/pub/P4P/Prolog_for_Programmers_neat.pdf).
  El capítulo toma la lista abierta que se extiende buscando su variable
  final, el árbol abierto, y la tabla de símbolos de un traductor con las
  direcciones como variables que se ligan al ensamblar ([sección 34.7](#347-la-tabla-de-simbolos-del-compilador)).
- Ulf Nilsson y Jan Małuszyński, *Logic, Programming and Prolog*, 2.ª
  edición, Wiley, 1995 — apartado «Difference Lists»
  ([edición en línea de los autores](https://www.ida.liu.se/~ulfni53/lpp/)).
  El capítulo toma los dos usos incorrectos de la [sección 34.2](#342-de-append3-a-la-lista-diferencia): la
  lista diferencia usada dos veces y la prueba de vacía que, sin la
  verificación de ocurrencias, crea un término infinito.
- Patrick Blackburn, Johan Bos y Kristina Striegnitz, *Learn Prolog Now!*,
  College Publications, 2006 — capítulo «Definite Clause Grammars»,
  apartado «Context Free Grammars»
  ([edición en línea](https://lpn.swi-prolog.org/lpnpage.php?pagetype=html&pageid=lpn-htmlse28)).
  El capítulo toma el paso de un reconocedor con `append/3` a uno con listas
  diferencia.
- Ivan Bratko, *Prolog Programming for Artificial Intelligence*,
  Addison-Wesley, 1986 — apartado «Improving the efficiency of list
  concatenation by a better data structure», del capítulo «Programming Style
  and Technique». Sin edición en línea de acceso libre. El capítulo toma la
  concatenación en una unificación con el par `L-F`.
- Paul Brna, *Prolog Programming: A First Course*, notas de curso, 2001 —
  apartado «Open Lists and Difference Lists». Sin edición en línea
  verificada. El capítulo toma la presentación de la lista abierta antes que
  la lista diferencia.

El código del capítulo es propio, escrito para el curso: las fuentes aportan
ideas y problemas, no código.
