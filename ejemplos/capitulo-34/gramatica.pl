:- encoding(utf8).

% Capítulo 34 - Las gramáticas como listas diferencia.
%
% en_orden//1 describe la lista de los elementos de un árbol en orden, como
% inorden_dif/2 de diferencia.pl, pero con la notación de las gramáticas:
% Prolog la traduce a en_orden/3, con la lista y su final como dos
% argumentos. en_orden_dif/3 es esa traducción escrita a mano. A
% diferencia de un analizador, la gramática no lee la lista: la construye.
%
%?- phrase(en_orden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio))), L).
%?- phrase(en_orden(n(vacio, 1, vacio)), L, [fin]).
%?- en_orden_dif(n(n(vacio, 1, vacio), 2, vacio), L, []).

%!  en_orden(+Arbol)// is det.
%
%   Los elementos de Arbol en orden: los del subárbol izquierdo, la raíz y
%   los del derecho. Arbol es vacio o n(Izq, X, Der).
en_orden(vacio) -->
    [].
en_orden(n(Izq, X, Der)) -->
    en_orden(Izq),
    [X],
    en_orden(Der).

%!  en_orden_dif(+Arbol, ?L:list, ?F:list) is det.
%
%   L tiene los elementos de Arbol en orden, seguidos de F: la traducción
%   de en_orden//1, escrita a mano.
en_orden_dif(vacio, L, L).
en_orden_dif(n(Izq, X, Der), L, F) :-
    en_orden_dif(Izq, L, [X|M]),
    en_orden_dif(Der, M, F).
