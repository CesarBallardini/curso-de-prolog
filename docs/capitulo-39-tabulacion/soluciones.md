# Soluciones del capítulo 39 — Tabulación

El código de esta página está en `ejemplos/capitulo-39/`: `soluciones.pl`
para los ejercicios 2, 4, 5, 6, 7, 8, 9 y 10, que repite los datos que usa y
corre en SWISH; `soluciones_inscripciones.pl` para el 14, un módulo que usa
los del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md); y `soluciones_experto.pl` para el 15, que carga
`experto.pl`. Cada uno tiene sus pruebas. Los ejercicios 1, 3, 11, 12 y 13
se resuelven con los archivos del capítulo. Como en el capítulo, las
respuestas de una tabla no tienen un orden fijo, y las pruebas las comparan
ordenadas.

## 1

Con `camino.pl` cargado:

<!-- ejemplo: capitulo-39/camino.pl predicado: camino/2 -->
```prolog
%!  camino(?X, ?Y) is nondet.
%
%   Hay un camino de X a Y. Las mismas cláusulas que camino_prolog/2,
%   tabuladas: cada respuesta aparece una vez y la consulta termina.
camino(X, Y) :-
    arco(X, Y).
camino(X, Y) :-
    camino(X, Z),
    arco(Z, Y).
```

```prolog
?- aggregate_all(count, camino(c, Y), N).
N = 4.

?- aggregate_all(count, camino(X, d), N).
N = 3.

?- aggregate_all(count, camino(X, Y), N).
N = 12.
```

Desde c se llega a los cuatro nodos, c incluido, por el ciclo; a d se llega
desde a, b y c, pero no desde d, que no tiene arcos; y hay doce caminos,
tres destinos desde cada uno de los tres nodos del ciclo más d desde cada
uno de ellos. Las tres terminan con la tabla.

Sin la tabla, `camino_prolog(c, d)` responde `true` y, pidiendo más
respuestas, vuelve a responder `true` una vez por cada vuelta al ciclo, sin
terminar nunca: cada vuelta es otra demostración del mismo átomo.
`camino_prolog(d, a)` no responde nada: la primera cláusula falla y la
segunda llama a `camino_prolog(d, Z)`, la misma consulta, hasta agotar la
pila.

```text
?- camino_prolog(d, a).
ERROR: Stack limit (1.0Gb) exceeded
```

## 2

<!-- ejemplo: capitulo-39/soluciones.pl fragmento: :- table camino_der/2. .. camino_der(Z, Y). -->
```prolog
:- table camino_der/2.

%!  camino_der(?X, ?Y) is nondet.
%
%   Hay un camino de X a Y, con la recursión a la derecha y tabulado.
camino_der(X, Y) :-
    arco(X, Y).
camino_der(X, Y) :-
    arco(X, Z),
    camino_der(Z, Y).
```

<!-- ejemplo: capitulo-39/soluciones.pl predicado: tablas/1 -->
```prolog
%!  tablas(-N:integer) is det.
%
%   N es la cantidad de tablas que existen en este momento.
tablas(N) :-
    aggregate_all(count, current_table(_, _), N).
```

```prolog
?- findall(Y, camino_der(a, Y), Ys), tablas(T).
Ys = [b, a, d, c],
T = 4.
```

Las respuestas son las mismas que las de `camino/2`, en otro orden. La
recursión a la derecha llama a `camino_der(b, Y)`, `camino_der(c, Y)` y
`camino_der(d, Y)`, cada una con su tabla, y cuando el ciclo vuelve a
`camino_der(a, Y)` encuentra la variante en curso y consume su tabla: cuatro
tablas, una por nodo alcanzado. `camino(a, Y)`, con la recursión a la
izquierda, llama siempre a `camino(a, Z)`, una variante de sí misma, y deja
una sola tabla.

## 3

