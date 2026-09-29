# Soluciones del capítulo 47 — Proyecto: aritmética racional y matrices

El código de esta página está en `ejemplos/capitulo-47/`, en tres archivos
que cargan los del capítulo: `soluciones_racional.pl` para los ejercicios
2 a 5, que carga `racional.pl` y `nativos.pl`; `soluciones_matriz.pl` para
los ejercicios 6 a 10, que carga `inversa.pl` y `matriz_simbolica.pl`; y
`soluciones_rutas.pl` para los ejercicios 11 y 12, que carga `rutas.pl`.
Cada uno tiene sus pruebas. Como cargan otros archivos, se ejecutan en una
instalación local y no en SWISH. El ejercicio 1 se resuelve con los
archivos del capítulo, que `soluciones_racional.pl` carga:

<!-- ejemplo: capitulo-47/soluciones_racional.pl fragmento: :- ensure_loaded(racional). .. :- ensure_loaded(nativos). -->
```prolog
:- ensure_loaded(racional).
:- ensure_loaded(nativos).
```

## 1

```prolog
?- q_valor(2/4, Q).
Q = fr(1, 2).

?- q_valor(fr(2, 4), fr(1, 2)).
true.

?- X is 2 rdiv 4 + 1r2.
X = 1.

?- X is 1r3 * 3.0.
X = 1.0.
```

`q_valor/2` evalúa `2/4` como el cociente de dos enteros y devuelve la
forma normal; la segunda consulta es verdadera porque `q_valor/2` normaliza
también un `fr/2` que no está en forma normal, y la forma normal de
`fr(2, 4)` unifica con `fr(1, 2)`. En la tercera, `2 rdiv 4` es `1r2`, y la
suma de dos medios es el entero 1, no `1r1`: un racional con denominador 1
es un entero. En la cuarta, el número de punto flotante contagia el
resultado, que es `1.0` aunque el producto sea exacto. Las dos últimas
producen errores, uno de evaluación y otro de tipo:

```text
?- fraccion(3, 0, Q).
ERROR: Arithmetic: evaluation error: `zero_divisor'

?- de_nativo(0.25, F).
ERROR: Type error: `rational' expected, found `0.25' (a float)
```

`fraccion/3` informa la división por 0 con el mismo error que `is/2`, y
`de_nativo/2` rechaza un número de punto flotante aunque 0.25 tenga una
representación binaria exacta: la conversión es `rational/3`, que exige un
racional.

## 2

<!-- ejemplo: capitulo-47/soluciones_racional.pl predicado: q_potencia/3 -->
```prolog
%!  q_potencia(+Q, +E:integer, -P) is det.
%
%   P es el racional en forma normal Q elevado al entero E. Produce un
%   error de evaluación si Q es 0 y E es negativo.
q_potencia(fr(N, D), E, P) :-
    must_be(integer, E),
    (   E >= 0
    ->  A is N ^ E,
        B is D ^ E
    ;   K is -E,
        A is D ^ K,
        B is N ^ K
    ),
    fraccion(A, B, P).
```

Con exponente negativo, la potencia es la del inverso: se intercambian el
numerador y el denominador antes de elevar. Como N y D no tienen divisores
comunes, sus potencias tampoco los tienen, y `fraccion/3` solo corrige el
signo del denominador. Con Q igual a 0 y un exponente negativo,
`fraccion/3` produce el error de la división por 0.

```prolog
?- q_potencia(fr(2, 3), -2, P).
P = fr(9, 4).

?- X is 2r3 ^ -2.
X = 9r4.
```

Sobre los racionales de SWI-Prolog, `^` acepta el exponente negativo y da
el mismo resultado, sin la bandera `prefer_rationals`.

## 3

<!-- ejemplo: capitulo-47/soluciones_racional.pl predicado: dec_suma/3 dec_producto/3 dec_valor/2 -->
```prolog
%!  dec_suma(+X, +Y, -Z) is det.
%
%   Z es la suma de los decimales dec(M, E), que valen M * 10^E, X e Y.
%   El exponente de Z es el menor de los dos.
dec_suma(dec(M1, E1), dec(M2, E2), dec(M, E)) :-
    E is min(E1, E2),
    M is M1 * 10 ^ (E1 - E) + M2 * 10 ^ (E2 - E).

