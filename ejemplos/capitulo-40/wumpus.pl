:- encoding(utf8).

% Capítulo 40 - La vuelta a casa del Wumpus.
%
% Después de encontrar el oro, el agente del capítulo 20 vuelve a la
% entrada, (1, 1), pasando solo por celdas ya establecidas como seguras. El
% problema vuelta(Desde, Seguras) lleva en el término la lista de esas
% celdas: las acciones mueven al agente a una celda vecina segura, con
% costo 1, y la heurística es la distancia en línea recta por la grilla (la
% distancia de Manhattan) a la entrada, que nunca estima de más. El bucle
% es el de puzzle8.pl, con A*. seguras/2 da las celdas seguras de dos
% cuevas: la del capítulo 20, tal como la deja la exploración del agente, y
% una más grande. primer_camino/2 es el camino en profundidad sin repetir
% celdas, como el de las soluciones del capítulo 20, para comparar.
%
%?- seguras(chica, S), buscar(mejor(a_estrella), vuelta(2-3, S), P, C, K).
%?- seguras(grande, S), primer_camino(vuelta(1-5, S), P), length(P, L).

:- use_module(library(heaps)).
:- use_module(library(assoc)).

% --- El problema --------------------------------------------------------------

%!  seguras(+Cueva, -Seguras:list) is det.
%
%   Seguras son las celdas X-Y establecidas como seguras en Cueva: en
%   chica, las que visitó el agente del capítulo 20 hasta encontrar el oro;
%   en grande, las de una cueva de 5 x 5 con cinco celdas desconocidas.
seguras(chica, [1-1, 1-2, 2-1, 2-2, 2-3, 3-2]).
seguras(grande, Seguras) :-
    findall(X-Y,
            ( between(1, 5, X),
              between(1, 5, Y),
              \+ memberchk(X-Y, [2-2, 2-3, 2-4, 4-2, 4-3]) ),
            Seguras).

%!  inicial(+Problema, -Celda) is det.
%
%   Celda es donde está el agente al empezar la vuelta.
inicial(vuelta(Desde, _), Desde).

%!  meta(+Problema, +Celda) is semidet.
%
%   Celda es la entrada de la cueva.
meta(vuelta(_, _), 1-1).

%!  sucesor(+Problema, +Celda, -Accion, -Siguiente, -Costo) is nondet.
%
%   Accion lleva al agente de Celda a Siguiente, una celda vecina segura,
%   con costo 1. Las vecinas se prueban en el orden del capítulo 20.
sucesor(vuelta(_, Seguras), X-Y, ir(Siguiente), Siguiente, 1) :-
    member(DX-DY, [1-0, -1-0, 0-1, 0-(-1)]),
    VX is X + DX,
    VY is Y + DY,
    Siguiente = VX-VY,
    memberchk(Siguiente, Seguras).

%!  heuristica(+Problema, +Celda, -H:integer) is det.
%
%   H es la distancia de Manhattan de Celda a la entrada.
heuristica(vuelta(_, _), X-Y, H) :-
    H is X - 1 + Y - 1.

% --- La búsqueda con visitados ---------------------------------------------

%!  buscar(+Estrategia, +Problema, -Plan:list, -Costo:number,
%!         -Expandidos:integer) is semidet.
%
%   Plan lleva del estado inicial de Problema a un estado meta con costo
%   Costo; Expandidos es la cantidad de nodos que la búsqueda expandió.
%   Estrategia es profundidad, anchura o mejor(Criterio), con Criterio
%   costo, heuristica o a_estrella. Falla si la frontera se vacía sin llegar
%   a una meta.
buscar(Estrategia, Problema, Plan, Costo, Expandidos) :-
    inicial(Problema, Estado),
    frontera_inicial(Estrategia, Problema, nodo(Estado, [], 0), Frontera),
    list_to_assoc([Estado-0], Vistos),
    bucle(Estrategia, Problema, Frontera, Vistos, 0, nodo(_, Camino, Costo),
          Expandidos),
    reverse(Camino, Plan).

