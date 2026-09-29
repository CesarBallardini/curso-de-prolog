# Soluciones del capítulo 38 — Semántica de los programas lógicos

El código de esta página está en `ejemplos/capitulo-38/`: `soluciones.pl`
para los ejercicios 1, 2, 3, 9, 10, 11, 12, 13 y 14, que carga los
evaluadores de `semantica.pl`; `soluciones_sld.pl` para el 4, el 5, el 6, el
7 y el 8, que carga `sld.pl`; y `soluciones_experto.pl` para el 15, que carga
`experto.pl`. Cada uno tiene sus pruebas. Como cargan otro archivo con
`ensure_loaded/1`, ninguno corre en SWISH; los archivos que cargan, sí.

Cada predicado nuevo que recibe un programa tiene, como los del capítulo, una
forma terminada en `_de`, que recibe la lista de cláusulas, y otra que recibe
el nombre del programa. Los programas que las soluciones construyen como
datos se nombran agregando cláusulas a `generado/2`; los de `soluciones.pl`
son estos:

<!-- ejemplo: capitulo-38/soluciones.pl predicado: generado/2 -->
```prolog
%!  generado(+Programa, -Clausulas:list) is semidet.
%
%   Los programas de estas soluciones: paridad, juego(Juego) (los
%   movimientos de Juego solamente), alcanzables(N) y cadena_doble(N).
generado(paridad, Clausulas) :-
    paridad(Clausulas).
generado(juego(Juego), Clausulas) :-
    del_juego(Juego, Clausulas).
generado(alcanzables(N), Clausulas) :-
    alcanzables(N, Clausulas).
generado(cadena_doble(N), Clausulas) :-
    cadena_doble(N, Clausulas).
```

## 1

Una interpretación del programa `lluvia` es un modelo si contiene `llueve`,
por el hecho, y `calle_mojada` cuando contiene `llueve` o `riego`. Con
`llueve` obligatorio, `calle_mojada` también lo es, y `riego` queda libre:
hay dos modelos, `[calle_mojada, llueve]` y `[calle_mojada, llueve, riego]`.
`modelos_de/3` prueba cada subconjunto de los átomos:

<!-- ejemplo: capitulo-38/soluciones.pl predicado: modelos_de/3 subconjunto/2 -->
```prolog
%!  modelos_de(+Clausulas:list, +Atomos:list, -Modelos:list) is det.
%
%   Modelos son los subconjuntos de Atomos que son modelos de Clausulas,
%   cada uno ordenado, en el orden en que subconjunto/2 los genera.
modelos_de(Clausulas, Atomos, Modelos) :-
    findall(I,
            ( subconjunto(Atomos, I),
              es_modelo_de(Clausulas, I) ),
            Modelos).

%!  subconjunto(+Conjunto:list, -Sub:list) is multi.
%
%   Sub es un subconjunto de Conjunto, con los elementos en el mismo orden.
%   Una respuesta por subconjunto: primero los que tienen el primer
%   elemento.
subconjunto([], []).
subconjunto([X|Xs], [X|Ys]) :-
    subconjunto(Xs, Ys).
subconjunto([_|Xs], Ys) :-
    subconjunto(Xs, Ys).
```

```prolog
?- modelos(lluvia, [calle_mojada, llueve, riego], Ms).
Ms = [[calle_mojada, llueve, riego], [calle_mojada, llueve]].
```

La intersección de los dos es `[calle_mojada, llueve]`, el resultado de
`modelo_minimo/2`: es el modelo mínimo, y la prueba `interseccion` lo
comprueba.

## 2

En un programa sin functores, el universo de Herbrand son las constantes, y
la base se forma combinando cada predicado con constantes en todas sus
posiciones:

