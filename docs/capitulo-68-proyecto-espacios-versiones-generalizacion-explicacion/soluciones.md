# Soluciones del capítulo 68 — Proyecto: espacios de versiones y generalización por explicación

Las soluciones de los ejercicios 2 a 8, 10 y 11 están en
`ejemplos/capitulo-68/soluciones.pl`, que carga las versiones 4
(`preguntas.pl`) y 6 (`ebg.pl`), como `proyecto.pl`, y la versión 3 del
[capítulo 67](../capitulo-67-proyecto-aprender-reglas-ejemplos/index.md) para comparar con la inducción. La del ejercicio 9 está
en `soluciones_ebg.pl`. Las pruebas están en `soluciones.plt` y
`soluciones_ebg.plt`.

## Ejercicio 1

Con `candidatos.pl` cargado:

<!-- contexto: capitulo-68/candidatos.pl -->
```prolog
?- eliminar([pos(pieza(cilindro, azul, grande, metal)), neg(pieza(cilindro, azul, chico, metal))], EV), entre_bordes(EV, N).
EV = ev([pieza(cilindro, azul, grande, metal)], [pieza(_, _, grande, _)]),
N = 8.

?- eliminar([pos(pieza(cilindro, azul, grande, metal)), neg(pieza(cilindro, azul, chico, metal)), neg(pieza(cubo, azul, grande, metal))], EV), estado(EV, E).
EV = ev([pieza(cilindro, azul, grande, metal)], [pieza(cilindro, _, grande, _)]),
E = abierto.
```

El positivo lleva S a la instancia misma. El negativo difiere de él solo
en el tamaño, así que la única especialización de `pieza(_, _, _, _)` que
lo excluye y sigue encima de S fija el tamaño en `grande`. Entre
`pieza(_, _, grande, _)` y la instancia están los conceptos que conservan
`grande` y liberan cualquier subconjunto de los otros tres atributos:
2³ = 8. El tercer ejemplo, un cubo, obliga a fijar también la forma. El
espacio queda abierto: entre `pieza(cilindro, _, grande, _)` y S hay
cuatro conceptos, según se fijen o no el color y el material.

## Ejercicio 2

<!-- ejemplo: capitulo-68/soluciones.pl predicado: ejemplos_de/2 eliminar_todos/2 todos_convergen/0 -->
```prolog
%!  ejemplos_de(+C, -Ejs:list) is det.
%
%   Ejs son las 36 instancias, en el orden de instancia/1, con la clase
%   que les da el concepto C.
ejemplos_de(C, Ejs) :-
    findall(Ej, ( instancia(I),
                  objetivo(C, I, Ej) ), Ejs).

%!  eliminar_todos(+C, -EV) is det.
%
%   EV es el espacio de versiones de las 36 instancias clasificadas por C.
eliminar_todos(C, EV) :-
    ejemplos_de(C, Ejs),
    eliminar(Ejs, EV).

%!  todos_convergen is semidet.
%
%   Para cada concepto C distinto de vacio, eliminar/2 converge a C con
%   los ejemplos de ejemplos_de/2.
todos_convergen :-
    forall(( concepto(C),
             C \== vacio ),
           ( eliminar_todos(C, EV),
             estado(EV, convergio(D)),
             D =@= C )).
```

<!-- contexto: capitulo-68/soluciones.pl -->
```prolog
?- todos_convergen.
true.

?- eliminar_todos(vacio, EV), estado(EV, E).
EV = ev([vacio], []),
E = colapso.
```

Con las 36 instancias clasificadas, cada concepto distinto de `vacio`
queda como único consistente: dos conceptos distintos del lenguaje cubren
conjuntos distintos de instancias, y alguna instancia los separa. Con
`vacio` todas las instancias son negativas. S conserva `vacio`, que no
cubre ninguna, pero G colapsa: las especializaciones de G son siempre
piezas, y cuando el último negativo es una instancia de la que G tiene un
concepto sin atributos libres, no hay especialización que la excluya. El
lenguaje tiene `vacio` debajo de todo, pero la especialización mínima no
llega a él. Una corrección es permitir que `especializacion/3` dé `vacio`
cuando el concepto no tiene atributos libres.

## Ejercicio 3

