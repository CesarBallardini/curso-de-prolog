# Soluciones del capítulo 46 — Proyecto: métodos numéricos

El código de esta página está en dos archivos de `ejemplos/capitulo-46/`,
cada uno con sus pruebas en el `.plt` del mismo nombre. `soluciones.pl`
resuelve los ejercicios 3 a 12 y carga `metodos.pl` y con él todo el
programa del capítulo —`iteracion.pl`, `biseccion.pl`, `secante.pl`,
`newton.pl` y `gauss_seidel.pl`— y los programas del
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md).
`soluciones_covington.pl` resuelve el 13 y el 14 y carga `covington.pl`.
Los ejercicios 1 y 2 se resuelven con los archivos del capítulo. Como allí,
los resultados de punto flotante se comparan en las pruebas con una
tolerancia.

## 1

La bisección reduce el ancho del intervalo a la mitad en cada paso, sin
usar el valor de la función más que por su signo:

<!-- ejemplo: capitulo-46/biseccion.pl predicado: paso_biseccion/6 -->
```prolog
%!  paso_biseccion(+F, +X:atom, +Intervalo0, -Intervalo, -M:float,
%!                 -Ancho:float) is det.
%
%   Intervalo es la mitad de Intervalo0, intervalo(A, FA, B), en la que F
%   cambia de signo; M es el punto medio y Ancho el ancho de la mitad.
paso_biseccion(F, X, intervalo(A, FA, B), Intervalo, M, Ancho) :-
    M is (A + B) / 2,
    valor_en(F, X, M, FM),
    Ancho is (B - A) / 2,
    (   FA * FM =< 0
    ->  Intervalo = intervalo(A, FA, M)
    ;   Intervalo = intervalo(M, FM, B)
    ).
```

Con un ancho inicial de 1 y una tolerancia de 1.0e-6, el ciclo se detiene en
el primer n con 1 / 2ⁿ ≤ 1.0e-6, es decir 2ⁿ ≥ 10⁶: como 2¹⁹ = 524 288 y
2²⁰ = 1 048 576, n = 20.

```prolog
?- biseccion(x ^ 3 = 10, x, 2-3, 1.0e-6, Xs), length(Xs, N).
Xs = [2.5, 2.25, 2.125, 2.1875, 2.15625, 2.140625, 2.1484375, 2.15234375, 2.154296875|...],
N = 20.
```

El paso de Newton, en cambio, depende de la función y de su derivada en cada
punto:

<!-- ejemplo: capitulo-46/newton.pl predicado: paso_newton/7 -->
```prolog
%!  paso_newton(+F, +DF, +X:atom, +X0:float, -X1:float, -X1:float,
%!              -Cambio:float) is semidet.
%
%   X1 es el punto donde la tangente a F en X0 corta el eje; DF es la
%   derivada de F. El estado y la aproximación son el mismo número. Falla
%   si la derivada vale 0 en X0.
paso_newton(F, DF, X, X0, X1, X1, Cambio) :-
    valor_en(F, X, X0, F0),
    valor_en(DF, X, X0, D0),
    D0 =\= 0,
    X1 is X0 - F0 / D0,
    Cambio is abs(X1 - X0).
```

```prolog
?- newton(x ^ 3 = 10, x, 2, 1.0e-6, Xs), length(Xs, N).
Xs = [2.1666666666666665, 2.1545036160420774, 2.1544346922369133, 2.154434690031884],
N = 4.
```

La cantidad de pasos de Newton depende de lo lejos que está el punto de
partida de la raíz y de la forma de la función entre los dos: desde 2, el
primer paso ya deja dos cifras correctas, y cada paso siguiente las duplica.
No hay una fórmula que la dé antes de empezar; la de la bisección solo usa el
ancho del intervalo y la tolerancia.

## 2

La ecuación E − 0.01 sen E = 2.5 se escribe con la incógnita `x`:

```prolog
?- secante(x - 0.01 * sin(x) = 2.5, x, 1-2, R).
R = 2.5059370519317916.
```

`resolver/5` intenta primero Newton a través de `derivable/1`:

<!-- ejemplo: capitulo-46/metodos.pl predicado: derivable/1 -->
```prolog
%!  derivable(:Meta) is semidet.
%
%   Ejecuta Meta, y falla en lugar del error de dominio que produce
%   derivar/3 con una expresión que no sabe derivar.
derivable(Meta) :-
    catch(Meta, error(domain_error(expresion_derivable, _), _), fail).
```

```prolog
?- resolver(x - 0.01 * sin(x) = 2.5, x, 2, R, M).
R = 2.5059370519317916,
M = secante.
```

