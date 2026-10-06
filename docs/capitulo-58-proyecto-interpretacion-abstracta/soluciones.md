# Soluciones del capítulo 58 — Proyecto: interpretación abstracta

Las soluciones que agregan código están en
`ejemplos/capitulo-58/soluciones.pl`, que carga `informe.pl` (y con él las
cinco versiones del capítulo), `simbolico.pl` y `library(clpfd)`. Los
dominios de los ejercicios 3, 6 y 11 son cláusulas nuevas de las
operaciones `multifile` de `reticulado.pl`. Las pruebas están en
`soluciones.plt`, y las consultas de esta página se ejecutan con
`soluciones.pl` cargado; los casos, con `programa_caso/3`, son los de
`concreto.pl`.

## Ejercicio 1

La resta de intervalos resta a cada cota la cota opuesta del otro
intervalo, con `suma_cota/3`, que deja los infinitos como están:

<!-- ejemplo: capitulo-58/intervalos.pl predicado: suma_cota/3 -->
```prolog
%!  suma_cota(+A, +B, -S) is det.
%
%   S es la suma de las cotas A y B; un infinito absorbe al entero. No se
%   suman inf y sup: una cota inferior no es sup, ni una superior inf.
suma_cota(A, B, S) :-
    (   integer(A),
        integer(B)
    ->  S is A + B
    ;   infinita(A)
    ->  S = A
    ;   S = B
    ).
```

```prolog
?- analizar("x := n - 1; escribir 10 / x", P), analisis(signos, P, [n-entre(2, sup)], F, Os).
P = [asignar(x, bin(-, id(n), num(1))), escribir(bin(/, num(10), id(x)))],
F = estado(signos, [n-pos, x-top]),
Os = [division(bin(/, num(10), id(x)), top), escribe(bin(/, num(10), id(x)), top)].

?- analizar("x := n - 1; escribir 10 / x", P), analisis(intervalos, P, [n-entre(2, sup)], F, Os).
P = [asignar(x, bin(-, id(n), num(1))), escribir(bin(/, num(10), id(x)))],
F = estado(intervalos, [n-i(2, sup), x-i(1, sup)]),
Os = [escribe(bin(/, num(10), id(x)), i(0, 10))].
```

Para los signos, n es `pos` y 1 también, y la diferencia de dos positivos
puede tener cualquier signo: x es `top`, puede ser cero, y hay alarma. El
dominio de signos no distingue n ≥ 2 de n ≥ 1. Los intervalos sí: i(2, sup)
menos i(1, 1) es i(1, sup), sin el cero, y el cociente de 10 por un entero
de 1 en adelante está entre 0 y 10.

## Ejercicio 2

```prolog
?- op_signos(/, neg, pos, S).
S = cero ;
S = neg ;
false.

?- op_signos(*, cero, neg, S).
S = cero ;
false.
```

El cociente de un negativo por un positivo es cero cuando el dividendo es
menor en valor absoluto, porque la división trunca hacia cero: −1 / 2 es
0; y es negativo en los demás casos: −4 / 2 es −2. El producto de cero por
cualquier entero es cero: 0 · (−3) es 0. Las alternativas pendientes vienen
de las cláusulas de `op_signos/4` y de `cociente/3` que no se aplican.

## Ejercicio 3

Las operaciones siguen las reglas de la paridad: una suma o una resta es
par si los operandos tienen la misma paridad; un producto es par si algún
factor es par, aunque el otro sea `top`; el cociente no conserva nada, y es
`top`. Solo la igualdad restringe: x = y obliga a x a tener la paridad de
y, y falla si las dos son conocidas y distintas.

<!-- ejemplo: capitulo-58/soluciones.pl predicado: operar_paridad/4 multiplicar_paridad/3 refinar_paridad/4 -->
```prolog
%!  operar_paridad(+Op, +A, +B, -V) is det.
%
%   V es la paridad del resultado de la operación Op de Mini entre valores
%   de paridad A y B. El cociente no conserva la paridad: 6 / 2 es impar.
operar_paridad(+, A, B, V) :-
    sumar_paridad(A, B, V).
operar_paridad(-, A, B, V) :-
    sumar_paridad(A, B, V).
operar_paridad(*, A, B, V) :-
    multiplicar_paridad(A, B, V).
operar_paridad(/, _, _, top).

%!  multiplicar_paridad(+A, +B, -V) is det.
%
%   V es la paridad de un producto: par si algún factor es par, aunque el
%   otro sea top.
multiplicar_paridad(A, B, V) :-
    (   ( A == par ; B == par )
    ->  V = par
    ;   ( A == top ; B == top )
    ->  V = top
    ;   V = impar
    ).

%!  refinar_paridad(+Op, +A, +B, -V) is semidet.
%
%   V es la paridad A restringida por la comparación Op con un valor de
%   paridad B: solo = restringe, a la paridad común. Falla si A y B son
%   paridades distintas y Op es =.
refinar_paridad(Op, A, B, V) :-
    (   Op == (=)
    ->  (   A == top
        ->  V = B
        ;   B == top
        ->  V = A
        ;   A == B,
            V = A
        )
    ;   V = A
    ).
```

