:- encoding(utf8).

% Capítulo 79 - Versión 3: el lenguaje de consejos y su intérprete.
%
% Un consejo tiene cuatro ingredientes: la meta mejor, que se quiere
% alcanzar; la meta a mantener, que no puede dejar de cumplirse en el
% camino; las restricciones de nuestras jugadas, y las de las jugadas del
% rival. Un consejo es satisfacible en una posición si nuestro bando puede
% forzar la meta mejor sin violar la meta a mantener, jugando solo las
% jugadas permitidas, contra cualquiera de las respuestas permitidas al
% rival. La prueba es un árbol forzante: una jugada en cada posición en que
% movemos y todas las respuestas en cada posición en que mueve el rival.
%
% Una tabla de consejos es un módulo que define:
%   regla(Nombre, si Condicion entonces Consejos), en orden de preferencia;
%   consejo(Nombre, MetaMejor, MetaAMantener, Nuestras, Suyas);
%   mueve(Posicion, Bando), con Bando igual a nosotros o ellos;
%   meta(Nombre, Posicion, Raiz), cada condición elemental, que puede
%   comparar la posición con la raíz del árbol;
%   jugadas(Nombre, Posicion, Jugada, Siguiente), cada restricción
%   elemental de las jugadas.
% El intérprete no conoce el juego: recibe el nombre de la tabla.
%
% solo-local: llama a la tabla por el nombre de su módulo, que el sandbox de
% SWISH no permite.

:- module(consejos,
          [ estrategia/4,
            satisfacible/4,
            cumple/4,
            jugada_con/6,
            op(800, xfx, entonces),
            op(790, fx, si),
            op(785, xfy, o),
            op(785, xfy, luego),
            op(780, xfy, y),
            op(770, fy, no)
          ]).

:- use_module(library(lists)).

%!  estrategia(+Tabla, +Posicion, -Consejo, -Arbol) is semidet.
%
%   Consejo es el primer consejo satisfacible de la primera regla de Tabla
%   cuya condición se cumple en Posicion, y Arbol su árbol forzante. Falla
%   si ningún consejo de esa regla es satisfacible.
estrategia(Tabla, Posicion, Consejo, Arbol) :-
    once(( Tabla:regla(_, si Condicion entonces Consejos),
           cumple(Tabla, Condicion, Posicion, Posicion) )),
    member(Consejo, Consejos),
    satisfacible(Tabla, Consejo, Posicion, Arbol),
    !.

%!  satisfacible(+Tabla, +Consejo, +Posicion, -Arbol) is semidet.
%
%   El consejo de nombre Consejo es satisfacible en Posicion, y Arbol es
%   el primer árbol forzante que se encuentra. Posicion es la raíz: tiene
%   profundidad 0, y las metas que comparan se refieren a ella.
satisfacible(Tabla, Consejo, Posicion, Arbol) :-
    Tabla:consejo(Consejo, Mejor, Mantener, Nuestras, Suyas),
    C = c(Tabla, Mejor, Mantener, Nuestras, Suyas),
    once(forzar(C, Posicion, 0, Posicion, Arbol)).

%!  forzar(+C, +Posicion, +Prof:integer, +Raiz, -Arbol) is nondet.
%
%   Arbol es un árbol forzante del consejo C desde Posicion, a Prof
%   jugadas de la Raiz: hoja si la meta mejor ya se cumple; juega(J, A) si
%   movemos, con la jugada J y el árbol A de la posición siguiente;
%   responde(Rs) si mueve el rival, con un par Respuesta-Arbol por cada
%   respuesta permitida. La meta a mantener se cumple en todos los nodos.
forzar(C, Posicion, Prof, Raiz, Arbol) :-
    C = c(Tabla, Mejor, Mantener, Nuestras, Suyas),
    cumple(Tabla, Mantener, Posicion, Raiz),
    (   cumple(Tabla, Mejor, Posicion, Raiz)
    ->  Arbol = hoja
    ;   Tabla:mueve(Posicion, nosotros)
    ->  Prof1 is Prof + 1,
        jugada_con(Tabla, Nuestras, Posicion, Prof, Jugada, Siguiente),
        forzar(C, Siguiente, Prof1, Raiz, A),
        Arbol = juega(Jugada, A)
    ;   Prof1 is Prof + 1,
        findall(J-S,
                jugada_con(Tabla, Suyas, Posicion, Prof, J, S),
                Respuestas),
        Respuestas \== [],
        forzar_todas(Respuestas, C, Prof1, Raiz, Ramas),
        Arbol = responde(Ramas)
    ).

%!  forzar_todas(+Respuestas:list, +C, +Prof:integer, +Raiz, -Ramas:list)
%!      is nondet.
%
%   Ramas tiene un par Jugada-Arbol por cada par Jugada-Posicion de
%   Respuestas, con un árbol forzante desde cada posición.
forzar_todas([], _, _, _, []).
forzar_todas([J-P|JPs], C, Prof, Raiz, [J-A|Ramas]) :-
    forzar(C, P, Prof, Raiz, A),
    forzar_todas(JPs, C, Prof, Raiz, Ramas).

%!  cumple(+Tabla, +Condicion, +Posicion, +Raiz) is semidet.
%
%   Condicion se cumple en Posicion. Una condición es una meta elemental
%   de Tabla o una combinación de condiciones con y, o y no. Raiz es la
%   posición con que empezó la búsqueda, para las metas que comparan.
cumple(Tabla, A y B, P, R) :-
    !,
    cumple(Tabla, A, P, R),
    cumple(Tabla, B, P, R).
cumple(Tabla, A o B, P, R) :-
    !,
    (   cumple(Tabla, A, P, R)
    ->  true
    ;   cumple(Tabla, B, P, R)
    ).
cumple(Tabla, no A, P, R) :-
    !,
    \+ cumple(Tabla, A, P, R).
cumple(Tabla, Meta, P, R) :-
    Tabla:meta(Meta, P, R),
    !.

%!  jugada_con(+Tabla, +Restriccion, +Posicion, +Prof:integer, ?Jugada,
%!             -Siguiente) is nondet.
%
%   Jugada lleva de Posicion a Siguiente y cumple Restriccion. Una
%   restricción es una restricción elemental de Tabla, una condición sobre
%   la profundidad (profundidad = N, profundidad < N), dos restricciones
%   que se cumplen a la vez (y) o dos en orden de preferencia (luego): las
%   jugadas de la primera, después las de la segunda.
jugada_con(Tabla, A y B, P, D, J, S) :-
    !,
    jugada_con(Tabla, A, P, D, J, S),
    jugada_con(Tabla, B, P, D, J, S).
jugada_con(Tabla, A luego B, P, D, J, S) :-
    !,
    (   jugada_con(Tabla, A, P, D, J, S)
    ;   jugada_con(Tabla, B, P, D, J, S)
    ).
jugada_con(_, profundidad = N, _, D, _, _) :-
    !,
    D =:= N.
jugada_con(_, profundidad < N, _, D, _, _) :-
    !,
    D < N.
jugada_con(Tabla, Nombre, P, _, J, S) :-
    Tabla:jugadas(Nombre, P, J, S).
