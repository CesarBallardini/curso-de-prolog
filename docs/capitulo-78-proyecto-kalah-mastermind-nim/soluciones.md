# Soluciones del capítulo 78 — Proyecto: Kalah, Mastermind y Nim

El código de esta página está en `ejemplos/capitulo-78/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `nim.pl`,
`candidatos.pl` (que carga `mastermind.pl`) y `kalah.pl`, sin
modificarlos; los juegos nuevos de los ejercicios 3 y 10 agregan sus
cláusulas al módulo `capitulo41`, como lo hacen `nim.pl` y `kalah.pl`. Es
`% solo-local`, porque carga otros archivos.

## 1

La suma de Nim de `[3, 4, 5]` es 011 xor 100 xor 101 = 010, es decir, 2:
el que mueve gana. Una pila P permite la jugada segura si P xor 2 es
menor que P, y eso pasa solo con la pila de 3, que tiene un 1 en la
columna del 2: se sacan 2 fichas y quedan `[1, 4, 5]`. Esa posición, como
`[2, 2, 7, 7]`, tiene suma 0: el que mueve pierde. En `[2, 2, 7, 7]` se ve
sin calcular: las pilas forman pares iguales, y el que juega segundo copia
cada jugada en la pila gemela.

<!-- contexto: capitulo-78/soluciones.pl -->
```prolog
?- maplist(suma_nim, [[3, 4, 5], [1, 4, 5], [2, 2, 7, 7]], S).
S = [2, 0, 0].

?- findall(J, jugada_segura([3, 4, 5], J), Js).
Js = [sacar(1, 2)].

?- ganadora_tabulada([3, 4, 5]).
true.

?- ganadora_tabulada([2, 2, 7, 7]).
false.
```

## 2

La búsqueda es la de `ganadora_tabulada/1` con un cambio en el caso sin
fichas: si no quedan, el rival sacó la última y perdió, así que el que
mueve ganó. La regla de Bouton, para cualquier cantidad de pilas, tiene
dos casos: si ninguna pila tiene más de una ficha, la posición es segura
con una cantidad impar de pilas de una ficha; si no, con suma de Nim 0.

<!-- ejemplo: capitulo-78/soluciones.pl predicado: ganadora_miseria/1 ganadora_miseria_forma/1 segura_miseria/1 -->
```prolog
%!  ganadora_miseria(+Pilas:list(integer)) is semidet.
%
%   En el Nim en que pierde quien saca la última ficha, el que mueve en
%   Pilas gana. Búsqueda tabulada sobre la forma de la posición.
ganadora_miseria(Pilas) :-
    forma(Pilas, Forma),
    ganadora_miseria_forma(Forma).

%!  ganadora_miseria_forma(+Forma:list(integer)) is semidet.
%
%   ganadora_miseria/1 sobre una forma. Sin fichas, el que mueve ganó: el
%   rival sacó la última.
ganadora_miseria_forma(Forma) :-
    (   Forma == []
    ->  true
    ;   once(( sacar(Forma, _, Pilas1),
               forma(Pilas1, Forma1),
               \+ ganadora_miseria_forma(Forma1) ))
    ).

%!  segura_miseria(+Pilas:list(integer)) is semidet.
%
%   Pilas es segura en el Nim de la miseria: si ninguna pila tiene más de
%   una ficha, hay una cantidad impar de pilas de una ficha; si no, la
%   suma de Nim es 0.
segura_miseria(Pilas) :-
    max_list([0|Pilas], Mayor),
    (   Mayor =< 1
    ->  sum_list(Pilas, Unos),
        Unos mod 2 =:= 1
    ;   segura(Pilas)
    ).
```

```prolog
?- segura_miseria([1, 1, 1]).
true.

?- segura_miseria([1, 1]).
false.

?- segura_miseria([2, 2]).
true.
```

Con tres pilas de una ficha, el que mueve deja dos, el rival una, y el
primero tiene que sacar la última: pierde. Con dos, saca una y deja al
rival la última. Las pruebas comparan la búsqueda con la regla en las 512
posiciones de tres pilas de hasta 7 fichas. La diferencia con el Nim
normal aparece solo al final: mientras alguna pila tenga dos fichas o
más, se juega igual, y el jugador que va ganando, cuando la última pila
grande se reduce, la deja en 0 o en 1 según cuántas pilas de una ficha
haya.

## 3

`nim_suma(Pilas)` delega todo en `nim(Pilas)` salvo la evaluación. Un
jugador que mueve en una posición segura pierde, así que una posición es
buena para max si es segura y mueve min, o si es insegura y mueve max.

<!-- ejemplo: capitulo-78/soluciones.pl fragmento: % nim_suma(Pilas) es nim(Pilas) con una evaluación .. Valor = -50 -->
```prolog
% nim_suma(Pilas) es nim(Pilas) con una evaluación que no es nula: 50 si
% la posición es buena para max según la suma de Nim, -50 si no.