El resolvedor usa la secante porque `derivar/3` del
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md) no sabe derivar `sin`: produce un error de dominio,
`derivable/1` lo convierte en un fallo, y el resolvedor pasa al método
siguiente. Con la derivada del [ejercicio 6](#6), Newton la resolvería.

## 3

`iterar_sin_limite/4` es `iterar/4` sin el contador de pasos:

<!-- ejemplo: capitulo-46/soluciones.pl predicado: iterar_sin_limite/4 -->
```prolog
%!  iterar_sin_limite(:Paso, +Tol:float, +Estado0,
%!                    -Aproximaciones:list) is semidet.
%
%   Como iterar/4, sin maximo_de_pasos/1: si la tolerancia no se alcanza,
%   no termina.
iterar_sin_limite(Paso, Tol, Estado0, [X|Xs]) :-
    call(Paso, Estado0, Estado, X, Cambio),
    (   Cambio =< Tol
    ->  Xs = []
    ;   iterar_sin_limite(Paso, Tol, Estado, Xs)
    ).
```

Sin el límite, la bisección con una tolerancia de 1.0e-20 no termina. El
intervalo [1, 2] se reduce hasta que sus extremos son dos flotantes
vecinos, separados por unos 2.2e-16. A partir de ahí, el punto medio
`(A + B) / 2` se redondea a uno de los dos extremos, el intervalo que da el
paso es el mismo que el anterior, y el ancho calculado, `(B - A) / 2`, queda
fijo en unos 1.1e-16, que nunca es menor o igual que 1.0e-20. El ciclo
repite el mismo paso sin fin. Con un límite de inferencias se observa sin
esperar:

```prolog
?- funcion(x ^ 2 = 2, F), call_with_inference_limit(iterar_sin_limite(paso_biseccion(F, x), 1.0e-20, intervalo(1.0, -1.0, 2.0), _), 1000000, R).
F = x^2-2,
R = inference_limit_exceeded.
```

El problema no es del método sino de la tolerancia: ningún método puede
distinguir dos números que el tipo de punto flotante no distingue.
`maximo_de_pasos/1` convierte ese caso en un fallo.

## 4

La única diferencia con `iterar/5` es la condición de parada:

<!-- ejemplo: capitulo-46/soluciones.pl predicado: iterar_relativa/4 iterar_relativa/5 -->
```prolog
%!  iterar_relativa(:Paso, +Tol:float, +Estado0,
%!                  -Aproximaciones:list) is semidet.
%
%   Como iterar/4, con la tolerancia relativa: se detiene cuando el cambio
%   es menor o igual que Tol por el mayor entre 1 y el valor absoluto de la
%   aproximación.
iterar_relativa(Paso, Tol, Estado0, Aproximaciones) :-
    maximo_de_pasos(Maximo),
    iterar_relativa(Paso, Tol, Maximo, Estado0, Aproximaciones).

%!  iterar_relativa(:Paso, +Tol:float, +Restantes:integer, +Estado0,
%!                  -Aproximaciones:list) is semidet.
%
%   Como iterar_relativa/4, con a lo sumo Restantes pasos.
iterar_relativa(Paso, Tol, Restantes, Estado0, [X|Xs]) :-
    Restantes > 0,
    call(Paso, Estado0, Estado, X, Cambio),
    (   Cambio =< Tol * max(1, abs(X))
    ->  Xs = []
    ;   Restantes1 is Restantes - 1,
        iterar_relativa(Paso, Tol, Restantes1, Estado, Xs)
    ).
```

<!-- ejemplo: capitulo-46/soluciones.pl predicado: biseccion_relativa/5 -->
```prolog
%!  biseccion_relativa(+Ecuacion, +X:atom, +Intervalo, +Tol:float,
%!                     -Aproximaciones:list(float)) is semidet.
%
%   Como biseccion/5, con la tolerancia relativa de iterar_relativa/4.
biseccion_relativa(Ecuacion, X, A0-B0, Tol, Xs) :-
    funcion(Ecuacion, F),
    A is float(A0),
    B is float(B0),
    valor_en(F, X, A, FA),
    valor_en(F, X, B, FB),
    (   A < B,
        FA * FB =< 0
    ->  iterar_relativa(paso_biseccion(F, X), Tol, intervalo(A, FA, B), Xs)
    ;   domain_error(intervalo_con_cambio_de_signo, A0-B0)
    ).
```

```prolog
?- biseccion_relativa(x ^ 2 = 2.0e12, x, 0-2.0e6, 1.0e-12, Xs), last(Xs, R), length(Xs, N).
Xs = [1000000.0, 1500000.0, 1250000.0, 1375000.0, 1437500.0, 1406250.0, 1421875.0, 1414062.5, 1417968.75|...],
R = 1414213.5623724242,
N = 41.
```

Cerca de 1.4·10⁶, la tolerancia relativa pide un cambio de a lo sumo
1.4·10⁻⁶, que los flotantes pueden representar, y la respuesta tiene doce
cifras significativas correctas, las mismas que la tolerancia absoluta daba
para √2. Para aproximaciones de valor absoluto menor que 1, el factor
max(1, |X|) mantiene la tolerancia absoluta: sin él, una raíz en 0 pediría
un cambio de 0 y no se alcanzaría nunca.

## 5

El estado guarda los extremos con sus valores y la aproximación anterior,
porque el ancho del intervalo no sirve como medida del cambio: en la falsa
posición, uno de los extremos suele quedar fijo y el intervalo no se reduce
a cero.

<!-- ejemplo: capitulo-46/soluciones.pl predicado: falsa_posicion/5 paso_falsa_posicion/6 -->
```prolog
%!  falsa_posicion(+Ecuacion, +X:atom, +Intervalo, +Tol:float,
%!                 -Aproximaciones:list(float)) is semidet.
%
%   Aproximaciones son los puntos donde la secante por los extremos del
%   intervalo corta el eje, hasta que dos seguidos difieren en Tol o menos.
%   Intervalo es A-B con A < B y un cambio de signo, o se produce un error
%   de dominio.
falsa_posicion(Ecuacion, X, A0-B0, Tol, Xs) :-
    funcion(Ecuacion, F),
    A is float(A0),
    B is float(B0),
    valor_en(F, X, A, FA),
    valor_en(F, X, B, FB),
    (   A < B,
        FA * FB =< 0
    ->  iterar(paso_falsa_posicion(F, X), Tol, falsa(A, FA, B, FB, A), Xs)
    ;   domain_error(intervalo_con_cambio_de_signo, A0-B0)
    ).

%!  paso_falsa_posicion(+F, +X:atom, +Estado0, -Estado, -C:float,
%!                      -Cambio:float) is semidet.
%
%   C es el punto donde la secante por los extremos de Estado0,
%   falsa(A, FA, B, FB, Anterior), corta el eje; Estado es la parte del
%   intervalo con cambio de signo, y Cambio la distancia de C a la
%   aproximación Anterior. Falla si FA y FB son iguales.
paso_falsa_posicion(F, X, falsa(A, FA, B, FB, Anterior), Estado, C,
                    Cambio) :-
    FA =\= FB,
    C is B - FB * (B - A) / (FB - FA),
    valor_en(F, X, C, FC),
    Cambio is abs(C - Anterior),
    (   FA * FC =< 0
    ->  Estado = falsa(A, FA, C, FC, C)
    ;   Estado = falsa(C, FC, B, FB, C)
    ).
```

```prolog
?- falsa_posicion(x ^ 2 = 2, x, 1-2, 1.0e-12, Xs), length(Xs, N).
Xs = [1.3333333333333335, 1.4, 1.4117647058823528, 1.4137931034482758, 1.4141414141414144, 1.4142011834319526, 1.41421143847487, 1.4142131979695431, 1.4142134998513232|...],
N = 17.
```

Diecisiete pasos, entre los cuarenta de la bisección y los siete de la
secante. El extremo derecho, 2, queda fijo durante todo el cálculo, porque
la función es convexa y cada secante corta el eje a la izquierda de la raíz;
la convergencia es entonces lineal, más rápida que la bisección pero sin la
aceleración de la secante, que siempre usa los dos últimos puntos. A cambio,
la falsa posición conserva la garantía de la bisección: la raíz nunca sale
del intervalo.

## 6

`derivada_ampliada/3` repite los casos de `derivada/3` del
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md) y agrega las cuatro funciones con la regla de la cadena:
la derivada de f(U) es f'(U) por la derivada de U. No puede delegar en
`derivada/3` los casos que ya existen, porque esta deriva los argumentos
con sus propios casos y produciría el error de dominio en un `sin` anidado
dentro de una suma.

