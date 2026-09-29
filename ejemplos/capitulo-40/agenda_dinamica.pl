:- encoding(utf8).

% Capítulo 40 - Antipatrón: la agenda en la base de datos dinámica.
%
% La misma búsqueda en anchura con visitados de visitados.pl, con la
% frontera y los visitados guardados como hechos dinámicos: assertz/1 agrega
% un nodo al final de la agenda, retract/1 saca el primero. El programa
% encuentra el mismo plan, pero la agenda es estado global: queda cargada
% después de cada búsqueda y la siguiente parte de ella, dos búsquedas no
% pueden estar en curso a la vez, y cada paso cuesta la modificación de la
% base de datos. El problema es el de las jarras de jarras.pl.
%
%?- buscar_con_agenda(jarras(4, 3, 2), Plan).
%?- limpiar_agenda, buscar_con_agenda(jarras(4, 3, 1), Plan).

:- dynamic pendiente/1, visto/1.

% --- El problema de las jarras (jarras.pl) ----------------------------------

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es el estado de partida de Problema: las dos jarras vacías.
inicial(jarras(_, _, _), j(0, 0)).

%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es un estado buscado de Problema: una de las jarras tiene la
%   cantidad pedida.
meta(jarras(_, _, M), j(A, B)) :-
    (   A =:= M
    ->  true
    ;   B =:= M
    ).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Accion lleva de Estado a Siguiente y mueve Costo litros de agua.
sucesor(jarras(C1, _, _), j(A, B), llenar(1), j(C1, B), Costo) :-
    A < C1,
    Costo is C1 - A.
sucesor(jarras(_, C2, _), j(A, B), llenar(2), j(A, C2), Costo) :-
    B < C2,
    Costo is C2 - B.
sucesor(jarras(_, _, _), j(A, B), vaciar(1), j(0, B), A) :-
    A > 0.
sucesor(jarras(_, _, _), j(A, B), vaciar(2), j(A, 0), B) :-
    B > 0.
sucesor(jarras(_, C2, _), j(A, B), pasar(1, 2), j(A1, B1), Costo) :-
    Costo is min(A, C2 - B),
    Costo > 0,
    A1 is A - Costo,
    B1 is B + Costo.
sucesor(jarras(C1, _, _), j(A, B), pasar(2, 1), j(A1, B1), Costo) :-
    Costo is min(B, C1 - A),
    Costo > 0,
    A1 is A + Costo,
    B1 is B - Costo.

% --- La búsqueda con la agenda dinámica --------------------------------------

%!  buscar_con_agenda(+Problema, -Plan:list) is semidet.
%
%   Plan es una de las secuencias de acciones más cortas que llevan del
%   estado inicial de Problema a un estado meta. Deja en la base de datos
%   los hechos pendiente/1 y visto/1 de la búsqueda, y parte de los que dejó
%   la búsqueda anterior.
buscar_con_agenda(Problema, Plan) :-
    inicial(Problema, Estado),
    assertz(visto(Estado)),
    assertz(pendiente(nodo(Estado, []))),
    bucle_con_agenda(Problema, Camino),
    reverse(Camino, Plan).

%!  bucle_con_agenda(+Problema, -Camino:list) is semidet.
%
%   Saca el primer nodo de la agenda; si su estado es una meta, Camino es su
%   camino, y si no, agrega a la agenda sus hijos no vistos y sigue.
bucle_con_agenda(Problema, Camino) :-
    retract(pendiente(nodo(Estado, Camino0))),
    !,
    (   meta(Problema, Estado)
    ->  Camino = Camino0
    ;   forall(( sucesor(Problema, Estado, Accion, Siguiente, _),
                 \+ visto(Siguiente) ),
               ( assertz(visto(Siguiente)),
                 assertz(pendiente(nodo(Siguiente, [Accion|Camino0]))) )),
        bucle_con_agenda(Problema, Camino)
    ).

%!  limpiar_agenda is det.
%
%   Borra la agenda y los visitados. Cada búsqueda debería empezar por él,
%   y nada obliga a hacerlo.
limpiar_agenda :-
    retractall(pendiente(_)),
    retractall(visto(_)).