%!  capitulo41:inicial(+Juego, -Posicion) is det.
%
%   nim_suma(Pilas) empieza como nim(Pilas).
capitulo41:inicial(nim_suma(Pilas), P) :-
    capitulo41:inicial(nim(Pilas), P).

%!  capitulo41:jugada(+Juego, +Posicion, ?Jugada, -Siguiente) is nondet.
%
%   Las jugadas de nim_suma(Pilas) son las de nim(Pilas).
capitulo41:jugada(nim_suma(Pilas), P, J, P1) :-
    capitulo41:jugada(nim(Pilas), P, J, P1).

%!  capitulo41:turno(+Juego, +Posicion, -Lado) is det.
%
%   Como en nim(Pilas).
capitulo41:turno(nim_suma(Pilas), P, Lado) :-
    capitulo41:turno(nim(Pilas), P, Lado).

%!  capitulo41:fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   Como en nim(Pilas).
capitulo41:fin(nim_suma(Pilas), P, R) :-
    capitulo41:fin(nim(Pilas), P, R).

%!  capitulo41:evaluar(+Juego, +Posicion, -Valor) is det.
%
%   La evaluación de nim_suma/1, con valor_suma/3.
capitulo41:evaluar(nim_suma(_), pilas(Pilas, J), Valor) :-
    valor_suma(Pilas, J, Valor).

