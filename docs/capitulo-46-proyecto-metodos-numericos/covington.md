# La incógnita como variable de Prolog

Esta página contiene la sección [46.9](index.md#469-version-6-la-incognita-como-variable-de-prolog) del [capítulo 46](index.md): la versión 6 del programa, el resolvedor de
Covington con la incógnita como variable de Prolog y su evaluador aritmético. Los
ejemplos están en `covington.pl`, en `ejemplos/capitulo-46/`, con sus pruebas;
cargan los programas del [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md), y se ejecutan localmente.

## La incógnita como variable de Prolog

Las cinco versiones anteriores escriben la incógnita como un átomo, `x`, y
la reciben como un argumento aparte. El programa SOLVER.PL de Covington, en
el apartado 7.13 de *Prolog Programming in Depth*, la escribe como una
variable de Prolog: la consulta `solve(X + 1 = 1 / X)` liga X con la raíz,
y se lee como la consulta `X + 1 is 1 / X` que `is/2` no puede responder.
El programa busca la variable dentro de la ecuación, define la diferencia
entre los dos miembros y aplica la secante desde 1 y 2. Esta versión lo
reescribe con las herramientas del capítulo, junto con el evaluador
aritmético que el mismo apartado presenta en la figura 7.9.

## Un evaluador con una cláusula por operación

Covington escribe un sustituto de `is/2` con el operador `:=`, que
SWI-Prolog ya declara (prioridad 800, `xfx`), de modo que no hace falta una
directiva `op/3`. Cada operación es una cláusula, y la indexación por el
functor elige la que corresponde. La versión del curso separa el caso del
número, para que ninguna consulta deje alternativas pendientes, y convierte
en errores lo que el original resuelve escribiendo un mensaje y fallando:

<!-- ejemplo: capitulo-46/covington.pl fragmento: %!  :=(-Valor .. V is 1 / VX. -->
```prolog
%!  :=(-Valor:number, +Expresion) is det.
%
%   Valor es el valor de Expresion, un término cerrado con números, +, -,
%   *, / y rec/1, el recíproco. Produce un error de instanciación si
%   Expresion tiene variables, y un error de tipo si usa otra operación.
Valor := Expresion :-
    must_be(ground, Expresion),
    (   valor_c(Expresion, Valor0)
    ->  Valor = Valor0
    ;   type_error(expresion_evaluable, Expresion)
    ).

%!  valor_c(+Expresion, -Valor:number) is semidet.
%
%   Valor es el valor de Expresion, un número o una operación. Falla si
%   Expresion usa otra operación.
valor_c(E, V) :-
    (   number(E)
    ->  V = E
    ;   operacion(E, V)
    ).

%!  operacion(+Expresion, -Valor:number) is semidet.
%
%   Valor es el valor de la operación Expresion. Hay una cláusula por
%   operación, y la indexación por el functor del primer argumento elige
%   la que corresponde.
operacion(X + Y, V) :-
    valor_c(X, VX),
    valor_c(Y, VY),
    V is VX + VY.
operacion(X - Y, V) :-
    valor_c(X, VX),
    valor_c(Y, VY),
    V is VX - VY.
operacion(X * Y, V) :-
    valor_c(X, VX),
    valor_c(Y, VY),
    V is VX * VY.
operacion(X / Y, V) :-
    valor_c(X, VX),
    valor_c(Y, VY),
    V is VX / VY.
operacion(rec(X), V) :-
    valor_c(X, VX),
    V is 1 / VX.
```

```prolog
?- R := 2 * rec(4) + 1.
R = 1.5.

?- R := 2 ^ 3.
ERROR: Type error: `expresion_evaluable' expected, found `2^3' (a compound)
ERROR: In:
ERROR:   [14] throw(error(type_error(expresion_evaluable,...),_13732))
```

`is/2` ya hace todo esto, y más rápido. Lo que el evaluador muestra es que la
evaluación aritmética es una relación más, definida por casos sobre la forma
del término, como `evaluar/3` del
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md): agregar una
operación es agregar una cláusula, lo que pide el
[ejercicio 13](index.md#ejercicios).

## Encontrar la incógnita

`free_in/2` de Covington recorre la ecuación con `=..` hasta encontrar una
variable libre. `libre_en/2` hace lo mismo con `arg/3`, que enumera los
argumentos de un término compuesto al reintentarse, y da una respuesta por
aparición:

<!-- ejemplo: capitulo-46/covington.pl predicado: libre_en/2 -->
```prolog
%!  libre_en(+Termino, -X) is nondet.
%
%   X es una variable libre que aparece en Termino. Da una respuesta por
%   cada aparición, de izquierda a derecha.
libre_en(X, X) :-
    var(X).
libre_en(T, X) :-
    compound(T),
    arg(_, T, A),
    libre_en(A, X).
```

```prolog
?- libre_en(f(A, g(B, A)), V).
A = V ;
B = V ;
A = V ;
false.
```

`term_variables/2`, predefinido, da la lista de las variables distintas de un
término sin repeticiones; `libre_en/2` muestra el recorrido que hay detrás.

## La diferencia sin `assert`

Covington define la función *Dif* agregando al programa una cláusula,
`dif(X, Dif) :- Dif is Left - Right`, con `abolish/1` y `assert/1`; cada
llamada a `dif/2` usa una copia nueva de la cláusula, y por eso puede
evaluar la diferencia en muchos puntos aunque X siga libre en la ecuación.
`copy_term/2` obtiene la misma copia sin modificar el programa: copia el par
formado por la incógnita y la diferencia, y unifica la copia de la
incógnita con el punto. (El nombre `dif/2` designa además, en SWI-Prolog,
la restricción de desigualdad del
[capítulo 23](../capitulo-23-programacion-con-restricciones/index.md); esa es
otra razón para no definir un predicado con ese nombre.)

<!-- ejemplo: capitulo-46/covington.pl predicado: resolver_libre/1 diferencia_en/4 paso_libre/6 -->
```prolog
%!  resolver_libre(+Ecuacion) is semidet.
%
%   Ecuacion es Izq = Der con una variable libre, la incógnita, que queda
%   ligada con una raíz. Como el programa de Covington, aplica la secante
%   desde 1 y 2. Falla si Ecuacion no tiene variables o si la secante
%   falla; otra variable libre en Ecuacion produce un error de
%   instanciación.
resolver_libre(Izq = Der) :-
    once(libre_en(Izq = Der, X)),
    F = Izq - Der,
    diferencia_en(X, F, 1.0, F1),
    diferencia_en(X, F, 2.0, F2),
    iterar(paso_libre(X, F), 1.0e-12, secante(1.0, F1, 2.0, F2), Xs),
    last(Xs, X).

%!  diferencia_en(+X, +F, +A:number, -V:float) is det.
%
%   V es el valor de la expresión F cuando su variable X vale A. Evalúa
%   una copia de F, de modo que F y X quedan libres.
diferencia_en(X, F, A, V) :-
    copy_term(X-F, A-F1),
    V is float(F1).

%!  paso_libre(+X, +F, +Estado0, -Estado, -X2:float, -Cambio:float)
%!      is semidet.
%
%   Como paso_secante/6, con la incógnita X como variable de Prolog.
paso_libre(X, F, secante(X0, F0, X1, F1), secante(X1, F1, X2, F2), X2,
           Cambio) :-
    F1 =\= F0,
    X2 is X1 - F1 * (X1 - X0) / (F1 - F0),
    diferencia_en(X, F, X2, F2),
    Cambio is abs(X2 - X1).
```

El paso es el de la secante de la
[sección 46.4](index.md#464-version-2-la-secante), con `diferencia_en/4` en lugar de
`valor_en/4`, y el ciclo es `iterar/4`. Solo al final, con `last/2`, la
incógnita queda ligada con la última aproximación:

```prolog
?- resolver_libre(X + 1 = 1 / X).
X = 0.6180339887498948.

?- E = (X - 0.01 * sin(X) = 2.5), resolver_libre(E).
E = (2.5059370519317916-0.01*sin(2.5059370519317916)=2.5),
X = 2.5059370519317916.

?- resolver_libre(X * X = X * 3).
false.

?- resolver_libre(X + Y = 3).
ERROR: Arguments are not sufficiently instantiated
ERROR: In:
ERROR:   [14] _4496 is float(... - 3)
```

La segunda consulta es la ecuación de Kepler del ejercicio 7.13.1 de
Covington: la ecuación entera queda ligada, porque X aparece en ella. La
tercera es la secante horizontal de la
[sección 46.4](index.md#464-version-2-la-secante). En la cuarta, `libre_en/2` elige
X, la primera variable, y la Y que queda libre hace fallar la evaluación con
un error de instanciación.

## Las dos maneras de escribir la incógnita

| | `resolver/5` | `resolver_libre/1` |
|---|---|---|
| la incógnita | un átomo, dado como argumento | una variable, encontrada con `libre_en/2` |
| el resultado | un número en otro argumento | la incógnita queda ligada |
| la ecuación después | se puede volver a usar | queda instanciada |
| la evaluación | `evaluar/3` reemplaza el átomo | `copy_term/2` copia la ecuación |
| los métodos | Newton, secante y bisección | solo la secante desde 1 y 2 |
| varias incógnitas | se elige cuál resolver | se resuelve la primera; otra libre es un error |

La variable da una consulta más breve y más parecida a la ecuación escrita a
mano, pero la ecuación se consume al resolverla: después de la consulta ya no
tiene incógnita, y para resolverla desde otro punto hay que volver a
escribirla. El átomo separa la ecuación de su solución, y por eso la misma
ecuación pasa sin cambios por `derivar/3`, por la bisección y por la
secante. Las dos representaciones se convierten una en otra con
`copy_term/2`, y el [ejercicio 14](index.md#ejercicios) lo aprovecha para dar a la
versión de Covington los métodos de `resolver/5`.

!!! question "Actividad"
    Predecir qué responden `resolver_libre(X = X + 1)` y
    `resolver_libre(sin(X) = 0.01)`, los ejercicios 7.13.2 y el tercer fallo
    de Covington, y comprobarlo. Explicar por qué
    `E = (X * X = 2), resolver_libre(E), resolver_libre(E)` falla en la
    segunda llamada.
