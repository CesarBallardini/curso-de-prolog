# Soluciones del capítulo 32 — Inspección de términos

El código de esta página está en `ejemplos/capitulo-32/soluciones.pl`,
`soluciones_experto.pl` y `soluciones_simplificar.pl`, en el mismo directorio,
y pasa sus pruebas. Los dos últimos contienen las reglas del
[capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md) y el simplificador del capítulo, para que cada uno se cargue solo.

## 1

```prolog
?- functor(T, punto, 2).
T = punto(_, _).

?- arg(N, p(a, b, a), a).
N = 1 ;
N = 3.

?- X =.. [f].
X = f.

?- f(a, b) =.. [F|As].
F = f,
As = [a, b].

?- atom([]).
false.

?- atomic("hola").
true.
```

`functor/3` construye un término con variables nuevas. `arg/3` con la posición
libre enumera, y `a` está en las posiciones 1 y 3. `=..` con una lista de un
solo elemento da el átomo, no un compuesto sin argumentos. `[]` es una
constante propia de SWI-Prolog, distinta del átomo `'[]'`, por lo que `atom/1`
falla; `atomic/1`, en cambio, la acepta, igual que a las cadenas.

## 2

```prolog
?- var(X), X = a.
X = a.

?- X = a, var(X).
false.

?- number(X), X = 3.
false.

?- X = 3, number(X).
X = 3.

?- is_list([a|T]), T = [].
false.

?- T = [], is_list([a|T]).
T = [].
```

