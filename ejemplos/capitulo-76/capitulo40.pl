:- encoding(utf8).

% Capítulo 76 - Las búsquedas del capítulo 40, para problemas de otros
% módulos.
%
% puzzle8.pl y frontera.pl del capítulo 40 no son módulos: se cargan, sin
% copiarlos, dentro de los módulos capitulo40 y frontera40. Sus búsquedas
% llaman a inicial/2, meta/2, sucesor/5 y heuristica/3 con el problema como
% primer argumento; este archivo declara esos predicados multifile antes de
% cargarlos y les agrega una cláusula para los problemas escritos
% Modulo:Problema, que pasa la llamada al módulo que define el problema.
% Así cada problema del capítulo vive en su propio módulo y se resuelve con
% las búsquedas del capítulo 40 tal como están.
%
% buscar/5 es la búsqueda con registro de visitados de puzzle8.pl, con las
% estrategias anchura, mejor(costo), mejor(heuristica) y mejor(a_estrella);
% ida_estrella/4 es su IDA*. buscar_sin_visitados/5 es el bucle de
% frontera.pl, que no recuerda los estados vistos, con A* agregado.
%
% solo-local: carga archivos de otro capítulo, y SWISH no permite cargar
% otro archivo.
%
%?- buscar(anchura, capitulo40:puzzle([2,4,3,7,1,5,0,8,6], cero), P, C, K).

:- module(capitulo40,
          [ buscar/5,
            ida_estrella/4,
            buscar_sin_visitados/5
          ]).

:- multifile
    inicial/2,
    meta/2,
    sucesor/5,
    heuristica/3,
    frontera40:inicial/2,
    frontera40:meta/2,
    frontera40:sucesor/5,
    frontera40:prioridad/4.

:- load_files(capitulo40:'../capitulo-40/puzzle8', []).
:- load_files(frontera40:'../capitulo-40/frontera', []).

%!  inicial(+Problema, -Estado) is det.
%
%   Para Modulo:P, Estado es el estado inicial que Modulo da a P.
inicial(M:P, Estado) :-
    M:inicial(P, Estado).

%!  meta(+Problema, +Estado) is semidet.
%
%   Para Modulo:P, Estado es un estado meta de P según Modulo.
meta(M:P, Estado) :-
    M:meta(P, Estado).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Para Modulo:P, Accion lleva de Estado a Siguiente con Costo según Modulo.
sucesor(M:P, Estado, Accion, Siguiente, Costo) :-
    M:sucesor(P, Estado, Accion, Siguiente, Costo).

%!  heuristica(+Problema, +Estado, -H:number) is det.
%
%   Para Modulo:P, H es lo que Modulo estima que falta desde Estado.
heuristica(M:P, Estado, H) :-
    M:heuristica(P, Estado, H).

%!  frontera40:inicial(+Problema, -Estado) is det.
%
%   Lo mismo que inicial/2, para el bucle de frontera.pl.
frontera40:inicial(M:P, Estado) :-
    M:inicial(P, Estado).

%!  frontera40:meta(+Problema, +Estado) is semidet.
%
%   Lo mismo que meta/2, para el bucle de frontera.pl.
frontera40:meta(M:P, Estado) :-
    M:meta(P, Estado).

%!  frontera40:sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo)
%!      is nondet.
%
%   Lo mismo que sucesor/5, para el bucle de frontera.pl.
frontera40:sucesor(M:P, Estado, Accion, Siguiente, Costo) :-
    M:sucesor(P, Estado, Accion, Siguiente, Costo).

%!  frontera40:prioridad(+Criterio, +Problema, +Nodo, -F:number) is det.
%
%   Con a_estrella, F es el costo del camino de Nodo más lo que la
%   heurística de Problema estima que falta: A* en el bucle de frontera.pl,
%   que solo traía el costo uniforme.
frontera40:prioridad(a_estrella, M:P, nodo(Estado, _, G), F) :-
    M:heuristica(P, Estado, H),
    F is G + H.

%!  buscar_sin_visitados(+Estrategia, +Problema, -Plan:list, -Costo:number,
%!                       -Expandidos:integer) is semidet.
%
%   Como buscar/5, con el bucle de frontera.pl, que no recuerda los estados
%   ya vistos. Estrategia es anchura, mejor(costo) o mejor(a_estrella).
buscar_sin_visitados(Estrategia, Problema, Plan, Costo, Expandidos) :-
    frontera40:buscar(Estrategia, Problema, Plan, Costo, Expandidos).
