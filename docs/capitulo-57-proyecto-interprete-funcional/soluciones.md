# Soluciones del capítulo 57 — Proyecto: un intérprete funcional

El código de esta página está en `ejemplos/capitulo-57/soluciones.pl`, con
sus pruebas en `soluciones.plt`. Carga el intérprete terminado,
`funcional.pl`, y con él las cinco versiones: `sustitucion.pl`,
`entornos.pl`, `lector.pl`, `perezoso.pl` y `necesidad.pl`. Las soluciones
escritas en Lam son textos, guardados en `definiciones/2`; `lam_con/3` y
`ejecutar_con/3` evalúan una expresión con las definiciones de un
ejercicio, por necesidad y en forma estricta. Como carga otros archivos,
se ejecuta en una instalación local y no en SWISH:

<!-- ejemplo: capitulo-57/soluciones.pl fragmento: :- ensure_loaded(funcional). .. :- ensure_loaded(funcional). -->
```prolog
:- ensure_loaded(funcional).
```

## 1

Por necesidad, las tres primeras expresiones dan un valor:

```prolog
?- lam("(fun x -> 3) (cabeza [])", V).
V = 3.

?- lam("longitud [cabeza [], 2]", V).
V = 2.

?- lam("tomar 1 [1, cabeza []]", V).
V = [1].
```

La función `fun x -> 3` no usa su parámetro, así que la promesa de
`cabeza []` nunca se fuerza. `longitud` suma uno por cada elemento sin
mirarlo: recorre las colas de la lista, pero no fuerza ninguna cabeza.
`tomar 1` construye una lista con la primera cabeza y no llega a la
segunda. Con evaluación estricta, las cuatro producen el mismo error, porque
`cabeza []` se evalúa al construir el argumento o la lista, antes de
cualquier otra cosa:

```text
?- ejecutar("(fun x -> 3) (cabeza [])", V).
ERROR: Type error: `lista_no_vacia' expected, found `[]' (an empty_list)
```

`tomar 2 [1, cabeza []]` produce el mismo error también por necesidad.
`tomar` no fuerza la segunda cabeza, pero la deja en el resultado, y
`ejecutar_perezoso/4` fuerza con `forzar_todo/3` todos los elementos de la
lista que devuelve para escribirla. El error aparece al mostrar el valor,
no al calcularlo.

## 2

El dato cambia antes de llegar a la lambda. `aplicar_lambdas/3` evalúa
cada argumento de `map` antes de sustituirlo, y el segundo es la lista
`[inc]`: la cláusula de las listas de `valor/2` evalúa cada elemento, e
`inc` es un átomo con un hecho `funcion(inc, ...)`, así que la sexta
cláusula lo evalúa a la lambda de `suma@[1]`. `map` recibe ya la lista
`[lambda(...)]`, y la lambda del ejercicio la envuelve en otra lista. El
dato se convierte en función porque en la versión 1 un argumento es
siempre una expresión que se evalúa, y un átomo es una expresión cuando
tiene definición.

Un dato `par`, sin definición, llega hasta la última cláusula y queda como
está; un dato `cuadrado` se evalúa a su lambda:

```prolog
?- valor(map@[lambda(X, [X]), [par, cuadrado]], V).
V = [[par], [lambda(_A, producto@[_A, _A])]].
```

 La clase de un término depende de un hecho
que está en otra parte del programa, y no de su forma: es la representación
«defaulty» que la versión 2 reemplaza por `num/1`, `id/1` y los demás
functores.

## 3

<!-- ejemplo: capitulo-57/soluciones.pl fragmento: definiciones(iterar, "iterar .. definiciones(iterar, "iterar -->
```prolog
definiciones(iterar, "iterar f x = cons x (iterar f (f x))").
```

```prolog
?- lam_con(iterar, "tomar 8 (iterar ((*) 2) 1)", V).
V = [1, 2, 4, 8, 16, 32, 64, 128].

