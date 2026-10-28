# El ta-te-ti completo, en la terminal

Esta página continúa la página
[Tablas de transposición con tabulación](transposicion.md#426-tablas-de-transposicion-con-tabulacion)
del [capítulo 42](index.md), con la sección
[42.7](#427-el-ta-te-ti-completo-en-la-terminal): una partida de ta-te-ti
contra la computadora, a
pantalla completa en la terminal. El ejemplo está en `tateti_terminal.pl`,
en `ejemplos/capitulo-42/`, con sus pruebas. Carga el módulo `pantalla` del
[capítulo 37](../capitulo-37-interfaces-de-usuario/index.md) y
`profundizacion.pl`, y no corre en SWISH, que no tiene terminal.

## 42.7 El ta-te-ti completo, en la terminal

La [sección 37.3](../capitulo-37-interfaces-de-usuario/index.md#373-el-buscaminas-y-el-menu-de-inscripciones-a-pantalla-completa)
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

<!-- ejemplo: capitulo-42/tateti_terminal.pl predicado: jugar/2 bucle/3 terminado/1 -->
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

<!-- ejemplo: capitulo-42/tateti_terminal.pl predicado: paso/3 marcar/3 responder/4 -->
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

<!-- ejemplo: capitulo-42/tateti_terminal.pl predicado: pantalla/2 mensaje/4 resultado/2 -->
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
?- consult('ejemplos/capitulo-42/tateti_terminal.pl'), jugar(3, profundidad(9)).
```

Con `jugar(4, tiempo(2))` se juega en el tablero de 4 × 4, y la
computadora busca cada jugada durante dos segundos.

### Cómo se prueba

`pantalla/2` y `paso/3` son puros, y se prueban como cualquier predicado.
La partida entera se prueba con `bucle/3`, que recibe de dónde leer: en las
pruebas, `get_code/2` sobre un stream abierto con `open_string/2`, con las
teclas escritas en una cadena, flechas incluidas como secuencias de
escape, y la salida capturada con `with_output_to/2`, como en la
[sección 37.7](../capitulo-37-interfaces-de-usuario/web.md#377-como-se-prueba-una-interfaz):

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

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `jugada/4` aclara que no comprueba el fin de la partida, y `acotado/9` qué significa su valor fuera del intervalo |
    | C3 | la búsqueda no conoce el juego: recibe el juego como término y solo llama a `inicial/2`, `jugada/4`, `turno/3`, `fin/3`, `valor_final/3` y `evaluar/3`; la misma poda juega el árbol de ejemplo, el ta-te-ti de 3 × 3 y el de 4 × 4 |
    | C4 | las búsquedas son `det` y sus pruebas no declaran `nondet`: `turno/3` pasa por `lado/2`, `clave/4` y `responder/4` llevan primero el argumento que decide la cláusula |
    | C6 | la terminal está separada del núcleo: `pantalla/2` y `paso/3` son puros, salvo el reloj de la profundización, y solo `bucle/3` lee y escribe |
    | C7 | 96 pruebas en nueve archivos, y 31 más sobre las soluciones; la poda se compara con minimax sobre una muestra de posiciones, y lo que depende de la máquina, como la profundidad alcanzada en un tiempo, se prueba con cotas y no con un valor |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

13. **(2)** Escribir `jugar_con_o(N, Rival)`: la partida en la que la
    computadora juega con x y mueve primero, y la persona juega con o.
    ¿Qué predicados de `tateti_terminal.pl` sirven sin cambios, y cuáles
    hay que cambiar?
14. **(3)** Escribir `autojuego(+Juego, +RivalX, +RivalO, -Jugadas,
    -Resultado)`: una partida entera entre dos rivales de la computadora,
    como los de la terminal. Jugar el tablero de 3 × 3 con `profundidad(9)`
    contra `profundidad(9)` y contra `profundidad(1)`, y el de 4 × 4 con
    `profundidad(4)` contra `profundidad(1)`; predecir los resultados antes
    de ejecutarlos, y explicarlos.

## Resumen

| | |
|---|---|
| **árbol de la partida** | las posiciones como nodos y las jugadas como ramas; las hojas son las posiciones finales |
| **posición ganada** | un árbol Y/O: basta una jugada propia, y tienen que ser buenas todas las del rival |
| **minimax** | el valor de una posición es el máximo de los de sus jugadas si mueve max, el mínimo si mueve min |
| **evaluación estática** | la estimación del valor de una posición del límite, sin buscar jugadas hacia adelante |
| **variante principal** | la secuencia de jugadas en la que cada jugador elige su mejor jugada |
| **poda alfa-beta** | minimax con dos cotas: lo que max y lo que min ya tienen asegurado; lo que queda fuera no se busca |
| **orden de las jugadas** | con la mejor primero, la poda corta más; con la peor, no corta |
| **efecto horizonte** | una pérdida postergada hasta más allá del límite no se ve |
| `inicial/2`, `jugada/4`, `turno/3`, `fin/3`, `valor_final/3` | la descripción de un juego, con el juego como primer argumento |
| `ganada/2`, `perdida/2`, `partidas/3` | la posición ganada y el tamaño del árbol |
| `filas/3` | el tablero como una lista de cadenas, una por fila |
| `minimax/6`, `valor/7`, `mejor/10` | minimax con profundidad y contador de nodos |
| `alfabeta/6`, `acotado/9`, `cotas/11`, `poda/4`, `estrecha/6` | la poda alfa-beta |
| `evaluar/3`, `abierta/3` | la evaluación por líneas abiertas |
| `alfabeta/7`, `ordenar/5`, `por_evaluacion/4` | la poda con las jugadas ordenadas |
| `nth1/4` | `nth1(I, L, X, R)`: X en la posición I de L, contando desde 1, y R el resto; en sentido inverso, inserta |
| `call_with_time_limit/2` | `call_with_time_limit(S, G)`: G como `once/1`, interrumpida con la excepción `time_limit_exceeded` si no termina en S segundos ([Profundización progresiva](profundizacion.md#425-profundizacion-progresiva-con-limite-de-tiempo)) |
| `profundizar/6`, `primero/6` | la profundización progresiva con límite de tiempo ([Profundización progresiva](profundizacion.md#425-profundizacion-progresiva-con-limite-de-tiempo)) |
| `en_paralelo/5`, `en_paralelo/6` | las jugadas buscadas en paralelo ([Profundización progresiva](profundizacion.md#jugadas-en-paralelo)) |
| `valor/3`, `jugada_optima/4`, `valor_limitado/4` | minimax tabulado ([Tablas de transposición](transposicion.md#426-tablas-de-transposicion-con-tabulacion)) |
| `min_list/2` | el menor elemento de una lista de números ([Tablas de transposición](transposicion.md#426-tablas-de-transposicion-con-tabulacion)) |
| `jugar/2`, `paso/3`, `pantalla/2`, `bucle/3` | el ta-te-ti en la terminal ([El ta-te-ti en la terminal](#427-el-ta-te-ti-completo-en-la-terminal)) |
| **[Patrón 55](../patrones.md#55-poda-alfa-beta)** | poda alfa-beta |
| `expand_file_name/2` | los archivos que cumplen un patrón con comodines, como `*.pl` |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Kalah con la poda alfa-beta; Mastermind y Nim | [capítulo 79](../capitulo-79-proyecto-kalah-mastermind-nim/index.md) |
| Un lenguaje de consejos para el ajedrez: metas y restricciones sobre las jugadas en lugar de una evaluación numérica | [capítulo 80](../capitulo-80-proyecto-lenguaje-consejos-ajedrez/index.md) |
| La búsqueda mejor primero en grafos Y/O, de los que la posición ganada es un caso | [capítulo 72](../capitulo-72-proyecto-grafos-o/index.md) |

## Referencias

Los programas del capítulo son propios del curso: ninguno se copia de las
fuentes, que aportan las ideas y los algoritmos.