El intérprete `resolver_sin_ciclos/1` del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md) lleva los
objetivos antepasados de la rama y, cuando encuentra una variante de uno de
ellos, **abandona** la rama. Para `antepasado_izq(A, eva)`, la segunda
cláusula llama a `antepasado_izq(A, H)`, y la segunda cláusula de este a
`antepasado_izq(A, H2)`, una variante: la rama se corta, y con ella la
cadena de tres generaciones que llega a juan.

La tabla también reconoce la variante, pero no la abandona: la llamada
`antepasado_izq(A, H)` pasa a **consumir** las respuestas de la tabla de la
llamada en curso. Al principio la tabla tiene solo las respuestas de la
primera cláusula, los pares padre-hijo; con cada una, `padre(H, D)` agrega
pares de abuelos, y esas respuestas nuevas vuelven a la llamada consumidora,
que agrega bisabuelos, y así hasta que no aparece ninguna respuesta nueva.
Ninguna rama se descarta: la que el intérprete cortaba se reanuda cada vez
que la tabla crece. Lo que se evita es solo la repetición de la misma
llamada, y como la tabla tiene finitas respuestas posibles, la ejecución
termina con todas.

## 4

<!-- ejemplo: capitulo-39/soluciones.pl fragmento: :- table suma_hasta/2. .. S is S1 + N. -->
```prolog
:- table suma_hasta/2.

%!  suma_hasta(+N:integer, -S:integer) is semidet.
%
%   S es la suma de 1 a N. Falla si N no es positivo.
suma_hasta(1, 1).
suma_hasta(N, S) :-
    N > 1,
    N1 is N - 1,
    suma_hasta(N1, S1),
    S is S1 + N.
```

```prolog
?- suma_hasta(100, S), tablas(T).
S = 5050,
T = 100.
```

Hay una tabla por cada llamada, `suma_hasta(100, S)`, `suma_hasta(99, S1)`,
…, `suma_hasta(1, S)`: cien tablas de una respuesta cada una. Es lo mismo
que guardaba `suma_guardada/2`, más la suma de 1, y sin el predicado que la
borra.

## 5

<!-- ejemplo: capitulo-39/soluciones.pl fragmento: :- table formas/3. .. N is N1 + N2 -->
```prolog
:- table formas/3.

%!  formas(+Monto:integer, +Monedas:list(integer), -N:integer) is det.
%
%   N es la cantidad de formas de pagar Monto con monedas de los valores de
%   Monedas, positivos y sin repetir, sin importar el orden.
formas(Monto, Monedas, N) :-
    (   Monto =:= 0
    ->  N = 1
    ;   Monedas == []
    ->  N = 0
    ;   Monedas = [Moneda|Resto],
        (   Moneda > Monto
        ->  formas(Monto, Resto, N)
        ;   Menos is Monto - Moneda,
            formas(Menos, Monedas, N1),
            formas(Monto, Resto, N2),
            N is N1 + N2
```

Cada monto se paga usando al menos una moneda del primer valor, y queda por
pagar el resto con las mismas monedas, o sin usar ninguna, y queda el monto
entero con las demás. El caso en que el primer valor supera al monto solo
tiene la segunda opción. `formas_sin_tabla/3` es la misma definición sin la
directiva:

```text
?- time(formas(100, [1, 5, 10, 25, 50], N)).
% 23,867 inferences, 0.016 CPU in 0.007 seconds (231% CPU, 1527488 Lips)
N = 292.

?- time(formas_sin_tabla(100, [1, 5, 10, 25, 50], N)).
% 123,986 inferences, 0.016 CPU in 0.011 seconds (146% CPU, 7935104 Lips)
N = 292.

?- time(formas(300, [1, 5, 10, 25, 50], N)).
% 72,667 inferences, 0.016 CPU in 0.021 seconds (75% CPU, 4650688 Lips)
N = 9590.

?- time(formas_sin_tabla(300, [1, 5, 10, 25, 50], N)).
% 8,232,736 inferences, 0.578 CPU in 0.653 seconds (89% CPU, 14240408 Lips)
N = 9590.
```

