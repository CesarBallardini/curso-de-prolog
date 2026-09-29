:- encoding(utf8).

% Capítulo 40 - Planificación: operadores STRIPS y análisis de medios y fines.
%
% El mundo de bloques del capítulo 22, con los estados como conjuntos
% ordenados de hechos: sobre(B, X), con X otro bloque o mesa; libre(B), que
% no tiene nada encima; mano_vacia; y sostiene(B). Cada acción es un
% operador STRIPS: sus precondiciones, los hechos que agrega y los que
% borra. El análisis de medios y fines elige una meta que el estado no
% cumple, un operador que la agrega, planifica antes sus precondiciones,
% aplica el operador, y sigue con las metas. planificar/3 fija la longitud
% del plan con length/2, como la profundización iterativa: sin esa cota, la
% recursión sobre las precondiciones no termina.
%
%?- sussman(E), planificar(E, [sobre(a, b), sobre(b, c)], Plan).
%?- sussman(E), aplicar(E, desapilar(c, a), E1).

% bloque(B): B es un bloque.
bloque(a).
bloque(b).
bloque(c).

%!  sussman(-Estado:list) is det.
%
%   Estado es el estado inicial de la anomalía de Sussman: c sobre a, y a y
%   b sobre la mesa.
sussman(Estado) :-
    list_to_ord_set([sobre(c, a), sobre(a, mesa), sobre(b, mesa), libre(c),
                     libre(b), mano_vacia],
                    Estado).

%!  operador(?Accion, -Precondiciones:list, -Agrega:list, -Borra:list)
%!      is nondet.
%
%   Accion es aplicable en un estado que cumple Precondiciones; en el
%   estado siguiente, los hechos de Borra dejan de valer y los de Agrega
%   pasan a valer. Las acciones se generan sin variables.
operador(tomar(B), [libre(B), sobre(B, mesa), mano_vacia],
         [sostiene(B)], [libre(B), sobre(B, mesa), mano_vacia]) :-
    bloque(B).
operador(desapilar(B, C), [libre(B), sobre(B, C), mano_vacia],
         [sostiene(B), libre(C)], [libre(B), sobre(B, C), mano_vacia]) :-
    bloque(B),
    bloque(C),
    B \== C.
operador(soltar(B), [sostiene(B)],
         [sobre(B, mesa), libre(B), mano_vacia], [sostiene(B)]) :-
    bloque(B).
operador(apilar(B, C), [sostiene(B), libre(C)],
         [sobre(B, C), libre(B), mano_vacia], [sostiene(B), libre(C)]) :-
    bloque(B),
    bloque(C),
    B \== C.

%!  aplicar(+Estado:list, ?Accion, -Siguiente:list) is nondet.
%
%   Accion se puede aplicar en Estado y lleva a Siguiente: Estado menos lo
%   que Accion borra, más lo que agrega.
aplicar(Estado, Accion, Siguiente) :-
    operador(Accion, Pre, Agrega, Borra),
    list_to_ord_set(Pre, Pre1),
    ord_subset(Pre1, Estado),
    list_to_ord_set(Borra, Borra1),
    list_to_ord_set(Agrega, Agrega1),
    ord_subtract(Estado, Borra1, Estado1),
    ord_union(Estado1, Agrega1, Siguiente).

%!  planificar(+Estado:list, +Metas:list, -Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado donde valen todas las Metas, y se
%   obtiene por medios y fines. Los planes se obtienen de menor a mayor
%   longitud; si no hay ninguno, no termina.
planificar(Estado, Metas, Plan) :-
    length(Plan, _),
    lograr(Estado, Metas, Plan, _).

%!  lograr(+Estado:list, +Metas:list, ?Plan:list, -Final:list) is nondet.
%
%   Plan lleva de Estado a Final, donde valen las Metas: cada acción logra
%   una meta que no valía, después de lograr sus precondiciones. Con la
%   longitud de Plan fijada, termina.
lograr(Estado, Metas, [], Estado) :-
    list_to_ord_set(Metas, Metas1),
    ord_subset(Metas1, Estado).
lograr(Estado, Metas, Plan, Final) :-
    append(Antes, [Accion|Despues], Plan),
    member(Meta, Metas),
    \+ ord_memberchk(Meta, Estado),
    operador(Accion, Pre, Agrega, _),
    memberchk(Meta, Agrega),
    lograr(Estado, Pre, Antes, Intermedio),
    aplicar(Intermedio, Accion, Siguiente),
    lograr(Siguiente, Metas, Despues, Final).
