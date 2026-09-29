# Profundización progresiva con límite de tiempo

Esta página contiene la sección
[41.5](index.md#415-profundizacion-progresiva-con-limite-de-tiempo) del
[capítulo 41](index.md): la búsqueda que profundiza mientras dura el tiempo
de una jugada, y las jugadas buscadas en paralelo. Los ejemplos están en
`profundizacion.pl`, que corre en SWISH, y en `paralelo.pl`, que crea hilos
y por eso no corre allí; los dos están en `ejemplos/capitulo-41/`, con sus
pruebas.

## Profundización progresiva con límite de tiempo

Un programa que juega tiene un tiempo para cada jugada, no una
profundidad, y cuánto tarda la poda a una profundidad dada depende de la
posición. La **profundización progresiva** que describe Bratko en «Game
Playing» busca con profundidad 1, después con 2, después con 3, y así hasta
que se acaba el tiempo; juega la mejor jugada de la última búsqueda que
terminó. Es la profundización iterativa de la
[sección 40.4](../capitulo-40-busqueda-y-planificacion/index.md#404-profundidad-limitada-y-profundizacion-iterativa),
con otra condición de parada: el reloj.

<!-- ejemplo: capitulo-41/profundizacion.pl predicado: profundizar/6 iterar/6 completa/4 primero/6 consulta: profundizar(tateti(3), pos([x,o,v, v,x,v, v,v,o], o), 10, J, V, D). -->
```prolog
%!  profundizar(+Juego, +Posicion, +Segundos:number, -Jugada, -Valor,
%!              -Profundidad:integer) is det.
%
%   Jugada y Valor son los de la búsqueda alfa-beta más profunda que
%   termina en Segundos, y Profundidad es su profundidad. Deja de
%   profundizar antes si la búsqueda llega al final de la partida en todas
%   las ramas o encuentra una victoria. Si ni la búsqueda de profundidad 1
%   termina a tiempo, Jugada es ninguna y Profundidad es 0.
profundizar(Juego, Posicion, Segundos, Jugada, Valor, Profundidad) :-
    get_time(Ahora),
    Limite is Ahora + Segundos,
    iterar(Juego, Posicion, 1, Limite, r(ninguna, 0, 0),
           r(Jugada, Valor, Profundidad)).

%!  iterar(+Juego, +Posicion, +D:integer, +Limite:float, +Previo,
%!         -Resultado) is det.
%
%   Resultado es r(Jugada, Valor, Profundidad) de la última búsqueda que
%   termina antes del instante Limite, desde la de profundidad D; Previo es
%   el de la búsqueda de profundidad D - 1.
iterar(Juego, Posicion, D, Limite, Previo, Resultado) :-
    Previo = r(Primera, _, _),
    get_time(Ahora),
    Resto is Limite - Ahora,
    (   Resto > 0,
        catch(call_with_time_limit(Resto,
                  primero(Juego, Posicion, D, Primera, Jugada, Valor)),
              time_limit_exceeded,
              fail)
    ->  Actual = r(Jugada, Valor, D),
        (   completa(Juego, Posicion, D, Valor)
        ->  Resultado = Actual
        ;   D1 is D + 1,
            iterar(Juego, Posicion, D1, Limite, Actual, Resultado)
        )
    ;   Resultado = Previo
    ).

%!  completa(+Juego, +Posicion, +D:integer, +Valor:number) is semidet.
%
%   Una búsqueda de profundidad D desde Posicion no cambia si se profundiza
%   más: D alcanza para llenar el tablero, o Valor es una victoria.
completa(tateti(_), pos(Tablero, _), D, Valor) :-
    (   include(==(v), Tablero, Vacias),
        length(Vacias, K),
        D >= K
    ->  true
    ;   abs(Valor) >= 100
    ).

%!  primero(+Juego, +Posicion, +D:integer, +Primera, -Jugada, -Valor)
%!      is det.
%
%   Como alfabeta/6 con profundidad D, buscando primero la jugada Primera,
%   si es una de las de Posicion.
primero(Juego, Posicion, D, Primera, Jugada, Valor) :-
    findall(J-P, jugada(Juego, Posicion, J, P), Hijos0),
    (   selectchk(Primera-P1, Hijos0, Resto)
    ->  Hijos = [Primera-P1|Resto]
    ;   Hijos = Hijos0
    ),
    turno(Juego, Posicion, Lado),
    D1 is D - 1,
    cotas(Hijos, Juego, Lado, D1, -inf, inf, ninguna, Jugada, Valor, 1, _).
```

`call_with_time_limit(Segundos, Meta)`, de `library(time)`, ejecuta `Meta`
como `once/1`, y si no termina en `Segundos` la interrumpe con la excepción
`time_limit_exceeded`; `iterar/6` la atrapa con `catch/3`
([capítulo 25](../capitulo-25-errores-y-excepciones/index.md)) y devuelve el resultado de la búsqueda anterior, que terminó. El
resultado viaja como argumento, `r(Jugada, Valor, Profundidad)`, y la
búsqueda interrumpida no deja nada a medio escribir. `completa/4` detiene
la profundización antes del tiempo si la búsqueda ya llega al final de la
partida en todas las ramas, o si encontró una victoria; es la única parte
que conoce el ta-te-ti, por la cantidad de casillas vacías.

`primero/6` aprovecha la búsqueda anterior, como propone Bratko: busca
primero la jugada que la anterior eligió, que suele seguir siendo buena, y
con ella la poda corta más desde el principio. La raíz se busca con
`cotas/11` de la poda, con las jugadas ya reordenadas.

```prolog
?- profundizar(tateti(3), pos([x,o,v, v,x,v, v,v,o], o), 10, J, V, D).
J = 4,
V = 0,
D = 5.

?- profundizar(tateti(3), pos([x,o,v, v,x,v, v,v,o], x), 10, J, V, D).
J = 4,
V = 102,
D = 3.

?- profundizar(tateti(3), pos([x,o,v, v,x,v, v,v,o], x), 0, J, V, D).
J = ninguna,
V = D, D = 0.
```

En la primera posición la búsqueda llega a las cinco casillas vacías y se
detiene: la jugada, 4, empata como la 3 que eligió la poda sin
profundización, porque la búsqueda de profundidad 4 la dejó primera. En la
segunda, la profundidad 3 encuentra la victoria de x y no sigue. Sin
tiempo, no hay jugada.

En el tablero de 4 × 4 vacío el tiempo sí decide. Medido en esta máquina,
con `time/1`:

| Tiempo | Profundidad alcanzada | Jugada | Valor |
|---:|---:|---:|---:|
| 0,001 s | 1 | 1 | 3 |
| 1 s | 5 | 1 | 2 |
| 5 s | 6 | 1 | 0 |
| 10 s | 6 | 1 | 0 |

La búsqueda de profundidad 7 tarda 13,8 segundos: con 10 no termina, y se
juega la de profundidad 6. El tiempo de la búsqueda interrumpida se pierde,
y es el costo de la técnica, junto con repetir las profundidades menores.
Esa repetición cuesta poco: las búsquedas de profundidad 1 a 5 suman
6,5 millones de inferencias, y la de profundidad 6 sola, 19,5 millones.
Cada profundidad más multiplica el costo por un factor de cuatro a cinco,
y la suma de las anteriores es una fracción de la última.

Los valores alternan con la profundidad: 3 con profundidad 1, 0 con 2, 3
con 3, 0 con 4, 2 con 5 y 0 con 6. El [ejercicio 12](index.md#ejercicios)
pide explicar por qué.

## Jugadas en paralelo

La poda es secuencial: cada jugada se busca con las cotas que dejaron las
anteriores. Para repartir la búsqueda entre varios núcleos, `paralelo.pl`
busca cada jugada de la raíz en un hilo con `concurrent_maplist/3`
([sección 37.4](../capitulo-37-concurrencia-y-paralelismo/index.md#374-paralelismo-de-datos)),
cada una con sus propias cotas, y elige al final:

<!-- ejemplo: capitulo-41/paralelo.pl predicado: en_paralelo/5 valor_hijo/4 elegir/3 -->
```prolog
%!  en_paralelo(+Juego, +Posicion, +Profundidad:integer, -Jugada, -Valor)
%!      is semidet.
%
%   Jugada y Valor son los que da alfabeta/6 con Profundidad, calculados
%   con una búsqueda por jugada, cada una en un hilo. Falla si la partida
%   terminó o Profundidad es 0.
en_paralelo(Juego, Posicion, Profundidad, Jugada, Valor) :-
    Profundidad > 0,
    \+ fin(Juego, Posicion, _),
    findall(J-P, jugada(Juego, Posicion, J, P), Hijos),
    Profundidad1 is Profundidad - 1,
    concurrent_maplist(valor_hijo(Juego, Profundidad1), Hijos, Valores),
    turno(Juego, Posicion, Lado),
    pairs_keys(Hijos, Jugadas),
    pairs_keys_values(Pares, Valores, Jugadas),
    elegir(Lado, Pares, Valor-Jugada).

%!  valor_hijo(+Juego, +Profundidad:integer, +Hijo, -Valor) is det.
%
%   Valor es el valor alfa-beta de la posición de Hijo, un par
%   Jugada-Posicion.
valor_hijo(Juego, Profundidad, _-Posicion, Valor) :-
    alfabeta(Juego, Posicion, Profundidad, _, Valor, _).

%!  elegir(+Lado, +Pares:list(pair), -Mejor:pair) is det.
%
%   Mejor es el primer par Valor-Jugada de Pares con el mejor valor para
%   Lado: el mayor si es max, el menor si es min.
elegir(max, Pares, Mejor) :-
    foldl(mayor, Pares, -inf-ninguna, Mejor).
elegir(min, Pares, Mejor) :-
    foldl(menor, Pares, inf-ninguna, Mejor).
```

`elegir/3` recorre los pares `Valor-Jugada` con `foldl/4`
([capítulo 18](../capitulo-18-orden-superior/index.md)) y se queda con el
primero de mejor valor, como la poda. Las búsquedas de las jugadas no se
podan entre sí, y en total se visitan más nodos que en la búsqueda
secuencial; la ganancia depende de cuántos núcleos compensen ese trabajo de
más. En el tablero de 4 × 4 vacío, con 16 núcleos:

| Profundidad | Secuencial | En paralelo |
|---:|---:|---:|
| 4 | 0,13 s | 0,13 s |
| 5 | 0,67 s | 0,31 s |
| 6 | 2,78 s | 2,24 s |
| 7 | 18,2 s | 7,3 s |

Las dos dan la misma jugada y el mismo valor. Con 16 núcleos la búsqueda
de profundidad 7 tarda 2,5 veces menos, no 16: cada jugada de la raíz se
busca entera, sin la cota que la mejor jugada anterior le daría, y las
búsquedas no duran lo mismo, así que al final quedan pocos hilos
trabajando.

El límite de tiempo va dentro de cada hilo. En Windows,
`call_with_time_limit/2` no interrumpe la espera de `thread_join/2`
([solución 3 del capítulo 37](../capitulo-37-concurrencia-y-paralelismo/soluciones.md#3)), y un
límite puesto alrededor de `concurrent_maplist/3` no se cumpliría:

<!-- ejemplo: capitulo-41/paralelo.pl predicado: en_paralelo/6 valor_a_tiempo/5 -->
```prolog
%!  en_paralelo(+Juego, +Posicion, +Profundidad:integer, +Segundos:number,
%!              -Jugada, -Valor) is semidet.
%
%   Como en_paralelo/5, con Segundos para cada búsqueda. Falla si alguna no
%   termina a tiempo. El límite está dentro de cada hilo: en Windows,
%   call_with_time_limit/2 no interrumpe la espera de thread_join/2.
en_paralelo(Juego, Posicion, Profundidad, Segundos, Jugada, Valor) :-
    Profundidad > 0,
    \+ fin(Juego, Posicion, _),
    findall(J-P, jugada(Juego, Posicion, J, P), Hijos),
    Profundidad1 is Profundidad - 1,
    catch(concurrent_maplist(valor_a_tiempo(Juego, Profundidad1, Segundos),
                             Hijos, Valores),
          time_limit_exceeded,
          fail),
    turno(Juego, Posicion, Lado),
    pairs_keys(Hijos, Jugadas),
    pairs_keys_values(Pares, Valores, Jugadas),
    elegir(Lado, Pares, Valor-Jugada).

%!  valor_a_tiempo(+Juego, +Profundidad:integer, +Segundos:number,
%!                 +Hijo, -Valor) is det.
%
%   Como valor_hijo/4, en Segundos como mucho; si no, lanza
%   time_limit_exceeded.
valor_a_tiempo(Juego, Profundidad, Segundos, Hijo, Valor) :-
    call_with_time_limit(Segundos,
                         valor_hijo(Juego, Profundidad, Hijo, Valor)).
```

```prolog
?- inicial(tateti(4), P), en_paralelo(tateti(4), P, 4, J, V).
P = pos([v, v, v, v, v, v, v, v|...], x),
J = 1,
V = 0.

?- inicial(tateti(4), P), en_paralelo(tateti(4), P, 7, 0.5, J, V).
false.
```

Con medio segundo por hilo, la búsqueda de profundidad 7 falla a los 0,63
segundos: el primer hilo que agota su tiempo lanza la excepción,
`concurrent_maplist/3` la propaga y detiene a los demás, y `en_paralelo/6`
la convierte en una falla. Con `en_paralelo/6` en lugar de `primero/6`,
`profundizar/6` repartiría cada profundidad entre los núcleos.