Medido en esta máquina: con 100, la tabla usa la quinta parte de las
inferencias; con 300, la ciento trece ava parte. Sin tabla, el trabajo crece
con la cantidad de formas; con ella, con la cantidad de pares distintos de
monto y lista de monedas, que es a lo sumo el monto por la cantidad de
valores.

## 6

Desde b solo sale el tramo a d, de 5; de d se va a a con 3, en total 8; de a
a c con 1, en total 9; y a b se vuelve por a y c, 8 + 1 + 2 = 11, o por a
directamente, 8 + 4 = 12.

<!-- ejemplo: capitulo-39/soluciones.pl fragmento: :- table distancia(_, _, min). .. D is D0 + D1. -->
```prolog
:- table distancia(_, _, min).

%!  distancia(?X, ?Y, -D:integer) is nondet.
%
%   D es la longitud del recorrido más corto de X a Y. D debe llegar libre.
distancia(X, Y, D) :-
    tramo(X, Y, D).
distancia(X, Y, D) :-
    distancia(X, Z, D0),
    tramo(Z, Y, D1),
    D is D0 + D1.
```

```prolog
?- findall(Y-D, distancia(b, Y, D), Ps), msort(Ps, Ordenadas).
Ps = [b-11, c-9, d-5, a-8],
Ordenadas = [a-8, b-11, c-9, d-5].
```

`ruta(b, a, R)`, con `distancias.pl`, da `R = 8-[b, d, a]`.

Con `max` la consulta no termina:

<!-- ejemplo: capitulo-39/soluciones.pl fragmento: :- table distancia_max(_, _, max). .. D is D0 + D1. -->
```prolog
:- table distancia_max(_, _, max).

%!  distancia_max(?X, ?Y, -D:integer) is nondet.
%
%   Pretende dar la longitud del recorrido más largo de X a Y. Con un
%   ciclo de longitud positiva no termina: cada vuelta mejora el máximo.
distancia_max(X, Y, D) :-
    tramo(X, Y, D).
distancia_max(X, Y, D) :-
    distancia_max(X, Z, D0),
    tramo(Z, Y, D1),
    D is D0 + D1.
```

```prolog
?- call_with_inference_limit(distancia_max(a, b, _), 1000000, R).
R = inference_limit_exceeded.
```

Una tabla con modo recibe una respuesta nueva cada vez que una derivación
mejora el valor guardado. Con `min` y longitudes positivas, una vuelta más
al ciclo alarga el recorrido, y la respuesta que produce no mejora el
mínimo: después de las primeras derivaciones ya no aparece nada nuevo. Con
`max`, cada vuelta **mejora** el máximo guardado, esa mejora vuelve a las
llamadas consumidoras, que dan otra vuelta, y la tabla no se completa nunca:
en un grafo con un ciclo de longitud positiva, el recorrido más largo no
existe.

## 7

<!-- ejemplo: capitulo-39/soluciones.pl fragmento: :- table saltos(_, _, min). .. N is N0 + 1. -->
```prolog
:- table saltos(_, _, min).

%!  saltos(?X, ?Y, -N:integer) is nondet.
%
%   N es la menor cantidad de tramos de un recorrido de X a Y. N debe
%   llegar libre.
saltos(X, Y, 1) :-
    tramo(X, Y, _).
saltos(X, Y, N) :-
    saltos(X, Z, N0),
    tramo(Z, Y, _),
    N is N0 + 1.
```

```prolog
?- saltos(a, b, N), distancia(a, b, D).
N = 1,
D = 3.
```

De a a b hay un recorrido de un tramo, de longitud 4, y el más corto, por c,
tiene dos tramos y mide 3: el recorrido de menos tramos no es el más corto.

## 8

<!-- ejemplo: capitulo-39/soluciones.pl predicado: dag/3 -->
```prolog
% dag(X, Y, D): hay un tramo de X a Y de longitud D, en un grafo sin
% ciclos.
dag(s, a, 2).
dag(s, b, 1).
dag(b, a, 5).
dag(a, t, 3).
dag(b, t, 1).
```

