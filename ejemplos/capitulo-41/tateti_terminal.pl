:- encoding(utf8).

% Capítulo 41 - El ta-te-ti completo, en la terminal.
%
% La interfaz del Buscaminas del capítulo 36 sobre el ta-te-ti: el módulo
% pantalla dibuja y lee las teclas, y este archivo solo agrega el modelo de
% pantalla y la respuesta a cada tecla. Un estado es
% e(Juego, Rival, Posicion, Cursor, Pedido): el juego, cómo elige sus
% jugadas la computadora (profundidad(D) para alfabeta/6 con profundidad D,
% o tiempo(S) para profundizar/6 con S segundos), la posición, la casilla
% del cursor, y jugar o salir. La persona juega con x y mueve primero.
% pantalla/2 y paso/3 son puros, salvo el reloj de profundizar/6; bucle/3
% es el único que lee y escribe.
%
% solo-local: SWISH no admite módulos propios ni tiene una terminal.
%
%?- inicial(tateti(3), P), pantalla(e(tateti(3),profundidad(9),P,5,jugar), L).

:- use_module('../capitulo-36/texto/pantalla').
:- ensure_loaded(profundizacion).

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

%!  mover(+Eje, +Delta:integer, +Estado0, -Estado) is det.
%
%   Estado tiene el cursor de Estado0 una fila o una columna más allá,
%   según Eje y Delta, sin salir del tablero.
mover(Eje, Delta, e(tateti(N), R, P, C0, Pd), e(tateti(N), R, P, C, Pd)) :-
    F0 is (C0 - 1) // N,
    K0 is (C0 - 1) mod N,
    (   Eje == fila
    ->  F is max(0, min(N - 1, F0 + Delta)),
        K = K0
    ;   F = F0,
        K is max(0, min(N - 1, K0 + Delta))
    ),
    C is F * N + K + 1.

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

%!  fila_con_cursor(+N:integer, +Tablero:list, +Cursor:integer,
%!                  +F:integer, -Linea:string) is det.
%
%   Linea muestra la fila F de Tablero, con la casilla Cursor entre
%   corchetes y un punto en las vacías.
fila_con_cursor(N, Tablero, Cursor, F, Linea) :-
    Primera is (F - 1) * N + 1,
    Ultima is F * N,
    numlist(Primera, Ultima, Casillas),
    maplist(celda(Tablero, Cursor), Casillas, Celdas),
    atomics_to_string(Celdas, Linea).

%!  celda(+Tablero:list, +Cursor:integer, +Casilla:integer, -Celda:string)
%!      is det.
%
%   Celda es la marca de Casilla en tres columnas: entre corchetes si es la
%   del cursor, entre blancos si no.
celda(Tablero, Cursor, Casilla, Celda) :-
    nth1(Casilla, Tablero, Marca),
    simbolo(Marca, S),
    (   Casilla =:= Cursor
    ->  format(string(Celda), "[~w]", [S])
    ;   format(string(Celda), " ~w ", [S])
    ).

% simbolo(M, S): la marca M se dibuja con S.
simbolo(x, "X").
simbolo(o, "O").
simbolo(v, "·").

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
