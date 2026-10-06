# Más métodos de PRESS

Esta página contiene las secciones
[43.7](index.md#437-la-homogeneizacion-trigonometrica) a
[43.11](index.md#4311-desigualdades) del [capítulo 43](index.md): cinco
partes de PRESS que las versiones 1 a 5 no tienen. Cada una está en su
propio módulo de `ejemplos/capitulo-43/`, con sus pruebas, y carga los
módulos de las versiones anteriores; se ejecutan en una instalación local.
Las fuentes son la descripción de PRESS de Sterling, Bundy, Byrd, O'Keefe y
Silver (1982), el capítulo «An Equation Solver» de Sterling y Shapiro y los
artículos que esas dos fuentes citan: Bundy y Silver (1981) para la
homogeneización, Borning y Bundy (1981) para el emparejamiento, y Bundy
(1984) para los intervalos.

## 43.7 La homogeneización trigonométrica

El ejercicio 7 escribe la homogeneización de Bundy y Silver para las
potencias de una misma base. El tercer ejercicio del capítulo de Sterling y
Shapiro pide el caso trigonométrico: `cos(2 * x) - sin(x) = 0` es una
ecuación cuadrática en `sin(x)`, porque el coseno del ángulo doble vale
$1 - 2\sin^2 x$. En el vocabulario de Bundy y Silver, `cos(2 * x)` y
`sin(x)` son los **ofensores**, los términos que impiden que la ecuación
sea algebraica, y `sin(x)` es el **término reducido**: cada ofensor se
escribe como un polinomio en él. `reducida/5` es la tabla de esas
identidades, para los dos términos reducidos posibles:

<!-- ejemplo: capitulo-43/trigonometria.pl predicado: reducida/5 -->
```prolog
%!  reducida(+F, +X:atom, +U:atom, +T, -E) is semidet.
%
%   E es el término trigonométrico T escrito en función de U = F(X).
reducida(F, X, U, T, U) :-
    T =.. [F, Y],
    Y == X.
reducida(sin, X, U, cos(Y) ^ 2, 1 - U ^ 2) :-
    Y == X.
reducida(cos, X, U, sin(Y) ^ 2, 1 - U ^ 2) :-
    Y == X.
reducida(sin, X, U, cos(2 * Y), 1 - 2 * U ^ 2) :-
    Y == X.
reducida(cos, X, U, cos(2 * Y), 2 * U ^ 2 - 1) :-
    Y == X.
```

`en_funcion_de/5` recorre la ecuación y reemplaza cada ofensor por su
polinomio en la incógnita nueva `U`. Si después de eso la incógnita
original ya no aparece, la ecuación quedó homogeneizada;
`reducir_trigonometrica/5` prueba primero con el seno y después con el
coseno:

<!-- ejemplo: capitulo-43/trigonometria.pl predicado: reducir_trigonometrica/5 en_funcion_de/5 -->
```prolog
%!  reducir_trigonometrica(+Ecuacion, +X:atom, +U:atom, -F, -Ecuacion1)
%!      is semidet.
%
%   Ecuacion1 es la Ecuacion escrita en función de U = F(X), con F el
%   primero de sin y cos que lo permite, y X ya no aparece en ella. U no
%   debe aparecer en la Ecuacion.
reducir_trigonometrica(Ecuacion, X, U, F, Ecuacion1) :-
    libre(U, Ecuacion),
    member(F, [sin, cos]),
    en_funcion_de(F, X, U, Ecuacion, Ecuacion1),
    libre(X, Ecuacion1),
    !.

%!  en_funcion_de(+F, +X:atom, +U:atom, +E0, -E) is det.
%
%   E es E0 con cada término trigonométrico de X reescrito en función de
%   U = F(X) con las identidades de reducida/5. Lo que no tiene identidad
%   queda como está.
en_funcion_de(F, X, U, E0, E) :-
    (   reducida(F, X, U, E0, E1)
    ->  E = E1
    ;   compound(E0)
    ->  mapargs(en_funcion_de(F, X, U), E0, E)
    ;   E = E0
    ).
```

```prolog
?- reducir_trigonometrica(cos(2 * x) - sin(x) = 0, x, u, F, E).
F = sin,
E = (1-2*u^2-u=0).

?- reducir_trigonometrica(2 * sin(x) ^ 2 + 3 * cos(x) = 3, x, u, F, E).
F = cos,
E = (2*(1-u^2)+3*u=3).
```

En la segunda, el seno no sirve como término reducido, porque `cos(x)` no
se escribe como un polinomio en `sin(x)`; el coseno sí, con
$\sin^2 x = 1 - \cos^2 x$. `resolver_trigonometrica/3` resuelve el
polinomio en `u` con `resolver/3` de la versión 5, descarta los valores
fuera de $[-1, 1]$, que ningún seno ni coseno real alcanza, y aísla la
incógnita en `sin(x) = V`:

<!-- ejemplo: capitulo-43/trigonometria.pl predicado: resolver_trigonometrica/3 fuera_de_rango/1 -->
```prolog
%!  resolver_trigonometrica(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = E, una solución de la Ecuacion cerrada. Si la Ecuacion
%   se escribe como un polinomio en sin(X) o en cos(X), lo resuelve en ese
%   término; si no, usa resolver/3 de ecuaciones.pl.
resolver_trigonometrica(Ecuacion, X, Solucion) :-
    must_be(ground, Ecuacion),
    must_be(atom, X),
    (   reducir_trigonometrica(Ecuacion, X, u, F, Ecuacion1)
    ->  resolver(Ecuacion1, u, u = V),
        \+ fuera_de_rango(V),
        T =.. [F, X],
        resolver(T = V, X, Solucion)
    ;   resolver(Ecuacion, X, Solucion)
    ).

%!  fuera_de_rango(+V) is semidet.
%
%   La expresión cerrada V tiene un valor real de valor absoluto mayor
%   que 1: ningún seno ni coseno real lo alcanza.
fuera_de_rango(V) :-
    catch(W is V, error(evaluation_error(_), _), fail),
    abs(W) > 1.
```

```prolog
?- resolver_trigonometrica(cos(2 * x) - sin(x) = 0, x, S).
S = (x=asin(-1.0)) ;
S = (x=pi-asin(-1.0)) ;
S = (x=asin(0.5)) ;
S = (x=pi-asin(0.5)) ;
false.

?- resolver_trigonometrica(sin(x) ^ 2 = 4, x, S).
false.
```

Las dos primeras respuestas son $-\pi/2$ y $3\pi/2$, el mismo ángulo con
una vuelta de diferencia; las dos últimas, $\pi/6$ y $5\pi/6$. Sin la
homogeneización, ningún método del programa resuelve la primera ecuación:
la incógnita aparece dos veces, en un seno y en un coseno, y Newton no
tiene la derivada de `sin/1`.

## 43.8 El intercambio de funciones

PRESS llama **intercambio de funciones** (*function swapping*) a los
métodos que reemplazan una función por otra que el resto del programa
maneja mejor. El caso más común es la raíz cuadrada: en
`sqrt(x + 3) = x + 1` la incógnita aparece dentro y fuera de la raíz, y
ningún método la aísla. Elevar al cuadrado los dos lados cambia la raíz
por su argumento: `x + 3 = (x + 1) ^ 2` es un polinomio.
`intercambiar/3` aísla la primera raíz que contiene la incógnita como si
fuera una incógnita propia, `z`, y eleva al cuadrado:

<!-- ejemplo: capitulo-43/intercambio.pl predicado: intercambiar/3 -->
```prolog
%!  intercambiar(+Ecuacion, +X:atom, -Ecuacion1) is semidet.
%
%   Ecuacion1 resulta de aislar en la Ecuacion la primera raíz cuadrada
%   sqrt(U) que contiene X, como si fuera una incógnita, y de elevar al
%   cuadrado los dos lados: U = R2, con R2 el cuadrado de R desarrollado
%   por desarrollar/2. Se acepta solo si Ecuacion1 tiene menos raíces
%   cuadradas con X que la Ecuacion.
intercambiar(Ecuacion, X, U = R2) :-
    raices_con(Ecuacion, X, N0),
    N0 > 0,
    libre(z, Ecuacion),
    once(( sub_term(S, Ecuacion),
           S = sqrt(U),
           con(X, U) )),
    mapsubterms(reemplazo(S, z), Ecuacion, Ecuacion0),
    once(aislar(Ecuacion0, z, z = R)),
    desarrollar(R ^ 2, R2),
    raices_con(U = R2, X, N),
    N < N0.
```

La condición del final es la medida de la
[sección 43.3](index.md#433-version-2-reglas-de-reescritura-y-coleccion):
cada intercambio debe reducir la cantidad de raíces con la incógnita.
Cuando el otro lado tiene una segunda raíz, el cuadrado se desarrolla
para que esa raíz quede como un sumando que se pueda aislar en el paso
siguiente, y el cuadrado de una raíz se cambia por su argumento:

<!-- ejemplo: capitulo-43/intercambio.pl predicado: desarrollar/2 cuadrado/2 -->
```prolog
%!  desarrollar(+E0, -E) is det.
%
%   E es E0 con el cuadrado de una raíz cuadrada reemplazado por su
%   argumento, y el cuadrado de una suma o una resta con una raíz cuadrada
%   desarrollado: (A + sqrt(U)) ^ 2 pasa a ser A ^ 2 + 2 * A * sqrt(U) + U.
desarrollar(E0, E) :-
    (   cuadrado(E0, E1)
    ->  E = E1
    ;   compound(E0)
    ->  mapargs(desarrollar, E0, E)
    ;   E = E0
    ).

%!  cuadrado(+T, -E) is semidet.
%
%   E es el desarrollo del cuadrado T.
cuadrado(sqrt(U) ^ 2, U).
cuadrado((A + sqrt(U)) ^ 2, A ^ 2 + 2 * A * sqrt(U) + U).
cuadrado((A - sqrt(U)) ^ 2, A ^ 2 - 2 * A * sqrt(U) + U).
cuadrado((sqrt(U) + A) ^ 2, U + 2 * A * sqrt(U) + A ^ 2).
cuadrado((sqrt(U) - A) ^ 2, U - 2 * A * sqrt(U) + A ^ 2).
```

```prolog
?- intercambiar(sqrt(x + 3) = x + 1, x, E).
E = (x+3=(x+1)^2).

?- intercambiar(sqrt(5 * x - 25) - sqrt(x - 1) = 2, x, E).
E = (5*x-25=2^2+2*2*sqrt(x-1)+(x-1)).
```

Elevar al cuadrado no conserva las soluciones: `U = R ^ 2` también se
cumple cuando `sqrt(U) = -R`. `resolver_intercambio/3` intercambia solo si
`resolver/3` no da soluciones, y `valores_intercambio/3` comprueba cada
una en la ecuación original:

<!-- ejemplo: capitulo-43/intercambio.pl predicado: resolver_intercambio/3 valores_intercambio/3 -->
```prolog
%!  resolver_intercambio(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es una solución X = E de la Ecuacion, o de la ecuación que
%   resulta de intercambiar/3 si resolver/3 no da ninguna. Puede ser una
%   solución espuria: valores_intercambio/3 las descarta.
resolver_intercambio(Ecuacion, X, Solucion) :-
    must_be(ground, Ecuacion),
    must_be(atom, X),
    (   resolver(Ecuacion, X, Solucion)
    *-> true
    ;   intercambiar(Ecuacion, X, Ecuacion1),
        resolver_intercambio(Ecuacion1, X, Solucion)
    ).

%!  valores_intercambio(+Ecuacion, +X:atom, -Vs:list(number)) is det.
%
%   Vs son los valores de las soluciones de resolver_intercambio/3 que
%   cumplen la Ecuacion original, de menor a mayor y sin repetir. Sumar 0
%   lleva el -0.0 de una raíz nula a 0.0.
valores_intercambio(Ecuacion, X, Vs) :-
    findall(V,
            ( resolver_intercambio(Ecuacion, X, X = E),
              catch(V is E + 0, error(evaluation_error(_), _), fail),
              cumple(Ecuacion, X, V) ),
            Vs0),
    sort(Vs0, Vs).
```

```prolog
?- resolver_intercambio(sqrt(x + 3) = x + 1, x, S).
S = (x= -2.0) ;
S = (x=1.0).

?- valores_intercambio(sqrt(x + 3) = x + 1, x, Vs).
Vs = [1.0].

?- valores_intercambio(sqrt(5 * x - 25) - sqrt(x - 1) = 2, x, Vs).
Vs = [10.0].
```

La última es el ejemplo de la descripción de PRESS: dos intercambios
llevan a una cuadrática disfrazada, cuyas raíces son 5 y 10; la primera es
espuria, porque $\sqrt{0} - \sqrt{4} = -2$.

## 43.9 El emparejamiento conmutativo

La regla de colección `U * W + V * W ~> (U + V) * W` no se aplica a
`sin(x) * 2 + 3 * sin(x)`: la cabeza de `regla/3` unifica con el término
tal como está escrito, y en el primer producto el factor con la incógnita
es el izquierdo. El emparejador de PRESS, descrito por Borning y Bundy
(1981), conoce la conmutatividad y la asociatividad de la suma y el
producto. `variante/3` agrega la conmutatividad: da el término con los
operandos de algunas sumas y algunos productos intercambiados, en sus
niveles más altos:

<!-- ejemplo: capitulo-43/emparejamiento.pl predicado: variante/3 -->
```prolog
%!  variante(+T, +N:integer, -V) is multi.
%
%   V es T con los operandos de algunas sumas y productos intercambiados,
%   en los N niveles más altos de T. La primera respuesta es T mismo.
variante(T, N, V) :-
    (   N > 0,
        compound(T),
        compound_name_arguments(T, Op, [A, B])
    ->  N1 is N - 1,
        variante(A, N1, A1),
        variante(B, N1, B1),
        (   V =.. [Op, A1, B1]
        ;   conmutativa(Op),
            V =.. [Op, B1, A1]
        )
    ;   V = T
    ).
```

```prolog
?- variante(a * b + c, 2, V).
V = a*b+c ;
V = c+a*b ;
V = b*a+c ;
V = c+b*a.
```

Dos niveles alcanzan para las reglas de colección, cuyos patrones son
sumas de productos. `colectar_ac/3` es `colectar/3` con cada regla probada
sobre las variantes de cada subtérmino, con la misma medida, y
`resolver_ac/3` lo usa antes que los métodos de la versión 5:

<!-- ejemplo: capitulo-43/emparejamiento.pl predicado: regla_ac/3 colectar_ac/3 resolver_ac/3 resolver_ac_/3 -->
```prolog
%!  regla_ac(+X:atom, +S0, -S) is nondet.
%
%   S resulta de aplicar una regla de colección a una variante de S0 en
%   sus dos niveles más altos.
regla_ac(X, S0, S) :-
    variante(S0, 2, V),
    colectar:regla(X, V, S).

%!  colectar_ac(+Ecuacion0, +X:atom, -Ecuacion) is semidet.
%
%   Como colectar/3, pero cada regla se prueba también sobre las
%   variantes conmutativas de cada subtérmino.
colectar_ac(Ecuacion0, X, Ecuacion) :-
    apariciones(Ecuacion0, X, N0),
    once(( reescribir(regla_ac, X, Ecuacion0, Ecuacion),
           apariciones(Ecuacion, X, N),
           N < N0 )).

%!  resolver_ac(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = E, una solución de la Ecuacion cerrada: aísla si X
%   aparece una vez, colecta con colectar_ac/3 y vuelve a empezar, y si
%   ninguno se aplica usa resolver/3 de ecuaciones.pl.
resolver_ac(Ecuacion, X, Solucion) :-
    must_be(ground, Ecuacion),
    must_be(atom, X),
    resolver_ac_(Ecuacion, X, Solucion).

%!  resolver_ac_(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver_ac/3, sin verificar los argumentos.
resolver_ac_(Ecuacion, X, X = E) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, X = E0),
        simplificar(E0, E)
    ;   colectar_ac(Ecuacion, X, Ecuacion1)
    ->  resolver_ac_(Ecuacion1, X, X = E)
    ;   resolver(Ecuacion, X, X = E)
    ).
```

```prolog
?- colectar_ac(sin(x) * 2 + 3 * sin(x) = 1, x, E).
E = (sin(x)*(2+3)=1).

?- resolver_ac(sin(x) * 2 + 3 * sin(x) = 1, x, S).
S = (x=asin(1/5)) ;
S = (x=pi-asin(1/5)) ;
false.
```

El costo es la cantidad de variantes: dos niveles de una suma de productos
dan ocho, y cada una se prueba con cada regla. Borning y Bundy evitan esa
búsqueda con un emparejador que trata la suma y el producto como
colecciones de operandos sin orden; con él, además, la asociatividad sale
sin costo extra, y `x * y + z * (3 * x)` se colecta en `(y + 3 * z) * x`.

## 43.10 Intervalos

Las condiciones de las reglas de PRESS, como que un divisor no se anule,
no siempre se deciden evaluando: si el divisor contiene la incógnita, su
valor depende de la solución. PRESS las comprueba con un paquete de
**aritmética de intervalos** (Bundy, 1984): si la incógnita está entre
dos números, cada expresión que la contiene está en un intervalo que se
calcula a partir de los intervalos de sus argumentos. `intervalo/3` lo
hace por recursión sobre la expresión; un intervalo es `i(Min, Max)`:

<!-- ejemplo: capitulo-43/intervalos.pl predicado: intervalo/3 -->
```prolog
%!  intervalo(+E, +Asignacion:list(pair), -I) is semidet.
%
%   I = i(Min, Max) contiene todos los valores de la expresión cerrada E
%   cuando cada variable X de la Asignacion, una lista de pares
%   X-i(Lo, Hi), toma un valor entre Lo y Hi. Falla si E tiene una
%   operación sin regla, o una que puede no estar definida en ese
%   intervalo: un divisor que contiene 0, una raíz o un logaritmo de un
%   intervalo con valores negativos.
intervalo(E, _, i(E, E)) :-
    number(E),
    !.
intervalo(pi, _, i(V, V)) :-
    !,
    V is pi.
intervalo(X, Asignacion, i(Lo, Hi)) :-
    atom(X),
    !,
    memberchk(X-i(Lo0, Hi0), Asignacion),
    Lo is Lo0,
    Hi is Hi0.
intervalo(E, Asignacion, I) :-
    compound_name_arguments(E, Op0, Args),
    (   Op0 == (-),
        Args = [_]
    ->  Op = opuesto
    ;   Op = Op0
    ),
    maplist(intervalo_de(Asignacion), Args, Is),
    operar_intervalo(Op, Is, I).
```

`operar_intervalo/3` tiene una cláusula por operación. La suma suma los
extremos; la resta resta los extremos cruzados; el producto toma el
menor y el mayor de los cuatro productos de extremos; las funciones
crecientes, como `exp/1`, aplican la función a cada extremo; el seno y el
coseno, que no son monótonos, agregan 1 o -1 cuando el intervalo contiene
un máximo o un mínimo. Una operación que puede no estar definida en el
intervalo, como dividir por un intervalo que contiene 0, hace fallar el
cálculo:

<!-- ejemplo: capitulo-43/intervalos.pl fragmento: operar_intervalo(+, [i(A1, A2), i(B1, B2)], i(C1, C2)) :- .. max_list([P1, P2, P3, P4], C2). -->
```prolog
operar_intervalo(+, [i(A1, A2), i(B1, B2)], i(C1, C2)) :-
    C1 is A1 + B1,
    C2 is A2 + B2.
operar_intervalo(-, [i(A1, A2), i(B1, B2)], i(C1, C2)) :-
    C1 is A1 - B2,
    C2 is A2 - B1.
operar_intervalo(opuesto, [i(A1, A2)], i(C1, C2)) :-
    C1 is -A2,
    C2 is -A1.
operar_intervalo(*, [i(A1, A2), i(B1, B2)], i(C1, C2)) :-
    P1 is A1 * B1,
    P2 is A1 * B2,
    P3 is A2 * B1,
    P4 is A2 * B2,
    min_list([P1, P2, P3, P4], C1),
    max_list([P1, P2, P3, P4], C2).
```

```prolog
?- intervalo(x - cos(x), [x-i(pi / 3, pi / 2)], I).
I = i(0.5471975511965975, 1.5707963267948966).

?- distinto_de_cero(x - cos(x), [x-i(pi / 3, pi / 2)]).
true.

?- intervalo(1 / x, [x-i(-1, 1)], I).
false.
```

La primera es el ejemplo de la descripción de PRESS: con la incógnita
entre $\pi/3$ y $\pi/2$, `x - cos(x)` no se anula, y la regla que divide
por esa expresión se puede aplicar. El mismo cálculo prueba que una
ecuación no tiene raíces en un intervalo, y partiendo el intervalo en
mitades **encierra** las que tiene: `encerrar/5` descarta cada mitad cuyo
intervalo no contiene 0 y sigue partiendo las otras hasta un ancho dado:

<!-- ejemplo: capitulo-43/intervalos.pl predicado: distinto_de_cero/2 sin_raices/3 encerrar/5 partir/7 -->
```prolog
%!  distinto_de_cero(+E, +Asignacion:list(pair)) is semidet.
%
%   El intervalo de E con la Asignacion no contiene 0: E no se anula para
%   ningún valor de las variables en sus intervalos.
distinto_de_cero(E, Asignacion) :-
    intervalo(E, Asignacion, i(Lo, Hi)),
    ( Lo > 0 ; Hi < 0 ),
    !.

%!  sin_raices(+Ecuacion, +X:atom, +I) is semidet.
%
%   La Ecuacion Izq = Der no tiene soluciones con X en el intervalo I.
sin_raices(Izq = Der, X, I) :-
    distinto_de_cero(Izq - Der, [X-I]).

%!  encerrar(+Ecuacion, +X:atom, +I, +Ancho:number, -Is:list) is det.
%
%   Is son intervalos de ancho Ancho o menor, de menor a mayor, cuya unión
%   contiene todas las soluciones de la Ecuacion con X en I. Un intervalo
%   donde no se puede descartar una raíz se parte en dos mitades; los
%   contiguos que quedan se unen.
encerrar(Ecuacion, X, i(Lo0, Hi0), Ancho, Is) :-
    must_be(ground, Ecuacion),
    Lo is Lo0,
    Hi is Hi0,
    partir(Ecuacion, X, Ancho, Lo, Hi, Is0, []),
    unir(Is0, Is).

%!  partir(+Ecuacion, +X:atom, +Ancho, +Lo, +Hi, -Is, ?Is0) is det.
%
%   Is, con Is0 como resto, son los intervalos de ancho Ancho o menor
%   entre Lo y Hi donde la Ecuacion puede tener soluciones.
partir(Ecuacion, X, Ancho, Lo, Hi, Is, Is0) :-
    (   sin_raices(Ecuacion, X, i(Lo, Hi))
    ->  Is = Is0
    ;   Hi - Lo =< Ancho
    ->  Is = [i(Lo, Hi)|Is0]
    ;   M is (Lo + Hi) / 2,
        partir(Ecuacion, X, Ancho, Lo, M, Is, Is1),
        partir(Ecuacion, X, Ancho, M, Hi, Is1, Is0)
    ).
```

```prolog
?- encerrar(cos(x) = x, x, i(-10, 10), 0.001, Is).
Is = [i(0.738525390625, 0.7391357421875)].

?- encerrar(x ^ 2 + 1 = 0, x, i(-3, 3), 0.001, Is).
Is = [].
```

`cos(x) = x` es la ecuación que la versión 5 no resuelve porque
`derivar/3` no deriva `cos/1`: el intervalo no necesita derivadas. Una
lista vacía es una prueba de que no hay raíces en el intervalo; una lista
no vacía solo dice dónde pueden estar, porque el intervalo de una
expresión suele ser más ancho que el conjunto de sus valores. Los
extremos se calculan con números de punto flotante sin redondear hacia
afuera, como sí hace un paquete de intervalos profesional.

## 43.11 Desigualdades

PRESS resuelve también desigualdades. Con una sola aparición de la
incógnita, el aislamiento sirve igual que en las ecuaciones, con una
diferencia: multiplicar o dividir por un número negativo invierte el
sentido, y también lo invierte pasar el sustraendo al otro lado. Una
desigualdad se representa durante el aislamiento como `d(Rel, Izq, Der)`,
y cada axioma que multiplica o divide evalúa el signo del factor cerrado:

<!-- ejemplo: capitulo-43/desigualdades.pl predicado: axioma_d/3 segun_signo/3 -->
```prolog
%!  axioma_d(+N:integer, +D0, -D) is semidet.
%
%   D es equivalente a D0, con la operación de la raíz del lado izquierdo
%   pasada al lado derecho; la incógnita está en su argumento N. Es
%   multifile: otro archivo puede agregar axiomas.
axioma_d(1, d(R, -U, W), d(I, U, -W)) :-
    invertida(R, I).
axioma_d(1, d(R, U + V, W), d(R, U, W - V)).
axioma_d(2, d(R, U + V, W), d(R, V, W - U)).
axioma_d(1, d(R, U - V, W), d(R, U, W + V)).
axioma_d(2, d(R, U - V, W), d(I, V, U - W)) :-
    invertida(R, I).
axioma_d(1, d(R, U * V, W), d(R1, U, W / V)) :-
    segun_signo(V, R, R1).
axioma_d(2, d(R, U * V, W), d(R1, V, W / U)) :-
    segun_signo(U, R, R1).
axioma_d(1, d(R, U / V, W), d(R1, U, W * V)) :-
    segun_signo(V, R, R1).
axioma_d(1, d(R, exp(U), W), d(R, U, log(W))) :-
    W1 is W,
    W1 > 0.

%!  segun_signo(+E, +R, -R1) is semidet.
%
%   R1 es R si la expresión cerrada E es positiva, y R invertida si es
%   negativa. Falla si E vale 0.
segun_signo(E, R, R1) :-
    V is E,
    (   V > 0
    ->  R1 = R
    ;   V < 0
    ->  invertida(R, R1)
    ).
```

`resolver_desigualdad/3` es el aislamiento de la
[sección 43.2](index.md#432-version-1-el-aislamiento) con esos axiomas: la
posición de la incógnita, la orientación, que también invierte la
relación, y un axioma por nivel:

<!-- ejemplo: capitulo-43/desigualdades.pl predicado: resolver_desigualdad/3 orientar/3 -->
```prolog
%!  resolver_desigualdad(+Desigualdad, +X:atom, -Solucion) is semidet.
%
%   Solucion es X Rel E, con E sin X, equivalente a la Desigualdad cerrada
%   en la que X aparece una sola vez. Falla si X no aparece exactamente una
%   vez, o si un axioma no se aplica: un factor que vale 0, o un
%   logaritmo de un valor que no es positivo. Cada operación tiene un solo
%   axioma por argumento, y once/1 descarta las alternativas que la
%   indexación deja abiertas.
resolver_desigualdad(Desigualdad, X, Solucion) :-
    must_be(ground, Desigualdad),
    must_be(atom, X),
    Desigualdad =.. [Rel, Izq, Der],
    relacion(Rel),
    apariciones(Desigualdad, X, 1),
    once(posicion(X, Desigualdad, [Lado|Camino])),
    orientar(Lado, d(Rel, Izq, Der), D),
    once(aislar_desigualdad(Camino, D, d(Rel1, X, E0))),
    simplificar(E0, E),
    Solucion =.. [Rel1, X, E].

%!  orientar(+Lado:integer, +D0, -D) is det.
%
%   D es la desigualdad D0, d(Rel, Izq, Der), con el lado número Lado a
%   la izquierda.
orientar(1, D, D).
orientar(2, d(Rel, Izq, Der), d(Inv, Der, Izq)) :-
    invertida(Rel, Inv).
```

```prolog
?- resolver_desigualdad(3 - 2 * x < 7, x, S).
S = (x> -4/2).

?- resolver_desigualdad(10 < x / -2, x, S).
S = (x< -20).

?- resolver_desigualdad(exp(x + 1) >= 5, x, S).
S = (x>=log(5)-1).
```

La primera pasa por `2 * x > 3 - 7`: el sustraendo cambia de lado e
invierte la relación, y dividir por 2, que es positivo, la conserva. La
segunda divide por -2 e invierte otra vez. La tercera usa que la
exponencial es creciente, y exige que el otro lado sea positivo: con
`exp(x) > -1`, que se cumple para todo `x`, el axioma no se aplica y
`resolver_desigualdad/3` falla. Una solución que fuera «todo número
real», o un intervalo con dos extremos, como la de `x * x < 4`, necesita
otra representación de la respuesta.
