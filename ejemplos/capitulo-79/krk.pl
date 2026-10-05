:- encoding(utf8).

% Capítulo 79 - Versión 4: la tabla de consejos de rey y torre contra rey.
%
% La tabla tiene dos reglas y seis consejos, los de la figura 15.7 de
% Bratko, «Prolog Programming for Artificial Intelligence» (1986), con
% nombres en castellano. La biblioteca de predicados que la tabla usa está
% debajo: las metas elementales, meta/3, y las restricciones elementales de
% las jugadas, jugadas/4. Las blancas son nuestro bando.
%
% solo-local: carga reglas.pl y consejos.pl; exporta también el intérprete,
% para consultar la tabla sin cargar otro archivo.
%
%?- estrategia(krk, pos(blancas, 3-3, 2-2, 1-1), C, A).

:- module(krk,
          [ regla/2,
            consejo/5,
            mueve/2,
            meta/3,
            jugadas/4,
            espacio/2,
            casilla_critica/2,
            torre_perdida/1,
            torre_expuesta/1
          ]).

:- use_module(reglas).
:- reexport(consejos).

% --- La tabla ------------------------------------------------------------

% regla(Nombre, si Condicion entonces Consejos): en las posiciones en que se
% cumple Condicion, se prueban los Consejos en orden. Se usa la primera
% regla cuya condición se cumple.
regla(borde, si rey_negro_en_borde y reyes_cerca
             entonces [mate_en_2, encierro, acercamiento, mantener_espacio,
                       dividir_en_2, dividir_en_3]).
regla(resto, si verdadero
             entonces [encierro, acercamiento, mantener_espacio,
                       dividir_en_2, dividir_en_3]).

% consejo(Nombre, Mejor, Mantener, Nuestras, Suyas): la meta mejor, la meta
% a mantener y las restricciones de las jugadas de los dos bandos. La
% profundidad se cuenta en jugadas de un bando (plies) desde la raíz.
consejo(mate_en_2,
        mate,
        no torre_perdida y rey_negro_en_borde,
        profundidad = 0 y legal luego profundidad = 2 y jaque_con_torre,
        profundidad = 1 y legal).
consejo(encierro,
        espacio_menor y no torre_expuesta y torre_divide y no ahogado,
        no torre_perdida,
        profundidad = 0 y torre,
        ninguna).
consejo(acercamiento,
        acerca_casilla_critica y no torre_expuesta y
            (torre_divide o patron_l) y
            (espacio_mayor_que_2 o no rey_blanco_en_borde),
        no torre_perdida,
        profundidad = 0 y rey_diagonal_primero,
        ninguna).
consejo(mantener_espacio,
        mueven_negras y no torre_expuesta y torre_divide y
            rey_no_se_aleja y
            (espacio_mayor_que_2 o no rey_blanco_en_borde),
        no torre_perdida,
        profundidad = 0 y rey_diagonal_primero,
        ninguna).
consejo(dividir_en_2,
        mueven_negras y torre_divide y no torre_expuesta,
        no torre_perdida,
        profundidad < 3 y legal,
        profundidad < 2 y legal).
consejo(dividir_en_3,
        mueven_negras y torre_divide y no torre_expuesta,
        no torre_perdida,
        profundidad < 5 y legal,
        profundidad < 4 y legal).

% --- Los bandos ----------------------------------------------------------

% mueve(Posicion, Bando): en Posicion mueve Bando; las blancas son nosotros.
mueve(pos(blancas, _, _, _), nosotros).
mueve(pos(negras, _, _, _), ellos).

% --- Las metas elementales -----------------------------------------------

%!  meta(+Nombre, +Posicion, +Raiz) is semidet.
%
%   La meta elemental Nombre se cumple en Posicion; las que comparan, como
%   espacio_menor, comparan Posicion con Raiz, la posición en que empezó la
%   búsqueda. Falla también si Nombre no es una meta de la tabla.
meta(verdadero, _, _).
meta(mate, P, _) :-
    mate(P).
meta(ahogado, P, _) :-
    ahogado(P).
meta(mueven_negras, pos(negras, _, _, _), _).
meta(torre_perdida, P, _) :-
    torre_perdida(P).
meta(torre_expuesta, P, _) :-
    torre_expuesta(P).
meta(torre_divide, pos(_, RX-RY, TX-TY, NX-NY), _) :-
    (   ordenados(RX, TX, NX)
    ->  true
    ;   ordenados(RY, TY, NY)
    ).
meta(espacio_menor, P, R) :-
    espacio(P, E),
    espacio(R, E0),
    E < E0.
meta(espacio_mayor_que_2, P, _) :-
    espacio(P, E),
    E > 2.
meta(acerca_casilla_critica, P, R) :-
    distancia_critica(P, D),
    distancia_critica(R, D0),
    D < D0.