%!  dec_producto(+X, +Y, -Z) is det.
%
%   Z es el producto de los decimales X e Y.
dec_producto(dec(M1, E1), dec(M2, E2), dec(M, E)) :-
    M is M1 * M2,
    E is E1 + E2.

%!  dec_valor(+X, -Q:rational) is det.
%
%   Q es el racional de SWI-Prolog que vale el decimal X.
dec_valor(dec(M, E), Q) :-
    (   E >= 0
    ->  Q is M * 10 ^ E
    ;   K is -E,
        Q is M rdiv 10 ^ K
    ).
```

Para sumar, los dos números se llevan al menor exponente, multiplicando la
mantisa del otro por la potencia de 10 que falta; el producto multiplica
las mantisas y suma los exponentes. Las dos operaciones son exactas y
cerradas: el resultado es otro decimal.

```prolog
?- dec_suma(dec(125, -2), dec(3, 1), X).
X = dec(3125, -2).

?- dec_valor(dec(125, -2), Q).
Q = 5r4.
```

El cociente no es cerrado: 1 / 3 no tiene una escritura decimal finita,
porque ninguna potencia de 10 es múltiplo de 3. Un racional en forma normal
es un decimal finito si y solo si su denominador no tiene factores primos
distintos de 2 y de 5. `dec_de_racional/2` lo verifica y convierte, y falla
en los demás casos; un paquete de decimales solo puede dividir truncando
el resultado a una cantidad de cifras, con lo que pierde la exactitud.

<!-- ejemplo: capitulo-47/soluciones_racional.pl predicado: dec_de_racional/2 -->
```prolog
%!  dec_de_racional(+Q:rational, -X) is semidet.
%
%   X es el decimal que vale el racional Q. Falla si Q no tiene una
%   escritura decimal finita: si su denominador tiene un factor primo
%   distinto de 2 y de 5.
dec_de_racional(Q, dec(M, E)) :-
    rational(Q, N, D),
    sin_factor(D, 2, D1, A),
    sin_factor(D1, 5, 1, B),
    K is max(A, B),
    M is N * 10 ^ K // D,
    E is -K.
```

```prolog
?- dec_de_racional(3r8, X).
X = dec(375, -3).

?- dec_de_racional(1r3, X).
false.
```

## 4

<!-- ejemplo: capitulo-47/soluciones_racional.pl predicado: fraccion_continua/2 valor_fraccion_continua/2 -->
```prolog
%!  fraccion_continua(+Q:rational, -Cocientes:list(integer)) is det.
%
%   Cocientes son los cocientes de la fracción continua del racional
%   positivo Q: Q = A0 + 1 / (A1 + 1 / (A2 + ...)).
fraccion_continua(Q, [A|As]) :-
    must_be(rational, Q),
    A is floor(Q),
    R is Q - A,
    (   R =:= 0
    ->  As = []
    ;   Q1 is 1 rdiv R,
        fraccion_continua(Q1, As)
    ).

%!  valor_fraccion_continua(+Cocientes:list(integer), -Q:rational) is det.
%
%   Q es el racional cuya fracción continua tiene los Cocientes, que no son
%   una lista vacía.
valor_fraccion_continua([A], A) :-
    !.
valor_fraccion_continua([A|As], Q) :-
    valor_fraccion_continua(As, Q1),
    Q is A + 1 rdiv Q1.
```

Cada paso separa la parte entera con `floor` y continúa con el inverso del
resto, que es un racional mayor que 1; el resto es exacto, y la sucesión
termina porque los denominadores decrecen, como en el algoritmo de
Euclides. `valor_fraccion_continua/2` hace el camino inverso de derecha a
izquierda.

```prolog
?- fraccion_continua(415r93, Cs).
Cs = [4, 2, 6, 7].

?- valor_fraccion_continua([4, 2, 6, 7], Q).
Q = 415r93.
```

## 5

<!-- ejemplo: capitulo-47/soluciones_racional.pl predicado: mejor_aproximacion/3 -->
```prolog
%!  mejor_aproximacion(+X:number, +MaxD:integer, -Q:rational) is det.
%
%   Q es el racional con denominador entre 1 y MaxD más cercano a X; entre
%   dos igual de cercanos, el de menor denominador.
mejor_aproximacion(X, MaxD, Q) :-
    must_be(positive_integer, MaxD),
    Y is float(X),
    findall(Error-D-N,
            ( between(1, MaxD, D),
              N is round(Y * D),
              Error is abs(Y - N / D) ),
            Candidatos),
    min_member(_-D-N, Candidatos),
    Q is N rdiv D.
