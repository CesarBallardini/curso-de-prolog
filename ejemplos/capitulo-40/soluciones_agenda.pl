:- encoding(utf8).

% Capítulo 40 - Solución del ejercicio 6: la agenda dinámica, borrada al
% empezar y al terminar.
%
% buscar_limpio/2 envuelve buscar_con_agenda/2 en setup_call_cleanup/3:
% borra la agenda antes, y después, también si la búsqueda falla o lanza
% una excepción. Dos búsquedas seguidas ya no se estorban, pero una búsqueda
% dentro de otra sí: el problema prudente(J) solo acepta los estados desde
% los que hay un plan, y lo averigua con otra búsqueda, que borra la agenda
% de la búsqueda de afuera.
%
% solo-local: incluye agenda_dinamica.pl con include/1, y SWISH no permite
% cargar otro archivo.
%
%?- buscar_limpio(jarras(4, 3, 2), _), buscar_limpio(jarras(4, 3, 1), P).
%?- buscar_limpio(jarras(4, 2, 1), P).

:- discontiguous inicial/2, meta/2, sucesor/5.

:- include(agenda_dinamica).

%!  buscar_limpio(+Problema, -Plan:list) is semidet.
%
%   Como buscar_con_agenda/2, con la agenda vacía al empezar y al terminar.
buscar_limpio(Problema, Plan) :-
    setup_call_cleanup(limpiar_agenda,
                       buscar_con_agenda(Problema, Plan),
                       limpiar_agenda).

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es el estado de partida de Problema. desde(E, J) es el problema
%   J con E como estado inicial.
inicial(desde(Estado, _), Estado).

%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es un estado buscado de Problema: en desde(E, J), uno de J.
meta(desde(_, J), Estado) :-
    meta(J, Estado).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Accion lleva de Estado a Siguiente con Costo: en desde(E, J), como en J.
sucesor(desde(_, J), Estado, Accion, Siguiente, Costo) :-
    sucesor(J, Estado, Accion, Siguiente, Costo).

% prudente(J): el problema J, sin los estados desde los que no hay plan.
inicial(prudente(J), Estado) :-
    inicial(J, Estado).
meta(prudente(J), Estado) :-
    meta(J, Estado).
sucesor(prudente(J), Estado, Accion, Siguiente, Costo) :-
    sucesor(J, Estado, Accion, Siguiente, Costo),
    buscar_limpio(desde(Siguiente, J), _).
