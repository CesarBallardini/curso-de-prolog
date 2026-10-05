# Soluciones del capítulo 67 — Proyecto: aprender reglas de ejemplos

Las soluciones de los ejercicios 2 a 11 están en
`ejemplos/capitulo-67/soluciones.pl`, que carga la versión 5
(`recursion.pl`, que reexporta las anteriores: `descendente.pl`,
`ascendente.pl`, `subsuncion.pl`, `generalizar.pl` y `familia.pl`) y agrega los predicados que
piden los ejercicios. Los que cambian un predicado interno de una versión
lo hacen sobre una copia con otro nombre. Las pruebas están en
`soluciones.plt`.

## Ejercicio 1

Con `subsuncion.pl` cargado:

<!-- contexto: capitulo-67/subsuncion.pl -->
```prolog
?- lgg(f(g(a), a), f(g(b), b), G).
G = f(g(_A), _A).

?- lgg([1, 2, 3], [4, 5], G).
G = [_, _|_].

?- subsume((p(X) :- [q(X, Y)]), (p(a) :- [q(a, a)])).
true.

?- subsume((p(a) :- []), (p(X) :- [])).
false.
```

El par `a`–`b` aparece dos veces, dentro de `g/1` y como segundo
argumento, y recibe la misma variable. Las dos listas tienen distinta
longitud: la lgg conserva lo que tienen en común, dos celdas `'[|]'`, y
pone variables en los elementos, que difieren, y en el resto, `[3]` contra
`[]`. En la tercera consulta, θ = {X/a, Y/a}: dos variables distintas
pueden ir al mismo término. En la cuarta, la cláusula `p(a)` es **más
específica** que `p(X)`: para subsumirla habría que sustituir la X de la
segunda cláusula, y `subsume/2` la congela.

## Ejercicio 2

<!-- ejemplo: capitulo-67/soluciones.pl predicado: lgg_lista/2 -->
```prolog
%!  lgg_lista(+Ts:list, -G) is det.
%
%   G es la lgg de todos los términos de la lista no vacía Ts: la lgg del
%   primero con el segundo, la de ese resultado con el tercero, y así.
lgg_lista([T|Ts], G) :-
    foldl(lgg_con, Ts, T, G).
```

```prolog
?- lgg_lista([pertenece(1, [1]), pertenece(z, [z, y]), pertenece(b, [b, c, d])], G).
G = pertenece(_A, [_A|_]).

?- lgg_lista([pertenece(b, [b, c, d]), pertenece(1, [1]), pertenece(z, [z, y])], G).
G = pertenece(_A, [_A|_]).
```

La lgg de dos términos es su menor cota superior en el orden de la
θ-subsunción: la generalización común que es caso particular de todas las
demás. La lgg de una lista es entonces la menor cota superior del
conjunto, que no depende del orden en que se agregan los términos: la de
T1 y T2 generaliza a los dos, y su lgg con T3 es la menor generalización
de los tres. El resultado es el mismo salvo el nombre de las variables, y
eso es lo que verifica la prueba con las seis permutaciones, comparando
con `=@=`. `lgg_lista/2` es `det`: la lista llega con al menos un término,
y cada paso de `foldl/4` tiene una sola respuesta.

## Ejercicio 3

<!-- ejemplo: capitulo-67/soluciones.pl predicado: reducida/2 -->
```prolog
%!  reducida(+C0, -C) is det.
%
%   C es la cláusula C0 sin los literales redundantes: se quita un
%   literal si la cláusula actual subsume a la que queda sin él. C y C0
%   se subsumen mutuamente.
reducida((H :- B0), (H :- B)) :-
    sin_redundantes(B0, [], H, B).
```

```prolog
?- lgg_clausula((p(a) :- [q(a, b), q(a, c)]), (p(d) :- [q(d, e)]), C), reducida(C, R).
C = (p(_A):-[q(_A, _), q(_A, _B)]),
R = (p(_A):-[q(_A, _B)]).
```

La lgg tiene un literal por cada par: `q(a, b)` con `q(d, e)` y `q(a, c)`
con `q(d, e)`, con variables distintas. Uno de los dos es redundante:
la cláusula completa subsume a la que tiene solo el segundo, con la
sustitución que lleva la variable del primero a la del segundo. Quitar un
literal da una cláusula más general, que por eso subsume a la original;
si además la original la subsume, las dos se implican mutuamente y son
equivalentes.