meta(patron_l, pos(_, RB, T, RN), _) :-
    T \== capturada,
    manhattan(RB, RN, 2),
    manhattan(T, RN, 3).
meta(rey_no_se_aleja, pos(_, RB, T, _), pos(_, RB0, T0, _)) :-
    T \== capturada,
    distancia(RB, T, D),
    distancia(RB0, T0, D0),
    D =< D0.
meta(rey_blanco_en_borde, pos(_, RB, _, _), _) :-
    en_borde(RB).
meta(rey_negro_en_borde, pos(_, _, _, RN), _) :-
    en_borde(RN).
meta(reyes_cerca, pos(_, RB, _, RN), _) :-
    distancia(RB, RN, D),
    D < 4.

%!  en_borde(+Casilla) is semidet.
%
%   Casilla está en la primera o la última columna o fila.
en_borde(X-Y) :-
    (   memberchk(X, [1, 8])
    ->  true
    ;   memberchk(Y, [1, 8])
    ).

%!  torre_perdida(+Posicion) is semidet.
%
%   La torre fue capturada, o mueven las negras y su rey puede capturarla:
%   la toca y el rey blanco no la defiende.
torre_perdida(pos(_, _, capturada, _)) :-
    !.
torre_perdida(pos(negras, RB, T, RN)) :-
    distancia(RN, T, 1),
    distancia(RB, T, D),
    D > 1.

%!  torre_expuesta(+Posicion) is semidet.
%
%   El rey negro puede llegar a la torre antes de que el rey blanco la
%   defienda: el rey blanco está más lejos de ella, con una jugada de
%   ventaja para el bando que mueve.
torre_expuesta(pos(Lado, RB, T, RN)) :-
    T \== capturada,
    distancia(RB, T, D1),
    distancia(RN, T, D2),
    (   Lado == blancas
    ->  D1 > D2 + 1
    ;   D1 > D2
    ).

%!  espacio(+Posicion, -Espacio:integer) is det.
%
%   Espacio es la cantidad de casillas del rectángulo al que la torre
%   confina al rey negro: el cuadrante, entre la columna y la fila de la
%   torre y los bordes, en que está el rey. Si la torre está en la columna
%   o la fila del rey negro, o fue capturada, no lo confina: 64.
espacio(pos(_, _, T, RN), Espacio) :-
    T = TX-TY,
    RN = NX-NY,
    NX =\= TX,
    NY =\= TY,
    !,
    lado(NX, TX, LX),
    lado(NY, TY, LY),
    Espacio is LX * LY.
espacio(_, 64).

%!  lado(+N:integer, +T:integer, -L:integer) is det.
%
%   L es la cantidad de columnas (o filas) entre la de la torre, T, y el
%   borde del lado en que está N.
lado(N, T, L) :-
    (   N < T
    ->  L is T - 1
    ;   L is 8 - T
    ).

%!  casilla_critica(+Posicion, -Casilla) is det.
%
%   Casilla es la casilla crítica: la vecina diagonal de la torre en
%   dirección al rey negro. Ocuparla con el rey blanco defiende la torre y
%   prepara el encierro siguiente.
casilla_critica(pos(_, _, TX-TY, NX-NY), CX-CY) :-
    (   NX < TX
    ->  CX is TX - 1
    ;   CX is TX + 1
    ),
    (   NY < TY
    ->  CY is TY - 1
    ;   CY is TY + 1
    ).

%!  distancia_critica(+Posicion, -D:integer) is det.
%
%   D es la distancia de Manhattan del rey blanco a la casilla crítica.
distancia_critica(P, D) :-
    P = pos(_, RB, _, _),
    casilla_critica(P, C),
    manhattan(RB, C, D).

% --- Las restricciones elementales de las jugadas ------------------------

%!  jugadas(+Nombre, +Posicion, ?Jugada, -Siguiente) is nondet.
%
%   Jugada es una jugada legal de Posicion que cumple la restricción
%   elemental Nombre: legal, cualquiera; rey_diagonal_primero, una del rey
%   blanco, primero las diagonales; torre, una de la torre; jaque_con_torre,
%   una de la torre que da jaque. La restricción ninguna no tiene cláusulas:
%   no permite ninguna jugada.
jugadas(legal, P, J, S) :-
    jugada(P, J, S).
jugadas(rey_diagonal_primero, P, J, S) :-
    P = pos(blancas, _, _, _),
    J = rey(_, _),
    jugada(P, J, S).
jugadas(torre, P, J, S) :-
    P = pos(blancas, _, _, _),
    J = torre(_, _),
    jugada(P, J, S).
jugadas(jaque_con_torre, P, J, S) :-
    jugadas(torre, P, J, S),
    jaque(S).
