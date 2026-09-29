# Soluciones del capítulo 50 — Proyecto: la FFT simbólica

El código de esta página está en `ejemplos/capitulo-50/soluciones.pl`, con
sus pruebas en `soluciones.plt`. Carga el programa terminado del capítulo,
`fft.pl`, y con él las cinco versiones: `tdf.pl`, `raices.pl`,
`mitades.pl`, `grafo.pl` y `mariposa.pl`. Como carga otros archivos, se
ejecuta en una instalación local y no en SWISH:

<!-- ejemplo: capitulo-50/soluciones.pl fragmento: :- ensure_loaded(fft). .. :- ensure_loaded(fft). -->
```prolog
:- ensure_loaded(fft).
```

## 1

```prolog
?- evaluar([0, 1, 2, 3], 3, 4, E0), simplificar_raices(4, E0, E).
E0 = a(0)+w(2)*a(2)+w(3)*(a(1)+w(2)*a(3)),
E = a(0)-a(2)-w(1)*(a(1)-a(3)).
```

Con $k = 3$ y $n = 4$, el primer nivel evalúa los polinomios de índices
`[0, 2]` y `[1, 3]` en $\omega^{6 \bmod 4} = \omega^2$, y multiplica el
segundo por `w(3)`. La simplificación es de abajo hacia arriba. En las dos
sumas internas, `a(0) + w(2) * a(2)` y `a(1) + w(2) * a(3)`, se aplica la
tercera regla de `raiz/3` con $K = 2 = n/2$: pasan a ser restas con
`w(0) * ...`, y la segunda regla y `regla(1 * X, X)` del
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md) eliminan el producto. En la suma externa, `w(3)` tiene
$3 \geq 2$: la misma regla la convierte en la resta con `w(1)`, que
queda. El resultado es $X_3 = (a_0 - a_2) - i\,(a_1 - a_3)$, con
$\omega = i$.

## 2

Con la llamada recursiva `alternar(T, Ys, Xs)`, los elementos siguientes
se reparten con los papeles cambiados en cada nivel:

<!-- ejemplo: capitulo-50/soluciones.pl predicado: alternar_mal/3 -->
```prolog
%!  alternar_mal(?Lista:list, ?Pares:list, ?Impares:list) is semidet.
%
%   La versión con error del ejercicio 2: pretende ser alternar/3, pero la
%   llamada recursiva intercambia las dos listas.
alternar_mal([], [], []).
alternar_mal([X, Y|T], [X|Xs], [Y|Ys]) :-
    alternar_mal(T, Ys, Xs).
```

```prolog
?- alternar_mal([0, 1, 2, 3], P, I).
P = [0, 3],
I = [1, 2].
```

El primer par va bien (0 a los pares, 1 a los impares), pero el segundo
llega con las listas intercambiadas: 2 va a los impares y 3 a los pares.
Con una copia de `mitades.pl` que tiene ese error, fallan cuatro pruebas
de `mitades.plt`: `alternar`, `inversa`, `salida_seis` y
`como_definicion` para los órdenes 4, 8 y 16. Pasan `impar`, `un_indice`,
`no_potencia` y `costo`: con una lista de dos elementos el error no se
manifiesta, y la cantidad de operaciones no depende de qué índice va en
cada lugar. De las cuatro salidas de `fft_arboles(4, Es)` solo la 0 sigue
siendo correcta, porque en ella todas las potencias son `w(0)` y el valor
es la suma de los cuatro coeficientes, en cualquier orden. La prueba
numérica es la que encuentra el error: la cantidad de operaciones no lo ve.

## 3

La solución agrega una cláusula a `costo/4`, que es `multifile`:

<!-- ejemplo: capitulo-50/soluciones.pl fragmento: % costo/4, declarada en tdf.pl: el grafo de las expresiones de la matriz, .. contar_nodos(Nodos, _, S, P). -->
```prolog
% costo/4, declarada en tdf.pl: el grafo de las expresiones de la matriz,
% simplificadas, sin la recursión sobre las mitades.
costo(matriz_grafo, N, S, P) :-
    tdf_ingenua(N, Es0),
    maplist(simplificar_raices(N), Es0, Es),
    grafo(Es, Nodos, _),
    contar_nodos(Nodos, _, S, P).
```

