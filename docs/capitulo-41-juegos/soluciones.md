# Soluciones del capítulo 41 — Juegos

El código de esta página está en `ejemplos/capitulo-41/`: `soluciones.pl`
para los ejercicios 3, 4, 5, 6, 9 y 11, `soluciones_orden.pl` para el 7 y
el 8, y `soluciones_simetria.pl` para el 10; los tres copian al final lo que
usan de los archivos del capítulo y corren en SWISH. `soluciones_terminal.pl`,
para el 13 y el 14, carga `tateti_terminal.pl` y no corre en SWISH. Cada
uno tiene sus pruebas. Los ejercicios 1, 2 y 12 se resuelven con los
archivos del capítulo.

## 1

Con `tateti.pl` cargado:

<!-- ejemplo: capitulo-41/tateti.pl predicado: ganada/2 -->
```prolog
%!  ganada(+Juego, +Posicion) is semidet.
%
%   El jugador de turno en Posicion gana, juegue lo que juegue el rival:
%   tiene una jugada tras la cual todas las respuestas llevan a una
%   posición en la que vuelve a ganar. Recorre el árbol entero de la
%   partida.
ganada(Juego, Posicion) :-
    \+ fin(Juego, Posicion, _),
    jugada(Juego, Posicion, _, Siguiente),
    perdida(Juego, Siguiente),
    !.
```

```prolog
?- fin(tateti(3), pos([o,x,x, v,o,x, v,v,o], x), R).
R = gana(o).

?- fin(tateti(4), pos([x,x,x,v, o,o,o,v, v,v,v,v, v,v,v,v], x), R).
false.

?- ganada(tateti(3), pos([x,v,v, v,v,v, v,v,v], o)).
false.

?- ganada(tateti(3), pos([x,o,v, v,v,v, v,v,v], x)).
true.
```

En la primera, o completó la diagonal 1-5-9; la columna 3 tiene dos x y
una o. En la segunda, tres en línea no alcanzan en el tablero de 4 × 4, y
la partida sigue. La tercera pregunta si o, que mueve después de una x en
la esquina, puede forzar la victoria: no puede, porque x no pierde con buen
juego. La cuarta es la conocida: con x en una esquina y o en un borde
vecino, x gana, por ejemplo jugando al centro, que amenaza la diagonal y
obliga a o a taparla en 9, y después en 4, que amenaza dos líneas.

## 2

```prolog
?- partidas(tateti(3), pos([x,v,v, v,o,v, v,v,v], x), N).
N = 3468.

?- partidas(tateti(3), pos([o,v,v, v,x,v, v,v,v], x), N).
N = 3198.
```

Con siete casillas vacías, si ninguna partida terminara antes de llenar el
tablero habría 7! = 5 040 en las dos. Cada partida que termina con una
victoria antes deja sin jugar todas las continuaciones que habría tenido,
y cuántas terminan antes depende de dónde están las marcas. Contadas por
cantidad de jugadas:

```prolog
?- findall(L, (partida(tateti(3), pos([o,v,v, v,x,v, v,v,v], x), Js), length(Js, L)), Ls), msort(Ls, S), clumped(S, C).
Ls = [7, 6, 5, 7, 7, 5, 5, 7, 7|...],
S = [3, 3, 3, 3, 3, 3, 3, 3, 3|...],
C = [3-30, 4-72, 5-792, 6-720, 7-1584].
```

Con x en el centro, que está en cuatro líneas, x completa una línea a las
tres jugadas en 30 partidas, contra 20 cuando x tiene la esquina y o el
centro (la otra consulta, con la primera posición, da
`C = [3-20, 4-112, 5-552, 6-1200, 7-1584]`), y a las cinco jugadas en 792
contra 552. Las partidas que terminan
antes cortan más ramas, y la segunda posición tiene menos partidas.

## 3

Con victorias que valen todas 100, el juego `plano(N)` delega en
`tateti(N)` todo menos el valor final, que distingue por el término
`plano(R)` que devuelve su `fin/3`:

<!-- ejemplo: capitulo-41/soluciones.pl fragmento: %!  inicial(+Juego, -Posicion) is det. .. V is S * 100. -->
```prolog
%!  inicial(+Juego, -Posicion) is det.
%
%   Posicion es la de partida de Juego: en plano(N), la de tateti(N).
inicial(plano(N), P) :-
    inicial(tateti(N), P).

%!  jugada(+Juego, +Posicion, ?Casilla:integer, -Siguiente) is nondet.
%
%   Siguiente es la posición que resulta de marcar Casilla en Posicion,
%   como en tateti(N).
jugada(plano(N), P, J, P1) :-
    jugada(tateti(N), P, J, P1).

%!  turno(+Juego, +Posicion, -Lado) is det.
%
%   Lado es el que mueve en Posicion, como en tateti(N).
turno(plano(N), P, Lado) :-
    turno(tateti(N), P, Lado).

%!  fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   La partida terminó en Posicion con Resultado: en plano(N), plano(R) con
%   el resultado R de tateti(N). Falla si la partida sigue.
fin(plano(N), P, plano(R)) :-
    fin(tateti(N), P, R).

%!  valor_final(+Resultado, +Posicion, -Valor:integer) is det.
%
%   Valor es el de una partida terminada, para x: 0 el empate, 100 si gana
%   x y -100 si gana o, sin contar las casillas vacías.
valor_final(plano(empate), _, 0).
valor_final(plano(gana(J)), _, V) :-
    signo(J, S),
    V is S * 100.
```

```prolog
?- minimax(plano(3), pos([x,o,x, v,x,o, v,o,v], x), 9, J, V, N).
J = 4,
V = 100,
N = 8.

?- minimax(tateti(3), pos([x,o,x, v,x,o, v,o,v], x), 9, J, V, N).
J = 7,
V = 102,
N = 8.
```

x gana en el acto con 7 (la diagonal 3-5-7) o con 9 (la diagonal 1-5-9).
Sin el premio, la jugada 4 también gana, una jugada más tarde, porque deja
dos amenazas; vale 100 como las otras y es la primera del orden natural.
Un programa así elige cualquier jugada ganadora, y contra una persona
puede dar vueltas sin cerrar una partida ganada: en cada jugada ve que
sigue ganando, y nada lo empuja a terminar. El premio por las casillas
vacías hace que ganar antes valga más.

## 4

<!-- ejemplo: capitulo-41/soluciones.pl predicado: negamax/6 nega/8 mejor_nega/10 signo_lado/2 otro_lado/2 -->
```prolog
%!  negamax(+Juego, +Posicion, +Profundidad:integer, -Jugada, -Valor,
%!          -Nodos:integer) is det.
%
%   Como minimax/6, con un solo caso para los dos jugadores: internamente,
%   el valor de una posición se mide desde el punto de vista del que mueve.
%   Valor es, como en minimax/6, desde el punto de vista de max.
negamax(Juego, Posicion, Profundidad, Jugada, Valor, Nodos) :-
    turno(Juego, Posicion, Lado),
    signo_lado(Lado, S),
    nega(Juego, Posicion, Lado, Profundidad, Jugada, V, 0, Nodos),
    Valor is S * V.

%!  nega(+Juego, +Posicion, +Lado, +Profundidad:integer, -Jugada, -Valor,
%!       +N0:integer, -N:integer) is det.
%
%   Valor es el valor de Posicion para Lado, el jugador que mueve en ella.
%   Los valores de las posiciones siguientes, que son del rival, se toman
%   con el signo cambiado, y siempre se elige el máximo.
nega(Juego, Posicion, Lado, Profundidad, Jugada, Valor, N0, N) :-
    N1 is N0 + 1,
    signo_lado(Lado, S),
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, V),
        Valor is S * V,
        Jugada = ninguna,
        N = N1
    ;   Profundidad =:= 0
    ->  evaluar(Juego, Posicion, V),
        Valor is S * V,
        Jugada = ninguna,
        N = N1
    ;   findall(J-P, jugada(Juego, Posicion, J, P), [J1-P1|Hijos]),
        otro_lado(Lado, Rival),
        Profundidad1 is Profundidad - 1,
        nega(Juego, P1, Rival, Profundidad1, _, V1, N1, N2),
        W1 is -V1,
        mejor_nega(Hijos, Juego, Rival, Profundidad1, J1, W1, Jugada, Valor,
                   N2, N)
    ).

%!  mejor_nega(+Hijos:list, +Juego, +Rival, +Profundidad:integer, +J0,
%!             +V0, -Jugada, -Valor, +N0:integer, -N:integer) is det.
%
%   Jugada y Valor son los de la jugada de mayor valor, con el signo
%   cambiado del que tiene para Rival, entre J0 y las de Hijos.
mejor_nega([], _, _, _, Jugada, Valor, Jugada, Valor, N, N).
mejor_nega([J-P|Hijos], Juego, Rival, Profundidad, J0, V0, Jugada, Valor,
           N0, N) :-
    nega(Juego, P, Rival, Profundidad, _, V1, N0, N1),
    V is -V1,
    (   V > V0
    ->  mejor_nega(Hijos, Juego, Rival, Profundidad, J, V, Jugada, Valor,
                   N1, N)
    ;   mejor_nega(Hijos, Juego, Rival, Profundidad, J0, V0, Jugada, Valor,
                   N1, N)
    ).

% signo_lado(L, S): el valor de max se multiplica por S para el lado L.
signo_lado(max, 1).
signo_lado(min, -1).

% otro_lado(L, R): R es el lado contrario de L.
otro_lado(max, min).
otro_lado(min, max).
```