## Ejercicio 4

<!-- ejemplo: capitulo-67/soluciones.pl predicado: reducir_corta/4 -->
```prolog
%!  reducir_corta(+C0, +Negs:list, +M:list, -C) is semidet.
%
%   C es la más corta de las reducciones de C0 con el cuerpo en su orden y
%   en el inverso; la primera, si tienen la misma longitud. Falla si C0
%   cubre un negativo.
reducir_corta((H :- B0), Negs, M, C) :-
    reducir((H :- B0), Negs, M, C1),
    reverse(B0, B1),
    reducir((H :- B1), Negs, M, C2),
    C1 = (_ :- L1),
    C2 = (_ :- L2),
    length(L1, N1),
    length(L2, N2),
    (   N2 < N1
    ->  C = C2
    ;   C = C1
    ).
```

`aprender_asc_con/4` es el algoritmo de cobertura de la versión 3 con el
predicado de reducción como argumento, y `aprender_asc_corta/3` lo llama
con `reducir_corta/4`:

```prolog
?- aprender_asc_corta(abuelo, H, N).
H = [(abuelo(_A, _B):-[progenitor(_C, _B), padre(_A, _C)])],
N = 3.
```

Es la regla esperada, con los literales en el orden inverso. El criterio
sigue siendo local: se comparan dos órdenes entre los n! posibles, y nada
garantiza que uno de ellos dé la reducción más corta.

## Ejercicio 5

```prolog
?- aprender_asc(abuela, H, _), modelo_fondo(M), evaluar_en(abuela, H, M, A, FP, FN).
H = [(abuela(marta, _A):-[progenitor(pedro, _A)])],
M = [mujer(ana), mujer(eva), mujer(marta), mujer(sofia), varon(juan), varon(luis), varon(pedro), madre(eva, sofia), madre(..., ...)|...],
A = 2,
FP = FN, FN = 0.

?- aprender_desc(abuela, H, _), modelo_fondo(M), evaluar_en(abuela, H, M, A, FP, FN).
H = [(abuela(_A, _B):-[padre(_C, _B), madre(_A, _C)])],
M = [mujer(ana), mujer(eva), mujer(marta), mujer(sofia), varon(juan), varon(luis), varon(pedro), madre(eva, sofia), madre(..., ...)|...],
A = 2,
FP = FN, FN = 0.
```

Las dos hipótesis tienen la misma extensión en la familia, los dos
nietos de marta, y las dos son más específicas que la regla del
[capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md): la primera nombra a marta y a pedro, la segunda solo admite
abuelas por parte de padre. La versión 3 conserva las constantes porque la
lgg solo reemplaza por una variable lo que difiere, y marta está en los
dos ejemplos. La versión 4 parte de una cabeza con variables distintas y
sus refinamientos solo unifican variables o agregan literales con
variables: el lenguaje de hipótesis no tiene constantes, y ninguna
cláusula de la búsqueda puede nombrar a marta.

## Ejercicio 6

<!-- ejemplo: capitulo-67/soluciones.pl predicado: hermano_con_tomas/3 -->
```prolog
%!  hermano_con_tomas(-Pos:list, -H:list, -N:integer) is det.
%
%   Pos son los positivos de hermano/2 en la familia con tomas, y H la
%   hipótesis de ascendente/5 para ellos; N es la cantidad de rlgg.
hermano_con_tomas(Pos, H, N) :-
    modelo_con_tomas(M),
    personas_de(M, Personas),
    findall(hermano(A, B),
            ( member(varon(A), M),
              member(progenitor(P, A), M),
              member(progenitor(P, B), M),
              A \== B ),
            Pos0),
    sort(Pos0, Pos),
    findall(hermano(A, B),
            ( member(A, Personas),
              member(B, Personas),
              \+ memberchk(hermano(A, B), Pos) ),
            Negs),
    ascendente(Pos, Negs, M, H, N).
```

```prolog
?- hermano_con_tomas(Pos, H, N).
Pos = [hermano(luis, eva), hermano(pedro, ana), hermano(pedro, tomas), hermano(tomas, ana), hermano(tomas, pedro)],
H = [(hermano(_A, _B):-[mujer(_B), varon(_A), progenitor(_C, _B), progenitor(_C, _A)]), (hermano(pedro, tomas):-[]), (hermano(tomas, pedro):-[])],
N = 11.

?- rlgg_con_distintos(Hechos, Literales).
Hechos = 82,
Literales = 3208.
```

