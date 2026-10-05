:- encoding(utf8).

% Capítulo 78 - Kalah: el tablero, la siembra y el jugador con la poda
% alfa-beta del capítulo 41.
%
% El tablero tiene dos filas de seis hoyos y un kalah por jugador, sur y
% norte. Se representa como tablero(Mios, Kalah, Suyos, KalahRival) desde
% el punto de vista del que mueve, como en Sterling y Shapiro: Mios son
% sus seis hoyos, el 1 el más lejano a su kalah, y Suyos los del rival, en
% el mismo sentido. Al terminar el turno, el tablero se gira.
%
% Sembrar es sacar las piedras de un hoyo propio y dejar una en cada hoyo
% siguiente, en sentido antihorario: los hoyos propios, el kalah propio y
% los hoyos del rival, sin el kalah del rival. Desde el punto de vista del
% que mueve son trece casillas en anillo: Mios, Kalah y Suyos. Si la
% última piedra cae en el kalah propio, el jugador vuelve a sembrar; si
% cae en un hoyo propio vacío y el hoyo de enfrente tiene piedras, las
% captura con la última. Cuando los hoyos de un jugador quedan vacíos,
% cada uno guarda en su kalah las piedras de su lado, y la partida
% termina. Gana quien tiene más de la mitad de las piedras.
%
% Una jugada es la lista de los hoyos sembrados en el turno: [1, 4] es
% sembrar el 1, cuya última piedra cae en el kalah, y después el 4.
%
% solo-local: es un módulo que carga otros.
%
%?- inicial(kalah(6), P), jugada(kalah(6), P, [1, 4], P1).
%?- inicial(kalah(6), P), alfabeta(kalah(6), P, 2, J, V, N).

