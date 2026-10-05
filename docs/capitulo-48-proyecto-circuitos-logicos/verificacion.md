# Verificar con library(clpb)

Esta página contiene la sección [48.4](index.md#484-verificar-con-libraryclpb) del
[capítulo 48](index.md): la tercera conducta de la descripción de los circuitos,
que convierte cada compuerta en una restricción booleana, y la verificación de
equivalencias con `library(clpb)`. El ejemplo está en `verificar.pl`, en
`ejemplos/capitulo-48/`, con sus pruebas; carga los módulos `circuitos` y
`formulas`, y se ejecuta localmente.

## Verificar con `library(clpb)`

`library(clpb)` representa cada fórmula con un diagrama de decisión binario,
una forma **canónica**: dos fórmulas equivalentes tienen el mismo diagrama.
Markus Triska describe esa implementación en «The Boolean Constraint Solver
of SWI-Prolog: System Description» (FLOPS 2016,
[versión del autor](https://www.metalevel.at/swiclpb.pdf)).
`taut/2` decide si una fórmula es verdadera para todos los valores de sus
variables sin recorrer la tabla. `verificar.pl` usa la misma descripción una
tercera vez, con una conducta que impone a cada compuerta una restricción:
su salida equivale a la fórmula de la versión 3 sobre sus entradas, que
ahora son variables booleanas.

<!-- ejemplo: capitulo-48/verificar.pl predicado: restriccion/4 modelo/3 equivalentes/2 -->
```prolog
%!  restriccion(+Ruta:list, +Tipo, +Entradas:list, ?Salida) is det.
%
%   Salida y Entradas son variables booleanas de library(clpb), y la
%   restricción impone que Salida equivalga a la fórmula de la compuerta
%   Tipo sobre las Entradas.
restriccion(Ruta, Tipo, Entradas, Salida) :-
    simbolica(Ruta, Tipo, Entradas, Formula),
    sat(Salida =:= Formula).

%!  modelo(+Circuito, -Entradas:list, -Salidas:list) is det.
%
%   Entradas y Salidas son variables booleanas, y las restricciones de
%   las compuertas de Circuito las relacionan.
modelo(Circuito, Entradas, Salidas) :-
    circuito(Circuito, NEs, NSs),
    same_length(NEs, Entradas),
    same_length(NSs, Salidas),
    once(simular(restriccion, Circuito, Entradas, Salidas)).

%!  equivalentes(+Circuito1, +Circuito2) is semidet.
%
%   Los dos circuitos tienen tantas entradas y salidas uno como el otro, y
%   con las mismas entradas dan las mismas salidas, en todos los casos.
equivalentes(C1, C2) :-
    modelo(C1, Entradas, Salidas1),
    modelo(C2, Entradas, Salidas2),
    maplist(equivalente, Salidas1, Salidas2).
```

`modelo/3` crea las variables de las entradas y las salidas, y deja las
restricciones de todas las compuertas; las variables de los cables internos
no aparecen en el resultado. `equivalentes/2` construye los modelos de los
dos circuitos con las mismas variables de entrada, y pregunta con `taut/2` si
cada salida del primero equivale a la del segundo. El `once/1` de `modelo/3`
descarta la alternativa que deja la simulación, que con restricciones no
tiene otra respuesta. El archivo agrega tres circuitos al módulo
`circuitos`, con cláusulas `multifile`: una compuerta XOR sola; un sumador
que calcula el acarreo como mayoría, con tres compuertas AND y dos OR; y el
mismo sumador con un cable mal conectado:

<!-- ejemplo: capitulo-48/verificar.pl fragmento: % El mismo, con la segunda .. circuitos:componente(sumador_error, o2, or, [u, r], [co]). -->
```prolog
% El mismo, con la segunda entrada de y2 conectada a b en lugar de ci.
circuitos:circuito(sumador_error, [a, b, ci], [s, co]).
circuitos:componente(sumador_error, x1, xor, [a, b], [t]).
circuitos:componente(sumador_error, x2, xor, [t, ci], [s]).
circuitos:componente(sumador_error, y1, and, [a, b], [p]).
circuitos:componente(sumador_error, y2, and, [a, b], [q]).
circuitos:componente(sumador_error, y3, and, [b, ci], [r]).
circuitos:componente(sumador_error, o1, or, [p, q], [u]).
circuitos:componente(sumador_error, o2, or, [u, r], [co]).
```

```prolog
?- equivalentes(sumador, sumador_mayoria).
true.

?- equivalentes(xor_nand, xor1).
true.

?- equivalentes(sumador, sumador_error).
false.
```

La suma de productos no podía demostrar la primera equivalencia; `taut/2` lo
hace sin enumerar entradas. Cuando dos circuitos no son equivalentes, lo útil
es una entrada que los distinga. `diferencia/3` exige con `sat/1` que alguna
salida difiera —la disyunción, con `+(Lista)`, de las disyunciones
exclusivas de las salidas correspondientes— y etiqueta las entradas con
`labeling/1`:

<!-- ejemplo: capitulo-48/verificar.pl predicado: diferencia/3 cuantas/4 -->
```prolog
%!  diferencia(+Circuito1, +Circuito2, -Entradas:list) is nondet.
%
%   Entradas es una combinación de valores con la que alguna salida de
%   Circuito1 es distinta de la misma salida de Circuito2.
diferencia(C1, C2, Entradas) :-
    modelo(C1, Entradas, Salidas1),
    modelo(C2, Entradas, Salidas2),
    maplist([X, Y, X # Y]>>true, Salidas1, Salidas2, Distintas),
    sat(+(Distintas)),
    labeling(Entradas).

%!  cuantas(+Circuito, +Salida, +Valor, -N:integer) is det.
%
%   N es la cantidad de combinaciones de valores de las entradas de
%   Circuito con las que la salida Salida vale Valor.
cuantas(Circuito, Salida, Valor, N) :-
    circuito(Circuito, _, NSs),
    nth1(I, NSs, Salida),
    !,
    modelo(Circuito, Entradas, Salidas),
    nth1(I, Salidas, S),
    sat(S =:= Valor),
    sat_count(+[1|Entradas], N).
```

```prolog
?- diferencia(sumador, sumador_error, Es).
Es = [1, 0, 1].

?- cuantas(sumador3, c, 1, N).
N = 28.
```

Con a = 1, b = 0 y ci = 1, el sumador correcto da acarreo 1 y el erróneo 0:
la compuerta `y2` recibe b en lugar de ci. Es la única entrada con la que
difieren, y `diferencia/3` la encuentra sin simular las otras siete.
`cuantas/4` cuenta con `sat_count/2` las combinaciones de entradas con las
que una salida toma un valor: el acarreo final del sumador de tres bits es 1
en 28 de las 64 sumas, las que dan 8 o más.

!!! question "Actividad"
    En `sumador_error`, la compuerta `y2` recibe `[a, b]`. Predecir qué
    entradas daría `diferencia/3` si en cambio recibiera `[b, ci]`, igual
    que `y3`, y si recibiera `[a, a]`. Comprobarlo en una copia de
    `verificar.pl`, y comprobar también la predicción con
    `tabla_de_verdad/2`.

Las cuatro versiones tratan circuitos **combinacionales**: sus salidas
dependen solo de las entradas del momento. El biestable de la
[sección 48.1](index.md#481-compuertas-como-tablas-circuitos-como-reglas) mostró que un circuito con realimentación puede guardar un bit,
pero `simular/3` solo enumera sus estados estables, y `formula/3` lo
rechaza. Falta el tiempo.
