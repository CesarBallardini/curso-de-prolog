:- encoding(utf8).

% Capítulo 40 - Soluciones de los ejercicios 3, 4, 5, 7 y 8.
%
% El archivo repite el bucle con visitados de visitados.pl, con una
% estrategia más, anchura_lista (ejercicio 5), y el problema de las jarras,
% para cargarse solo. Los problemas nuevos son rio (ejercicio 3) y
% misioneros (ejercicio 4). recorrido_caballo/2 (ejercicio 7) usa la lista
% de las casillas que quedan, y mas_cortos/2 (ejercicio 8) la idea de
% iterativo/2.
%
%?- buscar(anchura, rio, Plan, Costo, Expandidos).
%?- buscar(anchura, misioneros, Plan, Costo, Expandidos).
%?- recorrido_caballo(5, R).
%?- mas_cortos(jarras(4, 3, 2), Planes).

:- use_module(library(heaps)).
:- use_module(library(assoc)).

% --- Ejercicio 3: el granjero, el lobo, la cabra y la col --------------------

% Un estado del río es r(G, L, C, K): la orilla, i o d, del granjero, el
% lobo, la cabra y la col.

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es el estado de partida de Problema.
inicial(rio, r(i, i, i, i)).
inicial(misioneros, m(3, 3, i)).
inicial(jarras(_, _, _), j(0, 0)).

%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es un estado buscado de Problema.
meta(rio, r(d, d, d, d)).
meta(misioneros, m(0, 0, d)).
meta(jarras(_, _, M), j(A, B)) :-
    (   A =:= M
    ->  true
    ;   B =:= M
    ).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Accion lleva de Estado a Siguiente con costo Costo.
sucesor(rio, r(G, L, C, K), cruzar(Quien), Siguiente, 1) :-
    otra(G, G1),
    pasajero(Quien, r(G, L, C, K), G1, Siguiente),
    segura(Siguiente).
sucesor(misioneros, m(M, C, B), cruzan(DM, DC), m(M1, C1, B1), 1) :-
    member(DM-DC, [1-0, 2-0, 0-1, 0-2, 1-1]),
    (   B == i
    ->  M1 is M - DM,
        C1 is C - DC,
        B1 = d
    ;   M1 is M + DM,
        C1 is C + DC,
        B1 = i
    ),
    between(0, 3, M1),
    between(0, 3, C1),
    a_salvo(M1, C1),
    M2 is 3 - M1,
    C2 is 3 - C1,
    a_salvo(M2, C2).
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

% otra(O1, O2): O2 es la orilla opuesta a O1.
otra(i, d).
otra(d, i).

%!  pasajero(?Quien, +Estado, +Orilla, -Siguiente) is nondet.
%
%   El granjero cruza a Orilla, solo o con Quien, que estaba en su misma
%   orilla, y el río queda en Siguiente.
pasajero(solo, r(_, L, C, K), G1, r(G1, L, C, K)).
pasajero(lobo, r(G, G, C, K), G1, r(G1, G1, C, K)).
pasajero(cabra, r(G, L, G, K), G1, r(G1, L, G1, K)).
pasajero(col, r(G, L, C, G), G1, r(G1, L, C, G1)).

%!  segura(+Estado) is semidet.
%
%   En Estado, la cabra no queda sin el granjero con el lobo ni con la col.
segura(r(G, L, C, K)) :-
    \+ ( C == L, C \== G ),
    \+ ( C == K, C \== G ).

% --- Ejercicio 4: misioneros y caníbales -------------------------------------

% Un estado es m(M, C, B): los misioneros y los caníbales en la orilla de
% partida, y la orilla del bote.

%!  a_salvo(+M:integer, +C:integer) is semidet.
%
%   En una orilla con M misioneros y C caníbales, los caníbales no superan
%   a los misioneros, o no hay misioneros.
a_salvo(M, C) :-
    (   M =:= 0
    ->  true
    ;   M >= C
    ).

% --- La búsqueda con visitados ---------------------------------------------

%!  buscar(+Estrategia, +Problema, -Plan:list, -Costo:number,
%!         -Expandidos:integer) is semidet.
%
%   Plan lleva del estado inicial de Problema a un estado meta con costo
%   Costo; Expandidos es la cantidad de nodos que la búsqueda expandió.
%   Estrategia es profundidad, anchura, anchura_lista (ejercicio 5: la
%   cola como lista cerrada) o mejor(costo). Falla si la frontera se vacía
%   sin llegar a una meta.
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
vacia(anchura_lista, []).
vacia(mejor(_), Monticulo) :-
    empty_heap(Monticulo).

%!  sacar(+Estrategia, +Frontera0, -Nodo, -Frontera) is semidet.
%
%   Nodo es el próximo nodo de Frontera0 según Estrategia, y Frontera lo
%   que queda. Falla si Frontera0 está vacía.
sacar(profundidad, [Nodo|Pila], Nodo, Pila).
sacar(anchura, Cola0, Nodo, Cola) :-
    desencolar(Nodo, Cola0, Cola).
sacar(anchura_lista, [Nodo|Cola], Nodo, Cola).
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
agregar(anchura_lista, _, Nodos, Cola0, Cola) :-
    append(Cola0, Nodos, Cola).
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


% --- Ejercicio 7: el recorrido del caballo ------------------------------------

%!  recorrido_caballo(+N:integer, -Recorrido:list) is nondet.
%
%   Recorrido es un recorrido del caballo por un tablero de N x N que
%   empieza en 1-1 y pasa una vez por cada casilla.
recorrido_caballo(N, [1-1|Recorrido]) :-
    findall(F-C, ( between(1, N, F), between(1, N, C) ), Casillas),
    selectchk(1-1, Casillas, Libres),
    saltar(1-1, Libres, Recorrido).

%!  saltar(+Casilla, +Libres:list, -Recorrido:list) is nondet.
%
%   Recorrido pasa una vez por cada casilla de Libres, empezando con un
%   salto desde Casilla.
saltar(_, [], []).
saltar(Casilla, Libres, [Siguiente|Recorrido]) :-
    salto(Casilla, Siguiente),
    select(Siguiente, Libres, Libres1),
    saltar(Siguiente, Libres1, Recorrido).

%!  salto(+Casilla, -Destino) is nondet.
%
%   Destino está a un salto de caballo de Casilla, dentro o fuera del
%   tablero; select/3 descarta las que no están libres.
salto(F-C, F1-C1) :-
    member(DF-DC, [1-2, 2-1, 2-(-1), 1-(-2), -1-(-2), -2-(-1), -2-1, -1-2]),
    F1 is F + DF,
    C1 is C + DC.

% --- Ejercicio 8: todos los planes más cortos -------------------------------

%!  mas_cortos(+Problema, -Planes:list) is det.
%
%   Planes son todos los planes de longitud mínima de Problema. Como
%   iterativo/2, no termina si Problema no tiene solución.
mas_cortos(Problema, Planes) :-
    inicial(Problema, Estado),
    length(Plan0, _),
    desde(Problema, Estado, Plan0),
    !,
    length(Plan0, Longitud),
    length(Plan, Longitud),
    findall(Plan, desde(Problema, Estado, Plan), Planes).

%!  desde(+Problema, +Estado, ?Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado meta de Problema. Con la longitud de
%   Plan fijada, termina.
desde(Problema, Estado, []) :-
    meta(Problema, Estado).
desde(Problema, Estado, [Accion|Plan]) :-
    sucesor(Problema, Estado, Accion, Siguiente, _),
    desde(Problema, Siguiente, Plan).