<!-- ejemplo: capitulo-46/soluciones.pl predicado: derivar_ampliado/3 derivada_ampliada/3 -->
```prolog
%!  derivar_ampliado(+E, +X:atom, -D) is det.
%
%   D es la derivada de la expresión cerrada E respecto de X, simplificada.
%   E usa +, -, *, ^ con exponente numérico, sin, cos, exp y log.
derivar_ampliado(E, X, D) :-
    must_be(ground, E),
    must_be(atom, X),
    derivada_ampliada(E, X, D0),
    simplificar(D0, D).

%!  derivada_ampliada(+E, +X:atom, -D) is det.
%
%   D es la derivada de E respecto de X, sin simplificar, con la regla de la
%   cadena para las cuatro funciones. Produce un error de dominio con otra
%   operación.
derivada_ampliada(E, X, D) :-
    (   E == X
    ->  D = 1
    ;   atomic(E)
    ->  D = 0
    ;   E = U + V
    ->  D = DU + DV,
        derivada_ampliada(U, X, DU),
        derivada_ampliada(V, X, DV)
    ;   E = U - V
    ->  D = DU - DV,
        derivada_ampliada(U, X, DU),
        derivada_ampliada(V, X, DV)
    ;   E = U * V
    ->  D = DU * V + U * DV,
        derivada_ampliada(U, X, DU),
        derivada_ampliada(V, X, DV)
    ;   E = U ^ N,
        number(N)
    ->  N1 is N - 1,
        D = N * U ^ N1 * DU,
        derivada_ampliada(U, X, DU)
    ;   E = sin(U)
    ->  D = cos(U) * DU,
        derivada_ampliada(U, X, DU)
    ;   E = cos(U)
    ->  D = -1 * sin(U) * DU,
        derivada_ampliada(U, X, DU)
    ;   E = exp(U)
    ->  D = exp(U) * DU,
        derivada_ampliada(U, X, DU)
    ;   E = log(U)
    ->  D = DU / U,
        derivada_ampliada(U, X, DU)
    ;   domain_error(expresion_derivable, E)
    ).
```