```prolog
?- costo(matriz_grafo, 8, S, P).
S = 56,
P = 14.
```

De 32 productos quedan 14, y las 56 sumas siguen siendo 56. Después de la
simplificación, un término como `w(1) * a(3)` aparece en varias salidas: el
exponente $3k \bmod 8$, reducido a menos de $n/2$ con la regla del signo,
repite valores entre las filas, y el grafo calcula cada producto una vez.
Las sumas, en cambio, están asociadas a izquierda desde el primer término:
la salida $k$ es `((a(0) + T1) + T2) + ...`, y dos salidas solo
compartirían una suma si tuvieran el mismo prefijo de términos, lo que no
ocurre porque el segundo término, el de `a(1)`, es distinto en cada fila.
La forma de las expresiones decide qué se puede compartir: la de la
recursión sobre las mitades agrupa los términos de modo que los grupos se
repiten.

## 4

<!-- ejemplo: capitulo-50/soluciones.pl predicado: productos_por/3 productos_no_triviales/2 -->
```prolog
%!  productos_por(+Nodos:list, +K:integer, -Cantidad:integer) is det.
%
%   Cantidad es la cantidad de productos del grafo Nodos en los que uno de
%   los operandos es la hoja w(K).
productos_por(Nodos, K, Cantidad) :-
    memberchk(nodo(Raiz, w(K)), Nodos),
    !,
    aggregate_all(count,
                  ( member(nodo(_, op(*, I, J)), Nodos),
                    ( I == Raiz -> true ; J == Raiz )
                  ),
                  Cantidad).
productos_por(_, _, 0).

%!  productos_no_triviales(+N:integer, -Cantidad:integer) is det.
%
%   Cantidad es la cantidad de productos de la mariposa de orden N que no
%   son por w(N/4), es decir, por la unidad imaginaria. N es una potencia
%   de 2.
productos_no_triviales(N, Cantidad) :-
    fft_grafo(N, Nodos, _),
    contar_nodos(Nodos, _, _, P),
    K is N // 4,
    productos_por(Nodos, K, Pi),
    Cantidad is P - Pi.
```

```prolog
?- grafo([w(1) * a + w(1) * b], Ns, _), productos_por(Ns, 1, C).
Ns = [nodo(1, w(1)), nodo(2, a), nodo(3, op(*, 1, 2)), nodo(4, b), nodo(5, op(*, 1, 4)), nodo(6, op(+, 3, 5))],
C = 2.

?- productos_no_triviales(16, C).
C = 10.
```

La hoja `w(K)` es un solo nodo, así que basta con buscar su número y contar
los productos que lo usan. Si el grafo no tiene la hoja, la segunda
cláusula da 0. En la mariposa de orden 8 hay 3 productos por `w(2)`: uno
en el último nivel y uno en cada una de las dos transformadas de orden 4
del nivel anterior, donde $\omega_8^2$ hace de $\omega_4 = i$. Quedan 2, 10
y 34 productos que no son por $i$ en los órdenes 8, 16 y 32, contra 5, 17 y
49 en total. Los programas de la transformada rápida aprovechan también
este caso, y los de $\omega^{n/8}$, cuyas partes real e imaginaria son
iguales.

## 5

El encabezado declara `semidet`: si `Id` no es un nodo del grafo,
`memberchk/2` falla. `Nodos` e `Id` son de entrada, porque la profundidad
se calcula a partir del nodo; con `Id` libre, `memberchk/2` tomaría el
primer nodo y el predicado dejaría de describir la relación para los
demás.