`nega/8` recibe el lado que mueve, porque el árbol de ejemplo no dice quién
mueve en las hojas, y lo pasa cambiado a las posiciones siguientes. Los
valores finales y la evaluación, que son desde el punto de vista de max, se
multiplican por el signo del que mueve; el valor de una jugada es el de la
posición a la que lleva con el signo cambiado, y siempre se elige el
máximo. Las pruebas comparan jugada, valor y nodos con `minimax/6` sobre
una muestra de posiciones.

```prolog
?- negamax(arbol, a, 3, J, V, N).
J = b,
V = 5,
N = 15.

?- negamax(tateti(3), pos([x,o,v, v,x,v, v,v,o], o), 9, J, V, N).
J = 3,
V = 0,
N = 250.
```

## 5

La poda busca c primero: f vale 2 (hojas 1 y 2), así que c vale 2 o menos;
en g, la hoja g1 vale 8, que alcanza la cota de min en c, y g2 no se busca.
Después b, con alfa en 2: d vale 5; en e, la hoja e1 vale 6, que alcanza la
cota de min en b, 5, y e2 no se busca. Quedan sin buscar g2 y e2, y se
visitan 13 nodos, contra 11 con b primero:

<!-- ejemplo: capitulo-41/soluciones.pl fragmento: inicial(invertido, a). .. hoja(P, V). -->
```prolog
inicial(invertido, a).

jugada(invertido, P, H, H) :-
    (   P == a
    ->  member(H, [c, b])
    ;   rama(P, H)
    ).

turno(invertido, P, Lado) :-
    mueve(P, Lado).

fin(invertido, P, hoja(V)) :-
    hoja(P, V).
```

```prolog
?- alfabeta(invertido, a, 3, J, V, N).
J = b,
V = 5,
N = 13.
```

El orden de la raíz importa: con la mejor jugada primero, la cota que deja
es más alta, y poda más en las jugadas que siguen.

## 6

<!-- ejemplo: capitulo-41/soluciones.pl predicado: linea/2 casilla/4 casilla_columna/4 diagonal/3 antidiagonal/3 -->
```prolog
%!  linea(+N:integer, -Casillas:list(integer)) is nondet.
%
%   Casillas son las de una fila, una columna o una diagonal de un tablero
%   de N por N, en orden: primero las filas, después las columnas, después
%   la diagonal principal y la otra.
linea(N, Casillas) :-
    numlist(1, N, Is),
    (   between(1, N, F),
        maplist(casilla(N, F), Is, Casillas)
    ;   between(1, N, C),
        maplist(casilla_columna(N, C), Is, Casillas)
    ;   maplist(diagonal(N), Is, Casillas)
    ;   maplist(antidiagonal(N), Is, Casillas)
    ).

%!  casilla(+N:integer, +Fila:integer, +Columna:integer, -Casilla:integer)
%!      is det.
%
%   Casilla es el número de la casilla en Fila y Columna, contadas desde 1.
casilla(N, Fila, Columna, Casilla) :-
    Casilla is (Fila - 1) * N + Columna.

%!  casilla_columna(+N:integer, +Columna:integer, +Fila:integer,
%!                  -Casilla:integer) is det.
%
%   Como casilla/4, con la columna antes que la fila.
casilla_columna(N, Columna, Fila, Casilla) :-
    casilla(N, Fila, Columna, Casilla).

%!  diagonal(+N:integer, +I:integer, -Casilla:integer) is det.
%
%   Casilla es la de la fila I en la diagonal principal.
diagonal(N, I, Casilla) :-
    casilla(N, I, I, Casilla).

%!  antidiagonal(+N:integer, +I:integer, -Casilla:integer) is det.
%
%   Casilla es la de la fila I en la otra diagonal.
antidiagonal(N, I, Casilla) :-
    Columna is N + 1 - I,
    casilla(N, I, Columna, Casilla).
```

