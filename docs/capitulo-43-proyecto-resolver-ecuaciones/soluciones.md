# Soluciones del capítulo 43 — Proyecto: resolver ecuaciones

El código de esta página está en `ejemplos/capitulo-43/`, en cinco módulos
con sus pruebas: `soluciones_aislar.pl` para el ejercicio 2,
`soluciones_reglas.pl` para el 3, el 4 y el 5, `soluciones_metodos.pl` para
el 6, el 7, el 8 y el 12, `soluciones_numericas.pl` para el 9 y el 10, y
`soluciones.pl` para el 11. Ninguno modifica los archivos del capítulo: los
axiomas y las reglas nuevas se agregan a `axioma/3` y a `regla/3`, que son
`multifile`, y los métodos nuevos son predicados que prueban su método y
usan `resolver/3` de `ecuaciones.pl` cuando no se aplica. Como en el
capítulo, todos cargan otros módulos y se ejecutan en una instalación local.
En las consultas, un predicado de otro módulo se llama con el nombre del
módulo delante, `ecuaciones:resolver/3`, porque el archivo de la solución no
lo exporta.

## 1

Con `aislar.pl` cargado:

<!-- ejemplo: capitulo-43/aislar.pl predicado: posicion/3 -->
```prolog
%!  posicion(+S, +T, -Camino:list(integer)) is nondet.
%
%   Camino es la lista de números de argumento que lleva de T a un
%   subtérmino idéntico (==) a S. Hay una respuesta por aparición.
posicion(S, T, []) :-
    T == S.
posicion(S, T, [N|Camino]) :-
    compound(T),
    arg(N, T, A),
    posicion(S, A, Camino).
```

```prolog
?- posicion(x, 3 - x = 1, P).
P = [1, 2] ;
false.

?- resolver(3 - x = 1, x, S).
S = (x=2) ;
false.

?- posicion(x, cos(2 * x) = 0, P).
P = [1, 1, 2] ;
false.

?- resolver(cos(2 * x) = 0, x, S).
S = (x=acos(0)/2) ;
S = (x= -acos(0)/2) ;
false.

?- resolver(x ^ 3 = 8, x, S).
S = (x=8^(1/3)) ;
false.

?- resolver(x * (x + 1) = 2, x, S).
false.

?- resolver(x / 2 = 5, x, S).
false.
```

En `3 - x = 1`, la incógnita es el segundo argumento de la resta, y el axioma
`axioma(2, U - V = W, V = U - W)` da `x = 3 - 1`, que el simplificador reduce
a 2. En `cos(2 * x) = 0` se aplican dos axiomas: el del coseno, con dos
soluciones, y el del producto por el segundo argumento, que divide por 2. En
`x ^ 3 = 8` el exponente no es 2, y el axioma general da la raíz cúbica como
`8 ^ (1 / 3)`. `x * (x + 1) = 2` tiene dos apariciones y la versión 1 no la
resuelve. `x / 2 = 5` tiene una sola, pero no hay axioma para el cociente:
`aislar_camino/3` no encuentra uno para el número 1 con `/` en la raíz, y
falla. Una aparición es necesaria para aislar, pero no suficiente: cada
operación del camino necesita su axioma.

## 2