```prolog
?- analizar("x := 2 * n + 1; mientras x <> 0 hacer x := x - 2 fin", P), analisis(paridad, P, [n-entre(inf, sup)], F, Os).
P = [asignar(x, bin(+, bin(*, num(2), id(n)), num(1))), mientras(rel(<>, id(x), num(0)), [asignar(x, bin(-, id(x), num(2)))])],
F = nada,
Os = [siempre(rel(<>, id(x), num(0)))].
```

2 · n es par con n `top`, y 2 · n + 1 es impar. Restar 2 conserva la
paridad, y el invariante del bucle es `impar`. La salida exige x = 0, que es
par: la restricción falla, el estado de salida es `nada`, y el análisis
observa que la condición se cumple siempre. El bucle no termina con ningún
n, cosa que ni los signos ni los intervalos pueden probar. La prueba
`paridad_par` verifica el caso contrario: con x := 10, x es par y la salida
es posible.

## Ejercicio 4

El estado lleva, además del entorno con `asignada` o `sin_asignar`, el
conjunto de las variables leídas sin asignar hasta allí. Los dos son
finitos, y la tabla de `def/3` termina. Las condiciones no se deciden: `si`
sigue las dos ramas y `mientras` sale o da una vuelta más, como en el
análisis de Warren.

<!-- ejemplo: capitulo-58/soluciones.pl predicado: def/3 leer/4 -->
```prolog
%!  def(+Sent, +S0, -S) is nondet.
%
%   Ejecutar la sentencia Sent puede llevar el estado S0 a S. Una respuesta
%   por estado alcanzable; tabulada, termina con los bucles.
def(asignar(X, Exp), s(E0, L0), s(E, L)) :-
    leer(Exp, E0, L0, L),
    actualizar(X, asignada, E0, E).
def(escribir(Exp), s(E, L0), s(E, L)) :-
    leer(Exp, E, L0, L).
def(si(C, Si, No), s(E, L0), S) :-
    leer(C, E, L0, L),
    (   def_bloque(Si, s(E, L), S)
    ;   def_bloque(No, s(E, L), S)
    ).
def(mientras(C, Cuerpo), s(E, L0), S) :-
    leer(C, E, L0, L),
    (   S = s(E, L)
    ;   def_bloque(Cuerpo, s(E, L), S1),
        def(mientras(C, Cuerpo), S1, S)
    ).

%!  leer(+T, +E:list, +L0:list, -L:list) is det.
%
%   L es el conjunto L0 con las variables que T, una expresión o una
%   condición, lee mientras están sin_asignar en el entorno E.
leer(T, E, L0, L) :-
    findall(X, ( sub_term(id(X), T),
                 valor(X, E, sin_asignar) ),
            Xs),
    append(L0, Xs, L1),
    sort(L1, L).
```

```prolog
?- sin_asignar_texto("escribir z; z := z + 1", Xs).
Xs = [z].

?- sin_asignar_texto("x := 1; si x > 0 entonces y := 1 fin; escribir y", Xs).
Xs = [y].
```

En el segundo programa la condición x > 0 siempre se cumple, pero este
análisis no mira los valores: el camino del `sino` vacío llega a `escribir
y` con y sin asignar. Es una falsa alarma que un análisis de signos
combinado con este evitaría. Los cuatro programas de ejemplo del
[capítulo 45](../capitulo-45-proyecto-compilador/index.md) asignan cada variable antes de leerla; lo verifica la prueba
`sin_asignar_ejemplos`.

## Ejercicio 5

<!-- ejemplo: capitulo-58/soluciones.pl predicado: estrechar/3 -->
```prolog
%!  estrechar(+Bucle, +E0, -I) is det.
%
%   I es el estado en la condición del mientras Bucle, al que se llega con
%   E0, mejorado con una vuelta sin ensanchar: la unión de E0 con el
%   final del cuerpo desde el invariante de cabeza/3 restringido por la
%   condición. I sigue siendo correcto, y puede ser más preciso.
estrechar(mientras(C, Cuerpo), E0, I) :-
    cabeza(mientras(C, Cuerpo), E0, I0),
    phrase(( partir(C, I0, Dentro, _),
             abs_bloque(Cuerpo, Dentro, E1) ),
           _),
    unir_estados(E0, E1, I).
```