```

Para cada denominador D, el mejor numerador es el entero más cercano a
X · D. Los candidatos se comparan con `min_member/2` sobre términos
`Error-D-N`: el orden estándar compara primero el error y, si empata, el
denominador. `aggregate_all(min(…))` no sirve aquí, porque exige que lo que
se minimiza sea un número.

```prolog
?- mejor_aproximacion(pi, 1000, Q).
Q = 355r113.

?- X is rationalize(pi).
X = 245850922r78256779.
```

355/113 difiere de π en menos de 3 · 10⁻⁷. `rationalize/1` resuelve otro
problema: da el racional más simple cuyo valor, convertido a punto
flotante, es exactamente el número dado, y para eso necesita un
denominador de ocho cifras.

## 6

<!-- ejemplo: capitulo-47/soluciones_matriz.pl predicado: determinante/2 det/2 reducir_fila/3 -->
```prolog
%!  determinante(+A:list(list), -D:number) is det.
%
%   D es el determinante de la matriz cuadrada A, exacto si sus elementos
%   son enteros o racionales. Produce un error de dominio si A no es
%   cuadrada.
determinante(A, D) :-
    dimensiones(A, N, C),
    (   N =:= C
    ->  true
    ;   domain_error(matriz_cuadrada, A)
    ),
    det(A, D).

%!  det(+A:list(list), -D:number) is det.
%
%   D es el determinante de la matriz cuadrada A. Elige como pivote la
%   primera fila con el primer elemento distinto de 0; sacarla de la
%   posición I y ponerla primera son I intercambios de filas vecinas, y
%   cada uno cambia el signo. Sin pivote, la matriz es singular y D es 0.
det([], 1).
det([F|Fs], D) :-
    (   nth0(I, [F|Fs], P, Resto),
        P = [X|_],
        X =\= 0
    ->  maplist(reducir_fila(P), Resto, Menor),
        det(Menor, D0),
        D is (-1) ^ I * X * D0
    ;   D = 0
    ).

%!  reducir_fila(+Pivote:list, +Fila:list, -Reducida:list) is det.
%
%   Reducida es Fila menos el múltiplo de Pivote que anula su primer
%   elemento, sin ese primer elemento.
reducir_fila([X|Xs], [Y|Ys], Reducida) :-
    dividir_por(X, Y, F),
    maplist(restar_multiplo(F), Xs, Ys, Reducida).
```

La eliminación es la de `inversa.pl` sin la mitad derecha y sin normalizar
el pivote: el determinante es el pivote por el determinante de la matriz
que queda al eliminar la primera columna. Sacar la fila del pivote de la
posición I y ponerla primera equivale a I intercambios de filas vecinas,
y cada uno cambia el signo. `reducir_fila/3` usa `dividir_por/3` y
`restar_multiplo/4` de `inversa.pl`. Sin pivote, la matriz es singular y el
determinante es 0: aquí no hay nada que falle, a diferencia de `inversa/2`.

```prolog
?- hilbert(4, racional, H), determinante(H, D).
H = [[1, 1r2, 1r3, 1r4], [1r2, 1r3, 1r4, 1r5], [1r3, 1r4, 1r5, 1r6], [1r4, 1r5, 1r6, 1r7]],
D = 1r6048000.
```

## 7

<!-- ejemplo: capitulo-47/soluciones_matriz.pl predicado: resolver/3 -->
```prolog
%!  resolver(+A:list(list), +B:list(number), -X:list(number)) is semidet.
%
%   X es la solución del sistema lineal A * X = B, con A cuadrada. Falla si
%   A es singular.
resolver(A, B, X) :-
    maplist([Fila, Bi, Ampliada]>>append(Fila, [Bi], Ampliada),
            A, B, Filas),
    gauss_jordan(Filas, [], Reducida),
    maplist(last, Reducida, X).
```

La matriz ampliada tiene una sola columna más, y `gauss_jordan/3` de
`inversa.pl` la reduce sin cambios: al terminar, la última columna es la
solución. Si A es singular, `gauss_jordan/3` falla, y `resolver/3` también.

```prolog
?- resolver([[2, 1], [1, 3]], [3, 5], X).
X = [4r5, 7r5].