%!  valor_suma(+Pilas:list(integer), +Jugador, -Valor:integer) is det.
%
%   Valor es 50 si la posición es buena para max: segura con min por
%   mover, o insegura con max por mover; -50 en los otros casos.
valor_suma(Pilas, J, Valor) :-
    suma_nim(Pilas, S),
    (   ( S =:= 0, J == dos
        ; S =\= 0, J == uno
        )
    ->  Valor = 50
    ;   Valor = -50
```

```prolog
?- alfabeta(nim_suma([1, 3, 5, 7, 9]), pilas([1, 3, 5, 7, 9], uno), 1, J, V, N).
J = sacar(5, 9),
V = 50,
N = 26.
```

Con una sola jugada hacia adelante, la búsqueda examina las 25 jugadas de
la posición, más la raíz, y elige la primera que deja suma 0: sacar las 9
fichas de la quinta pila, porque 1 xor 3 xor 5 xor 7 = 0. Con una
evaluación perfecta, la profundidad 1 basta, y la búsqueda es la suma de
Nim con otra forma.

## 4

```text
?- abolish_all_tables, time(ganadora_tabulada([1, 3, 5, 7, 9])), posiciones(N).
% 303,920 inferences, 0.063 CPU in 0.060 seconds (104% CPU, 4862720 Lips)
N = 728.

?- abolish_all_tables, time(ganadora_tabulada([1, 3, 5, 7, 9, 11])), posiciones(N).
% 1,254,413 inferences, 0.219 CPU in 0.211 seconds (104% CPU, 5734459 Lips)
N = 2374.
```

Una forma es una lista ordenada de tamaños, cada uno a lo sumo el de la
pila de partida: su cantidad crece como la de las combinaciones de los
tamaños, que con pilas de hasta 11 fichas son unos pocos miles. El árbol
crece como el producto de las jugadas posibles a lo largo de la partida,
y las jugadas son tantas como fichas: con `[1, 3, 5, 7]`, 16 jugadas en la
primera posición y 25 millones de nodos en la búsqueda.

## 5

<!-- ejemplo: capitulo-78/soluciones.pl predicado: particion/3 particion/2 -->
```prolog
%!  particion(+Intento:list, +Codigos:list, -Clases:list) is det.
%
%   Clases son los términos Toros-Vacas-K, en orden: K códigos de Codigos
%   darían la respuesta Toros-Vacas a Intento.
particion(Intento, Codigos, Clases) :-
    findall(T-V, ( member(C, Codigos),
                   respuesta(C, Intento, T, V) ),
            Respuestas),
    msort(Respuestas, Ordenadas),
    clumped(Ordenadas, Clases).

%!  particion(+Intento:list, -Clases:list) is det.
%
%   particion/3 sobre los 5040 códigos.
particion(Intento, Clases) :-
    candidatos(Codigos),
    particion(Intento, Codigos, Clases).
```

```prolog
?- particion([0, 1, 2, 3], C).
C = [0-0-360, 0-1-1440, 0-2-1260, 0-3-264, 0-4-9, 1-0-480, 1-1-720, ... - ... - 216, ... - ...|...].
```

Las clases son 14. La mayor es la de cero toros y una vaca, con 1440
códigos: uno solo de los cuatro dígitos del intento está en el código, en
otra posición, y los otros tres dígitos del código salen de los seis que
el intento no usa. Es la respuesta más probable, 1440 de 5040, y después
de ella el segundo intento tiene que elegir entre 1440 códigos. Una
respuesta de cuatro toros deja uno solo, y cero toros y cuatro vacas,
nueve: las permutaciones de 0123 que no dejan ningún dígito en su lugar.

## 6

`mejor_intento/2` calcula, para cada código posible, el tamaño de su
mayor clase sobre los códigos posibles, y se queda con el menor; ante un
empate, `keysort/2` conserva el orden de los códigos y el elegido es el
primero.

<!-- ejemplo: capitulo-78/soluciones.pl predicado: adivinar_minimax/2 minimax_entre/4 mejor_intento/2 peor_clase/3 -->
```prolog
%!  adivinar_minimax(+Secreto:list, -Intentos:list) is det.
%
%   Como adivinar_candidatos/2, pero cada intento después del primero es
%   el código posible cuya mayor clase es la menor; ante un empate, el
%   primero.
adivinar_minimax(Secreto, Intentos) :-
    candidatos(Codigos),
    minimax_entre(Codigos, [0, 1, 2, 3], Secreto, Intentos).

%!  minimax_entre(+Codigos:list, +Intento:list, +Secreto:list,
%!                -Intentos:list) is det.
%
%   Intentos empiezan con Intento, uno de Codigos, los códigos posibles.
minimax_entre(Codigos, Intento, Secreto, [Intento|Intentos]) :-
    respuesta(Secreto, Intento, T, V),
    (   T =:= 4
    ->  Intentos = []
    ;   filtrar(Codigos, Intento, T, V, Codigos1),
        mejor_intento(Codigos1, Siguiente),
        minimax_entre(Codigos1, Siguiente, Secreto, Intentos)
    ).

%!  mejor_intento(+Codigos:list, -Intento:list) is det.
%
%   Intento es el código de Codigos cuya mayor clase sobre Codigos es la
%   menor; ante un empate, el primero.
mejor_intento(Codigos, Intento) :-
    map_list_to_pairs(peor_clase(Codigos), Codigos, Pares),
    keysort(Pares, [_-Intento|_]).

%!  peor_clase(+Codigos:list, +Intento:list, -Mayor:integer) is det.
%
%   Mayor es la cantidad de códigos de la mayor clase de Intento.
peor_clase(Codigos, Intento, Mayor) :-
    particion(Intento, Codigos, Clases),
    pairs_values(Clases, Ks),
    max_list(Ks, Mayor).
```

Elegir cuesta: con 1260 códigos posibles, cada uno se compara con todos,
y el segundo intento examina más de un millón y medio de pares. Una
partida tarda unos trece segundos, así que la medición usa once secretos,
uno de cada 500 códigos:

Medido con `findall(C, codigo(C), Cs), findall(C, (nth0(K, Cs, C), K mod 500 =:= 0), M), time(medir(adivinar_minimax, M, Q, Me))`, que pasa del límite de 15 segundos de las
transcripciones del curso:

```text
% 547,298,626 inferences, 95.547 CPU in 98.692 seconds (97% CPU, 5728064 Lips)
Q = [1-1, 4-1, 5-3, 6-5, 7-1],
Me = 5.181818181818182.
```

Sobre los mismos once secretos, `adivinar/2` necesita 5,36 intentos de
media, con el mismo máximo de 7 (`Q = [1-1, 5-3, 6-6, 7-1]`), en medio
segundo. Elegir el intento ahorra unos dos décimos de intento por partida
y cuesta doscientas veces más. Con 83 códigos posibles, por ejemplo, el
primero, 1547, deja en el peor caso 27, y el elegido, 1574, deja 25.

## 7

<!-- ejemplo: capitulo-78/soluciones.pl predicado: codigo_colores/1 color/1 respuesta_colores/4 veces/3 adivinar_colores/2 colores_entre/3 explica_colores/4 medir_colores/2 -->
```prolog
%!  codigo_colores(-Codigo:list(integer)) is multi.
%
%   Codigo son cuatro colores, del 1 al 6, que pueden repetirse: 1296
%   códigos, en orden.
codigo_colores([A, B, C, D]) :-
    maplist(color, [A, B, C, D]).

% color(C): C es uno de los seis colores.
color(C) :-
    between(1, 6, C).

%!  respuesta_colores(+Secreto:list, +Intento:list, -Toros:integer,
%!                    -Vacas:integer) is det.
%
%   Toros son las posiciones iguales; Vacas, los colores comunes, cada uno
%   tantas veces como el menor de sus apariciones, menos los toros.
respuesta_colores(Secreto, Intento, Toros, Vacas) :-
    aggregate_all(count, ( nth1(I, Secreto, X), nth1(I, Intento, X) ), Toros),
    aggregate_all(sum(M), ( color(C),
                            veces(C, Secreto, N1),
                            veces(C, Intento, N2),
                            M is min(N1, N2) ),
                  Comunes),
    Vacas is Comunes - Toros.

%!  veces(+X, +Lista:list, -N:integer) is det.
%
%   N es la cantidad de veces que X aparece en Lista.
veces(X, Lista, N) :-
    include(==(X), Lista, Xs),
    length(Xs, N).

%!  adivinar_colores(+Secreto:list, -Intentos:list) is det.
%
%   Intentos son los de la regla de la jugada consistente sobre los 1296
%   códigos de colores, hasta el que acierta.
adivinar_colores(Secreto, Intentos) :-
    findall(C, codigo_colores(C), Codigos),
    colores_entre(Codigos, Secreto, Intentos).

%!  colores_entre(+Codigos:list, +Secreto:list, -Intentos:list) is det.
%
%   Como adivinar_entre/3 de candidatos.pl, con respuesta_colores/4.
colores_entre([Intento|Codigos0], Secreto, [Intento|Intentos]) :-
    respuesta_colores(Secreto, Intento, T, V),
    (   T =:= 4
    ->  Intentos = []
    ;   include(explica_colores(Intento, T, V), Codigos0, Codigos),
        colores_entre(Codigos, Secreto, Intentos)
    ).

%!  explica_colores(+Intento:list, +T:integer, +V:integer, +Codigo:list)
%!      is semidet.
%
%   Si Codigo fuera el secreto, Intento recibiría T toros y V vacas.
explica_colores(Intento, T, V, Codigo) :-
    respuesta_colores(Codigo, Intento, T, V).

%!  medir_colores(-Cuantos:list(pair), -Media:float) is det.
%
%   medir/4 de mastermind.pl sobre los 1296 códigos de colores.
medir_colores(Cuantos, Media) :-
    findall(C, codigo_colores(C), Secretos),
    medir(adivinar_colores, Secretos, Cuantos, Media).
```

```prolog
?- respuesta_colores([1, 1, 2, 3], [1, 2, 1, 6], T, V).
T = 1,
V = 2.
```

Medido con `time(medir_colores(Q, M))`, que pasa del límite de 15 segundos de las
transcripciones del curso:

```text
% 306,303,880 inferences, 49.297 CPU in 50.879 seconds (97% CPU, 6213454 Lips)
Q = [1-1, 2-4, 3-25, 4-108, 5-305, 6-602, 7-196, 8-49, 9-6],
M = 5.764660493827161.
```

Con colores repetidos, la cuenta de vacas no puede usar «dígitos comunes
menos toros» sobre listas sin repetición: para cada color se toma el
menor de las veces que aparece en el secreto y en el intento. En
`[1, 1, 2, 3]` contra `[1, 2, 1, 6]` el 1 aparece dos veces en cada uno,
una vez en el mismo lugar, y el 2 una vez: un toro y dos vacas. La regla
de la jugada consistente adivina los 1296 códigos con 5,76 intentos de
media y 9 como máximo; con menos códigos que la variante de dígitos, la
media es mayor, y el primer intento, 1111, solo informa sobre un color.

## 8

<!-- ejemplo: capitulo-78/soluciones.pl predicado: primera_contradiccion/2 contradiccion/4 -->
```prolog
%!  primera_contradiccion(+Respuestas:list, -K:integer) is semidet.
%
%   K es la posición en Respuestas de la primera respuesta después de la
%   cual ningún código las explica a todas. Falla si no hay contradicción.
primera_contradiccion(Respuestas, K) :-
    candidatos(Codigos),
    contradiccion(Respuestas, 1, Codigos, K).

%!  contradiccion(+Respuestas:list, +I:integer, +Codigos:list, -K:integer)
%!      is semidet.
%
%   Como primera_contradiccion/2, con I la posición de la primera de
%   Respuestas y Codigos los que explican las anteriores.
contradiccion([r(Intento, T, V)|Respuestas], I, Codigos0, K) :-
    filtrar(Codigos0, Intento, T, V, Codigos),
    (   Codigos == []
    ->  K = I
    ;   I1 is I + 1,
        contradiccion(Respuestas, I1, Codigos, K)
    ).
```

```prolog
?- primera_contradiccion([r([0, 1, 2, 3], 0, 0), r([4, 5, 6, 7], 0, 0)], K).
K = 2.
```

Después de la primera respuesta quedan los 360 códigos hechos con los
dígitos 4 a 9; la segunda descarta también 4, 5, 6 y 7, y con dos dígitos
no se forma un código de cuatro dígitos distintos.

## 9

Las 13 piedras dan una vuelta entera: cada casilla del anillo recibe una,
incluido el hoyo de partida, que había quedado vacío, y la última cae en
él. El hoyo de enfrente, el 4 del rival, tiene una piedra (la de la
vuelta), así que se captura: 1 + 1 piedras van al kalah, que ya tenía 1.

```prolog
?- sembrar(3, tablero([0, 0, 13, 0, 0, 0], 0, [0, 0, 0, 0, 2, 0], 0), U, T0), capturar(U, T0, T).
U = 3,
T0 = tablero([1, 1, 1, 1, 1, 1], 1, [1, 1, 1, 1, 3, 1], 0),
T = tablero([1, 1, 0, 1, 1, 1], 3, [1, 1, 1, 0, 3, 1], 0).
```

El programa del libro reparte las piedras igual, pero solo examina la
captura cuando las piedras no pasan del kalah (`Stones =< 7-N`), y 13 es
mayor que 4: deja la piedra en el hoyo 3, sin captura, con el kalah en 1.

## 10

<!-- ejemplo: capitulo-78/soluciones.pl fragmento: % kalah_piedras(N) es kalah(N) con otra evaluación .. sum_list(Ps, Total). -->
```prolog
% kalah_piedras(N) es kalah(N) con otra evaluación: la diferencia de
% kalahs más la mitad de la diferencia de las piedras en los hoyos.

%!  capitulo41:inicial(+Juego, -Posicion) is det.
%
%   kalah_piedras(N) empieza como kalah(N).
capitulo41:inicial(kalah_piedras(N), P) :-
    capitulo41:inicial(kalah(N), P).

%!  capitulo41:jugada(+Juego, +Posicion, ?Jugada, -Siguiente) is nondet.
%
%   Las jugadas de kalah_piedras(N) son las de kalah(N).
capitulo41:jugada(kalah_piedras(N), P, J, P1) :-
    capitulo41:jugada(kalah(N), P, J, P1).

%!  capitulo41:turno(+Juego, +Posicion, -Lado) is det.
%
%   Como en kalah(N).
capitulo41:turno(kalah_piedras(N), P, Lado) :-
    capitulo41:turno(kalah(N), P, Lado).

%!  capitulo41:fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   Como en kalah(N).
capitulo41:fin(kalah_piedras(N), P, R) :-
    capitulo41:fin(kalah(N), P, R).

%!  capitulo41:evaluar(+Juego, +Posicion, -Valor) is det.
%
%   La evaluación de kalah_piedras/1, con piedras/3.
capitulo41:evaluar(kalah_piedras(_), k(T, J), Valor) :-
    piedras(T, J, Valor).

%!  piedras(+Tablero, +Jugador, -Valor:number) is det.
%
%   Valor es, desde sur, la diferencia de los kalahs más la mitad de la
%   diferencia de las piedras de los hoyos, con Tablero visto desde
%   Jugador.
piedras(tablero(Mios, K, Suyos, L), J, Valor) :-
    sum_list(Mios, A),
    sum_list(Suyos, B),
    V is K - L + (A - B) / 2,
    (   J == sur
    ->  Valor = V
    ;   Valor is -V
    ).

%!  torneo(+Juegos:list, +Profundidades:list, -Resultados:list) is det.
%
%   Resultados son los términos r(Sur, Norte, Resultado) de las partidas
%   de kalah(6) con Sur y Norte, pares Juego-Profundidad con distinto
%   juego, como estrategias.
torneo(Juegos, Profundidades, Resultados) :-
    findall(r(GS-DS, GN-DN, R),
            ( member(GS, Juegos), member(GN, Juegos), GS \== GN,
              member(DS, Profundidades), member(DN, Profundidades),
              partida(kalah(6), profundidad_en(GS, DS),
                      profundidad_en(GN, DN), _, R) ),
            Resultados).

%!  profundidad_en(+Juego, +D:integer, +Juego0, +Posicion, -Jugada) is det.
%
%   La estrategia que busca D jugadas hacia adelante con la evaluación de
%   Juego, aunque la partida sea de Juego0: los dos juegos tienen las
%   mismas posiciones y jugadas.
profundidad_en(Juego, D, _, Posicion, Jugada) :-
    alfabeta(Juego, Posicion, D, Jugada, _, _).

%!  puntos(+Resultados:list, -Puntos:list(pair)) is det.
%
%   Puntos son los pares Juego-P: una victoria vale 1 y un empate 0,5.
puntos(Resultados, Puntos) :-
    findall(G-P, ( member(r(GS-_, GN-_, R), Resultados),
                   puntaje(R, GS, GN, G, P) ),
            Todos),
    keysort(Todos, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    maplist(sumar_grupo, Grupos, Puntos).

%!  puntaje(+Resultado, +GS, +GN, -G, -P:number) is nondet.
%
%   El juego G obtiene P puntos en una partida de GS como sur y GN como
%   norte.
puntaje(gana(sur), GS, _, GS, 1).
puntaje(gana(norte), _, GN, GN, 1).
puntaje(empate, GS, GN, G, 0.5) :-
    member(G, [GS, GN]).

%!  sumar_grupo(+Grupo, -Par) is det.
%
%   Par es G-Total, con Total la suma de los puntos del Grupo G-Ps.
sumar_grupo(G-Ps, G-Total) :-
    sum_list(Ps, Total).
```

`profundidad_en/5` es una estrategia que busca con la evaluación de un
juego aunque la partida sea de otro: los dos juegos tienen las mismas
posiciones y jugadas. Las partidas, con `torneo/3`:

Medido con `time(torneo([kalah(6), kalah_piedras(6)], [2, 3, 4], R)), puntos(R, P)`, que pasa del límite de 15 segundos de las
transcripciones del curso:

```text
% 148,060,804 inferences, 25.016 CPU in 26.137 seconds (96% CPU, 5918733 Lips)
P = [kalah(6)-13.5, kalah_piedras(6)-4.5].
```

De las 18 partidas, la evaluación del libro gana 13 y empata una. Sumar
las piedras de los hoyos empeora el juego: una piedra en un hoyo propio
no es del jugador, porque al sembrar pasa al lado del rival y porque el
rival la puede capturar, y la evaluación premia acumular piedras justo
donde están expuestas. Una evaluación mejor tendría que distinguir las
piedras que se pueden perder de las que no, y medirse igual que esta.

## 11

<!-- ejemplo: capitulo-78/soluciones.pl predicado: jugada_nim_texto/2 -->
```prolog
%!  jugada_nim_texto(+Jugada, -Texto:string) is det.
%
%   Texto describe la jugada sacar(K, M) de la computadora.
jugada_nim_texto(sacar(K, M), Texto) :-
    (   M =:= 1
    ->  format(string(Texto), "La computadora saca 1 ficha de la pila ~d.",
               [K])
    ;   format(string(Texto),
               "La computadora saca ~d fichas de la pila ~d.", [M, K])
    ).
```

```prolog
?- jugada_nim_texto(sacar(2, 3), T).
T = "La computadora saca 3 fichas de la pila 2.".
```

`partida/5` no escribe nada, y `pantalla/3` y `leer_jugada/4` ya son de
cada juego: `nim_texto(Pilas)` los define delegando en `nim(Pilas)`, como
los juegos de los ejercicios 3 y 10. El único predicado de `partida.pl`
que hay que cambiar es `bucle/5`, que escribe la jugada de la computadora
con un texto fijo, `La computadora juega ~W.` La solución que no toca el
resto es un tercer predicado `multifile`, `texto_jugada/3`, que `bucle/5`
consulte antes de escribir y que tenga una cláusula por omisión con el
texto actual; los juegos que no lo definen siguen igual.
