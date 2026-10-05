:- encoding(utf8).

% Capítulo 79 - Versión 7: verificar una tabla de consejos.
%
% La idea es la de Bramer (1979): en lugar de jugar partidas de ejemplo, se
% construye hacia atrás, desde los mates, el conjunto de las posiciones
% desde las que el programa da mate contra cualquier defensa. El programa
% de la versión 5 tiene memoria: juega por un árbol forzante hasta que se
% termina, y solo entonces pide otro. Por eso el paso de la verificación no
% es una jugada sino un árbol entero: desde una posición en que la tabla da
% un árbol nuevo, cada respuesta de las negras lleva por el árbol hasta una
% salida, que es un mate, una falla o una posición en que se pide un árbol
% nuevo. Una posición queda asegurada cuando todas sus salidas son mates o
% posiciones ya aseguradas.
%
% Se recorren todas las posiciones con las blancas a mover, sin reducirlas
% por simetría, porque el orden en que se prueban las jugadas no es
% simétrico y el programa puede jugar distinto en dos posiciones simétricas.
%
% solo-local: modifica la base de datos con assertz/1 y tarda minutos.
%
%?- salidas(krk, pos(blancas, 5-5, 1-1, 4-7), S).

:- module(verificar,
          [ salidas/3,
            verificar/2,
            verificar_desde/3,
            no_aseguradas/2,
            peor_partida/3
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(aggregate)).
:- use_module(reglas).
:- use_module(consejos).
:- use_module(finales, [codigo/2, decodificar/3]).
:- use_module(krk, []).
:- use_module(corregida, []).

:- dynamic paso/3, asegura/3.

% paso(T, C, Salidas): con la tabla T, desde la posición de las blancas de
% código C, el árbol nuevo termina en Salidas (ver salidas/3), con las
% posiciones codificadas.
% asegura(T, C, K): con la tabla T, desde la posición de código C, el mate
% llega a lo sumo en K jugadas de las blancas, contra cualquier defensa.

%!  salidas(+Tabla, +Posicion, -Salidas:list) is det.
%
%   Salidas son las maneras en que termina el árbol forzante que Tabla da
%   en Posicion, una por cada camino según las respuestas de las negras:
%   N-mate, si el camino termina en mate después de N jugadas de las
%   blancas; N-nueva(P), si termina en la posición P, con las blancas a
%   mover y sin árbol; N-falla(F), si termina en un ahogado o con la torre
%   capturada. Si la tabla no da ningún árbol, Salidas es
%   [0-falla(sin_consejo)].
salidas(Tabla, Posicion, Salidas) :-
    (   estrategia(Tabla, Posicion, _, Arbol)
    ->  findall(S, recorrer(Posicion, Arbol, 0, S), Salidas)
    ;   Salidas = [0-falla(sin_consejo)]
    ).

%!  recorrer(+Posicion, +Arbol, +N0:integer, -Salida) is nondet.
%
%   Salida es una de las maneras en que termina Arbol, que empieza en
%   Posicion, con las blancas a mover y N0 jugadas hechas.
recorrer(P, juega(J, A), N0, S) :-
    jugada(P, J, P1),
    N is N0 + 1,
    respuesta(P1, A, N, S).

%!  respuesta(+Posicion, +Arbol, +N:integer, -Salida) is nondet.
%
%   Salida es una manera en que termina la partida por el árbol desde
%   Posicion, con las negras a mover; cada jugada legal de las negras da
%   una, esté o no en el árbol.
respuesta(P, _, N, N-mate) :-
    mate(P),
    !.
respuesta(P, _, N, N-falla(ahogado)) :-
    ahogado(P),
    !.
respuesta(P, A, N, S) :-
    jugada(P, R, P2),
    (   P2 = pos(_, _, capturada, _)
    ->  S = N-falla(torre_perdida)
    ;   A = responde(Ramas),
        memberchk(R-A2, Ramas),
        A2 = juega(_, _)
    ->  recorrer(P2, A2, N, S)
    ;   S = N-nueva(P2)
    ).

%!  verificar(+Tabla, -R) is det.
%
%   R es r(Aseguradas, Total, Mayor): de las Total posiciones legales con
%   las blancas a mover, la tabla asegura el mate en Aseguradas, y el mate
%   más demorado llega en Mayor jugadas de las blancas.
verificar(Tabla, R) :-
    retractall(paso(Tabla, _, _)),
    retractall(asegura(Tabla, _, _)),
    forall(posicion_blanca(P), registrar(Tabla, P)),
    propagar(Tabla),
    contar(Tabla, R).

%!  verificar_desde(+Tabla, +Posicion, -R) is det.
%
%   Como verificar/2, pero solo sobre las posiciones a las que puede llegar
%   la partida desde Posicion, con las blancas a mover: Posicion y todas
%   las posiciones nuevas a las que llevan sus árboles, y así siguiendo.
verificar_desde(Tabla, Posicion, R) :-
    retractall(paso(Tabla, _, _)),
    retractall(asegura(Tabla, _, _)),
    alcanzar([Posicion], Tabla),
    propagar(Tabla),
    contar(Tabla, R).

%!  alcanzar(+Pendientes:list, +Tabla) is det.
%
%   Registra las posiciones de Pendientes que todavía no se registraron, y
%   después las posiciones nuevas a las que llevan sus salidas.
alcanzar([], _).
alcanzar([P|Ps], Tabla) :-
    codigo(P, C),
    (   paso(Tabla, C, _)
    ->  alcanzar(Ps, Tabla)
    ;   registrar(Tabla, P),
        paso(Tabla, C, Salidas),
        findall(P1,
                ( member(nueva(C1)-_, Salidas),
                  decodificar(blancas, C1, P1) ),
                Nuevas),
        append(Nuevas, Ps, Ps1),
        alcanzar(Ps1, Tabla)
    ).

%!  contar(+Tabla, -R) is det.
%
%   R es r(Aseguradas, Total, Mayor) sobre las posiciones registradas;
%   Mayor es 0 si ninguna está asegurada.
contar(Tabla, r(Aseguradas, Total, Mayor)) :-
    aggregate_all(count, paso(Tabla, _, _), Total),
    aggregate_all(count, asegura(Tabla, _, _), Aseguradas),
    (   aggregate_all(max(K), asegura(Tabla, _, K), Mayor)
    ->  true
    ;   Mayor = 0
    ).

%!  posicion_blanca(-Posicion) is nondet.
%
%   Posicion es una posición legal con las blancas a mover y la torre en
%   el tablero.
posicion_blanca(P) :-
    P = pos(blancas, RB, T, RN),
    casilla(RN),
    casilla(RB),
    casilla(T),
    legal(P).

%!  casilla(-Casilla) is multi.
%
%   Casilla es una de las 64 casillas del tablero.
casilla(X-Y) :-
    between(1, 8, X),
    between(1, 8, Y).

%!  registrar(+Tabla, +Posicion) is det.
%
%   Agrega paso(Tabla, C, Salidas) para Posicion, con cada salida reducida
%   a la más larga hacia cada destino.
registrar(Tabla, P) :-
    codigo(P, C),
    salidas(Tabla, P, Ss),
    maplist(codificar, Ss, Cs),
    sort(Cs, Ordenadas),
    peores(Ordenadas, Peores),
    assertz(paso(Tabla, C, Peores)).

%!  codificar(+Salida, -Codificada) is det.
%
%   Codificada es Destino-N, con la posición nueva como un código.
codificar(N-nueva(P), nueva(C)-N) :-
    !,
    codigo(P, C).
codificar(N-D, D-N).

%!  peores(+Ordenadas:list, -Peores:list) is det.
%
%   Peores tiene, para cada destino de Ordenadas, el par con la mayor
%   cantidad de jugadas. Ordenadas está ordenada por destino y cantidad.
peores([], []).
peores([D-N], [D-N]) :-
    !.
peores([D-_, D-N|Ps], Peores) :-
    !,
    peores([D-N|Ps], Peores).
peores([P|Ps], [P|Peores]) :-
    peores(Ps, Peores).

%!  propagar(+Tabla) is det.
%
%   Marca como aseguradas, pasada tras pasada, las posiciones cuyas salidas
%   son todas mates o posiciones ya aseguradas, hasta que una pasada no
%   agrega ninguna.
propagar(Tabla) :-
    findall(C-K,
            ( paso(Tabla, C, Salidas),
              \+ asegura(Tabla, C, _),
              valor_salidas(Salidas, Tabla, 0, K) ),
            Nuevas),
    (   Nuevas == []
    ->  true
    ;   forall(member(C-K, Nuevas), assertz(asegura(Tabla, C, K))),
        propagar(Tabla)
    ).

%!  valor_salidas(+Salidas:list, +Tabla, +K0:integer, -K:integer)
%!      is semidet.
%
%   K es el mayor entre K0 y lo que tarda el mate por cada salida: N si es
%   un mate, N más lo asegurado si es una posición nueva. Falla si alguna
%   salida es una falla o una posición todavía no asegurada.
valor_salidas([], _, K, K).
valor_salidas([D-N|Ss], Tabla, K0, K) :-
    valor_destino(D, Tabla, N, V),
    K1 is max(K0, V),
    valor_salidas(Ss, Tabla, K1, K).

%!  valor_destino(+Destino, +Tabla, +N:integer, -V:integer) is semidet.
%
%   V es lo que tarda el mate por una salida a Destino tras N jugadas.
valor_destino(mate, _, N, N).
valor_destino(nueva(C), Tabla, N, V) :-
    asegura(Tabla, C, K),
    V is N + K.

%!  no_aseguradas(+Tabla, -Ps:list) is det.
%
%   Ps son las posiciones desde las que Tabla no asegura el mate, después
%   de verificar/2.
no_aseguradas(Tabla, Ps) :-
    findall(P,
            ( paso(Tabla, C, _),
              \+ asegura(Tabla, C, _),
              decodificar(blancas, C, P) ),
            Ps).

%!  peor_partida(+Tabla, -Posicion, -K:integer) is nondet.
%
%   Desde Posicion el mate puede demorar K jugadas de las blancas, el
%   máximo de todas las posiciones, después de verificar/2.
peor_partida(Tabla, Posicion, K) :-
    aggregate_all(max(K0), asegura(Tabla, _, K0), K),
    asegura(Tabla, C, K),
    decodificar(blancas, C, Posicion).
