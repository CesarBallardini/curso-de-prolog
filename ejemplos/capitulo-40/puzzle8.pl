:- encoding(utf8).

% Capítulo 40 - Heurísticas: A* e IDA* en el rompecabezas de 8.
%
% El rompecabezas de 8 tiene ocho fichas numeradas y un hueco en un marco de
% 3 x 3; una acción desliza al hueco una ficha vecina, lo que equivale a
% mover el hueco arriba, abajo, a la izquierda o a la derecha. Un estado es
% la lista de las nueve casillas por filas, con 0 en el hueco, y la meta es
% [1, 2, 3, 4, 5, 6, 7, 8, 0]. El problema puzzle(Inicial, Heuristica)
% lleva la heurística que estima lo que falta: fuera (las fichas fuera de
% lugar), manhattan (la suma de las distancias de cada ficha a su casilla)
% o cero. El bucle es el de visitados.pl; se agregan dos criterios de
% prioridad: heuristica (la búsqueda voraz) y a_estrella (el costo más la
% heurística). ida_estrella/4 es la profundización iterativa con la cota
% sobre el costo más la heurística.
%
%?- ejemplo(facil, E), buscar(mejor(a_estrella), puzzle(E, fuera), P, C, K).
%?- ejemplo(medio, E), ida_estrella(puzzle(E, manhattan), P, C, K).

:- use_module(library(heaps)).
:- use_module(library(assoc)).

% --- El problema --------------------------------------------------------------

% ejemplo(Nombre, Estado): un estado inicial del rompecabezas; el plan más
% corto desde facil tiene 8 acciones, desde medio 20 y desde dificil 26.
ejemplo(facil, [2, 4, 3, 7, 1, 5, 0, 8, 6]).
ejemplo(medio, [1, 6, 3, 7, 5, 4, 0, 8, 2]).
ejemplo(dificil, [0, 7, 5, 4, 8, 2, 3, 6, 1]).

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es el estado de partida de Problema.
inicial(puzzle(Inicial, _), Inicial).

%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es la disposición buscada: las fichas en orden y el hueco al
%   final.
meta(puzzle(_, _), [1, 2, 3, 4, 5, 6, 7, 8, 0]).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Accion mueve el hueco de Estado en una dirección y lleva a Siguiente,
%   con costo 1.
sucesor(puzzle(_, _), Estado, Accion, Siguiente, 1) :-
    nth0(Hueco, Estado, 0),
    movimiento(Accion, Hueco, Destino),
    nth0(Destino, Estado, Ficha),
    intercambiar(Estado, Hueco, Destino, Ficha, Siguiente).

%!  movimiento(?Accion, +Hueco:integer, -Destino:integer) is nondet.
%
%   Mover el hueco con Accion lo lleva de la casilla Hueco a Destino, en un
%   marco de 3 x 3 con las casillas numeradas de 0 a 8 por filas.
movimiento(arriba, H, D) :-
    H >= 3,
    D is H - 3.
movimiento(abajo, H, D) :-
    H < 6,
    D is H + 3.
movimiento(izquierda, H, D) :-
    H mod 3 > 0,
    D is H - 1.
movimiento(derecha, H, D) :-
    H mod 3 < 2,
    D is H + 1.

%!  intercambiar(+Estado, +Hueco:integer, +Destino:integer, +Ficha,
%!               -Siguiente) is det.
%
%   Siguiente es Estado con Ficha en la casilla Hueco y el hueco en Destino.
intercambiar(Estado, Hueco, Destino, Ficha, Siguiente) :-
    nth0(Hueco, Estado, 0, Resto0),
    nth0(Hueco, Estado1, Ficha, Resto0),
    nth0(Destino, Estado1, Ficha, Resto1),
    nth0(Destino, Siguiente, 0, Resto1).

%!  heuristica(+Problema, +Estado, -H:integer) is det.
%
%   H estima cuántas acciones faltan desde Estado, con la heurística de
%   Problema. Las tres nunca estiman de más.
heuristica(puzzle(_, Nombre), Estado, H) :-
    estimacion(Nombre, Estado, H).

%!  estimacion(+Nombre, +Estado, -H:integer) is det.
%
%   H es lo que estima la heurística Nombre desde Estado: cero, fuera o
%   manhattan.
estimacion(cero, _, 0).
estimacion(fuera, Estado, H) :-
    aggregate_all(count,
                  ( nth1(I, Estado, Ficha),
                    Ficha =\= 0,
                    Ficha =\= I ),
                  H).
