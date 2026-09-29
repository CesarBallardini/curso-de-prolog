# El método de Newton y la comprobación

Esta página contiene la sección
[43.6](index.md#436-version-5-el-metodo-de-newton-y-la-comprobacion) del
[capítulo 43](index.md): la versión 5 y final del programa que resuelve
ecuaciones, que agrega un respaldo numérico para lo que los métodos
simbólicos no resuelven y comprueba cada solución en la ecuación original.
El código está en `ecuaciones.pl`, en `ejemplos/capitulo-43/`, con sus
pruebas; carga los módulos de las versiones anteriores y se ejecuta en una
instalación local.

## El método de Newton y la comprobación

Para lo que ningún método simbólico resuelve, el **método de Newton** busca
un cero de $f(x) = \mathit{Izq} - \mathit{Der}$: desde un valor $x_0$,
reemplaza la curva por su recta tangente y toma el punto donde esa recta
corta el eje,

$$x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)}$$

hasta que dos valores sucesivos quedan cerca. La derivada la da `derivar/3`
del [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md), una sola vez, y los valores `evaluar/3`, en cada paso:

<!-- ejemplo: capitulo-43/ecuaciones.pl predicado: newton/6 valor/4 cerca/2 -->
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

<!-- ejemplo: capitulo-43/ecuaciones.pl predicado: raices/4 inicial/1 -->
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
([sección 15.2](../capitulo-15-control/index.md#152-y-lo-que-poda)): si un método simbólico da soluciones, son esas; si no
da ninguna, las numéricas. Un error de dominio de `derivar/3` significa que
la expresión tiene una operación que ese predicado no deriva, y entonces el
respaldo numérico no se aplica:

<!-- ejemplo: capitulo-43/ecuaciones.pl predicado: resolver_numerico/3 -->
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
[capítulo 46](../capitulo-46-proyecto-metodos-numericos/index.md) desarrolla métodos que no la necesitan.

Por último, `valores/3` calcula el valor de cada solución y conserva las que
cumplen la ecuación original, que es la comprobación que la versión 3
necesitaba:

<!-- ejemplo: capitulo-43/ecuaciones.pl predicado: valores/3 cumple/3 -->
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