```prolog
?- derivar_ampliado(x - cos(x), x, D).
D = 1- -1*sin(x).

?- derivar_ampliado(sin(x ^ 2) + exp(2 * x) + log(x), x, D).
D = cos(x^2)*(2*x)+2*exp(2*x)+1/x.
```

El simplificador del [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md) no tiene reglas para el
signo, y deja `1- -1*sin(x)` en lugar de `1+sin(x)`; el valor es el mismo.
`newton_ampliado/5` es `newton/5` con este derivador:

<!-- ejemplo: capitulo-46/soluciones.pl predicado: newton_ampliado/5 -->
```prolog
%!  newton_ampliado(+Ecuacion, +X:atom, +X0:number, +Tol:float,
%!                  -Aproximaciones:list(float)) is semidet.
%
%   Como newton/5, con la derivada de derivar_ampliado/3.
newton_ampliado(Ecuacion, X, X0, Tol, Xs) :-
    funcion(Ecuacion, F),
    derivar_ampliado(F, X, DF),
    A is float(X0),
    iterar(paso_newton(F, DF, X), Tol, A, Xs).
```

```prolog
?- newton_ampliado(x = cos(x), x, 1, 1.0e-12, Xs).
Xs = [0.7503638678402439, 0.7391128909113617, 0.739085133385284, 0.7390851332151607, 0.7390851332151607].
```

