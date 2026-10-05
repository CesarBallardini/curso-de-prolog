# Soluciones del capítulo 68 — Proyecto: espacios de versiones y generalización por explicación

Las soluciones de los ejercicios 2 a 8, 10 y 11 están en
`ejemplos/capitulo-68/soluciones.pl`, que carga las versiones 4
(`preguntas.pl`) y 6 (`ebg.pl`), como `proyecto.pl`, y la versión 3 del
[capítulo 67](../capitulo-67-proyecto-aprender-reglas-ejemplos/index.md) para comparar con la inducción. La del ejercicio 9 está
en `soluciones_ebg.pl`, las de los ejercicios 12 y 13 en
`soluciones_v7.pl` y la del ejercicio 14 en `soluciones_interactivo.pl`.
Las pruebas de cada archivo están en el `.plt` del mismo nombre.

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

## Ejercicio 12

<!-- ejemplo: capitulo-68/soluciones_v7.pl predicado: disyunciones/2 sin_variantes/2 -->
```prolog
%!  disyunciones(+Nombre, -Ds:list) is det.
%
%   Ds son las disyunciones distintas que da disyuncion_de/2 con cada
%   orden de los positivos de la secuencia Nombre, seguidos de los
%   negativos.
disyunciones(Nombre, Ds) :-
    ejemplos_de(Nombre, Ejs),
    findall(pos(I), member(pos(I), Ejs), Pos),
    findall(neg(I), member(neg(I), Ejs), Negs),
    findall(D, ( permutation(Pos, Pos1),
                 append(Pos1, Negs, Ejs1),
                 disyuncion_de(Ejs1, D) ), Ds0),
    sin_variantes(Ds0, Ds).

%!  sin_variantes(+Ts:list, -Us:list) is det.
%
%   Us son los términos de Ts sin variantes repetidas, en el orden de su
%   primera aparición.
sin_variantes([], []).
sin_variantes([T|Ts], [T|Us]) :-
    exclude(=@=(T), Ts, Ts1),
    sin_variantes(Ts1, Us).
```

```prolog
?- disyunciones(esferas_y_cubos_verdes, Ds), length(Ds, N).
Ds = [[pieza(esfera, _, _, _), pieza(cubo, verde, grande, metal)], [pieza(_, _, grande, metal), pieza(esfera, rojo, chico, madera)]],
N = 2.

?- disyunciones(rojo_o_esfera, Ds).
Ds = [[pieza(esfera, verde, chico, madera), pieza(cubo, rojo, chico, madera)], [pieza(cubo, rojo, chico, madera), pieza(esfera, verde, chico, madera)]].
```

Los seis órdenes de los tres positivos de `esferas_y_cubos_verdes` dan
dos disyunciones distintas, según cuál de dos piezas llega antes. Si la
esfera roja llega antes que el cubo verde, las dos esferas se
generalizan juntas en `pieza(esfera, _, _, _)` y el cubo verde queda
solo. Si el cubo verde llega antes que la esfera roja, la esfera azul se
generaliza con él en `pieza(_, _, grande, metal)`, que tampoco cubre
ningún negativo, y la esfera roja queda sola: no se generaliza con ese
disyunto sin liberar los cuatro atributos. Las dos disyunciones son consistentes y clasifican
distinto a otras instancias: la primera acepta cualquier esfera, la
segunda cualquier pieza grande de metal.

El orden importa cuando un positivo se puede generalizar, sin cubrir
negativos, con más de un disyunto o con más de un positivo: el
procesamiento es voraz y toma la primera generalización consistente,
sin volver atrás. Con `rojo_o_esfera` ninguna generalización de los dos
positivos es consistente, y el orden solo cambia el orden de los
disyuntos.

## Ejercicio 13

<!-- ejemplo: capitulo-68/soluciones_v7.pl predicado: costos_incorporar/3 -->
```prolog
%!  costos_incorporar(-Recorrer:integer, -Teoria:integer,
%!      -Segunda:integer) is det.
%
%   Inferencias que usa reconocer las tazas de la población: Recorrer con
%   recorrer/2, que empieza sin reglas; Teoria con la teoría sola; y
%   Segunda en una segunda pasada, con las reglas que dejó la primera.
costos_incorporar(Recorrer, Teoria, Segunda) :-
    inferencias(recorrer(taza, _), Recorrer),
    inferencias(clasificar_con_teoria(taza, _), Teoria),
    recorrer(taza, _),
    poblacion(Os),
    inferencias(maplist(reconocer(taza), Os, _), Segunda).
```

```prolog
?- costos_incorporar(Recorrer, Teoria, Segunda).
Recorrer = 25855,
Teoria = 15390,
Segunda = 24735.
```

