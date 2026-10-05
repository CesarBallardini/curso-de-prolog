:- encoding(utf8).

% Capítulo 76 - Versión 5: el laberinto de compuertas.
%
% El laberinto de Csenki es una sucesión de paredes horizontales, una por
% fila, cada una con algunas aberturas, las compuertas. Se entra por la
% única compuerta de la fila 1 y se sale por la única de la última fila; de
% una compuerta se pasa a cualquiera de la fila siguiente caminando por el
% corredor entre las dos paredes. Una compuerta es g(Fila, Posicion), con la
% posición contada desde la pared de la izquierda; el costo de ir de
% g(F, P) a g(F+1, Q) es |P - Q| + 1, la distancia contando solo movimientos
% horizontales y verticales. Nunca se vuelve a una fila anterior, así que el
% grafo no tiene ciclos.
%
% Tres heurísticas, ninguna estima de más: cero; euclidea, la distancia en
% línea recta hasta la salida, que nunca supera la distancia con
% movimientos horizontales y verticales; y vuelo, la de Csenki: para cada
% fila intermedia, la menor longitud de un vuelo en dos tramos rectos que
% pasa por una de sus compuertas, y de esas, la mayor.
%
% solo-local: carga las búsquedas del capítulo 40.
%
%?- laberinto(csenki, Filas), length(Filas, N).
%?- salida(csenki, Camino, Costo, K).

:- module(laberinto,
          [ laberinto/2,
            sembrado/5,
            salida/4,
            salida_con/6,
            estimacion/4,
            mostrar_laberinto/2
          ]).

:- use_module(capitulo40).

% --- Los laberintos -----------------------------------------------------------

%!  laberinto(?Nombre, -Filas:list) is nondet.
%
%   Filas son las posiciones de las compuertas de cada fila del laberinto
%   Nombre, de abajo hacia arriba. csenki es el de la figura 3.10 de
%   Csenki; sembrado(S, F, A, C) es el de sembrado/5.
laberinto(csenki,
          [ [2], [7, 14, 20], [2, 17], [5, 8], [2, 20], [13, 17, 19],
            [2, 15], [7, 19], [4, 8, 18], [3, 16, 19], [3, 12], [5]
          ]).
laberinto(sembrado(Semilla, NFilas, Ancho, Compuertas), Filas) :-
    sembrado(Semilla, NFilas, Ancho, Compuertas, Filas).

%!  sembrado(+Semilla:integer, +NFilas:integer, +Ancho:integer,
%!           +Compuertas:integer, -Filas:list) is det.
%
%   Filas es un laberinto de NFilas filas de ancho Ancho: la primera y la
%   última con una compuerta, las demás con a lo sumo Compuertas, en
%   posiciones tomadas de un generador congruencial lineal con la Semilla.
%   El mismo pedido da siempre el mismo laberinto, en cualquier instalación.
sembrado(Semilla, NFilas, Ancho, Compuertas, [[P1]|Filas]) :-
    azar(Semilla, Ancho, P1, S1),
    NMedio is NFilas - 2,
    filas(NMedio, Ancho, Compuertas, S1, Medio, S2),
    azar(S2, Ancho, PN, _),
    append(Medio, [[PN]], Filas).

%!  filas(+N:integer, +Ancho:integer, +Compuertas:integer, +S0:integer,
%!        -Filas:list, -S:integer) is det.
%
%   Filas son N filas de a lo sumo Compuertas compuertas distintas.
filas(0, _, _, S, [], S) :-
    !.
filas(N, Ancho, Compuertas, S0, [Fila|Filas], S) :-
    length(Ps, Compuertas),
    foldl(posicion(Ancho), Ps, S0, S1),
    sort(Ps, Fila),
    N1 is N - 1,
    filas(N1, Ancho, Compuertas, S1, Filas, S).

%!  posicion(+Ancho:integer, -P:integer, +S0:integer, -S:integer) is det.
%
%   P es una posición entre 1 y Ancho tomada del generador.
posicion(Ancho, P, S0, S) :-
    azar(S0, Ancho, P, S).

%!  azar(+S0:integer, +N:integer, -X:integer, -S:integer) is det.
%
%   X es un entero entre 1 y N y S el estado siguiente del generador
%   congruencial lineal de módulo 2^31.
azar(S0, N, X, S) :-
    S is (1103515245 * S0 + 12345) mod 2147483648,
    X is (S >> 16) mod N + 1.

% --- El problema --------------------------------------------------------------

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es la compuerta de entrada, la única de la fila 1.
inicial(salir(Filas, _), g(1, P)) :-
    Filas = [[P]|_].

%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es la compuerta de salida, la única de la última fila.
meta(salir(Filas, _), g(F, P)) :-
    length(Filas, F),
    last(Filas, [P]).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Siguiente es una compuerta de la fila siguiente, también la Accion, y
%   Costo la distancia caminada por el corredor.
sucesor(salir(Filas, _), g(F, P), g(F1, Q), g(F1, Q), Costo) :-
    F1 is F + 1,
    nth1(F1, Filas, Fila),
    member(Q, Fila),
    Costo is abs(P - Q) + 1.

