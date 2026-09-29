# Capítulo 58 — Proyecto: interpretación abstracta

Un intérprete responde qué hace un programa con unos datos. Un **análisis
estático** responde qué hace con todos los datos posibles, sin ejecutarlo
con cada uno: si alguna ejecución divide por cero, si una variable es
siempre positiva al terminar, si una rama del programa puede ejecutarse. La
**interpretación abstracta** obtiene esas respuestas ejecutando el programa
sobre **valores abstractos**, cada uno de los cuales representa un conjunto
de valores concretos: `pos` representa todos los enteros positivos, y el
intervalo de 0 a 10 representa once enteros. Una sola ejecución abstracta
cubre así infinitas ejecuciones concretas.

El proyecto es un analizador de los programas **Mini** del
[capítulo 45](../capitulo-45-proyecto-compilador/index.md). Carga su análisis
sintáctico y su intérprete, sin copiarlos, y crece en cinco versiones: el
intérprete concreto como referencia; la ejecución sobre valores
simbólicos; un intérprete abstracto sobre signos, tabulado, que sigue cada
combinación de signos por separado; otro que guarda un solo estado por
punto del programa y une los estados con la subsunción de respuestas del
[capítulo 39](../capitulo-39-tabulacion/index.md); y el dominio de los
intervalos, que necesita **ensanchamiento** para terminar. Cada versión se
compara con las ejecuciones concretas de una muestra.