`linea/2` es `nondet`: da las 2N + 2 líneas de a una, en el orden de
`lineas/2`. El modo es `+N`, porque con N libre `between/3` lanza un error
de instanciación.

```prolog
?- findall(L, linea(4, L), Ls), length(Ls, K).
Ls = [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16], [1, 5, 9, 13], [2, 6, 10|...], [3, 7|...], [4|...], [...|...]|...],
K = 10.

?- aggregate_all(count, linea(5, _), N).
N = 12.
```

Las pruebas comprueban que `findall/3` sobre `linea/2` da exactamente las
listas de `lineas/2` para 3 y 4.

## 7

<!-- ejemplo: capitulo-41/soluciones_orden.pl predicado: evaluar_amenazas/3 amenaza/3 -->
```prolog
%!  evaluar_amenazas(+Juego, +Posicion, -Valor:integer) is det.
%
%   Valor es el de evaluar/3 más 10 por cada línea en la que a x le falta
%   una marca y no hay ninguna o, menos 10 por cada una al revés.
evaluar_amenazas(Juego, Posicion, Valor) :-
    evaluar(Juego, Posicion, V0),
    Posicion = pos(Tablero, _),
    lineas(Juego, Lineas),
    aggregate_all(count, ( member(L, Lineas), amenaza(Tablero, o, L) ),
                  X),
    aggregate_all(count, ( member(L, Lineas), amenaza(Tablero, x, L) ),
                  O),
    Valor is V0 + 10 * (X - O).

%!  amenaza(+Tablero:list, +Rival, +Linea:list(integer)) is semidet.
%
%   Linea tiene una sola casilla vacía y ninguna marca de Rival: al otro
%   jugador le falta una marca para completarla.
amenaza(Tablero, Rival, Linea) :-
    abierta(Tablero, Rival, Linea),
    include(marca(Tablero, v), Linea, [_]).
```

```prolog
?- evaluar(tateti(3), pos([x,v,v, v,o,v, v,v,x], o), V).
V = 1.

?- evaluar_amenazas(tateti(3), pos([x,v,v, v,o,v, v,v,x], o), V).
V = 1.

?- evaluar(tateti(3), pos([x,x,v, v,o,v, v,v,v], o), V).
V = 0.

?- evaluar_amenazas(tateti(3), pos([x,x,v, v,o,v, v,v,v], o), V).
V = 10.
```

En la primera posición ninguna línea tiene dos marcas de un jugador y
ninguna del otro, porque la diagonal de x pasa por la o del centro, y las
dos evaluaciones coinciden. En la segunda, x amenaza completar la fila de
arriba: las líneas abiertas dan 0, y la amenaza, 10. Una amenaza vale poco
si mueve el que la tiene que tapar, como aquí, y mucho si mueve el que la
puede completar; una evaluación que lo distinga necesita saber quién mueve.

## 8

<!-- ejemplo: capitulo-41/soluciones_orden.pl fragmento: %!  ordenar(+Orden, +Juego, +Lado, +Hijos0:list, -Hijos:list) is det. .. Clave is -K. -->
```prolog
%!  ordenar(+Orden, +Juego, +Lado, +Hijos0:list, -Hijos:list) is det.
%
%   Con central, Hijos son los pares de Hijos0 ordenados por centralidad/3:
%   primero las jugadas en las casillas por las que pasan más líneas.
ordenar(central, Juego, _, Hijos0, Hijos) :-
    map_list_to_pairs(centralidad(Juego), Hijos0, Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Hijos).

%!  centralidad(+Juego, +Hijo, -Clave:integer) is det.
%
%   Clave es la cantidad de líneas que pasan por la casilla de la jugada
%   de Hijo, con el signo cambiado: las más centrales quedan primero.
centralidad(Juego, Casilla-_, Clave) :-
    lineas(Juego, Lineas),
    aggregate_all(count, ( member(L, Lineas), memberchk(Casilla, L) ), K),
    Clave is -K.
```