<!-- ejemplo: capitulo-68/soluciones.pl predicado: con_interior/1 generalizacion_ingenua/3 -->
```prolog
%!  con_interior(:Meta) is semidet.
%
%   Prueba Meta con un quinto atributo, interior, cuyos valores rojo y
%   verde repiten valores de color.
con_interior(Meta) :-
    setup_call_cleanup(assertz(espacio:atributo(interior, [rojo, verde])),
                       once(Meta),
                       retract(espacio:atributo(interior, [rojo, verde]))).

%!  generalizacion_ingenua(+S, +I, -S1) is det.
%
%   Como generalizacion/3, con lgg_ingenua/3: cada diferencia recibe su
%   propia variable, y el resultado nunca exige que dos atributos
%   coincidan.
generalizacion_ingenua(S, I, S1) :-
    (   S == vacio
    ->  S1 = I
    ;   lgg_ingenua(S, I, S1)
    ).
```

La primera consulta usa `generalizacion/3`, de `unidireccional.pl`, y
`concepto/1`, de `espacio.pl`, con el atributo agregado:

```prolog
?- con_interior(( generalizacion(pieza(esfera, rojo, chico, madera, rojo), pieza(esfera, verde, chico, madera, verde), C), \+ ( concepto(D), D =@= C ) )).
C = pieza(esfera, _A, chico, madera, _A).

?- generalizacion_ingenua(pieza(esfera, rojo, chico, madera, rojo), pieza(esfera, verde, chico, madera, verde), C).
C = pieza(esfera, _, chico, madera, _).
```

La lgg ve dos veces el par `rojo`–`verde`, en el color y en el interior,
y le da la misma variable: el resultado dice «el color y el interior son
iguales», y ningún concepto del lenguaje, donde cada atributo es un valor
o una variable propia, es una variante de él. La lgg es la menor
generalización en el lenguaje de todos los términos; aquí el lenguaje es
más chico, y en él la generalización mínima reemplaza cada diferencia por
una variable propia, que es lo que hace `lgg_ingenua/3`. Lo que en el
[capítulo 67](../capitulo-67-proyecto-aprender-reglas-ejemplos/index.md) era un defecto es aquí la operación correcta.

## Ejercicio 4

<!-- ejemplo: capitulo-68/soluciones.pl predicado: cuenta_clases/3 -->
```prolog
%!  cuenta_clases(-Pos:integer, -Neg:integer, -Desc:integer) is det.
%
%   Cantidad de instancias positivas, negativas y desconocidas según el
%   espacio de los tres primeros ejemplos de esfera_roja.
cuenta_clases(Pos, Neg, Desc) :-
    eliminar_de(esfera_roja, 3, EV),
    aggregate_all(count, ( instancia(I), clasificar(EV, I, positivo) ),
                  Pos),
    aggregate_all(count, ( instancia(I), clasificar(EV, I, negativo) ),
                  Neg),
    aggregate_all(count, ( instancia(I), clasificar(EV, I, desconocido) ),
                  Desc).
```

```prolog
?- cuenta_clases(P, N, D).
P = 4,
N = D, D = 16.
```

Las positivas son las cuatro esferas rojas. Las negativas son las 16 que
no son esferas ni rojas: 2 formas por 2 colores por 4 combinaciones de
tamaño y material. Las 16 restantes son las esferas no rojas y las piezas
rojas que no son esferas, 8 y 8, y `desconocidas_esperadas/0` verifica que
son esas.

## Ejercicio 5

<!-- ejemplo: capitulo-68/soluciones.pl predicado: pasivo_inverso/3 promedio_inverso/1 -->
```prolog
%!  pasivo_inverso(+C, -N:integer, -E) is det.
%
%   Como pasivo/3, con las instancias en el orden inverso al de
%   instancia/1 después del primer positivo.
pasivo_inverso(C, N, E) :-
    primer_positivo(C, I),
    findall(Ej, ( instancia(J),
                  J \== I,
                  objetivo(C, J, Ej) ), Ejs0),
    reverse(Ejs0, Ejs),
    inicial(EV0),
    actualizar(pos(I), EV0, EV),
    recibir(Ejs, EV, 1, N, E).

%!  promedio_inverso(-P:float) is det.
%
%   P es el promedio de ejemplos de pasivo_inverso/3 sobre los conceptos
%   distintos de vacio, redondeado a dos decimales.
promedio_inverso(P) :-
    aggregate_all(bag(N), ( concepto(C),
                            C \== vacio,
                            pasivo_inverso(C, N, _) ), Ns),
    sum_list(Ns, Suma),
    length(Ns, K),
    P is round(Suma / K * 100) / 100.0.
```

