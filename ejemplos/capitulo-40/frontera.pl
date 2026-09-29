:- encoding(utf8).

% Capítulo 40 - Una sola búsqueda, varias estrategias.
%
% buscar/5 es un solo bucle: saca un nodo de la frontera, termina si su
% estado es una meta, y si no agrega sus hijos a la frontera. La estrategia
% es la estructura de datos de la frontera: una pila (en profundidad), una
% cola con contador y lista diferencia del capítulo 34 (en anchura), o un
% montículo de library(heaps), del que se extrae primero el nodo de menor
% prioridad (mejor primero; con mejor(costo), la prioridad es el costo
% acumulado: la búsqueda de costo uniforme). Un nodo es
% nodo(Estado, Camino, G): Camino tiene las acciones que llevaron a Estado,
% la última primero, y G es su costo. El problema es el de las jarras de
% jarras.pl, repetido para que el archivo se cargue solo. Todavía no se
% recuerdan los estados visitados: en profundidad, la búsqueda no termina.
%
%?- buscar(anchura, jarras(4, 3, 2), Plan, Costo, Expandidos).
%?- buscar(mejor(costo), jarras(4, 3, 2), Plan, Costo, Expandidos).

:- use_module(library(heaps)).

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

% --- La búsqueda --------------------------------------------------------------

%!  buscar(+Estrategia, +Problema, -Plan:list, -Costo:number,
%!         -Expandidos:integer) is semidet.
%
%   Plan lleva del estado inicial de Problema a un estado meta con costo
%   Costo; Expandidos es la cantidad de nodos que la búsqueda expandió.
%   Estrategia es profundidad, anchura o mejor(costo). Falla si la
%   frontera se vacía sin llegar a una meta.
buscar(Estrategia, Problema, Plan, Costo, Expandidos) :-
    inicial(Problema, Estado),
    frontera_inicial(Estrategia, Problema, nodo(Estado, [], 0), Frontera),
    bucle(Estrategia, Problema, Frontera, 0, nodo(_, Camino, Costo),
          Expandidos),
    reverse(Camino, Plan).

%!  bucle(+Estrategia, +Problema, +Frontera, +K0:integer, -Solucion,
%!        -K:integer) is semidet.
%
%   Solucion es el primer nodo meta que se extrae de Frontera; K es K0 más la
%   cantidad de nodos expandidos hasta sacarlo.
bucle(Estrategia, Problema, Frontera0, K0, Solucion, K) :-
    sacar(Estrategia, Frontera0, Nodo, Frontera1),
    Nodo = nodo(Estado, _, _),
    (   meta(Problema, Estado)
    ->  Solucion = Nodo,
        K = K0
    ;   K1 is K0 + 1,
        hijos(Problema, Nodo, Hijos),
        agregar(Estrategia, Problema, Hijos, Frontera1, Frontera2),
        bucle(Estrategia, Problema, Frontera2, K1, Solucion, K)
    ).

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
%   Con costo, es el costo del camino: la búsqueda de costo uniforme.
prioridad(costo, _, nodo(_, _, G), G).

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