Medido en esta máquina, en el tablero de 4 × 4 vacío, a profundidad 6:

| Orden | Nodos | Inferencias | Segundos |
|---|---:|---:|---:|
| natural | 41 330 | 19 549 647 | 2,4 |
| mejores | 8 669 | 20 892 662 | 2,8 |
| central | 14 637 | 9 060 697 | 1,7 |

El orden central poda menos que `mejores`, pero cuesta mucho menos: cuenta
las líneas de una casilla con `memberchk/2`, sin examinar el tablero. Es el
único de los tres que baja las inferencias. Las líneas de cada casilla no
dependen de la posición, y se podrían calcular una sola vez por juego.

## 9

<!-- ejemplo: capitulo-41/soluciones.pl fragmento: inicial(restar(K), r(K, x)). .. V < 0 ), Pilas). -->
```prolog
inicial(restar(K), r(K, x)).

jugada(restar(_), r(K, J), S, r(K1, Otro)) :-
    between(1, 3, S),
    S =< K,
    K1 is K - S,
    otro(J, Otro).

turno(restar(_), r(_, J), Lado) :-
    lado(J, Lado).

fin(restar(_), r(0, J), restar(gana(Otro))) :-
    otro(J, Otro).

valor_final(restar(gana(J)), _, V) :-
    signo(J, S),
    V is S * 100.

%!  perdedoras(+Maximo:integer, -Pilas:list(integer)) is det.
%
%   Pilas son las pilas de 1 a Maximo fichas en las que pierde el que
%   mueve, según la poda buscada hasta el final.
perdedoras(Maximo, Pilas) :-
    findall(K, ( between(1, Maximo, K),
                 alfabeta(restar(K), r(K, x), K, _, V, _),
                 V < 0 ), Pilas).
```

```prolog
?- perdedoras(12, Pilas).
Pilas = [4, 8, 12].
```

Pierde el que mueve con un múltiplo de 4: saque lo que saque, de 1 a 3, el
rival saca lo que falta para volver a un múltiplo de 4, y termina sacando
la última. Con cualquier otra pila, el que mueve deja un múltiplo de 4. El
resultado de `fin/3` es `restar(gana(J))` y no `gana(J)`: con `gana(J)`,
`valor_final/3` tenía dos cláusulas posibles, la del ta-te-ti y la de
restar, y la búsqueda dejaba un punto de elección.

## 10

<!-- ejemplo: capitulo-41/soluciones_simetria.pl predicado: valor_simetrico/3 valor_canonico/3 canonica/2 simetria/1 -->
```prolog
%!  valor_simetrico(+Juego, +Posicion, -Valor) is det.
%
%   Valor es el valor minimax de Posicion, buscando hasta el final, con
%   una tabla por cada grupo de posiciones simétricas.
valor_simetrico(Juego, pos(Tablero, Turno), Valor) :-
    canonica(Tablero, Canonico),
    valor_canonico(Juego, pos(Canonico, Turno), Valor).

%!  valor_canonico(+Juego, +Posicion, -Valor) is det.
%
%   Como valor/3 de transposicion.pl, para una posición en forma canónica.
%   Las posiciones siguientes se buscan con valor_simetrico/3.
valor_canonico(Juego, Posicion, Valor) :-
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor)
    ;   turno(Juego, Posicion, Lado),
        findall(V, ( jugada(Juego, Posicion, _, P),
                     valor_simetrico(Juego, P, V) ), Valores),
        extremo(Lado, Valores, Valor)
    ).

%!  canonica(+Tablero:list, -Canonico:list) is det.
%
%   Canonico es la menor, en el orden estándar, de las ocho simetrías de
%   Tablero, un tablero de 3 por 3.
canonica(Tablero, Canonico) :-
    findall(S, ( simetria(Orden),
                 maplist(casilla_de(Tablero), Orden, S) ), Simetricos),
    min_member(Canonico, Simetricos).

% simetria(O): el tablero girado o reflejado tiene en cada casilla, por
% filas, la marca de la casilla de O del tablero original.
simetria([1, 2, 3, 4, 5, 6, 7, 8, 9]).
simetria([7, 4, 1, 8, 5, 2, 9, 6, 3]).
simetria([9, 8, 7, 6, 5, 4, 3, 2, 1]).
simetria([3, 6, 9, 2, 5, 8, 1, 4, 7]).
simetria([7, 8, 9, 4, 5, 6, 1, 2, 3]).
simetria([3, 2, 1, 6, 5, 4, 9, 8, 7]).
simetria([1, 4, 7, 2, 5, 8, 3, 6, 9]).
simetria([9, 6, 3, 8, 5, 2, 7, 4, 1]).
```

