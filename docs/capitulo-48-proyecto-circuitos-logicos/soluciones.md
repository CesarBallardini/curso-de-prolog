# Soluciones del capítulo 48 — Proyecto: circuitos lógicos

Los ejercicios 1 y 13 se resuelven con los archivos del capítulo,
`compuertas.pl` y `retardos.pl`. Las soluciones de los demás están en
`ejemplos/capitulo-48/`, en tres archivos que cargan otros y se ejecutan
localmente: `soluciones.pl`, para los ejercicios 2 a 9 y 11, carga los
módulos del proyecto (`circuitos.pl`, `formulas.pl`, `verificar.pl`,
`secuenciales.pl` y `estados.pl`) y agrega sus circuitos con cláusulas
`multifile`; `soluciones_vectores.pl`, para el 12, carga el módulo
`vectores`; y `soluciones_cmos.pl`, para el 10 y el 14, carga
`transistores.pl`. Cada archivo tiene sus pruebas en el `.plt` del mismo
nombre.

## Ejercicio 1

Con `compuertas.pl` cargado:

<!-- ejemplo: capitulo-48/compuertas.pl predicado: semisumador/4 -->
```prolog
%!  semisumador(?A, ?B, ?S, ?C) is nondet.
%
%   S es el bit de suma y C el acarreo de sumar los bits A y B.
semisumador(A, B, S, C) :-
    xor(A, B, S),
    and(A, B, C).
```

```prolog
?- semisumador(A, B, 0, 1).
A = B, B = 1.

?- sumador(A, B, 1, S, 0).
A = 0,
B = 0,
S = 1 ;
false.

?- biestable(0, 0, Q, Qn).
Q = 1,
Qn = 1.

?- biestable(S, R, 0, 0).
false.

?- sumar_bits([1, 1], Bs, Ss, 1).
Bs = [0, 1],
Ss = [1, 0] ;
Bs = [1, 0],
Ss = [0, 0] ;
Bs = [1, 1],
Ss = [0, 1] ;
false.
```

- La suma 0 con acarreo 1 solo se obtiene con dos unos. La respuesta termina
  en `.`: de las filas que cumplen `xor(A, B, 0)`, la que da la respuesta,
  `xor(1, 1, 0)`, es la última cláusula de `xor/3`, y no quedan
  alternativas.
- Con el acarreo de entrada en 1 y el de salida en 0, las otras dos entradas
  tienen que ser 0, y la suma es 1. Queda una alternativa pendiente, que
  falla.
- Con las dos entradas del biestable en 0, las dos salidas son 1: es el
  estado que el biestable real evita, porque al volver las entradas a 1 el
  resultado depende de cuál cambia primero. El modelo lo admite como estado
  estable.
- Ninguna combinación da las dos salidas en 0: una NAND con una entrada en 0
  da 1, y cada salida es entrada de la otra compuerta.
- `sumar_bits/4` en sentido inverso encuentra los números de dos bits que
  sumados a 3 (`[1, 1]`) desbordan: 2, 1 y 3, con los resultados 1, 0 y 2 y
  acarreo 1, es decir 5, 4 y 6. La suma 3 + 0 no desborda, y no aparece.

## Ejercicio 2