```prolog
?- promedio_inverso(P).
P = 18.74.
```

El promedio baja de 21,39 a 18,74. El orden de `instancia/1` empieza por
las esferas rojas chicas de madera y termina con los cilindros azules
grandes de metal. Un concepto converge cuando llegaron los ejemplos que
descartan cada alternativa, y el orden decide cuándo llegan. Para el
aprendiz pasivo el orden es un dato que no controla, y su promedio
depende de él; el activo, que elige, necesita cinco en cualquier caso.

## Ejercicio 6

<!-- ejemplo: capitulo-68/soluciones.pl predicado: eliminar_con_descarte/3 con_descarte/3 -->
```prolog
%!  eliminar_con_descarte(+Ejs:list, -EV, -Descartados:list) is det.
%
%   EV es el espacio de versiones de los ejemplos de Ejs, salvo los que lo
%   harían colapsar, que se ignoran y quedan en Descartados, en el orden
%   en que llegaron.
eliminar_con_descarte(Ejs, EV, Descartados) :-
    inicial(EV0),
    foldl(con_descarte, Ejs, EV0-[], EV-Inv),
    reverse(Inv, Descartados).

%!  con_descarte(+Ej, +Estado0, -Estado) is det.
%
%   Estado es EV-Ds después de Ej: si actualizar EV0 con Ej lo hace
%   colapsar, EV es EV0 y Ej se agrega a Ds.
con_descarte(Ej, EV0-Ds0, EV-Ds) :-
    actualizar(Ej, EV0, EV1),
    (   estado(EV1, colapso)
    ->  EV = EV0,
        Ds = [Ej|Ds0]
    ;   EV = EV1,
        Ds = Ds0
    ).
```

```prolog
?- eliminar_con_descarte_de(3, EV, D).
EV = ev([pieza(esfera, rojo, _, _)], [pieza(esfera, rojo, _, _)]),
D = [neg(pieza(esfera, rojo, grande, madera))].

?- eliminar_con_descarte_de(0, EV, D).
EV = ev([pieza(esfera, rojo, chico, madera)], [pieza(_, rojo, chico, _)]),
D = [pos(pieza(esfera, rojo, grande, metal))].
```

Con el error en tercer lugar, el espacio ya tiene S = esferas rojas, y el
negativo erróneo lo vaciaría: se descarta, y el aprendizaje termina bien.
Con el error primero, el espacio lo acepta, porque todavía hay conceptos
que lo excluyen; el que se descarta después es el positivo correcto
`pieza(esfera, rojo, grande, metal)`, y el resultado es falso. El descarte
elige el último ejemplo del conflicto, no el erróneo: nada en el espacio
de versiones distingue cuál de los dos es el equivocado.

## Ejercicio 7

<!-- contexto: capitulo-68/ebg.pl -->
La consulta `operacionales(taza, Ops), mostrar_aprendida_con(taza, [tiene_asa/1, estable/1|Ops], taza1, taza(taza1))` escribe:

```prolog
taza(A) :-
    peso(A, B),
    B<400,
    tiene_asa(A),
    parte(A, C),
    concava(C),
    abierta_arriba(C),
    estable(A).
```

Siete condiciones en lugar de diez: `tiene_asa/1` y `estable/1` quedan
enteras y reemplazan a las dos o tres condiciones de cada una, y
`se_levanta/1`, que no es operacional, se sigue desplegando.

## Ejercicio 8

