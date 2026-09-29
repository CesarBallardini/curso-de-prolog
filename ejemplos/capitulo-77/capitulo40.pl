:- encoding(utf8).

% Capítulo 77 - La vuelta a casa con A*, del capítulo 40, en un módulo.
%
% wumpus.pl del capítulo 40 no es un módulo: se carga con load_files/2 y
% el nombre de un módulo delante del archivo, sin copiarlo. Su problema
% vuelta(Desde, Seguras) lleva al agente a la entrada, (1, 1), pasando solo
% por las celdas de Seguras; buscar/5, con la estrategia
% mejor(a_estrella), da el camino más corto.
%
% solo-local: carga un archivo de otro capítulo, y SWISH no permite cargar
% otro archivo.
%
%?- vuelta(2-3, [1-1, 1-2, 2-1, 2-2, 2-3, 3-2], Plan, Costo, K).

:- module(capitulo40,
          [ vuelta/5
          ]).

:- load_files(capitulo40:'../capitulo-40/wumpus', []).

%!  vuelta(+Desde, +Seguras:list, -Plan:list, -Costo:integer,
%!         -Expandidos:integer) is semidet.
%
%   Plan es el camino más corto de Desde a (1, 1) por las celdas de Seguras,
%   hallado con el A* del capítulo 40: una lista de acciones ir(Celda).
%   Costo es su longitud y Expandidos, los nodos que expandió la búsqueda.
%   Falla si no hay camino.
vuelta(Desde, Seguras, Plan, Costo, Expandidos) :-
    buscar(mejor(a_estrella), vuelta(Desde, Seguras), Plan, Costo,
           Expandidos).