```prolog
?- inicial(tateti(3), P), valor_simetrico(tateti(3), P, V), canonicas(N).
P = pos([v, v, v, v, v, v, v, v|...], x),
V = 0,
N = 765.
```

Quedan 765 posiciones distintas, contra 5 478. La búsqueda tarda 0,14
segundos y 1 175 975 inferencias, casi lo mismo que con 5 478 tablas:
calcular las ocho simetrías de cada posición cuesta lo que ahorra la tabla.
La tabla es siete veces más pequeña, y eso importa cuando la memoria es el
límite.

## 11

<!-- ejemplo: capitulo-41/soluciones.pl predicado: acotado_tabulado/5 cotas_tabuladas/6 tablas_de_la_poda/1 -->
```prolog
%!  acotado_tabulado(+Juego, +Posicion, +Alfa, +Beta, -Valor) is det.
%
%   Como acotado/9 de la poda, hasta el final de la partida y sin la
%   jugada ni el contador, tabulado con las cotas como argumentos.
acotado_tabulado(Juego, Posicion, Alfa, Beta, Valor) :-
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor)
    ;   findall(P, jugada(Juego, Posicion, _, P), Siguientes),
        turno(Juego, Posicion, Lado),
        cotas_tabuladas(Siguientes, Juego, Lado, Alfa, Beta, Valor)
    ).

%!  cotas_tabuladas(+Posiciones:list, +Juego, +Lado, +Alfa, +Beta, -Valor)
%!      is det.
%
%   Como cotas/11 de la poda, sobre acotado_tabulado/5.
cotas_tabuladas([], _, Lado, Alfa, Beta, Valor) :-
    propia(Lado, Alfa, Beta, Valor).
cotas_tabuladas([P|Ps], Juego, Lado, Alfa, Beta, Valor) :-
    acotado_tabulado(Juego, P, Alfa, Beta, V),
    (   poda(Lado, V, Alfa, Beta)
    ->  Valor = V
    ;   estrecha(Lado, V, Alfa, Beta, Alfa1, Beta1)
    ->  cotas_tabuladas(Ps, Juego, Lado, Alfa1, Beta1, Valor)
    ;   cotas_tabuladas(Ps, Juego, Lado, Alfa, Beta, Valor)
    ).

%!  tablas_de_la_poda(-Cantidad:integer) is det.
%
%   Cantidad es la cantidad de tablas de acotado_tabulado/5.
tablas_de_la_poda(Cantidad) :-
    aggregate_all(count,
                  ( current_table(Variante, _),
                    Variante = acotado_tabulado(_, _, _, _, _) ),
                  Cantidad).
```

```prolog
?- inicial(tateti(3), P), acotado_tabulado(tateti(3), P, -inf, inf, V), tablas_de_la_poda(T).
P = pos([v, v, v, v, v, v, v, v|...], x),
V = 0,
T = 5138.
```

La poda tabulada deja 5 138 tablas, que corresponden a solo 2 668
posiciones distintas: la poda no visita casi la mitad de las 5 478
posiciones, pero cada posición visitada con cotas distintas es otra
variante y abre otra tabla. El valor guardado con unas cotas es una cota,
y no sirve para otras. Tarda 0,17 segundos, poco menos que minimax
tabulado.

## 12