El préstamo del semirrestador es ¬a · b, y el restador completo resta
primero b de a y después el préstamo de entrada, como el sumador de la
[sección 48.2](index.md#482-el-circuito-como-dato) suma con dos semisumadores:

<!-- ejemplo: capitulo-48/soluciones.pl fragmento: % El préstamo es 1 .. circuitos:componente(restador3, r2, restador, [a2, b2, p1], [d2, p]). -->
```prolog
% El préstamo es 1 cuando a es 0 y b es 1.
circuitos:circuito(semirrestador, [a, b], [d, p]).
circuitos:componente(semirrestador, x1, xor, [a, b], [d]).
circuitos:componente(semirrestador, i1, inv, [a], [na]).
circuitos:componente(semirrestador, y1, and, [na, b], [p]).

circuitos:circuito(restador, [a, b, pi], [d, po]).
circuitos:componente(restador, r1, semirrestador, [a, b], [t, p1]).
circuitos:componente(restador, r2, semirrestador, [t, pi], [d, p2]).
circuitos:componente(restador, o1, or, [p1, p2], [po]).

circuitos:circuito(restador3, [a0, a1, a2, b0, b1, b2], [d0, d1, d2, p]).
circuitos:componente(restador3, r0, semirrestador, [a0, b0], [d0, p0]).
circuitos:componente(restador3, r1, restador, [a1, b1, p0], [d1, p1]).
circuitos:componente(restador3, r2, restador, [a2, b2, p1], [d2, p]).
```

`resta_correcta/0` compara, para los 64 pares, la simulación con la resta
aritmética:

<!-- ejemplo: capitulo-48/soluciones.pl predicado: resta_correcta/0 bits3/2 -->
```prolog
%!  resta_correcta is semidet.
%
%   Para todo par de números X e Y de 0 a 7, restador3 da X - Y módulo 8, y
%   el préstamo final es 1 si X es menor que Y.
resta_correcta :-
    forall(( between(0, 7, X), between(0, 7, Y) ),
           ( bits3(X, [A0, A1, A2]),
             bits3(Y, [B0, B1, B2]),
             once(simular(restador3, [A0, A1, A2, B0, B1, B2],
                          [D0, D1, D2, P])),
             D0 + 2 * D1 + 4 * D2 =:= (X - Y) mod 8,
             (   X < Y
             ->  P =:= 1
             ;   P =:= 0
             )
           )).

%!  bits3(+N:integer, -Bits:list) is det.
%
%   Bits son los tres bits de N, el menos significativo primero.
bits3(N, [B0, B1, B2]) :-
    B0 is N /\ 1,
    B1 is (N >> 1) /\ 1,
    B2 is (N >> 2) /\ 1.
```

```prolog
?- resta_correcta.
true.

?- simular(restador3, [1, 0, 0, 0, 1, 0], Ds).
Ds = [1, 1, 1, 1] ;
false.
```

La segunda consulta es 1 − 2: el resultado es 7, que es −1 módulo 8, con
préstamo 1.

## Ejercicio 3

<!-- ejemplo: capitulo-48/soluciones.pl fragmento: circuitos:circuito(mux, .. circuitos:componente(mux_nand, n4, nand, [u, v], [z]). -->
```prolog
circuitos:circuito(mux, [s, a, b], [z]).
circuitos:componente(mux, i1, inv, [s], [ns]).
circuitos:componente(mux, y1, and, [ns, a], [u]).
circuitos:componente(mux, y2, and, [s, b], [v]).
circuitos:componente(mux, o1, or, [u, v], [z]).

circuitos:circuito(mux_nand, [s, a, b], [z]).
circuitos:componente(mux_nand, n1, nand, [s, s], [ns]).
circuitos:componente(mux_nand, n2, nand, [ns, a], [u]).
circuitos:componente(mux_nand, n3, nand, [s, b], [v]).
circuitos:componente(mux_nand, n4, nand, [u, v], [z]).
```

En `mux_nand`, la compuerta `n1` con sus dos entradas unidas es un
inversor, y las tres restantes forman una suma de dos productos: la NAND de
dos NAND es la disyunción de las conjunciones, por De Morgan.

```prolog
?- tabla_de_verdad(mux, Filas).
Filas = [[0, 0, 0]-[0], [0, 0, 1]-[0], [0, 1, 0]-[1], [0, 1, 1]-[1], [1, 0, 0]-[0], [1, 0, 1]-[1], [1, 1, 0]-[0], [1, 1, 1]-[1]].

?- formula(mux, z, F), suma_de_productos(F, Ps).
F = ~s*a+s*b,
Ps = [[a, ~s], [b, s]] ;
false.

?- equivalentes(mux, mux_nand).
true.
```

Las filas con s = 0 copian a, y las filas con s = 1 copian b. La suma de
productos es a·¬s + b·s.

## Ejercicio 4

<!-- ejemplo: capitulo-48/soluciones.pl fragmento: circuitos:circuito(inv_nand, .. circuitos:componente(or1, g1, or, [a, b], [z]). -->
```prolog
circuitos:circuito(inv_nand, [a], [z]).
circuitos:componente(inv_nand, n1, nand, [a, a], [z]).

circuitos:circuito(and_nand, [a, b], [z]).
circuitos:componente(and_nand, n1, nand, [a, b], [t]).
circuitos:componente(and_nand, n2, nand, [t, t], [z]).

circuitos:circuito(or_nand, [a, b], [z]).
circuitos:componente(or_nand, n1, nand, [a, a], [na]).
circuitos:componente(or_nand, n2, nand, [b, b], [nb]).
circuitos:componente(or_nand, n3, nand, [na, nb], [z]).

circuitos:circuito(inv1, [a], [z]).
circuitos:componente(inv1, g1, inv, [a], [z]).

circuitos:circuito(and1, [a, b], [z]).
circuitos:componente(and1, g1, and, [a, b], [z]).

circuitos:circuito(or1, [a, b], [z]).
circuitos:componente(or1, g1, or, [a, b], [z]).
```

```prolog
?- equivalentes(inv_nand, inv1), equivalentes(and_nand, and1), equivalentes(or_nand, or1).
true.
```

El inversor es una NAND con las entradas unidas; la AND, una NAND seguida
de un inversor; la OR, por De Morgan, la NAND de las dos entradas negadas.

## Ejercicio 5

La conducta recibe la ruta de la falla y su valor antes de los cuatro
argumentos que agrega `simular/4`:

<!-- ejemplo: capitulo-48/soluciones.pl predicado: pegada/6 detecta/4 -->
```prolog
%!  pegada(+Falla:list, +Valor, +Ruta:list, ?Tipo, ?Entradas:list, ?Salida)
%!      is nondet.
%
%   La conducta de un circuito en el que la compuerta de ruta Falla da
%   siempre Valor; las demás cumplen su tabla.
pegada(Falla, Valor, Ruta, Tipo, Entradas, Salida) :-
    (   Ruta == Falla
    ->  Salida = Valor
    ;   tabla(Tipo, Entradas, Salida)
    ).

%!  detecta(+Circuito, +Falla:list, +Valor, -Entradas:list) is nondet.
%
%   Con Entradas, Circuito con la compuerta Falla pegada a Valor da otras
%   salidas que Circuito sin fallas.
detecta(Circuito, Falla, Valor, Entradas) :-
    circuito(Circuito, Nombres, _),
    same_length(Nombres, Entradas),
    maplist(bit, Entradas),
    once(simular(Circuito, Entradas, Salidas)),
    once(simular(pegada(Falla, Valor), Circuito, Entradas, ConFalla)),
    Salidas \== ConFalla.
```

```prolog
?- findall(Es, detecta(sumador, [m2, x1], 0, Es), Ess).
Ess = [[0, 0, 1], [0, 1, 0], [1, 0, 0], [1, 1, 1]].

?- findall(Es, detecta(sumador, [o1], 1, Es), Ess).
Ess = [[0, 0, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0]].
```

La compuerta `[m2, x1]` da el bit de suma; pegada a 0, la falla se ve solo
con las entradas cuya suma es 1, las que tienen una cantidad impar de unos.
La compuerta `[o1]` da el acarreo; pegada a 1, se ve con las entradas cuyo
acarreo es 0. Con las demás entradas, el circuito con la falla responde lo
mismo que el que funciona, y una prueba que use solo esas entradas no la
detecta. El [capítulo 49](../capitulo-49-proyecto-diagnostico-abduccion/index.md) resuelve el problema inverso: dadas las entradas y
las salidas observadas, qué compuertas pueden estar fallando.

## Ejercicio 6

<!-- ejemplo: capitulo-48/soluciones.pl predicado: minterminos/3 literal/3 -->
```prolog
%!  minterminos(+Circuito, +Salida, -Productos:list(list)) is det.
%
%   Productos tiene un producto por cada fila de la tabla de verdad de
%   Circuito en la que Salida vale 1, con un literal por entrada.
minterminos(Circuito, Salida, Productos) :-
    circuito(Circuito, Nombres, Salidas),
    nth1(I, Salidas, Salida),
    !,
    tabla_de_verdad(Circuito, Filas),
    findall(P,
            ( member(Es-Ss, Filas),
              nth1(I, Ss, 1),
              maplist(literal, Nombres, Es, P0),
              sort(P0, P) ),
            Productos0),
    sort(Productos0, Productos).

%!  literal(+Nombre, +Valor, -Literal) is det.
%
%   Literal es Nombre si Valor es 1, y ~Nombre si es 0.
literal(Nombre, 1, Nombre).
literal(Nombre, 0, ~Nombre).
```

```prolog
?- minterminos(xor_nand, z, Ps).
Ps = [[x, ~y], [y, ~x]].

?- minterminos(sumador, co, Ps).
Ps = [[a, b, ci], [a, b, ~ci], [a, ci, ~b], [b, ci, ~a]].
```

Para el `xor_nand`, la suma de los mintérminos y la de
`suma_de_productos/2` coinciden: ningún producto de la disyunción exclusiva
se puede acortar. Para el acarreo son distintas: la de los mintérminos tiene
cuatro productos de tres literales, uno por fila, y la de
`suma_de_productos/2`, tres, porque `[a, b]` reúne las filas 110 y 111. Los
mintérminos son una forma canónica —dos funciones iguales tienen los mismos—,
pero su tamaño crece con la tabla de verdad, que es lo que la
[sección 48.4](index.md#484-verificar-con-libraryclpb) evita.

## Ejercicio 7

<!-- ejemplo: capitulo-48/soluciones.pl predicado: simplificar_consenso/2 cerrar/2 consenso/3 -->
```prolog
%!  simplificar_consenso(+Productos:list(list), -Simples:list(list)) is det.
%
%   Simples es Productos simplificada y cerrada por consenso: agregar los
%   consensos de todos los pares y simplificar, hasta que no cambia.
simplificar_consenso(Productos, Simples) :-
    simplificar(Productos, Ps0),
    cerrar(Ps0, Simples).

%!  cerrar(+Productos:list(list), -Cerrados:list(list)) is det.
%
%   Productos está simplificada; Cerrados es el punto fijo del consenso.
cerrar(Ps0, Ps) :-
    findall(C,
            ( member(P, Ps0),
              member(Q, Ps0),
              consenso(P, Q, C) ),
            Cs),
    append(Ps0, Cs, Ps1),
    simplificar(Ps1, Ps2),
    (   Ps2 == Ps0
    ->  Ps = Ps0
    ;   cerrar(Ps2, Ps)
    ).

%!  consenso(+P:list, +Q:list, -C:list) is nondet.
%
%   C es el consenso de los productos P y Q: P tiene un nombre X, Q tiene
%   ~X, y la unión de los demás literales no es contradictoria.
consenso(P, Q, C) :-
    member(X, P),
    atom(X),
    memberchk(~X, Q),
    ord_del_element(P, X, P1),
    ord_del_element(Q, ~X, Q1),
    ord_union(P1, Q1, C),
    \+ ( member(Y, C), atom(Y), memberchk(~Y, C) ).
```

`consenso/3` exige que el resultado no sea contradictorio: si P y Q tienen
dos pares de literales opuestos, su consenso contiene un literal y su
negación, y vale 0. `cerrar/2` termina porque la cantidad de productos
distintos sobre un conjunto finito de literales es finita, y
`simplificar/2` deja la lista ordenada, de modo que `==` detecta el punto
fijo.

```prolog
?- formula(sumador, co, F), suma_de_productos(F, Ps0), simplificar_consenso(Ps0, Ps).
F = a*b+(a#b)*ci,
Ps0 = [[a, b], [a, ci, ~b], [b, ci, ~a]],
Ps = [[a, b], [a, ci], [b, ci]] ;
false.
```

El consenso de `[a, b]` y `[a, ci, ~b]` es `[a, ci]`, que absorbe al segundo;
el de `[a, b]` y `[b, ci, ~a]` es `[b, ci]`, que absorbe al tercero. El
resultado es la suma de los **implicantes primos**, los productos que no se
pueden acortar; la prueba `consenso_minterminos` verifica que desde los
cuatro mintérminos se llega al mismo resultado.

## Ejercicio 8

El bit menos significativo cambia cuando e = 1, y el más significativo,
cuando e = 1 y el menos significativo es 1: un semisumador que suma e al
contador.

<!-- ejemplo: capitulo-48/soluciones.pl fragmento: secuenciales:secuencial(contador2, .. circuitos:componente(contador2_c, x2, xor, [b1, c], [n1]). -->
```prolog
secuenciales:secuencial(contador2, contador2_c, 2).

% Con e = 1 el contador suma 1; con e = 0, n0 = b0 y n1 = b1.
circuitos:circuito(contador2_c, [e, b0, b1], [b0, b1, n0, n1]).
circuitos:componente(contador2_c, x1, xor, [b0, e], [n0]).
circuitos:componente(contador2_c, y1, and, [b0, e], [c]).
circuitos:componente(contador2_c, x2, xor, [b1, c], [n1]).
```

```prolog
?- ejecutar(contador2, [0, 0], [[1], [1], [0], [1], [0], [1]], Ss).
Ss = [[0, 0], [1, 0], [0, 1], [0, 1], [1, 1], [1, 1]] ;
false.

?- aggregate_all(count, alcanzable(contador2, [0, 0], _), N).
N = 4.
```

Cada salida es el estado antes del pulso: 0, 1, 2, 2, 3, 3. Después del
tercer y el quinto pulso, con e = 0, el estado no cambia.

## Ejercicio 9

<!-- ejemplo: capitulo-48/soluciones.pl fragmento: secuenciales:secuencial(detector, .. (Z =< X)). -->
```prolog
secuenciales:secuencial(detector, detector_c, 2).

% El estado es [q1, q2]: la entrada anterior y la de antes. La salida es 1
% si x = 1, q1 = 0 y q2 = 1; el estado siguiente es [x, q1].
circuitos:circuito(detector_c, [x, q1, q2], [z, x, q1]).
circuitos:componente(detector_c, i1, inv, [q1], [nq1]).
circuitos:componente(detector_c, y1, and, [x, nq1], [t]).
circuitos:componente(detector_c, y2, and, [t, q2], [z]).

%!  detector_correcto is semidet.
%
%   En todo arco alcanzable del detector, la salida es 1 solo si la
%   entrada es 1.
detector_correcto :-
    siempre(detector, [0, 0], [_, [X], [Z], _]>>(Z =< X)).
```

```prolog
?- ejecutar(detector, [0, 0], [[1], [0], [1], [0], [1], [1], [0], [1]], Ss).
Ss = [[0], [0], [1], [0], [1], [0], [0], [1]] ;
false.

?- detector_correcto.
true.
```

La salida es 1 en los pulsos 3, 5 y 8, donde terminan las apariciones de
1 0 1; la del pulso 5 comparte su primer 1 con la del pulso 3. La propiedad
se verifica en los ocho arcos del grafo, cuatro estados por dos entradas,
sin elegir una sucesión.

## Ejercicio 10

Las dos ramas de la NAND se escriben como en el inversor de la
[sección 48.9](index.md#489-compuertas-hechas-con-transistores): los dos
transistores p en paralelo comparten la fuente, en 1, y el drenador, la
salida; los dos n en serie están unidos por un cable interno, W, que no
aparece en la cabeza.

<!-- ejemplo: capitulo-48/soluciones_cmos.pl predicado: nand_cmos/3 -->
```prolog
%!  nand_cmos(?A, ?B, ?Z) is nondet.
%
%   Z es la salida de la compuerta NAND CMOS con entradas A y B: dos
%   transistores p en paralelo entre el 1 y la salida, y dos n en serie
%   entre la salida y el 0, unidos por el cable interno W.
nand_cmos(A, B, Z) :-
    ptran(1, A, Z),
    ptran(1, B, Z),
    ntran(Z, A, W),
    ntran(W, B, 0).
```

```prolog
?- nand_cmos(A, B, Z).
A = B, B = 0,
Z = 1 ;
A = 0,
B = Z, Z = 1 ;
A = Z, Z = 1,
B = 0 ;
A = B, B = 1,
Z = 0.

?- nand_cmos(A, B, 0).
A = B, B = 1 ;
false.
```

Las cuatro respuestas son la tabla de `nand/3`, y la prueba `nand` de
`soluciones_cmos.plt` verifica que cada combinación de entradas tiene una
sola salida. La segunda consulta usa la salida como dato y obtiene las
entradas: el modelo describe estados estables, una relación entre los
valores de los cables, y no distingue qué cable impone su valor a cuál.
Spivey observa que por eso el modelo es más permisivo que el hardware, donde
un transistor no puede llevar su compuerta a un valor desde el drenador.

## Ejercicio 11

<!-- ejemplo: capitulo-48/soluciones.pl fragmento: % gi = ai .. circuitos:componente(sumador3_anticipado, oc3, or, [t5, t4], [c]). -->
```prolog
% gi = ai * bi, pi = ai # bi; c1 = g0, c2 = g1 + p1 * g0,
% c = g2 + p2 * g1 + p2 * p1 * g0.
circuitos:circuito(sumador3_anticipado, [a0, a1, a2, b0, b1, b2],
                   [s0, s1, s2, c]).
circuitos:componente(sumador3_anticipado, ga0, and, [a0, b0], [g0]).
circuitos:componente(sumador3_anticipado, ga1, and, [a1, b1], [g1]).
circuitos:componente(sumador3_anticipado, ga2, and, [a2, b2], [g2]).
circuitos:componente(sumador3_anticipado, xp0, xor, [a0, b0], [s0]).
circuitos:componente(sumador3_anticipado, xp1, xor, [a1, b1], [p1]).
circuitos:componente(sumador3_anticipado, xp2, xor, [a2, b2], [p2]).
circuitos:componente(sumador3_anticipado, xs1, xor, [p1, g0], [s1]).
circuitos:componente(sumador3_anticipado, yc1, and, [p1, g0], [t1]).
circuitos:componente(sumador3_anticipado, oc1, or, [g1, t1], [c2]).
circuitos:componente(sumador3_anticipado, xs2, xor, [p2, c2], [s2]).
circuitos:componente(sumador3_anticipado, yc2, and, [p2, g1], [t2]).
circuitos:componente(sumador3_anticipado, yc3, and, [p2, p1], [t3]).
circuitos:componente(sumador3_anticipado, yc4, and, [t3, g0], [t4]).
circuitos:componente(sumador3_anticipado, oc2, or, [g2, t2], [t5]).
circuitos:componente(sumador3_anticipado, oc3, or, [t5, t4], [c]).
```

```prolog
?- equivalentes(sumador3, sumador3_anticipado).
true.

?- compuertas(sumador3, N), compuertas(sumador3_anticipado, M).
N = 12,
M = 15.
```

El sumador con acarreo anticipado usa tres compuertas más, y a cambio el
acarreo final no espera a los acarreos intermedios. Una conducta más lo
mide: si cada entrada lleva 0 y cada compuerta da uno más que la mayor de
sus entradas, cada salida lleva la cantidad de compuertas del camino más
largo que llega a ella.

<!-- ejemplo: capitulo-48/soluciones.pl predicado: profundidad/4 -->
```prolog
%!  profundidad(+Ruta:list, +Tipo, +Entradas:list(integer), -P:integer)
%!      is det.
%
%   Una conducta más: cada cable lleva la cantidad de compuertas que hay
%   en el camino más largo desde una entrada, y cada entrada, 0.
profundidad(_Ruta, _Tipo, Entradas, P) :-
    max_list(Entradas, P0),
    P is P0 + 1.
```

```prolog
?- once(simular(profundidad, sumador3, [0, 0, 0, 0, 0, 0], P1)), once(simular(profundidad, sumador3_anticipado, [0, 0, 0, 0, 0, 0], P2)).
P1 = [1, 2, 4, 5],
P2 = [1, 2, 4, 4].
```

El acarreo final atraviesa cuatro compuertas en lugar de cinco. En un
sumador de n bits la diferencia crece con n, porque la cadena de acarreos
crece y la fórmula anticipada no la recorre. La equivalencia se demuestra
sin recorrer las 64 combinaciones.

## Ejercicio 12

La cobertura prueba los subconjuntos de los implicantes primos por tamaño
creciente, de modo que el primero que cubre todas las filas es uno de los
más chicos:

<!-- ejemplo: capitulo-48/soluciones_vectores.pl predicado: cobertura/3 subconjunto/2 -->
```prolog
%!  cobertura(+Unos:list(list), +Primos:list(list), -Elegidos:list(list))
%!      is semidet.
%
%   Elegidos es un subconjunto de Primos, de la menor cantidad posible de
%   elementos, tal que cada vector de Unos está cubierto por alguno de
%   ellos. Entre los del mismo tamaño, da el primero en el orden de
%   Primos. Falla si Primos no cubre todos los Unos.
cobertura(Unos, Primos, Elegidos) :-
    length(Primos, N),
    between(0, N, K),
    length(Elegidos, K),
    subconjunto(Primos, Elegidos),
    forall(member(U, Unos),
           ( member(P, Elegidos),
             cubre(P, U) )),
    !.

%!  subconjunto(+Lista:list, ?Sub:list) is nondet.
%
%   Sub tiene elementos de Lista, en el mismo orden.
subconjunto([], []).
subconjunto([X|Xs], [X|Ys]) :-
    subconjunto(Xs, Ys).
subconjunto([_|Xs], Ys) :-
    subconjunto(Xs, Ys).
```

```prolog
?- unos(sumador, co, Us), implicantes_primos(Us, Ps), cobertura(Us, Ps, Cs).
Us = [[-, +, +], [+, -, +], [+, +, -], [+, +, +]],
Ps = Cs, Cs = [[0, +, +], [+, 0, +], [+, +, 0]].

?- Us = [[+, -, -], [+, -, +], [+, +, +], [-, +, +]], implicantes_primos(Us, Ps), cobertura(Us, Ps, Cs).
Us = [[+, -, -], [+, -, +], [+, +, +], [-, +, +]],
Ps = [[0, +, +], [+, 0, +], [+, -, 0]],
Cs = [[0, +, +], [+, -, 0]].
```

El acarreo necesita sus tres implicantes primos: cada uno es el único que
cubre una de las filas con dos entradas en 1. En el segundo caso, a · c
cubre las filas a · ¬b · c y a · b · c, pero la primera ya la cubre a · ¬b y
la segunda b · c, y el resultado es b · c + a · ¬b. La búsqueda prueba hasta
2ⁿ subconjuntos de n implicantes; el método de Quine y McCluskey elige
primero los **esenciales**, los que son los únicos que cubren alguna fila,
y reduce así la búsqueda, que en general es un problema difícil.

## Ejercicio 13

`retardar/3`, de la página
[Retardos en cascada](secuenciales.md#retardos-en-cascada), recorre los
pulsos con `retardo/4`:

<!-- ejemplo: capitulo-48/retardos.pl predicado: retardar/3 -->
```prolog
%!  retardar(?Entradas:list, +Estado0:list, ?Salidas:list) is det.
%
%   Salidas son las salidas de la cascada de retardo/4 en cada pulso,
%   desde el Estado0, cuando Entradas son sus entradas. Una de las dos
%   listas debe tener longitud conocida.
retardar(Entradas, Estado0, Salidas) :-
    foldl(retardo_en_pulso, Entradas, Salidas, Estado0, _).
```

En cada pulso la salida es la entrada de dos pulsos antes, y los dos
primeros pulsos dan los ceros del estado inicial:

```prolog
?- retardar([1, 0, 1, 1], [0, 0], Qs).
Qs = [0, 0, 1, 0].

?- retardar(Es, [0, 0], [0, 0, 1, 0]).
Es = [1, 0, _, _].
```

En sentido inverso, las dos últimas entradas quedan libres: entraron en la
cascada pero todavía no llegaron a la salida, y cualquier valor da las
mismas salidas. `desplazamiento(N)` alcanza los 2ᴺ estados: con una sola
entrada, en N pulsos se puede escribir en el registro cualquier sucesión de
N bits, y el registro no tiene otros estados. Lo verifica la prueba
`alcanzables` de `retardos.plt` para N = 3.

## Ejercicio 14

Cada variante quita un transistor del par en paralelo:

<!-- ejemplo: capitulo-48/soluciones_cmos.pl predicado: xor_sin_par_p/3 xor_sin_par_n/3 -->
```prolog
%!  xor_sin_par_p(?A, ?B, ?Z) is nondet.
%
%   La XOR de seis transistores de xor_cmos/3 sin el transistor p del par
%   en paralelo: cinco transistores.
xor_sin_par_p(A, B, Z) :-
    inversor_cmos(A, NA),
    ntran(B, NA, Z),
    ptran(A, B, Z),
    ntran(NA, B, Z).

%!  xor_sin_par_n(?A, ?B, ?Z) is nondet.
%
%   La XOR de seis transistores de xor_cmos/3 sin el transistor n del par
%   en paralelo: cinco transistores.
xor_sin_par_n(A, B, Z) :-
    inversor_cmos(A, NA),
    ptran(B, A, Z),
    ptran(A, B, Z),
    ntran(NA, B, Z).
```

```prolog
?- xor_sin_par_p(A, B, Z).
A = B, B = Z, Z = 0 ;
A = 0,
B = Z, Z = 1 ;
A = Z, Z = 1,
B = 0 ;
A = B, B = 1,
Z = 0.
```

Las dos variantes tienen la tabla de `xor_cmos/3`, y las pruebas `sin_par_p`
y `sin_par_n` lo verifican. Cuando A es 0, el transistor n del par conduce y
pasa B a la salida, y el p también; en el modelo, uno solo basta. En un
circuito real, un transistor n transmite bien el 0 y mal el 1, que llega
debilitado, y un p al revés: con los dos en paralelo, la salida recibe los
dos valores completos. El modelo de estados estables solo distingue 0 y 1,
y por eso no puede detectar ese defecto: una simulación que da la tabla
correcta no prueba que el circuito funcione, aunque una que da una tabla
incorrecta sí prueba que no funciona.