<!-- ejemplo: capitulo-68/soluciones.pl predicado: reglas_abuelo/1 sin_subsumidas/2 cobertura_abuelo/2 -->
```prolog
%!  reglas_abuelo(-Rs:list) is det.
%
%   Rs son las reglas de abuelo/2 aprendidas de cada positivo de
%   ejemplos/3, sin las que otra regla de la lista subsume.
reglas_abuelo(Rs) :-
    ejemplos(abuelo, Pos, _),
    findall(R, ( member(E, Pos),
                 aprender(familia, familia, E, R) ), Rs0),
    sin_subsumidas(Rs0, Rs).

%!  sin_subsumidas(+Rs0:list, -Rs:list) is det.
%
%   Rs son las reglas de Rs0, en su orden, salvo las que una regla
%   anterior de Rs subsume.
sin_subsumidas(Rs0, Rs) :-
    foldl(agregar_si_nueva, Rs0, [], Inv),
    reverse(Inv, Rs).

%!  cobertura_abuelo(-P:integer, -N:integer) is det.
%
%   P es la cantidad de positivos y N la de negativos de abuelo/2 que
%   cubre alguna regla de reglas_abuelo/1.
cobertura_abuelo(P, N) :-
    reglas_abuelo(Rs),
    ejemplos(abuelo, Pos, Negs),
    hechos(familia, Hs),
    aggregate_all(count, ( member(E, Pos), cubierto(Rs, Hs, E) ), P),
    aggregate_all(count, ( member(E, Negs), cubierto(Rs, Hs, E) ), N).
```

La consulta `forall((reglas_abuelo(Rs), member(R, Rs)), mostrar(R))` escribe:

```prolog
abuelo(A, B) :-
    varon(A),
    padre(A, C),
    padre(C, B).
abuelo(A, B) :-
    varon(A),
    padre(A, C),
    madre(C, B).
```

```prolog
?- cobertura_abuelo(P, N).
P = 3,
N = 0.
```

Los positivos `abuelo(juan, eva)` y `abuelo(juan, luis)` dan la misma
regla, que se subsumen entre sí; `abuelo(pedro, sofia)` da la segunda.
Las dos cubren los tres positivos y ningún negativo, como la hipótesis de
`aprender_asc/3`, que también es exacta en la familia. La diferencia está
en lo que cada una necesitó: la inducción, los 46 negativos y ninguna
teoría; la generalización por explicación, ningún negativo y la teoría
del [capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md), de la que las dos reglas son casos particulares.

## Ejercicio 9

<!-- ejemplo: capitulo-68/soluciones_ebg.pl predicado: regla_is/1 hechos_is/2 predefinido_is/1 generalizar_is//3 -->
```prolog
% regla_is(R): R es una regla de la teoría pesado.
regla_is((pesado(X) :- peso(X, P), volumen(X, V), D is P / V, D > 1)).

% hechos_is(E, Hs): Hs es la descripción del ejemplo E.
hechos_is(bloque1, [peso(bloque1, 3000), volumen(bloque1, 1000),
                    color(bloque1, gris)]).
hechos_is(corcho1, [peso(corcho1, 240), volumen(corcho1, 1000)]).

% predefinido_is(G): el intérprete ejecuta G con ejecutar_is/1.
predefinido_is(_ is _).
predefinido_is(_ < _).
predefinido_is(_ > _).

%!  generalizar_is(+Hs:list, +G, ?GG)// is nondet.
%
%   Como generalizar//5 de ebg.pl, con la teoría pesado.
generalizar_is(Hs, G, GG) -->
    (   { predefinido_is(G) }
    ->  { ejecutar_is(G) },
        [GG]
    ;   { operacionales_is(Ops),
          functor(G, Nombre, Aridad),
          memberchk(Nombre/Aridad, Ops) }
    ->  { explicar_is(Hs, G) },
        [GG]
    ;   { regla_is(R),
          copy_term(R, (G :- Cuerpo)),
          copy_term(R, (GG :- CuerpoG)) },
        generalizar_cuerpo_is(Hs, Cuerpo, CuerpoG)
    ).
```

```prolog
?- aprender_is(bloque1, pesado(bloque1), R).
R = (pesado(_A):-[peso(_A, _B), volumen(_A, _C), _D is _B/_C, _D>1]).
```

El cálculo queda entero en la regla: `D is B/C` con las variables
generales, no el valor 3 que dio la prueba de `bloque1`. En la prueba
particular `is/2` se ejecuta, porque la comparación que sigue necesita
el número; en la general se registra como condición, porque sus datos
dependen del objeto al que se aplique la regla. La regla no reconoce
`corcho1`, cuya densidad es 0,24.

