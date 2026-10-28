# El método de Newton y la comprobación

Esta página continúa la página
[La forma normal de un polinomio](forma-normal.md#445-version-4-la-forma-normal-de-un-polinomio)
del [capítulo 44](index.md), con la sección
[44.6](#446-version-5-el-metodo-de-newton-y-la-comprobacion): la versión 5
y final del programa que resuelve
ecuaciones, que agrega un respaldo numérico para lo que los métodos
simbólicos no resuelven y comprueba cada solución en la ecuación original.
El código está en `ecuaciones.pl`, en `ejemplos/capitulo-44/`, con sus
pruebas; carga los módulos de las versiones anteriores y se ejecuta en una
instalación local.

## 44.6 Versión 5: el método de Newton y la comprobación

Para lo que ningún método simbólico resuelve, el **método de Newton** busca
un cero de $f(x) = \mathit{Izq} - \mathit{Der}$: desde un valor $x_0$,
reemplaza la curva por su recta tangente y toma el punto donde esa recta
corta el eje,

$$x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)}$$

hasta que dos valores sucesivos quedan cerca; *Numerical Recipes*, de Press,
Teukolsky, Vetterling y Flannery, lo presenta en el apartado 9.4. La derivada la da `derivar/3`
del [capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md), una sola vez, y los valores `evaluar/3`, en cada paso:

<!-- ejemplo: capitulo-44/ecuaciones.pl predicado: newton/6 valor/4 cerca/2 -->
```prolog
%!  newton(+F, +DF, +X:atom, +X0:number, +N:integer, -R:number) is semidet.
%
%   Como newton/5, con N pasos como máximo.
newton(F, DF, X, X0, N, R) :-
    N > 0,
    valor(F, X, X0, Y),
    valor(DF, X, X0, Pendiente),
    Pendiente =\= 0,
    X1 is X0 - Y / Pendiente,
    (   cerca(X0, X1)
    ->  R = X1
    ;   N1 is N - 1,
        newton(F, DF, X, X1, N1, R)
    ).

%!  valor(+E, +X:atom, +V:number, -Y:number) is semidet.
%
%   Y es el valor de E con X = V. Falla si ese valor no es un número real.
valor(E, X, V, Y) :-
    catch(evaluar(E, [X-V], Y),
          error(evaluation_error(_), _),
          fail).

%!  cerca(+A:number, +B:number) is semidet.
%
%   A y B difieren en menos de una parte en 10^9 del mayor de 1, |A|, |B|.
cerca(A, B) :-
    abs(A - B) =< 1.0e-9 * max(1, max(abs(A), abs(B))).
```

El método falla de tres maneras, las mismas que Covington describe para el
método de la secante: la derivada se anula y la recta tangente no corta el
eje; la iteración no converge, porque no hay raíz o porque cae en un ciclo;
o converge a una raíz distinta de la esperada. `newton/6` falla en los dos
primeros casos, con un máximo de 100 pasos, y `raices/4` prueba cuatro
valores iniciales y conserva las raíces distintas:

<!-- ejemplo: capitulo-44/ecuaciones.pl predicado: raices/4 inicial/1 -->
```prolog
%!  raices(+F, +DF, +X:atom, -Rs:list(number)) is det.
%
%   Rs son las raíces de la expresión F en X que el método de Newton, con
%   la derivada DF, halla desde los valores iniciales: de menor a mayor y
%   sin repetir.
raices(F, DF, X, Rs) :-
    findall(R,
            ( inicial(X0),
              newton(F, DF, X, X0, R) ),
            Rs0),
    distintos(Rs0, Rs).

% inicial(X0): X0 es uno de los valores desde los que empieza Newton.
inicial(-10).
inicial(-1).
inicial(1).
inicial(10).
```

