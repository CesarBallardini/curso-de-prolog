:- encoding(utf8).

% Capítulo 51 - Algoritmos de Markov y sistemas de Post.
%
% Dos modelos de cómputo que trabajan sobre una palabra, una lista de
% símbolos, reescribiéndola, sin estados ni cinta.
%
% Un algoritmo de Markov es una lista ordenada de reglas
%
%   regla_markov(A, Izquierda, Derecha, Tipo)
%
% En cada paso se toma la primera regla, en el orden del programa, cuya
% Izquierda aparece en la palabra, y se reemplaza su primera aparición,
% la de más a la izquierda, por Derecha. Una Izquierda vacía aparece al
% comienzo de cualquier palabra. Si la regla es de Tipo para, el
% algoritmo se detiene; si es de Tipo sigue, vuelve a empezar; si ninguna
% regla se aplica, se detiene.
%
% Una producción de Post tiene variables, que se ligan a partes de la
% palabra:
%
%   produccion(P, Izquierda, Derecha, Tipo)
%
% Izquierda y Derecha son listas de segmentos: un segmento es una lista
% de símbolos o una variable que representa una palabra cualquiera. La
% Izquierda debe coincidir con toda la palabra; la palabra nueva es la
% Derecha con las variables ligadas. Aquí se toma, como en un algoritmo,
% la primera producción y la primera manera de coincidir.
%
% Las dos relaciones son multifile: otros archivos agregan algoritmos.
%
%?- markov(intercambio, [a, b, b, a], 100, R).
%?- markov(ordenar, [b, a, b, a], 100, R).
%?- post(palindromo_p, [a, b, b, a], 100, R).

:- multifile regla_markov/4, produccion/4.
:- discontiguous regla_markov/4, produccion/4.

% intercambio cambia cada a por b y cada b por a: la última regla pone
% una marca # al comienzo, las dos primeras la hacen avanzar cambiando la
% letra que salta, y la tercera la borra al llegar al final.
regla_markov(intercambio, [#, a], [b, #], sigue).
regla_markov(intercambio, [#, b], [a, #], sigue).
regla_markov(intercambio, [#], [], para).
regla_markov(intercambio, [], [#], sigue).

% ordenar pone todas las a antes que las b: cada paso intercambia la
% primera b seguida de una a.
regla_markov(ordenar, [b, a], [a, b], sigue).

% palindromo_p reduce una palabra sobre {a, b} quitando la primera y la
% última letra mientras son iguales; escribe si cuando la reducción llega
% a una letra o a la palabra vacía, y se detiene sin reescribir si las dos
% puntas son distintas.
produccion(palindromo_p, [[a], X, [a]], [X], sigue).
produccion(palindromo_p, [[b], X, [b]], [X], sigue).
produccion(palindromo_p, [[a]], [[s, i]], para).
produccion(palindromo_p, [[b]], [[s, i]], para).
produccion(palindromo_p, [], [[s, i]], para).

%!  markov(+A, +W:list, +Limite:integer, -R) is det.
%
%   R es el resultado de aplicar el algoritmo de Markov A a la palabra W,
%   con a lo sumo Limite pasos: fin(W1), con la palabra final, o
%   limite(W1), si se agotaron los pasos.
markov(A, W, Limite, R) :-
    (   regla_markov(A, Izquierda, Derecha, Tipo),
        reemplazar(Izquierda, Derecha, W, W1)
    ->  (   Limite =:= 0
        ->  R = limite(W)
        ;   Tipo == para
        ->  R = fin(W1)
        ;   Limite1 is Limite - 1,
            markov(A, W1, Limite1, R)
        )
    ;   R = fin(W)
    ).

%!  reemplazar(+Izquierda:list, +Derecha:list, +W:list, -W1:list)
%!      is semidet.
%
%   W1 es W con la primera aparición de Izquierda reemplazada por
%   Derecha. Falla si Izquierda no aparece en W.
reemplazar(Izquierda, Derecha, W, W1) :-
    append(Antes, Resto, W),
    append(Izquierda, Despues, Resto),
    !,
    append([Antes, Derecha, Despues], W1).

%!  post(+P, +W:list, +Limite:integer, -R) is det.
%
%   R es el resultado de aplicar las producciones de Post de P a la
%   palabra W, con a lo sumo Limite pasos: fin(W1) o limite(W1), como en
%   markov/4.
post(P, W, Limite, R) :-
    (   produccion(P, Izquierda, Derecha, Tipo),
        coincidir(Izquierda, W)
    ->  append(Derecha, W1),
        (   Limite =:= 0
        ->  R = limite(W)
        ;   Tipo == para
        ->  R = fin(W1)
        ;   Limite1 is Limite - 1,
            post(P, W1, Limite1, R)
        )
    ;   R = fin(W)
    ).

%!  coincidir(?Segmentos:list, +W:list) is nondet.
%
%   La concatenación de los Segmentos es W: cada variable libre se liga a
%   una parte de W, en todas las maneras posibles.
coincidir([], []).
coincidir([S|Ss], W) :-
    append(S, Resto, W),
    coincidir(Ss, Resto).
