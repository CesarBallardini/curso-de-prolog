# Capítulo 42 — Juegos

En un juego de dos jugadores, las jugadas de uno alternan con las del otro,
y el segundo elige las suyas contra el primero. Buscar una jugada ya no es
buscar un camino hasta una meta, como en el
[capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md): es buscar
una jugada que resulte buena **cualquiera sea la respuesta** del rival. La
búsqueda recorre el **árbol de la partida**, cuyas posiciones alternan
entre las que decide un jugador y las que decide el otro, y en los juegos
de interés ese árbol es demasiado grande para recorrerlo entero: una
búsqueda útil examina unas pocas jugadas hacia adelante y estima el resto.

El capítulo sigue una escalera sobre el **ta-te-ti**. El juego se describe
con cinco predicados que la búsqueda no conoce por dentro, como el problema
del capítulo anterior; una primera búsqueda recorre el árbol entero para
decidir si una posición está ganada; **minimax** da a cada posición un
valor numérico y corta la búsqueda a una profundidad fija; la **poda
alfa-beta** llega a los mismos valores sin visitar las posiciones que no
pueden cambiar la decisión; una **función de evaluación** estima las
posiciones del límite, y el **orden de las jugadas** decide cuánto poda la
poda. Las últimas secciones completan la escalera: la
[profundización progresiva](profundizacion.md#425-profundizacion-progresiva-con-limite-de-tiempo)
con un límite de tiempo, y las jugadas buscadas en paralelo; las
[tablas de transposición](transposicion.md#426-tablas-de-transposicion-con-tabulacion)
escritas con la tabulación del
[capítulo 40](../capitulo-40-tabulacion/index.md); y
[el ta-te-ti completo en la terminal](terminal.md#427-el-ta-te-ti-completo-en-la-terminal),
con la interfaz del [capítulo 37](../capitulo-37-interfaces-de-usuario/index.md).

La fuente principal es el capítulo «Game Playing» de *Prolog Programming
for Artificial Intelligence* de Ivan Bratko (Addison-Wesley, 1986), del que el capítulo toma la
posición ganada definida como un árbol Y/O, el principio minimax, el
algoritmo alfa-beta con su valor «suficientemente bueno» entre dos cotas,
la importancia del orden de las jugadas, la profundización progresiva y el
efecto horizonte. La segunda es *The Art of Prolog* de Leon Sterling y Ehud
Shapiro (MIT Press, 2.ª edición, 1994): sus capítulos «Search Techniques», que escribe minimax y alfa-beta con un
solo caso para los dos jugadores, y «Game-Playing Programs», con programas
para Mastermind, Nim y Kalah. Esos tres juegos son el proyecto del
[capítulo 79](../capitulo-79-proyecto-kalah-mastermind-nim/index.md), y aquí
solo se los menciona. Los programas del capítulo están escritos para el
curso. Cada página termina con las referencias que usa; las de esta página
están en sus [Referencias](#referencias).

El capítulo cumple los anuncios de los capítulos
[9](../capitulo-09-backtracking-y-corte/index.md) y
[23](../capitulo-23-estructuras-de-datos-de-la-biblioteca/index.md) (la
búsqueda con un adversario, los juegos de dos jugadores), del
[capítulo 37](../capitulo-37-interfaces-de-usuario/index.md) (un tablero
redibujado en cada jugada), del
[capítulo 38](../capitulo-38-concurrencia-y-paralelismo/index.md) (jugadas
buscadas en paralelo y con un límite de tiempo), del
[capítulo 40](../capitulo-40-tabulacion/index.md) (las tablas de
transposición) y del
[capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) (minimax y
la poda alfa-beta). Salvo las jugadas en paralelo y la terminal, los
ejemplos corren en SWISH: para eso, cada archivo termina con una copia del
código que usa de los otros, y las pruebas de `copias.pl` verifican que
cada copia coincide, cláusula por cláusula, con su original.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- describir un juego de dos jugadores con `inicial/2`, `jugada/4`,
  `turno/3`, `fin/3` y `valor_final/3`, con el juego como un término que la
  búsqueda recibe;
- decidir si una posición está ganada recorriendo el árbol entero, y
  explicar por qué eso solo sirve en juegos pequeños;
- escribir minimax con un límite de profundidad y una evaluación estática,
  y calcular a mano los valores de un árbol pequeño;
- escribir la poda alfa-beta, explicar qué significan las dos cotas y por
  qué el valor y la jugada no cambian, y contar los nodos que ahorra;
- escribir una función de evaluación y ordenar las jugadas con ella, y medir
  cuándo el orden paga lo que cuesta;
- buscar con profundización progresiva dentro de un tiempo fijo, en un hilo
  o repartida entre varios;
- usar la tabulación como tabla de transposición, y reconocer cuándo no
  alcanza sin la poda;
- jugar al ta-te-ti contra la computadora en la terminal, con el núcleo del
  juego separado de la interfaz.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **3:10 h**.
    Resolver los 6 ejercicios marcados con ★: **1:40 h**.
    Resolver los 14 ejercicios del capítulo: **4:00 h**.

## 42.1 Posiciones, jugadas y fin de partida

El ta-te-ti se juega en un tablero de 3 × 3; dos jugadores, x y o, marcan
por turno una casilla vacía, y gana quien completa una fila, una columna o
una diagonal. `tateti.pl` describe también el tablero de 4 × 4, con cuatro
en línea, que las secciones siguientes usan cuando el de 3 × 3 resulta demasiado pequeño.
El juego es un término, `tateti(3)` o `tateti(4)`, y es el primer argumento
de cada predicado de la descripción. Una posición es `pos(Tablero, Turno)`:
la lista de las casillas por filas, cada una `x`, `o` o `v` (vacía), y el
jugador que mueve. Una jugada es el número de una casilla, de 1 a 9 en el
tablero de 3 × 3.

<!-- ejemplo: capitulo-42/tateti.pl predicado: inicial/2 jugada/4 otro/2 turno/3 lado/2 consulta: findall(J, jugada(tateti(3), pos([x,o,v, v,x,v, v,v,o], x), J, _), Js). -->
```prolog
%!  inicial(+Juego, -Posicion) is det.
%
%   Posicion es la de partida de Juego: el tablero vacío, y mueve x.
inicial(tateti(N), pos(Tablero, x)) :-
    Casillas is N * N,
    length(Tablero, Casillas),
    maplist(=(v), Tablero).

%!  jugada(+Juego, +Posicion, ?Casilla:integer, -Siguiente) is nondet.
%
%   Siguiente es la posición que resulta de que el jugador de turno en
%   Posicion marque Casilla, una casilla vacía. No comprueba si la partida
%   terminó: las búsquedas llaman antes a fin/3.
jugada(tateti(_), pos(Tablero0, Jugador), Casilla, pos(Tablero, Otro)) :-
    nth1(Casilla, Tablero0, v, Resto),
    nth1(Casilla, Tablero, Jugador, Resto),
    otro(Jugador, Otro).

% otro(J, K): K es el rival de J.
otro(x, o).
otro(o, x).

%!  turno(+Juego, +Posicion, -Lado) is det.
%
%   Lado es max si en Posicion mueve x, que busca los valores altos, y min
%   si mueve o.
turno(tateti(_), pos(_, Jugador), Lado) :-
    lado(Jugador, Lado).

% lado(J, L): el jugador J es L, max o min.
lado(x, max).
lado(o, min).
```

`nth1/4` saca y pone un elemento en una posición de una lista: con
`nth1(Casilla, Tablero0, v, Resto)` se elige una casilla vacía y `Resto` es
el tablero sin ella, y `nth1(Casilla, Tablero, Jugador, Resto)`, en sentido
inverso, pone la marca en el mismo lugar. `turno/3` dice qué hace el
jugador de turno con los valores: x es **max**, que busca los valores
altos, y o es **min**, que busca los bajos.

El fin de la partida lo reconoce `fin/3`. Las líneas de cada tablero están
escritas como un hecho, y `fin/3` busca una cuya primera casilla tenga una
marca que se repite en todas las demás:

<!-- ejemplo: capitulo-42/tateti.pl predicado: fin/3 marca/3 lineas/2 valor_final/3 signo/2 -->
```prolog
%!  fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   La partida terminó en Posicion con Resultado: gana(J) si J completó una
%   línea, o empate si el tablero está lleno. Falla si la partida sigue.
fin(Juego, pos(Tablero, _), Resultado) :-
    lineas(Juego, Lineas),
    (   member([C|Cs], Lineas),
        marca(Tablero, J, C),
        J \== v,
        maplist(marca(Tablero, J), Cs)
    ->  Resultado = gana(J)
    ;   \+ memberchk(v, Tablero),
        Resultado = empate
    ).

%!  marca(+Tablero:list, ?Marca, +Casilla:integer) is semidet.
%
%   Marca es lo que hay en Casilla: x, o o v.
marca(Tablero, Marca, Casilla) :-
    nth1(Casilla, Tablero, Marca).

% lineas(Juego, Lineas): Lineas son las filas, las columnas y las dos
% diagonales del tablero de Juego, cada una como la lista de sus casillas.
lineas(tateti(3), [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [1, 5, 9], [3, 5, 7]]).
lineas(tateti(4), [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12],
                   [13, 14, 15, 16],
                   [1, 5, 9, 13], [2, 6, 10, 14], [3, 7, 11, 15],
                   [4, 8, 12, 16],
                   [1, 6, 11, 16], [4, 7, 10, 13]]).

%!  valor_final(+Resultado, +Posicion, -Valor:integer) is det.
%
%   Valor es el de una partida terminada, para x: 0 el empate, y 100 más la
%   cantidad de casillas vacías si gana x, con el signo cambiado si gana o.
%   Las casillas vacías premian ganar antes.
valor_final(empate, _, 0).
valor_final(gana(J), pos(Tablero, _), Valor) :-
    include(==(v), Tablero, Vacias),
    length(Vacias, K),
    signo(J, S),
    Valor is S * (100 + K).

% signo(J, S): S es 1 si J es x, que maximiza, y -1 si es o, que minimiza.
signo(x, 1).
signo(o, -1).
```

`valor_final/3` da el valor de una partida terminada desde el punto de
vista de x: 0 el empate, y 100 más las casillas vacías una victoria de x,
con el signo cambiado si gana o. Las casillas vacías hacen que una victoria
rápida valga más que una lenta; el [ejercicio 3](#ejercicios) muestra qué
pasa sin ellas. Las consultas se leen como las reglas del juego:

```prolog
?- findall(J, jugada(tateti(3), pos([x,o,v, v,x,v, v,v,o], x), J, _), Js).
Js = [3, 4, 6, 7, 8].

?- fin(tateti(3), pos([x,o,v, v,x,v, v,v,o], x), R).
false.

?- fin(tateti(3), pos([x,o,v, x,x,o, x,v,o], o), R).
R = gana(x).

?- fin(tateti(3), pos([x,o,x, x,o,o, o,x,x], x), R).
R = empate.
```

Las líneas son hechos, y no se calculan en cada llamada, porque `fin/3` se
llama en cada posición de cada búsqueda. La primera versión las generaba
en cada llamada con `numlist/3` y `maplist/3`, y comparaba todas las
casillas de cada línea: recorrer el árbol entero del ta-te-ti tardaba 20
segundos. Con las líneas como hechos y una comparación que se detiene en la
primera casilla distinta, tarda 7,7. El [ejercicio 6](#ejercicios)
escribe las líneas de un tablero de cualquier tamaño.

### La posición ganada, sin números

Un jugador que mueve **gana** si tiene una jugada tras la cual el rival
**pierde**; y el que mueve pierde si la partida terminó con la victoria del
otro, o si todas sus jugadas llevan a posiciones que el otro gana. Es la
definición del juego como un árbol Y/O que Bratko da al empezar el
capítulo «Game Playing»: las posiciones del que busca ganar son nodos O,
basta una jugada; las del rival son nodos Y, tienen que ser buenas todas.

<!-- ejemplo: capitulo-42/tateti.pl predicado: ganada/2 perdida/2 consulta: ganada(tateti(3), pos([x,o,v, v,x,v, v,v,o], x)). -->
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

%!  perdida(+Juego, +Posicion) is semidet.
%
%   El jugador de turno en Posicion pierde: la partida terminó con la
%   victoria del rival, o todas sus jugadas llevan a posiciones ganadas
%   por el rival.
perdida(Juego, Posicion) :-
    (   fin(Juego, Posicion, Resultado)
    ->  Resultado = gana(_)
    ;   forall(jugada(Juego, Posicion, _, Siguiente),
               ganada(Juego, Siguiente))
    ).
```

`tateti.pl` define también `filas/3`, que muestra un tablero como una
lista de cadenas, una por fila, con X, O o el número de cada casilla
vacía; sirve para leer las posiciones de los ejemplos:

```prolog
?- filas(tateti(3), pos([x,o,v, v,x,v, v,v,o], x), L).
L = ["X O 3", "4 X 6", "7 8 O"].

?- ganada(tateti(3), pos([x,o,v, v,x,v, v,v,o], x)).
true.

?- ganada(tateti(3), pos([x,o,v, v,x,v, v,v,o], o)).
false.

?- inicial(tateti(3), P), ganada(tateti(3), P).
false.
```

Con x en 1 y en 5, y o en 2 y en 9, x gana: la jugada 4 amenaza completar
la fila 4-5-6 y la columna 1-4-7, y o puede tapar solo una. Si en la misma
posición mueve o, no gana, y desde el tablero vacío tampoco gana x: con
buen juego de los dos, el ta-te-ti termina empatado. `ganada/2` es la
negación como falla del [capítulo 10](../capitulo-10-negacion-como-falla/index.md)
aplicada dos veces, `\+` y `forall/2`, y es el mismo juego que la
[sección 40.4](../capitulo-40-tabulacion/subsuncion.md#404-negacion-tabulada)
resolvió con `tnot/1` sobre un grafo con ciclos; aquí no hay ciclos, porque
cada jugada llena una casilla, y la negación de Prolog termina.

La definición tiene dos límites. Solo distingue ganar de no ganar: el
empate y la derrota del que mueve dan los dos `false`. Y recorre el árbol
hasta el final de la partida. `partidas/3` cuenta las ramas de ese árbol:

```text
?- inicial(tateti(3), P), time(partidas(tateti(3), P, N)).
% 59,723,069 inferences, 7.719 CPU in 7.827 seconds (99% CPU, 7737402 Lips)
N = 255168.
```

El ta-te-ti tiene 255 168 partidas distintas y 549 946 posiciones en su
árbol, contando cada posición tantas veces como caminos llevan a ella. En
el tablero de 4 × 4, las formas de llenar las 16 casillas en orden son
16!, más de 2 · 10<sup>13</sup>; muchas partidas terminan antes, pero el
árbol queda fuera de alcance, y en el ajedrez Bratko estima del orden de
10<sup>120</sup> posiciones. Un programa que juega
no puede recorrerlo: tiene que decidir con una parte de él.

!!! question "Actividad"
    Predecir, sin ejecutarlas, las respuestas de
    `ganada(tateti(3), pos([x,v,v, v,o,v, v,v,x], o))` y de
    `ganada(tateti(3), pos([v,o,v, v,x,v, v,v,v], x))`, y cuántas partidas
    da `partidas(tateti(3), pos([x,o,x, o,x,v, v,v,o], x), N)`. Comprobarlo.

## 42.2 Minimax

Minimax da a cada posición un **valor**, un número, desde el punto de vista
de max. Una posición final vale lo que dice `valor_final/3`. Una posición
en la que mueve max vale el **máximo** de los valores de las posiciones a
las que llevan sus jugadas, y una en la que mueve min, el **mínimo**: cada
jugador elige lo mejor para sí, suponiendo que el otro hace lo mismo. Si la
búsqueda llega a una profundidad fija sin que la partida termine, la
posición recibe una **evaluación estática**, una estimación que no busca
jugadas hacia adelante. La jugada elegida es la que lleva al mejor valor.

<!-- ejemplo: capitulo-42/minimax.pl predicado: minimax/6 valor/7 mejor/10 mejora/3 consulta: minimax(arbol, a, 3, Jugada, Valor, Nodos). -->
```prolog
%!  minimax(+Juego, +Posicion, +Profundidad:integer, -Jugada, -Valor,
%!          -Nodos:integer) is det.
%
%   Valor es el valor minimax de Posicion buscando Profundidad jugadas
%   hacia adelante, y Jugada la primera de las mejores jugadas, o ninguna
%   si la partida terminó o Profundidad es 0. Nodos es la cantidad de
%   posiciones visitadas.
minimax(Juego, Posicion, Profundidad, Jugada, Valor, Nodos) :-
    valor(Juego, Posicion, Profundidad, Jugada, Valor, 0, Nodos).

%!  valor(+Juego, +Posicion, +Profundidad:integer, -Jugada, -Valor,
%!        +N0:integer, -N:integer) is det.
%
%   Como minimax/6; N es N0 más los nodos visitados.
valor(Juego, Posicion, Profundidad, Jugada, Valor, N0, N) :-
    N1 is N0 + 1,
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor),
        Jugada = ninguna,
        N = N1
    ;   Profundidad =:= 0
    ->  evaluar(Juego, Posicion, Valor),
        Jugada = ninguna,
        N = N1
    ;   findall(J-P, jugada(Juego, Posicion, J, P), [J1-P1|Hijos]),
        turno(Juego, Posicion, Lado),
        Profundidad1 is Profundidad - 1,
        valor(Juego, P1, Profundidad1, _, V1, N1, N2),
        mejor(Hijos, Juego, Lado, Profundidad1, J1, V1, Jugada, Valor,
              N2, N)
    ).

%!  mejor(+Hijos:list, +Juego, +Lado, +Profundidad:integer, +J0, +V0,
%!        -Jugada, -Valor, +N0:integer, -N:integer) is det.
%
%   Jugada y Valor son los de la mejor jugada para Lado entre J0, de valor
%   V0, y las de Hijos, pares Jugada-Posicion. Ante un empate queda la
%   primera.
mejor([], _, _, _, Jugada, Valor, Jugada, Valor, N, N).
mejor([J-P|Hijos], Juego, Lado, Profundidad, J0, V0, Jugada, Valor,
      N0, N) :-
    valor(Juego, P, Profundidad, _, V, N0, N1),
    (   mejora(Lado, V, V0)
    ->  mejor(Hijos, Juego, Lado, Profundidad, J, V, Jugada, Valor, N1, N)
    ;   mejor(Hijos, Juego, Lado, Profundidad, J0, V0, Jugada, Valor,
              N1, N)
    ).

%!  mejora(+Lado, +V:number, +V0:number) is semidet.
%
%   Para Lado, el valor V es mejor que V0: mayor si Lado es max, menor si
%   es min.
mejora(max, V, V0) :-
    V > V0.
mejora(min, V, V0) :-
    V < V0.
```

`valor/7` lleva, además, un contador de las posiciones visitadas, que
entra en `N0` y sale en `N`; es lo que las secciones siguientes comparan.
`mejor/10` recorre las jugadas con la mejor encontrada hasta el momento, y
ante un empate se queda con la primera. La búsqueda no depende del
juego: solo llama a `fin/3`, `valor_final/3`, `evaluar/3`, `jugada/4` y
`turno/3` con el juego que recibe.

Para verlo con números que se puedan seguir a mano, `minimax.pl` define un
segundo juego, `arbol`: un árbol fijo de profundidad 3, con max en la raíz y
en el tercer nivel, min en el segundo, y un valor en cada hoja. Los dos
juegos definen los mismos predicados en lugares distintos del archivo, y
por eso el archivo declara `:- discontiguous`. Las ramas, las hojas y el
jugador de cada posición son hechos, `rama/2`, `hoja/2` y `mueve/2`, que el
dibujo muestra con los valores; el juego los consulta:

<!-- ejemplo: capitulo-42/minimax.pl fragmento: %!  inicial(+Juego, -Posicion) is det. .. valor_final(hoja(V), _, V). -->
```prolog
%!  inicial(+Juego, -Posicion) is det.
%
%   Posicion es la de partida de Juego: en el árbol, la raíz.
inicial(arbol, a).

%!  jugada(+Juego, +Posicion, ?Jugada, -Siguiente) is nondet.
%
%   Siguiente es la posición a la que lleva Jugada desde Posicion: en el
%   árbol, la jugada es el hijo mismo.
jugada(arbol, P, H, H) :-
    rama(P, H).

%!  turno(+Juego, +Posicion, -Lado) is det.
%
%   Lado es max o min, el que mueve en Posicion.
turno(arbol, P, Lado) :-
    mueve(P, Lado).

%!  fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   La partida terminó en Posicion con Resultado: en el árbol, una hoja,
%   con hoja(V). Falla si la partida sigue.
fin(arbol, P, hoja(V)) :-
    hoja(P, V).

%!  valor_final(+Resultado, +Posicion, -Valor:integer) is det.
%
%   Valor es el de una partida terminada, para max: en el árbol, el de la
%   hoja.
valor_final(hoja(V), _, V).
```

```mermaid
flowchart TD
    a["a · max · 5"] --> b["b · min · 5"]
    a --> c["c · min · 2"]
    b --> d["d · max · 5"]
    b --> e["e · max · 9"]
    c --> f["f · max · 2"]
    c --> g["g · max · 8"]
    d --> d1["3"]
    d --> d2["5"]
    e --> e1["6"]
    e --> e2["9"]
    f --> f1["1"]
    f --> f2["2"]
    g --> g1["8"]
    g --> g2["4"]
```

Los valores se calculan de abajo hacia arriba: d vale 5, el máximo de 3 y 5;
e vale 9; b, donde mueve min, vale 5, el mínimo de 5 y 9; c vale 2, y la
raíz vale 5, con la jugada b. La secuencia a-b-d-d2, en la que cada jugador
elige su mejor jugada, es la **variante principal**, y el valor no cambia a
lo largo de ella.

```prolog
?- minimax(arbol, a, 3, Jugada, Valor, Nodos).
Jugada = b,
Valor = 5,
Nodos = 15.

?- minimax(tateti(3), pos([x,o,v, v,x,v, v,v,o], x), 9, J, V, N).
J = 4,
V = 102,
N = 238.

?- minimax(tateti(3), pos([x,o,v, v,x,v, v,v,o], o), 9, J, V, N).
J = 3,
V = 0,
N = 250.
```

En la posición de la sección anterior, minimax encuentra la jugada 4 de x,
que gana con dos casillas vacías: 102. Si mueve o, la jugada 3 evita la
amenaza doble, porque obliga a x a tapar la columna 3-6-9, y la partida
termina empatada. Desde el tablero vacío y sin límite, minimax visita el
árbol entero:

```text
?- inicial(tateti(3), P), time(minimax(tateti(3), P, 9, J, V, N)).
% 71,540,279 inferences, 9.844 CPU in 9.945 seconds (99% CPU, 7267584 Lips)
J = 1,
V = 0,
N = 549946.
```

Con un límite, la búsqueda termina antes y la evaluación estática decide.
`minimax.pl` usa la **evaluación nula**, 0 para toda posición que no
terminó; con ella, a profundidad 2 ninguna jugada inicial se distingue de
otra, y la búsqueda devuelve la primera:

```prolog
?- inicial(tateti(3), P), minimax(tateti(3), P, 2, J, V, N).
P = pos([v, v, v, v, v, v, v, v|...], x),
J = 1,
V = 0,
N = 82.
```

La [sección 42.4](evaluacion.md#424-funciones-de-evaluacion-y-orden-de-las-jugadas)
escribe una evaluación que distingue las posiciones. Sterling y Shapiro
escriben minimax con un solo caso, midiendo el valor siempre desde el punto
de vista del que mueve y cambiándole el signo en cada nivel; el
[ejercicio 4](#ejercicios) lo hace con este programa.

## 42.3 La poda alfa-beta

En el árbol de ejemplo, después de buscar d, está establecido que min
obtiene en b 5 o menos. Al buscar e, la primera hoja vale 6: en e, max va a
obtener 6 o más, y min, que ya tiene 5 por d, no va a elegir e. La segunda
hoja de e no puede cambiar la decisión, y no hace falta buscarla. Lo mismo en
c: después de b, max tiene 5 asegurado en la raíz; en c, f vale 2, así que
min va a obtener 2 o menos en c, y max no va a elegir c. El subárbol de
g tampoco hace falta buscarlo.

La **poda alfa-beta** formaliza ese razonamiento con dos cotas. **Alfa** es
el valor que max ya tiene asegurado por otro camino, y **beta**, el que min
ya tiene asegurado. Una posición se busca con las dos, y solo importa su
valor exacto si queda entre ellas; si no, basta una cota que muestre que
queda afuera. Bratko define así un valor «suficientemente bueno»: igual al
valor minimax si este queda entre alfa y beta, menor o igual que alfa si el
valor lo es, mayor o igual que beta si el valor lo es.

<!-- ejemplo: capitulo-42/alfabeta.pl predicado: alfabeta/6 acotado/9 cotas/11 propia/4 poda/4 estrecha/6 consulta: alfabeta(arbol, a, 3, Jugada, Valor, Nodos). -->
```prolog
%!  alfabeta(+Juego, +Posicion, +Profundidad:integer, -Jugada, -Valor,
%!           -Nodos:integer) is det.
%
%   Valor es el valor minimax de Posicion buscando Profundidad jugadas
%   hacia adelante, y Jugada la primera de las mejores jugadas, o ninguna
%   si la partida terminó o Profundidad es 0: los mismos que da minimax/6.
%   Nodos es la cantidad de posiciones visitadas.
alfabeta(Juego, Posicion, Profundidad, Jugada, Valor, Nodos) :-
    acotado(Juego, Posicion, Profundidad, -inf, inf, Jugada, Valor, 0, Nodos).

%!  acotado(+Juego, +Posicion, +Profundidad:integer, +Alfa, +Beta,
%!          -Jugada, -Valor, +N0:integer, -N:integer) is det.
%
%   Valor es el valor minimax V de Posicion si queda entre Alfa y Beta. Si
%   no, es una cota que basta para descartar la posición: un valor menor o
%   igual que Alfa si V =< Alfa, mayor o igual que Beta si V >= Beta. N es
%   N0 más los nodos visitados.
acotado(Juego, Posicion, Profundidad, Alfa, Beta, Jugada, Valor, N0, N) :-
    N1 is N0 + 1,
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor),
        Jugada = ninguna,
        N = N1
    ;   Profundidad =:= 0
    ->  evaluar(Juego, Posicion, Valor),
        Jugada = ninguna,
        N = N1
    ;   findall(J-P, jugada(Juego, Posicion, J, P), Hijos),
        turno(Juego, Posicion, Lado),
        Profundidad1 is Profundidad - 1,
        cotas(Hijos, Juego, Lado, Profundidad1, Alfa, Beta, ninguna,
              Jugada, Valor, N1, N)
    ).

%!  cotas(+Hijos:list, +Juego, +Lado, +Profundidad:integer, +Alfa, +Beta,
%!        +J0, -Jugada, -Valor, +N0:integer, -N:integer) is det.
%
%   Busca las jugadas de Hijos, pares Jugada-Posicion, con las cotas Alfa y
%   Beta, que se estrechan a medida que aparecen jugadas mejores para Lado.
%   J0 es la mejor jugada hasta el momento. Si una jugada alcanza la cota
%   del rival, las demás no se buscan: es la poda.
cotas([], _, Lado, _, Alfa, Beta, Jugada, Jugada, Valor, N, N) :-
    propia(Lado, Alfa, Beta, Valor).
cotas([J-P|Hijos], Juego, Lado, Profundidad, Alfa, Beta, J0, Jugada, Valor,
      N0, N) :-
    acotado(Juego, P, Profundidad, Alfa, Beta, _, V, N0, N1),
    (   poda(Lado, V, Alfa, Beta)
    ->  Jugada = J,
        Valor = V,
        N = N1
    ;   estrecha(Lado, V, Alfa, Beta, Alfa1, Beta1)
    ->  cotas(Hijos, Juego, Lado, Profundidad, Alfa1, Beta1, J, Jugada,
              Valor, N1, N)
    ;   cotas(Hijos, Juego, Lado, Profundidad, Alfa, Beta, J0, Jugada,
              Valor, N1, N)
    ).

%!  propia(+Lado, +Alfa, +Beta, -Valor) is det.
%
%   Valor es la cota de Lado: Alfa para max, Beta para min. Al terminar las
%   jugadas, es el valor de la mejor, o la cota que ninguna superó.
propia(max, Alfa, _, Alfa).
propia(min, _, Beta, Beta).

%!  poda(+Lado, +V:number, +Alfa, +Beta) is semidet.
%
%   Una jugada de valor V alcanza la cota del rival: con ella, max obtiene
%   al menos Beta, que min ya evita por otro camino; min obtiene a lo sumo
%   Alfa, que max ya evita.
poda(max, V, _, Beta) :-
    V >= Beta.
poda(min, V, Alfa, _) :-
    V =< Alfa.

%!  estrecha(+Lado, +V:number, +Alfa, +Beta, -Alfa1, -Beta1) is semidet.
%
%   V mejora la cota de Lado, que pasa a ser V. Falla si no la mejora.
estrecha(max, V, Alfa, Beta, V, Beta) :-
    V > Alfa.
estrecha(min, V, Alfa, Beta, Alfa, V) :-
    V < Beta.
```

`acotado/9` es `valor/7` con las cotas. `cotas/11` busca las jugadas de a
una: si una alcanza la cota del rival (`poda/4`), deja las demás sin buscar
y devuelve ese valor; si mejora la propia (`estrecha/6`), la cota sube para
max o baja para min, y las jugadas siguientes se buscan con el intervalo
más estrecho. La raíz empieza con alfa en `-inf` y beta en `inf`, y ahí el
valor es exacto.

```mermaid
flowchart TD
    a["a · max · 5"] --> b["b · min · 5"]
    a --> c["c · min · ≤ 2"]
    b --> d["d · max · 5"]
    b --> e["e · max · ≥ 6"]
    c --> f["f · max · 2"]
    c -.-> g["g: no se busca"]
    d --> d1["3"]
    d --> d2["5"]
    e --> e1["6"]
    e -.-> e2["9: no se busca"]
    f --> f1["1"]
    f --> f2["2"]
```

```prolog
?- alfabeta(arbol, a, 3, Jugada, Valor, Nodos).
Jugada = b,
Valor = 5,
Nodos = 11.

?- alfabeta(tateti(3), pos([x,o,v, v,x,v, v,v,o], o), 9, J, V, N).
J = 3,
V = 0,
N = 134.
```

El árbol se busca con 11 nodos en lugar de 15, con el mismo valor y la
misma jugada. Los valores de e y de c no son los de minimax, 9 y 2, sino
cotas, 6 y 2; alcanzan para la decisión. Sobre el tablero vacío, medido en
esta máquina:

```text
?- inicial(tateti(3), P), time(alfabeta(tateti(3), P, 9, J, V, N)).
% 3,046,624 inferences, 0.375 CPU in 0.415 seconds (90% CPU, 8124331 Lips)
J = 1,
V = 0,
N = 20866.
```

La poda visita 20 866 posiciones donde minimax visita 549 946: veintiséis
veces menos, y la búsqueda tarda 0,4 segundos en lugar de 9,8. Las pruebas
de `alfabeta.plt` comprueban sobre una muestra de posiciones que la jugada y
el valor son los de minimax, con límite de profundidad y sin él.

!!! question "Actividad"
    En el árbol de ejemplo, cambiar el valor de la hoja e1 de 6 a 4 y
    predecir el valor de la raíz, la jugada, y cuántos nodos visitan
    `minimax/6` y `alfabeta/6`. Comprobarlo en una copia de `alfabeta.pl`.

!!! example "Patrón 55 — Poda alfa-beta"
    **Problema.** Es necesario elegir una jugada con minimax en un juego
    cuyo árbol crece exponencialmente con la profundidad, y la búsqueda
    completa hasta la profundidad deseada es demasiado lenta.

    **Versión ingenua.** Minimax que busca todas las jugadas de cada
    posición hasta el límite y recién entonces compara sus valores: visita
    posiciones cuyo valor no puede cambiar la jugada elegida.

    **Patrón.** Cada posición se busca con dos cotas: alfa, lo que max ya
    tiene asegurado, y beta, lo que min ya tiene asegurado. Las jugadas de
    una posición se recorren de a una; una jugada que alcanza la cota del
    rival corta la búsqueda de las demás, y una que mejora la cota propia la
    estrecha para las siguientes. El valor devuelto es exacto dentro del
    intervalo y una cota fuera de él; en la raíz, con `-inf` e `inf`, es el
    valor minimax, con la misma jugada.

    **Cuándo no usarlo.** Cuando el árbol es pequeño y se busca entero una
    sola vez: minimax es más simple. Cuando se necesita el valor exacto de
    todas las jugadas y no solo de la mejor, para mostrarlas o para
    ordenarlas: la poda da cotas. Y cuando las posiciones se repiten mucho
    y el juego se busca hasta el final: una tabla de transposición
    ([sección 42.6](transposicion.md#426-tablas-de-transposicion-con-tabulacion)) ahorra
    más, y las cotas dificultan reutilizar lo guardado.

El capítulo continúa en la página
[Funciones de evaluación y orden de las jugadas](evaluacion.md#424-funciones-de-evaluacion-y-orden-de-las-jugadas),
con la evaluación de las posiciones del límite y el orden en que la poda
recorre las jugadas.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir, con `tateti.pl` cargado, la respuesta de cada
   consulta y comprobarlo:
   `fin(tateti(3), pos([o,x,x, v,o,x, v,v,o], x), R).` ·
   `fin(tateti(4), pos([x,x,x,v, o,o,o,v, v,v,v,v, v,v,v,v], x), R).` ·
   `ganada(tateti(3), pos([x,v,v, v,v,v, v,v,v], o)).` ·
   `ganada(tateti(3), pos([x,o,v, v,v,v, v,v,v], x)).`
2. **(1)** Contar con `partidas/3` las partidas que siguen a
   `pos([x,v,v, v,o,v, v,v,v], x)` y a `pos([o,v,v, v,x,v, v,v,v], x)`.
   ¿Por qué dan cantidades distintas, si las dos tienen siete casillas
   vacías?
3. ★ **(2)** Si `valor_final/3` diera 100 y −100, sin las casillas vacías,
   ¿qué jugada elegiría minimax para x en
   `pos([x,o,x, v,x,o, v,o,v], x)`? Escribir un juego `plano(N)` que
   delegue en `tateti(N)` y valga 100 o −100 al terminar, comprobarlo, y
   explicar qué haría un programa así contra una persona.
4. **(2)** Escribir `negamax/6`, con el mismo significado que `minimax/6`,
   con un solo caso para los dos jugadores: el valor de una posición desde
   el punto de vista del que mueve es el máximo de los valores de sus
   jugadas con el signo cambiado (Sterling y Shapiro, «Search Techniques»).
   Comprobar que da los mismos resultados.
5. ★ **(1)** En el árbol de ejemplo, predecir cuántos nodos visita la poda
   si en la raíz se busca c antes que b, y cuáles hojas quedan sin buscar.
   Comprobarlo con un juego `invertido` que delegue en `arbol`.
6. ★ **(2)** Escribir `linea(+N, -Casillas)`, que genere en orden las filas,
   las columnas y las dos diagonales de un tablero de N × N, con su
   encabezado de modos y determinación. Comprobar que para 3 y 4 da las
   mismas líneas que `lineas/2`, y contar las de 5 × 5.
7. **(2)** En el juego de restar hay una pila de fichas; cada jugador saca
   una, dos o tres, y gana quien saca la última. Describirlo como el juego
   `restar` con los cinco predicados, y usar `alfabeta/6` para encontrar
   las pilas de 1 a 12 en las que pierde el que mueve.

## Referencias

- Ivan Bratko, *Prolog Programming for Artificial Intelligence*,
  Addison-Wesley, 1986 — capítulo «Game Playing», secciones «Two-person,
  perfect-information games», «The minimax principle», «The alpha-beta
  algorithm: an efficient implementation of minimax» y «Minimax-based
  programs: refinements and limitations». Sin edición en línea de acceso
  libre. Esta página toma de allí la posición ganada como un árbol Y/O
  ([sección 42.1](#421-posiciones-jugadas-y-fin-de-partida)), el principio
  minimax ([sección 42.2](#422-minimax)) y el valor «suficientemente bueno»
  de la poda alfa-beta ([sección 42.3](#423-la-poda-alfa-beta)).
- Leon Sterling y Ehud Shapiro, *The Art of Prolog: Advanced Programming
  Techniques*, 2.ª edición, MIT Press, 1994 — capítulos «Search
  Techniques» (minimax y alfa-beta con un solo caso para los dos
  jugadores, que el [ejercicio 4](#ejercicios) pide escribir) y
  «Game-Playing Programs» (Mastermind, Nim y Kalah, que se mencionan aquí
  y se desarrollan en el
  [capítulo 79](../capitulo-79-proyecto-kalah-mastermind-nim/index.md)).
  La 1.ª edición (1986) se consigue en
  [préstamo en el Internet Archive](https://archive.org/details/artofprologadvan00ster).
