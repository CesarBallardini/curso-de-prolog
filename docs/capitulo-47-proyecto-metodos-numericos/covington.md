# La incógnita como variable de Prolog

Esta página continúa el [capítulo 47](index.md) después de la
[sección 47.8](index.md#478-version-5-un-resolvedor-que-elige-el-metodo), con
la sección [47.9](#479-version-6-la-incognita-como-variable-de-prolog): la
versión 6 del programa, el resolvedor de Covington con la incógnita como
variable de Prolog y su evaluador aritmético. La versión reescribe ese
programa con las herramientas del capítulo: el evaluador `:=/2` de
Covington, con una cláusula por operación; `libre_en/2`, que encuentra la
incógnita dentro de la ecuación; y `resolver_libre/1`, que evalúa la
diferencia entre los dos miembros sobre copias de la ecuación hechas con
`copy_term/2`, en lugar de agregar una cláusula con `assert`, y aplica la
secante desde 1 y 2. La sección termina comparando las dos maneras de
escribir la incógnita. Los
ejemplos están en `covington.pl`, en `ejemplos/capitulo-47/`, con sus pruebas;
cargan los programas del [capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md), y se ejecutan localmente.

## 47.9 Versión 6: la incógnita como variable de Prolog

Las cinco versiones anteriores escriben la incógnita como un átomo, `x`, y
la reciben como un argumento aparte. El programa SOLVER.PL de Covington, en
el apartado 7.13 de *Prolog Programming in Depth*, la escribe como una
variable de Prolog: la consulta `solve(X + 1 = 1 / X)` liga X con la raíz,
y se lee como la consulta `X + 1 is 1 / X` que `is/2` no puede responder.
El programa busca la variable dentro de la ecuación, define la diferencia
entre los dos miembros y aplica la secante desde 1 y 2. Esta versión lo
reescribe con las herramientas del capítulo, junto con el evaluador
aritmético que el mismo apartado presenta en la figura 7.9.

### Un evaluador con una cláusula por operación

Covington escribe un sustituto de `is/2` con el operador `:=`, que
SWI-Prolog ya declara (prioridad 800, `xfx`), de modo que no hace falta una
directiva `op/3`. Cada operación es una cláusula, y la indexación por el
functor elige la que corresponde. La versión del curso separa el caso del
número, para que ninguna consulta deje alternativas pendientes, y convierte
en errores lo que el original resuelve escribiendo un mensaje y fallando:

<!-- ejemplo: capitulo-47/covington.pl fragmento: %!  :=(-Valor .. V is 1 / VX. -->
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
[capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md): agregar una
operación es agregar una cláusula, lo que pide el
[ejercicio 13](#ejercicios).

### Encontrar la incógnita

`free_in/2` de Covington recorre la ecuación con `=..` hasta encontrar una
variable libre. `libre_en/2` hace lo mismo con `arg/3`, que enumera los
argumentos de un término compuesto al reintentarse, y da una respuesta por
aparición:

<!-- ejemplo: capitulo-47/covington.pl predicado: libre_en/2 -->
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

### La diferencia sin `assert`

Covington define la función *Dif* agregando al programa una cláusula,
`dif(X, Dif) :- Dif is Left - Right`, con `abolish/1` y `assert/1`; cada
llamada a `dif/2` usa una copia nueva de la cláusula, y por eso puede
evaluar la diferencia en muchos puntos aunque X siga libre en la ecuación.
`copy_term/2` obtiene la misma copia sin modificar el programa: copia el par
formado por la incógnita y la diferencia, y unifica la copia de la
incógnita con el punto. (El nombre `dif/2` designa además, en SWI-Prolog,
la restricción de desigualdad del
[capítulo 24](../capitulo-24-programacion-con-restricciones/index.md); esa es
otra razón para no definir un predicado con ese nombre.)

<!-- ejemplo: capitulo-47/covington.pl predicado: resolver_libre/1 diferencia_en/4 paso_libre/6 -->
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
[sección 47.4](index.md#474-version-2-la-secante), con `diferencia_en/4` en lugar de
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
[sección 47.4](index.md#474-version-2-la-secante). En la cuarta, `libre_en/2` elige
X, la primera variable, y la Y que queda libre hace fallar la evaluación con
un error de instanciación.

### Las dos maneras de escribir la incógnita

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
`copy_term/2`, y el [ejercicio 14](#ejercicios) lo aprovecha para dar a la
versión de Covington los métodos de `resolver/5`.

!!! question "Actividad"
    Predecir qué responden `resolver_libre(X = X + 1)` y
    `resolver_libre(sin(X) = 0.01)`, los ejercicios 7.13.2 y el tercer fallo
    de Covington, y comprobarlo. Explicar por qué
    `E = (X * X = 2), resolver_libre(E), resolver_libre(E)` falla en la
    segunda llamada.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; los métodos son `semidet` porque pueden no converger, y lo dicen en el encabezado junto con las condiciones de su fallo |
    | C5 | un intervalo sin cambio de signo y una expresión que no se sabe derivar producen errores de dominio, y un átomo desconocido un error de existencia; la falta de convergencia es un fallo, porque no indica un error en los datos |
    | C6 | todo el programa es puro: el ciclo, los pasos y el resolvedor no tienen estado ni efectos; la tolerancia y el punto de partida son argumentos |
    | C7 | 113 pruebas en siete archivos; los resultados de punto flotante se comparan con una tolerancia, y cada fallo descrito en el texto (los tres de Covington, el ciclo de Newton, la tolerancia inalcanzable, el sistema que diverge) tiene su prueba |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

13. **(2)** Escribir `valor_ampliado/2`, que evalúa como `:=/2` y además la
    potencia `X ^ N` con exponente entero, el opuesto `-X` y `sqrt/1`.
    Evaluar `sqrt(2 ^ 2 * 4) - -1` y `2 ^ -1`, y explicar por qué no basta
    con agregar tres cláusulas a `operacion/2`.
14. ★ **(2)** Escribir `resolver_variable(Ecuacion, Metodo)`, que recibe la
    ecuación con la incógnita como variable, como `resolver_libre/1`, la
    reemplaza en una copia por un átomo que no aparece en la ecuación y
    aplica `resolver/5` desde 1. Comparar sus respuestas con las de
    `resolver_libre/1` para `X * X = X * 3` y `X + 1 = 1 / X`.

## Resumen

| | |
|---|---|
| **método iterativo** | produce una sucesión de aproximaciones, cada una a partir de la anterior, que se acerca a la solución |
| **paso** | el cálculo de un método que da el estado siguiente, su aproximación y el cambio; `iterar/4` lo repite |
| **tolerancia** | el cambio máximo entre dos aproximaciones para detenerse; no puede ser menor que la distancia entre flotantes cerca de la raíz |
| **límite de pasos** | convierte la falta de convergencia en un fallo |
| **bisección** | parte un intervalo con cambio de signo; siempre converge, un bit por paso |
| **secante** | la recta por los dos últimos puntos; no necesita intervalo, puede no converger |
| **Newton** | la recta tangente, con la derivada exacta; convergencia cuadrática en una raíz simple |
| **raíz doble** | la derivada se anula en la raíz; Newton converge solo linealmente |
| **Gauss–Seidel** | cada incógnita se despeja de su ecuación con los valores más recientes; converge con diagonal dominante |
| `funcion/2`, `valor_en/4` | la ecuación como término y su valor en un punto, con la evaluación del [capítulo 33](../capitulo-33-inspeccion-de-terminos/index.md) |
| `iterar/4`, `maximo_de_pasos/1` | el ciclo común de los métodos |
| `biseccion/4,5`, `secante/4,5`, `newton/4,5` | los tres métodos para una ecuación; la versión de cinco argumentos da todas las aproximaciones |
| `gauss_seidel/3,5`, `barrido/5` | el método para sistemas lineales |
| `resolver/5`, `derivable/1` | el resolvedor que elige el método |
| `errores/3` | la distancia de cada aproximación al valor exacto |
| `:=/2`, `valor_c/2` | el evaluador de Covington, con una cláusula por operación |
| `libre_en/2`, `resolver_libre/1` | la incógnita como variable de Prolog, encontrada en la ecuación y ligada con la raíz |
| `nexttoward/2` | la función aritmética que da el flotante vecino en una dirección |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Las matrices como listas de listas, con aritmética exacta | [capítulo 48](../capitulo-48-proyecto-aritmetica-racional-matrices/index.md) |
| Un perceptrón entrenado por iteración, con su curva de aprendizaje | [capítulo 70](../capitulo-70-proyecto-perceptron/index.md) |

## Referencias

- Michael A. Covington, Donald Nute y André Vellino, *Prolog Programming in
  Depth*, Prentice Hall, 1997 — apartado 7.13, «Solving equations
  numerically», figuras 7.9 «An expression evaluator in Prolog», 7.10 y
  7.11 «A numerical equation solver».
  [Edición en línea](https://www.covingtoninnovations.com/books/PPID.pdf).
  Esta página toma, para la versión 6, el evaluador `:=`, la búsqueda de la
  incógnita con `free_in/2` y la incógnita como variable de Prolog, con la
  secante sobre la diferencia entre los dos miembros y la ecuación de
  Kepler de sus ejercicios.
- Michael A. Covington, «A numerical equation solver in Prolog»,
  *Computer Language* 6 (10), octubre de 1989, págs. 45–51. Es el artículo
  original del programa SOLVER.PL que reproduce el apartado 7.13 de
  *Prolog Programming in Depth*; no tiene edición en línea.

El código del capítulo es propio, escrito para el curso: la secante es un
paso del ciclo de iteración común, y el barrido de Gauss–Seidel recorre las
filas sin rotar la matriz y se detiene por tolerancia, a diferencia del
programa de Csenki, que rota las filas y hace un número fijo de iteraciones.