?- resolver([[1, 2], [2, 4]], [1, 2], X).
false.
```

El segundo sistema tiene infinitas soluciones, y un sistema con la misma
matriz y `[1, 3]` a la derecha no tiene ninguna: la eliminación no los
distingue, porque se detiene al no encontrar un pivote. Distinguirlos
exige seguir reduciendo las demás columnas y examinar las filas que quedan
en 0.

## 8

<!-- ejemplo: capitulo-47/soluciones_matriz.pl predicado: suma/3 por_escalar/3 traza/2 -->
```prolog
%!  suma(+A:list(list), +B:list(list), -C:list(list)) is det.
%
%   C es la suma, elemento por elemento, de las matrices A y B, de las
%   mismas dimensiones.
suma(A, B, C) :-
    maplist(maplist([X, Y, Z]>>(Z is X + Y)), A, B, C).

%!  por_escalar(+K:number, +A:list(list), -B:list(list)) is det.
%
%   B es la matriz A con cada elemento multiplicado por K.
por_escalar(K, A, B) :-
    maplist(maplist([X, Y]>>(Y is K * X)), A, B).

%!  traza(+A:list(list), -T:number) is det.
%
%   T es la suma de los elementos de la diagonal de la matriz cuadrada A.
traza(A, T) :-
    findall(X, ( nth1(I, A, Fila), nth1(I, Fila, X) ), Diagonal),
    sum_list(Diagonal, T).
```

`maplist(maplist(…))` recorre las filas y, dentro de cada una, los
elementos; la lambda de `library(yall)` hace la operación. La traza recoge
el elemento I de la fila I con `nth1/3`.

```prolog
?- traza([[1, 2], [3, 4]], T).
T = 5.
```

## 9

<!-- ejemplo: capitulo-47/soluciones_matriz.pl predicado: potencia/4 fibonacci/2 -->
```prolog
%!  potencia(+M:list(list), +K:integer, -P:list(list),
%!           -Productos:integer) is det.
%
%   P es M elevada a K, y el cálculo hace Productos productos de matrices.
potencia(M, 0, I, 0) :-
    !,
    length(M, N),
    identidad(N, I).
potencia(M, 1, M, 0) :-
    !.
potencia(M, K, P, Productos) :-
    K2 is K // 2,
    potencia(M, K2, Q, Productos0),
    producto(Q, Q, Q2),
    (   K mod 2 =:= 0
    ->  P = Q2,
        Productos is Productos0 + 1
    ;   producto(M, Q2, P),
        Productos is Productos0 + 2
    ).

%!  fibonacci(+N:integer, -F:integer) is det.
%
%   F es el número de Fibonacci N: el elemento de la primera fila y la
%   segunda columna de [[1, 1], [1, 0]] elevada a N.
fibonacci(N, F) :-
    potencia([[1, 1], [1, 0]], N, [[_, F]|_]).
```

Para K par, M^K es el cuadrado de M^(K/2); para K impar, es M por ese
cuadrado. `potencia/4` cuenta los productos.

```prolog
?- potencia([[1, 1], [1, 0]], 10, P).
P = [[89, 55], [55, 34]].

?- potencia([[1, 1], [1, 0]], 300, _, N).
N = 11.

?- fibonacci(300, F).
F = 222232244629420445529739893461909967206666939096499764990979600.
```

Para 300, las divisiones por 2 son 300, 150, 75, 37, 18, 9, 4 y 2, y cada
una cuesta un cuadrado: 8 productos. Las impares, 75, 37 y 9, cuestan un
producto más cada una: 11 en total, frente a los 299 de multiplicar 300
veces. El número de Fibonacci 300 tiene 63 cifras, y los enteros de
SWI-Prolog no tienen límite de tamaño.

## 10

<!-- ejemplo: capitulo-47/soluciones_matriz.pl predicado: simplificar_signos/2 signos/2 regla_signo/2 producto_con_signos/3 -->
```prolog
%!  simplificar_signos(+E0, -E) is det.
%
%   E es la expresión cerrada E0 sin el menos unario en los productos, ni
%   una suma o una resta de un opuesto. Produce un error de instanciación
%   si E0 tiene variables.
simplificar_signos(E0, E) :-
    must_be(ground, E0),
    signos(E0, E).

%!  signos(+E0, -E) is det.
%
%   E es E0 con las reglas de regla_signo/2 aplicadas de abajo hacia
%   arriba, como simp/2 del capítulo 32.
signos(E0, E) :-
    (   compound(E0)
    ->  mapargs(signos, E0, E1)
    ;   E1 = E0
    ),
    (   regla_signo(E1, E2)
    ->  signos(E2, E)
    ;   E = E1
    ).