```prolog
?- diez_estrechado(I, Fuera).
I = estado(intervalos, [i-i(0, 10)]),
Fuera = estado(intervalos, [i-i(10, 10)]).
```

El invariante ensanchado es i(0, sup). Restringido por i < 10 queda
i(0, 9), el cuerpo lo lleva a i(1, 10), y la unión con el estado de
entrada, i(0, 0), da i(0, 10). La salida, i ≥ 10, deja i(10, 10). El
resultado sigue siendo correcto porque parte de un estado que ya contiene
todos los alcanzables: una vuelta desde él no puede perder ninguno. Es la
**iteración descendente** de Cousot y Cousot, con un solo paso.

## Ejercicio 6

`signos6` reúne los signos posibles de cada operación con las relaciones de
`signos.pl`, como el dominio de signos de `reticulado.pl`, pero los abstrae
con `alfa6/2`, que tiene un valor para cero o positivo y otro para cero o
negativo:

<!-- ejemplo: capitulo-58/soluciones.pl predicado: representa6/2 alfa6/2 -->
```prolog
% representa6(V, Ss): Ss son los signos que representa V.
representa6(neg, [neg]).
representa6(cero, [cero]).
representa6(pos, [pos]).
representa6(noneg, [cero, pos]).
representa6(nopos, [cero, neg]).
representa6(top, [cero, neg, pos]).

%!  alfa6(+Ss:list, -V) is det.
%
%   V es el menor valor de signos6 que representa los signos de Ss; sin
%   ninguno, top.
alfa6(Ss0, V) :-
    sort(Ss0, Ss),
    (   Ss \== [],
        representa6(V0, Ss)
    ->  V = V0
    ;   V = top
    ).
```

```prolog
?- analisis_caso(signos6, promedio, [n-entre(0, sup)], F, Os).
F = estado(signos6, [i-noneg, n-noneg, s-noneg]),
Os = [division(bin(/, id(s), id(n)), noneg), escribe(bin(/, id(s), id(n)), noneg)].
```

s empieza en cero y suma valores de i, que es `noneg`: la unión de cero y
positivo, que antes era `top`, ahora es `noneg`, y el análisis prueba que s
no es negativa. La alarma sigue, y es correcta: n puede ser 0. La prueba
`signos6_cubre` verifica el dominio con las corridas de los seis casos.

## Ejercicio 7

```prolog
?- finales_caso(mcd, [a-entre(inf, sup), b-entre(1, sup)], Fs).
Fs = [estado([a-pos, b-pos])].
```

No cambia nada. Con a negativa o cero, a ≠ b se cumple; a > b no puede
cumplirse, y b := b − a deja b positiva. Desde esos estados el bucle no
sale nunca, y no aportan estados finales. La ejecución concreta hace lo
mismo: con a ≤ 0 y b > 0, b crece o queda igual en cada vuelta y nunca
alcanza a a. Con a y b positivas, el resultado dice que **si** el programa
termina, a es positiva; que termine es otra propiedad, que se prueba con
una medida que decrece en cada vuelta, a + b, y no con un análisis de
estados alcanzables.

## Ejercicio 8

Cada incógnita pasa a ser una variable de restricción, y cada comparación
de Prolog la restricción de `library(clpfd)` correspondiente; `//` es
también una operación de clpfd:

<!-- ejemplo: capitulo-58/soluciones.pl predicado: camino_posible/3 restriccion/2 -->
```prolog
%!  camino_posible(+Nombre, -Condiciones:list, -Salida:list) is nondet.
%
%   Como simbolizar_caso/3, pero solo los caminos cuyas condiciones puede
%   cumplir algún entero, según la propagación de library(clpfd). Una
%   propagación que no falla no prueba que haya solución: el filtro puede
%   dejar un camino imposible, nunca descarta uno posible.
camino_posible(Nombre, Condiciones, Salida) :-
    simbolizar_caso(Nombre, Condiciones, Salida),
    \+ \+ posibles(Condiciones).

%!  restriccion(+Ps:list, +C) is semidet.
%
%   Impone la comparación C de Prolog como restricción de clpfd, con las
%   incógnitas reemplazadas según Ps.
restriccion(Ps, C) :-
    C =.. [Op, A, B],
    restriccion_de(Op, R),
    reemplazar(Ps, A, VA),
    reemplazar(Ps, B, VB),
    Meta =.. [R, VA, VB],
    call(Meta).
```