## Ejercicio 10

<!-- ejemplo: capitulo-68/soluciones.pl predicado: reglas_de_tazas/1 costo_con/2 -->
```prolog
%!  reglas_de_tazas(-Rs:list) is det.
%
%   Rs son las reglas aprendidas de cada taza de la población, sin las
%   que una regla anterior subsume.
reglas_de_tazas(Rs) :-
    poblacion(Os),
    clasificar_con_teoria(taza, Tazas),
    findall(R, ( member(O, Tazas),
                 memberchk(O-Hs, Os),
                 operacionales(taza, Ops),
                 once(ebg(taza, Ops, Hs, taza(O), R)) ), Rs0),
    sin_subsumidas(Rs0, Rs).

%!  costo_con(+K:integer, -N:integer) is det.
%
%   N son las inferencias de reconocidas/3 con K reglas: las de
%   reglas_de_tazas/1 repetidas en ciclo hasta completar K.
costo_con(K, N) :-
    reglas_de_tazas(Rs),
    length(Rs, L),
    findall(R, ( between(1, K, J),
                 I is (J - 1) mod L,
                 nth0(I, Rs, R) ), Reglas),
    ebg:inferencias(reconocidas(taza, Reglas, _), N).
```

```prolog
?- costo_con(1, N1), costo_con(2, N2), costo_con(4, N4), costo_con(8, N8).
N1 = 7284,
N2 = 12756,
N4 = 21707,
N8 = 39609.
```

De las cuatro tazas salen dos reglas distintas. Con una sola regla el
costo es menor, pero se reconocen solo dos tazas. A partir de dos, cada
regla agregada no reconoce nada nuevo y el costo crece casi en
proporción: cada objeto que no es taza se prueba contra todas las reglas.
Es el **problema de la utilidad**: acumular reglas aprendidas puede hacer
más lento al programa que las usa, y conviene quitar las redundantes, como
hace `sin_subsumidas/2`, o medir cuánto se usa cada una.

## Ejercicio 11

<!-- ejemplo: capitulo-68/soluciones.pl predicado: relevantes/4 irrelevantes/4 hoja/2 -->
```prolog
%!  relevantes(+T, +E, +Meta, -Usados:list) is semidet.
%
%   Usados son los hechos de la descripción del ejemplo E que son hojas
%   de la primera explicación de Meta con la teoría T, en el orden de la
%   descripción. Falla si Meta no tiene explicación.
relevantes(T, E, Meta, Usados) :-
    hechos(E, Hs),
    once(explicar(T, Hs, Meta, Arbol)),
    findall(H, hoja(Arbol, H), Hojas),
    include(usado(Hojas), Hs, Usados).

%!  irrelevantes(+T, +E, +Meta, -Otros:list) is semidet.
%
%   Otros son los hechos de la descripción de E que la primera
%   explicación de Meta con la teoría T no usa.
irrelevantes(T, E, Meta, Otros) :-
    hechos(E, Hs),
    relevantes(T, E, Meta, Usados),
    exclude(usado(Usados), Hs, Otros).

%!  hoja(+Arbol, -H) is nondet.
%
%   H es un hecho que aparece como hoja prueba(H, []) del árbol Arbol.
hoja(prueba(H, []), H).
hoja(prueba(_, [A|As]), H) :-
    member(B, [A|As]),
    hoja(B, H).
```

```prolog
?- irrelevantes(taza, taza1, taza(taza1), O).
O = [material(taza1, loza), color(taza1, blanco), color(cuerpo1, blanco)].

?- relevantes(familia, familia, abuelo(juan, luis), U).
U = [varon(juan), padre(juan, pedro), padre(pedro, luis)].
```

Los dos predicados reciben la teoría, el ejemplo y el objetivo, y
devuelven una lista: los tres primeros argumentos son `+` y el cuarto
`-`. Son `semidet` y no `det`: fallan si el objetivo no tiene
explicación, como `taza(vaso1)`. Usan la primera explicación, con
`once/1`, porque otra explicación podría usar otros hechos, y el
resultado de un objetivo con varias pruebas no está definido por una
sola. De los 21 hechos del modelo de la familia, la explicación de
`abuelo(juan, luis)` usa tres.
