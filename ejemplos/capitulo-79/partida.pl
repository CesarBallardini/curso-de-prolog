:- encoding(utf8).

% Capítulo 79 - Versión 5: jugar con la tabla de consejos.
%
% El ciclo de juego de Advice Language 0: con las blancas a mover y sin un
% árbol forzante en curso, la tabla da un consejo y su árbol; las blancas
% juegan por el árbol mientras dure, y cuando se termina piden otro. Las
% negras juegan con una defensa, un predicado que recibe la posición y
% elige una respuesta legal. La partida es una lista de jugadas, cada una
% con el consejo que la eligió.
%
% solo-local: carga reglas.pl, consejos.pl, krk.pl, corregida.pl y
% finales.pl.
%
%?- partida(krk, primera, pos(blancas, 5-5, 1-1, 4-7), P, F).

:- module(partida,
          [ partida/5,
            jugadas_hasta_mate/4,
            medir/3,
            primera/2,
            resistente/2,
            narrar/3
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(reglas).
:- use_module(consejos).
:- use_module(krk).
:- use_module(corregida, []).
:- use_module(finales, [posiciones/2]).

:- meta_predicate partida(+, 2, +, -, -), jugadas_hasta_mate(+, 2, +, -),
                  narrar(+, 2, +), medir(+, 2, -).

%!  partida(+Tabla, :Defensa, +Posicion, -Jugadas:list, -Final) is det.
%
%   Jugadas es la partida que se juega desde Posicion con las blancas
%   guiadas por Tabla y las negras por Defensa: una lista de elementos
%   blancas(Jugada, Consejo), con el consejo que dio el árbol en curso, y
%   negras(Jugada). Final es mate, ahogado, torre_perdida, sin_consejo (si
%   ningún consejo es satisfacible) o limite (después de 100 jugadas de las
%   blancas).
partida(Tabla, Defensa, Posicion, Jugadas, Final) :-
    jugar(Tabla, Defensa, Posicion, ninguno, 0, Jugadas, Final).

%!  jugar(+Tabla, :Defensa, +Posicion, +Arbol, +N:integer, -Jugadas:list,
%!        -Final) is det.
%
%   Continúa la partida desde Posicion, con Arbol el árbol forzante en
%   curso, consejo(Nombre, A), o ninguno; N es la cantidad de jugadas de
%   las blancas hechas.
jugar(Tabla, Defensa, Posicion, Arbol, N, Jugadas, Final) :-
    (   terminada(Posicion, F)
    ->  Jugadas = [],
        Final = F
    ;   N >= 100
    ->  Jugadas = [],
        Final = limite
    ;   Posicion = pos(blancas, _, _, _)
    ->  (   siguiente_en_arbol(Arbol, Nombre, Jugada, Resto)
        ->  true
        ;   estrategia(Tabla, Posicion, Nombre, juega(Jugada, A))
        ->  Resto = A
        ;   Jugada = ninguna
        ),
        (   Jugada == ninguna
        ->  Jugadas = [],
            Final = sin_consejo
        ;   once(jugada(Posicion, Jugada, Siguiente)),
            N1 is N + 1,
            Jugadas = [blancas(Jugada, Nombre)|Js],
            jugar(Tabla, Defensa, Siguiente, consejo(Nombre, Resto), N1, Js,
                  Final)
        )
    ;   call(Defensa, Posicion, Jugada),
        once(jugada(Posicion, Jugada, Siguiente)),
        rama(Arbol, Jugada, Arbol1),
        Jugadas = [negras(Jugada)|Js],
        jugar(Tabla, Defensa, Siguiente, Arbol1, N, Js, Final)
    ).

%!  terminada(+Posicion, -Final) is semidet.
%
%   La partida terminó en Posicion: mate, ahogado o torre_perdida, si la
%   torre fue capturada.
terminada(P, mate) :-
    mate(P),
    !.
terminada(P, ahogado) :-
    ahogado(P),
    !.
terminada(pos(_, _, capturada, _), torre_perdida).

%!  siguiente_en_arbol(+Arbol, -Nombre, -Jugada, -Resto) is semidet.
%
%   El árbol en curso indica la Jugada de las blancas, y Resto es lo que
%   queda de él. Falla si no hay árbol en curso o si se terminó.
siguiente_en_arbol(consejo(Nombre, juega(Jugada, Resto)), Nombre, Jugada,
                   Resto).

%!  rama(+Arbol, +Respuesta, -Arbol1) is det.
%
%   Arbol1 es el subárbol que corresponde a la Respuesta de las negras, o
%   ninguno si el árbol se terminó o no la prevé.
rama(consejo(Nombre, responde(Ramas)), Respuesta, consejo(Nombre, A)) :-
    memberchk(Respuesta-A, Ramas),
    !.
rama(_, _, ninguno).

%!  jugadas_hasta_mate(+Tabla, :Defensa, +Posicion, -N:integer) is semidet.
%
%   La partida desde Posicion termina en mate después de N jugadas de las
%   blancas. Falla si termina de otra forma.
jugadas_hasta_mate(Tabla, Defensa, Posicion, N) :-
    partida(Tabla, Defensa, Posicion, Jugadas, mate),
    include(de_blancas, Jugadas, Bs),
    length(Bs, N).

%!  medir(+Tabla, :Defensa, -R) is det.
%
%   Juega una partida desde cada una de las 27 352 posiciones con las
%   blancas a mover y el rey negro en el triángulo a1-d1-d4. R es
%   r(Finales, Mayor, Media): Finales cuenta las partidas por su final, como
%   pares Final-Cantidad; Mayor y Media son la mayor cantidad y la media de
%   jugadas de las blancas en las que terminaron en mate.
medir(Tabla, Defensa, r(Finales, Mayor, Media)) :-
    posiciones(blancas, Ps),
    findall(F-N,
            ( member(P, Ps),
              partida(Tabla, Defensa, P, Js, F),
              include(de_blancas, Js, Bs),
              length(Bs, N) ),
            FNs),
    pairs_keys(FNs, Fs0),
    msort(Fs0, Fs),
    clumped(Fs, Finales),
    findall(N, member(mate-N, FNs), Ns),
    max_list(Ns, Mayor),
    sum_list(Ns, Suma),
    length(Ns, Cantidad),
    Media is round(100 * Suma / Cantidad) / 100.

% de_blancas(E): el elemento E de una partida es una jugada de las blancas.
de_blancas(blancas(_, _)).

% --- Defensas ------------------------------------------------------------

%!  primera(+Posicion, -Jugada) is semidet.
%
%   Jugada es la primera jugada legal de las negras en Posicion.
primera(Posicion, Jugada) :-
    once(jugada(Posicion, Jugada, _)).

%!  resistente(+Posicion, -Jugada) is semidet.
%
%   Jugada es la respuesta de las negras que deja a su rey el mayor
%   espacio y, entre las que empatan, la más alejada de los bordes. Captura
%   la torre si puede.
resistente(Posicion, Jugada) :-
    findall(V-J,
            ( jugada(Posicion, J, S),
              valor_defensa(S, V) ),
            VJs),
    VJs \== [],
    keysort(VJs, Ordenadas),
    last(Ordenadas, _-Jugada).

%!  valor_defensa(+Posicion, -Valor) is det.
%
%   Valor ordena las posiciones que pueden resultar de una respuesta de las
%   negras: la torre capturada es lo mejor; si no, más espacio y más
%   distancia al borde.
valor_defensa(pos(_, _, capturada, _), v(1000, 0)) :-
    !.
valor_defensa(P, v(E, B)) :-
    espacio(P, E),
    P = pos(_, _, _, X-Y),
    B is min(min(X, 9 - X), min(Y, 9 - Y)).

% --- La partida escrita --------------------------------------------------

%!  narrar(+Tabla, :Defensa, +Posicion) is det.
%
%   Escribe la partida desde Posicion: una línea por jugada de las blancas,
%   con la respuesta de las negras y el consejo, y al final el resultado.
narrar(Tabla, Defensa, Posicion) :-
    partida(Tabla, Defensa, Posicion, Jugadas, Final),
    escribir(Jugadas, 1),
    format("~w~n", [Final]).

%!  escribir(+Jugadas:list, +N:integer) is det.
%
%   Escribe las jugadas numeradas desde N.
escribir([], _).
escribir([blancas(J, C)|Js], N) :-
    notacion(J, T),
    (   Js = [negras(R)|Js1]
    ->  notacion(R, TR)
    ;   TR = '',
        Js1 = Js
    ),
    format("~w. ~w ~w~t~20|~w~n", [N, T, TR, C]),
    N1 is N + 1,
    escribir(Js1, N1).
