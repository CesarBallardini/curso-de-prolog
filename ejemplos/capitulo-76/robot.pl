:- encoding(utf8).

% Capítulo 76 - Versiones 2 y 3: el robot en el plano, con las búsquedas
% del capítulo 40.
%
% El problema ruta(Plano, Desde, Hasta, Heuristica) lleva al robot por las
% celdas libres de un plano de plano.pl. Un estado es la celda del robot,
% cada paso a una celda vecina cuesta 1 y la heurística es cero o
% manhattan, la distancia contando solo movimientos horizontales y
% verticales, que nunca estima de más. Las acciones de los planes son las
% celdas a las que va el robot, así que un plan es el camino sin su celda
% de partida.
%
% camino/7 resuelve el problema con la búsqueda con visitados del capítulo
% 40; camino_sin_visitados/6, con el bucle que no los recuerda, y
% camino_ida/6, con IDA*.
%
% solo-local: carga plano.pl y las búsquedas del capítulo 40.
%
%?- camino(taller, a_estrella, 1-4, 20-6, Camino, Pasos, K).
%?- camino_ida(patio, 28-8, 32-8, Camino, Pasos, K).

:- module(robot,
          [ camino/7,
            camino_sin_visitados/6,
            camino_ida/6,
            manhattan/3
          ]).

:- reexport(plano).
:- use_module(capitulo40).

% --- El problema ------------------------------------------------------------

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es la celda de partida.
inicial(ruta(_, Desde, _, _), Desde).

%!  meta(+Problema, +Estado) is semidet.
%
%   El robot está en la celda de llegada.
meta(ruta(_, _, Hasta, _), Hasta).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   El robot pasa a una celda vecina libre, que es también la Accion, con
%   costo 1.
sucesor(ruta(Plano, _, _, _), Celda, Vecina, Vecina, 1) :-
    vecina(Plano, Celda, _, Vecina).

%!  heuristica(+Problema, +Estado, -H:integer) is det.
%
%   H estima la cantidad de pasos que faltan; nunca estima de más.
heuristica(ruta(_, _, _, cero), _, 0).
heuristica(ruta(_, _, Hasta, manhattan), Celda, H) :-
    manhattan(Celda, Hasta, H).

%!  manhattan(+A, +B, -D:integer) is det.
%
%   D es la distancia entre las celdas A y B contando solo movimientos
%   horizontales y verticales.
manhattan(X1-Y1, X2-Y2, D) :-
    D is abs(X1 - X2) + abs(Y1 - Y2).

% --- Las consultas ----------------------------------------------------------

%!  camino(+Plano, +Estrategia, +Desde, +Hasta, -Camino:list,
%!         -Pasos:integer, -Expandidos:integer) is semidet.
%
%   Camino va de Desde a Hasta por celdas libres de Plano, con Pasos pasos,
%   hallado con buscar/5 del capítulo 40. Estrategia es anchura,
%   costo_uniforme, voraz o a_estrella; las dos últimas usan manhattan.
%   Falla si no hay camino.
camino(Plano, Estrategia, Desde, Hasta, [Desde|Plan], Pasos, Expandidos) :-
    estrategia(Estrategia, E, H),
    buscar(E, robot:ruta(Plano, Desde, Hasta, H), Plan, Pasos, Expandidos).

% estrategia(Nombre, Estrategia, Heuristica): la estrategia de buscar/5 y
% la heurística del problema que corresponden a Nombre.
estrategia(anchura, anchura, cero).
estrategia(costo_uniforme, mejor(costo), cero).
estrategia(voraz, mejor(heuristica), manhattan).
estrategia(a_estrella, mejor(a_estrella), manhattan).

%!  camino_sin_visitados(+Plano, +Desde, +Hasta, -Camino:list,
%!                       -Pasos:integer, -Expandidos:integer) is semidet.
%
%   Como camino/7 con a_estrella, pero con el bucle que no recuerda los
%   estados vistos.
camino_sin_visitados(Plano, Desde, Hasta, [Desde|Plan], Pasos, Expandidos) :-
    buscar_sin_visitados(mejor(a_estrella),
                         robot:ruta(Plano, Desde, Hasta, manhattan),
                         Plan, Pasos, Expandidos).

%!  camino_ida(+Plano, +Desde, +Hasta, -Camino:list, -Pasos:integer,
%!             -Expandidos:integer) is semidet.
%
%   Como camino/7 con a_estrella, pero con el IDA* del capítulo 40.
camino_ida(Plano, Desde, Hasta, [Desde|Plan], Pasos, Expandidos) :-
    ida_estrella(robot:ruta(Plano, Desde, Hasta, manhattan), Plan, Pasos,
                 Expandidos).
