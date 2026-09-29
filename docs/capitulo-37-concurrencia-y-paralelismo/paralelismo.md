# Paralelismo de datos y motores

Esta página contiene las secciones [37.4](index.md#374-paralelismo-de-datos) y
[37.5](index.md#375-motores) del [capítulo 37](index.md): repartir un
cálculo sobre muchos datos entre los núcleos del procesador, y ejecutar una
meta con un motor que entrega sus respuestas de a una. Los ejemplos están en
`paralelo.pl` y `motores.pl`, en `ejemplos/capitulo-37/`, con sus pruebas;
los dos usan lo que presentan las secciones [37.1](index.md#371-hilos) a
[37.3](index.md#373-estado-compartido), y ninguno corre en SWISH.

## Paralelismo de datos

Un cálculo sobre muchos datos independientes se puede repartir entre los
núcleos del procesador. La bandera `cpu_count` da cuántos ve SWI-Prolog; en
la máquina de las mediciones, un AMD Ryzen 9 5900HX con 8 núcleos y 2 hilos
de ejecución por núcleo, da 16. `concurrent_maplist/2..4` es
`maplist/2..4` con los elementos repartidos entre tantos hilos como núcleos,
o como elementos si son menos. Cada llamada se ejecuta como `once/1`, y las
ligaduras vuelven: a diferencia de `thread_create/3`, el resultado queda en
la lista. `paralelo.pl` cuenta los primos de una lista de tramos:

<!-- ejemplo: capitulo-37/paralelo.pl predicado: primos_en/2 contar_primos/2 contar_primos_paralelo/2 -->
```prolog
%!  primos_en(+Tramo, -C:integer) is det.
%
%   C es la cantidad de primos del intervalo Tramo, Desde-Hasta.
primos_en(Desde-Hasta, C) :-
    aggregate_all(count, ( between(Desde, Hasta, N), primo(N) ), C).

%!  contar_primos(+Tramos:list, -Total:integer) is det.
%
%   Total es la cantidad de primos de todos los Tramos.
contar_primos(Tramos, Total) :-
    maplist(primos_en, Tramos, Cs),
    sum_list(Cs, Total).

%!  contar_primos_paralelo(+Tramos:list, -Total:integer) is det.
%
%   La misma relación, con los tramos repartidos entre varios hilos.
contar_primos_paralelo(Tramos, Total) :-
    concurrent_maplist(primos_en, Tramos, Cs),
    sum_list(Cs, Total).
```

```prolog
?- tramos(4, 1000, Ts), contar_primos_paralelo(Ts, N).
Ts = [1-1000, 1001-2000, 2001-3000, 3001-4000],
N = 550.
```

Con 32 tramos de 20 000 números:

```text
?- tramos(32, 20000, _Ts), time(contar_primos(_Ts, N)).
% 74,441,112 inferences, 6.531 CPU in 6.544 seconds (100% CPU, 11397682 Lips)
_Ts = [1-20000, 20001-40000, 40001-60000, 60001-80000, 80001-100000, 100001-120000, 120001-140000, 140001-160000, ... - ...|...],
N = 52074.

?- tramos(32, 20000, _Ts), time(contar_primos_paralelo(_Ts, N)).
% 74,430,715 inferences, 9.234 CPU in 0.715 seconds (1291% CPU, 8060179 Lips)
_Ts = [1-20000, 20001-40000, 40001-60000, 60001-80000, 80001-100000, 100001-120000, 120001-140000, 140001-160000, ... - ...|...],
N = 52074.
```

De 6,5 a 0,7 segundos: nueve veces más rápido, no 16. `time/1` suma el
tiempo de procesador de todos los hilos, 9,2 segundos, más que los 6,5 de la
versión secuencial: los dos hilos de un mismo núcleo comparten sus
unidades de cálculo, y cada uno avanza más despacio que un hilo solo. Además,
los tramos no cuestan lo mismo, porque un número grande tiene más divisores
que probar, y el último hilo en terminar decide el tiempo total.

La falla simétrica es repartir trabajos demasiado pequeños:

```text
?- numlist(1, 100000, _L), time(maplist(succ, _L, _)).
% 200,000 inferences, 0.016 CPU in 0.018 seconds (86% CPU, 12800000 Lips)
_L = [1, 2, 3, 4, 5, 6, 7, 8, 9|...].

?- numlist(1, 100000, _L), time(concurrent_maplist(succ, _L, _)).
% 2,500,358 inferences, 1.906 CPU in 1.055 seconds (181% CPU, 1311663 Lips)
_L = [1, 2, 3, 4, 5, 6, 7, 8, 9|...].
```

Casi sesenta veces más lento: repartir, copiar y reunir cada elemento cuesta
mucho más que sumarle uno. El [Patrón 10](../patrones.md#10-medir-antes-de-cambiar) se aplica aquí con más razón que
en ningún otro caso: paralelizar es un cambio que se mide antes de dejarlo.

`concurrent_forall(Condicion, Accion)` es `forall/2` con las acciones
repartidas entre hilos. `goldbach_hasta/1` comprueba que cada par hasta N es
la suma de dos primos:

<!-- ejemplo: capitulo-37/paralelo.pl predicado: suma_de_primos/2 goldbach_hasta/1 goldbach_paralelo/1 -->
```prolog
%!  suma_de_primos(+P:integer, -Par) is semidet.
%
%   Par es A-B, con A y B primos, A =< B y A + B = P; A es el menor posible.
suma_de_primos(P, A-B) :-
    Mitad is P // 2,
    between(2, Mitad, A),
    primo(A),
    B is P - A,
    primo(B),
    !.

%!  goldbach_hasta(+N:integer) is semidet.
%
%   Cada número par entre 4 y N es la suma de dos primos.
goldbach_hasta(N) :-
    Mitad is N // 2,
    forall(between(2, Mitad, I),
           ( P is 2 * I,
             suma_de_primos(P, _) )).

%!  goldbach_paralelo(+N:integer) is semidet.
%
%   La misma relación, con los números repartidos entre varios hilos.
goldbach_paralelo(N) :-
    Mitad is N // 2,
    concurrent_forall(between(2, Mitad, I),
                      ( P is 2 * I,
                        suma_de_primos(P, _) )).
```

```text
?- time(goldbach_hasta(100000)).
% 34,775,019 inferences, 3.078 CPU in 3.102 seconds (99% CPU, 11297468 Lips)
true.

?- time(goldbach_paralelo(100000)).
% 35,213,473 inferences, 4.531 CPU in 0.388 seconds (1167% CPU, 7771249 Lips)
true.
```

Ocho veces más rápido: cada número par es un trabajo independiente, y hay
50 000.

`first_solution(Plantilla, Metas, Opciones)` corre cada meta de la lista en
su propio hilo, se queda con la primera respuesta que aparece y termina los
demás hilos. `un_divisor/2` busca un divisor de N desde 2 hacia arriba y
desde la raíz hacia abajo a la vez:

<!-- ejemplo: capitulo-37/paralelo.pl predicado: un_divisor/2 desde_abajo/2 desde_arriba/2 -->
```prolog
%!  un_divisor(+N:integer, -D:integer) is semidet.
%
%   D es un divisor de N mayor que 1 y no mayor que su raíz cuadrada. Busca
%   a la vez desde 2 hacia arriba y desde la raíz hacia abajo, y responde
%   con la búsqueda que termina primero. Falla si N es primo.
un_divisor(N, D) :-
    first_solution(D, [ desde_abajo(N, D),
                        desde_arriba(N, D) ],
                   []).

%!  desde_abajo(+N:integer, -D:integer) is semidet.
%
%   D es el menor divisor de N entre 2 y la raíz cuadrada de N.
desde_abajo(N, D) :-
    Raiz is truncate(sqrt(N)),
    between(2, Raiz, D),
    N mod D =:= 0,
    !.

%!  desde_arriba(+N:integer, -D:integer) is semidet.
%
%   D es el mayor divisor de N entre 2 y la raíz cuadrada de N.
desde_arriba(N, D) :-
    Raiz is truncate(sqrt(N)),
    between(2, Raiz, K),
    D is Raiz + 2 - K,
    N mod D =:= 0,
    !.
```

```text
?- N is 9999991 * 10000019, time(desde_abajo(N, D)).
% 19,999,980 inferences, 1.938 CPU in 1.970 seconds (98% CPU, 10322570 Lips)
N = 100000099999829,
D = 9999991.

?- time(desde_arriba(100000000000311, D)).
% 29,999,994 inferences, 3.938 CPU in 3.982 seconds (99% CPU, 7619046 Lips)
D = 3.

?- N is 9999991 * 10000019, time(un_divisor(N, D)).
% 57,879 inferences, 0.016 CPU in 0.021 seconds (76% CPU, 3704256 Lips)
N = 100000099999829,
D = 9999991.

?- time(un_divisor(100000000000311, D)).
% 53,927 inferences, 0.000 CPU in 0.021 seconds (0% CPU, Infinite Lips)
D = 3.
```

El primer número es el producto de dos primos cercanos a su raíz, y la
búsqueda desde abajo tarda casi dos segundos; el segundo es 3 por un primo
grande, y la búsqueda desde arriba tarda casi cuatro. `un_divisor/2` responde
los dos en centésimas: cada vez gana la estrategia que sirve. Cuando las
metas pueden dar respuestas distintas, como con `un_divisor(1000, D)`, que da
2 o 25 según qué hilo termine primero, la respuesta depende del orden de los
hilos, y la prueba acepta cualquiera de las dos.

Las tres herramientas exigen lo mismo de las metas: que sean independientes,
sin cambios compartidos en la base de datos o con ellos detrás de un mutex,
y lo bastante grandes para pagar el reparto.

!!! question "Actividad"
    Predecir si `contar_primos_paralelo/2` es más rápido con 4 tramos de
    400 000 números o con 32 de 50 000, que cubren los mismos números.
    Comprobarlo con `time/1`.

## Motores

Un **motor** (*engine*) ejecuta una meta y entrega sus respuestas de a una,
cuando se le piden. `engine_create(Plantilla, Meta, Motor)` lo crea sin
ejecutar nada; `engine_next(Motor, Termino)` ejecuta la meta hasta su
respuesta siguiente, da la Plantilla ligada y la deja detenida allí; falla
cuando no hay más respuestas. `engine_destroy/1` lo libera. El motor corre en
el hilo que lo llama: no hay paralelismo, sino una meta que avanza a pedido.
`motores.pl` toma las primeras respuestas de un generador sin fin:

<!-- ejemplo: capitulo-37/motores.pl predicado: multiplo/2 primeros/4 tomar/3 -->
```prolog
%!  multiplo(+K:integer, -M:integer) is multi.
%
%   M es un múltiplo positivo de K, en orden creciente, sin fin.
multiplo(K, M) :-
    natural(N),
    M is K * (N + 1).

%!  primeros(+N:integer, ?Plantilla, :Meta, -Lista:list) is det.
%
%   Lista tiene la Plantilla de las primeras N respuestas de Meta, o de
%   todas si Meta tiene menos.
primeros(N, Plantilla, Meta, Lista) :-
    setup_call_cleanup(engine_create(Plantilla, Meta, Motor),
                       tomar(N, Motor, Lista),
                       engine_destroy(Motor)).

%!  tomar(+N:integer, +Motor, -Lista:list) is det.
%
%   Lista tiene las siguientes N respuestas de Motor, o las que le queden.
tomar(N, Motor, Lista) :-
    (   N > 0,
        engine_next(Motor, X)
    ->  Lista = [X|Resto],
        N1 is N - 1,
        tomar(N1, Motor, Resto)
    ;   Lista = []
    ).
```

```prolog
?- primeros(5, X, multiplo(3, X), L).
L = [3, 6, 9, 12, 15].
```

`findall/3` sobre `multiplo(3, X)` no termina, y el retroceso da las
respuestas de a una pero solo dentro de la consulta que las pide. Un motor
guarda el punto donde quedó la meta y se puede consultar desde cualquier
lugar, y varios motores avanzan a la vez. `mezclar/4` combina dos
generadores ordenados en uno: pide al que tiene el número menor, y a los dos
cuando coinciden:

<!-- ejemplo: capitulo-37/motores.pl predicado: mezclar/4 mezcla/6 -->
```prolog
%!  mezclar(+N:integer, :Gen1, :Gen2, -Lista:list) is det.
%
%   Gen1 y Gen2 generan números en orden creciente, con call(Gen, X). Lista
%   tiene los primeros N números que genera alguno de los dos, en orden y
%   sin repetidos.
mezclar(N, Gen1, Gen2, Lista) :-
    setup_call_cleanup(( engine_create(X, call(Gen1, X), M1),
                         engine_create(Y, call(Gen2, Y), M2) ),
                       ( engine_next(M1, X1),
                         engine_next(M2, Y1),
                         mezcla(N, X1, M1, Y1, M2, Lista) ),
                       ( engine_destroy(M1),
                         engine_destroy(M2) )).

%!  mezcla(+N:integer, +X, +M1, +Y, +M2, -Lista:list) is det.
%
%   Lista son los N menores números entre X, Y y los que siguen en los
%   motores M1 y M2, sin repetidos. X e Y son la última respuesta de cada
%   motor, todavía sin usar.
mezcla(0, _, _, _, _, []) :-
    !.
mezcla(N, X, M1, Y, M2, [Z|Zs]) :-
    N1 is N - 1,
    (   X < Y
    ->  Z = X,
        engine_next(M1, X1),
        mezcla(N1, X1, M1, Y, M2, Zs)
    ;   Y < X
    ->  Z = Y,
        engine_next(M2, Y1),
        mezcla(N1, X, M1, Y1, M2, Zs)
    ;   Z = X,
        engine_next(M1, X1),
        engine_next(M2, Y1),
        mezcla(N1, X1, M1, Y1, M2, Zs)
    ).
```

```prolog
?- mezclar(8, multiplo(4), multiplo(6), L).
L = [4, 6, 8, 12, 16, 18, 20, 24].
```

Un motor también recibe datos. `engine_post(Motor, Termino, Respuesta)`
entrega Termino al motor y le pide la respuesta siguiente; dentro, la meta lo
toma con `engine_fetch/1` y responde con `engine_yield/1`, que entrega un
término sin terminar la meta. Así el motor es una **corrutina** que conserva
su estado entre llamadas, sin base de datos ni variables globales:

<!-- ejemplo: capitulo-37/motores.pl predicado: sumar/1 parciales/2 -->
```prolog
%!  sumar(+Total:number) is det.
%
%   El cuerpo del motor de parciales/2: recibe un número con engine_fetch/1,
%   entrega la suma acumulada con engine_yield/1 y sigue con la suma nueva.
sumar(Total0) :-
    engine_fetch(X),
    Total is Total0 + X,
    engine_yield(Total),
    sumar(Total).

%!  parciales(+Numeros:list(number), -Sumas:list(number)) is det.
%
%   Sumas tiene, para cada elemento de Numeros, la suma de ese y los
%   anteriores. Un solo motor recibe los números de a uno y conserva la
%   suma entre un pedido y el siguiente.
parciales(Numeros, Sumas) :-
    setup_call_cleanup(engine_create(_, sumar(0), Motor),
                       maplist(engine_post(Motor), Numeros, Sumas),
                       engine_destroy(Motor)).
```

```prolog
?- parciales([5, 3, 10, 2], Ps).
Ps = [5, 8, 18, 20].
```

La suma acumulada vive en el argumento de `sumar/1`, como en cualquier
recursión, y el motor la conserva mientras espera el número siguiente. Los
tres predicados crean sus motores con `setup_call_cleanup/3`
([sección 25.6](../capitulo-25-errores-y-excepciones/index.md#256-setup_call_cleanup3)): un motor que no se destruye ocupa sus pilas hasta
el final de la sesión, y la prueba `sin_motores` comprueba con
`current_engine/1` que no queda ninguno.

!!! question "Actividad"
    Predecir la respuesta de `primeros(3, X, member(X, [a]), L)` y la de
    `mezclar(5, multiplo(2), multiplo(2), L)`, y comprobarlas.
