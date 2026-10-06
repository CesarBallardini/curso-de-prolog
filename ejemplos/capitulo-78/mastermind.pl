:- encoding(utf8).

% Capítulo 78 - Mastermind, versión 1: la siguiente jugada consistente.
%
% El código secreto son cuatro dígitos distintos, de 0 a 9. Cada intento
% recibe una respuesta: los toros, dígitos del intento que están en el
% código en la misma posición, y las vacas, dígitos que están en el código
% en otra posición. El programa adivina con la regla de Sterling y Shapiro:
% los intentos posibles se recorren en orden, y se propone siempre el
% primero que es consistente con todas las respuestas recibidas, es decir,
% el que, si fuera el código, habría recibido esas mismas respuestas.
%
% Las respuestas se guardan en una lista de términos r(Intento, Toros,
% Vacas), y cada intento se busca desde el primer código: es generar y
% probar.
%
%?- respuesta([1, 2, 3, 4], [1, 3, 5, 6], T, V).
%?- adivinar([3, 8, 1, 6], Intentos).

:- module(mastermind,
          [ codigo/1,
            respuesta/4,
            consistente/2,
            siguiente/2,
            adivinar/2,
            medir/4
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

%!  codigo(-Codigo:list(integer)) is multi.
%
%   Codigo es una lista de cuatro dígitos distintos. Enumera los 5040
%   códigos en orden creciente, de [0, 1, 2, 3] a [9, 8, 7, 6].
codigo(Codigo) :-
    numlist(0, 9, Digitos),
    distintos(4, Digitos, Codigo).

%!  distintos(+N:integer, +Elementos:list, -Lista:list) is nondet.
%
%   Lista son N elementos distintos de Elementos, en el orden en que
%   select/3 los elige.
distintos(0, _, []).
distintos(N, Elementos, [X|Xs]) :-
    N > 0,
    select(X, Elementos, Resto),
    N1 is N - 1,
    distintos(N1, Resto, Xs).

%!  respuesta(+Secreto:list, +Intento:list, -Toros:integer,
%!            -Vacas:integer) is det.
%
%   Toros es la cantidad de posiciones en que Intento coincide con
%   Secreto, y Vacas la de dígitos de Intento que están en Secreto en otra
%   posición.
respuesta(Secreto, Intento, Toros, Vacas) :-
    foldl(toro, Secreto, Intento, 0, Toros),
    include(en(Secreto), Intento, Comunes),
    length(Comunes, C),
    Vacas is C - Toros.

%!  toro(+X, +Y, +T0:integer, -T:integer) is det.
%
%   T es T0 más 1 si X e Y son el mismo dígito.
toro(X, Y, T0, T) :-
    (   X =:= Y
    ->  T is T0 + 1
    ;   T = T0
    ).

%!  en(+Lista:list, +X) is semidet.
%
%   X está en Lista.
en(Lista, X) :-
    memberchk(X, Lista).

%!  consistente(+Respuestas:list, +Intento:list) is semidet.
%
%   Si Intento fuera el código, cada intento anterior de Respuestas,
%   r(I, T, V), habría recibido T toros y V vacas.
consistente(Respuestas, Intento) :-
    forall(member(r(I, T, V), Respuestas),
           respuesta(Intento, I, T, V)).

%!  siguiente(+Respuestas:list, -Intento:list) is semidet.
%
%   Intento es el primer código consistente con Respuestas. Recorre los
%   códigos desde el primero. Falla si ninguno es consistente: las
%   respuestas se contradicen. Intento debe llegar libre.
siguiente(Respuestas, Intento) :-
    once(( codigo(Intento),
           consistente(Respuestas, Intento) )).

%!  adivinar(+Secreto:list, -Intentos:list) is det.
%
%   Intentos son los intentos de la versión 1 contra Secreto, hasta el
%   que lo acierta, que es el último.
adivinar(Secreto, Intentos) :-
    adivinar(Secreto, [], Intentos).

%!  adivinar(+Secreto:list, +Respuestas:list, -Intentos:list) is det.
%
%   Como adivinar/2, con las Respuestas ya recibidas.
adivinar(Secreto, Respuestas, [Intento|Intentos]) :-
    siguiente(Respuestas, Intento),
    respuesta(Secreto, Intento, T, V),
    (   T =:= 4
    ->  Intentos = []
    ;   adivinar(Secreto, [r(Intento, T, V)|Respuestas], Intentos)
    ).

%!  medir(:Adivinar, +Secretos:list, -Cuantos:list(pair), -Media:float)
%!      is det.
%
%   Juega con Adivinar, un predicado como adivinar/2, contra cada código
%   de Secretos. Cuantos son pares N-K: K partidas se ganaron con N
%   intentos. Media es la cantidad media de intentos.
medir(Adivinar, Secretos, Cuantos, Media) :-
    maplist(intentos(Adivinar), Secretos, Ns),
    msort(Ns, Ordenados),
    clumped(Ordenados, Cuantos),
    sum_list(Ns, Total),
    length(Ns, Partidas),
    Media is Total / Partidas.

:- meta_predicate
    medir(2, +, -, -),
    intentos(2, +, -).

%!  intentos(:Adivinar, +Secreto:list, -N:integer) is det.
%
%   N es la cantidad de intentos que Adivinar necesita contra Secreto.
intentos(Adivinar, Secreto, N) :-
    call(Adivinar, Secreto, Intentos),
    length(Intentos, N).