<!-- ejemplo: capitulo-50/soluciones.pl predicado: profundidad/3 profundidad_maxima/3 profundidad_version/3 -->
```prolog
%!  profundidad(+Nodos:list, +Id:integer, -P:integer) is semidet.
%
%   P es la cantidad de operaciones del camino más largo desde una hoja
%   del grafo Nodos hasta el nodo Id; 0 si Id es una hoja. Falla si Id no
%   es un nodo del grafo.
profundidad(Nodos, Id, P) :-
    memberchk(nodo(Id, T), Nodos),
    (   T = op(_, I, J)
    ->  profundidad(Nodos, I, PI),
        profundidad(Nodos, J, PJ),
        P is max(PI, PJ) + 1
    ;   P = 0
    ).

%!  profundidad_maxima(+Nodos:list, +Salidas:list, -P:integer) is det.
%
%   P es la mayor profundidad de los nodos Salidas del grafo Nodos.
profundidad_maxima(Nodos, Salidas, P) :-
    maplist(profundidad(Nodos), Salidas, Ps),
    max_list(Ps, P).

%!  profundidad_version(+Version, +N:integer, -P:integer) is det.
%
%   P es la mayor profundidad de las salidas del grafo de orden N de la
%   Version: mariposa, o matriz_grafo, el del ejercicio 3.
profundidad_version(mariposa, N, P) :-
    fft_grafo(N, Nodos, Salidas),
    profundidad_maxima(Nodos, Salidas, P).
profundidad_version(matriz_grafo, N, P) :-
    tdf_ingenua(N, Es0),
    maplist(simplificar_raices(N), Es0, Es),
    grafo(Es, Nodos, Salidas),
    profundidad_maxima(Nodos, Salidas, P).
```

```prolog
?- profundidad_version(mariposa, 8, P).
P = 5.
```

Las profundidades máximas de la mariposa de órdenes 4, 8 y 16 son 3, 5 y 7,
$2 \log_2 n - 1$: en cada nivel una suma o resta, y en todos menos el
primero un producto antes. Las del grafo de la matriz simplificada
(ejercicio 3) son 4, 8 y 16, es decir $n$: la suma asociada a izquierda es
una cadena de $n - 1$ sumas, con un producto al principio. La profundidad
mide cuántos pasos hacen falta si todas las operaciones de un nivel se
calculan a la vez: la mariposa es menos costosa también en ese sentido. El
recorrido no guarda las profundidades ya calculadas, y en un grafo con
muchos caminos repite trabajo; para los órdenes de la prueba alcanza.

## 6

<!-- ejemplo: capitulo-50/soluciones.pl predicado: rotaciones/1 costo_rotaciones/4 -->
```prolog
%!  rotaciones(-Es:list) is det.
%
%   Es son los 16 elementos, fila por fila, del producto simplificado de
%   las rotaciones alrededor del eje z en los ángulos a y b.
rotaciones(Es) :-
    rotacion(z, a, A),
    rotacion(z, b, B),
    producto_simbolico(A, B, P),
    append(P, Es).

%!  costo_rotaciones(-S0, -P0, -S, -P) is det.
%
%   Los elementos de rotaciones/1 tienen, por separado, S0 sumas o restas
%   y P0 productos, y su grafo tiene S sumas o restas y P productos.
costo_rotaciones(S0, P0, S, P) :-
    rotaciones(Es),
    operaciones(Es, S0, P0),
    grafo(Es, Nodos, _),
    contar_nodos(Nodos, _, S, P).
```

```prolog
?- costo_rotaciones(S0, P0, S, P).
S0 = S, S = 4,
P0 = 8,
P = 7.
```

Los 16 elementos del producto, simplificados, tienen 4 sumas y 8
productos; el grafo, 4 sumas y 7 productos. Solo se comparte
`cos(a) * cos(b)`, que está en los elementos de la fila 1, columna 1, y de
la fila 2, columna 2. Los productos `sin(a) * -sin(b)` y `-sin(a) * sin(b)`
valen lo mismo, pero son términos distintos, y `grafo/3` compara términos,
no valores: para compartirlos, antes habría que llevar las expresiones a
una forma normal que saque el signo afuera del producto. Además, `-sin(b)`
queda como una hoja, porque `operacion/4` reconoce solo operaciones de dos
argumentos; las hojas `0` y `1`, que son constantes, se calculan una vez,
y cada una es la salida de varios elementos.

## 7

Las inferencias de `fft_grafo/3`, medidas con `statistics/2`:

| $n$ | `fft_grafo/3` | de ellas, `grafo/3` | árboles y simplificación |
|---|---|---|---|
| 16 | 110 499 | 31 502 | 53 848 |
| 32 | 491 993 | 246 721 | 245 272 |
| 64 | 3 023 473 | 1 926 105 | 1 097 368 |
| 128 | 19 884 561 | 15 036 537 | 4 848 024 |