```prolog
?- camino_posible(cuadrado, Cs, S).
Cs = [n*n>=0],
S = [n*n].
```

clpfd sabe que el cuadrado de un entero no es negativo, y descarta el
camino n · n < 0. La doble negación prueba las restricciones sin dejar
ligaduras. El filtro es correcto en un solo sentido: la propagación de
clpfd puede no detectar una contradicción, y entonces un camino imposible
queda; pero nunca descarta un camino posible.

## Ejercicio 9

Medido con `time/1` y `statistics(table_space_used, B)`, cada análisis en
un proceso nuevo después de borrar las tablas; el análisis unido se midió
después del otro, para no contar la carga de los predicados de biblioteca:

| K | estados finales | inferencias, conjuntos | tablas, bytes | inferencias, unido |
|---|---|---|---|---|
| 2 | 9 | 11 072 | 73 336 | 834 |
| 4 | 81 | 52 371 | 1 424 856 | 1 649 |
| 6 | 729 | 581 410 | 22 729 976 | 2 500 |
| 8 | 6 561 | 6 766 913 | 319 503 640 | 3 387 |

Entre K y K + 2 los estados finales se multiplican por 9, y las
inferencias y el espacio de las tablas por algo más de 10: el análisis por
conjuntos crece como $3^K$. El unido suma unas 420 inferencias por cada `si`.
Con K = 9 el análisis por conjuntos produce `Not enough resources:
private_table_space`: las tablas necesitan más que el gigabyte que
SWI-Prolog les reserva por omisión, la opción `table_space`. Se puede
aumentar con `set_prolog_flag(table_space, B)`, pero cada entrada más
triplica lo necesario.

## Ejercicio 10

Una rama es inalcanzable si el análisis observa `nunca(C)` para la rama del
`si` o el cuerpo del `mientras`, o `siempre(C)` para la rama del `sino`; y
lo que sigue a un `mientras` con `siempre(C)` también:

<!-- ejemplo: capitulo-58/soluciones.pl predicado: muertas//3 muerta_en//3 rama//3 -->
```prolog
%!  muertas(+Ss:list, +Estado, +Obs:list)// is det.
%
%   Las sentencias de Ss que no se alcanzan, si el bloque empieza vivo o
%   muerto.
muertas([], _, _) -->
    [].
muertas([S|Ss], Estado, Obs) -->
    muerta_segun(Estado, S, Obs, Sigue),
    muertas(Ss, Sigue, Obs).

%!  muerta_en(+S, +Obs:list, -Sigue)// is det.
%
%   Las sentencias inalcanzables dentro de S, alcanzada; Sigue es muerto si
%   después de S no se llega a nada.
muerta_en(asignar(_, _), _, vivo) -->
    [].
muerta_en(escribir(_), _, vivo) -->
    [].
muerta_en(si(C, Si, No), Obs, vivo) -->
    rama(Si, nunca(C), Obs),
    rama(No, siempre(C), Obs).
muerta_en(mientras(C, Cuerpo), Obs, Sigue) -->
    rama(Cuerpo, nunca(C), Obs),
    { (   memberchk(siempre(C), Obs)
      ->  Sigue = muerto
      ;   Sigue = vivo
      ) }.

%!  rama(+Ss:list, +Marca, +Obs:list)// is det.
%
%   Las sentencias inalcanzables de la rama Ss: todas si Obs tiene la Marca,
%   y si no, las de adentro.
rama(Ss, Marca, Obs) -->
    (   { memberchk(Marca, Obs) }
    ->  muertas(Ss, muerto, Obs)
    ;   muertas(Ss, vivo, Obs)
    ).
```

```prolog
?- analizar("x := 0 - 1; si x > 0 entonces escribir x fin", P), inalcanzables(signos, P, [], Ss).
P = [asignar(x, bin(-, num(0), num(1))), si(rel(>, id(x), num(0)), [escribir(id(x))], [])],
Ss = [escribir(id(x))].
```

La prueba `inalcanzable_bucle` verifica el segundo programa: el bucle no
sale, y `escribir x` no se alcanza. Las observaciones se buscan por la
condición, así que dos condiciones iguales en lugares distintos se
confunden; y un `si` cuyas dos ramas terminan en `nada` no marca lo que le
sigue. En los dos casos el resultado informa menos sentencias muertas de
las que hay, nunca una viva.

