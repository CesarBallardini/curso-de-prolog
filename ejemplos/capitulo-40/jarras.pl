:- encoding(utf8).

% Capítulo 40 - El problema como interfaz: las jarras.
%
% Un problema de búsqueda se describe con tres predicados cuyo primer
% argumento es el problema: inicial/2, el estado de partida; meta/2, los
% estados buscados; y sucesor/5, las acciones, con el estado al que llevan y
% su costo. El problema jarras(C1, C2, M) tiene dos jarras sin marcas, de C1
% y C2 litros, una canilla y un desagüe; se busca que una de las jarras
% tenga M litros. El costo de una acción son los litros de agua que mueve.
% resolver_ingenuo/2 busca en profundidad con la recursión de Prolog, y no
% termina: vuelve una y otra vez a los mismos estados.
%
%?- inicial(jarras(4, 3, 2), E), sucesor(jarras(4, 3, 2), E, A, E1, C).
%?- call_with_inference_limit(resolver_ingenuo(jarras(4, 3, 2), P), 100000, R).

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
%   Accion lleva de Estado a Siguiente y mueve Costo litros de agua. Solo
%   se consideran las acciones que cambian el estado: llenar una jarra que
%   no está llena, vaciar una que no está vacía, o pasar agua de una a la
%   otra hasta que la primera se vacíe o la segunda se llene.
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

%!  resolver_ingenuo(+Problema, -Plan:list) is nondet.
%
%   Plan es una secuencia de acciones que lleva del estado inicial de
%   Problema a un estado meta. Busca en profundidad sin recordar los estados
%   por los que pasó: en un problema con ciclos, como las jarras, no
%   termina.
resolver_ingenuo(Problema, Plan) :-
    inicial(Problema, Estado),
    desde(Problema, Estado, Plan).

%!  desde(+Problema, +Estado, -Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado meta de Problema.
desde(Problema, Estado, []) :-
    meta(Problema, Estado).
desde(Problema, Estado, [Accion|Plan]) :-
    sucesor(Problema, Estado, Accion, Siguiente, _),
    desde(Problema, Siguiente, Plan).
