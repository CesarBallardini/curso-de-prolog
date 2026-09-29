# La forma normal de un polinomio

Esta página contiene la sección
[43.5](index.md#435-version-4-la-forma-normal-de-un-polinomio) del
[capítulo 43](index.md): la versión 4 del programa que resuelve ecuaciones,
que lleva un polinomio a una forma normal y obtiene de ella dos métodos
nuevos. El código está en `polinomio.pl`, en `ejemplos/capitulo-43/`, con
sus pruebas; carga los módulos de las versiones anteriores y se ejecuta en
una instalación local.

## La forma normal de un polinomio

Un polinomio en `x` con coeficientes numéricos tiene una **forma normal**:
la lista de sus monomios `Grado-Coeficiente`, de mayor a menor grado, uno
por grado, sin coeficientes nulos. Dos polinomios iguales tienen la misma
forma normal, cualquiera sea la forma en que se escribieron. `monomios/3`
recorre la expresión y da sus monomios sin agrupar: la resta y el signo
menos pasan a los coeficientes, que es la etapa de «llevar la negación hacia
adentro» de *Clause and Effect*; los productos y las potencias de exponente
natural se distribuyen; una división solo se acepta por una constante; y
cualquier otra operación hace fallar el predicado, porque la expresión no es
un polinomio:

<!-- ejemplo: capitulo-43/polinomio.pl predicado: monomios/3 -->
```prolog
%!  monomios(+E, +X:atom, -Ms:list(pair)) is semidet.
%
%   Ms son los monomios Grado-Coeficiente de E, sin agrupar.
monomios(E, X, Ms) :-
    (   E == X
    ->  Ms = [1-1]
    ;   number(E)
    ->  Ms = [0-E]
    ;   E = U + V
    ->  monomios(U, X, MU),
        monomios(V, X, MV),
        append(MU, MV, Ms)
    ;   E = U - V
    ->  monomios(U, X, MU),
        monomios(V, X, MV),
        maplist(por(-1), MV, MV1),
        append(MU, MV1, Ms)
    ;   E = -U
    ->  monomios(U, X, MU),
        maplist(por(-1), MU, Ms)
    ;   E = U * V
    ->  monomios(U, X, MU),
        monomios(V, X, MV),
        producto(MU, MV, Ms)
    ;   E = U / V
    ->  forma_normal(V, X, [0-C]),
        monomios(U, X, MU),
        Inversa is 1 / C,
        maplist(por(Inversa), MU, Ms)
    ;   E = U ^ N,
        integer(N),
        N >= 0
    ->  monomios(U, X, MU),
        potencia(N, MU, Ms)
    ).
```

Los monomios del mismo grado se suman con la técnica de la
[sección 22.4](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#224-pares-y-keysort2): `keysort/2` los ordena por grado sin perder los
repetidos, y `group_pairs_by_key/2` reúne los coeficientes de cada grado:

<!-- ejemplo: capitulo-43/polinomio.pl predicado: forma_normal/3 semejantes/2 sumar_grupo/3 -->
```prolog
%!  forma_normal(+E, +X:atom, -Ms:list(pair)) is semidet.
%
%   Ms son los monomios Grado-Coeficiente de la expresión cerrada E, un
%   polinomio en X con coeficientes numéricos: grados de mayor a menor,
%   uno por grado, sin coeficientes nulos. Falla si E no es un polinomio.
forma_normal(E, X, Ms) :-
    monomios(E, X, Ms0),
    semejantes(Ms0, Ms).

%!  semejantes(+Ms0:list(pair), -Ms:list(pair)) is det.
%
%   Ms tiene un monomio por grado de Ms0, con la suma de los coeficientes
%   de ese grado, de mayor a menor grado y sin los nulos.
semejantes(Ms0, Ms) :-
    keysort(Ms0, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    foldl(sumar_grupo, Grupos, [], Ms).

%!  sumar_grupo(+Grupo:pair, +Ms0:list(pair), -Ms:list(pair)) is det.
%
%   Ms es Ms0 con el monomio del Grupo Grado-Coeficientes delante, salvo
%   que los coeficientes sumen 0. Como los grupos llegan de menor a mayor
%   grado, la lista queda de mayor a menor.
sumar_grupo(G-Cs, Ms0, Ms) :-
    sum_list(Cs, C),
    (   C =:= 0
    ->  Ms = Ms0
    ;   Ms = [G-C|Ms0]
    ).
```

`polinomio_termino/3` escribe la forma normal como una suma asociada a
izquierda, con `foldl/4` y la suma construida hasta el momento como
acumulador, la misma construcción de `asociar_izquierda_2/2` en la
[solución 16 del capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/soluciones.md#16):

```prolog
?- forma_normal((x + 1) * (x - 1) - 2 * (x - 3), x, Ms).
Ms = [2-1, 1- -2, 0-5].

?- forma_normal(x - 3 * x ^ 2 + 1 / 2, x, Ms), polinomio_termino(Ms, x, T).
Ms = [2- -3, 1-1, 0-0.5],
T = -3*x^2+x+0.5.

?- forma_normal(x + sin(x), x, Ms).
false.
```

La forma normal da dos métodos. El primero resuelve un polinomio de grado 1
o 2 con la fórmula de la ecuación cuadrática; el discriminante decide si hay dos raíces
reales, una o ninguna:

<!-- ejemplo: capitulo-43/polinomio.pl predicado: resolver_polinomio/3 -->
```prolog
%!  resolver_polinomio(+Ms:list(pair), +X:atom, -Solucion) is nondet.
%
%   Solucion es X = V, con V un número real, una raíz del polinomio de
%   grado 1 o 2 en forma normal Ms. Falla si el grado es otro, o si no
%   tiene raíces reales.
resolver_polinomio([1-A|Ms], X, X = V) :-
    coeficiente(0, Ms, B),
    V is -B / A.
resolver_polinomio([2-A|Ms], X, X = V) :-
    coeficiente(1, Ms, B),
    coeficiente(0, Ms, C),
    D is B * B - 4 * A * C,
    (   D =:= 0
    ->  V is -B / (2 * A)
    ;   D > 0,
        (   V is (-B + sqrt(D)) / (2 * A)
        ;   V is (-B - sqrt(D)) / (2 * A)
        )
    ).
```

El segundo es una colección general: `normalizar/3` escribe en forma normal
cada subtérmino maximal que es un polinomio, y `colectar_normal/3` acepta el
resultado si reduce las apariciones, con la misma medida que las reglas. El
despachador de la versión 4 prueba el polinomio después del aislamiento, y
la colección por forma normal después de la de las reglas:

<!-- ejemplo: capitulo-43/polinomio.pl predicado: colectar_normal/3 resolver_/3 -->
```prolog
%!  colectar_normal(+Ecuacion0, +X:atom, -Ecuacion) is semidet.
%
%   Ecuacion es Ecuacion0 con sus subtérminos polinómicos en forma normal,
%   si eso reduce las apariciones de X.
colectar_normal(Ecuacion0, X, Ecuacion) :-
    normalizar(Ecuacion0, X, Ecuacion),
    apariciones(Ecuacion0, X, N0),
    apariciones(Ecuacion, X, N),
    N < N0.

%!  resolver_(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Como resolver/3, sin verificar los argumentos ni simplificar. Prueba
%   los métodos en orden: aislar, el polinomio, colectar con las reglas,
%   colectar con la forma normal, y atraer.
resolver_(Ecuacion, X, Solucion) :-
    (   apariciones(Ecuacion, X, 1)
    ->  aislar(Ecuacion, X, Solucion)
    ;   Ecuacion = (Izq = Der),
        forma_normal(Izq - Der, X, Ms)
    ->  resolver_polinomio(Ms, X, Solucion)
    ;   colectar(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ;   colectar_normal(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ;   atraer(Ecuacion, X, Ecuacion1)
    ->  resolver_(Ecuacion1, X, Solucion)
    ).
```

```prolog
?- resolver(x ^ 2 - 3 * x + 2 = 0, x, S).
S = (x=2.0) ;
S = (x=1.0).

?- normalizar(2 ^ (x + (x + 1)) = 32, x, E).
E = (2^(2*x+1)=32).

?- resolver(2 ^ x * 2 ^ (x + 1) = 32, x, S).
S = (x=(log(32)/log(2)-1)/2) ;
false.
```

La normalización se aplica después de los otros métodos, no antes: la forma
normal de `(x + 1) ^ 2` tiene tres monomios y dos apariciones de `x`, y
llevar a esa forma una ecuación que se podía aislar la haría más difícil.
El método del polinomio no alcanza el grado 3:

```prolog
?- resolver(x ^ 3 - 2 * x - 5 = 0, x, S).
false.
```

!!! question "Actividad"
    Predecir la forma normal de `(x - 1) ^ 3 - x ^ 3` y la respuesta de
    `resolver((x - 1) ^ 3 = x ^ 3, x, S)`: ¿de qué grado es la ecuación, y
    cuántas soluciones reales tiene? Comprobarlo.