%!  bucle(+Estrategia, +Problema, +Frontera, +Vistos, +K0:integer,
%!        -Solucion, -K:integer) is semidet.
%
%   Solucion es el primer nodo meta que se extrae de Frontera; Vistos da, para
%   cada estado visto, el menor costo con que se llegó a él; K es K0 más la
%   cantidad de nodos expandidos hasta sacar Solucion.
bucle(Estrategia, Problema, Frontera0, Vistos0, K0, Solucion, K) :-
    sacar(Estrategia, Frontera0, Nodo, Frontera1),
    Nodo = nodo(Estado, _, G),
    (   get_assoc(Estado, Vistos0, Mejor),
        G > Mejor
    ->  bucle(Estrategia, Problema, Frontera1, Vistos0, K0, Solucion, K)
    ;   meta(Problema, Estado)
    ->  Solucion = Nodo,
        K = K0
    ;   K1 is K0 + 1,
        hijos(Problema, Nodo, Hijos0),
        nuevos(Hijos0, Vistos0, Hijos, Vistos1),
        agregar(Estrategia, Problema, Hijos, Frontera1, Frontera2),
        bucle(Estrategia, Problema, Frontera2, Vistos1, K1, Solucion, K)
    ).

%!  nuevos(+Hijos0:list, +Vistos0, -Hijos:list, -Vistos) is det.
%
%   Hijos son los nodos de Hijos0 cuyo estado no se vio, o se vio con un
%   costo mayor; Vistos es Vistos0 con el costo de cada uno.
nuevos([], Vistos, [], Vistos).
nuevos([Hijo|Hijos0], Vistos0, Hijos, Vistos) :-
    Hijo = nodo(Estado, _, G),
    (   get_assoc(Estado, Vistos0, G0),
        G0 =< G
    ->  Hijos = Hijos1,
        Vistos1 = Vistos0
    ;   put_assoc(Estado, Vistos0, G, Vistos1),
        Hijos = [Hijo|Hijos1]
    ),
    nuevos(Hijos0, Vistos1, Hijos1, Vistos).

%!  hijos(+Problema, +Nodo, -Hijos:list) is det.
%
%   Hijos son los nodos de los estados que siguen al de Nodo, cada uno con
%   su camino y su costo. findall/3 reúne solo las transiciones: el camino
%   de cada hijo se arma afuera, y comparte el de Nodo en lugar de copiarlo.
hijos(Problema, nodo(Estado, Camino, G), Hijos) :-
    findall(t(Accion, Siguiente, Costo),
            sucesor(Problema, Estado, Accion, Siguiente, Costo),
            Transiciones),
    maplist(hijo(Camino, G), Transiciones, Hijos).

%!  hijo(+Camino:list, +G:number, +Transicion, -Hijo) is det.
%
%   Hijo es el nodo al que lleva Transicion desde un nodo con Camino y G.
hijo(Camino, G, t(Accion, Siguiente, Costo),
     nodo(Siguiente, [Accion|Camino], G1)) :-
    G1 is G + Costo.

% --- Las fronteras ------------------------------------------------------------

%!  frontera_inicial(+Estrategia, +Problema, +Nodo, -Frontera) is det.
%
%   Frontera tiene solo a Nodo, con la estructura de datos de Estrategia.
frontera_inicial(Estrategia, Problema, Nodo, Frontera) :-
    vacia(Estrategia, Vacia),
    agregar(Estrategia, Problema, [Nodo], Vacia, Frontera).

%!  vacia(+Estrategia, -Frontera) is det.
%
%   Frontera es la frontera vacía de Estrategia: una pila, una cola o un
%   montículo.
vacia(profundidad, []).
vacia(anchura, cola(0, F, F)).
vacia(mejor(_), Monticulo) :-
    empty_heap(Monticulo).

