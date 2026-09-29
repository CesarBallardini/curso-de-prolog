:- encoding(utf8).

% Capítulo 40 - Profundidad limitada y profundización iterativa.
%
% con_limite/3 busca en profundidad, con la recursión de Prolog, planes de a
% lo sumo Limite acciones: termina siempre, aunque el espacio tenga ciclos,
% pero no encuentra los planes más largos que el límite. iterativo/2 fija la
% longitud del plan con length/2 antes de buscar, y length/2 con la lista
% libre da longitudes 0, 1, 2, ...: el primer plan es uno de los más cortos,
% como en anchura, y la memoria es la de un solo camino, como en
% profundidad. El problema es el de las jarras de jarras.pl.
%
%?- con_limite(jarras(4, 3, 2), 5, Plan).
%?- iterativo(jarras(4, 3, 2), Plan).

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

% --- Profundidad limitada -----------------------------------------------------

%!  con_limite(+Problema, +Limite:integer, -Plan:list) is nondet.
%
%   Plan lleva del estado inicial de Problema a un estado meta con a lo sumo
%   Limite acciones.
con_limite(Problema, Limite, Plan) :-
    inicial(Problema, Estado),
    hasta(Problema, Estado, Limite, Plan).

%!  hasta(+Problema, +Estado, +Limite:integer, -Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado meta con a lo sumo Limite acciones.
hasta(Problema, Estado, _, []) :-
    meta(Problema, Estado).
hasta(Problema, Estado, Limite, [Accion|Plan]) :-
    Limite > 0,
    Limite1 is Limite - 1,
    sucesor(Problema, Estado, Accion, Siguiente, _),
    hasta(Problema, Siguiente, Limite1, Plan).

% --- Profundización iterativa -------------------------------------------------

%!  iterativo(+Problema, -Plan:list) is nondet.
%
%   Plan lleva del estado inicial de Problema a un estado meta. Los planes
%   se obtienen de menor a mayor longitud, y el primero es uno de los más
%   cortos. Si Problema no tiene solución, no termina; después de la última
%   respuesta, tampoco.
iterativo(Problema, Plan) :-
    inicial(Problema, Estado),
    length(Plan, _),
    desde(Problema, Estado, Plan).

%!  desde(+Problema, +Estado, ?Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado meta de Problema. Con la longitud de
%   Plan fijada, termina.
desde(Problema, Estado, []) :-
    meta(Problema, Estado).
desde(Problema, Estado, [Accion|Plan]) :-
    sucesor(Problema, Estado, Accion, Siguiente, _),
    desde(Problema, Siguiente, Plan).