El total crece 4,5, 6,2 y 6,6 veces con cada duplicación, y `grafo/3`,
cerca de 8 veces. Cada una de las $n$ salidas es un árbol de unos $4n$
nodos, así que `agregar/3` visita unos $4n^2$ nodos, también los de las
subexpresiones que ya agregó; y en cada visita `buscar/3` recorre la lista
del diccionario, que llega a tener del orden de $n \log_2 n$ entradas,
comparando claves. El producto crece como $n^3 \log n$: con cada
duplicación, algo más de 8 veces. La construcción de los árboles y su
simplificación crece más despacio, como el tamaño de los árboles, $n^2$
por un factor logarítmico.

## 8

<!-- ejemplo: capitulo-50/soluciones.pl predicado: presente/3 grafo_rapido/3 agregar_rapido/3 -->
```prolog
%!  presente(+E, ?Dic, -Id) is semidet.
%
%   La clave cerrada E está en el diccionario incompleto Dic con el valor
%   Id. A diferencia de buscar/3, no agrega nada: falla al llegar al final
%   abierto.
presente(E, Dic, Id) :-
    nonvar(Dic),
    Dic = [E0-V|Resto],
    (   E0 == E
    ->  Id = V
    ;   presente(E, Resto, Id)
    ).

%!  grafo_rapido(+Es:list, -Nodos:list, -Salidas:list(integer)) is det.
%
%   La misma relación que grafo/3, sin volver a recorrer una subexpresión
%   que ya está en el diccionario.
grafo_rapido(Es, Nodos, Salidas) :-
    must_be(ground, Es),
    maplist(agregar_rapido(Dic), Es, Salidas),
    numerar(Dic, 1),
    nodos(Dic, Dic, Nodos).

%!  agregar_rapido(?Dic, +E, -Id) is det.
%
%   Como agregar/3, pero si E ya está en Dic no examina sus hijos, que
%   también están.
agregar_rapido(Dic, E, Id) :-
    (   presente(E, Dic, Id0)
    ->  Id = Id0
    ;   (   operacion(E, _, A, B)
        ->  agregar_rapido(Dic, A, _),
            agregar_rapido(Dic, B, _)
        ;   true
        ),
        buscar(E, Dic, Id)
    ).
```