Cinco pasos, contra los de la secante de la [sección 46.4](index.md#464-version-2-la-secante).
Para que `resolver/5` use Newton con esta ecuación, basta con que
`newton/5` llame a `derivar_ampliado/3` en lugar de `derivar/3`.

## 7

<!-- ejemplo: capitulo-46/soluciones.pl predicado: newton_multiple/6 paso_newton_multiple/8 -->
```prolog
%!  newton_multiple(+Ecuacion, +X:atom, +M:integer, +X0:number,
%!                  +Tol:float, -Aproximaciones:list(float)) is semidet.
%
%   Como newton/5, con el paso multiplicado por M, la multiplicidad de la
%   raíz buscada.
newton_multiple(Ecuacion, X, M, X0, Tol, Xs) :-
    funcion(Ecuacion, F),
    derivar(F, X, DF),
    A is float(X0),
    iterar(paso_newton_multiple(F, DF, X, M), Tol, A, Xs).

%!  paso_newton_multiple(+F, +DF, +X:atom, +M:integer, +X0:float,
%!                       -X1:float, -X1:float, -Cambio:float) is semidet.
%
%   X1 es X0 menos M veces el cociente entre F y su derivada DF en X0.
%   Falla si la derivada vale 0 en X0.
paso_newton_multiple(F, DF, X, M, X0, X1, X1, Cambio) :-
    valor_en(F, X, X0, F0),
    valor_en(DF, X, X0, D0),
    D0 =\= 0,
    X1 is X0 - M * F0 / D0,
    Cambio is abs(X1 - X0).
```

```prolog
?- newton((x - 1) ^ 2 * (x + 2) = 0, x, 2, 1.0e-12, Xs), length(Xs, N).
Xs = [1.5555555555555556, 1.2979066022544283, 1.1553901992137674, 1.079562210414361, 1.040288435171016, 1.0202768097867339, 1.010172323431422, 1.0050947410932753, 1.0025495280828274|...],
N = 41.

?- newton_multiple((x - 1) ^ 2 * (x + 2) = 0, x, 2, 2, 1.0e-12, Xs), length(Xs, N).
Xs = [1.1111111111111112, 1.0019493177387915, 1.0000006326899509, 1.0000000000000666, 1.0],
N = 5.
```

La raíz 1 es doble. `newton/5` reduce el error a la mitad por paso y
necesita 41; con m = 2, los errores son 1.1e-1, 1.9e-3, 6.3e-7, 6.7e-14:
la convergencia vuelve a ser cuadrática. El precio es conocer m: con m = 2
en la raíz simple de x² = 2, el paso es el doble del correcto, y desde 1 las
aproximaciones alternan entre 2 y 1 sin converger;
`newton_multiple(x ^ 2 = 2, x, 2, 1, 1.0e-12, Xs)` falla.

## 8

Jacobi separa los valores del barrido anterior de los nuevos: `Anteriores`
y `Viejos` son siempre valores del barrido anterior, y los nuevos se
acumulan aparte, en la lista de salida.

<!-- ejemplo: capitulo-46/soluciones.pl predicado: jacobi/5 paso_jacobi/6 barrido_jacobi/5 -->
```prolog
%!  jacobi(+Filas:list(list(number)), +Bs:list(number),
%!         +X0s:list(number), +Tol:float,
%!         -Aproximaciones:list(list(float))) is semidet.
%
%   Como gauss_seidel/5, pero cada barrido usa solo los valores del
%   barrido anterior.
jacobi(Filas, Bs, X0s, Tol, Aproximaciones) :-
    iterar(paso_jacobi(Filas, Bs), Tol, X0s, Aproximaciones).

%!  paso_jacobi(+Filas, +Bs, +X0s, -Xs, -Xs, -Cambio:float) is semidet.
%
%   Xs es el resultado de un barrido de Jacobi desde X0s; Cambio es el
%   mayor cambio de una componente.
paso_jacobi(Filas, Bs, X0s, Xs, Xs, Cambio) :-
    barrido_jacobi(Filas, Bs, [], X0s, Xs),
    foldl(mayor_diferencia, X0s, Xs, 0.0, Cambio).

%!  barrido_jacobi(+Filas, +Bs, +Anteriores:list(number),
%!                 +Viejos:list(number), -Xs:list(float)) is semidet.
%
%   Xs son los valores nuevos de las incógnitas de Filas. Anteriores y
%   Viejos son los valores del barrido anterior de las incógnitas que
%   preceden a la fila actual y de las que siguen, ella incluida. Falla si
%   un coeficiente de la diagonal es 0.
barrido_jacobi([], [], _, [], []).
barrido_jacobi([Fila|Filas], [B|Bs], Anteriores, [V|Viejos], [X|Xs]) :-
    length(Anteriores, K),
    length(Izquierda, K),
    append(Izquierda, [Diagonal|Derecha], Fila),
    Diagonal =\= 0,
    producto_escalar(Izquierda, Anteriores, P1),
    producto_escalar(Derecha, Viejos, P2),
    X is (B - P1 - P2) / Diagonal,
    append(Anteriores, [V], Anteriores1),
    barrido_jacobi(Filas, Bs, Anteriores1, Viejos, Xs).
```

```prolog
?- jacobi([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18], [0, 0, 0], 1.0e-12, As), length(As, N), last(As, Xs).
As = [[0.75, 3.4, 3.0], [0.65, 2.05, 3.3166666666666664], [1.0666666666666667, 1.9433333333333338, 3.125], [1.0454166666666667, 1.9366666666666668, 2.9683333333333337], [1.0079166666666668, 2.0035833333333333, 2.974305555555556], [0.9926805555555557, 2.008694444444444, 2.997958333333333], [0.9973159722222222, 2.0022805555555556|...], [1.0004020833333334|...], [...|...]|...],
N = 33,
Xs = [1.000000000000046, 1.9999999999998657, 3.00000000000022].
```

Jacobi necesita 33 barridos y Gauss–Seidel 19. El primer barrido ya lo
muestra: Jacobi calcula y = (17 − 0 − 0) / 5 = 3.4 con la x inicial, 0, y
Gauss–Seidel calcula y = 3.25 con la x = 0.75 que acaba de obtener. Usar
los valores nuevos en cuanto existen acelera la convergencia en los sistemas
de diagonal dominante; a cambio, en Jacobi las incógnitas de un barrido son
independientes entre sí y se podrían calcular en paralelo, con los hilos
del [capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md).

## 9

<!-- ejemplo: capitulo-46/soluciones.pl predicado: diagonal_dominante/1 diagonal_dominante/2 ordenar_filas/4 -->
```prolog
%!  diagonal_dominante(+Filas:list(list(number))) is semidet.
%
%   En cada fila de Filas, el valor absoluto del coeficiente de la diagonal
%   supera la suma de los valores absolutos de los demás.
diagonal_dominante(Filas) :-
    diagonal_dominante(Filas, 0).

%!  diagonal_dominante(+Filas:list(list(number)), +K:integer) is semidet.
%
%   Como diagonal_dominante/1, con la diagonal de la primera fila de Filas
%   en la posición K, contada desde 0.
diagonal_dominante([], _).
diagonal_dominante([Fila|Filas], K) :-
    length(Izquierda, K),
    append(Izquierda, [Diagonal|Derecha], Fila),
    foldl(sumar_absoluto, Izquierda, 0, S1),
    foldl(sumar_absoluto, Derecha, S1, S),
    abs(Diagonal) > S,
    K1 is K + 1,
    diagonal_dominante(Filas, K1).

%!  ordenar_filas(+Filas:list(list(number)), +Bs:list(number),
%!                -Filas1:list(list(number)), -Bs1:list(number))
%!      is semidet.
%
%   Filas1 y Bs1 son las mismas ecuaciones en el primer orden, entre las
%   permutaciones, que tiene la diagonal estrictamente dominante. Falla si
%   ningún orden la tiene.
ordenar_filas(Filas, Bs, Filas1, Bs1) :-
    pairs_keys_values(Pares, Filas, Bs),
    once(( permutation(Pares, Pares1),
           pairs_keys_values(Pares1, Filas2, _),
           diagonal_dominante(Filas2) )),
    pairs_keys_values(Pares1, Filas1, Bs1).
```

```prolog
?- diagonal_dominante([[1, 5, 2], [4, 1, -1], [2, -1, 6]]).
false.

?- ordenar_filas([[1, 5, 2], [4, 1, -1], [2, -1, 6]], [17, 3, 18], Fs, Bs).
Fs = [[4, 1, -1], [1, 5, 2], [2, -1, 6]],
Bs = [3, 17, 18].
```

Las filas se permutan junto con sus términos independientes, como pares,
para que cada ecuación conserve su término. `once/1` se queda con el primer
orden que cumple la condición. La búsqueda recorre hasta n! permutaciones,
lo que basta para sistemas chicos; para uno grande, se elige para cada
columna la fila cuyo coeficiente en ella domina, si existe.

## 10

<!-- ejemplo: capitulo-46/soluciones.pl predicado: residuo/4 residuo_fila/5 -->
```prolog
%!  residuo(+Filas:list(list(number)), +Bs:list(number),
%!          +Xs:list(number), -R:float) is det.
%
%   R es el mayor valor absoluto de las componentes de A·x - b.
residuo(Filas, Bs, Xs, R) :-
    foldl(residuo_fila(Xs), Filas, Bs, 0.0, R).

%!  residuo_fila(+Xs:list(number), +Fila:list(number), +B:number,
%!               +R0:float, -R:float) is det.
%
%   R es el mayor entre R0 y el valor absoluto de Fila·Xs - B.
residuo_fila(Xs, Fila, B, R0, R) :-
    producto_escalar(Fila, Xs, P),
    R is max(R0, abs(P - B)).
```

```prolog
?- gauss_seidel([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18], Xs), residuo([[4, 1, -1], [1, 5, 2], [2, -1, 6]], [3, 17, 18], Xs, R).
Xs = [0.9999999999999524, 1.999999999999958, 3.000000000000009],
R = 2.4158453015843406e-13.

?- gauss_seidel([[1, 0.95], [0.95, 1]], [1.95, 1.95], [0, 0], 1.0e-3, As), last(As, Xs), residuo([[1, 0.95], [0.95, 1]], [1.95, 1.95], Xs, R).
As = [[1.95, 0.09750000000000014], [1.8573749999999998, 0.18549375000000023], [1.7737809374999998, 0.2649081093750003], [1.6983372960937497, 0.33657956871093786], [1.630249409724609, 0.40126306076162144], [1.5688000922764596, 0.45963991233736334], [1.5133420832795048, 0.5123250208844705], [1.463291230159753|...], [...|...]|...],
Xs = [1.008478036692944, 0.9919458651417032],
R = 0.0008266085775621157.
```

En el segundo sistema, el último barrido cambió menos de 1.0e-3 y el
residuo es de 8.3e-4, pero el error es de 8.5e-3, diez veces mayor. Las dos
filas son casi iguales, y la diagonal apenas domina (1 > 0.95): cada barrido
corrige poco, de modo que un cambio pequeño indica que el método avanza
despacio, no que esté cerca. Y como las dos ecuaciones son casi la misma, un
punto que se aparta de la solución en la dirección en que las dos rectas
casi coinciden las satisface casi a las dos: el residuo también es
pequeño. Ninguna de las dos
medidas acota el error sin conocer algo más de la matriz.

## 11

`derivar/3` trata como constante todo átomo que no es la incógnita, de modo
que derivar respecto de x con y en la expresión da la derivada parcial. Las
cuatro se calculan una vez; cada paso las evalúa en el punto, resuelve el
sistema lineal del jacobiano por la regla de Cramer y avanza:

<!-- ejemplo: capitulo-46/soluciones.pl predicado: newton_sistema/4 paso_newton_sistema/8 valor_en_punto/3 -->
```prolog
%!  newton_sistema(+Ecuaciones:list, +Incognitas, +Inicio, -Raiz)
%!      is semidet.
%
%   Raiz, un par X-Y, es una solución de las dos Ecuaciones en las
%   Incognitas, un par de átomos, buscada desde Inicio, otro par, con una
%   tolerancia de 1.0e-12. Falla si el jacobiano se anula o si el método no
%   converge.
newton_sistema([E1, E2], X-Y, X0-Y0, Raiz) :-
    funcion(E1, F1),
    funcion(E2, F2),
    derivar(F1, X, A),
    derivar(F1, Y, B),
    derivar(F2, X, C),
    derivar(F2, Y, D),
    Punto is float(X0),
    Punto2 is float(Y0),
    iterar(paso_newton_sistema(X-Y, F1-F2, A-B, C-D), 1.0e-12,
           Punto-Punto2, Aproximaciones),
    last(Aproximaciones, Raiz).

%!  paso_newton_sistema(+Incognitas, +Fs, +Fila1, +Fila2, +P0, -P, -P,
%!                      -Cambio:float) is semidet.
%
%   P es el punto que sigue a P0 en el método de Newton para las dos
%   funciones Fs, F1-F2, cuyas derivadas parciales forman las filas del
%   jacobiano Fila1 y Fila2. El sistema lineal se resuelve por la regla de
%   Cramer. Falla si el determinante es 0.
paso_newton_sistema(X-Y, F1-F2, A-B, C-D, X0-Y0, X1-Y1, X1-Y1, Cambio) :-
    Valores = [X-X0, Y-Y0],
    maplist(valor_en_punto(Valores), [F1, F2, A, B, C, D],
            [V1, V2, VA, VB, VC, VD]),
    Det is VA * VD - VB * VC,
    Det =\= 0,
    DX is (VB * V2 - VD * V1) / Det,
    DY is (VC * V1 - VA * V2) / Det,
    X1 is X0 + DX,
    Y1 is Y0 + DY,
    Cambio is max(abs(DX), abs(DY)).

%!  valor_en_punto(+Valores:list(pair), +E, -V:float) is det.
%
%   V es el valor de E con las incógnitas de Valores.
valor_en_punto(Valores, E, V) :-
    evaluar(E, Valores, V0),
    V is float(V0).
```

```prolog
?- newton_sistema([x ^ 2 + y ^ 2 = 4, x * y = 1], x-y, 2-0.5, R).
R = 1.9318516525781364-0.5176380902050416.
```

El punto está sobre la circunferencia de radio 2 y sobre la hipérbola
x · y = 1, que se cortan en cuatro puntos; desde (2, 0.5), el método llega
al más cercano. Si el determinante del jacobiano se anula, como en un
sistema lineal con dos ecuaciones paralelas, el paso falla.

## 12

`convlist/3` del [capítulo 18](../capitulo-18-orden-superior/index.md) aplica el tramo a cada índice y
conserva solo los resultados de los tramos donde el predicado tiene éxito:

<!-- ejemplo: capitulo-46/soluciones.pl predicado: raices/5 raiz_en_tramo/6 -->
```prolog
%!  raices(+Ecuacion, +X:atom, +Intervalo, +N:integer,
%!         -Raices:list(float)) is det.
%
%   Raices son las que da la bisección en cada uno de los N intervalos
%   iguales en que se parte Intervalo, A-B, que tiene cambio de signo.
raices(Ecuacion, X, A-B, N, Raices) :-
    must_be(positive_integer, N),
    Ancho is (B - A) / N,
    N1 is N - 1,
    numlist(0, N1, Is),
    convlist(raiz_en_tramo(Ecuacion, X, A, Ancho), Is, Raices).

%!  raiz_en_tramo(+Ecuacion, +X:atom, +A:number, +Ancho:number,
%!                +I:integer, -R:float) is semidet.
%
%   R es la raíz que da la bisección en el tramo I, de A + I·Ancho a
%   A + (I + 1)·Ancho. Falla si el tramo no tiene cambio de signo. Una raíz
%   en el borde entre dos tramos pertenece al que termina en ella, y solo
%   el primer tramo toma la que está en su extremo izquierdo.
raiz_en_tramo(Ecuacion, X, A, Ancho, I, R) :-
    Desde is A + I * Ancho,
    Hasta is Desde + Ancho,
    funcion(Ecuacion, F),
    valor_en(F, X, Desde, FD),
    valor_en(F, X, Hasta, FH),
    (   FD * FH < 0
    ;   FH =:= 0
    ;   I =:= 0,
        FD =:= 0
    ),
    !,
    biseccion(Ecuacion, X, Desde-Hasta, R).
```

```prolog
?- raices(sin(x) = 0, x, 1-10, 9, Rs).
Rs = [3.141592653589214, 6.2831853071793375, 9.424777960769461].

?- raices(sin(x) = 0, x, 1-10, 2, Rs).
Rs = [3.141592653589953].
```

Con nueve tramos de ancho 1, cada raíz queda sola en uno. Con dos tramos,
[1, 5.5] contiene solo π, y [5.5, 10] contiene 2π y 3π: el seno es negativo
en los dos extremos, el tramo no tiene cambio de signo, y las dos raíces se
pierden. Un tramo con una cantidad par de raíces no cambia de signo; la
búsqueda solo es completa si los tramos son más chicos que la menor
distancia entre dos raíces, que en general no se conoce. Una raíz que cae
exactamente en el borde de dos tramos hace cero el producto de signos de
los dos; `raiz_en_tramo/6` la asigna solo al tramo que termina en ella (o
al primero, si es el extremo izquierdo de `A-B`), y así no aparece dos
veces:

```prolog
?- raices(x ^ 2 = 4, x, 0-4, 2, Rs).
Rs = [1.9999999999990905].
```

## 13

`operacion/2` evalúa los argumentos de cada operación con `valor_c/2`, que
solo conoce las cinco operaciones de Covington: tres cláusulas más en
`operacion/2` evaluarían `2 ^ 3`, pero no `2 * sqrt(4)`, porque el
argumento `sqrt(4)` volvería a pasar por `valor_c/2`. La ampliación necesita
su propio par de predicados, que se llaman entre sí:

<!-- ejemplo: capitulo-46/soluciones_covington.pl predicado: valor_ampliado/2 ampliado/2 operacion_ampliada/2 -->
```prolog
%!  valor_ampliado(+Expresion, -Valor:number) is det.
%
%   Como :=/2, con la potencia X ^ N de exponente entero, el opuesto -X y
%   sqrt/1 además de las operaciones de valor_c/2.
valor_ampliado(Expresion, Valor) :-
    must_be(ground, Expresion),
    (   ampliado(Expresion, Valor0)
    ->  Valor = Valor0
    ;   type_error(expresion_evaluable, Expresion)
    ).

%!  ampliado(+Expresion, -Valor:number) is semidet.
%
%   Valor es el valor de Expresion, un número o una operación de
%   operacion_ampliada/2. Falla si usa otra operación.
ampliado(E, V) :-
    (   number(E)
    ->  V = E
    ;   operacion_ampliada(E, V)
    ).

%!  operacion_ampliada(+Expresion, -Valor:number) is semidet.
%
%   Las cláusulas de operacion/2, con ampliado/2 para los argumentos, y
%   tres más.
operacion_ampliada(X + Y, V) :-
    ampliado(X, VX),
    ampliado(Y, VY),
    V is VX + VY.
operacion_ampliada(X - Y, V) :-
    ampliado(X, VX),
    ampliado(Y, VY),
    V is VX - VY.
operacion_ampliada(X * Y, V) :-
    ampliado(X, VX),
    ampliado(Y, VY),
    V is VX * VY.
operacion_ampliada(X / Y, V) :-
    ampliado(X, VX),
    ampliado(Y, VY),
    V is VX / VY.
operacion_ampliada(rec(X), V) :-
    ampliado(X, VX),
    V is 1 / VX.
operacion_ampliada(X ^ N, V) :-
    integer(N),
    ampliado(X, VX),
    V is VX ** N.
operacion_ampliada(-X, V) :-
    ampliado(X, VX),
    V is -VX.
operacion_ampliada(sqrt(X), V) :-
    ampliado(X, VX),
    V is sqrt(VX).
```

```prolog
?- valor_ampliado(sqrt(2 ^ 2 * 4) - -1, V).
V = 5.0.

?- valor_ampliado(2 ^ -1, V).
V = 0.5.
```

La potencia se evalúa con `**`, que con un exponente entero negativo da un
número de punto flotante; con `^`, `2 ^ -1` sería un error, porque `^`
entre enteros debe dar un entero. Un exponente que no es entero no
corresponde a ninguna cláusula, y la expresión produce el error de tipo.

## 14

La copia de la ecuación reemplaza la variable por un átomo nuevo, y
`resolver/5` trabaja sobre la copia; al final, la variable original se
liga con la raíz:

<!-- ejemplo: capitulo-46/soluciones_covington.pl predicado: resolver_variable/2 nueva_incognita/2 -->
```prolog
%!  resolver_variable(+Ecuacion, -Metodo:atom) is semidet.
%
%   Liga la variable libre de Ecuacion con una raíz que encuentra
%   resolver/5 desde 1, y Metodo con el método que la encontró. Falla si
%   Ecuacion no tiene variables o si ningún método encuentra una raíz.
resolver_variable(Ecuacion, Metodo) :-
    once(libre_en(Ecuacion, X)),
    nueva_incognita(Ecuacion, A),
    copy_term(X-Ecuacion, A-EcuacionA),
    resolver(EcuacionA, A, 1, Raiz, Metodo),
    X = Raiz.

%!  nueva_incognita(+Termino, -A:atom) is det.
%
%   A es el primero de los átomos x1, x2, ... que no aparece en Termino.
%   La comparación usa ==: sub_term(A, Termino) unificaría A con una
%   variable de Termino.
nueva_incognita(Termino, A) :-
    between(1, inf, N),
    atom_concat(x, N, A),
    \+ ( sub_term(S, Termino),
         S == A
       ),
    !.
```

`nueva_incognita/2` compara con `==`: `sub_term(A, Termino)` unificaría el
átomo con la propia incógnita, que es una variable de `Termino`, y ningún
átomo resultaría nuevo.

```prolog
?- resolver_variable(X * X = X * 3, M).
X = 0.0,
M = newton.

?- resolver_variable(X + 1 = 1 / X, M).
X = 0.6180339887498948,
M = secante.
```

La primera ecuación es la secante horizontal de Covington, que
`resolver_libre/1` no resuelve: Newton, desde 1, llega a la raíz 0. En la
segunda, `derivar/3` no conoce la división, Newton queda descartado, y la
secante da la misma raíz que `resolver_libre/1`. La variable da la
comodidad de la consulta, y la copia con un átomo da los métodos que
necesitan examinar la ecuación.