?- call_with_inference_limit(ejecutar_con(iterar, "tomar 8 (iterar ((*) 2) 1)", V), 1000000, R).
R = inference_limit_exceeded.
```

`(*) 2` es la función que duplica. Con evaluación estricta, `iterar`
evalúa `iterar f (f x)` antes de construir la lista, y así sin fin, igual
que `desde` en la [sección 57.4](index.md#574-una-sintaxis-concreta-y-un-preludio).

## 4

<!-- ejemplo: capitulo-57/soluciones.pl fragmento: definiciones(plegados, .. sino a) []"). -->
```prolog
definiciones(plegados,
             "map2 f = plegar_der (fun x a -> cons (f x) a) []; \c
              filtrar2 p = plegar_der \c
                (fun x a -> si p x entonces cons x a sino a) []").
```

```prolog
?- ejecutar_con(plegados, "filtrar2 (fun x -> mod x 2 = 0) (hasta 1 10)", V).
V = [2, 4, 6, 8, 10].

?- lam_con(plegados, "tomar 3 (filtrar2 (fun x -> mod x 2 = 0) (desde 1))", V).
V = [2, 4, 6].
```

`plegar_der f a l` es `f (cabeza l) (plegar_der f a (cola l))`. Por
necesidad, el segundo argumento de `f` es una promesa: la función de
`map2` pone esa promesa como cola de un `cons` sin forzarla, y la de
`filtrar2` la fuerza solo cuando el elemento no pasa el filtro. `tomar 3`
pide tres cabezas, y el plegado avanza solo hasta el elemento que las
produce. En forma estricta, en cambio, `plegar_der` evalúa la llamada
recursiva antes de aplicar `f`, y sobre una lista infinita no termina.
`plegar_izq` no tendría esa propiedad en ningún caso: devuelve el
acumulador recién cuando la lista se termina.

## 5

<!-- ejemplo: capitulo-57/soluciones.pl fragmento: definiciones(sin_lista, .. cuantos p = componer longitud (filtrar p)"). -->
```prolog
definiciones(sin_lista,
             "plegar1 f l = plegar_izq f (cabeza l) (cola l); \c
              maximo = plegar1 (fun a b -> si a > b entonces a sino b); \c
              pares = filtrar (fun x -> mod x 2 = 0); \c
              cuantos p = componer longitud (filtrar p)").
```

```prolog
?- lam_con(sin_lista, "maximo [3, 1, 4, 1, 5, 9, 2, 6]", V).
V = 9.

?- lam_con(sin_lista, "pares (hasta 1 10)", V).
V = [2, 4, 6, 8, 10].

?- lam_con(sin_lista, "cuantos (fun x -> x > 2) [1, 5, 3, 2]", V).
V = 2.

?- lam("suma", V).
V = clausura(l, si(ap(id(vacia), id(l)), id(a), ap(ap(ap(id(plegar_izq), id(f)), ap(ap(id(f), id(a)), ap(id(cabeza), id(l)))), ap(id(cola), id(l)))), [a-memo(num(0), [], _), f-memo(id(+), [], _)]).
```

`suma` es `plegar_izq` aplicada a dos argumentos: su valor es la clausura
del tercer parámetro, `l`, con el cuerpo de `plegar_izq`, y un entorno que
liga `f` y `a` a las promesas de `(+)` y de `0`, todavía sin forzar: la
variable de cada `memo/3` está libre. `plegar1` recibe la lista, porque la
usa dos veces; las demás no la nombran.

## 6

<!-- ejemplo: capitulo-57/soluciones.pl fragmento: definiciones(cond, .. fact n = cond (n = 0) 1 (n * fact (n - 1))"). -->
```prolog
definiciones(cond,
             "cond c a b = si c entonces a sino b; \c
              fact n = cond (n = 0) 1 (n * fact (n - 1))").
```

```prolog
?- lam_con(cond, "fact 5", V).
V = 120.

?- call_with_inference_limit(ejecutar_con(cond, "fact 5", V), 1000000, R).
R = inference_limit_exceeded.
```

Con evaluación estricta, `cond` recibe sus tres argumentos ya evaluados, y
el tercero es `n * fact (n - 1)`, que llama a `fact` también cuando `n` es
0: la recursión no tiene caso base. Por necesidad, `si` fuerza la
condición y una sola de las dos promesas, y `fact 0` devuelve 1 sin tocar
la otra. Por eso el evaluador estricto necesita que `si` sea una **forma
especial**: una cláusula de `evaluar/4` que evalúa la condición y después
solo la rama elegida. Una primitiva recibe sus argumentos evaluados, y no
podría evitar evaluar las dos ramas.

## 7

<!-- ejemplo: capitulo-57/soluciones.pl fragmento: definiciones(z, .. f fact n = si n = 0 entonces 1 sino n * fact (n - 1)"). -->
```prolog
definiciones(z,
             "z g = (fun x -> g (fun v -> x x v)) \c
                    (fun x -> g (fun v -> x x v)); \c
              f fact n = si n = 0 entonces 1 sino n * fact (n - 1)").
```

```prolog
?- ejecutar_con(z, "z f 10", V).
V = 3628800.
```

En `y`, el argumento de `g` es `x x`, que la evaluación estricta calcula
antes de llamar a `g`, y ese cálculo vuelve a producir `g (x x)`. En `z`, el
argumento es `fun v -> x x v`, una función: evaluarla solo crea una
clausura. `x x` se calcula recién cuando `fact` se aplica a un número, y
para entonces `f` ya comprobó si `n` es 0. `f` no se nombra a sí misma:
recibe la llamada recursiva como su parámetro `fact`.

## 8

<!-- ejemplo: capitulo-57/soluciones.pl predicado: suma_cuadrados_pares/2 -->
```prolog
%!  suma_cuadrados_pares(+N:integer, -S:integer) is det.
%
%   S es la suma de los cuadrados de los números pares de 1 a N, con los
%   predicados de orden superior del capítulo 18.
suma_cuadrados_pares(N, S) :-
    numlist(1, N, L),
    include([X]>>(X mod 2 =:= 0), L, Pares),
    maplist([X, Y]>>(Y is X * X), Pares, Cuadrados),
    foldl([X, A0, A]>>(A is A0 + X), Cuadrados, 0, S).
```

```prolog
?- suma_cuadrados_pares(100, S).
S = 171700.

?- contar(suma_cuadrados_pares(100, _), I0), contar(suma_cuadrados_pares(100, _), I).
I0 = 44940,
I = 2715.

?- T = "suma (map (fun x -> x * x) (filtrar (fun x -> mod x 2 = 0) (hasta 1 100)))", inferencias(estricto, T, I0), inferencias(estricto, T, I).
T = "suma (map (fun x -> x * x) (filtrar (fun x -> mod x 2 = 0) (hasta 1 100)))",
I0 = 39570,
I = 39423.
```

La primera medición de Prolog incluye la carga automática de
`library(yall)` y de `library(apply)` y la compilación de las lambdas; por
eso se mide dos veces. En la segunda, Lam usa unas 15 veces más
inferencias. Cada paso de Lam es una llamada a `evaluar/4` que decide qué
clase de expresión tiene, cada nombre se busca en una lista de pares o de
definiciones, y cada aplicación de `plegar_izq`, `map` o `filtrar` pasa
por una clausura y un entorno nuevo; en Prolog, `foldl/4` llama
directamente a la lambda. El orden de los argumentos también es distinto:
la lambda de `foldl/4` recibe el elemento antes que el acumulador,
`[X, A0, A]`, y la función que recibe `plegar_izq` en Lam, el acumulador
antes que el elemento.

## 9

```prolog
?- evaluar(ap(lam(n, lam(x, ap(ap(id(+), id(x)), id(n)))), num(10)), [], [], V).
V = clausura(x, ap(ap(id(+), id(x)), id(n)), [n-10]).

?- valor(lambda(N, lambda(X, suma@[X, N]))@[10], V).
V = lambda(_A, suma@[_A, 10]).
```

En la versión 2 el cuerpo no cambia: el 10 queda en el entorno de la
clausura, ligado al nombre `n`. En la versión 1, la sustitución lo escribió
dentro del cuerpo, en el lugar de `N`. La clausura es un término cerrado:
se puede comparar con `==`, escribir y volver a leer, y sigue siendo la
misma función. La lambda de la versión 1 tiene una variable de Prolog como
parámetro: al escribirla y volver a leerla se obtiene una variable nueva, y
dos lambdas iguales salvo el nombre de la variable no son `==`.

## 10

<!-- ejemplo: capitulo-57/soluciones.pl predicado: desazucar/2 evaluar_con_rec/2 -->
```prolog
%!  desazucar(+E, -D) is det.
%
%   D es la expresión E con cada searec(F, E1, E2), un «sea» recursivo,
%   reemplazado por sea(F, ap(id(z), lam(F, E1)), E2): F se liga al punto
%   fijo de la función que recibe F y devuelve E1.
desazucar(searec(F, E1, E2), sea(F, ap(id(z), lam(F, D1)), D2)) :-
    !,
    desazucar(E1, D1),
    desazucar(E2, D2).
desazucar(E, D) :-
    compound(E),
    !,
    compound_name_arguments(E, Nombre, Args),
    maplist(desazucar, Args, Ds),
    compound_name_arguments(D, Nombre, Ds).
desazucar(E, E).

%!  evaluar_con_rec(+E, -V) is det.
%
%   V es el valor estricto de la expresión E, que puede tener searec/3,
%   con el preludio y la definición de z del ejercicio 7.
evaluar_con_rec(E, V) :-
    definiciones(z, Texto),
    leer_programa(Texto, Z),
    preludio_leido(Preludio),
    append(Z, Preludio, Prog),
    desazucar(E, D),
    evaluar(D, [], Prog, V).
```

```prolog
?- leer_expresion("fun n -> si n = 0 entonces 1 sino n * f (n - 1)", E), evaluar_con_rec(searec(f, E, ap(id(f), num(5))), V).
E = lam(n, si(ap(ap(id(=), id(n)), num(0)), num(1), ap(ap(id(*), id(n)), ap(id(f), ap(ap(id(-), id(n)), num(1)))))),
V = 120.
```

El encabezado de `desazucar/2` declara `+E, -D` y `det`: la expresión
llega completa, siempre hay exactamente un resultado, y los cortes hacen
que la segunda cláusula no se pruebe después de la primera ni la tercera
después de la segunda. La primera cláusula reconoce el `searec/3` antes que
el recorrido genérico, que de otro modo lo copiaría sin cambios; la
segunda recorre cualquier otro término compuesto con
`compound_name_arguments/3`, y la tercera deja los átomos y los números
como están. `desazucar/2` no evalúa nada: es una traducción de sintaxis a
sintaxis, y el evaluador de la versión 2 no necesita ninguna cláusula
nueva. `lam(F, D1)` es la función que recibe «la llamada recursiva» y
devuelve el cuerpo; `z` la convierte en la función recursiva.

## 11

<!-- ejemplo: capitulo-57/soluciones.pl fragmento: % prometer/4, declarada en perezoso.pl: dos modos .. flag(evaluaciones, N, N). -->
```prolog
% prometer/4, declarada en perezoso.pl: dos modos que cuentan cuántas
% veces se evalúa una promesa.
prometer(contado_nombre, E, Ent, contada(E, Ent)).
prometer(contado_necesidad, E, Ent, contada(E, Ent, _)).

% forzar/3, declarada en perezoso.pl: cada evaluación de una promesa
% contada suma uno al contador evaluaciones.
forzar(contada(E, Ent), Ctx, V) :-
    flag(evaluaciones, N, N + 1),
    valor_perezoso(E, Ent, Ctx, V).
forzar(contada(E, Ent, Valor), Ctx, V) :-
    (   nonvar(Valor)
    ->  V = Valor
    ;   flag(evaluaciones, N, N + 1),
        valor_perezoso(E, Ent, Ctx, V),
        Valor = V
    ).

%!  evaluaciones(+Modo, +Texto, -N:integer) is det.
%
%   N es la cantidad de promesas que se evalúan al calcular la expresión
%   de Texto en el Modo contado_nombre o contado_necesidad.
evaluaciones(Modo, Texto, N) :-
    flag(evaluaciones, _, 0),
    ejecutar_perezoso(Modo, Texto, "", _),
    flag(evaluaciones, N, N).
```

```prolog
?- evaluaciones(contado_nombre, "nesimo 10 fibs", N).
N = 2539.

?- evaluaciones(contado_necesidad, "nesimo 10 fibs", N).
N = 179.

?- evaluaciones(contado_nombre, "nesimo 15 fibs", N).
N = 26925.

?- evaluaciones(contado_necesidad, "nesimo 15 fibs", N).
N = 269.
```

Por necesidad, pasar de 10 a 15 agrega 90 evaluaciones, 18 por elemento
de `fibs`: crecimiento lineal. Por nombre, el cociente es 10,6 para cinco
elementos más, alrededor de 1,6 por elemento, la razón entre dos números
de Fibonacci consecutivos. Los dos modos nuevos son cláusulas de
`prometer/4` y de `forzar/3` en otro archivo, posibles porque las dos se
declaran `multifile` en `perezoso.pl`; el evaluador no cambia.

## 12

```prolog
?- numlist(1, 400, L), contar(valor(map@[inc, L], _), A), contar(ejemplo(ap(ap(id(map), id(inc)), id(l)), [l-L], _), B).
L = [1, 2, 3, 4, 5, 6, 7, 8, 9|...],
A = 831255,
B = 47419.
```

Con 100, 200 y 400 elementos, la versión 1 usa 57 855, 215 655 y 831 255
inferencias, y la versión 2, 12 019, 23 819 y 47 419: al duplicar la lista,
la primera se multiplica por casi 4 y la segunda por 2. `map` no tiene
acumulador, pero su cuerpo nombra la lista `L`, y la sustitución escribe
la lista entera en ese lugar. Cada llamada recursiva recibe `cola@[L]`:
evaluar ese argumento vuelve a recorrer toda la lista que se sustituyó,
con la cláusula de las listas de `valor/2`, y la copia del cuerpo en la
aplicación siguiente la copia otra vez. Con $n$ elementos hay $n$
llamadas, y cada una recorre una lista de hasta $n$ elementos.
