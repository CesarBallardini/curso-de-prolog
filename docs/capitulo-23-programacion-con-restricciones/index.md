# Capítulo 23 — Programación con restricciones

Un calendario de exámenes, el coloreo de un mapa, un criptoaritmo, la ubicación
de las reinas en un tablero: son problemas **combinatorios**, en los que hay
que elegir valores para muchas variables de modo que se cumplan muchas
condiciones a la vez. La [plantilla 15](../plantillas.md#15-generar-y-probar) los resuelve generando candidatos y
probándolos, lo que alcanza para problemas pequeños y se vuelve impracticable
en cuanto crecen.

La **programación con restricciones** los resuelve de otra forma. Se declaran
las variables y sus dominios, se declaran las condiciones como restricciones, y
el sistema las usa para descartar valores **antes** de probarlos. Este capítulo
presenta `library(clpfd)`, que trabaja con enteros: la aritmética en los dos
sentidos que la parte I dejó pendiente, los dominios, el etiquetado, las sumas
y los conteos, la reificación, y cuatro problemas clásicos. Presenta también
`dif/2`. El proyecto arma el calendario de exámenes, y el Buscaminas deduce
dónde están las minas.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- escribir relaciones aritméticas que funcionan en todos los sentidos, con
  `#=` y las demás restricciones;
- modelar un problema con variables, dominios y restricciones, y etiquetar al
  final;
- usar `all_different/1`, `sum/3`, `global_cardinality/2` y la reificación;
- comparar, con mediciones, generar y probar con restringir y etiquetar;
- usar `dif/2` en lugar de `\=` cuando las variables todavía no tienen valor.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:20 h**.
    Resolver los 7 ejercicios marcados con ★: **2:11 h**.
    Resolver los 16 ejercicios del final: **5:15 h**.

## 23.1 Aritmética en los dos sentidos

El [capítulo 8](../capitulo-08-aritmetica/index.md) mostró que `is/2` evalúa: su lado derecho debe estar ligado, y
por eso un predicado aritmético funciona en un solo sentido. La `suma/3` del
[capítulo 6](../capitulo-06-recursion/index.md), sobre los naturales de Peano, funcionaba en todos, a costa de
una notación impracticable. `library(clpfd)` recupera los dos sentidos con los
enteros predefinidos: `#=` es una **igualdad aritmética** entre expresiones con
variables.

<!-- ejemplo: capitulo-23/restricciones.pl predicado: doble/2 n_factorial/2 consulta: n_factorial(N, 120). -->
```prolog
%!  doble(?X:integer, ?Y:integer) is semidet.
%
%   Y es el doble de X. Con uno de los dos ligado, hay a lo sumo una
%   respuesta; con los dos libres, la relación queda como restricción.
doble(X, Y) :-
    Y #= 2 * X.

%!  n_factorial(?N:integer, ?F:integer) is nondet.
%
%   F es el factorial de N. Funciona en los dos sentidos: de N a F y de F a
%   N.
n_factorial(0, 1).
n_factorial(N, F) :-
    N #> 0,
    N1 #= N - 1,
    F #= N * F1,
    n_factorial(N1, F1).
```

```prolog
?- doble(3, Y).
Y = 6.

?- doble(X, 8).
X = 4.

?- doble(X, 7).
false.

?- n_factorial(N, 120).
N = 5 ;
false.
```

`doble(X, 8)` responde `X = 4`: `#=` resuelve la ecuación. `doble(X, 7)` falla,
porque ningún entero cumple `2 * X = 7`. `n_factorial/2` calcula el factorial
en los dos sentidos con la misma definición: la restricción `F #= N * F1` se
plantea antes de la llamada recursiva, cuando todavía no se conoce `F1`, y se
resuelve cuando se conoce.

La biblioteca se carga con `:- use_module(library(clpfd)).`. Sus restricciones
son `#=`, `#\=`, `#<`, `#>`, `#=<` y `#>=`, y sus expresiones admiten `+`, `-`,
`*`, `//`, `mod`, `abs`, `min` y `max`; `abs(E)` es el valor absoluto de `E`,
una función que también evalúa `is/2`. En un programa que usa enteros, `#=`
puede reemplazar a `is/2` siempre: con los datos ligados, calcula lo mismo; con
datos sin ligar, no produce un error.

## 23.2 Variables, dominios y restricciones

Una variable de restricción tiene un **dominio**: el conjunto de enteros que
todavía puede tomar. `X in 1..10` lo declara para una variable, y
`Xs ins 0..9` para todas las de una lista. Cada restricción que se agrega
**reduce** los dominios de las variables que menciona, en lo que se llama
**propagación**:

```prolog
?- X in 1..10, X #> 7.
X in 8..10.

?- X #= Y + 1, Y = 4.
X = 5,
Y = 4.

?- doble(X, Y).
2*X#=Y.
```

La primera respuesta no es un valor sino un dominio: `X` puede ser 8, 9 o 10.
En la tercera, sin ningún dato, la respuesta es la restricción misma: la
relación queda planteada, a la espera de que alguna variable reciba un valor.
`fd_dom(X, D)` da el dominio actual de una variable.

Plantear una restricción puede fallar de inmediato cuando ya es incompatible
con el dominio —`X in 1..3, X #> 5` falla sin etiquetar—, y por eso los
predicados del capítulo que plantean restricciones se declaran `semidet`.

!!! question "Actividad"
    Predecir la respuesta de `X in 0..20, X mod 3 #= 0, X #> 10.` y comprobarla.
    ¿Qué agrega `label([X])` al final?

## 23.3 Etiquetar

La propagación sola no siempre llega a un valor. `label(Vs)` **etiqueta**: da a
cada variable de la lista, por turno, un valor de su dominio, y deja que la
propagación descarte lo que no cumple. Al volver atrás, prueba el siguiente
valor.

```prolog
?- X in 1..3, label([X]).
X = 1 ;
X = 2 ;
X = 3.
```

`labeling(Opciones, Vs)` elige el orden. `ff` (*first fail*) etiqueta primero la
variable con el dominio más chico, la que tiene más posibilidades de fallar y
podar el árbol de búsqueda cuanto antes; `min(Expr)` y `max(Expr)` buscan
primero las soluciones que minimizan o maximizan una expresión. El orden no
cambia las soluciones, pero puede cambiar en varios órdenes de magnitud el
tiempo que se tarda en encontrar la primera: la [sección 23.9](#239-las-n-reinas) lo mide.

El etiquetado va **al final**, después de todas las restricciones. Si se
etiqueta antes, cada valor se prueba contra las restricciones de a uno, y el
programa vuelve a ser generar y probar.

## 23.4 `all_different/1`

Muchos problemas exigen valores distintos: los dígitos de un criptoaritmo, las
filas de las reinas, los días de exámenes de materias con alumnos en común.
`all_different(Vs)` lo declara para toda una lista:

<!-- ejemplo: capitulo-23/restricciones.pl predicado: tres_que_suman/2 consulta: tres_que_suman(6, Xs). -->
```prolog
%!  tres_que_suman(?Suma:integer, -Xs:list(integer)) is nondet.
%
%   Xs son tres dígitos distintos, en orden creciente, que suman Suma.
tres_que_suman(Suma, Xs) :-
    Xs = [A, B, C],
    Xs ins 0..9,
    all_different(Xs),
    A #< B,
    B #< C,
    sum(Xs, #=, Suma),
    label(Xs).
```

```prolog
?- tres_que_suman(6, Xs).
Xs = [0, 1, 5] ;
Xs = [0, 2, 4] ;
Xs = [1, 2, 3].
```

Las restricciones `A #< B` y `B #< C` eliminan las permutaciones de una misma
solución: sin ellas, cada terna aparecería seis veces. `all_distinct/1` es la
versión más fuerte de `all_different/1`: propaga más, a un costo mayor por
restricción.

## 23.5 Sumas y conteos

`sum(Vs, #=, S)` restringe la suma de una lista; con `#=<` u otro operador, la
compara. `global_cardinality(Vs, Pares)` restringe cuántas veces aparece cada
valor: `global_cardinality(Xs, [1-2, 2-2, 3-2])` exige dos de cada uno.
`scalar_product(Coeficientes, Vs, #=<, Limite)` restringe una suma ponderada,
como la cantidad de alumnos que rinden en un día, en el proyecto.

## 23.6 Reificación

A veces lo que se cuenta no es un valor sino una condición: cuántos elementos
son iguales a 1, cuántos exámenes caen un día. La **reificación** refleja la
verdad de una restricción en una variable booleana: `B #<==> (X #= 1)` hace
que `B` sea 1 si `X` es 1, y 0 si no, en los dos sentidos. Sumar las
variables booleanas cuenta las condiciones que se cumplen.

<!-- ejemplo: capitulo-23/restricciones.pl predicado: cantidad_de_unos/2 consulta: cantidad_de_unos([1, 0, 1], N). -->
```prolog
%!  cantidad_de_unos(?Xs:list(integer), ?N:integer) is nondet.
%
%   N es la cantidad de elementos de Xs iguales a 1. Cada comparación se
%   refleja en una variable booleana, 1 si se cumple y 0 si no, y N es su
%   suma.
cantidad_de_unos(Xs, N) :-
    maplist([X, B]>>(B #<==> (X #= 1)), Xs, Bs),
    sum(Bs, #=, N).
```

```prolog
?- cantidad_de_unos([1, 0, 1], N).
N = 2.

?- cantidad_de_unos([A, B], 2).
A = B, B = 1.
```

La segunda consulta va en sentido inverso: si dos de dos elementos son 1,
los dos lo son. La reificación admite también `#\/`, `#/\` y `#\` para
combinar condiciones.

!!! example "Patrón 26 — Contar con reificación"
    **Problema.** Un modelo necesita que exactamente, al menos o a lo sumo N de
    un conjunto de condiciones se cumplan.

    **Versión ingenua.** Generar las combinaciones de condiciones que se
    cumplen, o contarlas después de etiquetar, cuando ya no pueden podar la
    búsqueda.

    **Patrón.** Una variable booleana por condición, `B #<==> Condicion`, y una
    restricción sobre su suma: `sum(Bs, #=, N)`. La cuenta participa de la
    propagación desde el principio.

    **Cuándo no usarlo.** Cuando se cuentan valores y no condiciones:
    `global_cardinality/2` lo hace con una sola restricción.

## 23.7 Un criptoaritmo: SEND + MORE = MONEY

En un criptoaritmo cada letra es un dígito distinto, y la cuenta escrita con
letras debe ser correcta. El más conocido es SEND + MORE = MONEY:

<!-- ejemplo: capitulo-23/restricciones.pl predicado: send_more_money/1 consulta: send_more_money(Letras). -->
```prolog
%!  send_more_money(-Letras:list(integer)) is det.
%
%   Letras son los dígitos de S, E, N, D, M, O, R e Y, distintos entre sí,
%   tales que SEND + MORE = MONEY, sin ceros a la izquierda.
send_more_money([S, E, N, D, M, O, R, Y]) :-
    Letras = [S, E, N, D, M, O, R, Y],
    Letras ins 0..9,
    all_different(Letras),
    S #\= 0,
    M #\= 0,
              1000 * S + 100 * E + 10 * N + D
    +         1000 * M + 100 * O + 10 * R + E
    #= 10000 * M + 1000 * O + 100 * N + 10 * E + Y,
    label(Letras).
```

```prolog
?- send_more_money(L).
L = [9, 5, 6, 7, 1, 0, 8, 2] ;
false.
```

9567 + 1085 = 10652. El programa no dice cómo encontrar la solución: dice qué
es una solución. Las tres partes del modelo son visibles: las variables y su
dominio (`ins 0..9`), las restricciones (distintas, sin ceros a la izquierda,
la suma), y el etiquetado al final. La propagación hace casi todo el trabajo:
de la suma se deduce que M es 1 antes de etiquetar nada.

!!! example "Patrón 27 — Modelar, restringir, etiquetar"
    **Problema.** Es necesario encontrar valores para muchas variables que
    cumplen muchas condiciones a la vez.

    **Versión ingenua.** Generar y probar: producir combinaciones completas y
    comprobar cada una ([plantilla 15](../plantillas.md#15-generar-y-probar)).

    **Patrón.** Tres partes, en este orden: las variables con sus dominios
    (`in`, `ins`); todas las restricciones; y el etiquetado al final (`label/1`,
    `labeling/2`). El predicado que construye el modelo puede separarse del que
    etiqueta, para probar el modelo solo.

    **Cuándo no usarlo.** Cuando el problema no es sobre enteros, o cuando se
    resuelve con un cálculo directo; y cuando los dominios son enormes y las
    restricciones propagan poco: entonces hace falta otra formulación.

## 23.8 Coloreo de un mapa

Colorear un mapa es asignar un color a cada región de modo que dos regiones
vecinas tengan colores distintos. El mapa de este ejemplo tiene ocho provincias
del centro y el oeste de la Argentina.

<!-- ejemplo: capitulo-23/coloreo.pl predicado: colorear/2 distinto_color/2 consulta: colorear(4, Colores). -->
```prolog
%!  colorear(+K:integer, -Colores:list(pair)) is nondet.
%
%   Colores son pares Provincia-Color, con colores de 1 a K, tales que dos
%   provincias limítrofes tienen colores distintos. Falla si K colores no
%   alcanzan.
colorear(K, Colores) :-
    findall(P-_, provincia(P), Colores),
    pairs_values(Colores, Vs),
    Vs ins 1..K,
    findall(A-B, limita(A, B), Limites),
    maplist(distinto_color(Colores), Limites),
    label(Vs).

%!  distinto_color(+Colores:list(pair), +Limite:pair) is det.
%
%   Las dos provincias de Limite, A-B, tienen colores distintos en Colores.
distinto_color(Colores, A-B) :-
    memberchk(A-CA, Colores),
    memberchk(B-CB, Colores),
    CA #\= CB.
```

```prolog
?- colorear(3, Colores).
false.

?- aggregate_all(count, colorear(4, _), N).
N = 480.
```

Cada provincia tiene una variable, su color, y `findall(P-_, …)` crea una
variable nueva por provincia. Cada límite es una restricción `#\=`. Con tres
colores no hay solución: San Luis limita con San Juan, Mendoza, La Pampa,
Córdoba y La Rioja, que forman un anillo de cinco provincias; un anillo impar
necesita tres colores, y San Luis un cuarto. Con cuatro hay 480 coloreos. Todos
usan los cuatro colores, que se pueden permutar de 24 formas: si solo importa
qué provincias comparten color, son 20 coloreos distintos.

## 23.9 Las N reinas

Ubicar N reinas en un tablero de N × N sin que ninguna ataque a otra: ni en la
misma fila, ni en la misma columna, ni en la misma diagonal. El modelo pone una
reina por columna: `Qs = [Q1, …, QN]`, con `Qi` la fila de la reina de la
columna i.

<!-- ejemplo: capitulo-23/reinas.pl predicado: reinas/2 seguras/1 no_ataca/3 consulta: reinas(8, Qs). -->
```prolog
%!  reinas(+N:integer, -Qs:list(integer)) is nondet.
%
%   Qs es una ubicación de N reinas que no se atacan: la reina de la columna
%   i está en la fila i-ésima de Qs.
reinas(N, Qs) :-
    length(Qs, N),
    Qs ins 1..N,
    seguras(Qs),
    labeling([ff], Qs).

%!  seguras(+Qs:list) is semidet.
%
%   Ninguna reina de Qs ataca a otra: restringe cada una contra las de su
%   derecha.
seguras([]).
seguras([Q|Qs]) :-
    no_ataca(Q, Qs, 1),
    seguras(Qs).

%!  no_ataca(+Q, +Qs:list, +D:integer) is semidet.
%
%   La reina Q no ataca a las de Qs, la primera de las cuales está D
%   columnas a su derecha: otra fila y otra diagonal.
no_ataca(_, [], _).
no_ataca(Q, [Q1|Qs], D) :-
    Q #\= Q1,
    abs(Q - Q1) #\= D,
    D1 is D + 1,
    no_ataca(Q, Qs, D1).
```

```prolog
?- reinas(8, Qs).
Qs = [1, 5, 8, 6, 3, 7, 2, 4] ;
...

?- reinas(3, Qs).
false.
```

Las columnas son distintas por construcción; `Q #\= Q1` exige filas
distintas, y `abs(Q - Q1) #\= D`, con `D` la distancia entre columnas, exige
diagonales distintas. Con `ff`, la primera solución de 20 reinas tarda
milisegundos; el ejercicio 10 mide lo que tarda sin esa opción.

## 23.10 Generar y probar frente a restringir y etiquetar

`reinas_gyp/2`, en el mismo archivo, resuelve las reinas con la
[plantilla 15](../plantillas.md#15-generar-y-probar): genera cada permutación de las filas con `permutation/2` y
comprueba si alguna reina ataca a otra. `permutation(L, P)`, de `library(lists)`,
liga `P` a una permutación de `L` y, al reintentar, produce las demás. Las dos
versiones encuentran las mismas soluciones. Con las herramientas del [capítulo 16](../capitulo-16-rendimiento/index.md), contar las 724
soluciones de 10 reinas:

```text
% restringir y etiquetar
% 11,037,241 inferences, 0.469 CPU in 0.470 seconds (100% CPU, 23546114 Lips)
% generar y probar
% 115,046,367 inferences, 5.797 CPU in 5.857 seconds (99% CPU, 19846274 Lips)
```

Diez veces más inferencias y más tiempo. La diferencia está en cuándo se
descubre que un candidato no cumple las restricciones: generar y probar
construye la permutación completa antes de comprobar; restringir descarta el
valor de una reina en cuanto choca con otra, y con él todas las permutaciones
que empiezan igual. La diferencia crece con el tamaño: con 8 reinas, las dos
tardan centésimas de segundo; con 20, generar y probar no termina en un tiempo
razonable, y restringir encuentra una solución en milisegundos.

## 23.11 `dif/2`

El [capítulo 10](../capitulo-10-negacion-como-falla/index.md) mostró que `\+` y `\==` dan respuestas incorrectas con variables
libres: `X \== a` se cumple si `X` todavía no tiene valor, aunque después se
ligue a `a`. `dif(X, Y)` es la restricción de desigualdad: si `X` e `Y` ya son
distintos, se cumple; si ya son iguales, falla; y si todavía no se sabe, se
**posterga** hasta que se sepa.

<!-- ejemplo: capitulo-23/restricciones.pl predicado: distintos/2 consulta: distintos(X, a), X = b. -->
```prolog
%!  distintos(?X, ?Y) is semidet.
%
%   X e Y son distintos, con dif/2: si todavía no tienen valor, la
%   comparación se posterga hasta que lo tengan.
distintos(X, Y) :-
    dif(X, Y).
```

```prolog
?- distintos(X, a), X = b.
X = b.

?- distintos(X, a), X = a.
false.

?- dif(X, Y).
dif(X, Y).
```

`dif/2` funciona con cualquier término, no solo con enteros, y conserva la
lectura declarativa: el orden de los objetivos no cambia la respuesta. Es la
restricción que usan `sacar_puro/3` y `tfilter/3` en la
[sección 15.9](../capitulo-15-control/index.md#159-if_3-y-libraryreif-el-condicional-puro).

## 23.12 `library(clpb)`

Para restricciones sobre valores booleanos, `library(clpb)` resuelve problemas
de satisfacibilidad: `sat(X + Y)` exige que al menos una de dos variables sea
verdadera, y `taut/2` dice si una fórmula es siempre verdadera o siempre falsa.
Conecta con la lógica proposicional del [capítulo 12](../capitulo-12-prolog-y-la-logica/index.md). Este capítulo no la
desarrolla más allá de un ejemplo, que se puede omitir; el
[capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md) la retoma para verificar circuitos
([sección 48.4](../capitulo-48-proyecto-circuitos-logicos/index.md#484-verificar-con-libraryclpb)). El ejemplo es un circuito de cuatro
compuertas NAND. Una compuerta es una relación entre sus entradas y su salida,
y se escribe como su tabla de verdad; el circuito es la conjunción de sus
compuertas, con una variable por cable:

<!-- ejemplo: capitulo-23/circuito.pl predicado: nand/3 circuito/3 consulta: circuito(X, Y, 1). -->
```prolog
% nand(A, B, S): S es la salida de una compuerta NAND con entradas A y B.
nand(0, 0, 1).
nand(0, 1, 1).
nand(1, 0, 1).
nand(1, 1, 0).

%!  circuito(?X, ?Y, ?Z) is nondet.
%
%   Z es la salida del circuito para las entradas X e Y: la primera
%   compuerta combina las entradas, la segunda y la tercera combinan cada
%   entrada con la salida de la primera, y la cuarta da Z.
circuito(X, Y, Z) :-
    nand(X, Y, A),
    nand(X, A, B),
    nand(Y, A, C),
    nand(B, C, Z).
```

```prolog
?- circuito(X, Y, 1).
X = 0,
Y = 1 ;
X = 1,
Y = 0 ;
false.
```

La consulta fija la salida y obtiene las entradas: el circuito da 1 cuando las
dos entradas son distintas, que es la disyunción exclusiva. Enumerar las
entradas lo comprueba con dos entradas, pero con n entradas son 2ⁿ casos.
`library(clpb)` razona sobre las fórmulas: `circuito_b/3` escribe cada
compuerta como una restricción `sat/1`, con `~` para la negación, `*` para la
conjunción y `=:=` para la equivalencia, y `es_xor/1` pregunta con `taut/2`
si la salida equivale a `X # Y`, la disyunción exclusiva:

<!-- ejemplo: capitulo-23/circuito.pl predicado: circuito_b/3 es_xor/1 consulta: es_xor(T). -->
```prolog
%!  circuito_b(?X, ?Y, ?Z) is det.
%
%   El mismo circuito como restricciones de library(clpb): ~ es la
%   negación, * la conjunción y =:= la equivalencia.
circuito_b(X, Y, Z) :-
    sat(A =:= ~(X * Y)),
    sat(B =:= ~(X * A)),
    sat(C =:= ~(Y * A)),
    sat(Z =:= ~(B * C)).

%!  es_xor(-T) is det.
%
%   T es 1 si la salida del circuito es equivalente, para toda entrada, a la
%   disyunción exclusiva (#) de las entradas, y 0 si no lo es para ninguna.
es_xor(T) :-
    circuito_b(X, Y, Z),
    taut(Z =:= X # Y, T).
```

```prolog
?- circuito_b(X, Y, Z).
sat(X=:=Y#Z).

?- es_xor(T).
T = 1.
```

La primera respuesta es la restricción que queda sobre las variables de la
consulta cuando se eliminan los cables internos: X equivale a `Y # Z`, que es
lo mismo que Z equivale a `X # Y`. `taut/2` responde `T = 1` porque la
equivalencia es una tautología bajo las restricciones del circuito; con una
fórmula que no puede cumplirse respondería `T = 0`, y falla cuando depende de
los valores de las variables.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C2 | los modelos responden la consulta más general: `doble(X, Y)` da la restricción, `n_factorial(N, 120)` va en sentido inverso, `cantidad_de_unos([A, B], 2)` deduce los valores |
    | C5 | una expresión que no es aritmética produce un error de dominio (`_ #= a`), y un horario con días que no son un número también: la prueba `dominio_incorrecto` lo verifica, en lugar de una falla silenciosa |

## 23.13 El proyecto: el calendario de exámenes

La versión de *Inscripciones* de este capítulo arma el calendario de exámenes.
Cada materia rinde un día; dos materias con un alumno inscripto en común
deben rendir en días distintos, y cada día la cantidad de alumnos que rinden
no puede superar la capacidad del aula.

<!-- ejemplo: capitulo-23/inscripciones.pl predicado: horario/3 conflicto/2 dias_distintos/2 capacidad_del_dia/3 rinde_ese_dia/3 consulta: horario(5, 6, Horario). -->
```prolog
%!  horario(+Dias:integer, +Capacidad:integer, -Horario:list(pair)) is nondet.
%
%   Horario son pares Materia-Dia, con días de 1 a Dias, tales que dos
%   materias con un alumno inscripto en común rinden en días distintos y la
%   cantidad de alumnos que rinden cada día no supera Capacidad.
horario(Dias, Capacidad, Horario) :-
    findall(M-_, materia(M, _, _), Horario),
    pairs_values(Horario, Ds),
    Ds ins 1..Dias,
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(dias_distintos(Horario), Conflictos),
    numlist(1, Dias, Todos),
    maplist(capacidad_del_dia(Horario, Capacidad), Todos),
    label(Ds).

%!  conflicto(?M1:atom, ?M2:atom) is nondet.
%
%   M1 y M2 son materias distintas, M1 antes que M2 en orden alfabético, con
%   al menos un alumno inscripto en las dos. Una respuesta por par.
conflicto(M1, M2) :-
    materia(M1, _, _),
    materia(M2, _, _),
    M1 @< M2,
    once(( inscripcion(L, M1, _),
           inscripcion(L, M2, _) )).

%!  dias_distintos(+Horario:list(pair), +Conflicto:pair) is semidet.
%
%   Las dos materias de Conflicto tienen el examen en días distintos.
dias_distintos(Horario, M1-M2) :-
    memberchk(M1-D1, Horario),
    memberchk(M2-D2, Horario),
    D1 #\= D2.

%!  capacidad_del_dia(+Horario:list(pair), +Capacidad:integer, +Dia:integer)
%!      is semidet.
%
%   Los alumnos inscriptos en las materias que rinden el día Dia no son más
%   que Capacidad. Cada materia aporta sus inscriptos si su día es Dia: la
%   comparación se refleja en una variable 0 o 1.
capacidad_del_dia(Horario, Capacidad, Dia) :-
    maplist(rinde_ese_dia(Dia), Horario, Rinden),
    maplist(cantidad_de_inscriptos, Horario, Cantidades),
    scalar_product(Cantidades, Rinden, #=<, Capacidad).

%!  rinde_ese_dia(+Dia:integer, +MateriaDia:pair, -B) is det.
%
%   B es 1 si la materia rinde el día Dia, y 0 si no.
rinde_ese_dia(Dia, _-D, B) :-
    B #<==> (D #= Dia).
```

```prolog
?- horario(5, 6, Horario).
Horario = [am1-1, alg-2, log-3, am2-4, pp-5, ssl-1, bd-1] ;
...

?- horario(4, 6, Horario).
false.
```

El modelo sigue el [Patrón 27](../patrones.md#27-modelar-restringir-etiquetar): una variable por materia con dominio `1..Dias`;
una restricción `#\=` por par de materias en conflicto; una restricción de
capacidad por día; y el etiquetado al final. La capacidad usa la reificación:
para cada día, cada materia aporta sus inscriptos si su día es ese, y
`scalar_product/4` compara la suma con la capacidad. Cuatro días no alcanzan:
ana (101) está inscripta en cinco materias, que deben rendir en cinco días
distintos. Sintaxis y bases de datos no tienen inscriptos, y rinden cualquier
día.

## 23.14 Buscaminas: deducir dónde están las minas

El jugador de Buscaminas ve las celdas descubiertas, con su número, y las
ocultas. Deducir qué celdas ocultas tienen mina es un problema de
restricciones: cada celda oculta tiene una variable, 1 si tiene mina y 0 si
no, y cada número exige que sus vecinas ocultas sumen ese número.

<!-- ejemplo: capitulo-23/buscaminas.pl predicado: modelo/2 restringir/4 variable_de/3 clasificar/3 consulta: deducir(["#100", "1211", "01##", "01##"], Seguras, Minas). -->
```prolog
%!  modelo(+Lineas:list(string), -Ocultas:list(pair)) is semidet.
%
%   Ocultas son pares Celda-B, uno por celda oculta, con B en 0..1 y
%   restringido por los números de las celdas descubiertas.
%   Falla si algún número no se puede cumplir.
modelo(Lineas, Ocultas) :-
    length(Lineas, Filas),
    Lineas = [Primera|_],
    string_length(Primera, Columnas),
    findall((F-C)-X,
            ( nth1(F, Lineas, Linea),
              string_chars(Linea, Cs),
              nth1(C, Cs, X) ),
            Celdas),
    findall(Celda-_, member(Celda-'#', Celdas), Ocultas),
    pairs_values(Ocultas, Bs),
    Bs ins 0..1,
    findall(Celda-N, ( member(Celda-X, Celdas),
                       atom_number(X, N) ), Numeros),
    maplist(restringir(Filas, Columnas, Ocultas), Numeros).

%!  restringir(+Filas, +Columnas, +Ocultas:list(pair), +Numero:pair)
%!      is semidet.
%
%   Numero es Celda-N: las celdas ocultas vecinas de Celda suman N minas.
%   Falla si ya se sabe que no pueden sumarlas.
restringir(Filas, Columnas, Ocultas, Celda-N) :-
    findall(V, vecina(Filas, Columnas, Celda, V), Vecinas),
    convlist(variable_de(Ocultas), Vecinas, Bs),
    sum(Bs, #=, N).

%!  variable_de(+Ocultas:list(pair), +Celda:pair, -B) is semidet.
%
%   B es la variable de Celda en Ocultas. Falla si Celda no está oculta. Las
%   variables se buscan con memberchk/2, fuera de findall/3, que copiaría
%   las variables en lugar de devolver las mismas.
variable_de(Ocultas, Celda, B) :-
    memberchk(Celda-B, Ocultas).

%!  clasificar(+Ocultas:list(pair), -Seguras:list, -Minas:list) is det.
%
%   Seguras son las celdas que no pueden tener mina, y Minas las que no
%   pueden no tenerla, según las restricciones de Ocultas.
clasificar(Ocultas, Seguras, Minas) :-
    pairs_values(Ocultas, Bs),
    findall(C, ( member(C-B, Ocultas),
                 \+ ( B = 1, label(Bs) ) ), Seguras),
    findall(C, ( member(C-B, Ocultas),
                 \+ ( B = 0, label(Bs) ) ), Minas).
```

```prolog
?- deducir(["#100", "1211", "01##", "01##"], Seguras, Minas).
Seguras = [3-4, 4-3],
Minas = [1-1, 3-3].

?- deducir(["#100", "1211", "01##", "01##"], 2, Seguras, Minas).
Seguras = [3-4, 4-3, 4-4],
Minas = [1-1, 3-3].
```

Una celda es segura si ninguna solución le pone mina: `\+ ( B = 1, label(Bs) )`.
Es una mina si ninguna solución la deja libre. (4, 4) no toca ningún número, y
sin más información puede tener mina o no; sabiendo que el tablero tiene dos
minas, queda libre.

Dos detalles del modelo evitan errores que no producen ningún mensaje. Las
restricciones se plantean con `maplist/2` y no con `forall/2`: `forall/2` es
`\+ (C, \+ A)`, y la doble negación **deshace** todo lo que hizo, incluidas las
restricciones. Y las variables de las vecinas se buscan con `memberchk/2` fuera
de `findall/3`: `findall/3` devuelve **copias** de las variables, y una
restricción sobre una copia no restringe la original. Con cualquiera de los dos
errores, el modelo no tiene restricciones, y todas las celdas quedan sin
deducir.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta: `X #= 2 * 3.` ·
   `6 #= 2 * X.` · `X #> 3, X #< 6, label([X]).` · `X #= Y + 1, Y = 4.` ·
   `X in 1..3, X #\= 2, fd_dom(X, D).`
2. **(1)** Escribir `celsius_fahrenheit(C, F)` con `#=`, para temperaturas
   enteras, que funcione en los dos sentidos.
3. ★ **(2)** Escribir `cambio(Monto, [U, C, D])`: U monedas de 1, C de 5 y D de
   10 que suman Monto, con la menor cantidad de monedas.
4. **(2)** Escribir `cuadrado_magico/1`: un cuadrado de 3 × 3 con los números del
   1 al 9 cuyas filas, columnas y diagonales suman 15. ¿Cuántos hay?
5. ★ **(2)** Escribir `sudoku/1` para sudokus de 4 × 4, y resolver
   `[[1, _, _, _], [_, _, 3, _], [_, 4, _, _], [_, _, _, 2]]`.
6. **(2)** Escribir `dos_de_cada/1`: seis valores entre 1 y 3, con exactamente
   dos de cada uno, con `global_cardinality/2`. ¿Cuántas listas hay?
7. ★ **(2)** Escribir `exactamente(N, Xs, V)` con reificación, y usarlo para
   contar los resultados de tres dados con exactamente dos seis.
8. **(3)** Resolver TO + GO = OUT. Contar las soluciones de SEND + MORE = MONEY
   con y sin la restricción de que S y M no sean cero.
9. ★ **(2)** Escribir `colorear_gyp/2`, el coloreo de la [sección 23.8](#238-coloreo-de-un-mapa) con
   generar y probar, y comparar su tiempo con el de `colorear/2`.
10. **(2)** Medir el tiempo de la primera solución de 30 reinas con
    `labeling([ff], …)` y con `labeling([leftmost], …)`.
11. **(2)** Escribir `todos_distintos/1` con `dif/2`. ¿Qué ocurre con
    `all_different/1` sobre una lista de átomos?
12. ★ **(3)** Escribir `probabilidades(Lineas, Pares)` para el Buscaminas: la
    fracción de las soluciones en las que cada celda oculta tiene mina.
13. **(2)** Escribir `consistente(Lineas)`: los números del tablero visible se
    pueden cumplir.
14. ★ **(2)** Escribir `horario_minimo(Capacidad, Dias, Horario)`: la menor
    cantidad de días con la que hay un horario.
15. **(2)** Escribir `horario_separado/3`, que exige al menos dos días entre los
    exámenes de dos materias con un alumno en común. ¿Cuántos días hacen falta?
16. **(3)** Escribir `horario_con_aulas(Capacidades, Dias, Horario)`: cada examen
    tiene un día y un aula; un aula tiene a lo sumo un examen por día, y los
    inscriptos caben en ella.

## Resumen

| | |
|---|---|
| `#=`, `#\=`, `#<`, …, `abs/1` | restricciones aritméticas sobre enteros, en todos los sentidos; `abs/1`, el valor absoluto, también en `is/2` |
| `in/2`, `ins/2`, `fd_dom/2` | dominios de las variables |
| `label/1`, `labeling/2` | etiquetar al final; `ff`, `min`, `max` |
| `all_different/1` | valores distintos |
| `sum/3`, `scalar_product/4` | sumas y sumas ponderadas |
| `global_cardinality/2` | cuántas veces aparece cada valor |
| `B #<==> C` | reificación: la verdad de C en la variable B |
| `dif/2` | desigualdad que se posterga, para cualquier término |
| `sat/1`, `taut/2` | `library(clpb)`: restricciones booleanas; si una fórmula es tautología |
| generar y probar, `permutation/2` | se descubre el fracaso tarde; restringir lo descubre antes |
| **Patrones 26, 27** | contar con reificación; modelar, restringir, etiquetar |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| El calendario de exámenes como módulo del proyecto | [capítulo 24](../capitulo-24-modulos-y-organizacion/index.md) |
| El Buscaminas completo, con la deducción de celdas seguras | [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md) |
| Búsqueda: las reinas con una lista de visitados | [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) |