<!-- ejemplo: capitulo-38/soluciones.pl predicado: base_herbrand_de/2 atomo_de/2 constante/2 elegida/2 -->
```prolog
%!  base_herbrand_de(+Clausulas:list, -Base:list) is det.
%
%   Base es la base de Herbrand de Clausulas, un programa sin functores: los
%   átomos que se forman con sus predicados y sus constantes, ordenados.
base_herbrand_de(Clausulas, Base) :-
    findall(C, ( member(Clausula, Clausulas),
                 constante(Clausula, C) ),
            Cs0),
    sort(Cs0, Constantes),
    findall(P, ( member(Clausula, Clausulas),
                 atomo_de(Clausula, A),
                 indicador(A, P) ),
            Ps0),
    sort(Ps0, Predicados),
    findall(Atomo,
            ( member(Nombre/Aridad, Predicados),
              length(Argumentos, Aridad),
              maplist(elegida(Constantes), Argumentos),
              Atomo =.. [Nombre|Argumentos] ),
            Base0),
    sort(Base0, Base).

%!  atomo_de(+Clausula, -Atomo) is nondet.
%
%   Atomo es la cabeza de Clausula o un átomo de su cuerpo, positivo o
%   negado; las comparaciones no cuentan.
atomo_de(Cabeza :- _, Cabeza).
atomo_de(_ :- Cuerpo, Atomo) :-
    conjuncion_lista(Cuerpo, Literales),
    member(Literal, Literales),
    (   Literal = (\+ Atomo)
    ->  true
    ;   atomo(Literal),
        Atomo = Literal
    ).

%!  constante(+Clausula, -C) is nondet.
%
%   C es un argumento sin variables de un átomo de Clausula.
constante(Clausula, C) :-
    atomo_de(Clausula, Atomo),
    Atomo =.. [_|Argumentos],
    member(C, Argumentos),
    atomic(C).

%!  elegida(+Constantes:list, -C) is nondet.
%
%   C es una de Constantes.
elegida(Constantes, C) :-
    member(C, Constantes).
```

```prolog
?- base_herbrand(caminos, B), length(B, N).
B = [arco(a, a), arco(a, b), arco(a, c), arco(a, d), arco(b, a), arco(b, b), arco(b, c), arco(b, d), arco(..., ...)|...],
N = 32.

?- aggregate_all(count, consecuencia(caminos, _), NM).
NM = 16.
```

Con cuatro constantes y dos predicados binarios, la base tiene
$2 \cdot 4^2 = 32$ átomos, y el modelo mínimo, que `consecuencia/2` recorre
átomo por átomo, tiene la mitad: los 4 arcos y
los 12 caminos. Los 12 arcos que no están y los 4 caminos que salen de `d`
son falsos en el modelo mínimo.

## 3

La interpretación es un modelo: en ella q es verdadero, así que el cuerpo de
`p :- \+ q` es falso; lo mismo pasa con q y con r, y s está. Pero no es
mínimo. Con los cinco átomos del programa:

```prolog
?- es_modelo(circular, [p, q, r, s]).
true.

?- modelos(circular, [p, q, r, s, t], Ms), minimales(Ms, Minimales).
Ms = [[p, q, r, s, t], [p, q, r, s], [p, q, r, t], [p, r, s, t], [p, r, s], [p, r, t], [q, r|...], [q|...], [...|...]],
Minimales = [[p, r, s], [p, r, t], [q, r, s], [q, r, t]].
```

<!-- ejemplo: capitulo-38/soluciones.pl predicado: minimales/2 minimal/2 -->
```prolog
%!  minimales(+Modelos:list, -Minimales:list) is det.
%
%   Minimales son los de Modelos que no contienen estrictamente a ningún
%   otro de Modelos.
minimales(Modelos, Minimales) :-
    include(minimal(Modelos), Modelos, Minimales).

%!  minimal(+Modelos:list, +M:list) is semidet.
%
%   Ningún otro de Modelos está contenido en M.
minimal(Modelos, M) :-
    \+ ( member(N, Modelos),
         N \== M,
         ord_subset(N, M) ).
```

`ord_subset/2`, de `library(ordsets)`, tiene éxito si el primer conjunto
ordenado está contenido en el segundo. Los modelos que da `modelos/3`
conservan el orden de la lista de átomos, que aquí está ordenada. De los nueve modelos que encuentra `modelos/3`, cuatro son minimales, y
ninguno está contenido en los otros: el
programa no tiene modelo mínimo. Cada uno elige entre p y q, y entre s y t;
en todos está r, porque sin r el cuerpo de `r :- \+ r` es verdadero. La
sucesión de $T_P$ muestra por qué el cálculo del modelo mínimo no sirve aquí:

```prolog
?- consecuencias(circular, [], T1), consecuencias(circular, T1, T2).
T1 = [p, q, r, s],
T2 = [s].
```