`resolver/3` de la versión final usa `*->`
([sección 16.2](../capitulo-16-control/index.md#162-y-lo-que-poda)): si un método simbólico da soluciones, son esas; si no
da ninguna, las numéricas. Un error de dominio de `derivar/3` significa que
la expresión tiene una operación que ese predicado no deriva, y entonces el
respaldo numérico no se aplica:

<!-- ejemplo: capitulo-44/ecuaciones.pl predicado: resolver_numerico/3 -->
```prolog
%!  resolver_numerico(+Ecuacion, +X:atom, -Solucion) is nondet.
%
%   Solucion es X = R, con R una raíz de Izq - Der hallada con el método
%   de Newton desde uno de los valores iniciales, de menor a mayor y sin
%   repetir. Falla si derivar/3 no puede derivar Izq - Der.
resolver_numerico(Izq = Der, X, X = R) :-
    F = Izq - Der,
    catch(derivar(F, X, DF),
          error(domain_error(expresion_derivable, _), _),
          fail),
    raices(F, DF, X, Rs),
    member(R, Rs).
```

```prolog
?- newton(x ^ 3 - 2 * x - 5, x, 1, R).
R = 2.0945514815423265.

?- resolver(x ^ 3 - 2 * x - 5 = 0, x, S).
S = (x=2.0945514815423265).

?- resolver(cos(x) = x, x, S).
false.
```

La última ecuación tiene una raíz cerca de 0.739, pero `derivar/3` no deriva
`cos/1`. El ejercicio 9 amplía la derivada, y el
[capítulo 47](../capitulo-47-proyecto-metodos-numericos/index.md) desarrolla métodos que no la necesitan.

Por último, `valores/3` calcula el valor de cada solución y conserva las que
cumplen la ecuación original, que es la comprobación que la versión 3
necesitaba:

<!-- ejemplo: capitulo-44/ecuaciones.pl predicado: valores/3 cumple/3 -->
```prolog
%!  valores(+Ecuacion, +X:atom, -Vs:list(number)) is det.
%
%   Vs son los valores de las soluciones de resolver/3 que son números
%   reales y cumplen la Ecuacion, de menor a mayor y sin repetir.
valores(Ecuacion, X, Vs) :-
    findall(V,
            ( resolver(Ecuacion, X, X = E),
              catch(V is E, error(evaluation_error(_), _), fail),
              cumple(Ecuacion, X, V) ),
            Vs0),
    distintos(Vs0, Vs).

%!  cumple(+Ecuacion, +X:atom, +V:number) is semidet.
%
%   Los dos lados de la Ecuacion tienen valores reales y cercanos con
%   X = V.
cumple(Izq = Der, X, V) :-
    valor(Izq, X, V, A),
    valor(Der, X, V, B),
    cerca(A, B).
```

```prolog
?- valores(x ^ 2 + 1 = 0, x, Vs).
Vs = [].
```

`x ^ 2 + 1 = 0` se aísla en `x = sqrt(-1)` y `x = -sqrt(-1)`, dos
soluciones simbólicas sin valor real: `is/2` produce un error de evaluación,
`valores/3` lo captura y las descarta. Un error es la respuesta correcta de
`is/2`, y `valores/3` es el borde que lo convierte en «no es una solución
real».

Las secciones 44.7 a 44.11 agregan cinco partes de PRESS que las versiones
anteriores no tienen; cada una es un módulo propio que carga la versión 5.
El capítulo continúa en la página
[Más métodos de PRESS](press.md#447-la-homogeneizacion-trigonometrica),
con la primera de ellas.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos. Los
ejercicios que extienden el programa lo hacen desde un archivo propio, con
las cláusulas `multifile` de `axioma/3` y `regla/3`, o con un predicado que
prueba su método y usa `resolver/3` si no se aplica.

7. ★ **(2)** Agregar a la atracción `exp(U) / exp(V) ~> exp(U - V)` y la
   regla del cociente de dos potencias de la misma base. Predecir qué dan
   `resolver/3` y `valores/3` de `ecuaciones.pl` para
   `exp(2 * x) / exp(x) = 5` y para `3 ^ (x + 2) / 3 ^ x = 9`, y explicar la
   segunda: ¿qué ecuación queda, y cuáles son sus soluciones?
8. **(2)** Escribir `resolver_factores/3`, el método de factorización de
   Sterling y Shapiro: una ecuación `A * B = 0` se cumple si un factor que
   contiene la incógnita vale 0. Resolver `cos(x) * (1 - 2 * sin(x)) = 0` y
   `x * (x ^ 2 - 4) = 0`, que `resolver/3` no resuelve o resuelve con
   Newton.
9. ★ **(2)** Escribir `derivar_mas/3`, una derivada que agrega el cociente,
   el signo menos, `sin/1`, `cos/1`, `exp/1` y `log/1` a las reglas del
   [capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md), y `resolver_mas/3`, que usa `resolver/3` y, si no da
   soluciones, las raíces de `raices/4` con esa derivada. Resolver
   `cos(x) = x` y `x + 1 = 1 / x`.
10. **(2)** Escribir `pasos_newton(F, X, X0, N, Xs)`: Xs son los primeros
    valores que recorre Newton desde X0, como máximo N pasos. Predecir y
    comprobar los pasos de `x ^ 3 - 2 * x + 2` desde 0 y desde 10, de
    `x ^ 2 + 1` desde 1 y de `x ^ 2 - 2` desde 0, y relacionar cada uno con
    las formas de fallar de la [sección 44.6](#446-version-5-el-metodo-de-newton-y-la-comprobacion).
11. **(2)** Escribir `sistema(E1, E2, X, Y, S)`, que resuelve dos ecuaciones
    en dos incógnitas por sustitución: despeja X de E1, con Y como una
    constante más, la reemplaza en E2 y resuelve en Y. Resolver
    `x + y = 3, x - y = 1` y `x + y = 5, x * y = 6`. ¿Qué pasa con la
    segunda si se escriben las ecuaciones en el otro orden?
12. **(3)** El aislamiento exige una sola aparición, pero puede aplicarse
    hasta el menor subtérmino que contiene todas. Escribir
    `aislar_parcial/3`, que aísla ese subtérmino como si fuera una
    incógnita, y un despachador que lo use. Agregar la atracción
    `sqrt(U) * sqrt(V) ~> sqrt(U * V)` y resolver
    `sqrt(x) * sqrt(x + 5) = 6`. ¿Cuál de las soluciones cumple la ecuación?

## Referencias

- Michael A. Covington, Donald Nute y André Vellino, *Prolog Programming in
  Depth*, Prentice Hall, 1997 — apartado 7.13, «Solving equations
  numerically». [Edición en línea](https://www.covingtoninnovations.com/books/PPID.pdf).
  Esta página toma la búsqueda de un cero de `Izq - Der` como respaldo
  numérico, la enumeración de sus formas de fallar, que el apartado
  describe para el método de la secante, y las ecuaciones `cos(x) = x` y
  `x + 1 = 1 / x` del ejercicio 9.
- William H. Press, Saul A. Teukolsky, William T. Vetterling y Brian P.
  Flannery, *Numerical Recipes: The Art of Scientific Computing*, 3.ª
  edición, Cambridge University Press, 2007 — apartado 9.4,
  «Newton-Raphson Method Using Derivative».
  [Lectura en línea de los autores](https://numerical.recipes/book.html).
  Covington remite a esta obra para métodos mejores que la secante; esta
  página toma de allí el método de Newton y sus fallas: la derivada nula,
  los ciclos y la convergencia a otra raíz.
- William F. Clocksin y Christopher S. Mellish, *Programming in Prolog*,
  5.ª edición, Springer, 2003 — apartado 7.11, «Symbolic Differentiation».
  Es el origen de la derivada simbólica del
  [capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md), que el
  método de Newton usa.
- Leon Sterling, Alan Bundy, Lawrence Byrd, Richard O'Keefe y Bernard
  Silver, «Solving symbolic equations with PRESS», en *Computer Algebra
  (EUROCAM '82)*, Lecture Notes in Computer Science 144, Springer, 1982,
  pp. 109–116. [Copia de acceso abierto](https://era.ed.ac.uk/handle/1842/4475).
  Esta página toma de allí el descarte de las raíces espurias.
- Leon Sterling y Ehud Shapiro, *The Art of Prolog: Advanced Programming
  Techniques*, 2.ª edición, MIT Press, 1994 — «An Equation Solver».
  1.ª edición (1986) en [préstamo en el Internet Archive](https://archive.org/details/artofprologadvan00ster).
  De allí vienen los métodos de factorización y de homogeneización de los
  ejercicios 8 y 5.
- Alan Bundy y Bernard Silver, «Homogenization: Preparing Equations for
  Change of Unknown», *Proceedings of the Seventh International Joint
  Conference on Artificial Intelligence (IJCAI-81)*, 1981, pp. 551–553.
  [Edición en línea](https://www.ijcai.org/Proceedings/81-1/Papers/099.pdf).
  Describe la homogeneización —el conjunto de términos que impiden que la
  ecuación sea algebraica, el término reducido y el cambio de incógnita—
  que el ejercicio 5 escribe para el caso exponencial.
