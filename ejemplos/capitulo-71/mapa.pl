:- encoding(utf8).

% Capítulo 71 - Un mapa con un río, como grafo Y/O.
%
% Un río corre de norte a sur y separa los pueblos del oeste de los del
% este. Solo se lo cruza en tres pueblos, molino, paso y barca, que están
% sobre el río. Cada pueblo tiene coordenadas en kilómetros, y cada camino
% une dos pueblos con una longitud que no es menor que la distancia en
% línea recta entre ellos.
%
% El problema rio(Estimacion) reduce «ir de A a B», el nodo ruta(A, B):
%
% - si A y B están en orillas opuestas, la ruta pasa por uno de los
%   puentes: un nodo O cuyos hijos son cruce(A, P, B), uno por puente P;
%   cruce(A, P, B) es un nodo Y con dos hijos, ruta(A, P) y ruta(P, B),
%   que se resuelven cada uno por su lado;
% - si no, la ruta sale por uno de los caminos de A: un nodo O cuyos hijos
%   son ruta(C, B), uno por vecino C, con la longitud del camino como
%   costo del arco;
% - ruta(B, B) es primitivo.
%
% Estimacion es distancia, la distancia en línea recta truncada, o cero.
%
% viaje/6 y mostrar_viaje/3 resumen lo que devuelve cada búsqueda del
% capítulo: cada versión agrega una cláusula a arbol_viaje/6 con su nombre.
%
% solo-local: agrega cláusulas a los predicados de arboles.pl, que carga.
%
%?- expansion(rio(distancia), ruta(alamos, islas), Tipo, Hijos).
%?- estimacion(rio(distancia), ruta(alamos, islas), H).

:- ensure_loaded(arboles).

:- multifile primitivo/2, expansion/4, estimacion/3.
:- multifile arbol_viaje/6.
:- dynamic arbol_viaje/6.

% pueblo(P, Lado, X, Y): el pueblo P está en Lado (oeste, este o rio), en
% las coordenadas (X, Y).
pueblo(alamos,  oeste, 10, 50).
pueblo(bosque,  oeste, 25, 85).
pueblo(cantera, oeste, 30, 60).
pueblo(dique,   oeste, 20, 20).
pueblo(ermita,  oeste, 35, 35).
pueblo(molino,  rio,   50, 90).
pueblo(paso,    rio,   50, 50).
pueblo(barca,   rio,   50, 10).
pueblo(fuente,  este,  70, 85).
pueblo(granja,  este,  75, 55).
pueblo(huerta,  este,  65, 25).
pueblo(islas,   este,  90, 50).
pueblo(jardin,  este,  85, 15).

% camino(A, B, L): un camino de longitud L une A con B, en los dos sentidos.
camino(alamos,  cantera, 25).
camino(alamos,  dique,   33).
camino(alamos,  bosque,  40).
camino(bosque,  cantera, 26).
camino(bosque,  molino,  27).
camino(cantera, paso,    24).
camino(cantera, ermita,  27).
camino(dique,   ermita,  22).
camino(dique,   barca,   33).
camino(ermita,  paso,    30).
camino(ermita,  barca,   31).
camino(molino,  fuente,  22).
camino(paso,    granja,  40).
camino(paso,    huerta,  31).
camino(barca,   huerta,  23).
camino(barca,   jardin,  37).
camino(fuente,  granja,  32).
camino(fuente,  islas,   42).
camino(granja,  islas,   17).
camino(granja,  huerta,  33).
camino(huerta,  jardin,  24).
camino(islas,   jardin,  36).

%!  tramo(?A, ?B, ?L) is nondet.
%
%   Un camino de longitud L lleva de A a B, en cualquiera de los dos
%   sentidos.
tramo(A, B, L) :-
    (   camino(A, B, L)
    ;   camino(B, A, L)
    ).

%!  separados(+A, +B) is semidet.
%
%   A y B están en orillas opuestas del río.
separados(A, B) :-
    pueblo(A, LA, _, _),
    pueblo(B, LB, _, _),
    opuestas(LA, LB).

% opuestas(L1, L2): L1 y L2 son las dos orillas.
opuestas(oeste, este).
opuestas(este, oeste).