Desde la interpretación vacía, todas las negaciones se cumplen y $T_P$ da
p, q, r y s; con esos átomos, casi ninguna se cumple, y $T_P$ da solo s. Con
negación, $T_P$ no es **monótono**: agregar átomos a I puede quitar átomos de
$T_P(I)$. El teorema del punto fijo de la
[sección 38.6](index.md#386-evaluacion-de-abajo-hacia-arriba) necesita la
monotonía; `ingenua_de/4` une cada paso con el anterior, y así llega a
`[p, q, r, s]`, un modelo que no es el significado de nada. Por eso
`modelo_estandar/2` evalúa por estratos: dentro de un estrato, los
predicados negados ya no cambian, y $T_P$ vuelve a ser monótono.

## 4

<!-- ejemplo: capitulo-38/soluciones_sld.pl predicado: refutacion_de/5 -->
```prolog
%!  refutacion_de(+Seleccion, +Clausulas:list, +Metas:list,
%!                 +Limite:integer, -Resolventes:list) is nondet.
%
%   Resolventes son las consultas de una refutación de Metas con la regla
%   Seleccion, de Limite pasos o menos: la primera es Metas y la última la
%   consulta vacía. Cada una es una copia tomada en su paso, sin las
%   ligaduras de los pasos siguientes. Una respuesta por refutación, en el
%   orden del árbol SLD; la respuesta calculada queda en Metas.
refutacion_de(Seleccion, Clausulas, Metas, Limite, [Copia|Resolventes]) :-
    copy_term(Metas, Copia),
    (   Metas == []
    ->  Resolventes = []
    ;   Limite > 0,
        Limite1 is Limite - 1,
        paso_de(Seleccion, Clausulas, Metas, Resolvente),
        refutacion_de(Seleccion, Clausulas, Resolvente, Limite1, Resolventes)
    ).
```

```prolog
?- refutacion(izquierda, enlaces, [conexion(a, X)], 4, Rs).
X = b,
Rs = [[conexion(a, _)], [enlace(a, _)], []] ;
X = c,
Rs = [[conexion(a, _)], [conexion(a, _A), enlace(_A, _)], [enlace(a, _B), enlace(_B, _)], [enlace(b, _)], []] ;
false.
```

Con la consulta `conexion(a, c)`, la primera cláusula da `enlace(a, c)`, que
falla, y la refutación usa la segunda:

| Paso | Se resuelve | Sustitución | Resolvente |
|---|---|---|---|
| 1 | `conexion(a, c)` con la regla recursiva | θ₁ = { X/a, Y/c } | `conexion(a, Z), enlace(Z, c)` |
| 2 | `conexion(a, Z)` con la primera regla | θ₂ = { X₂/a, Y₂/Z } | `enlace(a, Z), enlace(Z, c)` |
| 3 | `enlace(a, Z)` con `enlace(a, b)` | θ₃ = { Z/b } | `enlace(b, c)` |
| 4 | `enlace(b, c)` con `enlace(b, c)` | θ₄ = { } | la consulta vacía |

`refutacion_de/5` guarda una copia de cada resolvente en su paso, antes de que
los pasos siguientes liguen sus variables; por eso la variable intermedia
aparece libre hasta el paso 3.

## 5

```prolog
?- arbol_sld(izquierda, familia, [abuelo(A, luis)], 5, T).
T = arbol([[abuelo(juan, luis)]], 6, 2, 0).

?- arbol_sld(derecha, familia, [abuelo(A, luis)], 5, T).
T = arbol([[abuelo(juan, luis)]], 4, 0, 0).
```

Con la regla de la izquierda, `padre(A, P)` con los dos argumentos libres
tiene tres soluciones, y cada una deja un objetivo `padre(P, luis)`: con P
ana y con P luis, fallan; con P pedro, tiene éxito. Son seis nodos y dos
fallos. Con la de la
derecha se elige primero `padre(P, luis)`, que liga P a pedro, y después
`padre(A, pedro)`: cuatro nodos, ninguno de fallo. Para esta consulta
conviene la regla de la derecha. La misma forma del árbol se obtiene en
Prolog escribiendo los objetivos al revés,
`abuelo(A, N) :- padre(P, N), padre(A, P).`: con N ligado, el objetivo que
lo usa va primero, como recomendó la
[sección 5.5](../capitulo-05-como-responde-prolog/index.md#55-el-orden-de-los-objetivos-determina-el-trabajo).

## 6

Es `refutacion_de/5` de la solución 4: recorre el árbol como `nodo/6`, pero
devuelve solo las ramas que llegan a la consulta vacía, con la lista de sus
resolventes. Da una respuesta por refutación, en el orden en que Prolog las
encuentra, y falla en las ramas que llegan al límite.

## 7

Con los movimientos del juego j2, la compleción es:

$$\forall J \, \forall X \; \bigl( \mathit{gana}(J, X) \leftrightarrow \exists Y \, (\mathit{mueve}(J, X, Y) \land \lnot \mathit{gana}(J, Y)) \bigr)$$

$$\forall J \, \forall X \, \forall Y \; \bigl( \mathit{mueve}(J, X, Y) \leftrightarrow (J = j2 \land X = a \land Y = b) \lor (J = j2 \land X = b \land Y = a) \lor (J = j2 \land X = b \land Y = c) \lor (J = j2 \land X = c \land Y = d) \bigr)$$

`sld.pl` no tiene el programa `juego`, que está en `semantica.pl`;
`soluciones_sld.pl` lo escribe como datos, con los movimientos de j2, y lo
llama `juego(j2)` en `generado/2`:

<!-- ejemplo: capitulo-38/soluciones_sld.pl predicado: generado/2 -->
```prolog
% generado(Programa, Clausulas): el programa juego(j2) son las cláusulas
% del programa juego de semantica.pl, escritas como datos: la regla de
% gana/2 y los movimientos del juego j2.
generado(juego(j2), [ (gana(J, X) :- mueve(J, X, Y), \+ gana(J, Y)),
                      (mueve(j2, a, b) :- true),
                      (mueve(j2, b, a) :- true),
                      (mueve(j2, b, c) :- true),
                      (mueve(j2, c, d) :- true) ]).
```

```prolog
?- complecion(juego(j2), gana/2, F).
F = sii(gana(_A, _B), existe([_C], (mueve(_A, _B, _C), \+gana(_A, _C)))).

?- complecion(juego(j2), mueve/3, F).
F = sii(mueve(_A, _B, _C), (_A=j2, _B=a, _C=b;_A=j2, _B=b, _C=a;_A=j2, _B=b, _C=c;_A=j2, _B=c, _C=d)).

?- complecion_de([(r :- \+ r)], r/0, F).
F = sii(r, \+r).
```

Aplicada a las posiciones, la compleción da
$\lnot \mathit{gana}(j2, d)$, porque desde d no hay movimientos, y de ahí
$\mathit{gana}(j2, c)$. Para a y b da
$\mathit{gana}(j2, a) \leftrightarrow \lnot \mathit{gana}(j2, b)$ y
$\mathit{gana}(j2, b) \leftrightarrow \lnot \mathit{gana}(j2, a)$, porque
el movimiento de b a c no sirve: las dos interpretaciones, con a ganadora o
con b ganadora, satisfacen la compleción, y ninguno de los dos átomos ni su
negación es consecuencia. La de `r/0`, $r \leftrightarrow \lnot r$, es falsa
tanto si r es verdadero como si es falso: no tiene modelos.

## 8

<!-- ejemplo: capitulo-38/soluciones_sld.pl predicado: mostrar_complecion/1 escribir_formula/1 -->
```prolog
%!  mostrar_complecion(+Programa:atom) is det.
%
%   Escribe la definición completada de cada predicado de Programa, uno por
%   línea, con las variables nombradas A, B, C…
mostrar_complecion(Programa) :-
    clausulas(Programa, Clausulas),
    programa(Programa, Indicadores),
    forall(member(Indicador, Indicadores),
           ( complecion_de(Clausulas, Indicador, Formula),
             escribir_formula(Formula) )).

%!  escribir_formula(+Formula) is det.
%
%   Escribe Formula y un salto de línea, con sus variables nombradas A, B,
%   C…, sin ligarlas.
escribir_formula(Formula) :-
    \+ \+ ( numbervars(Formula, 0, _),
            print(Formula),
            nl ).
```

```prolog
?- mostrar_complecion(familia).
sii(padre(A,B),(A=juan,B=ana;A=juan,B=pedro;A=pedro,B=luis))
sii(abuelo(A,B),existe([C],(padre(A,C),padre(C,B))))
true.
```

`numbervars/3` liga las variables a términos que `print/1` escribe como A,
B, C; la doble negación deshace esas ligaduras al terminar, y la fórmula
queda como estaba.

## 9

(a) es estratificado: d en el estrato 0, c usa d negado y queda en el 1, b
usa c en positivo y queda también en el 1, y a usa b negado y queda en el 2.
(b) no lo es: a usa c negado y c usa a negado. (c) tampoco: a usa b negado y
b usa a, un ciclo que pasa por una negación.

```prolog
?- estratos_de([(a :- \+ b), (b :- c), (c :- \+ d)], E).
E = [0-[d/0], 1-[b/0, c/0], 2-[a/0]].

?- ciclos_negativos_de([(a :- b, \+ c), (c :- \+ a)], P).
P = [a/0-c/0, c/0-a/0].

?- ciclos_negativos_de([(a :- \+ b), (b :- a)], P).
P = [a/0-b/0].
```

En (c) solo una arista cierra el ciclo con una negación, la de a a b; la de b
a a es positiva.

## 10

<!-- ejemplo: capitulo-38/soluciones.pl predicado: paridad/1 -->
```prolog
%!  paridad(-Clausulas:list) is det.
%
%   Clausulas es el programa del ejercicio 10: par/1 sobre los números del
%   0 al 6, con sigue/2.
paridad(Clausulas) :-
    findall(sigue(M, N) :- true,
            ( between(1, 6, N),
              M is N - 1 ),
            Hechos),
    append([ [ (par(0) :- true),
               (par(N) :- sigue(M, N), \+ par(M)) ],
             Hechos ],
           Clausulas).
```

```prolog
?- estratos(paridad, E).
false.

?- bien_fundado(paridad, V, I).
V = [par(0), par(2), par(4), par(6), sigue(0, 1), sigue(1, 2), sigue(2, 3), sigue(3, 4), sigue(..., ...)|...],
I = [].
```

El modelo es total, sin indefinidos, y sus verdaderos son los seis hechos de
`sigue/2` y `par(0)`, `par(2)`, `par(4)` y `par(6)`: 0 es par por el hecho,
1 no, porque su único anterior es par, 2 sí, y así hasta 6. El grafo de dependencias une `par/1` consigo mismo
por una negación, pero los átomos no: `par(2)` depende de `par(1)`, que
depende de `par(0)`, y ninguna cadena vuelve a un átomo ya visitado. Es un
programa **localmente estratificado**, en el que los estratos se asignan a
los átomos y no a los predicados (Nilsson y Małuszyński, en las notas
bibliográficas sobre la negación); decidir esa propiedad no es posible en
general, y la semántica bien fundada no la necesita.

## 11

<!-- ejemplo: capitulo-38/soluciones.pl predicado: alternancia_de/2 del_juego/2 de_otro_juego/2 -->
```prolog
%!  alternancia_de(+Clausulas:list, -Pasos:list) is det.
%
%   Pasos son los pares V-P del punto fijo alternado, desde V vacío: los
%   verdaderos de cada paso y los posibles que se calculan con ellos, hasta
%   que los verdaderos no cambian.
alternancia_de(Clausulas, Pasos) :-
    alternancia_de(Clausulas, [], Pasos).

%!  del_juego(+Juego, -Clausulas:list) is det.
%
%   Clausulas son las del programa juego con los movimientos de Juego
%   solamente.
del_juego(Juego, Clausulas) :-
    clausulas(juego, Todas),
    exclude(de_otro_juego(Juego), Todas, Clausulas).

%!  de_otro_juego(+Juego, +Clausula) is semidet.
%
%   Clausula es un movimiento de un juego distinto de Juego.
de_otro_juego(Juego, mueve(Otro, _, _) :- true) :-
    Otro \== Juego.
```

```prolog
?- forall((alternancia(juego(j2), Ps), member(V-P, Ps)), (include([A]>>(A = gana(_, _)), V, GV), include([A]>>(A = gana(_, _)), P, GP), print(GV-GP), nl)).
[]-[gana(j2,a),gana(j2,b),gana(j2,c)]
[gana(j2,c)]-[gana(j2,a),gana(j2,b),gana(j2,c)]
true.
```

En el primer paso, con todo lo no verdadero tomado por falso, son posibles
las posiciones que tienen algún movimiento: d ya no es posible, y queda
falsa desde el paso 0. Con esos posibles, lo seguro es que c gana, porque d
no es posible; eso se sabe en el paso 1. Los posibles no cambian, porque a y
b siguen siendo posibles, y los verdaderos tampoco: la alternancia termina,
con a y b indefinidos.

## 12

<!-- ejemplo: capitulo-38/soluciones.pl predicado: estables_de/2 -->
```prolog
%!  estables_de(+Clausulas:list, -Modelos:list) is det.
%
%   Modelos son los modelos estables de Clausulas: los M tales que el
%   modelo reducido con las negaciones evaluadas contra M es M. Los
%   candidatos son los subconjuntos de lo posible, reducido(Clausulas, [],
%   P).
estables_de(Clausulas, Modelos) :-
    reducido(Clausulas, [], Posibles),
    findall(M,
            ( subconjunto(Posibles, M),
              reducido(Clausulas, M, M) ),
            Modelos).
```

```prolog
?- estables_de([(p :- \+ q), (q :- \+ p)], Ms).
Ms = [[p], [q]].

?- estables(circular, Ms).
Ms = [].
```

`p :- \+ q` y `q :- \+ p` tienen dos modelos estables, los dos que la
semántica bien fundada deja indefinidos. `circular` no tiene ninguno: r no
puede estar en un modelo estable, porque con r en M el reducido no deriva r,
y sin r en M lo deriva. El juego j2 tiene dos, uno con a ganadora y otro con
b; los dos con c ganadora y d perdedora (prueba `estables_j2`). Un programa
estratificado tiene uno solo, su modelo estándar (prueba
`estable_estratificado`). El método prueba todos los subconjuntos de lo
posible, y su costo crece como $2^n$: con los 36 átomos posibles de `grafo`
serían más de sesenta mil millones de candidatos.

## 13

<!-- ejemplo: capitulo-38/soluciones.pl predicado: alcanzables/2 es_arco/1 -->
```prolog
%!  alcanzables(+N:integer, -Clausulas:list) is det.
%
%   Clausulas son las de alcanza/1, los nodos a los que se llega desde el 0,
%   sobre los N arcos en fila de cadena/2.
alcanzables(N, Clausulas) :-
    cadena(N, Cadena),
    include(es_arco, Cadena, Arcos),
    append(Arcos,
           [ (alcanza(Y) :- arco(0, Y)),
             (alcanza(Y) :- alcanza(Z), arco(Z, Y)) ],
           Clausulas).

%!  es_arco(+Clausula) is semidet.
%
%   Clausula es un hecho arco/2.
es_arco(arco(_, _) :- true).
```

```prolog
?- semi_ingenua(alcanzables(40), [], _, C).
C = costo(42, 80).

?- semi_ingenua(cadena(40), [], _, C).
C = costo(42, 860).
```

`alcanza/1` tiene 40 átomos, uno por nodo alcanzable, y la evaluación hace
80 derivaciones, una por átomo del modelo, entre arcos y `alcanza/1` (prueba
`alcanza`), contra 860 de `camino/2`. De los 820 caminos, la consulta
`camino(0, Y)` necesitaba 40, los que salen de 0: el resto es trabajo sin
uso. Especializar el programa para el primer argumento es lo que la
transformación mágica hace de manera automática.

## 14

<!-- ejemplo: capitulo-38/soluciones.pl predicado: semi_ingenua_estricta_de/4 viejos/3 cadena_doble/2 -->
```prolog
%!  semi_ingenua_estricta_de(+Clausulas:list, +I0:list, -M:list,
%!                            -Costo) is det.
%
%   El mismo M que semi_ingenua_de/4, sin derivaciones repetidas: en cada
%   paso, una derivación se cuenta en la primera posición del cuerpo que usa
%   un átomo nuevo. Los átomos anteriores se toman de los viejos, y los
%   posteriores de todos.
semi_ingenua_estricta_de(Clausulas, I0, M, Costo) :-
    derivar(Clausulas, I0, I0, Cabezas),
    length(Cabezas, D),
    sort(Cabezas, T),
    ord_subtract(T, I0, Nuevos),
    ord_union(I0, Nuevos, I1),
    estricta(Clausulas, I0, I1, Nuevos, M, costo(1, D), Costo).

%!  viejos(+Literales:list, +Viejos:list, +I:list) is nondet.
%
%   Cada uno de Literales es verdadero con sus átomos en Viejos; los
%   negados se evalúan contra I.
viejos([], _, _).
viejos([L|Ls], Viejos, I) :-
    cumple(L, Viejos, I),
    viejos(Ls, Viejos, I).

%!  cadena_doble(+N:integer, -Clausulas:list) is det.
%
%   Clausulas son los N arcos en fila de cadena/2 con camino/2 definido por
%   dos llamadas recursivas.
cadena_doble(N, Clausulas) :-
    cadena(N, Cadena),
    include(es_arco, Cadena, Arcos),
    append(Arcos,
           [ (camino(X, Y) :- arco(X, Y)),
             (camino(X, Y) :- camino(X, Z), camino(Z, Y)) ],
           Clausulas).
```

```prolog
?- semi_ingenua(cadena_doble(20), [], _, C1), semi_ingenua_estricta(cadena_doble(20), [], _, C2), ingenua(cadena_doble(20), [], _, C3).
C1 = costo(8, 1600),
C2 = costo(8, 1370),
C3 = costo(8, 4055).
```

Con dos literales recursivos, una derivación que usa dos caminos nuevos se
cuenta dos veces en `semi_ingenua_de/4`, una por cada posición, y una sola en la
estricta: 1 600 contra 1 370. Las dos quedan lejos de las 4 055 de la
ingenua. Los pasos son 8, no 22: cada paso duplica el largo de los caminos
que se conocen. Los tres métodos dan el mismo modelo (prueba
`estricta_doble`). Con un solo literal recursivo, como en `cadena(N)`, las dos
versiones cuentan lo mismo, porque ninguna derivación usa dos átomos nuevos
(prueba `estricta_simple`).

## 15

<!-- ejemplo: capitulo-38/soluciones_experto.pl predicado: con_herbivoros/2 generado/2 -->
```prolog
%!  con_herbivoros(+Version:atom, -Clausulas:list) is det.
%
%   Clausulas son las de la versión puede_volar de la base con las reglas
%   nuevas de Version, ciclo o corregida.
con_herbivoros(Version, Clausulas) :-
    must_be(oneof([ciclo, corregida]), Version),
    base(puede_volar, Base),
    findall(C,
            ( nueva(Version, _, Regla),
              regla_clausula(Regla, C) ),
            Nuevas),
    append(Base, Nuevas, Clausulas).

%!  generado(+Programa, -Clausulas:list) is semidet.
%
%   El programa herbivoros(Version): las cláusulas de con_herbivoros/2.
generado(herbivoros(Version), Clausulas) :-
    con_herbivoros(Version, Clausulas).
```

La observación `tiene_pelo` se agrega con el programa
`con_hechos(Programa, Hechos)` de `experto.pl`, como en
`diagnostico/3` de la [sección 38.7](index.md#387-las-reglas-del-sistema-experto):

```prolog
?- estratos(herbivoros(ciclo), E).
false.

?- ciclos_negativos(herbivoros(ciclo), P).
P = [herbivoro/0-carnivoro/0].

?- valor(con_hechos(herbivoros(ciclo), [tiene_pelo]), carnivoro, C), valor(con_hechos(herbivoros(ciclo), [tiene_pelo]), herbivoro, H).
C = H, H = indefinido.
```

`herbivoro` usa `carnivoro` negado, y r15 hace que `carnivoro` dependa de
`herbivoro`: el ciclo pasa por una negación, y la base deja de ser
estratificada. Con solo `tiene_pelo`, un mamífero es herbívoro si no es
carnívoro, y carnívoro si es herbívoro y no tiene cascos: las dos lecturas
son posibles, y los dos átomos quedan indefinidos. Si además se observa
`come_carne`, r5 decide, y el ciclo no deja nada indefinido (prueba
`come_carne`). La corrección es que r14 dependa de una observación en lugar
de una conclusión, `si mamifero y no come_carne entonces herbivoro`, y quitar
r15:

```prolog
?- estratos(herbivoros(corregida), [_|S]).
S = [1-[avestruz/0, herbivoro/0, pinguino/0], 2-[puede_volar/0]].

?- valor(con_hechos(herbivoros(corregida), [tiene_pelo]), carnivoro, C), valor(con_hechos(herbivoros(corregida), [tiene_pelo]), herbivoro, H).
C = falso,
H = verdadero.
```