La primera pasada cuesta casi el doble que la teoría sola, y la segunda,
con las dos reglas ya guardadas, apenas menos que la primera. De los 48
objetos, 44 no son tazas, y para concluirlo `reconocer/3` agota primero
las reglas aprendidas y después la teoría: las reglas se suman al costo
de la teoría en lugar de reemplazarlo. Solo las cuatro tazas se
benefician, y en la segunda pasada las cuatro se reconocen con una regla,
lo que explica la diferencia entre `Recorrer` y `Segunda`.

Guardar las reglas abarataría el reconocimiento en una población donde
la mayoría de los objetos son tazas por las razones que las reglas ya
cubren: cada una se reconocería con una regla operacional, sin la
búsqueda de la teoría. Es otra forma del problema de la utilidad del
[ejercicio 10](#ejercicio-10): una regla aprendida conviene si el ahorro
en los casos que reconoce supera lo que cuesta probarla en los que no.

## Ejercicio 14

<!-- ejemplo: capitulo-68/soluciones_interactivo.pl predicado: aprender_interactivo/1 lazo/2 leer/1 paso/3 ejemplo_valido/1 -->
```prolog
%!  aprender_interactivo(-EV) is det.
%
%   Lee ejemplos de la entrada actual hasta el término fin o el final de
%   la entrada, y escribe los bordes y el estado después de cada uno. EV
%   es el espacio de versiones de los ejemplos bien formados. Mientras
%   lee, el indicador de la terminal es «ejemplo: ».
aprender_interactivo(EV) :-
    inicial(EV0),
    setup_call_cleanup(prompt(Anterior, 'ejemplo: '),
                       lazo(EV0, EV),
                       prompt(_, Anterior)).

%!  lazo(+EV0, -EV) is det.
%
%   EV es el espacio EV0 después de los ejemplos que quedan en la entrada
%   actual, hasta fin o el final de la entrada.
lazo(EV0, EV) :-
    leer(Lectura),
    (   Lectura = termino(T),
        ( T == end_of_file ; T == fin )
    ->  EV = EV0
    ;   paso(Lectura, EV0, EV1),
        lazo(EV1, EV)
    ).

%!  leer(-Lectura) is det.
%
%   Lectura es termino(T), con T el próximo término de la entrada actual,
%   o sintaxis(M), si el texto hasta el próximo punto final no es un
%   término; M describe el error.
leer(Lectura) :-
    catch(( read_term(T, []),
            Lectura = termino(T) ),
          error(syntax_error(M), _),
          Lectura = sintaxis(M)).

%!  paso(+Lectura, +EV0, -EV) is det.
%
%   EV es EV0 actualizado con el ejemplo leído, si está bien formado, y
%   EV0 en otro caso. Escribe el ejemplo con los bordes y el estado, o el
%   motivo por el que se ignora.
paso(Lectura, EV0, EV) :-
    (   Lectura = termino(T),
        ejemplo_valido(T)
    ->  actualizar(T, EV0, EV),
        mostrar_conceptos([T]),
        informar(EV)
    ;   Lectura = sintaxis(M)
    ->  EV = EV0,
        format("error de sintaxis (~w): se ignora~n", [M])
    ;   Lectura = termino(T),
        EV = EV0,
        format("ejemplo mal formado: "),
        mostrar_conceptos([T])
    ).

%!  ejemplo_valido(@T) is semidet.
%
%   T es pos(I) o neg(I), con I una instancia del lenguaje: una pieza sin
%   variables con un valor admitido en cada atributo.
ejemplo_valido(T) :-
    nonvar(T),
    T =.. [Clase, I],
    memberchk(Clase, [pos, neg]),
    ground(I),
    once(instancia(I)).
```

Con `soluciones_interactivo.pl` cargado, la consulta
`aprender_interactivo(EV)` muestra en la terminal la sesión siguiente. Lo
que sigue a cada `ejemplo: ` es lo que se escribe; el tercer ejemplo
tiene tres atributos en lugar de cuatro:

```text
ejemplo: pos(pieza(esfera, rojo, chico, madera)).
pos(pieza(esfera, rojo, chico, madera))
  S:
    pieza(esfera, rojo, chico, madera)
  G:
    pieza(_, _, _, _)
  abierto
ejemplo: neg(pieza(cilindro, verde, grande, metal)).
neg(pieza(cilindro, verde, grande, metal))
  S:
    pieza(esfera, rojo, chico, madera)
  G:
    pieza(esfera, _, _, _)
    pieza(_, rojo, _, _)
    pieza(_, _, chico, _)
    pieza(_, _, _, madera)
  abierto
ejemplo: pos(pieza(esfera, rojo, grande)).
ejemplo mal formado: pos(pieza(esfera, rojo, grande))
ejemplo: pos(pieza(esfera, rojo, grande, metal)).
pos(pieza(esfera, rojo, grande, metal))
  S:
    pieza(esfera, rojo, _, _)
  G:
    pieza(esfera, _, _, _)
    pieza(_, rojo, _, _)
  abierto
ejemplo: fin.
EV = ev([pieza(esfera, rojo, _, _)], [pieza(esfera, _, _, _), pieza(_, rojo, _, _)]).
```

El lazo no aprende nada por su cuenta: `inicial/1`, `actualizar/3` y
`estado/2` de la versión 3 hacen todo el trabajo, y el lazo solo lee,
decide si el término es un ejemplo y escribe. Por eso las pruebas
verifican que, con la secuencia `esfera_roja` como texto, el lazo llega a
los mismos bordes que `eliminar/2`. Los bordes de la sesión son los del
tercer paso de `traza/1` en la
[sección 68.3](index.md#683-version-3-eliminacion-de-candidatos): el
ejemplo mal formado no cambió el espacio.

Hay dos maneras de que una entrada no sirva, y las dos se tratan como
un dato más. `leer/1` captura el error de sintaxis y lo devuelve como
`sintaxis(M)`; después del error, `read_term/2` sigue leyendo desde el
punto final siguiente, de modo que el lazo continúa. Un término que se lee
pero no es un ejemplo lo rechaza `ejemplo_valido/1`, que pide `pos/1` o
`neg/1` alrededor de una pieza sin variables con valores del lenguaje.
`nonvar/1` va primero, porque con una variable leída `=../2` lanzaría
un error de instanciación, y `ground/1` va antes de `instancia/1`,
porque `instancia/1` ligaría las variables de una pieza incompleta y la
aceptaría como ejemplo. El final de la entrada llega como el término
`end_of_file`, y el lazo lo trata como `fin`.

Luger y Stubblefield leen con `read/1`, que es `read_term/2` sin
opciones. Su `specific_to_general/2` no tiene caso de terminación, y su
`candidate_elim/3` termina solo cuando el espacio converge; con un
término que no es un ejemplo los dos fallan, y con un error de sintaxis
los dos se interrumpen con una excepción. El de la solución termina por
la entrada, y sigue aceptando ejemplos después de converger: un negativo
mal clasificado que llegue después colapsa el espacio, como en la
[sección 68.4](index.md#684-version-4-preguntar-antes-de-converger), y el
lazo lo informa.

<!-- ejemplo: capitulo-68/soluciones_interactivo.pl predicado: con_entrada/2 -->
```prolog
%!  con_entrada(+Texto:string, :Meta) is semidet.
%
%   Prueba Meta una vez con Texto como entrada actual, en lugar de la
%   terminal. La entrada anterior se restituye aunque Meta falle o lance
%   una excepción.
con_entrada(Texto, Meta) :-
    current_input(Anterior),
    setup_call_cleanup(( open_string(Texto, Flujo),
                         set_input(Flujo) ),
                       once(Meta),
                       ( set_input(Anterior),
                         close(Flujo) )).
```

El lazo lee de la entrada actual, como `read/1` en la fuente, y no de un
stream que recibe como argumento, como `menu/1` en la
[sección 15.7](../capitulo-15-control/index.md#157-bucles-por-falla).
`con_entrada/2` reemplaza la entrada actual por una cadena mientras se
prueba la meta, de modo que el lazo se ejecuta sin terminal:

```prolog
?- con_entrada("pos(pieza(esfera, rojo, chico, madera)). fin.", aprender_interactivo(EV)).
pos(pieza(esfera, rojo, chico, madera))
  S:
    pieza(esfera, rojo, chico, madera)
  G:
    pieza(_, _, _, _)
  abierto
EV = ev([pieza(esfera, rojo, chico, madera)], [pieza(_, _, _, _)]).
```

Las pruebas capturan lo escrito con `with_output_to/2`. Así verifican el informe de un paso línea por línea,
el corte en `fin`, la entrada vacía, los seis términos mal formados de
una entrada, el error de sintaxis y que la entrada anterior se restituye
aunque la meta falle:

```prolog
test(mal_formados, [true(EV-N =@= EV0-6)]) :-
    sesion("pos(pieza(esfera, rojo, grande)). \c
            pos(pieza(esfera, rosa, chico, madera)). \c
            neg(pieza(esfera, _, chico, madera)). \c
            ejemplo(pieza(esfera, rojo, chico, madera)). \c
            X. \c
            pieza(esfera, rojo, chico, madera).", EV, Salida),
    inicial(EV0),
    aggregate_all(count, sub_string(Salida, _, _, _, "mal formado"), N).
```

El indicador `ejemplo: ` lo escribe el sistema solo cuando la entrada es
la terminal: `prompt/2` lo cambia y `setup_call_cleanup/3` restituye el
anterior. Con la entrada tomada de una cadena no se escribe, y la salida
que comparan las pruebas no lo incluye.
