:- encoding(utf8).

:- begin_tests(agenda_dinamica, [setup(limpiar_agenda),
                                 cleanup(limpiar_agenda)]).

test(primera_vez, [setup(limpiar_agenda),
                   true(P == [llenar(2), pasar(2, 1), llenar(2),
                              pasar(2, 1)])]) :-
    buscar_con_agenda(jarras(4, 3, 2), P).

% La agenda queda cargada: la segunda búsqueda sigue con los nodos de la
% primera, y da un plan que no es el más corto.
test(segunda_vez, [setup(limpiar_agenda), true(L == 6)]) :-
    buscar_con_agenda(jarras(4, 3, 2), _),
    buscar_con_agenda(jarras(4, 3, 2), P),
    length(P, L).

% El nodo que quedó en la agenda responde otro problema con un plan de
% cinco acciones, cuando hay uno de dos.
test(otro_problema, [setup(limpiar_agenda),
                     true(P == [llenar(1), pasar(1, 2), vaciar(2),
                                pasar(1, 2), llenar(1)])]) :-
    buscar_con_agenda(jarras(4, 3, 2), _),
    buscar_con_agenda(jarras(4, 3, 1), P).

% Después de dos búsquedas, los visitados hacen fallar una que tiene
% solución.
test(tercera_vez, [setup(limpiar_agenda), fail]) :-
    buscar_con_agenda(jarras(4, 3, 2), _),
    buscar_con_agenda(jarras(4, 3, 2), _),
    buscar_con_agenda(jarras(4, 3, 1), _).

test(limpiando, [setup(limpiar_agenda),
                 true(P == [llenar(1), pasar(1, 2)])]) :-
    buscar_con_agenda(jarras(4, 3, 2), _),
    limpiar_agenda,
    buscar_con_agenda(jarras(4, 3, 1), P).

:- end_tests(agenda_dinamica).