`presente/3` recorre el diccionario sin llegar a agregar: se detiene con
una falla en el final abierto, y compara con `==/2`, que no liga nada.
`agregar_rapido/3` solo examina los hijos de una subexpresión nueva. Las
entradas se agregan en el mismo orden que con `agregar/3`, porque las
visitas que se omiten no agregaban nada, y la prueba `ejercicio_8`
comprueba que los dos grafos son iguales. Con las expresiones ya
simplificadas, `grafo_rapido/3` usa 22 105, 133 650, 763 395 y 4 158 196
inferencias para los órdenes 16 a 128, contra las de `grafo/3` del
ejercicio 7: 3,6 veces menos para $n = 128$, y la diferencia crece con
$n$. Lo que queda es el recorrido lineal de la lista; el diccionario en
árbol de la
[sección 34.4](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#344-diccionarios-incompletos) lo haría logarítmico, pero no conserva el orden
en que se agregaron las entradas, que es el que hace falta para numerar los
nodos después de sus hijos.

## 9

<!-- ejemplo: capitulo-50/soluciones.pl predicado: valor_exacto/4 raiz_exacta/3 fft_exacta/2 -->
```prolog
%!  valor_exacto(+N:integer, +Coefs:list, +E, -V) is det.
%
%   Como valor/4, con N igual a 1, 2 o 4 y las raíces exactas: V es un
%   complejo de componentes enteras si los coeficientes son enteros.
valor_exacto(_, _, X, c(X, 0)) :-
    number(X),
    !.
valor_exacto(_, Coefs, a(J), V) :-
    !,
    nth0(J, Coefs, C),
    complejo(C, V).
valor_exacto(N, _, w(K), V) :-
    !,
    raiz_exacta(N, K, V).
valor_exacto(N, Coefs, E, V) :-
    E =.. [Op, A, B],
    valor_exacto(N, Coefs, A, VA),
    valor_exacto(N, Coefs, B, VB),
    operar(Op, VA, VB, V).

%!  raiz_exacta(+N:integer, +K:integer, -V) is det.
%
%   V es la potencia K de la raíz N-ésima de la unidad, exacta, con N igual
%   a 1, 2 o 4. Produce un error de dominio para otro N.
raiz_exacta(N, K, V) :-
    (   memberchk(N, [1, 2, 4])
    ->  true
    ;   domain_error(orden_exacto, N)
    ),
    Q is (K * (4 // N)) mod 4,
    nth0(Q, [c(1, 0), c(0, 1), c(-1, 0), c(0, -1)], V).

%!  fft_exacta(+Coefs:list(integer), -Vs:list) is det.
%
%   Vs es la transformada exacta de Coefs, de longitud 1, 2 o 4, con el
%   grafo de la mariposa.
fft_exacta(Coefs, Vs) :-
    length(Coefs, N),
    fft_grafo(N, Nodos, Salidas),
    valor_grafo_exacto(N, Coefs, Nodos, Salidas, Vs).
```

```prolog
?- fft_exacta([1, 2, 3, 4], Vs).
Vs = [c(10, 0), c(-2, -2), c(-2, 0), c(-2, 2)].
```

Las raíces de orden 1, 2 y 4 son potencias de $i$: `raiz_exacta/3` lleva
el exponente a un exponente de $i$ multiplicando por $4/n$, y lo toma de
una tabla. Con coeficientes enteros, todas las operaciones de `operar/4`
son sumas, restas y productos de enteros, y el resultado es exacto. La
solución completa agrega `valor_grafo_exacto/5` y `valor_nodo_exacto/5`,
copias de `valor_grafo/5` y `valor_nodo/5` que llaman a `valor_exacto/4`;
pasar el evaluador de hojas como argumento evitaría la copia. Para
$n = 8$, $\omega = (1 + i)/\sqrt{2}$ no es un complejo de componentes
racionales, y `raiz_exacta/3` produce un error de dominio.

## 10

<!-- ejemplo: capitulo-50/soluciones.pl predicado: fft_inversa_grafo/3 salida_inversa/4 fft_inversa/2 dividir/3 -->
```prolog
%!  fft_inversa_grafo(+N:integer, -Nodos:list, -Salidas:list) is det.
%
%   Nodos es el grafo de la transformada inversa de orden N sin la
%   división por N: la salida J es el polinomio de las entradas evaluado
%   en w(-J), es decir, en w((N - J) mod N). N es una potencia de 2.
fft_inversa_grafo(N, Nodos, Salidas) :-
    potencia_de_dos(N),
    N1 is N - 1,
    numlist(0, N1, Is),
    maplist(salida_inversa(Is, N), Is, Es0),
    maplist(simplificar_raices(N), Es0, Es),
    grafo(Es, Nodos, Salidas).

%!  salida_inversa(+Is:list(integer), +N:integer, +J:integer, -E) is det.
%
%   E es la expresión de la salida J de la transformada inversa de orden N.
salida_inversa(Is, N, J, E) :-
    K is (N - J) mod N,
    evaluar(Is, K, N, E).

%!  fft_inversa(+Xs:list, -As:list) is det.
%
%   As es la transformada inversa de Xs, una lista de números o complejos
%   c(Re, Im) de longitud potencia de 2: el grafo de fft_inversa_grafo/3
%   evaluado con Xs, y cada valor dividido por la longitud.
fft_inversa(Xs, As) :-
    length(Xs, N),
    fft_inversa_grafo(N, Nodos, Salidas),
    valor_grafo(N, Xs, Nodos, Salidas, Vs),
    maplist(dividir(N), Vs, As).

%!  dividir(+N:number, +V, -W) is det.
%
%   W es el complejo V dividido por N.
dividir(N, c(R0, I0), c(R, I)) :-
    R is R0 / N,
    I is I0 / N.
```

```prolog
?- fft_numerica([1, 2, 3, 4], Xs), fft_inversa(Xs, As).
Xs = [c(10, 0), c(-2.0, -2.0), c(-2, 0), c(-1.9999999999999998, 2.0)],
As = [c(1.0, 0.0), c(2.0, 1.167414689223767e-16), c(3.0, 0.0), c(4.0, -1.167414689223767e-16)].
```

La inversa es la misma transformada con $\omega^{-1}$ en lugar de
$\omega$: la salida $j$ evalúa el polinomio de las entradas en
$\omega^{-j} = \omega^{(n - j) \bmod n}$. `evaluar/4` no necesita cambios,
y el grafo es una mariposa con la misma cantidad de operaciones. Los
coeficientes vuelven con errores de redondeo del orden de $10^{-16}$, que
`cercanos/2` tolera; la prueba `ejercicio_10` lo verifica hasta $n = 16$.

## 11

<!-- ejemplo: capitulo-50/soluciones.pl predicado: producto_polinomios/3 potencia_mayor/3 completar/3 -->
```prolog
%!  producto_polinomios(+P:list(integer), +Q:list(integer),
%!                      -R:list(integer)) is det.
%
%   R es la lista de coeficientes del producto de los polinomios de
%   coeficientes P y Q, calculado con la transformada rápida: las dos
%   transformadas, su producto salida por salida y la inversa, con la
%   parte real redondeada. P y Q no son vacías.
producto_polinomios(P, Q, R) :-
    length(P, LP),
    length(Q, LQ),
    L is LP + LQ - 1,
    potencia_mayor(L, 1, N),
    completar(P, N, P1),
    completar(Q, N, Q1),
    fft_numerica(P1, VP),
    fft_numerica(Q1, VQ),
    maplist(operar(*), VP, VQ, VR),
    fft_inversa(VR, As),
    length(R0, L),
    append(R0, _, As),
    maplist([c(Re, _), X]>>(X is round(Re)), R0, R).

%!  potencia_mayor(+L:integer, +N0:integer, -N:integer) is det.
%
%   N es la menor potencia de 2 que es al menos L y al menos N0, con N0 una
%   potencia de 2.
potencia_mayor(L, N0, N) :-
    (   N0 >= L
    ->  N = N0
    ;   N1 is 2 * N0,
        potencia_mayor(L, N1, N)
    ).

%!  completar(+P:list, +N:integer, -P1:list) is det.
%
%   P1 es P seguida de ceros hasta tener N elementos; P no tiene más de N.
completar(P, N, P1) :-
    length(P, LP),
    K is N - LP,
    length(Ceros, K),
    maplist(=(0), Ceros),
    append(P, Ceros, P1).
```

```prolog
?- producto_polinomios([1, 2, 3], [4, 5], R).
R = [4, 13, 22, 15].
```

El producto tiene grado 3 y 4 coeficientes, así que alcanza con $n = 4$.
Evaluar $p$ y $q$ en las $n$ raíces, multiplicar los valores y volver a
los coeficientes con la inversa da los coeficientes de $p\,q$, porque un
polinomio de grado menor que $n$ queda determinado por sus valores en $n$
puntos distintos. Los ceros agregados hacen que el producto tenga grado
menor que $n$; con menos puntos, los coeficientes de grado $n$ o más se
sumarían a los de grado menor. El resultado es de punto flotante, y
`round/1` lo lleva a enteros, lo que es correcto mientras el error de
redondeo sea menor que un medio. Con polinomios grandes, este es el método
que multiplica en del orden de $n \log n$ operaciones en lugar de $n^2$.

## 12

`buscar/3` compara la clave buscada con cada clave del diccionario por
unificación. Una clave con variables libres unifica con cualquier clave de
la misma forma, y las liga:

```prolog
?- buscar(op(+, I1, J1), D, V1), buscar(op(+, I2, J2), D, V2).
I1 = I2,
J1 = J2,
D = [op(+, I2, J2)-V2|_],
V1 = V2.
```

La segunda búsqueda encuentra la primera clave y unifica los números de
los hijos: las dos sumas quedan convertidas en el mismo nodo, cualesquiera
que sean sus operandos. `grafo/3` respondería con un grafo que tiene una
sola suma para `a + b` y `c + d`, y con los nodos de `a` y de `c` unidos
en uno. Por eso la clave es la subexpresión cerrada, que solo unifica con
otra igual, y los números se ligan al final con `numerar/2`. El capítulo de
Clocksin evita el problema de otra forma: numera cada nodo en el momento
de agregarlo, con un contador, de modo que la clave `op(+, I, J)` ya tiene
números y no variables. Las dos soluciones dan el mismo grafo; la del
contador compara claves más pequeñas, y la del diccionario no necesita
pasar el contador por todo el recorrido. La prueba `ejercicio_12`
comprueba que dos búsquedas de `op(+, _, _)`, con una clave `op(-, _, _)`
en medio, devuelven el mismo valor.