%!  regla_signo(+E0, -E) is nondet.
%
%   E es el resultado de reescribir la raíz de E0 con una regla de signos:
%   una respuesta por cada regla que se aplica. signos/2 usa la primera.
regla_signo(-(-A), A).
regla_signo(-A * -B, A * B).
regla_signo(A * -B, -(A * B)).
regla_signo(-A * B, -(A * B)).
regla_signo(A + -B, A - B).
regla_signo(A - -B, A + B).

%!  producto_con_signos(+A:list(list), +B:list(list), -C:list(list)) is det.
%
%   C es el producto simbólico de A y B, simplificado y sin el menos
%   unario en los productos.
producto_con_signos(A, B, C) :-
    producto_simbolico(A, B, C0),
    maplist(maplist(simplificar_signos), C0, C).
```

La pasada tiene la forma del simplificador del
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md#327-un-simplificador-de-expresiones): simplifica los argumentos de cada nodo con
`mapargs/3`, aplica una regla a la raíz y, si una se aplicó, vuelve a
simplificar el resultado. Las reglas están en su propio predicado, y el
archivo del [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md) no cambia. El orden de las reglas importa:
`-A * -B` también unifica con `A * -B`, y la primera cláusula que se aplica
es la que elimina los dos signos.

```prolog
?- rotacion(z, t, A), rotacion(z, f, B), producto_con_signos(A, B, P).
A = [[cos(t), sin(t), 0, 0], [-sin(t), cos(t), 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]],
B = [[cos(f), sin(f), 0, 0], [-sin(f), cos(f), 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]],
P = [[cos(t)*cos(f)-sin(t)*sin(f), cos(t)*sin(f)+sin(t)*cos(f), 0, 0], [- (sin(t)*cos(f))-cos(t)*sin(f), - (sin(t)*sin(f))+cos(t)*cos(f), 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]].
```

La primera fila es la de la rotación en t + f: `cos(t)*cos(f)-sin(t)*sin(f)`
es cos(t + f), y `cos(t)*sin(f)+sin(t)*cos(f)` es sin(t + f). Reconocer
esas identidades trigonométricas es un paso más de reescritura, con reglas
sobre sumas de productos.

## 11

<!-- ejemplo: capitulo-47/soluciones_rutas.pl fragmento: % salida(A, B, Hora, Minutos) .. salida(puerto_quieto, ribera_honda, 10:45, 20). -->
```prolog
% salida(A, B, Hora, Minutos): una balsa sale de A hacia B a la Hora y
% llega Minutos después.
salida(puerto_quieto, ribera_honda, 8:45, 20).
salida(puerto_quieto, ribera_honda, 9:45, 20).
salida(puerto_quieto, ribera_honda, 10:45, 20).
```

El costo de tomar la balsa depende de la hora de llegada al muelle, y el
sucesor necesita el costo acumulado. `costo_uniforme_t/4` es
`costo_uniforme/4` con un argumento más en la llamada al sucesor; la
búsqueda original es el caso particular en que el sucesor lo ignora, y
`sin_costo/5` adapta un sucesor de la versión 6:

<!-- ejemplo: capitulo-47/soluciones_rutas.pl predicado: costo_uniforme_t/5 sin_costo/5 sucesor_con_balsa/5 -->
```prolog
%!  costo_uniforme_t(+Frontera, +Cerrados:list, :Meta, :Sucesor,
%!                   -Invertido:list) is semidet.
%
%   Invertido es el camino de menor costo hasta una meta, del último
%   estado al primero, como en costo_uniforme/5.
costo_uniforme_t(Frontera0, Cerrados, Meta, Sucesor, Invertido) :-
    get_from_heap(Frontera0, C, [E-C|Resto], Frontera1),
    (   call(Meta, E)
    ->  Invertido = [E-C|Resto]
    ;   ord_memberchk(E, Cerrados)
    ->  costo_uniforme_t(Frontera1, Cerrados, Meta, Sucesor, Invertido)
    ;   findall(C1-[E1-C1, E-C|Resto],
                ( call(Sucesor, E, C, E1, Paso),
                  C1 is C + Paso ),
                Hijos),
        foldl(agregar_a_frontera, Hijos, Frontera1, Frontera),
        ord_add_element(Cerrados, E, Cerrados1),
        costo_uniforme_t(Frontera, Cerrados1, Meta, Sucesor, Invertido)
    ).