%!  heuristica(+Problema, +Estado, -H:number) is det.
%
%   H es la estimación de salir(Filas, Nombre) desde la compuerta Estado
%   hasta la salida.
heuristica(salir(Filas, Nombre), G, H) :-
    length(Filas, N),
    last(Filas, [P]),
    estimacion(Nombre, Filas, G, g(N, P), H).

%!  estimacion(+Nombre, +Filas:list, +X, +Y, -H:number) is det.
%
%   H estima con la heurística Nombre la distancia de la compuerta X a la
%   compuerta Y, en una fila posterior.
estimacion(cero, _, _, _, 0).
estimacion(euclidea, _, X, Y, H) :-
    recta(X, Y, H).
estimacion(vuelo, Filas, X, Y, H) :-
    X = g(F1, _),
    Y = g(F2, _),
    recta(X, Y, E),
    Desde is F1 + 1,
    Hasta is F2 - 1,
    findall(V, vuelo_por(Filas, Desde, Hasta, X, Y, V), Vs),
    max_list([E|Vs], H).

%!  vuelo_por(+Filas:list, +Desde:integer, +Hasta:integer, +X, +Y,
%!            -V:number) is nondet.
%
%   V es el vuelo más corto de X a Y que pasa por una compuerta de una
%   fila entre Desde y Hasta; una respuesta por fila.
vuelo_por(Filas, Desde, Hasta, X, Y, V) :-
    between(Desde, Hasta, F),
    nth1(F, Filas, Fila),
    aggregate_all(min(D),
                  ( member(P, Fila),
                    recta(X, g(F, P), D1),
                    recta(g(F, P), Y, D2),
                    D is D1 + D2 ),
                  V).

%!  recta(+X, +Y, -D:float) is det.
%
%   D es la distancia en línea recta entre las compuertas X e Y.
recta(g(F1, P1), g(F2, P2), D) :-
    D is sqrt((F1 - F2)**2 + (P1 - P2)**2).

%!  estimacion(+Nombre, +Laberinto, +X, -H:number) is det.
%
%   H es lo que estima la heurística Nombre de la compuerta X a la salida
%   del laberinto Laberinto.
estimacion(Nombre, Laberinto, X, H) :-
    laberinto(Laberinto, Filas),
    heuristica(salir(Filas, Nombre), X, H).

% --- Las consultas ------------------------------------------------------------

%!  salida(+Laberinto, -Camino:list, -Costo:number, -Expandidos:integer)
%!      is semidet.
%
%   Camino es el recorrido más corto por las compuertas del Laberinto, de
%   la entrada a la salida, hallado con A* y la heurística euclidea.
salida(Laberinto, Camino, Costo, Expandidos) :-
    salida_con(a_estrella, euclidea, Laberinto, Camino, Costo, Expandidos).

%!  salida_con(+Algoritmo, +Heuristica, +Laberinto, -Camino:list,
%!             -Costo:number, -Expandidos:integer) is semidet.
%
%   Como salida/4, con Algoritmo a_estrella o ida_estrella y la Heuristica
%   cero, euclidea o vuelo.
salida_con(Algoritmo, Heuristica, Laberinto, [Entrada|Plan], Costo,
           Expandidos) :-
    laberinto(Laberinto, Filas),
    Problema = laberinto:salir(Filas, Heuristica),
    inicial(salir(Filas, Heuristica), Entrada),
    resolver(Algoritmo, Problema, Plan, Costo, Expandidos).

%!  resolver(+Algoritmo, +Problema, -Plan:list, -Costo:number,
%!           -Expandidos:integer) is semidet.
%
%   Resuelve Problema con A* o con IDA*, las búsquedas del capítulo 40.
resolver(a_estrella, Problema, Plan, Costo, Expandidos) :-
    buscar(mejor(a_estrella), Problema, Plan, Costo, Expandidos).
resolver(ida_estrella, Problema, Plan, Costo, Expandidos) :-
    ida_estrella(Problema, Plan, Costo, Expandidos).

% --- El dibujo ----------------------------------------------------------------

%!  mostrar_laberinto(+Laberinto, +Camino:list) is det.
%
%   Escribe el Laberinto con la fila de salida arriba: cada pared es una
%   línea de '-' con un espacio en cada compuerta, o un '*' en la compuerta
%   por la que pasa Camino.
mostrar_laberinto(Laberinto, Camino) :-
    laberinto(Laberinto, Filas),
    aggregate_all(max(P), ( member(Fila, Filas), member(P, Fila) ), Ancho),
    length(Filas, N),
    forall(between(1, N, I),
           ( F is N + 1 - I,
             nth1(F, Filas, Fila),
             pared(Fila, F, Ancho, Camino, Linea),
             format("~t~d~3| ~w~n", [F, Linea]) )).

%!  pared(+Fila:list, +F:integer, +Ancho:integer, +Camino:list, -Linea)
%!      is det.
%
%   Linea dibuja la pared de la fila F, de Ancho posiciones.
pared(Fila, F, Ancho, Camino, Linea) :-
    findall(C,
            ( between(1, Ancho, P),
              (   memberchk(g(F, P), Camino)
              ->  C = '*'
              ;   memberchk(P, Fila)
              ->  C = ' '
              ;   C = '-'
              ) ),
            Cs),
    atom_chars(Linea, Cs).