El capítulo parte de *Programming in Tabled Prolog* de David S. Warren
([copia de archivo de la página del autor](https://web.archive.org/web/20240628211257/https://www3.cs.stonybrook.edu/~warren/xsbbook/book.html)),
del capítulo «Meta-Programming», secciones «Abstract Interpretation» y «AI
of a Simple Nested Procedural Language». De allí toma el método: escribir
primero el intérprete concreto; cambiar después sus operaciones por
operaciones sobre el dominio abstracto; aceptar que una condición abstracta
no se decide, de modo que el programa determinista se vuelve no
determinista y sigue las dos ramas; y obtener el menor punto fijo de los
estados alcanzables tabulando el intérprete, porque sin tablas cualquier
bucle abstracto se repite sin fin. El programa de Warren está escrito para
XSB y analiza otro lenguaje; aquí el lenguaje es Mini, la tabulación es la
de SWI-Prolog, y el código es propio. La teoría, con los reticulados, los
puntos fijos y el ensanchamiento, es la del artículo de Patrick y Radhia
Cousot de 1977. El capítulo cumple los anuncios de los capítulos
[39](../capitulo-39-tabulacion/index.md) (el análisis estático con tablas),
[45](../capitulo-45-proyecto-compilador/index.md) (el análisis de los
programas Mini) y [50](../capitulo-50-proyecto-fft-simbolica/index.md) (la
ejecución sobre valores simbólicos, que Clocksin llama interpretación
abstracta). Todos los archivos cargan los del [capítulo 45](../capitulo-45-proyecto-compilador/index.md) y corren solo en
una instalación local.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- explicar qué es un dominio abstracto, qué conjunto de enteros representa
  cada valor, y qué significa que un análisis sea correcto respecto de las
  ejecuciones concretas;
- ejecutar un programa sobre valores simbólicos y reconocer por qué sus
  caminos pueden ser infinitos;
- escribir las operaciones de un dominio abstracto como relaciones, y un
  intérprete abstracto con la forma del intérprete concreto;
- hacer terminar el análisis de un bucle tabulando el intérprete, y unir
  los estados de un punto con la subsunción de respuestas `lattice`;
- escribir un dominio de altura infinita con ensanchamiento, y medir lo
  que el análisis pierde con él;
- distinguir lo que un análisis prueba de lo que no puede probar, y
  comprobar sus resultados contra una muestra de ejecuciones.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:30 h**.
    Resolver los 5 ejercicios marcados con ★: **1:10 h**.
    Resolver los 11 ejercicios del final: **3:30 h**.

## 58.1 El analizador terminado

`informe.pl` carga todas las versiones. `informe/1` toma un caso, un
programa Mini con la descripción de sus entradas, y escribe su texto, el
valor de cada variable al terminar según los tres análisis, el rango de
valores de la muestra concreta, las alarmas, y cuántas ejecuciones de la
muestra cubre cada análisis. Sus columnas son las tres versiones del
análisis que siguen: `conjuntos` es el de la
[sección 58.4](#584-signos-un-interprete-abstracto-tabulado), `signos` e
`intervalos` los dos dominios de las secciones
[58.5](#585-un-estado-por-punto-la-union-con-lattice) y
[58.6](#586-intervalos-y-ensanchamiento).

La consulta `informe(cuenta)` escribe, y después responde `true`:

```text
    x := n;
    mientras x > 0 hacer x := x - 1 fin;
    escribir 100 / (x + 1)
entradas: [n-entre(1,sup)]

variable  conjuntos       signos  intervalos      muestra
n         {pos}           pos     i(1,sup)        1..12
x         {cero,neg}      top     i(0,0)          0..0

conjuntos: puede terminar dividiendo por cero
signos: el divisor de 100/(x+1) puede ser cero (top)
signos: cubre 12 de 12 corridas
intervalos: cubre 12 de 12 corridas
```

El programa baja `x` hasta 0 y divide por `x + 1`: con ningún n positivo
divide por cero. Los dos análisis de signos no lo pueden probar, porque
para ellos restar 1 a un positivo puede dar un negativo: dan una **falsa
alarma**. El de intervalos lo prueba: `x` termina en i(0, 0), y el cociente
es exactamente 100. Ninguno se equivoca en sentido contrario: las doce
ejecuciones de la muestra están dentro de lo que cada análisis dice. `informe(cuadrado)` muestra el caso inverso, uno que
solo los conjuntos de signos resuelven:

```text
    y := n * n;
    si y < 0 entonces escribir 0 sino escribir y fin
entradas: [n-entre(inf,sup)]

variable  conjuntos       signos  intervalos      muestra
n         {cero,neg,pos}  top     i(inf,sup)      -6..12
y         {cero,pos}      top     i(inf,sup)      0..144

conjuntos: nunca se ejecuta escribir 0
signos: cubre 19 de 19 corridas
intervalos: cubre 19 de 19 corridas
```

## 58.2 La referencia: el intérprete concreto

Un análisis se juzga contra lo que el programa hace de verdad, y lo que un
programa Mini hace lo define el intérprete de la
[sección 45.3](../capitulo-45-proyecto-compilador/index.md#453-el-interprete).
`concreto.pl` lo carga con `ensure_loaded/1` y le agrega **entradas**:
variables que empiezan con un valor dado en lugar de 0. Un **caso** es un
programa con la descripción de sus entradas, `X-entre(Min, Max)`, donde
`inf` y `sup` indican que el rango no tiene cota. Los dos primeros de los
seis casos son estos:

<!-- ejemplo: capitulo-58/concreto.pl fragmento: % caso(Nombre, .. "escribir f" ]). -->
```prolog
% caso(Nombre, Entradas, Lineas): un programa Mini con entradas, por líneas.
caso(promedio, [n-entre(0, sup)],
     [ "s := 0; i := 0;",
       "mientras i < n hacer",
       "  s := s + i;",
       "  i := i + 1",
       "fin;",
       "escribir s / n" ]).
caso(factorial, [n-entre(0, 10)],
     [ "f := 1;",
       "mientras n > 0 hacer",
       "  f := f * n;",
       "  n := n - 1",
       "fin;",
       "escribir f" ]).
```

`correr_desde/3` arma el entorno inicial con `entorno_inicial/2` y
`actualizar/4` del [capítulo 45](../capitulo-45-proyecto-compilador/index.md), y ejecuta el programa con
`ejecutar_bloque//3`, la gramática del intérprete. La división por cero, que
allí es un error de evaluación, pasa a ser un resultado:

<!-- ejemplo: capitulo-58/concreto.pl predicado: correr_desde/3 -->
```prolog
%!  correr_desde(+Programa:list, +Valores:list, -Resultado) is det.
%
%   Resultado es lo que produce Programa ejecutado con el intérprete del
%   capítulo 45, con las variables de Valores, pares X-N, en N y las demás
%   en 0: fin(Salida, Final), con la salida y el entorno final, o
%   error(division_por_cero). No termina si Programa no termina.
correr_desde(Programa, Valores, Resultado) :-
    entorno_inicial(Programa, E0),
    foldl(fijar, Valores, E0, E1),
    catch(( once(phrase(ejecutar_bloque(Programa, E1, E), Salida)),
            Resultado = fin(Salida, E) ),
          error(evaluation_error(zero_divisor), _),
          Resultado = error(division_por_cero)).
```

```prolog
?- correr_caso(promedio, [n-4], R).
R = fin([1], [i-4, n-4, s-6]).

?- correr_caso(promedio, [n-0], R).
R = error(division_por_cero).
```

`promedio` suma de 0 a n − 1 y divide por n, y con n = 0 divide por cero.
`muestra/2` ejecuta un caso con cada valor de entrada de una **ventana** de
−6 a 12, recortada por el rango de cada entrada: 13 ejecuciones para
`promedio`, 144 para `mcd`, que tiene dos entradas de 1 a 12. La muestra
encuentra la división por cero de `promedio` porque n = 0 está en la
ventana, pero no dice nada de los valores que no incluye. Para afirmar algo
de todas las ejecuciones, el programa tiene que ejecutarse sobre algo que
no sea un número.

## 58.3 Valores simbólicos

Lo más directo es no darle valor a la entrada: `n` vale el átomo `n`, una
**incógnita**, y cada expresión se evalúa a una expresión de Prolog sobre
las incógnitas, simplificada con el simplificador de la
[sección 32.7](../capitulo-32-inspeccion-de-terminos/index.md#327-un-simplificador-de-expresiones).
Es lo que hace el [capítulo 50](../capitulo-50-proyecto-fft-simbolica/index.md)
con los polinomios de la transformada, y lo que Clocksin llama
interpretación abstracta: el programa corre con valores que representan
cualquier dato. Una condición entre expresiones con incógnitas no se puede
decidir, y el intérprete sigue las dos ramas, cada una con la condición
**supuesta**. Cada respuesta es un **camino**:

<!-- ejemplo: capitulo-58/simbolico.pl predicado: sim_sentencia//3 suponer/3 -->
```prolog
%!  sim_sentencia(+Sent, +S0, -S)// is nondet.
%
%   Ejecutar la sentencia Sent sobre valores simbólicos lleva el estado S0
%   a S. Un si o un mientras con una condición que no se decide da una
%   respuesta por rama.
sim_sentencia(asignar(X, Exp), s(E0, Cs), s(E, Cs)) -->
    { sim_valor(Exp, E0, V),
      actualizar(X, V, E0, E) }.
sim_sentencia(escribir(Exp), s(E, Cs), s(E, Cs)) -->
    { sim_valor(Exp, E, V) },
    [V].
sim_sentencia(si(C, Si, _), S0, S) -->
    { suponer(C, S0, S1) },
    sim_bloque(Si, S1, S).
sim_sentencia(si(C, _, No), S0, S) -->
    { negar(C, NoC),
      suponer(NoC, S0, S1) },
    sim_bloque(No, S1, S).
sim_sentencia(mientras(C, _), S0, S) -->
    { negar(C, NoC),
      suponer(NoC, S0, S) }.
sim_sentencia(mientras(C, Cuerpo), S0, S) -->
    { suponer(C, S0, S1) },
    sim_bloque(Cuerpo, S1, S2),
    sim_sentencia(mientras(C, Cuerpo), S2, S).

%!  suponer(+C, +S0, -S) is semidet.
%
%   S es el estado S0 en el que se supone la condición C. Si los dos lados
%   son números, C se decide: S es S0 si se cumple, y falla si no. Si no,
%   S agrega C a las condiciones, como comparación de Prolog.
suponer(rel(Op, A, B), s(E, Cs), s(E, Cs1)) :-
    sim_valor(A, E, VA),
    sim_valor(B, E, VB),
    (   number(VA),
        number(VB)
    ->  comparar(Op, VA, VB),
        Cs1 = Cs
    ;   comparacion_prolog(Op, VA, VB, T),
        Cs1 = [T|Cs]
    ).
```

`suponer/3` decide la condición si los dos lados resultan números, con
`comparar/3` del [capítulo 45](../capitulo-45-proyecto-compilador/index.md), y si no, la agrega al camino. Para `cuadrado`
hay dos caminos, y para `factorial`, uno por cada cantidad de vueltas del
bucle:

```prolog
?- simbolizar_caso(cuadrado, Cs, S).
Cs = [n*n<0],
S = [0] ;
Cs = [n*n>=0],
S = [n*n].

?- limit(3, simbolizar_caso(factorial, Cs, S)).
Cs = [n=<0],
S = [1] ;
Cs = [n>0, n-1=<0],
S = [n] ;
Cs = [n>0, n-1>0, n-1-1=<0],
S = [n*(n-1)].
```

Cada camino es exacto: si n cumple sus condiciones, el programa escribe esa
expresión. Pero la ejecución simbólica tiene dos límites. El primero: las
condiciones no se comparan entre sí, y el primer camino de `cuadrado` es
imposible, porque ningún entero cumple n · n < 0; decidirlo pide razonar
sobre las condiciones. El segundo, que es el que importa: un bucle cuya
condición depende de una incógnita tiene infinitos caminos, uno por cada
cantidad de vueltas, y la enumeración no termina. El `mientras` de
`simbolico.pl` tiene primero la cláusula que sale del bucle para que los
caminos lleguen en orden, y aun así `limit/2` es lo único que detiene la
consulta. Un análisis que termine necesita valores que no crezcan con cada
vuelta: una cantidad finita de valores, o una forma de forzar que dejen de
cambiar.

## 58.4 Signos: un intérprete abstracto tabulado

El dominio de los **signos** tiene tres valores: `neg`, `cero` y `pos`, que
representan los enteros negativos, el cero y los positivos. Lo que cada
valor representa es su **concretización**; el signo de un entero, o los
signos de un rango, su **abstracción**. Una operación abstracta tiene que
ser **correcta**: si x tiene signo A e y tiene signo B, el signo de x + y
tiene que estar entre los resultados de la suma de A y B. Con signos, la
suma de un positivo y un negativo puede tener cualquier signo, y la forma
natural de escribirlo en Prolog es una relación con una respuesta por
resultado posible:

<!-- ejemplo: capitulo-58/signos.pl predicado: mas/3 -->
```prolog
%!  mas(?A, ?B, ?S) is nondet.
%
%   Hay un X de signo A y un Y de signo B tales que X + Y tiene signo S.
mas(cero, S, S) :-
    signo(S).
mas(neg, cero, neg).
mas(pos, cero, pos).
mas(neg, neg, neg).
mas(pos, pos, pos).
mas(neg, pos, S) :-
    signo(S).
mas(pos, neg, S) :-
    signo(S).
```

```prolog
?- op_signos(-, pos, pos, S).
S = neg ;
S = cero ;
S = pos.

?- op_signos(/, pos, cero, S).
S = error.
```

`menos/3` suma el opuesto, y `por/3` y `cociente/3` siguen la regla de los
signos, con una salvedad: el cociente de dos enteros no nulos también puede
ser cero, porque la división de Mini trunca: 1 / 2 es 0. `op_signos/4` reúne las cuatro operaciones y agrega el
resultado `error`, que no es un signo: es la división por cero, donde la
ejecución concreta se detiene. Una comparación es posible entre dos signos
si la diferencia puede tener el signo que la comparación pide: x < y cuando
x − y es negativa. `posible/3` lo calcula con `menos/3`, un entero de cada
signo y `comparar/3` del [capítulo 45](../capitulo-45-proyecto-compilador/index.md).

El intérprete abstracto tiene la forma del intérprete concreto: una
cláusula por construcción, y para `si` y `mientras` una con la condición
cierta y otra con la condición falsa. Es la forma que el intérprete del
[capítulo 45](../capitulo-45-proyecto-compilador/index.md) ya tenía, y la que Warren obtiene tachando el si-entonces-sino
de su intérprete: con valores abstractos las dos cláusulas pueden
cumplirse. Un estado es `estado(Entorno)` o `error`:

<!-- ejemplo: capitulo-58/signos.pl fragmento: :- table efecto/3. .. condicion_de(mientras(C, _), C). -->
```prolog
:- table efecto/3.

%!  efecto(+S, +R0, -R) is nondet.
%
%   Ejecutar la sentencia S sobre signos puede llevar el estado R0 a R. Una
%   respuesta por estado alcanzable; tabulada, termina aunque S sea un
%   mientras que vuelve a un estado ya visto.
efecto(_, error, error).
efecto(asignar(X, Exp), estado(E0), R) :-
    signo_exp(Exp, E0, V),
    asignar_signo(V, X, E0, R).
efecto(escribir(Exp), estado(E), R) :-
    signo_exp(Exp, E, V),
    seguir(V, estado(E), R).
efecto(si(C, Si, _), estado(E0), R) :-
    veredicto_condicion(C, E0, cierta),
    efecto_bloque(Si, estado(E0), R).
efecto(si(C, _, No), estado(E0), R) :-
    veredicto_condicion(C, E0, falsa),
    efecto_bloque(No, estado(E0), R).
efecto(mientras(C, Cuerpo), estado(E0), R) :-
    veredicto_condicion(C, E0, cierta),
    efecto_bloque(Cuerpo, estado(E0), R1),
    efecto(mientras(C, Cuerpo), R1, R).
efecto(mientras(C, _), estado(E), estado(E)) :-
    veredicto_condicion(C, E, falsa).
efecto(S, estado(E), error) :-
    condicion_de(S, C),
    veredicto_condicion(C, E, error).

% condicion_de(S, C): C es la condición de la sentencia S.
condicion_de(si(C, _, _), C).
condicion_de(mientras(C, _), C).
```

La directiva `:- table` es lo único que hace terminar los bucles. Una
vuelta de un `mientras` lleva a otro estado, y el bucle vuelve a llamar a
`efecto/3` con él; como hay una cantidad finita de estados de signos, tarde
o temprano la llamada es una variante de una anterior, y la tabla responde
con las respuestas ya encontradas en lugar de volver a entrar. Lo que la
tabla calcula es el **menor punto fijo** de los estados alcanzables, el
mismo concepto que la evaluación de abajo hacia arriba de la
[sección 38.6](../capitulo-38-semantica-de-los-programas-logicos/index.md#386-evaluacion-de-abajo-hacia-arriba).
`finales_signos/3` parte de cada estado inicial, una combinación de signos
de las entradas, y reúne los estados finales:

```prolog
?- finales_caso(cuadrado, [n-entre(inf, sup)], Fs).
Fs = [estado([n-cero, y-cero]), estado([n-neg, y-pos]), estado([n-pos, y-pos])].

?- finales_caso(promedio, [n-entre(0, sup)], Fs).
Fs = [error, estado([i-pos, n-pos, s-cero]), estado([i-pos, n-pos, s-pos])].

?- finales_caso(promedio, [n-entre(1, sup)], Fs).
Fs = [estado([i-pos, n-pos, s-cero]), estado([i-pos, n-pos, s-pos])].
```

Con n desde 0 el análisis encuentra la división por cero; con n desde 1
prueba que no ocurre, para todos los positivos y no solo para los de la
muestra. En `cuadrado` prueba que `y` nunca es negativa, porque cada signo
de n se sigue por separado. Hay más: la tabla de `efecto/3` guarda cada
llamada, es decir, cada sentencia con cada estado en que se ejecutó.
`muertas_signos/3` las lee con `current_table/2` y encuentra las
sentencias que no se ejecutan en ningún estado, el **código muerto**:

```prolog
?- muertas_caso(cuadrado, Ms).
Ms = [escribir(num(0))].
```

!!! question "Actividad"
    Predecir los estados finales de `cuenta` según `signos.pl`, con n
    positivo: qué signos puede tener x al salir del bucle, y si aparece
    `error`. Comprobarlo con `finales_caso(cuenta, [n-entre(1, sup)],
    Fs)`, y explicar qué operación de signos produce la falsa alarma.

El análisis de `mcd`, con a y b positivas, da un resultado que merece
atención:

```prolog
?- finales_caso(mcd, [a-entre(1, sup), b-entre(1, sup)], Fs).
Fs = [estado([a-pos, b-pos])].
```

Para los signos, `a - b` puede ser negativa o cero, y hay estados
abstractos en los que a deja de ser positiva. Pero desde esos estados la
condición a ≠ b se cumple siempre y el bucle no termina, así que no llegan
al final. El análisis prueba que **si el programa termina**, a es positiva y
`100 / a` no divide por cero; no prueba que termine. Es una propiedad de
**corrección parcial**, y es la clase de resultado que da un análisis de
estados alcanzables.

El precio de seguir cada combinación por separado es su cantidad.
`ramas(K, P, Es)` arma un programa con K entradas de cualquier signo y un
`si` por entrada; los estados iniciales son $3^K$, y las tablas crecen igual:

| K | estados finales | tablas de `efecto/3` | inferencias |
|---|---|---|---|
| 2 | 9 | 33 | 11 072 |
| 4 | 81 | 513 | 52 371 |
| 6 | 729 | 6 561 | 581 410 |
| 8 | 6 561 | 76 545 | 6 766 913 |

Con K = 8 el análisis tarda entre 2 y 3 segundos y sus tablas ocupan 320 MB; con
K = 9 agota el espacio de tablas, 1 GB por omisión (la opción
`table_space`), y termina con un error de recursos. Y con un dominio
infinito, como los intervalos, la tabla no se completaría:
cada vuelta de `i := i + 1` da un estado nuevo, como las longitudes de los
recorridos de la [sección 39.3](../capitulo-39-tabulacion/index.md#393-subsuncion-de-respuestas).

## 58.5 Un estado por punto: la unión con `lattice`

La alternativa es guardar un solo estado en cada punto del programa y
**unir** los estados que llegan a él por caminos distintos. Para unir
signos hace falta un cuarto valor, `top`, que representa todos los enteros:
la unión de `cero` y `pos` es `top`. Los valores forman un **reticulado**:
cada par tiene una unión, la menor cota superior. `reticulado.pl` escribe el
intérprete con el dominio como parámetro, como el intérprete de
circuitos del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md)
recibe la conducta de las compuertas
([Patrón 59](../patrones.md#59-interprete-con-conducta-como-parametro)):
cada dominio agrega cláusulas a las operaciones `dom_constante/3`,
`dom_operar/5`, `dom_refinar/5`, `dom_unir/4`, `dom_ensanchar/4` y las
demás, declaradas `multifile`. El dominio de signos con `top` se escribe
sobre las relaciones de `signos.pl`: reúne sus respuestas con `findall/3` y
las abstrae a un solo valor.

Un estado es `estado(D, Entorno)`, o `nada` si el punto no se alcanza. El
intérprete vuelve a ser una gramática, como el del [capítulo 45](../capitulo-45-proyecto-compilador/index.md), pero su
lista no es la salida del programa sino las **observaciones** del
análisis: `escribe(Exp, V)` en cada `escribir`, `division(Exp, V)` si un
divisor puede ser cero, `nunca(C)` si la condición C no se cumple en ningún
estado y `siempre(C)` si se cumple en todos:

<!-- ejemplo: capitulo-58/reticulado.pl predicado: abs_sentencia//4 -->
```prolog
%!  abs_sentencia(+S, +D, +Env:list, -E)// is det.
%
%   Ejecutar la sentencia S en el entorno abstracto Env del dominio D lleva
%   al estado E.
abs_sentencia(asignar(X, Exp), D, Env0, estado(D, Env)) -->
    valor_abs(Exp, D, Env0, V),
    { actualizar(X, V, Env0, Env) }.
abs_sentencia(escribir(Exp), D, Env, estado(D, Env)) -->
    valor_abs(Exp, D, Env, V),
    [escribe(Exp, V)].
abs_sentencia(si(C, Si, No), D, Env, E) -->
    partir(C, estado(D, Env), ESi, ENo),
    abs_bloque(Si, ESi, E1),
    abs_bloque(No, ENo, E2),
    { unir_estados(E1, E2, E) }.
abs_sentencia(mientras(C, Cuerpo), D, Env, Fuera) -->
    { cabeza(mientras(C, Cuerpo), estado(D, Env), I) },
    partir(C, I, Dentro, Fuera),
    abs_bloque(Cuerpo, Dentro, _).
```

Un `si` **parte** el estado en dos con `partir//4`: el estado restringido a
los valores que cumplen la condición y el restringido a los que no la
cumplen. Restringir es lo que hace `dom_refinar/5` con la variable de cada
lado: si x es `top` y la condición es x > 0, en la rama del `si` x es
`pos`. Al final, `unir_estados/3` une los estados de las dos ramas.

El estado de la condición de un `mientras` es la unión de los estados con
que se llega a ella: el de antes del bucle y el del final de cada vuelta. Es
un punto fijo, y `cabeza/3` lo calcula con una recursión a la izquierda
tabulada con el modo `lattice`: la tabla guarda una sola respuesta por
bucle y estado inicial, y cada vez que una vuelta produce un estado nuevo,
la reemplaza por lo que devuelve `ensanchar_estados/3`, que en un dominio
finito es la unión. Cuando ninguna vuelta cambia la respuesta, la tabla
está completa:

<!-- ejemplo: capitulo-58/reticulado.pl fragmento: :- table cabeza .. _). -->
```prolog
:- table cabeza(_, _, lattice(ensanchar_estados/3)).

%!  cabeza(+Bucle, +E0, -I) is det.
%
%   I es el estado en la condición del mientras Bucle, al que se llega con
%   E0: el menor punto fijo de las vueltas, unido con ensanchar_estados/3.
%   I debe llegar libre.
cabeza(_, E0, E0).
cabeza(mientras(C, Cuerpo), E0, I) :-
    cabeza(mientras(C, Cuerpo), E0, I0),
    phrase(( partir(C, I0, Dentro, _),
             abs_bloque(Cuerpo, Dentro, I) ),
           _).
```

Es la forma de `ruta/3` en la [sección 39.3](../capitulo-39-tabulacion/index.md#393-subsuncion-de-respuestas):
la primera cláusula da el estado de entrada, y la segunda extiende una
respuesta de la tabla con una vuelta más. Con el invariante calculado,
`abs_sentencia//4` recorre el cuerpo una sola vez más, desde el estado
restringido por la condición, para observar sus alarmas, y sale del bucle
con el estado restringido por la condición contraria. El argumento con modo
llega libre, como exige la tabla:

```prolog
?- analisis_caso(signos, factorial, [n-entre(0, 10)], F, Os).
F = estado(signos, [f-pos, n-top]),
Os = [escribe(id(f), pos)].

?- analisis_caso(signos, cuadrado, [n-entre(inf, sup)], F, Os).
F = estado(signos, [n-top, y-top]),
Os = [escribe(num(0), cero), escribe(id(y), top)].
```

El análisis prueba que `factorial` escribe un positivo, con cualquier n de
0 a 10: la condición n > 0 hace positivo a n dentro del bucle, y el
producto de dos positivos es positivo. En `cuadrado` pierde lo que el
análisis por conjuntos distinguía: n es `top`, y el producto de dos `top` es
`top`. Unir tiene ese costo, pero lo que gana es tamaño: un estado por
punto. Con el programa de K ramas de la sección anterior, el análisis
unido usa 834, 1 649, 2 500 y 3 387 inferencias para K = 2, 4, 6 y 8,
contra casi siete millones del análisis por conjuntos con K = 8.

!!! question "Actividad"
    Predecir el estado final y las observaciones del análisis de signos
    para `x := 1; mientras x > 0 hacer x := x + 1 fin; escribir x`: cuál es
    el invariante del bucle, si la condición se decide, y qué pasa con
    `escribir x`. Comprobarlo con `analizar/2` y `analisis/5`, y explicar
    qué significa el estado final `nada`.

## 58.6 Intervalos y ensanchamiento

El dominio de los **intervalos** da a cada variable un valor `i(Min, Max)`:
los enteros de Min a Max, con `inf` y `sup` como cotas infinitas.
`intervalos.pl` agrega sus cláusulas a las operaciones de
`reticulado.pl`. La suma suma las cotas; el producto y el cociente toman el
menor y el mayor de los resultados entre las cotas, y el cociente excluye
el cero del divisor partiéndolo en su parte negativa y su parte positiva,
como muestra la consulta que sigue al código del ensanchamiento.

Los intervalos tienen **cadenas crecientes infinitas**: i(0, 0), i(0, 1),
i(0, 2)… En `i := 0; mientras i < 10 hacer i := i + 1 fin` la unión en la
cabeza crece de uno en uno hasta i(0, 10), y en un bucle sin cota crecería
sin fin, y la tabla de `cabeza/3` no se completaría. El **ensanchamiento**
fuerza la estabilización: si una cota crece entre la respuesta vieja y la
nueva, salta a infinito. Antes de infinito prueba con 0, el único
**umbral**, porque muchos bucles bajan una variable hasta 0:

<!-- ejemplo: capitulo-58/intervalos.pl predicado: dom_ensanchar/4 bajar/2 -->
```prolog
dom_ensanchar(intervalos, Viejo, Nuevo, i(E, F)) :-
    Viejo = i(A, B),
    dom_unir(intervalos, Viejo, Nuevo, i(C, D)),
    (   C == A
    ->  E = A
    ;   bajar(C, E)
    ),
    (   D == B
    ->  F = B
    ;   subir(D, F)
    ).

%!  bajar(+C, -E) is det.
%
%   E es la cota inferior ensanchada desde C: 0 si C no es negativa, y si
%   no, inf.
bajar(C, E) :-
    (   cota_menor(0, C)
    ->  E = 0
    ;   E = inf
    ).
```

```prolog
?- dom_operar(intervalos, /, i(1, 10), i(-2, 3), V).
V = i(-10, 10).
```

Una cota solo puede cambiar dos veces, a 0 y a infinito, así que cada
cabeza se estabiliza en pocos pasos. Con ella, el análisis de `cuenta`
prueba lo que los signos no podían:

```prolog
?- analisis_caso(intervalos, cuenta, [n-entre(1, sup)], F, Os).
F = estado(intervalos, [n-i(1, sup), x-i(0, 0)]),
Os = [escribe(bin(/, num(100), bin(+, id(x), num(1))), i(100, 100))].
```

En la cabeza del bucle, x empieza en i(1, sup) y una vuelta da i(0, sup):
la cota inferior baja a 0, el umbral. Al salir, la condición x ≤ 0 deja
i(0, 0), y el cociente es exactamente 100, sin alarma. El precio del
ensanchamiento se ve en `diez`:

```prolog
?- analisis_caso(intervalos, diez, [], F, Os).
F = estado(intervalos, [i-i(10, sup)]),
Os = [escribe(id(i), i(10, sup))].
```

La cabeza va de i(0, 0) a i(0, 1), la cota superior crece y salta a `sup`:
la salida del bucle deja i(10, sup), cuando la ejecución concreta escribe
10. El resultado es correcto, porque contiene al 10, pero impreciso.

!!! question "Actividad"
    Predecir el intervalo que el análisis da a x al terminar
    `x := 5; mientras x > 0 hacer x := x - 2 fin`: seguir a mano las
    respuestas de `cabeza/3`, con el umbral 0, y la restricción de la
    salida. Compararlo con el valor que escribe `interpretar/2`, y con el
    resultado del análisis de signos.

## 58.7 Lo que el análisis prueba y lo que no

Los tres análisis, sobre los seis casos, con las entradas de cada caso:

| Caso | Pregunta | Conjuntos | Signos | Intervalos | Muestra |
|---|---|---|---|---|---|
| `promedio`, n ≥ 0 | ¿divide por cero? | sí, alarma | alarma | alarma | sí, con n = 0 |
| `factorial` | ¿escribe un positivo? | sí | sí | sí, ≥ 1 | sí |
| `cuenta` | ¿divide por cero? | falsa alarma | falsa alarma | no, prueba 100 | no |
| `cuadrado` | ¿se ejecuta `escribir 0`? | no, código muerto | no lo decide | no lo decide | no |
| `diez` | ¿qué escribe? | positivo | positivo | de 10 a sup | 10 |
| `mcd` | ¿divide por cero? | no, si termina | falsa alarma | falsa alarma | no |

Ningún dominio es mejor que otro en todo: los intervalos distinguen
magnitudes que los signos confunden, y los conjuntos de signos distinguen
correlaciones —n y n · n tienen el mismo signo o y es cero— que un valor
por variable pierde. Ninguno de los tres relaciona dos variables: en `mcd`,
a − b es positivo porque a > b, y un dominio que no guarda a > b no puede
saberlo. Los dominios **relacionales**, que guardan desigualdades entre
variables, existen y cuestan más.

Lo que sí se exige a todos es la **corrección**: todo lo que el programa
hace de verdad tiene que estar dentro de lo que el análisis dice. `cubre/3`
lo comprueba con cada corrida de la muestra: si terminó, cada valor final
está en el valor abstracto de su variable, y si dividió por cero, el
análisis tiene una alarma. Las pruebas `cubre` de `reticulado.plt` e
`intervalos.plt` lo verifican con las 200 corridas de los seis casos, para
los dos dominios. Una falsa alarma es una imprecisión; una corrida no
cubierta sería un error del análisis.

Quedan tres límites: un estado final distinto de `nada` no prueba que el
programa termine (**corrección parcial**); el **ensanchamiento** pierde
precisión en los bucles con cota, como en `diez`, y una vuelta más sin
ensanchar la recupera en parte (ejercicio 5); y el análisis por conjuntos
crece como $3^K$, mientras que el unido es lineal y pierde correlaciones.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; las operaciones de signos son relaciones `nondet`, una respuesta por resultado posible, y las del reticulado son `det`, una sola respuesta que las reúne |
    | C2 | el intérprete abstracto elige la cláusula por el functor del nodo, como el del [capítulo 45](../capitulo-45-proyecto-compilador/index.md); un estado es `estado(…)`, `error` o `nada`, y cada dominio es un nombre con cláusulas propias en las operaciones `multifile` |
    | C4 | el análisis unido no deja alternativas pendientes: las cotas infinitas y los extremos se comparan con si-entonces-sino, y las pruebas lo verifican |
    | C6 | ningún análisis escribe ni guarda estado propio; las tablas son el único estado, y `muertas_signos/3` las borra antes de leerlas |
    | C7 | 45 pruebas en seis archivos, y 16 más de las soluciones; los resultados de los análisis se comparan con la muestra concreta en todos los casos, y las imprecisiones conocidas (`diez`, `cuadrado`, `mcd`) están probadas como tales |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir lo que dicen los análisis de signos unidos y de
   intervalos sobre `x := n - 1; escribir 10 / x`, con n de 2 en adelante:
   el valor de x y si hay alarma de división. Comprobarlo con `analizar/2` y
   `analisis/5`, y explicar la diferencia.
2. **(1)** Predecir las respuestas de `op_signos(/, neg, pos, S)` y de
   `op_signos(*, cero, neg, S)`, y dar para cada una un par de enteros que
   produzca ese signo.
3. ★ **(2)** Escribir el dominio `paridad`, con los valores `par`, `impar` y
   `top`, como cláusulas de las operaciones `dom_*` de `reticulado.pl`.
   Comprobar que el análisis de `x := 2 * n + 1; mientras x <> 0 hacer
   x := x - 2 fin` con n cualquiera observa `siempre(x <> 0)`: el bucle no
   termina.
4. **(2)** El análisis de Warren detecta **variables no inicializadas**.
   En Mini las variables empiezan en 0, pero leer una antes de asignarla
   suele ser un descuido. Escribir `sin_asignar(Programa, Xs)`, con un
   intérprete como el de `signos.pl` cuyos valores son `asignada` y
   `sin_asignar`: Xs son las variables que alguna ejecución lee antes de
   asignarlas.
5. ★ **(2)** Escribir `estrechar/3`: con el invariante I que da `cabeza/3`,
   calcular una vuelta más sin ensanchar, la unión del estado de entrada con
   el final del cuerpo desde I restringido por la condición. Comprobar que
   en `diez` da i(0, 10), y que la salida del bucle queda en i(10, 10).
6. **(3)** Agregar al dominio de signos los valores `noneg` (cero o
   positivo) y `nopos` (cero o negativo), como un dominio nuevo `signos6`.
   Comprobar que en `promedio` la suma s termina `noneg`, donde `signos`
   daba `top`.
7. ★ **(1)** Analizar `mcd` con `finales_caso/3` y a en `entre(inf, sup)`.
   Explicar qué cambia en los estados finales y por qué, y qué dice el
   resultado con a y b positivas sobre la terminación del programa.
8. **(3)** Descartar los caminos imposibles de la ejecución simbólica:
   traducir las condiciones de cada camino a restricciones de
   `library(clpfd)` y quedarse con los caminos cuyas condiciones pueden
   cumplirse. Comprobar que en `cuadrado` queda un solo camino.
9. **(2)** Medir con `time/1` el análisis por conjuntos y el unido de
   `ramas(K, P, Es)` para K de 2 a 9, y comprobar que el primero crece
   como $3^K$ y el segundo en proporción a K. Medir también el espacio de las
   tablas con `statistics(table_space_used, B)`, y explicar el error que da
   el análisis por conjuntos con K = 9.
10. ★ **(2)** Escribir `inalcanzables(D, Programa, Entradas, Ss)`: las
    sentencias a las que el análisis en el dominio D llega con el estado
    `nada`, deducidas de sus observaciones `nunca/1` y `siempre/1`.
    Comprobar que con signos da `[escribir(id(x))]` para `x := 0 - 1; si
    x > 0 entonces escribir x fin` y para `x := 1; mientras x > 0 hacer
    x := x + 1 fin; escribir x`.
11. **(3)** Ensanchar con **umbrales tomados del programa**: la cota que
    crece salta a la menor constante del programa que la contiene, y solo
    después a infinito. Escribir el dominio `umbrales(Ts)`, un intervalo que
    lleva en su nombre la lista de umbrales, y comprobar que en `diez` da
    i(10, 10) sin estrechar.

## Resumen

| | |
|---|---|
| **análisis estático** | responder qué hace un programa con todos sus datos posibles, sin ejecutarlo con cada uno |
| **interpretación abstracta** | ejecutar el programa sobre valores abstractos, cada uno de los cuales representa un conjunto de valores concretos |
| **valor simbólico** | una incógnita o una expresión sobre incógnitas; la ejecución simbólica sigue un camino por cada combinación de condiciones |
| **concretización, abstracción** | lo que un valor abstracto representa; el menor valor abstracto que representa un conjunto dado |
| **corrección** | todo lo que el programa hace está dentro de lo que el análisis dice; una falsa alarma es una imprecisión, no un error |
| **reticulado, unión** | valores abstractos ordenados por lo que representan; la unión es la menor cota superior de dos valores |
| **menor punto fijo** | los estados alcanzables; la tabla lo calcula al completarse |
| **ensanchamiento** | llevar al infinito, o a un umbral, la cota que crece, para que la cabeza de un bucle se estabilice |
| **corrección parcial** | lo que vale si el programa termina; un análisis de estados alcanzables no prueba la terminación |
| `correr_desde/3`, `muestra/2` | la referencia concreta, cargada del [capítulo 45](../capitulo-45-proyecto-compilador/index.md) |
| `simbolizar/4` | la ejecución sobre valores simbólicos |
| `op_signos/4`, `efecto/3`, `finales_signos/3`, `muertas_signos/3` | los signos, por conjuntos de estados, tabulados |
| `analisis/5`, `cabeza/3`, `partir//4`, `dom_*` | el intérprete con el dominio como parámetro y la cabeza de los bucles con `lattice` |
| `dom_ensanchar/4`, `cubre/3`, `informe/1` | los intervalos, la comparación con la muestra y el analizador terminado |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| El grafo de llamadas de un programa Prolog y sus predicados recursivos o sin usar, otro análisis de programas | [capítulo 59](../capitulo-59-proyecto-analisis-programas/index.md) |
| La evaluación de abajo hacia arriba de un programa lógico como punto fijo, en un motor Datalog | [capítulo 85](../capitulo-85-proyecto-motor-datalog/index.md) |

## Referencias

- David S. Warren, *Programming in Tabled Prolog*, borrador distribuido
  con el sistema XSB, 1999 — capítulo «Meta-Programming», secciones
  «Abstract Interpretation» y «AI of a Simple Nested Procedural Language».
  [Copia de archivo de la página del autor](https://web.archive.org/web/20240628211257/https://www3.cs.stonybrook.edu/~warren/xsbbook/book.html).
  El capítulo toma el método: el intérprete concreto primero, las
  operaciones cambiadas por operaciones abstractas, las condiciones que no
  se deciden como no determinismo, y la tabulación del intérprete de
  sentencias para obtener el menor punto fijo de los estados alcanzables;
  también la idea del análisis de variables no inicializadas, que es el
  ejercicio 4. El programa de Warren, para XSB y para un lenguaje con
  procedimientos anidados, no se copió.
- Patrick Cousot y Radhia Cousot, «Abstract interpretation: a unified
  lattice model for static analysis of programs by construction or
  approximation of fixpoints», *Proceedings of the 4th ACM Symposium on
  Principles of Programming Languages (POPL '77)*, ACM, 1977, págs.
  238–252. DOI [10.1145/512950.512973](https://doi.org/10.1145/512950.512973).
  El capítulo toma los conceptos: dominio abstracto como reticulado,
  corrección respecto de la semántica concreta, el análisis como menor
  punto fijo, y el ensanchamiento para los dominios de altura infinita.
- William F. Clocksin, *Clause and Effect: Prolog Programming for the
  Working Programmer*, Springer, 1997 — «Case Study: The Fast Fourier
  Transform in Prolog». El capítulo toma de allí el sentido amplio de
  interpretación abstracta como ejecución sobre valores simbólicos, el
  punto de partida de la [sección 58.3](#583-valores-simbolicos).

El lenguaje Mini, su analizador sintáctico y su intérprete son los del
[capítulo 45](../capitulo-45-proyecto-compilador/index.md), cargados sin
cambios; los dominios, los intérpretes abstractos, los casos y el resto del
código del capítulo son propios, escritos para el curso.
