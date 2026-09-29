# El ta-te-ti completo, en la terminal

Esta página contiene la sección
[41.7](index.md#417-el-ta-te-ti-completo-en-la-terminal) del
[capítulo 41](index.md): una partida de ta-te-ti contra la computadora, a
pantalla completa en la terminal. El ejemplo está en `tateti_terminal.pl`,
en `ejemplos/capitulo-41/`, con sus pruebas. Carga el módulo `pantalla` del
[capítulo 36](../capitulo-36-interfaces-de-usuario/index.md) y
`profundizacion.pl`, y no corre en SWISH, que no tiene terminal.

## El ta-te-ti completo, en la terminal

La [sección 36.3](../capitulo-36-interfaces-de-usuario/index.md#363-el-buscaminas-y-el-menu-de-inscripciones-a-pantalla-completa)
puso el Buscaminas a pantalla completa con el
[Patrón 51](../patrones.md#51-modelo-de-pantalla): un predicado puro arma
las líneas de la pantalla a partir del estado, otro predicado puro da el
estado que sigue a cada tecla, y un solo predicado lee y escribe. El
ta-te-ti tiene la misma forma. Un estado es
`e(Juego, Rival, Posicion, Cursor, Pedido)`: el juego, cómo elige la
computadora sus jugadas, la posición, la casilla del cursor, y `jugar` o
`salir`. `Rival` es `profundidad(D)`, la poda con profundidad D, o
`tiempo(S)`, la profundización progresiva con S segundos. La persona juega
con x y mueve primero.

<!-- ejemplo: capitulo-41/tateti_terminal.pl predicado: jugar/2 bucle/3 terminado/1 -->
```prolog
%!  jugar(+N:integer, +Rival) is det.
%
%   Juega en la terminal una partida de ta-te-ti de N por N contra la
%   computadora, que elige sus jugadas según Rival.
jugar(N, Rival) :-
    inicial(tateti(N), Posicion),
    con_pantalla(bucle(get_single_char,
                       e(tateti(N), Rival, Posicion, 1, jugar), _)).

%!  bucle(:Siguiente, +Estado0, -Estado) is det.
%
%   Dibuja Estado0 y, si la partida sigue, lee una tecla de Siguiente, la
%   aplica y sigue con el estado que resulta. Estado es el último.
bucle(Siguiente, Estado0, Estado) :-
    pantalla(Estado0, Lineas),
    dibujar(Lineas),
    (   terminado(Estado0)
    ->  Estado = Estado0
    ;   leer_tecla(Siguiente, Tecla),
        paso(Tecla, Estado0, Estado1),
        bucle(Siguiente, Estado1, Estado)
    ).

%!  terminado(+Estado) is semidet.
%
%   En Estado la partida terminó, o la persona pidió salir.
terminado(e(_, _, _, _, salir)).
terminado(e(Juego, _, Posicion, _, jugar)) :-
    fin(Juego, Posicion, _).
```

`bucle/3` es el del Buscaminas: dibuja, y si la partida sigue lee una
tecla, la aplica y vuelve a empezar. `con_pantalla/1`, `dibujar/1` y
`leer_tecla/2` son del módulo `pantalla`; `get_single_char/1` lee cada
tecla sin esperar enter. Toda la lógica está en `paso/3`:

<!-- ejemplo: capitulo-41/tateti_terminal.pl predicado: paso/3 marcar/3 responder/4 -->
```prolog
%!  paso(+Tecla, +Estado0, -Estado) is det.
%
%   Estado es Estado0 después de Tecla: las flechas mueven el cursor, el
%   espacio y enter marcan la casilla del cursor, una cifra marca esa
%   casilla, y q o el fin de la entrada piden salir. Después de cada marca
%   válida responde la computadora. Las demás teclas no cambian nada.
paso(arriba, E0, E) :-
    !,
    mover(fila, -1, E0, E).
paso(abajo, E0, E) :-
    !,
    mover(fila, 1, E0, E).
paso(izquierda, E0, E) :-
    !,
    mover(columna, -1, E0, E).
paso(derecha, E0, E) :-
    !,
    mover(columna, 1, E0, E).
paso(espacio, E0, E) :-
    !,
    E0 = e(_, _, _, Cursor, _),
    marcar(Cursor, E0, E).
paso(enter, E0, E) :-
    !,
    E0 = e(_, _, _, Cursor, _),
    marcar(Cursor, E0, E).
paso(letra(q), e(J, R, P, C, _), e(J, R, P, C, salir)) :-
    !.
paso(fin, e(J, R, P, C, _), e(J, R, P, C, salir)) :-
    !.
paso(letra(L), E0, E) :-
    atom_number(L, Casilla),
    integer(Casilla),
    !,
    marcar(Casilla, E0, E).
paso(_, E, E).

%!  marcar(+Casilla:integer, +Estado0, -Estado) is det.
%
%   Si Casilla está vacía, la persona la marca, y si la partida sigue, la
%   computadora responde; el cursor queda en Casilla. Si no, Estado es
%   Estado0.
marcar(Casilla, E0, E) :-
    E0 = e(Juego, Rival, P0, _, jugar),
    jugada(Juego, P0, Casilla, P1),
    !,
    (   fin(Juego, P1, _)
    ->  P = P1
    ;   responder(Rival, Juego, P1, P)
    ),
    E = e(Juego, Rival, P, Casilla, jugar).
marcar(_, E, E).

%!  responder(+Rival, +Juego, +Posicion0, -Posicion) is det.
%
%   Posicion es Posicion0 después de la jugada que elige la computadora.
responder(profundidad(D), Juego, P0, P) :-
    alfabeta(Juego, P0, D, Jugada, _, _),
    jugada(Juego, P0, Jugada, P).
responder(tiempo(S), Juego, P0, P) :-
    profundizar(Juego, P0, S, Jugada, _, _),
    jugada(Juego, P0, Jugada, P).
```

Una marca en una casilla ocupada no cambia nada, porque `jugada/4` falla y
queda la segunda cláusula de `marcar/3`. Después de una marca válida, si la
partida no terminó, responde la computadora, con la poda o con la
profundización según `Rival`. `responder/4` lleva `Rival` como primer
argumento: con el juego primero, las dos cláusulas empiezan igual y la
llamada dejaba un punto de elección, que las pruebas señalaron.

La pantalla muestra el tablero con el cursor entre corchetes, y el estado
de la partida con un mensaje a la persona:

<!-- ejemplo: capitulo-41/tateti_terminal.pl predicado: pantalla/2 mensaje/4 resultado/2 -->
```prolog
%!  pantalla(+Estado, -Lineas:list(string)) is det.
%
%   Lineas son las de la pantalla de Estado: el tablero en una caja, con
%   el cursor entre corchetes, el estado de la partida en otra, y una línea
%   de ayuda.
pantalla(e(tateti(N), _, pos(Tablero, _), Cursor, Pedido), Lineas) :-
    numlist(1, N, Filas),
    maplist(fila_con_cursor(N, Tablero, Cursor), Filas, Dibujo),
    caja("Ta-te-ti", Dibujo, Caja),
    mensaje(tateti(N), pos(Tablero, _), Pedido, Mensaje),
    caja("Estado", [Mensaje], Estado),
    Ayuda = "Flechas: mover  Espacio o cifra: marcar  q: salir",
    append([Caja, Estado, [Ayuda]], Lineas).

%!  mensaje(+Juego, +Posicion, +Pedido, -Mensaje:string) is det.
%
%   Mensaje es el que se muestra a la persona según cómo sigue la partida.
mensaje(_, _, salir, "Partida abandonada.") :-
    !.
mensaje(Juego, Posicion, jugar, Mensaje) :-
    (   fin(Juego, Posicion, Resultado)
    ->  resultado(Resultado, Mensaje)
    ;   Mensaje = "Tu turno: juegas con X."
    ).

% resultado(R, M): M es el mensaje que anuncia el resultado R.
resultado(gana(x), "Ganaste.").
resultado(gana(o), "Gana la computadora.").
resultado(empate, "Empate.").
```

Al empezar, y después de jugar 1, 2 y 4 —una partida mal jugada: la
computadora responde en el centro, tapa la fila de arriba y completa la
diagonal 3-5-7—:

```text
┌─ Ta-te-ti ┐              ┌─ Ta-te-ti ┐
│  ·  ·  ·  │              │  X  X  O  │
│  · [·] ·  │              │ [X] O  ·  │
│  ·  ·  ·  │              │  O  ·  ·  │
└───────────┘              └───────────┘
┌─ Estado ────────────────┐ ┌─ Estado ─────────────┐
│ Tu turno: juegas con X. │ │ Gana la computadora. │
└─────────────────────────┘ └──────────────────────┘
```

Para jugar, en una terminal:

```text
?- consult('ejemplos/capitulo-41/tateti_terminal.pl'), jugar(3, profundidad(9)).
```

Con `jugar(4, tiempo(2))` se juega en el tablero de 4 × 4, y la
computadora busca cada jugada durante dos segundos.

### Cómo se prueba

`pantalla/2` y `paso/3` son puros, y se prueban como cualquier predicado.
La partida entera se prueba con `bucle/3`, que recibe de dónde leer: en las
pruebas, `get_code/2` sobre un stream abierto con `open_string/2`, con las
teclas escritas en una cadena, flechas incluidas como secuencias de
escape, y la salida capturada con `with_output_to/2`, como en la
[sección 36.7](../capitulo-36-interfaces-de-usuario/index.md#367-como-se-prueba-una-interfaz):

```prolog
test(con_flechas, true(R == gana(o))) :-
    nuevo(E0),
    con_teclas("\e[A\e[D \e[C \e[B\e[D ", E0, E, Salida),
    E = e(J, _, P, _, _),
    fin(J, P, R),
    atomic_list_concat(Pantallas, '\e[2J', Salida),
    last(Pantallas, Ultima),
    once(sub_atom(Ultima, _, _, _, 'Gana la computadora.')).
```

Las teclas llevan el cursor del centro a la casilla 1, la marcan, lo pasan
a la 2, la marcan, y lo bajan a la 4: la misma partida de arriba. La última
pantalla dibujada, separada de las anteriores por la secuencia que borra la
pantalla, anuncia el resultado. Lo que las pruebas no cubren es el dibujo
en una terminal real, que se comprueba jugando.