La cláusula con `mujer(B)` cubre los tres positivos con una hermana, y los
dos pares de varones quedan como hechos. Una cláusula que los cubra no
puede exigir `mujer(B)`, y sin esa condición, o una que diga que A y B son
distintos, cubre `hermano(pedro, pedro)`: pedro es varón y comparte
progenitores consigo mismo. En el lenguaje de la familia no hay otro
literal que separe a una persona de sí misma, así que no hay cláusula
consistente.

Los hechos `distintos/2` agregan esa condición, pero son 56 (ocho personas
por siete), y la rlgg tiene un literal por cada par de hechos del mismo
predicado: más de 3 000 literales enlazados, que la reducción tendría que
probar contra cada negativo. Una condición como «distintos» se agrega
mejor como un predicado que se evalúa, fuera del modelo, que como una
tabla de hechos.

## Ejercicio 7

<!-- ejemplo: capitulo-67/soluciones.pl predicado: sin_poda/9 -->
```prolog
%!  sin_poda(+D:integer, +C, +E, +Negs:list, +M:list, +L:list, -R,
%!           +N0:integer, -N:integer) is det.
%
%   buscar/6 de la versión 4 sin el filtro de los hijos.
sin_poda(D, C, E, Negs, M, L, R, N0, N) :-
    (   cubre(C, E, M),
        \+ cubre_alguno(C, Negs, M)
    ->  R = encontrada(C),
        N = N0
    ;   D > 0
    ->  findall(S, refinar(L, C, S), Hijos),
        length(Hijos, K),
        N1 is N0 + K,
        D1 is D - 1,
        sin_poda_en(Hijos, D1, E, Negs, M, L, R, N1, N)
    ;   R = ninguna,
        N = N0
    ).
```

```prolog
?- ejemplos(abuelo, [E|_], Negs), modelo_fondo(M), lenguaje(L), generadas_sin_poda(E, Negs, M, L, 2, N1), descendente([E], Negs, M, L, 2, _, N2).
E = abuelo(juan, eva),
Negs = [abuelo(ana, ana), abuelo(ana, eva), abuelo(ana, juan), abuelo(ana, luis), abuelo(ana, marta), abuelo(ana, pedro), abuelo(ana, sofia), abuelo(eva, ana), abuelo(..., ...)|...],
M = [mujer(ana), mujer(eva), mujer(marta), mujer(sofia), varon(juan), varon(luis), varon(pedro), madre(eva, sofia), madre(..., ...)|...],
L = [varon/1, mujer/1, padre/2, madre/2, progenitor/2],
N1 = 261,
N2 = 167.
```