<!-- ejemplo: capitulo-39/soluciones.pl fragmento: :- table ruta_mas_larga(_, _, lattice(mas_larga/3)). .. append(Nodos0, [Y], Nodos). -->
```prolog
:- table ruta_mas_larga(_, _, lattice(mas_larga/3)).

%!  ruta_mas_larga(?X, ?Y, -R) is nondet.
%
%   R es D-Nodos: el recorrido más largo de X a Y en dag/3, con su
%   longitud D y sus nodos. R debe llegar libre.
ruta_mas_larga(X, Y, D-[X, Y]) :-
    dag(X, Y, D).
ruta_mas_larga(X, Y, D-Nodos) :-
    ruta_mas_larga(X, Z, R0),
    R0 = D0-Nodos0,
    dag(Z, Y, D1),
    D is D0 + D1,
    append(Nodos0, [Y], Nodos).
```

<!-- ejemplo: capitulo-39/soluciones.pl predicado: mas_larga/3 -->
```prolog
%!  mas_larga(+R1, +R2, -R) is det.
%
%   R es la más larga de las rutas R1 y R2, de la forma D-Nodos; con
%   longitudes iguales, R1.
mas_larga(D1-N1, D2-N2, R) :-
    (   D1 >= D2
    ->  R = D1-N1
    ;   R = D2-N2
    ).
```

```prolog
?- ruta_mas_larga(s, t, R).
R = 9-[s, b, a, t].
```