estimacion(manhattan, Estado, H) :-
    aggregate_all(sum(D),
                  ( nth0(I, Estado, Ficha),
                    Ficha =\= 0,
                    distancia(I, Ficha, D) ),
                  H).

%!  distancia(+I:integer, +Ficha:integer, -D:integer) is det.
%
%   D es la cantidad de movimientos en línea recta entre la casilla I y la
%   casilla de Ficha en la meta, la Ficha-1.
distancia(I, Ficha, D) :-
    J is Ficha - 1,
    D is abs(I // 3 - J // 3) + abs(I mod 3 - J mod 3).

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


% --- IDA* ---------------------------------------------------------------------

%!  ida_estrella(+Problema, -Plan:list, -Costo:number, -Expandidos:integer)
%!      is semidet.
%
%   Plan es un plan de costo mínimo de Problema, si su heurística nunca
%   estima de más. Busca en profundidad los caminos cuyo costo más la
%   heurística no pasa de una cota; si no hay plan dentro de la cota, la
%   siguiente es el menor valor que la pasó. Expandidos cuenta los nodos
%   expandidos en todas las iteraciones. Falla si no hay plan.
ida_estrella(Problema, Plan, Costo, Expandidos) :-
    inicial(Problema, Estado),
    heuristica(Problema, Estado, Cota),
    iteracion(Problema, Estado, Cota, 0, Plan, Costo, Expandidos).

%!  iteracion(+Problema, +Estado, +Cota:number, +K0:integer, -Plan:list,
%!            -Costo:number, -K:integer) is semidet.
%
%   Busca con Cota, y si no encuentra un plan, con la cota siguiente.
iteracion(Problema, Estado, Cota, K0, Plan, Costo, K) :-
    acotada(Problema, Estado, 0, Cota, [Estado], Resultado, K0, K1),
    (   Resultado = plan(Plan, Costo)
    ->  K = K1
    ;   Resultado = cota(Siguiente),
        Siguiente \== infinito,
        iteracion(Problema, Estado, Siguiente, K1, Plan, Costo, K)
    ).

%!  acotada(+Problema, +Estado, +G:number, +Cota:number, +Rastro:list,
%!          -Resultado, +K0:integer, -K:integer) is det.
%
%   Resultado es plan(Plan, Costo) si hay un plan desde Estado, al que se
%   llegó con costo G, sin pasar de Cota ni repetir los estados de Rastro;
%   si no, es cota(C), con C el menor costo más heurística que pasó de Cota,
%   o infinito si ninguno pasó.
acotada(Problema, Estado, G, Cota, Rastro, Resultado, K0, K) :-
    heuristica(Problema, Estado, H),
    F is G + H,
    (   F > Cota
    ->  Resultado = cota(F),
        K = K0
    ;   meta(Problema, Estado)
    ->  Resultado = plan([], G),
        K = K0
    ;   K1 is K0 + 1,
        findall(t(Accion, Siguiente, C),
                ( sucesor(Problema, Estado, Accion, Siguiente, C),
                  \+ memberchk(Siguiente, Rastro) ),
                Transiciones),
        probar(Transiciones, Problema, G, Cota, Rastro, infinito,
               Resultado, K1, K)
    ).

%!  probar(+Transiciones:list, +Problema, +G:number, +Cota:number,
%!         +Rastro:list, +Menor, -Resultado, +K0:integer, -K:integer) is det.
%
%   Prueba las transiciones en orden hasta que una lleva a un plan; Menor es
%   la menor cota que pasaron las ya probadas.
probar([], _, _, _, _, Menor, cota(Menor), K, K).
probar([t(Accion, Siguiente, C)|Ts], Problema, G, Cota, Rastro, Menor0,
       Resultado, K0, K) :-
    G1 is G + C,
    acotada(Problema, Siguiente, G1, Cota, [Siguiente|Rastro], R, K0, K1),
    (   R = plan(Plan, Costo)
    ->  Resultado = plan([Accion|Plan], Costo),
        K = K1
    ;   R = cota(F),
        menor(F, Menor0, Menor),
        probar(Ts, Problema, G, Cota, Rastro, Menor, Resultado, K1, K)
    ).

%!  menor(+A, +B, -Menor) is det.
%
%   Menor es el menor de A y B, números o infinito.
menor(infinito, B, B) :-
    !.
menor(A, infinito, A) :-
    !.
menor(A, B, M) :-
    M is min(A, B).