:- module(kalah,
          [ sembrar/4,
            capturar/3,
            barrer/2,
            terminado/1,
            turno_completo/3,
            girar/2,
            kalahs/4
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(capitulo41, [alfabeta/6, profundizar/6, inicial/2, jugada/4,
                         fin/3]).
:- reexport(partida).

% --- El tablero y la siembra ------------------------------------------------

%!  sembrar(+Hoyo:integer, +Tablero, -Ultimo:integer, -Tablero1) is semidet.
%
%   Tablero1 es Tablero después de sembrar las piedras de Hoyo, uno de los
%   hoyos propios. Ultimo es la casilla del anillo donde cae la última
%   piedra: de 1 a 6 un hoyo propio, 7 el kalah propio, de 8 a 13 un hoyo
%   del rival. Falla si Hoyo está vacío.
sembrar(Hoyo, tablero(Mios, K, Suyos, L), Ultimo,
        tablero(Mios1, K1, Suyos1, L)) :-
    nth1(Hoyo, Mios, Piedras),
    Piedras > 0,
    append(Mios, [K|Suyos], Anillo0),
    Vueltas is Piedras // 13,
    Resto is Piedras mod 13,
    numlist(1, 13, Casillas),
    maplist(recibir(Hoyo, Vueltas, Resto), Casillas, Anillo0, Anillo),
    Ultimo is (Hoyo - 1 + Piedras) mod 13 + 1,
    length(Mios1, 6),
    append(Mios1, [K1|Suyos1], Anillo).

%!  recibir(+Hoyo:integer, +Vueltas:integer, +Resto:integer,
%!          +Casilla:integer, +C0:integer, -C:integer) is det.
%
%   C es lo que queda en Casilla, que tenía C0, después de sembrar desde
%   Hoyo: cada casilla recibe una piedra por cada vuelta completa al
%   anillo, y las Resto casillas siguientes a Hoyo, una más. Hoyo se vacía
%   antes de sembrar.
recibir(Hoyo, Vueltas, Resto, Casilla, C0, C) :-
    D is (Casilla - Hoyo) mod 13,
    (   D =:= 0
    ->  C = Vueltas
    ;   D =< Resto
    ->  C is C0 + Vueltas + 1
    ;   C is C0 + Vueltas
    ).

%!  capturar(+Ultimo:integer, +Tablero, -Tablero1) is det.
%
%   Si la última piedra cayó en un hoyo propio que estaba vacío, y el hoyo
%   de enfrente tiene piedras, las dos cosas van al kalah propio. Si no,
%   Tablero1 es Tablero. El hoyo de enfrente del hoyo I es el 7 - I del
%   rival.
capturar(Ultimo, tablero(Mios, K, Suyos, L), Tablero1) :-
    (   Ultimo =< 6,
        nth1(Ultimo, Mios, 1),
        Enfrente is 7 - Ultimo,
        nth1(Enfrente, Suyos, X),
        X > 0
    ->  poner(Ultimo, Mios, 0, Mios1),
        poner(Enfrente, Suyos, 0, Suyos1),
        K1 is K + 1 + X,
        Tablero1 = tablero(Mios1, K1, Suyos1, L)
    ;   Tablero1 = tablero(Mios, K, Suyos, L)
    ).

%!  poner(+I:integer, +Lista:list, +X, -Lista1:list) is det.
%
%   Lista1 es Lista con X en la posición I.
poner(I, Lista, X, Lista1) :-
    nth1(I, Lista, _, Resto),
    nth1(I, Lista1, X, Resto).

%!  barrer(+Tablero, -Tablero1) is det.
%
%   Si los hoyos de uno de los dos jugadores quedaron vacíos, cada uno
%   guarda en su kalah las piedras de sus hoyos. Si no, Tablero1 es
%   Tablero.
barrer(tablero(Mios, K, Suyos, L), Tablero1) :-
    (   ( vacios(Mios) ; vacios(Suyos) )
    ->  sum_list(Mios, A),
        sum_list(Suyos, B),
        K1 is K + A,
        L1 is L + B,
        Tablero1 = tablero([0, 0, 0, 0, 0, 0], K1, [0, 0, 0, 0, 0, 0], L1)
    ;   Tablero1 = tablero(Mios, K, Suyos, L)
    ).

%!  vacios(+Hoyos:list(integer)) is semidet.
%
%   Ningún hoyo de Hoyos tiene piedras.
vacios(Hoyos) :-
    sum_list(Hoyos, 0).

%!  terminado(+Tablero) is semidet.
%
%   Todos los hoyos de Tablero están vacíos: la partida terminó.
terminado(tablero(Mios, _, Suyos, _)) :-
    vacios(Mios),
    vacios(Suyos).

%!  turno_completo(+Tablero, ?Hoyos:list(integer), -Tablero1) is nondet.
%
%   Tablero1 es Tablero después de sembrar los Hoyos, uno tras otro: cada
%   siembra salvo la última termina en el kalah propio, y la última no,
%   o termina la partida. Sin girar el tablero.
turno_completo(Tablero, [Hoyo|Hoyos], Tablero1) :-
    between(1, 6, Hoyo),
    sembrar(Hoyo, Tablero, Ultimo, T1),
    capturar(Ultimo, T1, T2),
    barrer(T2, T3),
    (   Ultimo =:= 7,
        \+ terminado(T3)
    ->  turno_completo(T3, Hoyos, Tablero1)
    ;   Hoyos = [],
        Tablero1 = T3
    ).

%!  girar(?Tablero, ?Tablero1) is det.
%
%   Tablero1 es Tablero visto desde el rival.
girar(tablero(Mios, K, Suyos, L), tablero(Suyos, L, Mios, K)).

%!  kalahs(+Tablero, +Jugador, -Sur:integer, -Norte:integer) is det.
%
%   Sur y Norte son las piedras de los kalahs de sur y de norte, si
%   Tablero está visto desde Jugador.
kalahs(tablero(_, K, _, L), Jugador, Sur, Norte) :-
    (   Jugador == sur
    ->  Sur = K,
        Norte = L
    ;   Sur = L,
        Norte = K
    ).

% --- Kalah como juego del capítulo 41 ---------------------------------------

% La posición del capítulo 41 es k(Tablero, Jugador): el tablero visto
% desde Jugador, sur o norte, que es el que mueve. sur es max. El juego es
% kalah(N), con N piedras por hoyo al empezar.

%!  capitulo41:inicial(+Juego, -Posicion) is det.
%
%   En kalah(N), N piedras en cada hoyo, los kalahs vacíos, y mueve sur.
capitulo41:inicial(kalah(N), k(tablero(Hoyos, 0, Hoyos, 0), sur)) :-
    length(Hoyos, 6),
    maplist(=(N), Hoyos).

%!  capitulo41:jugada(+Juego, +Posicion, ?Hoyos, -Siguiente) is nondet.
%
%   En Kalah, una jugada es un turno completo; después se gira el tablero
%   y mueve el rival.
capitulo41:jugada(kalah(_), k(T0, J), Hoyos, k(T, Otro)) :-
    turno_completo(T0, Hoyos, T1),
    girar(T1, T),
    rival(J, Otro).

%!  capitulo41:turno(+Juego, +Posicion, -Lado) is det.
%
%   En Kalah, sur es max y norte es min.
capitulo41:turno(kalah(_), k(_, J), Lado) :-
    lado(J, Lado).

%!  capitulo41:fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   En kalah(N), gana quien tiene más de 6 N piedras en su kalah; con
%   todos los hoyos vacíos y los kalahs iguales, empate. Falla si la
%   partida sigue.
capitulo41:fin(kalah(N), k(T, J), Resultado) :-
    kalahs(T, J, Sur, Norte),
    Mitad is 6 * N,
    (   Sur > Mitad
    ->  Resultado = gana(sur)
    ;   Norte > Mitad
    ->  Resultado = gana(norte)
    ;   terminado(T)
    ->  Resultado = empate
    ).

%!  capitulo41:valor_final(+Resultado, +Posicion, -Valor) is det.
%
%   En Kalah, la diferencia de los kalahs desde sur, más 100 si gana sur
%   o menos 100 si gana norte.
capitulo41:valor_final(gana(J), k(T, Mueve), Valor) :-
    kalahs(T, Mueve, Sur, Norte),
    lado(J, Lado),
    premio(Lado, P),
    Valor is P + Sur - Norte.

%!  capitulo41:evaluar(+Juego, +Posicion, -Valor) is det.
%
%   En Kalah, la diferencia de los kalahs desde sur.
capitulo41:evaluar(kalah(_), k(T, J), Valor) :-
    kalahs(T, J, Sur, Norte),
    Valor is Sur - Norte.

%!  capitulo41:completa(+Juego, +Posicion, +D, +Valor) is semidet.
%
%   En Kalah, profundizar no cambia una búsqueda que encontró una
%   victoria.
capitulo41:completa(kalah(_), _, _, Valor) :-
    abs(Valor) >= 100.

% rival(J, K): K es el rival de J.
rival(sur, norte).
rival(norte, sur).

% lado(J, L): el jugador J es L, max o min.
lado(sur, max).
lado(norte, min).

% premio(L, P): P se suma al valor de una victoria de L.
premio(max, 100).
premio(min, -100).

% --- Kalah en la terminal ---------------------------------------------------

%!  partida:pantalla(+Juego, +Posicion, -Lineas:list(string)) is det.
%
%   Lineas dibujan el tablero visto desde sur: arriba los hoyos de norte,
%   del 6 al 1; a la izquierda el kalah de norte y a la derecha el de sur;
%   abajo los hoyos de sur, del 1 al 6, y sus números.
partida:pantalla(kalah(_), k(T, J), [Arriba, Kalahs, Abajo, Numeros]) :-
    (   J == sur
    ->  tablero(Sur, KS, Norte, KN) = T
    ;   tablero(Norte, KN, Sur, KS) = T
    ),
    reverse(Norte, NorteInvertido),
    fila(NorteInvertido, Arriba),
    format(string(Kalahs), "~t~d~3|~t~d~24|", [KN, KS]),
    fila(Sur, Abajo),
    format(string(Numeros), "~t(~d)~6|~t(~d)~9|~t(~d)~12|~t(~d)~15|\c
                             ~t(~d)~18|~t(~d)~21|", [1, 2, 3, 4, 5, 6]).

%!  fila(+Hoyos:list(integer), -Linea:string) is det.
%
%   Linea muestra los seis Hoyos, cada uno en tres columnas, después de
%   tres columnas para el kalah.
fila(Hoyos, Linea) :-
    format(string(Linea), "~t~d~6|~t~d~9|~t~d~12|~t~d~15|~t~d~18|~t~d~21|",
           Hoyos).

%!  partida:leer_jugada(+Juego, +Posicion, +Linea:string, -Jugada)
%!      is semidet.
%
%   Linea son los números de los hoyos sembrados, separados por espacios:
%   "1 4" es [1, 4]. Falla si alguno no es un número.
partida:leer_jugada(kalah(_), _, Linea, Hoyos) :-
    split_string(Linea, " ", " ", Partes),
    maplist(number_string, Hoyos, Partes).