En el grafo de `tramo/3` no terminaría por la misma razón que el máximo del
[ejercicio 6](#6): cada vuelta al ciclo da un recorrido más largo, que el
reticulado acepta como mejor, y la tabla no se completa.

## 9

<!-- ejemplo: capitulo-39/soluciones.pl predicado: mueve/3 -->
```prolog
% mueve(Juego, X, Y): en Juego, un jugador puede pasar de la posición X a
% la posición Y. j3 es j2 con un movimiento más, de a a e.
mueve(j2, a, b).
mueve(j2, b, a).
mueve(j2, b, c).
mueve(j2, c, d).
mueve(j3, a, b).
mueve(j3, b, a).
mueve(j3, b, c).
mueve(j3, c, d).
mueve(j3, a, e).
```

<!-- ejemplo: capitulo-39/soluciones.pl fragmento: :- table gana/2. .. tnot(gana(J, Y)). -->
```prolog
:- table gana/2.

%!  gana(?Juego, ?X) is nondet.
%
%   En Juego, quien mueve desde X gana. Las posiciones de empate son
%   respuestas indefinidas.
gana(J, X) :-
    mueve(J, X, Y),
    tnot(gana(J, Y)).
```

<!-- ejemplo: capitulo-39/soluciones.pl predicado: valor/2 -->
```prolog
%!  valor(+Meta, -Valor) is det.
%
%   Valor es verdadero, falso o indefinido: el de Meta, tabulada y sin
%   variables, en la semántica bien fundada.
valor(Meta, Valor) :-
    must_be(ground, Meta),
    findall(Condicion, call_delays(Meta, Condicion), Condiciones),
    (   Condiciones == []
    ->  Valor = falso
    ;   memberchk(true, Condiciones)
    ->  Valor = verdadero
    ;   Valor = indefinido
    ).
```

Desde e no hay movimientos, así que e pierde; desde a se puede ir a e, así
que a gana; desde b solo se va a a o a c, que ganan los dos para el rival,
así que b pierde. c gana y d pierde, como en j2. El empate desaparece: la
salida a e decide a, y con a decidida se decide b.

```prolog
?- findall(X-V, (member(X, [a, b, c, d, e]), valor(gana(j3, X), V)), Vs).
Vs = [a-verdadero, b-falso, c-verdadero, d-falso, e-falso].
```

## 10

<!-- ejemplo: capitulo-39/soluciones.pl predicado: p/0 q/0 r/0 r_prolog/0 -->
```prolog
%!  p is semidet.
%
%   p es verdadero si q no lo es.
p :-
    tnot(q).

%!  q is semidet.
%
%   q es verdadero si p no lo es.
q :-
    tnot(p).

%!  r is semidet.
%
%   r es verdadero si r no lo es.
r :-
    tnot(r).

%!  r_prolog is semidet.
%
%   r con la negación de Prolog y sin tabla: no termina.
r_prolog :-
    \+ r_prolog.
```

```prolog
?- findall(A-V, (member(A, [p, q, r]), valor(A, V)), Vs).
Vs = [p-indefinido, q-indefinido, r-indefinido].
```

p y q dependen cada uno de la negación del otro, como las posiciones a y b
del juego j2: el programa tiene dos modelos estables, uno con p y otro con
q, y la semántica bien fundada no elige, los deja indefinidos. r depende de
su propia negación, y ningún valor verdadero o falso es coherente con la
cláusula: también queda indefinido. Con `\+` y sin tabla, `r_prolog` se
llama a sí mismo dentro de la negación sin fin:

```text
?- r_prolog.
ERROR: Stack limit (1.0Gb) exceeded
```

## 11

Con `juego.pl` cargado:

<!-- ejemplo: capitulo-39/juego.pl predicado: valor/2 -->
```prolog
%!  valor(+Meta, -Valor) is det.
%
%   Valor es verdadero, falso o indefinido: el de Meta, tabulada y sin
%   variables, en la semántica bien fundada. Una respuesta sin condiciones
%   hace verdadera la meta; si todas tienen condiciones, es indefinida.
valor(Meta, Valor) :-
    must_be(ground, Meta),
    findall(Condicion, call_delays(Meta, Condicion), Condiciones),
    (   Condiciones == []
    ->  Valor = falso
    ;   memberchk(true, Condiciones)
    ->  Valor = verdadero
    ;   Valor = indefinido
    ).
```

```prolog
?- catch(tnot(mueve(j1, a, b)), E, true).
E = error(permission_error(tnot, non_tabled_procedure, mueve/3), context(system:'$tnot_implementation'/2, _)).

?- catch(valor(gana(j2, X), V), E, true).
E = error(instantiation_error, _).

?- tnot(gana(j2, X)).
false.
```

`tnot/1` necesita la tabla del objetivo negado: suspende la negación hasta
que esa tabla se completa, y si depende de la negación en curso la demora.
Sin tabla no hay dónde esperar ni qué completar, y el único resultado
posible sería el de `\+`, que no termina en los ciclos; por eso el error de
permiso. `valor/2` exige una meta sin variables porque clasifica un átomo:
con variables, `call_delays/2` daría una condición por cada instancia, y
reunirlas con `findall/3` mezclaría los valores de átomos distintos. La
tercera consulta muestra que `tnot/1` con variables no da un error: falla
porque alguna posición gana, como fallaría `\+`, sin decir cuál.

## 12

Con `incremental.pl` recién cargado:

<!-- ejemplo: capitulo-39/incremental.pl predicado: alcanza/2 alcanza_fijo/2 -->
```prolog
%!  alcanza(?X, ?Y) is nondet.
%
%   La misma relación, con una tabla incremental: sigue los cambios de
%   enlace/2.
alcanza(X, Y) :-
    enlace(X, Y).
alcanza(X, Y) :-
    alcanza(X, Z),
    enlace(Z, Y).

%!  alcanza_fijo(?X, ?Y) is nondet.
%
%   Desde X se llega a Y por uno o más enlaces. La tabla no sigue los
%   cambios de enlace/2.
alcanza_fijo(X, Y) :-
    enlace(X, Y).
alcanza_fijo(X, Y) :-
    alcanza_fijo(X, Z),
    enlace(Z, Y).
```

```prolog
?- assertz(enlace(c, a)), findall(Y, alcanza(c, Y), I1), findall(Y, alcanza_fijo(c, Y), F1), retract(enlace(a, b)), findall(Y, alcanza(c, Y), I2), findall(Y, alcanza_fijo(c, Y), F2).
I1 = F1, F1 = F2, F2 = [b, c, a],
I2 = [a].
```

Después de agregar el enlace de c a a, las dos consultas dan a, b y c: la
tabla común de `alcanza_fijo(c, Y)` no existía, y se calcula con el enlace
nuevo. Después de quitar el enlace de a a b, la tabla incremental se
invalida y da solo a; la común ya existe y sigue dando a, b y c, que ya no
es cierto. Para ponerla al día hace falta `abolish_all_tables/0`, o
declarar la tabla `incremental`.

## 13

Con `costo.pl` cargado:

<!-- ejemplo: capitulo-39/costo.pl predicado: cadena/1 tablas/1 -->
```prolog
%!  cadena(+N:integer) is det.
%
%   Reemplaza los enlaces por N enlaces en fila, de I a I + 1 para I de 0 a
%   N - 1, y borra las tablas.
cadena(N) :-
    must_be(nonneg, N),
    retractall(enlace(_, _)),
    abolish_all_tables,
    forall(between(1, N, J),
           ( I is J - 1,
             assertz(enlace(I, J)) )).

%!  tablas(-N:integer) is det.
%
%   N es la cantidad de tablas que existen en este momento.
tablas(N) :-
    aggregate_all(count, current_table(_, _), N).
```

```text
?- cadena(500), time(aggregate_all(count, alcanza_izq(_, 500), N)), tablas(T).
% 1,004,841 inferences, 0.156 CPU in 0.183 seconds (85% CPU, 6430982 Lips)
N = 500,
T = 2.

?- cadena(500), time(aggregate_all(count, alcanza_der(_, 500), N)), tablas(T).
% 21,035 inferences, 0.000 CPU in 0.007 seconds (0% CPU, Infinite Lips)
N = 500,
T = 501.

?- cadena(500), time(aggregate_all(count, alcanza_sin_tabla(_, 500), N)).
% 376,757 inferences, 0.031 CPU in 0.032 seconds (97% CPU, 12056224 Lips)
N = 500.
```

Medido en esta máquina, el orden se invierte. Con el segundo argumento
ligado, `alcanza_izq(X, 500)` llama a `alcanza_izq(X, Z)`, con los dos
argumentos libres: esa tabla calcula todos los pares de la red, 125 250
respuestas, para quedarse con los que terminan en 500. `alcanza_der(X,
500)` llama a `alcanza_der(Z, 500)` para cada Z, variantes con el segundo
argumento ligado, cada una con a lo sumo una respuesta: 501 tablas
pequeñas. La recursión conviene del lado del argumento que llega ligado,
para que la llamada recursiva lo conserve. Sin tabla, la consulta prueba
desde cada nodo el recorrido hasta 500, y repite los tramos compartidos.

## 14

<!-- ejemplo: capitulo-39/soluciones_inscripciones.pl fragmento: :- table habilita/2. .. correlativa(Otra, Intermedia). -->
```prolog
:- table habilita/2.

%!  habilita(?Materia:atom, ?Otra:atom) is nondet.
%
%   Aprobar Materia es necesario, directa o indirectamente, para cursar
%   Otra.
habilita(Materia, Otra) :-
    correlativa(Otra, Materia).
habilita(Materia, Otra) :-
    habilita(Materia, Intermedia),
    correlativa(Otra, Intermedia).
```

<!-- ejemplo: capitulo-39/soluciones_inscripciones.pl predicado: materias_habilitadas/2 -->
```prolog
%!  materias_habilitadas(+Legajo:integer, -Materias:list(atom)) is det.
%
%   Materias son las que el alumno Legajo no aprobó ni cursa y cuyos
%   requisitos, directos e indirectos, aprobó todos; en orden.
materias_habilitadas(Legajo, Materias) :-
    must_be(integer, Legajo),
    findall(M,
            ( materia(M, _, _),
              \+ aprobada(Legajo, M, _),
              \+ cursa(Legajo, M),
              forall(habilita(R, M), aprobada(Legajo, R, _)) ),
            Ms),
    sort(Ms, Materias).
```

```prolog
?- findall(M, habilita(log, M), Ms), msort(Ms, Ordenadas).
Ms = [pp, bd, ssl],
Ordenadas = [bd, pp, ssl].

?- materias_habilitadas(101, Ms).
Ms = [ssl].

?- materias_habilitadas(102, Ms).
Ms = [alg, am1, pp].
```

`habilita/2` es `requisito/2` con los argumentos invertidos, y la prueba
`inversa` lo comprueba contra `requisitos_de/2` del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md) para cada
materia. ana aprobó análisis 1, álgebra, lógica y análisis 2, y cursa
paradigmas: le queda sintaxis, cuyos requisitos aprobó; bases de datos
exige paradigmas. bruno aprobó solo lógica: puede cursar análisis 1 y
álgebra, que no tienen requisitos, y paradigmas.