%!  sin_costo(:Sucesor, +E, +C, -E1, -Paso) is nondet.
%
%   Adapta un sucesor de costo_uniforme/4, que no usa el costo C:
%   costo_uniforme/4 es costo_uniforme_t/4 con sin_costo(Sucesor).
sin_costo(Sucesor, E, _, E1, Paso) :-
    call(Sucesor, E, E1, Paso).

%!  sucesor_con_balsa(+Salida:integer, +A:atom, +C:number, -B:atom,
%!                    -Paso:number) is nondet.
%
%   Desde A, a la que se llega C minutos después del minuto Salida del
%   día, se pasa a B en Paso minutos: por un tramo de ruta, o esperando
%   una balsa que sale después de la llegada y viajando en ella.
sucesor_con_balsa(_, A, _, B, Paso) :-
    minutos_tramo(A, B, Paso).
sucesor_con_balsa(Salida, A, C, B, Paso) :-
    salida(A, B, Hora, Viaje),
    minutos_del_dia(Hora, Parte),
    Llegada is Salida + C,
    Parte >= Llegada,
    Paso is Parte - Llegada + Viaje.
```

La búsqueda sigue dando el camino más rápido porque la red cumple una
condición: llegar más tarde a una ciudad nunca permite llegar antes a la
siguiente, ya que la espera de la balsa como mucho compensa el atraso. Sin
esa condición, un estado cerrado podría tener un camino mejor que llega
más tarde. Saliendo de Pradera Alta a las 8:00, se llega a Puerto Quieto
a las 8:33 y la balsa de las 8:45 llega a Ribera Honda antes que la ruta;
saliendo a las 8:20, la balsa siguiente sale a las 9:45, y conviene la
ruta:

```prolog
?- horario_con_balsa(pradera_alta, ribera_honda, 8:00, H).
H = ['8:00'-pradera_alta, '8:33'-puerto_quieto, '9:05'-ribera_honda].

?- horario_con_balsa(pradera_alta, ribera_honda, 8:20, H).
H = ['8:20'-pradera_alta, '8:53'-puerto_quieto, '9:29'-piedra_mora, '9:50'-ribera_honda].
```

## 12

<!-- ejemplo: capitulo-47/soluciones_rutas.pl predicado: minutos_evitando/4 ruta_evitando/5 -->
```prolog
%!  minutos_evitando(+Calzadas:list(atom), ?A, ?B, -Minutos) is nondet.
%
%   Ir de A a B por un tramo directo lleva Minutos, y el tramo no tiene
%   ninguna de las Calzadas.
minutos_evitando(Calzadas, A, B, Minutos) :-
    conecta(A, B, _, Calzada, _, _),
    \+ memberchk(Calzada, Calzadas),
    once(minutos_tramo(A, B, Minutos)).

%!  ruta_evitando(+Origen:atom, +Destino:atom, +Calzadas:list(atom),
%!                -Minutos:rational, -Ciudades:list(atom)) is semidet.
%
%   Ciudades es el recorrido más rápido de Origen a Destino que no usa
%   tramos con ninguna de las Calzadas, y lleva Minutos. Falla si no hay
%   ninguno.
ruta_evitando(Origen, Destino, Calzadas, Minutos, Ciudades) :-
    must_be(atom, Origen),
    must_be(atom, Destino),
    must_be(list(atom), Calzadas),
    costo_uniforme(Origen, es(Destino), minutos_evitando(Calzadas),
                   Camino),
    last(Camino, Destino-Minutos),
    pairs_keys(Camino, Ciudades).
```

El problema cambia solo en los sucesores, y `ruta_evitando/5` pasa a
`costo_uniforme/4` un sucesor que descarta los tramos con las calzadas de
la lista. Sin autopistas, la única salida de Pradera Alta es el tramo
pavimentado a Arroyo Pinto; sin autopistas ni ripio, no hay recorrido.

```prolog
?- ruta_evitando(pradera_alta, ermita_vieja, [autopista], M, Cs).
M = 788r7,
Cs = [pradera_alta, arroyo_pinto, alto_del_cardo, ermita_vieja].

?- ruta_evitando(pradera_alta, ermita_vieja, [autopista, ripio], M, Cs).
false.
```
