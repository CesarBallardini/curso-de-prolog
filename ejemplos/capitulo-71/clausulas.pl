:- encoding(utf8).

% Capítulo 71 - Versión 1: el grafo Y/O escrito como cláusulas.
%
% Una cláusula con varios objetivos en el cuerpo es un nodo Y: para
% probar la cabeza hay que probar todos. Varias cláusulas para la misma
% cabeza son un nodo O: basta con una. Un hecho es un nodo primitivo. Así,
% Prolog ya es una búsqueda en profundidad en un grafo Y/O, y la reducción
% del mapa de mapa.pl se escribe directamente como tres cláusulas de
% llega/2. Tiene tres limitaciones: la respuesta es true o false, sin el
% árbol que la prueba; los costos de los caminos no intervienen; y los
% caminos en los dos sentidos forman ciclos, en los que la búsqueda en
% profundidad no termina.
%
% solo-local: carga mapa.pl.
%
%?- once(llega(alamos, paso)).
%?- call_with_inference_limit(llega(alamos, islas), 1000000, R).

:- ensure_loaded(mapa).

%!  llega(+A, +B) is semidet.
%
%   Hay un recorrido de A a B. Si A y B están en orillas opuestas, pasa
%   por un puente P: va de A a P y de P a B; si no, sale de A por un
%   camino. No termina si la búsqueda entra en un ciclo de caminos.
llega(B, B).
llega(A, B) :-
    A \== B,
    separados(A, B),
    pueblo(P, rio, _, _),
    llega(A, P),
    llega(P, B).
llega(A, B) :-
    A \== B,
    \+ separados(A, B),
    tramo(A, C, _),
    llega(C, B).