## 15

<!-- ejemplo: capitulo-39/soluciones_experto.pl predicado: como_tabulado/4 arbol/5 condiciones/5 -->
```prolog
%!  como_tabulado(+Version:atom, +Observaciones:list, +Meta, -Arbol)
%!      is semidet.
%
%   Arbol es una prueba de Meta con las reglas de Version y las
%   Observaciones, con las formas observado(M), deducido(M, Regla, Arbol),
%   A y B, X > Y y no M. Falla si Meta no es verdadera.
como_tabulado(Version, Os, Meta, Arbol) :-
    once(arbol(Version, Os, Meta, [], Arbol)).

%!  arbol(+Version:atom, +Os:list, ?Meta, +Rama:list, -Arbol) is nondet.
%
%   Arbol prueba Meta sin usar las conclusiones de Rama, las que están en
%   curso en la rama del árbol.
arbol(_, Os, Meta, _, observado(Meta)) :-
    member(Meta, Os).
arbol(Version, Os, Meta, Rama, deducido(Meta, Regla, Arbol)) :-
    \+ ( member(M, Rama), M == Meta ),
    regla_de(Version, Regla, si Condiciones entonces Meta),
    condiciones(Version, Os, Condiciones, [Meta|Rama], Arbol).

%!  condiciones(+Version:atom, +Os:list, +Condiciones, +Rama:list,
%!              -Arbol) is nondet.
%
%   Arbol prueba las Condiciones de una regla. Una condición atómica se
%   prueba solo si cierto/3 la da como verdadera, sin condiciones.
condiciones(Version, Os, A y B, Rama, ArbolA y ArbolB) :-
    condiciones(Version, Os, A, Rama, ArbolA),
    condiciones(Version, Os, B, Rama, ArbolB).
condiciones(_, _, X > Y, _, X > Y) :-
    X > Y.
condiciones(Version, Os, no A, _, no A) :-
    valor(cierto(Version, Os, A), falso).
condiciones(Version, Os, A, Rama, Arbol) :-
    atomica(A),
    call_delays(cierto(Version, Os, A), true),
    arbol(Version, Os, A, Rama, Arbol).
```

```prolog
?- como_tabulado(original, [tiene_plumas, peso(90)], avestruz, A).
A = deducido(avestruz, r12, deducido(ave, r3, observado(tiene_plumas))y no vuela y observado(peso(90))y 90>50).

?- como_tabulado(vuela, [tiene_plumas, nada, peso(30)], pinguino, A).
false.
```

`cierto/3` elige: una condición atómica se desarrolla solo si la tabla la da
como verdadera sin condiciones, y una negación solo si la tabla la da como
falsa. Con eso, cada rama que se desarrolla lleva a una prueba, salvo por
los ciclos: la conclusión `ave` es verdadera, y la regla r4 la deduce de
`vuela`, que r13 deduce de `ave`. La rama lleva las conclusiones en curso, y
`arbol/5` no vuelve a usar una: la prueba de `ave` por r4 queda descartada, y
la de r3 se encuentra. Un átomo verdadero en el modelo bien fundado siempre
tiene una prueba sin ciclos, así que descartar las ramas circulares no
pierde ninguno. El pingüino indefinido de la segunda consulta no tiene
prueba: `no vuela` no es falsa ni verdadera.