Sin la poda, la búsqueda genera 261 cláusulas en lugar de 167. La
diferencia es pequeña porque la búsqueda termina en la primera cláusula
consistente, y con límite 2 la encuentra pronto: la poda ahorra más
cuanto más profunda es la búsqueda que falla, como la de `hermano/2` con
límite 3 de la [sección 67.5](index.md#675-version-4-induccion-descendente). La versión sin poda tiene además que verificar
que la cláusula consistente cubra el ejemplo, porque ya no lo garantiza el
recorrido.

## Ejercicio 8

```prolog
?- ejemplos(abuelo, Pos, _), modelo_fondo(M), lenguaje(L), inductivo(Pos, [abuelo(pedro, eva)], M, L, 3, H, N), evaluar_en(abuelo, H, M, A, FP, FN).
Pos = [abuelo(juan, eva), abuelo(juan, luis), abuelo(pedro, sofia)],
M = [mujer(ana), mujer(eva), mujer(marta), mujer(sofia), varon(juan), varon(luis), varon(pedro), madre(eva, sofia), madre(..., ...)|...],
L = [varon/1, mujer/1, padre/2, madre/2, progenitor/2],
H = [(abuelo(_A, _B):-[padre(_A, _C), progenitor(_C, _B)])],
N = 403,
A = 3,
FP = FN, FN = 0.

?- ejemplos(abuelo, Pos, _), modelo_fondo(M), lenguaje(L), inductivo(Pos, [abuelo(juan, ana)], M, L, 3, H, N), evaluar_en(abuelo, H, M, A, FP, FN).
Pos = [abuelo(juan, eva), abuelo(juan, luis), abuelo(pedro, sofia)],
M = [mujer(ana), mujer(eva), mujer(marta), mujer(sofia), varon(juan), varon(luis), varon(pedro), madre(eva, sofia), madre(..., ...)|...],
L = [varon/1, mujer/1, padre/2, madre/2, progenitor/2],
H = [(abuelo(_, _A):-[madre(_A, _)]), (abuelo(_, _B):-[varon(_B)]), (abuelo(_C, _):-[padre(_, _C)])],
N = 87,
A = 3,
FP = 40,
FN = 0.
```

`abuelo(pedro, eva)` comparte el abuelo con `abuelo(pedro, sofia)` y la
nieta con `abuelo(juan, eva)`. Ninguna propiedad de A sola ni de B sola
lo separa de los positivos, y ninguna cláusula del nivel 1 es consistente
con él: todas las que cubren `abuelo(juan, eva)` cubren también el
negativo. En el nivel 2, la regla esperada es consistente (pedro es padre
de eva, no abuelo) y es la que cubre más positivos.

`abuelo(juan, ana)` no comparte nada de eso. En el nivel 1 hay cláusulas
consistentes que lo separan de cada positivo por una propiedad accidental
de una persona: eva es madre y ana no, luis es varón y ana no, pedro tiene
padre y juan no. Cada una cubre un solo positivo, y la hipótesis son tres
cláusulas que cubren 40 pares falsos. Un negativo sirve cuando se parece a
los positivos en todo menos en lo que la regla tiene que decir; ese es
«un casi ejemplo», y es el que obliga a la búsqueda a bajar de nivel.

## Ejercicio 9

```prolog
?- ejemplos(hermano, Pos, Negs), modelo_fondo(M), lenguaje(L), inductivo(Pos, Negs, M, L, 4, H, N).
Pos = [hermano(luis, eva), hermano(pedro, ana)],
Negs = [hermano(ana, ana), hermano(ana, eva), hermano(ana, juan), hermano(ana, luis), hermano(ana, marta), hermano(ana, pedro), hermano(ana, sofia), hermano(eva, ana), hermano(..., ...)|...],
M = [mujer(ana), mujer(eva), mujer(marta), mujer(sofia), varon(juan), varon(luis), varon(pedro), madre(eva, sofia), madre(..., ...)|...],
L = [varon/1, mujer/1, padre/2, madre/2, progenitor/2],
H = [(hermano(_A, _B):-[varon(_A), mujer(_B), padre(_C, _A), padre(_C, _B)])],
N = 201669.
```

La cláusula es la misma que la de la versión 4 con límite 4, y cuesta 24
veces más: 201 669 cláusulas contra 8 352. La búsqueda por niveles genera
completos los tres primeros niveles antes de encontrar una cláusula
consistente en el cuarto; la búsqueda en profundidad termina en cuanto la
encuentra. Elegir la mejor cláusula obliga a ver todas las del nivel, y
el nivel crece en forma exponencial con la profundidad.

## Ejercicio 10

<!-- ejemplo: capitulo-67/soluciones.pl predicado: verdadero_ordenado/2 -->
```prolog
%!  verdadero_ordenado(?B:list, +M:list) is nondet.
%
%   Como verdadero/2 de la versión 3, pero prueba primero el literal que
%   unifica con menos átomos de M (el primero, si empatan), y falla en
%   cuanto uno no unifica con ninguno.
verdadero_ordenado([], _).
verdadero_ordenado([L|Ls], M) :-
    findall(K-I, ( nth1(I, [L|Ls], Literal),
                   aggregate_all(count, member(Literal, M), K) ),
            Cuentas),
    min_member(Kmin-Imin, Cuentas),
    Kmin > 0,
    nth1(Imin, [L|Ls], Elegido, Resto),
    member(Elegido, M),
    verdadero_ordenado(Resto, M).
```

`cubre_ordenado/3` y `reducir_ordenado/4` son `cubre/3` y `reducir/4` con
`verdadero_ordenado/2`:

```prolog
?- time(aprender_asc(abuelo, _, _)).
% 1,259,911 inferences, 0.172 CPU in 0.172 seconds (100% CPU, 7330391 Lips)
true.

?- time(aprender_asc_con(reducir_ordenado, abuelo, _, _)).
% 1,426,173 inferences, 0.281 CPU in 0.280 seconds (101% CPU, 5070837 Lips)
true.

?- time(aprender_asc(hermano, _, _)).
% 120,509 inferences, 0.016 CPU in 0.016 seconds (99% CPU, 7712576 Lips)
true.

?- time(aprender_asc_con(reducir_ordenado, hermano, _, _)).
% 401,270 inferences, 0.062 CPU in 0.073 seconds (86% CPU, 6420320 Lips)
true.
```

En la familia, elegir el literal cuesta más de lo que ahorra: contar los
candidatos de cada literal recorre el modelo entero en cada paso, y los
cuerpos, después de enlazarlos, tienen 18 literales. La rlgg
de `antepasado(juan, luis)` y `antepasado(pedro, sofia)`, con los 14
positivos en el modelo, tiene otro tamaño: `reducir_antepasado/2` con
`reducir/4` no termina en 60 segundos, y con `reducir_ordenado/4` termina
en 20 segundos (111 613 106 inferencias en esta máquina) con esta
cláusula, que no es recursiva:

```text
antepasado(A, B) :-
    progenitor(A, C),
    progenitor(D, E),
    progenitor(D, C),
    progenitor(E, B).
```

Decidir si un cuerpo con variables nuevas es verdadero en un modelo es un
problema difícil en general, y la reducción lo resuelve una vez por cada
literal y cada negativo. Flach, para simplificar, exige cláusulas sin
variables nuevas en el cuerpo; la versión 3 las admite enlazadas, y paga
este costo cuando el modelo crece.

## Ejercicio 11

<!-- ejemplo: capitulo-67/soluciones.pl predicado: haz/8 -->
```prolog
%!  haz(+D:integer, +K:integer, +Max:integer, +Frontera:list, +Problema,
%!      -R, +N0:integer, -N:integer) is det.
%
%   nivel/7 de la versión 5 con la frontera recortada a K cláusulas. Las
%   consistentes se buscan entre todas las cláusulas del nivel, antes de
%   recortarlo.
haz(D, K, Max, Frontera, E-Pos-Negs-M-L, R, N0, N) :-
    exclude(cubre_algun_negativo(Negs, M), Frontera, Consistentes),
    (   Consistentes = [_|_]
    ->  mejores(Consistentes, Pos, M, [C|_]),
        R = encontrada(C),
        N = N0
    ;   D < Max
    ->  mejores(Frontera, Pos, M, Ordenadas),
        primeros(K, Ordenadas, Haz),
        findall(S, ( member(C0, Haz),
                     refinar(L, C0, S) ),
                Todos),
        length(Todos, T),
        N1 is N0 + T,
        include(cubre_ej(E, M), Todos, Siguiente),
        D1 is D + 1,
        haz(D1, K, Max, Siguiente, E-Pos-Negs-M-L, R, N1, N)
    ;   R = ninguna,
        N = N0
    ).
```

```prolog
?- aprender_haz(1, antepasado, H, N).
H = [(antepasado(_A, _B):-[progenitor(_A, _B)]), (antepasado(_C, _D):-[progenitor(_C, _E), antepasado(_E, _D)])],
N = 139.

?- aprender_haz(3, hermano, H, N).
H = [(hermano(luis, eva):-[]), (hermano(pedro, ana):-[])],
N = 678.
```

| K | `antepasado/2` | `hermano/2` |
|---|---|---|
| 1 | 139 cláusulas, definición recursiva | 210, dos hechos |
| 3 | 272, definición recursiva | 678, dos hechos |
| 10 | 676, definición recursiva | 2 503, dos hechos |
| todas (versión 5) | 743, definición recursiva | 14 922, cláusula circular |

Las consistentes se buscan entre todas las cláusulas del nivel, antes de
recortarlo; si se recortara primero, un haz de 1 perdería
`progenitor(A, B)`, que no es la cláusula que cubre más positivos entre
las inconsistentes del nivel 1. Para `antepasado/2`, un haz de ancho 1 da
el mismo resultado con la quinta parte del trabajo. Para `hermano/2`, el
haz pierde la cláusula circular, que en el nivel 3 sale de cláusulas que
cubren pocos positivos: el resultado es mejor que el de la versión 5 por
accidente, porque la hipótesis de dos hechos por lo menos no es falsa. La
búsqueda en haz no es completa: una cláusula consistente puede quedar
fuera del haz en un nivel anterior.

## Ejercicio 12

La hipótesis guarda las cláusulas tal como están en la lista de
cláusulas posibles, sin instanciar, y cada uso toma una copia: así la
cláusula supuesta para el primer ejemplo sirve para los siguientes sin
quedar atada a sus constantes. El recorrido de los ejemplos es un
plegado sobre la hipótesis:

<!-- ejemplo: capitulo-67/soluciones_otras.pl predicado: inducir_todos/4 inducir_general/5 -->
```prolog
%!  inducir_todos(+Ejemplos:list, +Inducibles:list, +Fondo:list, -H:list)
%!      is nondet.
%
%   H es una lista de cláusulas de Inducibles, sin instanciar, con las que
%   se prueban todos los Ejemplos junto con los hechos de Fondo. Una
%   cláusula supuesta para un ejemplo se reutiliza, renombrada, para los
%   siguientes.
inducir_todos(Ejemplos, Inducibles, Fondo, H) :-
    foldl(inducir_general(Inducibles, Fondo), Ejemplos, [], H).

%!  inducir_general(+Inducibles:list, +Fondo:list, +Meta, +H0:list,
%!                  -H:list) is nondet.
%
%   Como inducir/5, pero las cláusulas de H0 y H no están instanciadas:
%   cada uso es una copia.
inducir_general(_, Fondo, Meta, H, H) :-
    member(Meta, Fondo).
inducir_general(Inducibles, Fondo, Meta, H0, H) :-
    member(C, H0),
    copy_term(C, (Meta :- Cuerpo)),
    foldl(inducir_general(Inducibles, Fondo), Cuerpo, H0, H).
inducir_general(Inducibles, Fondo, Meta, H0, H) :-
    member(R, Inducibles),
    \+ ( member(C, H0),
         C =@= R ),
    copy_term(R, (Meta :- Cuerpo)),
    foldl(inducir_general(Inducibles, Fondo), Cuerpo, [R|H0], H).
```

La consulta
`once(inducir_todos(Pos, Is, M, H)), maplist(mostrar, H)`, con los
positivos de `abuelo/2`, las cláusulas de `inducibles/2` y el modelo de
fondo, escribe:

```text
abuelo(A, B) :-
    varon(A),
    padre(A, C),
    progenitor(C, B).
```

La primera respuesta es una sola cláusula, la más larga de la lista, que
explica los tres ejemplos; `inducir/5` daba, para un solo ejemplo, diez
explicaciones instanciadas. Las respuestas siguientes recorren las demás
combinaciones de cláusulas: son muchas, y llegan hasta `abuelo(_, _)`.
Sin negativos, el orden de la lista de cláusulas posibles es lo único
que decide cuál se elige primero.

## Ejercicio 13

`listnum([], _)` es consistente porque ningún negativo tiene la primera
lista vacía y la segunda no. Con el negativo `listnum([], [uno])`, la
búsqueda refuta esa cláusula y prueba la siguiente en el orden de los
refinamientos, que reemplaza primero la segunda variable: `listnum(_,
[])`, consistente porque ningún negativo tiene la segunda lista vacía y
la primera no. Hacen falta los dos negativos:

<!-- ejemplo: capitulo-67/soluciones_otras.pl predicado: numerales_corregidos/1 -->
```prolog
%!  numerales_corregidos(-H:list) is semidet.
%
%   H es la hipótesis de mis/4 para los ejemplos de numerales con dos
%   negativos más después del primer positivo: listnum([], [uno]) y
%   listnum([uno], []).
numerales_corregidos(H) :-
    mis(numerales,
        [ pos(listnum([], [])),
          neg(listnum([], [uno])),
          neg(listnum([uno], [])),
          neg(listnum([uno], [uno])),
          neg(listnum([1, dos], [uno, dos])),
          pos(listnum([1], [uno])),
          neg(listnum([cuatro, dos], [4, dos])),
          pos(listnum([cuatro], [4]))
        ], H, _).
```

La consulta `numerales_corregidos(H), maplist(mostrar, H)` escribe:

```text
listnum([A|B], [C|D]) :-
    listnum(B, D),
    num(C, A).
listnum([A|B], [C|D]) :-
    listnum(B, D),
    num(A, C).
listnum([], []).
```

Es la hipótesis de Flach. Cada negativo descarta una de las dos maneras
de generalizar el caso base; en una búsqueda descendente, los negativos
son los que dicen hasta dónde especializar.
