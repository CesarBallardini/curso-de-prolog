:- encoding(utf8).

% Capítulo 74 - Versión 3: el cubo como espacio de estados.
%
% Las búsquedas del capítulo 40 resuelven el cubo sin saber nada de él: el
% estado es el término c/54 y cada acción es un cuarto de vuelta.
% capitulo40.pl las carga, y este archivo mide cuánto cuestan. capas/2
% cuenta los estados distintos a cada distancia del cubo resuelto,
% generando cada capa desde la anterior y quitando los repetidos con
% sort/2. estados/1 calcula cuántos estados tiene el cubo entero.
%
% solo-local: carga vista.pl y capitulo40.pl.
%
%?- capas(3, Cuantos).
%?- estados(N).
%?- medir(profundizando, 5, 5, Largo, Inferencias).

:- ensure_loaded(vista).
:- use_module(capitulo40).

%!  capas(+D:integer, -Cuantos:list(integer)) is det.
%
%   Cuantos da, para cada distancia de 0 a D, la cantidad de estados a los
%   que se llega desde el cubo resuelto con esa cantidad mínima de cuartos
%   de vuelta.
capas(D, Cuantos) :-
    resuelto(C),
    capas(D, [], [C], Cuantos).

%!  capas(+D:integer, +Anterior:list, +Actual:list, -Cuantos:list) is det.
%
%   Cuantos cuenta Actual, la capa de una distancia, y las D capas que
%   siguen; Anterior es la capa de la distancia anterior. Un estado de la
%   capa siguiente es sucesor de uno de Actual y no está en Actual ni en
%   Anterior: todo cuarto de vuelta tiene inverso, y un sucesor está a lo
%   sumo una capa más atrás.
capas(0, _, Actual, [N]) :-
    !,
    length(Actual, N).
capas(D, Anterior, Actual, [N|Cuantos]) :-
    length(Actual, N),
    findall(C1, ( member(C, Actual), cuarto_de_vuelta(M), mover(M, C, C1) ),
            Sucesores0),
    sort(Sucesores0, Sucesores),
    ord_subtract(Sucesores, Actual, Sucesores1),
    ord_subtract(Sucesores1, Anterior, Siguiente),
    D1 is D - 1,
    capas(D1, Actual, Siguiente, Cuantos).

%!  estados(-N:integer) is det.
%
%   N es la cantidad de estados del cubo: las esquinas en cualquier orden
%   (8!) con cualquier orientación salvo la última, que queda determinada
%   (3^7); las aristas igual (12! y 2^11); y la mitad de esas
%   combinaciones, porque las dos permutaciones tienen la misma paridad.
estados(N) :-
    N is 40320 * 3^7 * 479001600 * 2^11 // 2.

%!  medir(+Busqueda, +Semilla:integer, +Largo:integer, -Solucion:integer,
%!        -Inferencias:integer) is det.
%
%   Busqueda, profundizando o en_anchura, resuelve la mezcla de Largo
%   giros de Semilla con una secuencia de Solucion giros y Inferencias
%   inferencias.
medir(Busqueda, Semilla, Largo, Solucion, Inferencias) :-
    mezcla(Semilla, Largo, Ms),
    resuelto(C),
    aplicar(Ms, C, C1),
    statistics(inferences, I0),
    resolver_con(Busqueda, C1, Plan),
    statistics(inferences, I1),
    Inferencias is I1 - I0,
    length(Plan, Solucion).

%!  resolver_con(+Busqueda, +Cubo, -Plan:list) is semidet.
%
%   Plan resuelve Cubo con la búsqueda Busqueda del capítulo 40.
resolver_con(profundizando, Cubo, Plan) :-
    profundizando(Cubo, Plan).
resolver_con(en_anchura, Cubo, Plan) :-
    en_anchura(Cubo, Plan, _).
