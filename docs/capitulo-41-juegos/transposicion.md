# Tablas de transposición con tabulación

Esta página contiene la sección
[41.6](index.md#416-tablas-de-transposicion-con-tabulacion) del
[capítulo 41](index.md): minimax con las posiciones ya buscadas guardadas en
tablas. El ejemplo está en `transposicion.pl`, en `ejemplos/capitulo-41/`,
con sus pruebas, y corre en SWISH.

## Tablas de transposición con tabulación

Una **transposición** es una posición a la que se llega por más de un
orden de jugadas: x en 1, o en 2 y x en 5 lleva al mismo tablero que x en
5, o en 2 y x en 1. Minimax y la poda la buscan cada vez que la encuentran,
y el árbol del ta-te-ti tiene 549 946 nodos para mucho menos posiciones
distintas. Una **tabla de transposición** guarda el valor de cada posición
ya buscada. Escrita a mano, es la memorización del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#205-memorizacion),
con su estado global; con la tabulación del
[capítulo 39](../capitulo-39-tabulacion/index.md) es una directiva sobre
minimax sin límite de profundidad:

<!-- ejemplo: capitulo-41/transposicion.pl fragmento: :- table valor/3. .. min_list(Valores, Valor). -->
```prolog
:- table valor/3.

%!  valor(+Juego, +Posicion, -Valor) is det.
%
%   Valor es el valor minimax de Posicion, buscando hasta el final de la
%   partida. Está tabulado: cada posición se busca una sola vez.
valor(Juego, Posicion, Valor) :-
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor)
    ;   turno(Juego, Posicion, Lado),
        findall(V, ( jugada(Juego, Posicion, _, P),
                     valor(Juego, P, V) ), Valores),
        extremo(Lado, Valores, Valor)
    ).

%!  extremo(+Lado, +Valores:list(number), -Valor:number) is det.
%
%   Valor es el mayor de Valores si Lado es max, y el menor si es min.
extremo(max, Valores, Valor) :-
    max_list(Valores, Valor).
extremo(min, Valores, Valor) :-
    min_list(Valores, Valor).
```

`max_list/2` y `min_list/2`, de `library(lists)`, dan el mayor y el menor
elemento de una lista de números. `valor/3` no lleva la jugada ni el contador de nodos: una tabla guarda las
respuestas de una llamada, y el valor de una posición es lo único que no
depende del camino por el que se llegó a ella. La jugada se elige después,
con los valores ya tabulados, y `posiciones/1` cuenta las tablas:

<!-- ejemplo: capitulo-41/transposicion.pl predicado: jugada_optima/4 posiciones/1 consulta: inicial(tateti(3), P), jugada_optima(tateti(3), P, J, V). -->
```prolog
%!  jugada_optima(+Juego, +Posicion, -Jugada, -Valor) is semidet.
%
%   Jugada es la primera jugada de Posicion que lleva a una posición del
%   mismo valor que Posicion, Valor. Falla si la partida terminó. valor/3
%   se llama con el valor libre: con el valor ligado, la llamada sería otra
%   variante y abriría otra tabla.
jugada_optima(Juego, Posicion, Jugada, Valor) :-
    \+ fin(Juego, Posicion, _),
    valor(Juego, Posicion, Valor),
    once(( jugada(Juego, Posicion, Jugada, P),
           valor(Juego, P, V),
           V =:= Valor )).

%!  posiciones(-Cantidad:integer) is det.
%
%   Cantidad es la cantidad de tablas de valor/3: las posiciones distintas
%   buscadas desde el último abolish_all_tables/0. current_table/2 busca la
%   variante exacta que recibe, y por eso la llamada va con la variable
%   libre y el filtro después.
posiciones(Cantidad) :-
    aggregate_all(count,
                  ( current_table(Variante, _),
                    Variante = valor(_, _, _) ),
                  Cantidad).
```

```prolog
?- inicial(tateti(3), P), jugada_optima(tateti(3), P, J, V).
P = pos([v, v, v, v, v, v, v, v|...], x),
J = 1,
V = 0.

?- posiciones(N).
N = 5478.

?- findall(C-V, (jugada(tateti(3), pos([x,v,v, v,v,v, v,v,v], o), C, P), valor(tateti(3), P, V)), Vs).
Vs = [2-102, 3-102, 4-102, 5-0, 6-102, 7-102, 8-102, 9-102].
```

El ta-te-ti tiene 5 478 posiciones alcanzables, y cada una se busca una
sola vez. La última consulta da el valor exacto de cada respuesta de o a
una esquina: solo el centro empata. La poda no puede dar esa lista, porque
fuera de la mejor jugada devuelve cotas.

Un detalle de la primera versión de `jugada_optima/4`: llamaba
`valor(Juego, P, Valor)` con `Valor` ya ligado, y `posiciones/1` contaba
5 479 tablas. Una llamada con un argumento ligado es otra **variante**, y
abre su propia tabla; la versión final llama con el valor libre y compara
después. Por la misma razón, `current_table/2` recibe una variable y
`posiciones/1` filtra después: con el patrón `valor(_, _, _)`, busca esa
variante exacta y no encuentra ninguna.

Medido en esta máquina, desde el tablero vacío y con las tablas borradas:

| Búsqueda | Nodos o tablas | Inferencias | Segundos |
|---|---:|---:|---:|
| minimax | 549 946 nodos | 71 540 279 | 9,8 |
| poda alfa-beta | 20 866 nodos | 3 046 624 | 0,4 |
| minimax tabulado | 5 478 tablas | 1 132 194 | 0,2 |

Una segunda llamada con las mismas tablas cuesta 3 inferencias: la
respuesta ya está. Las tablas duran lo que dura el programa, y se borran
con `abolish_all_tables/0`; las pruebas lo hacen en el `setup` de la
unidad, para que cada una mida desde cero.

### Con un límite de profundidad

En el tablero de 4 × 4 no hay tabla que alcance para buscar hasta el
final. `valor_limitado/4` es minimax con límite y la evaluación por líneas
abiertas, tabulado con la profundidad restante como argumento: una
posición a la que se llega por dos caminos con la misma profundidad
restante se busca una vez.

<!-- ejemplo: capitulo-41/transposicion.pl predicado: valor_limitado/4 consulta: inicial(tateti(4), P), valor_limitado(tateti(4), P, 3, V). -->
```prolog
%!  valor_limitado(+Juego, +Posicion, +Profundidad:integer, -Valor) is det.
%
%   Valor es el valor minimax de Posicion buscando Profundidad jugadas
%   hacia adelante, con evaluar/3 en el límite. Está tabulado: una posición
%   a la que se llega por dos caminos con la misma profundidad restante se
%   busca una sola vez.
valor_limitado(Juego, Posicion, Profundidad, Valor) :-
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor)
    ;   Profundidad =:= 0
    ->  evaluar(Juego, Posicion, Valor)
    ;   turno(Juego, Posicion, Lado),
        Profundidad1 is Profundidad - 1,
        findall(V, ( jugada(Juego, Posicion, _, P),
                     valor_limitado(Juego, P, Profundidad1, V) ), Valores),
        extremo(Lado, Valores, Valor)
    ).
```

| Profundidad | Tablas | Segundos | Nodos de minimax | Nodos de la poda | Segundos de la poda |
|---:|---:|---:|---:|---:|---:|
| 3 | 1 937 | 0,19 | 3 617 | 345 | 0,03 |
| 4 | 12 857 | 1,18 | 47 297 | 1 478 | 0,09 |
| 5 | 56 537 | 6,1 | 571 457 | 10 792 | 0,67 |

La tabla reduce los nodos de minimax a la décima parte a profundidad 5,
pero la poda visita cinco veces menos todavía, y cada tabla cuesta más que
un nodo. Con límite, las transposiciones son pocas comparadas con lo que la
poda descarta. Los programas de ajedrez usan las dos cosas a la vez: la
tabla guarda, junto con el valor, si es exacto o una cota, y con qué
profundidad se obtuvo. La tabulación de Prolog guarda respuestas a
llamadas, y con las cotas como argumentos cada intervalo distinto es otra
variante; el [ejercicio 11](index.md#ejercicios) lo mide. El
[ejercicio 10](index.md#ejercicios) reduce las tablas del ta-te-ti
tabulando una sola posición por cada grupo de posiciones simétricas.