## Ejercicio 11

El dominio `umbrales(Ts)` delega todo en `intervalos` salvo el
ensanchamiento, que lleva la cota que crece al umbral siguiente de la lista
y solo después a infinito. Como el nombre del dominio viaja en cada estado,
la tabla de `cabeza/3` usa los umbrales sin ningún cambio en
`reticulado.pl`:

<!-- ejemplo: capitulo-58/soluciones.pl predicado: umbral_arriba/3 analisis_umbrales/4 -->
```prolog
%!  umbral_arriba(+Ts:list, +D, -F) is det.
%
%   F es el menor umbral de Ts que no es menor que la cota D, o sup.
umbral_arriba(Ts, D, F) :-
    include([T]>>cota_menor(D, T), Ts, Mayores),
    (   Mayores == []
    ->  F = sup
    ;   min_list(Mayores, F)
    ).

%!  analisis_umbrales(+Programa:list, +Entradas:list, -F, -Obs:list) is det.
%
%   Como analisis/5 con los intervalos, ensanchando hacia las constantes de
%   Programa y 0.
analisis_umbrales(Programa, Entradas, F, Obs) :-
    findall(N, sub_term(num(N), Programa), Ns),
    sort([0|Ns], Ts),
    analisis(umbrales(Ts), Programa, Entradas, F, Obs).
```

```prolog
?- programa_caso(diez, P, _), analisis_umbrales(P, [], F, Os).
P = [asignar(i, num(0)), mientras(rel(<, id(i), num(10)), [asignar(i, bin(+, id(i), num(1)))]), escribir(id(i))],
F = estado(umbrales([0, 1, 10]), [i-i(10, 10)]),
Os = [escribe(id(i), i(10, 10))].
```

La cabeza pasa de i(0, 0) a i(0, 1), porque 1 es un umbral, y después a
i(0, 10). Con i < 10 el cuerpo da i(1, 10), que ya está contenido: el punto
fijo es i(0, 10), y la salida, i(10, 10). La prueba `umbrales_cubre`
verifica el dominio con los seis casos.

## Ejercicio 12

Los resúmenes ya dicen qué contextos terminan en `error`: basta filtrarlos.
`cociente_directo/1` arma la variante del caso sin la condición, y
`contextos_caso/2` y `contextos_directo/1` aplican el filtro a cada uno.

<!-- ejemplo: capitulo-58/soluciones.pl predicado: contextos_con_error/3 cociente_directo/1 contextos_caso/2 contextos_directo/1 -->
```prolog
%!  contextos_con_error(+Bloque, +Entradas:list, -Contextos:list) is det.
%
%   Contextos son los pares N-Vs, ordenados, de los procedimientos N que el
%   análisis de signos llama con los signos Vs en sus argumentos y cuyo
%   resumen incluye error.
contextos_con_error(Bloque, Entradas, Contextos) :-
    p_resumenes(Bloque, Entradas, Resumenes),
    findall(N-Vs, ( member(resumen(N, Vs, _, Salidas), Resumenes),
                    memberchk(error, Salidas) ),
            Contextos0),
    sort(Contextos0, Contextos).

%!  cociente_directo(-Bloque) is det.
%
%   Bloque es el de cociente con el bloque principal cambiado por una sola
%   llamada a dividir con a, sin la condición.
cociente_directo(bloque(Ds, Ss)) :-
    bloque_caso(cociente, bloque(Ds, _), _),
    traducir_sentencias([llamar(dividir, ["a"])], Ss).

%!  contextos_caso(+Nombre, -Contextos:list) is semidet.
%
%   Como contextos_con_error/3, sobre el caso Nombre con sus entradas.
contextos_caso(Nombre, Contextos) :-
    bloque_caso(Nombre, Bloque, Entradas),
    contextos_con_error(Bloque, Entradas, Contextos).

%!  contextos_directo(-Contextos:list) is det.
%
%   Como contextos_con_error/3, sobre el bloque de cociente_directo/1 con
%   a de cualquier signo.
contextos_directo(Contextos) :-
    cociente_directo(Bloque),
    contextos_con_error(Bloque, [a-entre(inf, sup)], Contextos).
```

```prolog
?- contextos_caso(cociente, Cs).
Cs = [].

?- contextos_directo(Cs).
Cs = [dividir-[cero]].
```

Sin la condición, `dividir/1` se llama con los tres signos de `a`, y con
`cero` el resumen incluye `error`. Las pruebas `ej12_*` de
`soluciones.plt` lo verifican, y también que `factorial` no tiene ningún
contexto con error.