%!  sacar(+Estrategia, +Frontera0, -Nodo, -Frontera) is semidet.
%
%   Nodo es el próximo nodo de Frontera0 según Estrategia, y Frontera lo
%   que queda. Falla si Frontera0 está vacía.
sacar(profundidad, [Nodo|Pila], Nodo, Pila).
sacar(anchura, Cola0, Nodo, Cola) :-
    desencolar(Nodo, Cola0, Cola).
sacar(mejor(_), Monticulo0, Nodo, Monticulo) :-
    get_from_heap(Monticulo0, _, Nodo, Monticulo).

%!  agregar(+Estrategia, +Problema, +Nodos:list, +Frontera0, -Frontera)
%!      is det.
%
%   Frontera es Frontera0 con Nodos agregados según Estrategia.
agregar(profundidad, _, Nodos, Pila0, Pila) :-
    append(Nodos, Pila0, Pila).
agregar(anchura, _, Nodos, Cola0, Cola) :-
    foldl(encolar, Nodos, Cola0, Cola).
agregar(mejor(Criterio), Problema, Nodos, Monticulo0, Monticulo) :-
    foldl(al_monticulo(Criterio, Problema), Nodos, Monticulo0, Monticulo).

%!  al_monticulo(+Criterio, +Problema, +Nodo, +Monticulo0, -Monticulo)
%!      is det.
%
%   Monticulo es Monticulo0 con Nodo, con la prioridad que le da Criterio.
al_monticulo(Criterio, Problema, Nodo, Monticulo0, Monticulo) :-
    prioridad(Criterio, Problema, Nodo, Prioridad),
    add_to_heap(Monticulo0, Prioridad, Nodo, Monticulo).

%!  prioridad(+Criterio, +Problema, +Nodo, -Prioridad:number) is det.
%
%   Prioridad es el valor de Nodo según Criterio; se extrae primero el menor.
%   Con costo, es el costo del camino: la búsqueda de costo uniforme; con
%   heuristica, lo que la heurística estima que falta: la búsqueda voraz;
%   con a_estrella, la suma de los dos: A*.
prioridad(costo, _, nodo(_, _, G), G).
prioridad(heuristica, Problema, nodo(Estado, _, _), H) :-
    heuristica(Problema, Estado, H).
prioridad(a_estrella, Problema, nodo(Estado, _, G), F) :-
    heuristica(Problema, Estado, H),
    F is G + H.

%!  encolar(+X, +Cola0, -Cola) is det.
%
%   Cola es Cola0 con X al final: la cola con contador del capítulo 34.
encolar(X, cola(N, Frente, [X|Fondo]), cola(N1, Frente, Fondo)) :-
    N1 is N + 1.

%!  desencolar(-X, +Cola0, -Cola) is semidet.
%
%   X es el primero de Cola0, y Cola el resto. Falla si Cola0 está vacía.
desencolar(X, cola(N, [X|Frente], Fondo), cola(N1, Frente, Fondo)) :-
    N > 0,
    N1 is N - 1.



% --- El primer camino en profundidad -----------------------------------------

%!  primer_camino(+Problema, -Plan:list) is semidet.
%
%   Plan es el primer plan que encuentra la búsqueda en profundidad sin
%   repetir celdas: no es necesariamente el más corto.
primer_camino(Problema, Plan) :-
    inicial(Problema, Celda),
    once(sin_ciclos(Problema, Celda, [Celda], Plan)).

%!  sin_ciclos(+Problema, +Celda, +Rastro:list, -Plan:list) is nondet.
%
%   Plan lleva de Celda a la entrada sin pasar por las celdas de Rastro.
sin_ciclos(Problema, Celda, _, []) :-
    meta(Problema, Celda).
sin_ciclos(Problema, Celda, Rastro, [Accion|Plan]) :-
    sucesor(Problema, Celda, Accion, Siguiente, _),
    \+ memberchk(Siguiente, Rastro),
    sin_ciclos(Problema, Siguiente, [Siguiente|Rastro], Plan).
