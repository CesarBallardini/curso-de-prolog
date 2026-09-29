:- encoding(utf8).

% Capítulo 71 - Versión 6: estrategias ganadoras como árboles solución.
%
% Un juego de dos jugadores es un grafo Y/O visto desde uno de ellos, J.
% En una posición en la que mueve J, basta con una jugada que gane: es un
% nodo O, mueve(Pos). En una posición en la que mueve el rival, J tiene que
% ganar contra todas sus respuestas: es un nodo Y, responde(Pos). Un nodo
% responde(Pos) en el que la partida terminó con la victoria de J es
% primitivo; cualquier otra posición final no tiene solución. Cada jugada
% cuesta 1.
%
% El problema es gana(Juego, J), sobre el ta-te-ti del capítulo 41. Un
% árbol solución es una estrategia ganadora: dice qué jugar en cada
% posición a la que el rival puede llevar la partida. ganada/2 del
% capítulo 41 responde si esa estrategia existe; las búsquedas de este
% capítulo la construyen. Dos órdenes distintos de jugadas llevan a la
% misma posición, así que el grafo comparte nodos, y la versión 5 los
% resuelve una sola vez.
%
% solo-local: carga las búsquedas de las versiones 2, 4 y 5, y
% capitulo41.pl, que carga un archivo de otro capítulo.
%
%?- estrategia(mejor, [x,o,v, v,x,v, v,v,o], Resultado, Expandidos).
%?- estrategia(compartido, [v,v,v, v,v,v, v,v,v], Resultado, Expandidos).

:- ensure_loaded(profundidad).
:- ensure_loaded(compartidos).
:- ensure_loaded(mejor).
:- use_module(capitulo41).

:- multifile primitivo/2, expansion/4, estimacion/3.

%!  primitivo(+Problema, +Nodo) is semidet.
%
%   Nodo es responde(Pos) y en Pos la partida terminó con la victoria de J.
primitivo(gana(Juego, J), responde(Pos)) :-
    fin(Juego, Pos, gana(J)).

%!  expansion(+Problema, +Nodo, -Tipo, -Hijos:list) is semidet.
%
%   En mueve(Pos), un nodo O, los hijos son las respuestas del rival a cada
%   jugada de J; en responde(Pos), un nodo Y, las posiciones a las que el
%   rival puede llevar la partida. Falla si la partida terminó.
expansion(gana(Juego, _), mueve(Pos), o, Hijos) :-
    \+ fin(Juego, Pos, _),
    findall(responde(Sig)-1, jugada(Juego, Pos, _, Sig), Hijos).
expansion(gana(Juego, _), responde(Pos), y, Hijos) :-
    \+ fin(Juego, Pos, _),
    findall(mueve(Sig)-1, jugada(Juego, Pos, _, Sig), Hijos).

%!  estimacion(+Problema, +Nodo, -H:integer) is det.
%
%   H es la menor cantidad de jugadas que puede tener la estrategia.
estimacion(gana(_, _), Nodo, H) :-
    minimo(Nodo, H).

% minimo(N, H): una posición en la que mueve J necesita al menos una
% jugada más; una en la que mueve el rival y que no es final, al menos dos.
minimo(mueve(_), 1).
minimo(responde(_), 2).

%!  plan(+Arbol, -Plan) is det.
%
%   Plan es la estrategia de Arbol, un árbol solución de un nodo mueve(P),
%   escrita con las casillas: jugar(C, Respuestas) juega la casilla C, y
%   Respuestas es gana si con eso termina la partida, o la lista de R-Plan,
%   el plan que sigue a cada respuesta R del rival.
plan(o(mueve(P), A-_), jugar(C, Respuestas)) :-
    raiz(A, responde(P1)),
    casilla(P, P1, C),
    respuestas(A, Respuestas).

%!  respuestas(+Arbol, -Respuestas) is det.
%
%   Respuestas es gana si Arbol es primitivo, o la lista de R-Plan para
%   cada respuesta R del rival en Arbol.
respuestas(meta(_), gana).
respuestas(y(responde(P), Arcos), Respuestas) :-
    maplist(respuesta(P), Arcos, Respuestas).

%!  respuesta(+P, +Arco, -Respuesta) is det.
%
%   Respuesta es R-Plan: el rival juega R en P, y el árbol del arco sigue
%   con Plan.
respuesta(P, A-_, R-Plan) :-
    raiz(A, mueve(P1)),
    casilla(P, P1, R),
    plan(A, Plan).

%!  casilla(+P0, +P, -C:integer) is det.
%
%   C es la casilla en la que difieren los tableros de las posiciones P0
%   y P.
casilla(pos(T0, _), pos(T, _), C) :-
    nth1(C, T0, v),
    nth1(C, T, M),
    M \== v,
    !.

%!  estrategia(+Busqueda, +Tablero:list, -Resultado, -Expandidos:integer)
%!      is det.
%
%   Busqueda, profundidad, compartido o mejor, busca una estrategia
%   ganadora para x en la posición de Tablero del ta-te-ti de 3 × 3, en la
%   que mueve x. Resultado es jugadas(N, Plan), con el plan de la
%   estrategia y su cantidad de jugadas, o ninguna; Expandidos es la
%   cantidad de nodos expandidos.
estrategia(Busqueda, Tablero, Resultado, Expandidos) :-
    buscar_estrategia(Busqueda, gana(tateti(3), x), mueve(pos(Tablero, x)),
                      R, Expandidos),
    (   R = si(Arbol)
    ->  costo(Arbol, N),
        plan(Arbol, Plan),
        Resultado = jugadas(N, Plan)
    ;   Resultado = ninguna
    ).

%!  buscar_estrategia(+Busqueda, +Problema, +Nodo, -R, -Expandidos:integer)
%!      is det.
%
%   R es si(Arbol) con el árbol solución de Nodo que halla Busqueda, o no.
buscar_estrategia(profundidad, Problema, Nodo, R, K) :-
    profundidad(Problema, Nodo, [], R, 0, K).
buscar_estrategia(compartido, Problema, Nodo, R, K) :-
    empty_assoc(M),
    recordado(Problema, Nodo, R, m(M, 0), m(_, K)).
buscar_estrategia(mejor, Problema, Nodo, R, K) :-
    buscar_mejor(Problema, Nodo, T, K),
    (   T = hecho(_, _, Arbol)
    ->  R = si(Arbol)
    ;   R = no
    ).
