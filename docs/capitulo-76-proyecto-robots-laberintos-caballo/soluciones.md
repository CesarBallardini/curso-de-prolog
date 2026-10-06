# Soluciones del capítulo 76 — Proyecto: robots, laberintos y el caballo

El código de esta página está en `ejemplos/capitulo-76/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `giros.pl` (que carga
`robot.pl` y `plano.pl`), `laberinto.pl`, `caballo.pl` y `recorrido.pl`,
sin modificarlos, y reexporta sus predicados. Los problemas nuevos se
definen en el módulo `soluciones` con `inicial/2`, `meta/2`, `sucesor/5` y
`heuristica/3`, y se resuelven con las búsquedas del
[capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) como
`soluciones:Problema`. Es `% solo-local`, porque carga otros archivos.

## 1

La predicción razonable es voraz < A\* < anchura ≈ costo uniforme, y que
la voraz es la única que puede dar un camino más largo, porque no mira lo
que ya costó llegar.

<!-- contexto: capitulo-76/soluciones.pl -->
```prolog
?- camino(taller, voraz, 1-4, 20-6, _, P, K).
P = 25,
K = 26.

?- camino(taller, costo_uniforme, 1-4, 20-6, _, P, K).
P = 23,
K = 146.
```

Con A\* son 23 pasos y 42 nodos, y con la anchura 23 y 144 (la tabla de
la [sección 76.3](index.md#763-version-2-a-en-el-plano)). Con todos los
pasos de costo 1, el costo de un camino es su largo: el montículo del
costo uniforme saca los nodos en el mismo orden de niveles que la cola de
la anchura, y las diferencias, 144 contra 146, vienen solo del orden en
que se sacan los empates dentro de un nivel.

## 2

Si la celda no está en la fila ni en la columna de la llegada, el camino
tiene que tener pasos horizontales y pasos verticales, así que en algún
momento cambia de dirección: al menos un giro, que cuesta 1. Ningún
camino desde ahí cuesta menos que 10 por paso más ese giro, y la
heurística sigue sin estimar de más. Las cláusulas de `giros2` pasan
`inicial/2`, `meta/2` y `sucesor/5` al problema `giros` de `giros.pl` y
cambian solo la heurística:

<!-- ejemplo: capitulo-76/soluciones.pl fragmento: heuristica(giros2(_, _, X2-Y2), c(X-Y, _), H) :- .. H is 10 * D -->
```prolog
heuristica(giros2(_, _, X2-Y2), c(X-Y, _), H) :-
    manhattan(X-Y, X2-Y2, D),
    (   X =\= X2,
        Y =\= Y2
    ->  H is 10 * D + 1
```

<!-- ejemplo: capitulo-76/soluciones.pl predicado: comparar_giros/5 -->
```prolog
%!  comparar_giros(+Plano, +Desde, +Hasta, -K1:integer, -K2:integer)
%!      is semidet.
%
%   K1 y K2 son los nodos que A* expande con giros, con la heurística del
%   capítulo y con la que suma el giro obligado; los dos caminos cuestan
%   lo mismo.
comparar_giros(Plano, Desde, Hasta, K1, K2) :-
    camino_con_giros(Plano, Desde, Hasta, _, C, K1),
    buscar(mejor(a_estrella), soluciones:giros2(Plano, Desde, Hasta), _, C,
           K2).
```

```prolog
?- comparar_giros(taller, 1-4, 20-6, K1, K2).
K1 = K2, K2 = 85.

?- comparar_giros(patio, 10-30, 50-30, K1, K2).
K1 = 4442,
K2 = 3914.
```

En el taller no cambia nada; en el patio ahorra un 12 % de los nodos. La
mejora es pequeña porque la heurística sube en 1 sobre valores del orden
de cientos, y solo desempata entre nodos con el mismo costo más
estimación.

## 3

Con ocho direcciones y costo 1 por paso, la distancia de Chebyshev
—la mayor de las diferencias de columna y de fila— es la cantidad de
pasos sin obstáculos, y un obstáculo solo la alarga: es admisible. La de
Manhattan dejaría de serlo, porque un paso en diagonal avanza 2 en esa
medida.

<!-- ejemplo: capitulo-76/soluciones.pl predicado: vecina8/3 camino8/5 -->
```prolog
%!  vecina8(+Plano, +Celda, -Vecina) is nondet.
%
%   Vecina es una celda libre junto a Celda en una de las ocho direcciones;
%   en diagonal, solo si las dos celdas por las que pasaría la esquina
%   también están libres.
vecina8(Plano, Celda, Vecina) :-
    vecina(Plano, Celda, _, Vecina).
vecina8(Plano, X-Y, X1-Y1) :-
    member(DX-DY, [1-1, 1-(-1), (-1)-1, (-1)-(-1)]),
    X1 is X + DX,
    Y1 is Y + DY,
    libre(Plano, X1, Y1),
    libre(Plano, X1, Y),
    libre(Plano, X, Y1).

%!  camino8(+Plano, +Desde, +Hasta, -Pasos:integer, -Expandidos:integer)
%!      is semidet.
%
%   Pasos es la menor cantidad de pasos de Desde a Hasta en ocho
%   direcciones, hallada con A* y la distancia de Chebyshev.
camino8(Plano, Desde, Hasta, Pasos, Expandidos) :-
    buscar(mejor(a_estrella), soluciones:ruta8(Plano, Desde, Hasta), _,
           Pasos, Expandidos).
```

```prolog
?- camino8(taller, 1-4, 20-6, Pasos, K).
Pasos = 20,
K = 53.
```

Se ahorran 3 de los 23 pasos: las diagonales solo sirven donde el camino
cambia de fila, y la condición de las esquinas impide cortarlas junto a
las paredes.

## 4

Una búsqueda en anchura por niveles que lleva, para cada celda del nivel,
cuántos caminos mínimos llegan a ella: la cantidad de una celda nueva es
la suma de las de sus vecinas del nivel anterior.

<!-- ejemplo: capitulo-76/soluciones.pl predicado: cantidad_minimos/4 niveles/5 ver/3 -->
```prolog
%!  cantidad_minimos(+Plano, +Desde, +Hasta, -N:integer) is semidet.
%
%   N es la cantidad de caminos de largo mínimo de Desde a Hasta: una
%   búsqueda en anchura por niveles que suma, para cada celda, los caminos
%   que llegan a ella desde el nivel anterior. Falla si no hay camino.
cantidad_minimos(Plano, Desde, Hasta, N) :-
    list_to_assoc([Desde-1], Nivel),
    list_to_assoc([Desde-si], Vistas),
    niveles(Plano, Nivel, Vistas, Hasta, N).

%!  niveles(+Plano, +Nivel, +Vistas, +Hasta, -N:integer) is semidet.
%
%   Nivel da, para cada celda a la misma distancia, cuántos caminos mínimos
%   llegan a ella.
niveles(Plano, Nivel, Vistas, Hasta, N) :-
    (   get_assoc(Hasta, Nivel, N0)
    ->  N = N0
    ;   assoc_to_list(Nivel, Pares),
        Pares \== [],
        findall(V-K,
                ( member(C-K, Pares),
                  vecina(Plano, C, _, V),
                  \+ get_assoc(V, Vistas, _) ),
                Llegadas),
        keysort(Llegadas, Ordenadas),
        group_pairs_by_key(Ordenadas, Grupos),
        findall(V-S, ( member(V-Ks, Grupos), sum_list(Ks, S) ), Siguiente),
        list_to_assoc(Siguiente, Nivel1),
        foldl(ver, Siguiente, Vistas, Vistas1),
        niveles(Plano, Nivel1, Vistas1, Hasta, N)
    ).

%!  ver(+Par, +Vistas0, -Vistas) is det.
%
%   Vistas es Vistas0 con la celda del Par.
ver(V-_, Vistas0, Vistas) :-
    put_assoc(V, Vistas0, si, Vistas).
```

```prolog
?- cantidad_minimos(patio, 28-8, 32-8, N1), cantidad_minimos(patio, 28-8, 20-20, N2).
N1 = 5,
N2 = 125970.
```

Hasta la llegada hay solo 5 caminos mínimos, porque todos pasan por el
hueco de la pared. Pero A\* sin visitados no expande solo caminos
mínimos hasta la llegada: expande todos los caminos parciales cuyo costo
más la heurística no pasa de 12, y la heurística, que estima 4 desde
cualquier celda de la columna 28, deja dentro de esa cota caminos que
bajan y vuelven a subir por toda la zona a la izquierda de la pared. A
cada celda de esa zona se llega por muchos caminos del mismo largo —a
(20, 20), a 20 pasos, por 125 970— y cada uno es un nodo distinto de la
frontera. Los 10 822 nodos son esos caminos, no esas celdas.

## 5

La tabla de una iteración reemplaza al rastro del camino actual: guarda,
para cada estado, el menor costo con que se llegó a él en esta iteración,
y pasa de un hijo al siguiente. Si un estado ya se alcanzó con un costo
igual o menor, todo lo que hay debajo ya se exploró con la misma cota y
con al menos el mismo margen, y no encontró un plan dentro de la cota;
volver a explorarlo no puede encontrar uno. Por eso el primer plan que
aparece sigue siendo de costo mínimo. Los ciclos quedan cubiertos por el
mismo argumento, porque volver a un estado del camino siempre cuesta más.

<!-- ejemplo: capitulo-76/soluciones.pl predicado: ida_con_tabla/4 iteracion_t/7 acotada_t/9 probar_t/10 camino_ida_con_tabla/5 -->
```prolog
%!  ida_con_tabla(+Problema, -Plan:list, -Costo:number, -Expandidos:integer)
%!      is semidet.
%
%   Como ida_estrella/4 del capítulo 40, pero cada iteración recuerda en un
%   assoc el menor costo con que llegó a cada estado y no vuelve a expandir
%   un estado al que llega con un costo igual o mayor: lo que había debajo
%   ya se exploró con la misma cota y más margen.
ida_con_tabla(Problema, Plan, Costo, Expandidos) :-
    capitulo40:inicial(Problema, Estado),
    capitulo40:heuristica(Problema, Estado, Cota),
    iteracion_t(Problema, Estado, Cota, 0, Plan, Costo, Expandidos).

%!  iteracion_t(+Problema, +Estado, +Cota:number, +K0:integer, -Plan:list,
%!              -Costo:number, -K:integer) is semidet.
%
%   Busca con Cota, y si no encuentra un plan, con la cota siguiente.
iteracion_t(Problema, Estado, Cota, K0, Plan, Costo, K) :-
    list_to_assoc([Estado-0], T0),
    acotada_t(Problema, Estado, 0, Cota, T0, _, Resultado, K0, K1),
    (   Resultado = plan(Plan, Costo)
    ->  K = K1
    ;   Resultado = cota(Siguiente),
        Siguiente \== infinito,
        iteracion_t(Problema, Estado, Siguiente, K1, Plan, Costo, K)
    ).

%!  acotada_t(+Problema, +Estado, +G:number, +Cota:number, +T0, -T,
%!            -Resultado, +K0:integer, -K:integer) is det.
%
%   Como acotada/8 del capítulo 40, con la tabla T0 de los menores costos
%   en lugar del rastro del camino.
acotada_t(Problema, Estado, G, Cota, T0, T, Resultado, K0, K) :-
    capitulo40:heuristica(Problema, Estado, H),
    F is G + H,
    (   F > Cota
    ->  Resultado = cota(F),
        T = T0,
        K = K0
    ;   capitulo40:meta(Problema, Estado)
    ->  Resultado = plan([], G),
        T = T0,
        K = K0
    ;   K1 is K0 + 1,
        findall(t(A, S, C),
                capitulo40:sucesor(Problema, Estado, A, S, C),
                Ts),
        probar_t(Ts, Problema, G, Cota, T0, T, infinito, Resultado, K1, K)
    ).

%!  probar_t(+Ts:list, +Problema, +G:number, +Cota:number, +T0, -T,
%!           +Menor, -Resultado, +K0:integer, -K:integer) is det.
%
%   Prueba las transiciones Ts en orden; salta las que llegan a un estado
%   ya alcanzado con un costo menor o igual.
probar_t([], _, _, _, T, T, Menor, cota(Menor), K, K).
probar_t([t(A, S, C)|Ts], Problema, G, Cota, T0, T, Menor0, Resultado,
         K0, K) :-
    G1 is G + C,
    (   get_assoc(S, T0, G0),
        G0 =< G1
    ->  probar_t(Ts, Problema, G, Cota, T0, T, Menor0, Resultado, K0, K)
    ;   put_assoc(S, T0, G1, T1),
        acotada_t(Problema, S, G1, Cota, T1, T2, R, K0, K1),
        (   R = plan(Plan, Costo)
        ->  Resultado = plan([A|Plan], Costo),
            T = T2,
            K = K1
        ;   R = cota(F),
            capitulo40:menor(F, Menor0, Menor),
            probar_t(Ts, Problema, G, Cota, T2, T, Menor, Resultado, K1, K)
        )
    ).

%!  camino_ida_con_tabla(+Plano, +Desde, +Hasta, -Pasos:integer,
%!                       -Expandidos:integer) is semidet.
%
%   Pasos es el largo del camino más corto, hallado con ida_con_tabla/4.
camino_ida_con_tabla(Plano, Desde, Hasta, Pasos, Expandidos) :-
    ida_con_tabla(robot:ruta(Plano, Desde, Hasta, manhattan), _, Pasos,
                  Expandidos).
```

```prolog
?- camino_ida_con_tabla(patio, 28-8, 32-8, P, K).
P = 12,
K = 83.

?- camino_ida_con_tabla(patio, 28-12, 32-12, P, K).
P = 20,
K = 667.
```

Para Y = 6, 8, 10, 12 y 14 expande 20, 83, 264, 667 y 1 428 nodos, donde
IDA\* expandía 23, 220, 3 625, 81 468 y no terminaba; para Y = 20 expande
7 699. Sigue expandiendo más que A\* (14 a 150), porque repite el trabajo
en cada iteración, pero ya no crece exponencialmente con la profundidad.
La memoria, en cambio, vuelve a ser la de A\*: una entrada por estado.

## 6

<!-- contexto: capitulo-76/soluciones.pl -->
```prolog
?- estimacion(euclidea, csenki, g(1, 2), E), estimacion(vuelo, csenki, g(1, 2), V), estimacion_h3(csenki, g(1, 2), H3).
E = 11.40175425099138,
V = 22.083045973594572,
H3 = 25.681802712609773.
```

`euclidea` es la línea recta de `g(1, 2)` a `g(12, 5)`. `vuelo` toma el
máximo entre esa misma recta y los vuelos por cada fila intermedia, y
cada vuelo en dos tramos es al menos tan largo como la recta, por la
desigualdad triangular: `vuelo` nunca es menor que `euclidea`. La
consulta muestra también H3, del ejercicio 8, que es mayor todavía. El
costo real es 54: las tres estimaciones quedan lejos, porque el recorrido
zigzaguea de un lado al otro del laberinto.

## 7

La distancia de Manhattan desde `g(F, P)` hasta la salida `g(N, Q)` es
`|P − Q| + N − F`: el recorrido tiene que subir N − F filas y desplazarse
al menos `|P − Q|` en total a lo largo de los corredores. Es admisible, y
nunca menor que la euclídea.

<!-- ejemplo: capitulo-76/soluciones.pl predicado: salida_manhattan/3 -->
```prolog
%!  salida_manhattan(+Laberinto, -Costo:integer, -Expandidos:integer)
%!      is semidet.
%
%   Costo es el del recorrido más corto del Laberinto, hallado con A* y la
%   distancia horizontal más la cantidad de filas que faltan.
salida_manhattan(Laberinto, Costo, Expandidos) :-
    laberinto(Laberinto, Filas),
    buscar(mejor(a_estrella), soluciones:salir_m(Filas), _, Costo,
           Expandidos).
```

```prolog
?- salida_manhattan(csenki, C, K).
C = 54,
K = 20.

?- salida_manhattan(sembrado(1, 30, 40, 4), C, K).
C = 131,
K = 95.
```

Expande lo mismo que `euclidea` en `csenki` (20) y uno más en el
laberinto sembrado (95 contra 94): aunque estima más, los empates se
resuelven en otro orden. El cálculo es igual de barato. Csenki pregunta
por el tiempo; con estas cifras, la diferencia está en el ruido de la
medición.

## 8

<!-- ejemplo: capitulo-76/soluciones.pl predicado: h3/4 vuelo3/6 salida_h3/3 -->
```prolog
%!  h3(+Filas:list, +X, +Y, -H:number) is det.
%
%   H es la mayor, sobre los pares de filas intermedias, de la menor
%   longitud de un vuelo de X a Y en tres tramos rectos que pasa por una
%   compuerta de cada fila; si no hay dos filas intermedias, es la
%   estimación vuelo del capítulo.
h3(Filas, X, Y, H) :-
    X = g(F1, _),
    Y = g(F2, _),
    laberinto:estimacion(vuelo, Filas, X, Y, H2),
    findall(V,
            ( between(F1, F2, R1), R1 > F1,
              between(R1, F2, R2), R2 > R1, R2 < F2,
              vuelo3(Filas, X, Y, R1, R2, V) ),
            Vs),
    max_list([H2|Vs], H).

%!  vuelo3(+Filas:list, +X, +Y, +R1:integer, +R2:integer, -V:number)
%!      is det.
%
%   V es el vuelo más corto de X a Y que pasa por una compuerta de la fila
%   R1 y después por una de la fila R2.
vuelo3(Filas, X, Y, R1, R2, V) :-
    nth1(R1, Filas, Fila1),
    nth1(R2, Filas, Fila2),
    aggregate_all(min(D),
                  ( member(P, Fila1),
                    member(Q, Fila2),
                    laberinto:recta(X, g(R1, P), D1),
                    laberinto:recta(g(R1, P), g(R2, Q), D2),
                    laberinto:recta(g(R2, Q), Y, D3),
                    D is D1 + D2 + D3 ),
                  V).

%!  salida_h3(+Laberinto, -Costo:number, -Expandidos:integer) is semidet.
%
%   Como salida_manhattan/3, con la heurística H3: vuelos en tres tramos.
salida_h3(Laberinto, Costo, Expandidos) :-
    laberinto(Laberinto, Filas),
    buscar(mejor(a_estrella), soluciones:salir_h3(Filas), _, Costo,
           Expandidos).
```

```prolog
?- salida_h3(csenki, C, K).
C = 54,
K = 18.
```

Medido con las inferencias de la búsqueda completa:

| Laberinto | `euclidea` | `vuelo` | H3 |
|---|---|---|---|
| `csenki` | 20 · 2 847 | 20 · 6 813 | 18 · 66 774 |
| `sembrado(1, 30, 40, 4)` | 94 · 23 006 | 90 · 131 307 | 86 · 2 894 103 |

H3 ahorra 2 y 4 nodos y multiplica las inferencias por 23 y por 125. En
el laberinto de 100 filas no termina en un minuto: cada estimación
recorre todos los pares de filas intermedias, y la cantidad de pares
crece con el cuadrado de las filas. No compensa.

## 9

Las distancias reales salen de una búsqueda en anchura por niveles desde
cada casilla, que el ejercicio 10 reutiliza:

<!-- ejemplo: capitulo-76/soluciones.pl predicado: distancias/3 capas/5 con_distancia/4 saltos_minimos/4 sobreestimaciones/2 casilla8/1 -->
```prolog
%!  distancias(+N:integer, +Desde, -Distancias) is det.
%
%   Distancias es un assoc con la cantidad mínima de saltos del caballo
%   desde Desde hasta cada casilla del tablero de N x N, calculada en
%   anchura por niveles.
distancias(N, Desde, Distancias) :-
    list_to_assoc([Desde-0], D0),
    capas(N, [Desde], 0, D0, Distancias).

%!  capas(+N:integer, +Nivel:list, +K:integer, +D0, -D) is det.
%
%   Nivel son las casillas a K saltos; D agrega a D0 las que siguen.
capas(_, [], _, D, D) :-
    !.
capas(N, Nivel, K, D0, D) :-
    K1 is K + 1,
    findall(S,
            ( member(C, Nivel),
              salto(N, C, S, _),
              \+ get_assoc(S, D0, _) ),
            Ss0),
    sort(Ss0, Ss),
    foldl(con_distancia(K1), Ss, D0, D1),
    capas(N, Ss, K1, D1, D).

%!  con_distancia(+K:integer, +S, +D0, -D) is det.
%
%   D es D0 con la casilla S a K saltos.
con_distancia(K, S, D0, D) :-
    put_assoc(S, D0, K, D).

%!  saltos_minimos(+N:integer, +A, +B, -D:integer) is semidet.
%
%   D es la menor cantidad de saltos del caballo de A a B en el tablero de
%   N x N. Falla si no se puede llegar.
saltos_minimos(N, A, B, D) :-
    distancias(N, A, Ds),
    get_assoc(B, Ds, D).

%!  sobreestimaciones(+Heuristica, -Pares:list) is det.
%
%   Pares son los pares Desde-Hasta de casillas del tablero de 8 x 8,
%   Desde antes que Hasta en el orden estándar, en los que la Heuristica
%   estima más saltos que los necesarios.
sobreestimaciones(Heuristica, Pares) :-
    findall(A-B,
            ( casilla8(A),
              distancias(8, A, Ds),
              casilla8(B),
              A @< B,
              get_assoc(B, Ds, D),
              estimar(Heuristica, A, B, H),
              H > D ),
            Pares).

%!  casilla8(-C) is multi.
%
%   C es una casilla del tablero de 8 x 8.
casilla8(X-Y) :-
    between(1, 8, X),
    between(1, 8, Y).
```

```prolog
?- sobreestimaciones(minima, Ps), length(Ps, N).
Ps = [1-1-(4-4), 1-1-(5-6), 1-1-(6-5), 1-1-(6-6), 1-1-(6-8), 1-1-(7-7), 1-1-(7-8), ... - ... - (... - ...), ... - ...|...],
N = 146.

?- sobreestimaciones(combinada, Ps).
Ps = [].

?- estimar(minima, 1-1, 4-4, H), saltos_minimos(8, 1-1, 4-4, D).
H = 3,
D = 2.
```

`minima` estima de más en 146 de los 2 016 pares: de a1 a d4 estima 3 y
bastan 2 saltos, por b3 o por c2: `minima` cuenta como si cada salto
avanzara una casilla en la coordenada que mide, y puede avanzar dos.

## 10

<!-- ejemplo: capitulo-76/soluciones.pl predicado: admisible/2 -->
```prolog
%!  admisible(+N:integer, +Heuristica) is semidet.
%
%   La Heuristica no estima de más para ningún par de casillas del tablero
%   de N x N.
admisible(N, Heuristica) :-
    forall(( between(1, N, X), between(1, N, Y) ),
           ( distancias(N, X-Y, Ds),
             forall(gen_assoc(B, Ds, D),
                    ( estimar(Heuristica, X-Y, B, H),
                      H =< D )) )).
```

```prolog
?- admisible(8, combinada).
true.

?- admisible(8, minima).
false.
```

Las cuatro admisibles del capítulo, `cero`, `manhattan`, `euclidea` y
`combinada`, y también `entera(combinada)`, dan `true`; `minima` da
`false`. Cada comprobación hace 64 búsquedas en anchura y 4 096
estimaciones, unas 420 000 inferencias. Una comprobación por exhaustión
como esta vale solo para el tablero examinado; la demostración de Csenki
con la desigualdad triangular vale para cualquiera.

## 11

<!-- ejemplo: capitulo-76/soluciones.pl predicado: recorrido_cerrado/3 -->
```prolog
%!  recorrido_cerrado(+N:integer, +Desde, -Camino:list) is nondet.
%
%   Camino es un recorrido del caballo por el tablero de N x N que empieza
%   en Desde y termina a un salto de Desde, hallado con la regla de
%   Warnsdorff.
recorrido_cerrado(N, Desde, Camino) :-
    recorrido(warnsdorff, N, Desde, Camino),
    last(Camino, Ultima),
    salto(N, Ultima, Desde, _).
```

```prolog
?- once(recorrido_cerrado(8, 1-1, C)), last(C, U).
C = [1-1, 2-3, 3-1, 1-2, 2-4, 1-6, 2-8, 4-7, ... - ...|...],
U = 3-2.
```

La última casilla, (3, 2), está a un salto de (1, 1). Cada salto cambia
el color de la casilla, porque cambia en 3 la suma de columna y fila. Un
recorrido cerrado vuelve a la casilla de partida y alterna colores en
todo el ciclo, así que tiene tantas casillas de un color como del otro: la
cantidad de casillas tiene que ser par. En el tablero de 5 × 5 hay 25, y
`recorrido_cerrado(5, 1-1, C)` falla después de recorrer los 304
recorridos abiertos, en unos 50 segundos.

En el de 6 × 6 sí hay recorridos cerrados, pero esta versión no encuentra
uno en un minuto: la condición de cerrar se comprueba al final, sobre
cada recorrido completo, y la regla de Warnsdorff no la tiene en cuenta.
En 8 × 8 el primer recorrido de Warnsdorff resultó cerrado. Una versión
que sirva en general reserva desde el principio las vecinas de la casilla
de partida para el final, o usa una regla de desempate que favorezca
cerrar, como las que menciona el artículo de Wikipedia citado en el
capítulo.

## 12

```text
?- aggregate_all(count, recorrido(ingenuo, 5, 1-1, _), N).
N = 304.          % 160 711 997 inferencias, 28,7 s

?- aggregate_all(count, recorrido(warnsdorff, 5, 1-1, _), N).
N = 304.          % 272 448 920 inferencias, 49,1 s
```

Las dos consultas tardan más que el límite de las transcripciones del
curso, y por eso se muestran como texto. Hay 304 recorridos desde una
esquina en el tablero de 5 × 5. Para encontrarlos todos hay que recorrer
el árbol de búsqueda entero, y el orden en que se visitan sus ramas no
cambia su tamaño: la regla de Warnsdorff solo agrega el costo de contar
las salidas de cada candidata, y tarda casi el doble. Una heurística que
ordena sirve para encontrar pronto la primera solución, no para acortar
una enumeración completa.