%!  distancia(+A, +B, -D:integer) is det.
%
%   D es la distancia en línea recta de A a B, truncada: no supera la
%   longitud de ningún recorrido de A a B.
distancia(A, B, D) :-
    pueblo(A, _, XA, YA),
    pueblo(B, _, XB, YB),
    D is truncate(sqrt((XA - XB)**2 + (YA - YB)**2)).

% primitivo(P, N): ir de un pueblo al mismo pueblo no requiere camino.
primitivo(rio(_), ruta(B, B)).

%!  expansion(+Problema, +Nodo, -Tipo, -Hijos:list) is semidet.
%
%   Nodo de Problema se reduce a Hijos, con Tipo o o y. Falla si Nodo es
%   primitivo.
expansion(rio(_), ruta(A, B), o, Hijos) :-
    A \== B,
    (   separados(A, B)
    ->  findall(cruce(A, P, B)-0, pueblo(P, rio, _, _), Hijos)
    ;   findall(ruta(C, B)-L, tramo(A, C, L), Hijos)
    ).
expansion(rio(_), cruce(A, P, B), y, [ruta(A, P)-0, ruta(P, B)-0]).

%!  estimacion(+Problema, +Nodo, -H:integer) is det.
%
%   H es la estimación del costo de Nodo: la distancia en línea recta, o
%   cero.
estimacion(rio(Estimacion), Nodo, H) :-
    estimacion_rio(Estimacion, Nodo, H).

%!  estimacion_rio(+Estimacion, +Nodo, -H:integer) is det.
%
%   H es la estimación del costo de Nodo según Estimacion, cero o
%   distancia.
estimacion_rio(cero, _, 0).
estimacion_rio(distancia, Nodo, H) :-
    distancia_nodo(Nodo, H).

%!  distancia_nodo(+Nodo, -H:integer) is det.
%
%   H es la distancia en línea recta que recorre, como mínimo, cualquier
%   solución de Nodo: de A a B en ruta(A, B), y de A a P más de P a B en
%   cruce(A, P, B).
distancia_nodo(ruta(A, B), H) :-
    distancia(A, B, H).
distancia_nodo(cruce(A, P, B), H) :-
    distancia(A, P, H1),
    distancia(P, B, H2),
    H is H1 + H2.

%!  pueblos(+Arbol, -Pueblos:list) is det.
%
%   Pueblos es el recorrido que describe Arbol, un árbol solución de un
%   nodo ruta(A, B): los pueblos de A a B, en orden.
pueblos(Arbol, [A|Resto]) :-
    raiz(Arbol, ruta(A, _)),
    phrase(pasos(Arbol), Resto).

%!  pasos(+Arbol)// is det.
%
%   La lista son los pueblos a los que se llega en el recorrido de Arbol,
%   sin el de partida.
pasos(meta(_)) -->
    [].
pasos(o(_, A-_)) -->
    { raiz(A, R) },
    llegada(R),
    pasos(A).
pasos(y(_, [A1-_, A2-_])) -->
    pasos(A1),
    pasos(A2).

%!  llegada(+Nodo)// is det.
%
%   La lista es el pueblo al que lleva un camino, si Nodo es ruta(C, B), o
%   vacía, si Nodo es un cruce.
llegada(ruta(C, _)) -->
    [C].
llegada(cruce(_, _, _)) -->
    [].

%!  viaje(+Busqueda, +De, +A, -Pueblos:list, -Costo:number,
%!        -Expandidos:integer) is semidet.
%
%   Busqueda halla un árbol solución de ruta(De, A) de costo Costo después
%   de expandir Expandidos nodos; Pueblos es el recorrido que describe.
viaje(Busqueda, De, A, Pueblos, Costo, Expandidos) :-
    arbol_viaje(Busqueda, De, A, Arbol, Costo, Expandidos),
    pueblos(Arbol, Pueblos).

%!  mostrar_viaje(+Busqueda, +De, +A) is semidet.
%
%   Escribe el árbol solución de ruta(De, A) que halla Busqueda.
mostrar_viaje(Busqueda, De, A) :-
    arbol_viaje(Busqueda, De, A, Arbol, _, _),
    mostrar(Arbol).