<!-- ejemplo: capitulo-41/profundizacion.pl predicado: evaluar/3 -->
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
```

```prolog
?- inicial(tateti(4), P), findall(D-V, (between(1, 6, D), alfabeta(tateti(4), P, D, _, V, _)), Vs).
P = pos([v, v, v, v, v, v, v, v|...], x),
Vs = [1-3, 2-0, 3-3, 4-0, 5-2, 6-0].

?- evaluar(tateti(4), pos([x,v,v,v, v,v,v,v, v,v,v,v, v,v,v,v], o), V).
V = 3.

?- evaluar(tateti(4), pos([x,o,v,v, v,v,v,v, v,v,v,v, v,v,v,v], x), V).
V = 1.
```

Con profundidad impar, la última jugada de la búsqueda es de x, y la
evaluación se aplica sin la respuesta de o: una x en la esquina cierra tres
líneas para o y vale 3. Con profundidad par, la última es de o, que cierra
líneas de x: en un borde, como la 2, deja 1, y en una casilla de tres
líneas, como la 6, la mejor respuesta, deja 0. Es el efecto horizonte en su forma más
simple: el que hace la última jugada antes del límite parece llevar
ventaja. Por eso los programas comparan valores de búsquedas con la misma
paridad, o extienden la búsqueda hasta una posición tranquila.

## 13

<!-- ejemplo: capitulo-41/soluciones_terminal.pl predicado: jugar_con_o/2 inicio_con_o/3 bucle_para/4 pantalla_para/3 mensaje_para/5 resultado_para/3 -->
```prolog
%!  jugar_con_o(+N:integer, +Rival) is det.
%
%   Juega en la terminal una partida de N por N en la que la computadora
%   mueve primero, con x, y la persona juega con o.
jugar_con_o(N, Rival) :-
    inicio_con_o(N, Rival, Estado),
    con_pantalla(bucle_para(o, get_single_char, Estado, _)).

%!  inicio_con_o(+N:integer, +Rival, -Estado) is det.
%
%   Estado es el de una partida nueva después de la primera jugada de la
%   computadora.
inicio_con_o(N, Rival, e(tateti(N), Rival, P, 1, jugar)) :-
    inicial(tateti(N), P0),
    responder(Rival, tateti(N), P0, P).

%!  bucle_para(+Persona, :Siguiente, +Estado0, -Estado) is det.
%
%   Como bucle/3, con la pantalla de una persona que juega con la marca
%   Persona.
bucle_para(Persona, Siguiente, Estado0, Estado) :-
    pantalla_para(Persona, Estado0, Lineas),
    dibujar(Lineas),
    (   terminado(Estado0)
    ->  Estado = Estado0
    ;   leer_tecla(Siguiente, Tecla),
        paso(Tecla, Estado0, Estado1),
        bucle_para(Persona, Siguiente, Estado1, Estado)
    ).

%!  pantalla_para(+Persona, +Estado, -Lineas:list(string)) is det.
%
%   Como pantalla/2, con los mensajes para una persona que juega con la
%   marca Persona.
pantalla_para(Persona, e(tateti(N), _, pos(Tablero, _), Cursor, Pedido),
              Lineas) :-
    numlist(1, N, Filas),
    maplist(fila_con_cursor(N, Tablero, Cursor), Filas, Dibujo),
    caja("Ta-te-ti", Dibujo, Caja),
    mensaje_para(Persona, tateti(N), pos(Tablero, _), Pedido, Mensaje),
    caja("Estado", [Mensaje], Estado),
    Ayuda = "Flechas: mover  Espacio o cifra: marcar  q: salir",
    append([Caja, Estado, [Ayuda]], Lineas).

%!  mensaje_para(+Persona, +Juego, +Posicion, +Pedido, -Mensaje:string)
%!      is det.
%
%   Como mensaje/4, para una persona que juega con la marca Persona.
mensaje_para(_, _, _, salir, "Partida abandonada.") :-
    !.
mensaje_para(Persona, Juego, Posicion, jugar, Mensaje) :-
    (   fin(Juego, Posicion, Resultado)
    ->  resultado_para(Resultado, Persona, Mensaje)
    ;   upcase_atom(Persona, Marca),
        format(string(Mensaje), "Tu turno: juegas con ~w.", [Marca])
    ).