Las tres pruebas responden sobre el estado del término en el momento de la
llamada. `var(X)` tiene éxito antes de que X se ligue y falla después;
`number/1` e `is_list/1` hacen lo contrario, porque una variable libre no es
un número ni una lista completa, aunque pueda llegar a serlo. En los tres
casos la conjunción deja de ser conmutativa, como `atom/1` en la
[sección 32.1](index.md#321-que-clase-de-termino-es).

## 3

<!-- ejemplo: capitulo-32/soluciones.pl predicado: aridad_maxima/2 consulta: aridad_maxima(f(a, g(b, c, d), [x]), N). -->
```prolog
%!  aridad_maxima(+Termino, -N:integer) is det.
%
%   N es la mayor aridad de los subtérminos compuestos de Termino, o 0 si no
%   tiene ninguno.
aridad_maxima(T, N) :-
    findall(A,
            ( sub_term(S, T),
              compound(S),
              compound_name_arity(S, _, A) ),
            Aridades),
    max_list([0|Aridades], N).
```

```prolog
?- aridad_maxima(f(a, g(b, c, d), [x]), N).
N = 3.

?- aridad_maxima(ana, N).
N = 0.
```

`sub_term/2` enumera los subtérminos, `compound/1` descarta los atómicos y
`compound_name_arity/3` da la aridad. `max_list/2`, de `library(lists)`, da el
mayor elemento de una lista de números. El 0 agregado al principio de la lista
cubre el término sin compuestos, para el que `max_list/2` fallaría con la lista
vacía.

## 4

<!-- ejemplo: capitulo-32/soluciones.pl predicado: posiciones_iguales/3 consulta: posiciones_iguales(f(a, X, c), f(a, X, d), Ps). -->
```prolog
%!  posiciones_iguales(+T1, +T2, -Posiciones:list(integer)) is semidet.
%
%   T1 y T2 tienen el mismo nombre y la misma aridad, y Posiciones son las
%   posiciones, en orden, de los argumentos idénticos (==) en los dos. Falla
%   si el nombre o la aridad difieren.
posiciones_iguales(T1, T2, Posiciones) :-
    functor(T1, Nombre, Aridad),
    functor(T2, Nombre, Aridad),
    findall(I,
            ( between(1, Aridad, I),
              arg(I, T1, X),
              arg(I, T2, Y),
              X == Y ),
            Posiciones).
```

```prolog
?- posiciones_iguales(f(a, X, c), f(a, X, d), Ps).
Ps = [1, 2].

?- posiciones_iguales(f(a), g(a), Ps).
false.
```

Los dos `functor/3` comprueban el nombre y la aridad: el segundo recibe el
nombre y la aridad del primero ya ligados. La comparación es con `==`, así que
la variable X es idéntica a sí misma y cuenta, y una variable no se liga para
igualar dos argumentos.

## 5

<!-- ejemplo: capitulo-32/soluciones.pl predicado: sustituir_ingenuo/4 consulta: sustituir_ingenuo(x, 3, f(Y, x), T). -->
```prolog
%!  sustituir_ingenuo(?Viejo, ?Nuevo, +Termino0, -Termino) is det.
%
%   Como sustituir/4, pero compara con =: reemplaza también los subtérminos
%   que unifican con Viejo, y liga sus variables.
sustituir_ingenuo(Viejo, Nuevo, T0, T) :-
    (   T0 = Viejo
    ->  T = Nuevo
    ;   compound(T0)
    ->  mapargs(sustituir_ingenuo(Viejo, Nuevo), T0, T)
    ;   T = T0
    ).
```

```prolog
?- sustituir_ingenuo(x, 3, f(Y, x), T).
Y = x,
T = f(3, 3).

?- sustituir(x, 3, f(Y, x), T).
T = f(Y, 3).
```

`T0 = Viejo` unifica la variable Y con `x`: la versión ingenua reemplaza una
aparición de `x` que no estaba en el término, y además liga Y en el término
original, que el que llama sigue usando. `sustituir/4`, de `recorrer.pl`,
compara con `==` y deja Y libre. Es la falla de `subtermino_ingenuo/2`, en una
operación que construye un término.

## 6

<!-- ejemplo: capitulo-32/soluciones.pl predicado: profundidad/2 consulta: profundidad(f(a, g(h(b)), c), P). -->
```prolog
%!  profundidad(@Termino, -P:integer) is det.
%
%   P es la profundidad de Termino: 0 si es atómico o una variable, y uno
%   más que la del argumento más profundo si es compuesto.
profundidad(T, P) :-
    (   compound(T)
    ->  compound_name_arguments(T, _, Args),
        maplist(profundidad, Args, Ps),
        max_list([0|Ps], Max),
        P is Max + 1
    ;   P = 0
    ).
```

```prolog
?- profundidad(f(a, g(h(b)), c), P).
P = 3.

?- profundidad([a, b], P).
P = 2.
```

La lista `[a, b]` es `'[|]'(a, '[|]'(b, []))`: dos compuestos anidados, y por
eso profundidad 2. `compound/1` va primero para que una variable tenga
profundidad 0 en lugar de producir un error en `compound_name_arguments/3`.

## 7

<!-- ejemplo: capitulo-32/soluciones.pl predicado: apariciones/3 consulta: apariciones(f(a, g(a, b), a), a, N). -->
```prolog
%!  apariciones(+Termino, @S, -N:integer) is det.
%
%   N es la cantidad de subtérminos de Termino idénticos (==) a S.
apariciones(T, S, N) :-
    aggregate_all(count, ( sub_term(X, T), X == S ), N).
```

```prolog
?- apariciones(f(a, g(a, b), a), a, N).
N = 3.

?- apariciones(f(X, g(Y, X)), X, N).
N = 2.
```

El encabezado es `apariciones(+Termino, @S, -N:integer) is det`. Termino es
`+` porque se recorre y debe estar ligado en lo que interesa: con Termino libre,
la respuesta es 1 si S es esa misma variable y 0 si no, que no es un error pero
tampoco un uso razonable. S es `@`: se compara con `==` y no se liga nunca, y
puede ser una variable, como en la segunda consulta. N es `-`, y con N ligada
el predicado compara la cuenta. Es `det` porque `aggregate_all/3` con `count`
da siempre exactamente una respuesta, también 0.

## 8

<!-- ejemplo: capitulo-32/soluciones.pl predicado: variantes/2 consulta: variantes(f(X, Y, X), f(A, B, A)). -->
```prolog
%!  variantes(@A, @B) is semidet.
%
%   A y B son iguales salvo el nombre de sus variables. No liga nada.
variantes(A, B) :-
    \+ \+ ( copy_term(A-B, CA-CB),
            numbervars(CA, 0, _),
            numbervars(CB, 0, _),
            CA == CB ).
```

```prolog
?- variantes(f(X, Y, X), f(A, B, A)).
true.

?- variantes(f(X, Y), f(A, A)).
false.
```

Las dos copias se hacen en un solo `copy_term/2`, sobre el par `A-B`, para que
una variable que aparece en los dos términos siga siendo la misma en las dos
copias. `numbervars/3` nombra las variables de cada copia en el orden en que
aparecen, y dos variantes quedan idénticas. La doble negación deshace las
ligaduras de `numbervars/3`: `variantes/2` no liga nada.

## 9

<!-- ejemplo: capitulo-32/soluciones.pl predicado: a_limpia/2 limpia/2 valor/3 consulta: a_limpia(x * 2 + y, L), valor(L, [x-3, y-1], V). -->
```prolog
%!  a_limpia(+Expresion, -Limpia) is det.
%
%   Limpia es la Expresion cerrada escrita con los functores num/1, inc/1,
%   suma/2, resta/2 y producto/2. Produce un error de instanciación si
%   Expresion tiene variables, y un error de dominio si contiene otra
%   operación.
a_limpia(E, L) :-
    must_be(ground, E),
    limpia(E, L).

%!  limpia(+Expresion, -Limpia) is det.
%
%   Como a_limpia/2, sin verificar que Expresion es cerrada.
limpia(E, L) :-
    (   number(E)
    ->  L = num(E)
    ;   atom(E)
    ->  L = inc(E)
    ;   E = A + B
    ->  L = suma(LA, LB),
        limpia(A, LA),
        limpia(B, LB)
    ;   E = A - B
    ->  L = resta(LA, LB),
        limpia(A, LA),
        limpia(B, LB)
    ;   E = A * B
    ->  L = producto(LA, LB),
        limpia(A, LA),
        limpia(B, LB)
    ;   domain_error(expresion, E)
    ).

%!  valor(+Limpia, +Valores:list(pair), ?V) is semidet.
%
%   V es el valor de la expresión Limpia con las incógnitas de Valores,
%   pares Incognita-Valor. Falla si una incógnita no tiene valor.
valor(num(N), _, N).
valor(inc(X), Valores, V) :-
    memberchk(X-V, Valores).
valor(suma(A, B), Valores, V) :-
    valor(A, Valores, VA),
    valor(B, Valores, VB),
    V is VA + VB.
valor(resta(A, B), Valores, V) :-
    valor(A, Valores, VA),
    valor(B, Valores, VB),
    V is VA - VB.
valor(producto(A, B), Valores, V) :-
    valor(A, Valores, VA),
    valor(B, Valores, VB),
    V is VA * VB.
```

```prolog
?- a_limpia(x * 2 + y, L), valor(L, [x-3, y-1], V).
L = suma(producto(inc(x), num(2)), inc(y)),
V = 7.
```

Es el [Patrón 44](../patrones.md#44-representacion-limpia) aplicado a las expresiones. `a_limpia/2` es el único
lugar con pruebas de tipo, y las aplica a una expresión que `must_be/2`
garantiza cerrada. `valor/3` elige cada caso por el functor, en la cabeza, y
da una respuesta o ninguna: una incógnita sin valor falla, porque `memberchk/2`
falla. La expresión es `+`: con ella libre, la primera respuesta es `num(V)`, y
al retroceder, la cláusula de la suma evalúa sumandos libres y produce un error de
instanciación.

## 10

<!-- ejemplo: capitulo-32/soluciones_experto.pl predicado: preguntables/1 atomos/2 agregar_atomo/3 consulta: preguntables(Ps). -->
```prolog
%!  preguntables(-Preguntables:list(atom)) is det.
%
%   Preguntables es el conjunto ordenado de los átomos que aparecen en las
%   condiciones de alguna regla y no son la conclusión de ninguna.
preguntables(Preguntables) :-
    findall(C, regla(_, si C entonces _), Condiciones),
    atomos(Condiciones, EnCondiciones),
    findall(Conclusion, regla(_, si _ entonces Conclusion), Conclusiones0),
    sort(Conclusiones0, Conclusiones),
    ord_subtract(EnCondiciones, Conclusiones, Preguntables).

%!  atomos(+Termino, -Atomos:list(atom)) is det.
%
%   Atomos es el conjunto ordenado de los átomos que aparecen en Termino.
atomos(T, Atomos) :-
    foldsubterms(agregar_atomo, T, [], Atomos).

%!  agregar_atomo(+Subtermino, +Conjunto0:list, -Conjunto:list) is semidet.
%
%   Conjunto es Conjunto0 con Subtermino agregado. Falla si Subtermino no
%   es un átomo, y entonces foldsubterms/4 sigue por sus argumentos.
agregar_atomo(X, Conjunto0, Conjunto) :-
    atom(X),
    ord_add_element(Conjunto0, X, Conjunto).
```

```prolog
?- preguntables(Ps).
Ps = [color_leonado, come_carne, cuello_largo, da_leche, manchas_oscuras, nada, no_vuela, pone_huevos, rayas_negras|...].
```

El toplevel abrevia la lista; tiene trece átomos, y los cuatro últimos son
`tiene_cascos`, `tiene_pelo`, `tiene_plumas` y `vuela`. La solución reúne en
una lista las condiciones de todas las reglas y le aplica `atomos/2`, de la
[sección 32.4](index.md#324-recorrer-cualquier-termino): los operadores `si`, `entonces` e `y` son functores, no
subtérminos, y no aparecen. `peso(P)` y `P > 50` no aportan átomos. A ese
conjunto se le restan las conclusiones con `ord_subtract/3`.

## 11

<!-- ejemplo: capitulo-32/soluciones_simplificar.pl fragmento: regla(N * X + X, P * X) :- .. regla(X + X, 2 * X). consulta: simplificar(2 * x + (y - y) * z + x ^ 1, E). -->
```prolog
regla(N * X + X, P * X) :-
    number(N),
    P is N + 1.
regla(X + N * X, P * X) :-
    number(N),
    P is N + 1.
regla(N * X + M * X, P * X) :-
    number(N),
    number(M),
    P is N + M.
regla(X + X, 2 * X).
```

```prolog
?- simplificar(2 * x + (y - y) * z + x ^ 1, E).
E = 3*x.
```

Las tres reglas van antes de `regla(X + X, 2 * X)`, en el mismo predicado.
La simplificación termina porque cada regla que se aplica deja un término con
menos nodos, o con los mismos y un número a la izquierda de un producto:
`X * N` pasa a `N * X`, y `X + X` con X atómica pasa a `2 * X`. Ninguna regla
deshace ese cambio, y las tres nuevas reemplazan dos productos y una suma por
un solo producto: reducen el término.

## 12

<!-- ejemplo: capitulo-32/soluciones.pl predicado: evaluar/3 valor_de/3 consulta: evaluar(x * x + y, [x-3, y-1], V). -->
```prolog
%!  evaluar(+Expresion, +Valores:list(pair), -V:number) is det.
%
%   V es el valor de la Expresion cerrada con cada incógnita reemplazada por
%   su valor en Valores, pares Incognita-Valor. Una incógnita sin valor
%   produce existence_error(incognita, X).
evaluar(E, Valores, V) :-
    must_be(ground, E),
    mapsubterms(valor_de(Valores), E, E1),
    V is E1.

%!  valor_de(+Valores:list(pair), +X, -V) is semidet.
%
%   V es el valor de la incógnita X en Valores. Falla si X no es un átomo, y
%   entonces mapsubterms/3 sigue por sus argumentos.
valor_de(Valores, X, V) :-
    atom(X),
    (   memberchk(X-V0, Valores)
    ->  V = V0
    ;   existence_error(incognita, X)
    ).
```

```prolog
?- evaluar(x * x + y, [x-3, y-1], V).
V = 10.

?- evaluar(x * z, [x-3], V).
ERROR: incognita `z' does not exist
ERROR: In:
ERROR:   [21] throw(error(existence_error(incognita,z),_228))
```

`mapsubterms/3` reemplaza cada átomo por su valor; donde `valor_de/3` falla
—un número, un compuesto—, sigue por los argumentos. Una incógnita sin valor
produce el error de existencia de la [sección 25.4](../capitulo-25-errores-y-excepciones/index.md#254-throw1-must_be2-y-libraryerror), no un `false.`
que se confundiría con «la expresión no tiene valor».

## 13

<!-- ejemplo: capitulo-32/soluciones_simplificar.pl predicado: derivar/3 derivada/3 consulta: derivar(x ^ 2 + 3 * x, x, D). -->
```prolog
%!  derivar(+E, +X:atom, -D) is det.
%
%   D es la derivada de la expresión cerrada E respecto de la incógnita X,
%   simplificada. E usa +, -, * y ^ con exponente numérico.
derivar(E, X, D) :-
    must_be(ground, E),
    must_be(atom, X),
    derivada(E, X, D0),
    simplificar(D0, D).

%!  derivada(+E, +X:atom, -D) is det.
%
%   D es la derivada de E respecto de X, sin simplificar. Produce un error
%   de dominio si E contiene otra operación.
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
    ;   E = U * V
    ->  D = DU * V + U * DV,
        derivada(U, X, DU),
        derivada(V, X, DV)
    ;   E = U ^ N,
        number(N)
    ->  N1 is N - 1,
        D = N * U ^ N1 * DU,
        derivada(U, X, DU)
    ;   domain_error(expresion_derivable, E)
    ).
```

```prolog
?- derivar(x ^ 2 + 3 * x, x, D).
D = 2*x+3.

?- derivar(x ^ 3, x, D).
D = 3*x^2.
```

`derivada/3` aplica las reglas de derivación con un caso por operación, sobre
una expresión cerrada, y produce términos largos: la derivada de `x ^ 2 + 3 * x`
es `2 * x ^ 1 * 1 + (0 * x + 3 * 1)`. `simplificar/2` la reduce. Una operación
sin regla produce el error de dominio: `derivar(sin(x), x, D)` lo produce,
porque `sin/1`, la función seno de `is/2` (con el argumento en radianes), no
tiene caso en `derivada/3`. El
[capítulo 43](../capitulo-43-proyecto-resolver-ecuaciones/index.md) usa la misma combinación en el método de Newton
([sección 43.6](../capitulo-43-proyecto-resolver-ecuaciones/index.md#436-version-5-el-metodo-de-newton-y-la-comprobacion)), cuando no se puede despejar la incógnita.