<!-- ejemplo: capitulo-43/soluciones_aislar.pl fragmento: aislar:axioma(1, U / V .. W \== 0. -->
```prolog
aislar:axioma(1, U / V = W, U = W * V).
aislar:axioma(2, U / V = W, V = U / W) :-
    W \== 0.
```

```prolog
?- resolver(x / 2 = 5, x, S).
S = (x=10) ;
false.

?- resolver(12 / x = 4, x, S).
S = (x=12/4) ;
false.

?- resolver(12 / x = 0, x, S).
false.
```

Con la incógnita en el dividendo, `U / V = W` pasa a `U = W * V`, y no hace
falta ninguna condición: `V` ya es un divisor de la ecuación original. Con la
incógnita en el divisor, `V = U / W` divide por `W`, el lado derecho, y si
`W` es 0 la ecuación `12 / x = 0` no tiene solución: sin la condición, el
axioma daría `x = 12 / 0`, una expresión sin valor. La condición es la misma
que la de los axiomas del producto. Las cláusulas se agregan desde otro
archivo porque `aislar.pl` declara `axioma/3` como `multifile`; sin esa
declaración, cargar `soluciones_aislar.pl` reemplazaría los axiomas del
capítulo en lugar de sumarse a ellos.

## 3

La regla se agrega con el mismo mecanismo que usa el capítulo: `coleccion/1`
envuelve la regla, y `term_expansion/2` la carga como una cláusula de
`colectar:regla/3`. Las reglas van entre dos pares de paréntesis porque la
prioridad de `si`, 1150, es mayor que la de un argumento:

<!-- ejemplo: capitulo-43/soluciones_reglas.pl predicado: term_expansion/2 -->
```prolog
%!  term_expansion(+Termino, -Clausula) is semidet.
%
%   coleccion(Regla) se carga como una cláusula de colectar:regla/3, y
%   atraccion(Regla) como una de atraer:regla/3.
term_expansion(coleccion(Regla), colectar:Clausula) :-
    expandir_regla(Regla, Clausula).
term_expansion(atraccion(Regla), atraer:Clausula) :-
    expandir_regla(Regla, Clausula).
```

<!-- ejemplo: capitulo-43/soluciones_reglas.pl fragmento: Ejercicio 3: .. coleccion((W ^ 2 -->
```prolog
% Ejercicio 3: una regla que aumenta las apariciones.
coleccion((W ^ 2 ~> W * W si con(W))).
```

```prolog
?- colectar:resolver(x * x + x = 6, x, S).
false.

?- colectar_sin_medida(x ^ 2 + x = 6, x, E).
E = (x*x+x=6).
```

La versión 2 colecta `x * x` en `x ^ 2`, y queda `x ^ 2 + x = 6`, con dos
apariciones que ninguna regla reduce. La regla nueva se aplica a `x ^ 2`,
pero da `x * x`, con tres apariciones en lugar de dos, y `colectar/3` la
descarta: la regla nunca se acepta, porque siempre aumenta la cantidad.
Sin esa comparación, las dos reglas se deshacen una a la otra:

<!-- ejemplo: capitulo-43/soluciones_reglas.pl predicado: resolver_sin_medida/3 colectar_sin_medida/3 -->
```prolog
%!  resolver_sin_medida(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver_/3 de colectar.pl, con colectar_sin_medida/3: puede no
%   terminar.
resolver_sin_medida(Ecuacion, X, Solucion) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, Solucion)
    ;   colectar_sin_medida(Ecuacion, X, Ecuacion1)
    ->  resolver_sin_medida(Ecuacion1, X, Solucion)
    ).

%!  colectar_sin_medida(+Ecuacion0, +X:atom, -Ecuacion) is semidet.
%
%   Ecuacion resulta de reescribir un subtérmino de Ecuacion0 con la
%   primera regla de colección que se aplica, reduzca o no las
%   apariciones de X.
colectar_sin_medida(Ecuacion0, X, Ecuacion) :-
    once(reescribir(colectar:regla, X, Ecuacion0, Ecuacion)).
```

```prolog
?- call_with_inference_limit(resolver_sin_medida(x * x + x = 6, x, _), 200000, R).
R = inference_limit_exceeded.

?- ecuaciones:resolver(x * x + x = 6, x, S).
S = (x=2.0) ;
S = (x= -3.0).
```

`resolver_sin_medida/3` pasa de `x * x + x = 6` a `x ^ 2 + x = 6` y de vuelta,
sin fin. La medida es lo que hace terminar la colección: un número natural
que baja en cada paso no puede bajar para siempre. La versión final resuelve
la ecuación como un polinomio.

## 4

<!-- ejemplo: capitulo-43/soluciones_reglas.pl fragmento: Ejercicio 4: .. coleccion((W + U * W -->
```prolog
% Ejercicio 4: potencias de la misma base y un sumando sin coeficiente.
coleccion((W ^ M * W ^ N ~> W ^ (M + N) si con(W), libre(M), libre(N))).
coleccion((W ^ N * W ~> W ^ (N + 1) si con(W), libre(N))).
coleccion((W * W ^ N ~> W ^ (N + 1) si con(W), libre(N))).
coleccion((W + U * W ~> (1 + U) * W si con(W), libre(U))).
```

```prolog
?- colectar:resolver(sin(x) ^ 2 * sin(x) = 0.125, x, S).
S = (x=asin(0.125^(1/3))) ;
S = (x=pi-asin(0.125^(1/3))) ;
false.

?- colectar:resolver(x ^ 2 * x ^ 3 = 32, x, S).
S = (x=32^(1/5)) ;
false.

?- colectar:resolver(x + 2 * x = 6, x, S).
S = (x=6/3) ;
false.
```

`W ^ N * W` necesita las dos formas, `W ^ N * W` y `W * W ^ N`, porque los
patrones no conocen la conmutatividad; con `W + U * W` pasa lo mismo respecto
de la regla `U * W + W` del capítulo. `0.125 ^ (1 / 3)` vale 0.5, y las dos
soluciones son $\pi/6$ y $5\pi/6$. La condición `libre(M), libre(N)` impide
sumar exponentes que contienen la incógnita, que es trabajo de la atracción.

## 5

<!-- ejemplo: capitulo-43/soluciones_reglas.pl fragmento: Ejercicio 5: .. atraccion((A ^ U / A ^ V -->
```prolog
% Ejercicio 5: cocientes de exponenciales de la misma base.
atraccion((exp(U) / exp(V) ~> exp(U - V) si con(U), con(V))).
atraccion((A ^ U / A ^ V ~> A ^ (U - V) si libre(A), con(U), con(V))).
```

```prolog
?- ecuaciones:resolver(exp(2 * x) / exp(x) = 5, x, S).
S = (x=log(5)) ;
false.

?- ecuaciones:valores(exp(2 * x) / exp(x) = 5, x, Vs).
Vs = [1.6094379124341003].

?- ecuaciones:resolver(3 ^ (x + 2) / 3 ^ x = 9, x, S).
false.

?- ecuaciones:valores(3 ^ (x + 2) / 3 ^ x = 9, x, Vs).
Vs = [].
```

La primera se atrae en `exp(2 * x - x) = 5`; la forma normal del exponente
es `x`, con una sola aparición, y el aislamiento da `log(5)`. La segunda se
atrae en `3 ^ (x + 2 - x) = 9`, y la forma normal de `x + 2 - x` es 2: la
ecuación queda `3 ^ 2 = 9`, sin la incógnita, y verdadera. Toda `x` es
solución, pero el programa no tiene forma de decir «todo número»: ningún
método se aplica a una ecuación sin incógnita, y `resolver/3` falla.
`valores/3` da la lista vacía, que tampoco dice lo correcto. Una extensión
razonable es reconocer ese caso antes de despachar: si la ecuación no
contiene la incógnita, evaluar sus dos lados y responder `identidad` o
fallar.

## 6

<!-- ejemplo: capitulo-43/soluciones_metodos.pl predicado: resolver_factores/3 factores/3 -->
```prolog
%!  resolver_factores(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Si la Ecuacion es A * B = 0, Solucion es una solución de F = 0 para
%   uno de los factores F que contienen X; si no, una solución de
%   resolver/3.
resolver_factores(Ecuacion, X, Solucion) :-
    (   Ecuacion = (A * B = 0)
    ->  factores(A * B, X, Fs0),
        list_to_set(Fs0, Fs),
        member(F, Fs),
        resolver_factores(F = 0, X, Solucion)
    ;   resolver(Ecuacion, X, Solucion)
    ).

%!  factores(+E, +X:atom, -Fs:list) is det.
%
%   Fs son los factores del producto E que contienen X, en orden.
factores(E, X, Fs) :-
    (   E = A * B
    ->  factores(A, X, FA),
        factores(B, X, FB),
        append(FA, FB, Fs)
    ;   con(X, E)
    ->  Fs = [E]
    ;   Fs = []
    ).
```

```prolog
?- resolver_factores(cos(x) * (1 - 2 * sin(x)) = 0, x, S).
S = (x=acos(0)) ;
S = (x= -acos(0)) ;
S = (x=asin(1/2)) ;
S = (x=pi-asin(1/2)) ;
false.

?- resolver_factores(x * (x ^ 2 - 4) = 0, x, S).
S = (x=0) ;
S = (x=sqrt(4)) ;
S = (x= -sqrt(4)) ;
false.

?- ecuaciones:resolver(x * (x ^ 2 - 4) = 0, x, S).
S = (x= -2.0) ;
S = (x=2.0).
```

La factorización se prueba antes que todo lo demás, porque la condición es
barata: unificar con `A * B = 0`. Cada factor se resuelve con el mismo
predicado, para que un factor que es a su vez un producto también se
factorice. Sin la factorización, la primera ecuación no se resuelve: tiene
dos apariciones, no es un polinomio y `derivar/3` no deriva el coseno. La
segunda es un polinomio de grado 3, y la versión final la resuelve con
Newton, que pierde la raíz 0: desde los cuatro valores iniciales, Newton
llega solo a -2 y a 2. La factorización da las tres, exactas.

## 7

<!-- ejemplo: capitulo-43/soluciones_metodos.pl predicado: resolver_homogeneo/3 homogeneizar/5 homogeneo/5 lineal/3 -->
```prolog
%!  resolver_homogeneo(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Si todas las potencias B ^ E de la Ecuacion con X en el exponente
%   tienen la misma base B y un exponente lineal C * X + D, con C entero
%   positivo, la Ecuacion se escribe como un polinomio en u = B ^ X, se
%   resuelve en u, y Solucion es una solución de B ^ X = u. Si no, una
%   solución de resolver/3.
resolver_homogeneo(Ecuacion, X, Solucion) :-
    (   homogeneizar(Ecuacion, X, u, B, Ecuacion1)
    ->  resolver(Ecuacion1, u, u = V),
        resolver(B ^ X = V, X, Solucion)
    ;   resolver(Ecuacion, X, Solucion)
    ).

%!  homogeneizar(+Ecuacion, +X:atom, +U:atom, -B, -Ecuacion1) is semidet.
%
%   Ecuacion1 es la Ecuacion con cada potencia B ^ (C * X + D) escrita
%   como B ^ D * U ^ C, y sin X. U no debe aparecer en la Ecuacion.
homogeneizar(Ecuacion, X, U, B, Ecuacion1) :-
    libre(U, Ecuacion),
    once(( sub_term(B ^ E, Ecuacion),
           libre(X, B),
           con(X, E) )),
    homogeneo(B, X, U, Ecuacion, Ecuacion1),
    libre(X, Ecuacion1).

%!  homogeneo(+B, +X:atom, +U:atom, +E0, -E) is semidet.
%
%   E es E0 con cada B ^ (C * X + D) escrita como B ^ D * U ^ C. Falla si
%   un exponente con X no es lineal con C entero positivo.
homogeneo(B, X, U, E0, E) :-
    (   E0 = B ^ Exponente,
        con(X, Exponente)
    ->  forma_normal(Exponente, X, Ms),
        lineal(Ms, C, D),
        integer(C),
        C > 0,
        potencia(U, C, P),
        (   D =:= 0
        ->  E = P
        ;   E = B ^ D * P
        )
    ;   compound(E0)
    ->  mapargs(homogeneo(B, X, U), E0, E)
    ;   E = E0
    ).

%!  lineal(+Ms:list(pair), -C:number, -D:number) is semidet.
%
%   Ms es la forma normal de C * X + D, con C distinto de 0.
lineal([1-C], C, 0).
lineal([1-C, 0-D], C, D).
```

```prolog
?- resolver_homogeneo(2 ^ (2 * x) - 5 * 2 ^ (x + 1) + 16 = 0, x, S).
S = (x=log(8.0)/log(2)) ;
S = (x=log(2.0)/log(2)) ;
false.
```

Las potencias con la incógnita en el exponente son `2 ^ (2 * x)` y
`2 ^ (x + 1)`, las que Sterling y Shapiro llaman los *offenders*. La forma
normal de cada exponente da `C` y `D`: `[1-2]` para `2 * x` y `[1-1, 0-1]`
para `x + 1`. Con `u = 2 ^ x`, la ecuación queda `u ^ 2 - 5 * (2 ^ 1 * u) +
16 = 0`, un polinomio de grado 2 con raíces 8 y 2; `2 ^ x = 8` y
`2 ^ x = 2` dan 3 y 1. `homogeneizar/5` exige al final que la ecuación nueva
no tenga la incógnita: si alguna potencia tenía otra base, o la incógnita
aparecía fuera de un exponente, el método no se aplica. El átomo `u` no
debe aparecer en la ecuación original; una versión más general lo elegiría
entre los que no aparecen.

## 8

<!-- ejemplo: capitulo-43/soluciones_metodos.pl predicado: resolver_bicuadrada/3 grado_par/1 mitad/2 -->
```prolog
%!  resolver_bicuadrada(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Si la Ecuacion es un polinomio en X de grado mayor que 2 con todos los
%   grados pares, se resuelve como un polinomio en u = X ^ 2, y Solucion
%   es una solución de X ^ 2 = u. Si no, una solución de resolver/3.
resolver_bicuadrada(Izq = Der, X, Solucion) :-
    (   forma_normal(Izq - Der, X, Ms),
        Ms = [G-_|_],
        G > 2,
        maplist(grado_par, Ms)
    ->  maplist(mitad, Ms, Ms2),
        polinomio_termino(Ms2, u, T),
        resolver(T = 0, u, u = V),
        resolver(X ^ 2 = V, X, Solucion)
    ;   resolver(Izq = Der, X, Solucion)
    ).

%!  grado_par(+M:pair) is semidet.
%
%   El monomio M tiene grado par.
grado_par(G-_) :-
    G mod 2 =:= 0.

%!  mitad(+M:pair, -M2:pair) is det.
%
%   M2 es el monomio M con la mitad del grado.
mitad(G-C, G2-C) :-
    G2 is G // 2.
```

```prolog
?- resolver_bicuadrada(x ^ 4 - 5 * x ^ 2 + 4 = 0, x, S).
S = (x=sqrt(4.0)) ;
S = (x= -sqrt(4.0)) ;
S = (x=sqrt(1.0)) ;
S = (x= -sqrt(1.0)) ;
false.
```

La forma normal es `[4-1, 2-(-5), 0-4]`: todos los grados son pares, y
dividirlos por 2 da `u ^ 2 - 5 * u + 4`, con raíces 4 y 1. Las cuatro
soluciones son las mismas que Newton halla en la
[sección 43.1](index.md#431-el-programa-terminado), pero exactas y como
expresiones. Newton las encuentra porque los valores iniciales -1 y 1 son
raíces y -10 y 10 convergen a -2 y 2; con otros valores iniciales podría
perder alguna, y la sustitución no depende de eso.

## 9

<!-- ejemplo: capitulo-43/soluciones_numericas.pl predicado: derivar_mas/3 derivada/3 resolver_mas/3 -->
```prolog
%!  derivar_mas(+E, +X:atom, -D) is det.
%
%   D es la derivada simplificada de la expresión cerrada E respecto de X.
%   E usa +, -, *, /, ^ con exponente numérico, sin/1, cos/1, exp/1 y
%   log/1; cualquier otra operación produce un error de dominio.
derivar_mas(E, X, D) :-
    must_be(ground, E),
    must_be(atom, X),
    derivada(E, X, D0),
    simplificar(D0, D).

%!  derivada(+E, +X:atom, -D) is det.
%
%   D es la derivada de E respecto de X, sin simplificar.
derivada(E, X, D) :-
    (   E == X
    ->  D = 1
    ;   atomic(E)
    ->  D = 0
    ;   E = U + V
    ->  D = DU + DV,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = U - V
    ->  D = DU - DV,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = -U
    ->  D = -DU,
        derivada(U, X, DU)
    ;   E = U * V
    ->  D = DU * V + U * DV,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = U / V
    ->  D = (DU * V - U * DV) / V ^ 2,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = U ^ N,
        number(N)
    ->  N1 is N - 1,
        D = N * U ^ N1 * DU,
        derivada(U, X, DU)
    ;   E = sin(U)
    ->  D = cos(U) * DU,
        derivada(U, X, DU)
    ;   E = cos(U)
    ->  D = -sin(U) * DU,
        derivada(U, X, DU)
    ;   E = exp(U)
    ->  D = exp(U) * DU,
        derivada(U, X, DU)
    ;   E = log(U)
    ->  D = DU / U,
        derivada(U, X, DU)
    ;   domain_error(expresion_derivable, E)
    ).

%!  resolver_mas(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es una solución de resolver/3 de ecuaciones.pl; si no hay
%   ninguna, X = R con R una raíz que Newton halla con derivar_mas/3.
resolver_mas(Ecuacion, X, Solucion) :-
    (   resolver(Ecuacion, X, Solucion)
    *-> true
    ;   Ecuacion = (Izq = Der),
        F = Izq - Der,
        derivar_mas(F, X, DF),
        raices(F, DF, X, Rs),
        member(R, Rs),
        Solucion = (X = R)
    ).
```

```prolog
?- derivar_mas(cos(x) - x, x, D).
D = -sin(x)-1.

?- resolver_mas(cos(x) = x, x, S).
S = (x=0.7390851332151607).

?- resolver_mas(x + 1 = 1 / x, x, S).
S = (x= -1.618033988749895) ;
S = (x=0.6180339887498948).
```

`derivar/3` del [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md) está en un archivo que no se modifica, y por eso
la derivada ampliada es un predicado nuevo con todas las reglas; las nuevas
son las de Clocksin y Mellish y la regla de la cadena para cada función. Las
dos raíces de `x + 1 = 1 / x` son $(-1 \pm \sqrt{5})/2$. Si una iteración
pasa por 0, `1 / x` produce un error de evaluación, que `valor/4` de
`ecuaciones.pl` captura: esa iteración no da raíz, y las otras sí.

## 10

<!-- ejemplo: capitulo-43/soluciones_numericas.pl predicado: pasos_newton/5 pasos/6 -->
```prolog
%!  pasos_newton(+F, +X:atom, +X0:number, +N:integer, -Xs:list) is det.
%
%   Xs son los valores que recorre el método de Newton sobre la expresión
%   F en X desde X0, con X0 primero y N pasos como máximo; la lista se
%   corta antes si la derivada se anula.
pasos_newton(F, X, X0, N, [X0|Xs]) :-
    derivar(F, X, DF),
    pasos(F, DF, X, X0, N, Xs).

%!  pasos(+F, +DF, +X:atom, +X0:number, +N:integer, -Xs:list) is det.
%
%   Como pasos_newton/5, con la derivada DF calculada y sin X0.
pasos(F, DF, X, X0, N, Xs) :-
    (   N > 0,
        evaluar(DF, [X-X0], Pendiente),
        Pendiente =\= 0
    ->  evaluar(F, [X-X0], Y),
        X1 is X0 - Y / Pendiente,
        N1 is N - 1,
        Xs = [X1|Xs1],
        pasos(F, DF, X, X1, N1, Xs1)
    ;   Xs = []
    ).
```

```prolog
?- pasos_newton(x ^ 3 - 2 * x + 2, x, 0, 5, Xs).
Xs = [0, 1, 0, 1, 0, 1].

?- pasos_newton(x ^ 3 - 2 * x + 2, x, 10, 8, Xs).
Xs = [10, 6.704697986577181, 4.52203148514122, 3.0825836315501505, 2.134661679301015, 1.4956177102374084, 0.9958380727097266, -0.025503310354579756, 1.000993185071497].

?- pasos_newton(x ^ 2 + 1, x, 1, 5, Xs).
Xs = [1, 0].

?- pasos_newton(x ^ 2 - 2, x, 0, 5, Xs).
Xs = [0].

?- ecuaciones:resolver(x ^ 3 - 2 * x + 2 = 0, x, S).
S = (x= -1.7692923542386314).
```

`x ^ 3 - 2 * x + 2` desde 0 es el ciclo: en 0 la tangente corta el eje en
1, y en 1 lo corta en 0. Desde 10 la iteración baja hacia la raíz real,
-1.769, pero pasa cerca de 1 y cae en el mismo ciclo. `x ^ 2 + 1` no tiene
raíces reales; desde 1 la tangente lleva a 0, donde la derivada se anula y
la tangente es horizontal. `x ^ 2 - 2` tiene raíces, pero en 0 la derivada
es nula y Newton no puede dar un paso. Son las tres formas de fallar de la
[sección 43.6](newton.md#el-metodo-de-newton-y-la-comprobacion): la derivada nula, la
iteración que no converge y la raíz que no se alcanza desde el valor
inicial. `resolver/3` encuentra la raíz de la cúbica porque prueba cuatro
valores iniciales y -10 y -1 convergen; los otros dos fallan después de 100
pasos.

## 11

<!-- ejemplo: capitulo-43/soluciones.pl predicado: sistema/5 reemplazo/4 -->
```prolog
%!  sistema(+E1, +E2, +X:atom, +Y:atom, -Solucion:list) is nondet.
%
%   Solucion es [X = VX, Y = VY], con VX y VY números que cumplen las
%   ecuaciones cerradas E1 y E2 en las incógnitas X e Y, si X puede
%   despejarse de E1. Hay una respuesta por solución.
sistema(E1, E2, X, Y, [X = VX, Y = VY]) :-
    resolver(E1, X, X = EX),
    mapsubterms(reemplazo(X, EX), E2, E2Y),
    resolver(E2Y, Y, Y = EY),
    VY is EY,
    evaluar(EX, [Y-VY], VX).

%!  reemplazo(+X:atom, +E, +T0, -T) is semidet.
%
%   T es E si T0 es la incógnita X; falla si no, y entonces mapsubterms/3
%   sigue por los argumentos de T0.
reemplazo(X, E, T0, E) :-
    T0 == X.
```

```prolog
?- sistema(x + y = 3, x - y = 1, x, y, S).
S = [x=2, y=1] ;
false.

?- sistema(x + y = 5, x * y = 6, x, y, S).
S = [x=3.0, y=2.0] ;
S = [x=2.0, y=3.0] ;
false.

?- sistema(x * y = 6, x + y = 5, x, y, S).
false.
```

`x + y = 3` tiene una sola aparición de `x`, y el aislamiento trata a `y`
como a cualquier otro átomo: `x = 3 - y`. La segunda ecuación queda
`3 - y - y = 1`, un polinomio en `y`. En el segundo sistema, `x = 5 - y`
convierte `x * y = 6` en `(5 - y) * y = 6`, un polinomio de grado 2 con dos
soluciones. Con las ecuaciones en el otro orden, `x = 6 / y`, y la segunda
queda `6 / y + y = 5`: la división por la incógnita no es un polinomio, y
`derivar/3` no deriva el cociente, así que ningún método de `ecuaciones.pl`
la resuelve. Multiplicar los dos lados por `y` la convertiría en un
polinomio, pero es un paso que puede agregar la solución `y = 0`, que la
comprobación de `valores/3` tendría que descartar.

## 12

<!-- ejemplo: capitulo-43/soluciones_metodos.pl fragmento: atraer:regla(X, sqrt(U) .. con(X, V). -->
```prolog
atraer:regla(X, sqrt(U) * sqrt(V), sqrt(U * V)) :-
    con(X, U),
    con(X, V).
```

<!-- ejemplo: capitulo-43/soluciones_metodos.pl predicado: parcial/3 aislar_parcial/3 subtermino/3 reemplazo/4 -->
```prolog
%!  parcial(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver_parcial/3, sin verificar los argumentos ni simplificar.
parcial(Ecuacion, X, Solucion) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, Solucion)
    ;   Ecuacion = (Izq = Der),
        forma_normal(Izq - Der, X, Ms)
    ->  resolver_polinomio(Ms, X, Solucion)
    ;   findall(E, aislar_parcial(Ecuacion, X, E), [E1|Es])
    ->  member(E2, [E1|Es]),
        parcial(E2, X, Solucion)
    ;   colectar(Ecuacion, X, Ecuacion1)
    ->  parcial(Ecuacion1, X, Solucion)
    ;   colectar_normal(Ecuacion, X, Ecuacion1)
    ->  parcial(Ecuacion1, X, Solucion)
    ;   atraer(Ecuacion, X, Ecuacion1)
    ->  parcial(Ecuacion1, X, Solucion)
    ).

%!  aislar_parcial(+Ecuacion, +X:atom, -Ecuacion1) is nondet.
%
%   Ecuacion1 es S = R, con S el menor subtérmino de la Ecuacion que
%   contiene todas las apariciones de X, si es menor que un lado entero.
%   R resulta de aislar S como si fuera una incógnita: hay una respuesta
%   por cada solución que separan los axiomas.
aislar_parcial(Ecuacion, X, S = R) :-
    findall(P, posicion(X, Ecuacion, P), [P1|Ps]),
    Ps \== [],
    foldl(prefijo_comun, Ps, P1, Comun),
    Comun = [_, _|_],
    subtermino(Comun, Ecuacion, S),
    libre(z, Ecuacion),
    mapsubterms(reemplazo(S, z), Ecuacion, Ecuacion0),
    aislar(Ecuacion0, z, z = R).

%!  subtermino(+Camino:list(integer), +T, -S) is det.
%
%   S es el subtérmino de T en la posición Camino.
subtermino([], T, T).
subtermino([N|Camino], T, S) :-
    arg(N, T, A),
    subtermino(Camino, A, S).

%!  reemplazo(+S, +Nuevo, +T0, -T) is semidet.
%
%   T es Nuevo si T0 es idéntico a S; falla si no, y entonces
%   mapsubterms/3 sigue por los argumentos de T0.
reemplazo(S, Nuevo, T0, Nuevo) :-
    T0 == S.
```

```prolog
?- aislar_parcial(sqrt(x * (x + 5)) = 6, x, E).
E = (x*(x+5)=6^2) ;
false.

?- resolver_parcial(sqrt(x) * sqrt(x + 5) = 6, x, S).
S = (x=4.0) ;
S = (x= -9.0).

?- ecuaciones:resolver(sqrt(x) * sqrt(x + 5) = 6, x, S).
false.
```

`aislar_parcial/3` reemplaza el menor subtérmino que contiene todas las
apariciones por un átomo nuevo, `z`, que aparece una sola vez, y lo aísla con
`aislar/3` de la versión 1: los axiomas no distinguen una incógnita de un
subtérmino. La atracción deja `sqrt(x * (x + 5)) = 6`, el aislamiento parcial
`x * (x + 5) = 6 ^ 2`, y el polinomio da 4 y -9. Solo 4 cumple la ecuación:
`sqrt(-9)` no tiene valor real, y la regla `sqrt(U) * sqrt(V) = sqrt(U * V)`
vale solo si U y V no son negativos. Es el mismo caso que el de los
logaritmos en la [sección 43.4](index.md#434-version-3-la-atraccion), y la
comprobación de `valores/3` descartaría -9 si `resolver_parcial/3`
reemplazara el despachador de `ecuaciones.pl`. Sin el aislamiento parcial,
la versión final no resuelve la ecuación aunque la regla de atracción esté
cargada: después de atraer quedan dos apariciones dentro de la raíz, y
ninguna regla de colección las reduce.

## 13

La potencia de exponente natural impar es creciente en todos los reales, y
por eso su axioma conserva la relación. `resolver_desigualdad/3`, de la
[sección 43.11](press.md#4311-desigualdades), aplica un axioma por nivel:

<!-- ejemplo: capitulo-43/desigualdades.pl predicado: resolver_desigualdad/3 -->
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
```

El axioma nuevo se agrega desde `soluciones_press.pl` como una cláusula
`multifile` de `axioma_d/3`:

<!-- ejemplo: capitulo-43/soluciones_press.pl fragmento: desigualdades:axioma_d(1, d(R, U ^ N, W), d(R, U, Raiz)) :- .. raiz_impar(W, N, Raiz). -->
```prolog
desigualdades:axioma_d(1, d(R, U ^ N, W), d(R, U, Raiz)) :-
    integer(N),
    N > 0,
    N mod 2 =:= 1,
    raiz_impar(W, N, Raiz).
```

<!-- ejemplo: capitulo-43/soluciones_press.pl predicado: raiz_impar/3 -->
```prolog
%!  raiz_impar(+W, +N:integer, -Raiz) is det.
%
%   Raiz es la expresión de la raíz real N-ésima de W, con N impar: la
%   potencia 1 / N de un número negativo no tiene valor real en is/2, y
%   por eso, si W es negativo, se escribe como el opuesto de la raíz del
%   valor de -W.
raiz_impar(W, N, Raiz) :-
    V is W,
    (   V >= 0
    ->  Raiz = W ^ (1 / N)
    ;   A is -V,
        Raiz = -(A ^ (1 / N))
    ).
```

```prolog
?- desigualdades:resolver_desigualdad(x ^ 3 + 1 > -7, x, S).
S = (x> -(8^(1/3))).

?- desigualdades:resolver_desigualdad(2 * x ^ 5 =< 64, x, S).
S = (x=<(64/2)^(1/5)).
```

`is/2` calcula `A ^ (1 / N)` con números de punto flotante, y la potencia
de un negativo con exponente no entero no tiene valor real: `(-8) ^ (1 / 3)`
es un error de evaluación aunque la raíz cúbica de -8 sea -2. Por eso, con
un lado derecho negativo, la raíz se escribe como el opuesto de la raíz de
su valor absoluto. Con un exponente par el axioma no se aplica, porque la
potencia no es monótona: `x ^ 2 < 4` necesita dos extremos.

## 14

<!-- ejemplo: capitulo-43/soluciones_press.pl predicado: valores_en/4 entre/3 -->
```prolog
%!  valores_en(+Ecuacion, +X:atom, +I, -Vs:list(number)) is det.
%
%   Vs son los valores de valores/3 que están en el intervalo I =
%   i(Lo, Hi). Si la aritmética de intervalos prueba que la Ecuacion no
%   tiene raíces en I, Vs es [] sin resolverla.
valores_en(Ecuacion, X, i(Lo0, Hi0), Vs) :-
    (   sin_raices(Ecuacion, X, i(Lo0, Hi0))
    ->  Vs = []
    ;   Lo is Lo0,
        Hi is Hi0,
        valores(Ecuacion, X, Vs0),
        include(entre(Lo, Hi), Vs0, Vs)
    ).

%!  entre(+Lo:number, +Hi:number, +V:number) is semidet.
%
%   V está entre Lo y Hi.
entre(Lo, Hi, V) :-
    Lo =< V,
    V =< Hi.
```

```prolog
?- valores_en(x ^ 2 - 2 = 0, x, i(0, 3), Vs).
Vs = [1.4142135623730951].

?- valores_en(x ^ 2 + 1 = 0, x, i(-10, 10), Vs).
Vs = [].
```

La segunda no llega a resolver la ecuación: el intervalo de `x ^ 2 + 1`
con `x` entre -10 y 10 es `i(1, 101)`, que no contiene 0. La prueba con
intervalos es más barata que resolver, pero solo puede responder «no hay
raíces»: si el intervalo contiene 0, las raíces pueden existir o no, y
hace falta resolver.