%!  resultado_para(+Resultado, +Persona, -Mensaje:string) is det.
%
%   Mensaje anuncia Resultado a la persona que juega con Persona.
resultado_para(empate, _, "Empate.").
resultado_para(gana(J), Persona, Mensaje) :-
    (   J == Persona
    ->  Mensaje = "Ganaste."
    ;   Mensaje = "Gana la computadora."
    ).
```

`paso/3`, `marcar/3` y `responder/4` sirven sin cambios: `jugada/4` marca
con el jugador de turno, que es o cuando le toca a la persona, y la poda
busca para el lado que mueve, que es max cuando responde x. Hay que
cambiar el comienzo, porque la computadora juega antes de la primera
tecla, y los mensajes: `mensaje/4` supone que la persona juega con x, y
con o anunciaría «Ganaste.» cuando gana la computadora. `mensaje_para/5`
recibe la marca de la persona, y `pantalla_para/3` y `bucle_para/4` son
`pantalla/2` y `bucle/3` con esa marca como argumento; `jugar_con_o/2`
usa `bucle_para/4`. `resultado_para/3` lleva primero el resultado, el
argumento que decide la cláusula, y no deja puntos de elección. Las
pruebas juegan una partida entera con las teclas en una cadena, como las
de `tateti_terminal.plt`, y comprueban que la última pantalla anuncia la
victoria de la computadora.

```prolog
?- mensaje_para(o, tateti(3), pos([o,o,o, x,x,v, x,v,v], x), jugar, M).
M = "Ganaste.".
```

## 14

<!-- ejemplo: capitulo-41/soluciones_terminal.pl predicado: autojuego/5 seguir/6 rival_de/4 -->
```prolog
%!  autojuego(+Juego, +RivalX, +RivalO, -Jugadas:list(integer), -Resultado)
%!      is det.
%
%   Jugadas son las de una partida entera de Juego en la que x elige con
%   RivalX y o con RivalO, y Resultado es cómo termina.
autojuego(Juego, RivalX, RivalO, Jugadas, Resultado) :-
    inicial(Juego, P),
    seguir(Juego, RivalX, RivalO, P, Jugadas, Resultado).

%!  seguir(+Juego, +RivalX, +RivalO, +Posicion, -Jugadas:list(integer),
%!         -Resultado) is det.
%
%   Jugadas son las que siguen a Posicion hasta el final de la partida.
seguir(Juego, RivalX, RivalO, P, Jugadas, Resultado) :-
    (   fin(Juego, P, R)
    ->  Jugadas = [],
        Resultado = R
    ;   turno(Juego, P, Lado),
        rival_de(Lado, RivalX, RivalO, Rival),
        responder(Rival, Juego, P, P1),
        jugada(Juego, P, J, P1),
        !,
        Jugadas = [J|Js],
        seguir(Juego, RivalX, RivalO, P1, Js, Resultado)
    ).

% rival_de(Lado, RX, RO, R): elige para Lado el rival R, RX para max y RO
% para min.
rival_de(max, RX, _, RX).
rival_de(min, _, RO, RO).
```

```prolog
?- autojuego(tateti(3), profundidad(9), profundidad(9), Js, R).
Js = [1, 5, 2, 3, 7, 4, 6, 8, 9],
R = empate.

?- autojuego(tateti(3), profundidad(9), profundidad(1), Js, R).
Js = [1, 5, 2, 3, 7, 4, 6, 8, 9],
R = empate.

?- autojuego(tateti(4), profundidad(4), profundidad(1), Js, R).
Js = [1, 4, 7, 6, 10, 9, 8, 15, 2, 3, 5, 11, 12, 13, 14, 16],
R = empate.
```

Entre dos búsquedas completas, el ta-te-ti termina empatado, como mostró
`ganada/2`. Contra la profundidad 1, x no logra ganar: con la evaluación
por líneas abiertas, o elige en cada jugada la casilla que deja la
evaluación más baja, la que más líneas de x cierra, y en el ta-te-ti eso
alcanza para tapar a tiempo. En el tablero de
4 × 4 la partida también se llena sin ganador: cuatro en línea en un
tablero de cuatro columnas se tapan con facilidad. En los dos casos, lo
que la búsqueda más profunda gana no alcanza para una victoria, porque el
juego no la tiene: ganar exige que el rival se equivoque, y la evaluación
lo evita incluso sin buscar jugadas hacia adelante.
