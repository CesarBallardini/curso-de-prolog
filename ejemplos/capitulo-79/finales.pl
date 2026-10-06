:- encoding(utf8).

% Capítulo 79 - Versión 6: la tabla de finales de rey y torre contra rey.
%
% El análisis retrógrado calcula, para cada posición, en cuántas jugadas de
% las blancas se da mate con el mejor juego de los dos bandos. Empieza por
% las posiciones de mate y retrocede una jugada por vez: una posición con
% las blancas a mover gana en K si tiene una jugada a una posición de las
% negras que pierde en menos de K; una de las negras pierde en K si todas
% sus jugadas llevan a posiciones de las blancas que ganan en K o menos, y
% ninguna captura la torre. Las ocho simetrías del tablero reducen las
% posiciones a las que tienen el rey negro en el triángulo a1-d1-d4.
%
% Los resultados se guardan como hechos dinámicos, con la posición
% codificada como un entero: 27 352 posiciones con las blancas a mover y
% las de las negras, en un par de minutos.
%
% solo-local: modifica la base de datos con assertz/1 y tarda más que el
% límite de SWISH.
%
%?- normal(pos(blancas, 7-7, 8-1, 5-8), N).

:- module(finales,
          [ normal/2,
            posiciones/2,
            calcular/0,
            mate_en/2,
            resumen/1,
            mejor_jugada/2,
            optima/2,
            nodo/3,
            codigo/2,
            decodificar/3,
            sucesora/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).
:- use_module(reglas).

:- dynamic gana/2, pierde/2, nodo/3.

% gana(C, K): la posición de código C, con las blancas a mover, da mate en K
% jugadas de las blancas.
% pierde(C, K): la posición de código C, con las negras a mover, recibe el
% mate después de K jugadas más de las blancas; K = 0 es el mate.
% nodo(Lado, C, Cs): C es el código de una posición normal con Lado a mover,
% y Cs los de sus sucesoras (captura, si una jugada captura la torre).

%!  simetria(?S:integer, +Casilla, -Imagen) is det.
%
%   Imagen es Casilla transformada por la simetría S del tablero, de 1 a 8:
%   la identidad, las dos reflexiones por las medianas, la rotación de
%   media vuelta, y las mismas cuatro compuestas con la reflexión por la
%   diagonal a1-h8.
simetria(1, X-Y, X-Y).
simetria(2, X-Y, X1-Y) :- X1 is 9 - X.
simetria(3, X-Y, X-Y1) :- Y1 is 9 - Y.
simetria(4, X-Y, X1-Y1) :- X1 is 9 - X, Y1 is 9 - Y.
simetria(5, X-Y, Y-X).
simetria(6, X-Y, Y1-X) :- Y1 is 9 - Y.
simetria(7, X-Y, Y-X1) :- X1 is 9 - X.
simetria(8, X-Y, Y1-X1) :- X1 is 9 - X, Y1 is 9 - Y.

%!  en_triangulo(+Casilla) is semidet.
%
%   Casilla está en el triángulo a1-d1-d4: columna de 1 a 4 y fila no
%   mayor que la columna.
en_triangulo(X-Y) :-
    X =< 4,
    Y =< X.

%!  normal(+Posicion, -Normal) is det.
%
%   Normal es Posicion transformada por la primera simetría que lleva el
%   rey negro al triángulo a1-d1-d4.
normal(pos(L, RB, T, RN), pos(L, RB1, T1, RN1)) :-
    between(1, 8, S),
    simetria(S, RN, RN1),
    en_triangulo(RN1),
    !,
    simetria(S, RB, RB1),
    (   T == capturada
    ->  T1 = capturada
    ;   simetria(S, T, T1)
    ).

%!  codigo(+Posicion, -C:integer) is det.
%
%   C codifica las tres casillas de Posicion, que tiene la torre.
codigo(pos(_, RB, T, RN), C) :-
    indice(RB, I),
    indice(T, J),
    indice(RN, K),
    C is (I * 64 + J) * 64 + K.

%!  indice(+Casilla, -I:integer) is det.
%
%   I es el número de Casilla, de 0 a 63.
indice(X-Y, I) :-
    I is (X - 1) * 8 + Y - 1.

%!  posiciones(+Lado, -Ps:list) is det.
%
%   Ps son las posiciones legales con Lado a mover, la torre en el tablero
%   y el rey negro en el triángulo a1-d1-d4.
posiciones(Lado, Ps) :-
    findall(pos(Lado, RB, T, RN),
            ( member(RN, [1-1, 2-1, 3-1, 4-1, 2-2, 3-2, 4-2, 3-3, 4-3, 4-4]),
              casilla(RB),
              casilla(T),
              legal(pos(Lado, RB, T, RN)) ),
            Ps).

%!  casilla(-Casilla) is multi.
%
%   Casilla es una de las 64 casillas del tablero.
casilla(X-Y) :-
    between(1, 8, X),
    between(1, 8, Y).

%!  calcular is det.
%
%   Calcula la tabla de finales: borra la anterior, registra cada posición
%   con los códigos de sus sucesoras, marca los mates y retrocede una
%   jugada por vez hasta que ninguna posición cambia.
calcular :-
    retractall(gana(_, _)),
    retractall(pierde(_, _)),
    retractall(nodo(_, _, _)),
    forall(( member(Lado, [blancas, negras]),
             posiciones(Lado, Ps),
             member(P, Ps) ),
           registrar(P)),
    forall(( nodo(negras, C, []),
             decodificar(negras, C, P),
             jaque(P) ),
           assertz(pierde(C, 0))),
    retroceder(1).

%!  registrar(+Posicion) is det.
%
%   Agrega el hecho nodo(Lado, C, Sucesoras): C es el código de Posicion y
%   Sucesoras, los códigos de las posiciones normales a las que llevan sus
%   jugadas; captura, si una jugada captura la torre.
registrar(P) :-
    P = pos(Lado, _, _, _),
    codigo(P, C),
    findall(C1,
            ( jugada(P, _, S),
              sucesora(S, C1) ),
            Cs0),
    sort(Cs0, Cs),
    assertz(nodo(Lado, C, Cs)).

%!  sucesora(+Siguiente, -C) is det.
%
%   C es el código de la forma normal de Siguiente, o captura si la torre
%   fue capturada.
sucesora(pos(_, _, capturada, _), captura) :-
    !.
sucesora(S, C) :-
    normal(S, S1),
    codigo(S1, C).

%!  retroceder(+K:integer) is det.
%
%   Marca las posiciones de las blancas que ganan en K y las de las negras
%   que pierden en K, y sigue con K + 1 mientras alguna cambie.
retroceder(K) :-
    findall(C,
            ( nodo(blancas, C, Cs),
              \+ gana(C, _),
              once(( member(C1, Cs), pierde(C1, _) )) ),
            Ganan),
    forall(member(C, Ganan), assertz(gana(C, K))),
    findall(C,
            ( nodo(negras, C, Cs),
              Cs \== [],
              \+ pierde(C, _),
              \+ memberchk(captura, Cs),
              forall(member(C1, Cs), gana(C1, _)) ),
            Pierden),
    forall(member(C, Pierden), assertz(pierde(C, K))),
    (   Ganan == [],
        Pierden == []
    ->  true
    ;   K1 is K + 1,
        retroceder(K1)
    ).

%!  decodificar(+Lado, +C:integer, -Posicion) is det.
%
%   Posicion es la de código C con Lado a mover.
decodificar(Lado, C, pos(Lado, RB, T, RN)) :-
    K is C mod 64,
    J is (C // 64) mod 64,
    I is C // 4096,
    casilla_de(I, RB),
    casilla_de(J, T),
    casilla_de(K, RN).

%!  casilla_de(+I:integer, -Casilla) is det.
%
%   Casilla es la de número I.
casilla_de(I, X-Y) :-
    X is I // 8 + 1,
    Y is I mod 8 + 1.

%!  mate_en(+Posicion, -K:integer) is semidet.
%
%   Con el mejor juego de los dos bandos, Posicion termina en mate después
%   de K jugadas de las blancas. Falla si las negras pueden evitarlo. La
%   tabla tiene que estar calculada.
mate_en(Posicion, K) :-
    normal(Posicion, P1),
    P1 = pos(Lado, _, T, _),
    T \== capturada,
    codigo(P1, C),
    (   Lado == blancas
    ->  gana(C, K)
    ;   pierde(C, K)
    ).

%!  resumen(-R) is det.
%
%   R resume la tabla: r(Blancas, Negras, Tablas, MayorK), con la cantidad
%   de posiciones de cada bando, las de las negras en que no reciben el
%   mate y la mayor cantidad de jugadas hasta el mate.
resumen(r(NB, NN, Tablas, Mayor)) :-
    aggregate_all(count, nodo(blancas, _, _), NB),
    aggregate_all(count, nodo(negras, _, _), NN),
    aggregate_all(count, ( nodo(negras, C, _), \+ pierde(C, _) ), Tablas),
    aggregate_all(max(K), gana(_, K), Mayor).

%!  mejor_jugada(+Posicion, -Jugada) is semidet.
%
%   Jugada es una jugada de las blancas que da mate en la menor cantidad de
%   jugadas, según la tabla.
mejor_jugada(Posicion, Jugada) :-
    mate_en(Posicion, K),
    K0 is K - 1,
    once(( jugada(Posicion, Jugada, S),
           mate_en(S, K0) )).

%!  optima(+Posicion, -Jugada) is semidet.
%
%   Jugada es la respuesta de las negras que más demora el mate según la
%   tabla; una defensa para partida/5. Captura la torre si puede.
optima(Posicion, Jugada) :-
    findall(K-J,
            ( jugada(Posicion, J, S),
              valor_negras(S, K) ),
            KJs),
    KJs \== [],
    keysort(KJs, Ordenadas),
    last(Ordenadas, _-Jugada).

%!  valor_negras(+Siguiente, -K) is det.
%
%   K mide la respuesta que lleva a Siguiente: 1000 si captura la torre;
%   si no, las jugadas que faltan para el mate.
valor_negras(pos(_, _, capturada, _), 1000) :-
    !.
valor_negras(S, K) :-
    (   mate_en(S, K)
    ->  true
    ;   K = 999
    ).
