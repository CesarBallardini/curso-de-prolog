# Funciones de evaluación y orden de las jugadas

Esta página contiene la sección
[41.4](index.md#414-funciones-de-evaluacion-y-orden-de-las-jugadas) del
[capítulo 41](index.md): la evaluación de las posiciones por líneas
abiertas, y la poda con las jugadas ordenadas, medida. El ejemplo está en
`orden.pl`, en `ejemplos/capitulo-41/`, con sus pruebas, y corre en SWISH.

## Funciones de evaluación y orden de las jugadas

Una búsqueda con límite depende de la evaluación de las posiciones del
límite. Una evaluación clásica del ta-te-ti cuenta las **líneas abiertas**:
las que x todavía puede completar, porque no tienen ninguna o, menos las
que o todavía puede completar. `orden.pl` la define:

<!-- ejemplo: capitulo-41/orden.pl predicado: evaluar/3 abierta/3 consulta: evaluar(tateti(3), pos([v,v,v, v,x,v, v,v,v], o), V). -->
```prolog
%!  evaluar(+Juego, +Posicion, -Valor:integer) is det.
%
%   Valor es la cantidad de líneas de Posicion en las que no hay ninguna o,
%   que x todavía puede completar, menos la cantidad de líneas en las que
%   no hay ninguna x.
evaluar(Juego, pos(Tablero, _), Valor) :-
    lineas(Juego, Lineas),
    aggregate_all(count, ( member(L, Lineas), abierta(Tablero, o, L) ), X),
    aggregate_all(count, ( member(L, Lineas), abierta(Tablero, x, L) ), O),
    Valor is X - O.

%!  abierta(+Tablero:list, +Rival, +Linea:list(integer)) is semidet.
%
%   Ninguna casilla de Linea tiene la marca de Rival.
abierta(Tablero, Rival, Linea) :-
    \+ ( member(C, Linea),
         marca(Tablero, Rival, C) ).
```

```prolog
?- evaluar(tateti(3), pos([v,v,v, v,x,v, v,v,v], o), V).
V = 4.

?- evaluar(tateti(3), pos([x,v,v, v,v,v, v,v,v], o), V).
V = 3.

?- evaluar(tateti(3), pos([v,x,v, v,v,v, v,v,v], o), V).
V = 2.
```

El centro está en cuatro líneas, una esquina en tres y un borde en dos: la
evaluación prefiere el centro. Con ella, la búsqueda a profundidad 2 elige
el centro, donde con la evaluación nula elegía la casilla 1:

```prolog
?- inicial(tateti(3), P), alfabeta(natural, tateti(3), P, 2, J, V, N).
P = pos([v, v, v, v, v, v, v, v|...], x),
J = 5,
V = 1,
N = 36.
```

Una evaluación es una estimación, y en los juegos de interés no puede ser
exacta: si lo fuera, bastaría buscar una sola jugada hacia adelante. Bratko
señala dos consecuencias. La evaluación es más confiable en las posiciones
tranquilas que en las que tienen amenazas pendientes, y por eso los
programas de ajedrez extienden la búsqueda más allá del límite mientras
haya capturas. Y una búsqueda con límite puede preferir una jugada que solo
posterga una pérdida hasta más allá del límite, donde no la ve: es el
**efecto horizonte**.

### El orden de las jugadas

La poda corta más cuanto antes aparece la mejor jugada: si la primera
jugada de max ya alcanza la cota de min, las demás no se buscan. Bratko
cita el resultado conocido: con las jugadas siempre en el mejor orden, la
poda evalúa del orden de la raíz cuadrada de las posiciones que evalúa
minimax, y en el mismo tiempo busca el doble de profundo; con las jugadas
en el peor orden, no poda nada. `orden.pl` agrega a la poda un argumento,
el orden en que se buscan las jugadas de cada posición: `natural`, el de
`jugada/4`; `mejores`, las mejores primero según `evaluar/3`; o `peores`,
al revés.

<!-- ejemplo: capitulo-41/orden.pl predicado: ordenar/5 por_evaluacion/4 clave/4 -->
```prolog
%!  ordenar(+Orden, +Juego, +Lado, +Hijos0:list, -Hijos:list) is det.
%
%   Hijos son los pares Jugada-Posicion de Hijos0 en Orden. Con mejores,
%   primero los de mayor evaluación si Lado es max, y los de menor si es
%   min; con peores, al revés. Entre evaluaciones iguales se mantiene el
%   orden natural.
ordenar(natural, _, _, Hijos, Hijos).
ordenar(mejores, Juego, Lado, Hijos0, Hijos) :-
    por_evaluacion(Juego, Lado, Hijos0, Hijos).
ordenar(peores, Juego, Lado, Hijos0, Hijos) :-
    otro_lado(Lado, Rival),
    por_evaluacion(Juego, Rival, Hijos0, Hijos).

%!  por_evaluacion(+Juego, +Lado, +Hijos0:list, -Hijos:list) is det.
%
%   Hijos son los de Hijos0, primero los mejores para Lado según evaluar/3.
por_evaluacion(Juego, Lado, Hijos0, Hijos) :-
    map_list_to_pairs(clave(Lado, Juego), Hijos0, Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Hijos).

%!  clave(+Lado, +Juego, +Hijo, -Clave:integer) is det.
%
%   Clave ordena de menor a mayor los hijos del mejor al peor para Lado.
clave(max, Juego, _-P, Clave) :-
    evaluar(Juego, P, V),
    Clave is -V.
clave(min, Juego, _-P, V) :-
    evaluar(Juego, P, V).
```

`por_evaluacion/4` es el ordenamiento con claves de la
[sección 22.4](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#224-pares-y-keysort2):
`keysort/2` es estable, y las jugadas de igual evaluación conservan el
orden natural. El resto de `orden.pl` es la poda de `alfabeta.pl` con el
orden como argumento, que `acotado/10` aplica a las jugadas antes de
buscarlas. Sobre el tablero vacío del ta-te-ti, hasta el final:

```prolog
?- inicial(tateti(3), P), alfabeta(mejores, tateti(3), P, 9, J, V, N).
P = pos([v, v, v, v, v, v, v, v|...], x),
J = 5,
V = 0,
N = 6010.

?- inicial(tateti(3), P), alfabeta(peores, tateti(3), P, 9, J, V, N).
P = pos([v, v, v, v, v, v, v, v|...], x),
J = 2,
V = 0,
N = 34178.
```

El valor es el mismo con los tres órdenes; la jugada elegida es la primera
de las mejores en cada orden, y por eso cambia. Los nodos y las inferencias,
medidos en esta máquina:

| Tablero, profundidad | Orden | Nodos | Inferencias | Segundos |
|---|---|---:|---:|---:|
| 3 × 3, hasta el final | natural | 20 866 | 3 034 029 | 0,4 |
| 3 × 3, hasta el final | mejores | 6 010 | 3 173 747 | 0,4 |
| 3 × 3, hasta el final | peores | 34 178 | 16 070 067 | 2,0 |
| 4 × 4, profundidad 6 | natural | 41 330 | 19 511 659 | 2,8 |
| 4 × 4, profundidad 6 | mejores | 8 669 | 20 887 386 | 3,5 |
| 4 × 4, profundidad 7 | natural | 209 518 | 96 264 149 | 13,8 |
| 4 × 4, profundidad 7 | mejores | 40 171 | 55 026 724 | 7,8 |

Ordenar reduce los nodos a la cuarta o la quinta parte, pero cuesta:
evaluar todas las jugadas de cada posición antes de buscarlas. En el
ta-te-ti de 3 × 3 y en el de 4 × 4 a profundidad 6, ese costo supera la
ganancia, porque `evaluar/3` recorre todas las líneas dos veces y cuesta más
que visitar un nodo. A profundidad 7, los nodos ahorrados crecen más que el
costo de ordenar, y la búsqueda ordenada tarda algo más de la mitad. El
[ejercicio 8](index.md#ejercicios) ordena con una clave más barata.
