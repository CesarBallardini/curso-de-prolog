:- encoding(utf8).

% Capítulo 71 - Versión 5: subproblemas compartidos.
%
% En las torres de Hanoi, la búsqueda en profundidad de la versión 2
% expande 2^N - 1 nodos torre para N discos, aunque solo hay seis maneras
% de elegir los postes De y A: el mismo subproblema aparece una y otra
% vez. El grafo Y/O tiene pocos nodos; lo que crece es el árbol que
% resulta de desplegarlo. Esta versión recuerda, en un assoc del capítulo
% 22, el resultado de cada nodo ya resuelto, y cuando el nodo reaparece
% reutiliza el mismo árbol, sin copiarlo. El árbol solución queda
% compartido: sus 2^N - 1 movimientos se describen con unos pocos nodos
% distintos en la memoria.
%
% Recordar el resultado de un nodo es correcto solo si ese resultado no
% depende del camino por el que se llegó a él. Con ciclos, como en el mapa
% del río, sí depende, porque un nodo no puede usar a sus ancestros: la
% versión es para grafos sin ciclos, y no lleva la lista de ancestros.
%
% solo-local: carga hanoi.pl y profundidad.pl, que cargan otros archivos.
%
%?- plan_torres(3, Movimientos).
%?- torres(compartido, 20, Movimientos, Expandidos).

:- use_module(library(assoc)).
:- ensure_loaded(hanoi).
:- ensure_loaded(profundidad).

%!  compartido(+Problema, +Nodo, -Arbol, -Expandidos:integer) is semidet.
%
%   Arbol es el primer árbol solución de Nodo en profundidad, con los
%   subárboles de los nodos repetidos compartidos; Expandidos es la
%   cantidad de nodos distintos expandidos. El grafo de Problema no debe
%   tener ciclos. Falla si Nodo no tiene solución.
compartido(Problema, Nodo, Arbol, Expandidos) :-
    empty_assoc(M0),
    recordado(Problema, Nodo, si(Arbol), m(M0, 0), m(_, Expandidos)).

%!  recordado(+Problema, +Nodo, -Resultado, +S0, -S) is det.
%
%   Resultado es si(Arbol) con un árbol solución de Nodo, o no si no lo
%   hay. S0 y S son m(Memoria, K): Memoria asocia cada nodo expandido con
%   su resultado, y K cuenta las expansiones.
recordado(Problema, Nodo, Resultado, S0, S) :-
    S0 = m(M0, K0),
    (   get_assoc(Nodo, M0, R)
    ->  Resultado = R,
        S = S0
    ;   primitivo(Problema, Nodo)
    ->  Resultado = si(meta(Nodo)),
        S = S0
    ;   expansion(Problema, Nodo, Tipo, Hijos)
    ->  K1 is K0 + 1,
        reducir_recordado(Tipo, Problema, Nodo, Hijos, Resultado,
                          m(M0, K1), m(M1, K)),
        put_assoc(Nodo, M1, Resultado, M),
        S = m(M, K)
    ;   Resultado = no,
        S = S0
    ).

%!  reducir_recordado(+Tipo, +Problema, +Nodo, +Hijos:list, -Resultado,
%!                    +S0, -S) is det.
%
%   Como reducir/8 de la versión 2, con la memoria en S0 y S.
reducir_recordado(o, Problema, Nodo, Hijos, Resultado, S0, S) :-
    alguno_recordado(Hijos, Problema, R, S0, S),
    (   R = si(Arco)
    ->  Resultado = si(o(Nodo, Arco))
    ;   Resultado = no
    ).
reducir_recordado(y, Problema, Nodo, Hijos, Resultado, S0, S) :-
    todos_recordados(Hijos, Problema, R, S0, S),
    (   R = si(Arcos)
    ->  Resultado = si(y(Nodo, Arcos))
    ;   Resultado = no
    ).

%!  alguno_recordado(+Hijos:list, +Problema, -Resultado, +S0, -S) is det.
%
%   Resultado es si(Arbol-C) para el primer hijo Hijo-C que tiene
%   solución, o no.
alguno_recordado([], _, no, S, S).
alguno_recordado([Hijo-C|Hijos], Problema, Resultado, S0, S) :-
    recordado(Problema, Hijo, R, S0, S1),
    (   R = si(Arbol)
    ->  Resultado = si(Arbol-C),
        S = S1
    ;   alguno_recordado(Hijos, Problema, Resultado, S1, S)
    ).

%!  todos_recordados(+Hijos:list, +Problema, -Resultado, +S0, -S) is det.
%
%   Resultado es si(Arcos) si todos los hijos tienen solución, o no.
todos_recordados([], _, si([]), S, S).
todos_recordados([Hijo-C|Hijos], Problema, Resultado, S0, S) :-
    recordado(Problema, Hijo, R, S0, S1),
    (   R = si(Arbol)
    ->  todos_recordados(Hijos, Problema, R1, S1, S),
        (   R1 = si(Arcos)
        ->  Resultado = si([Arbol-C|Arcos])
        ;   Resultado = no
        )
    ;   Resultado = no,
        S = S1
    ).

%!  torres(+Busqueda, +N:integer, -Movimientos:integer,
%!         -Expandidos:integer) is det.
%
%   Busqueda, profundidad o compartido, resuelve torre(N, a, c) con un
%   árbol de Movimientos movimientos después de expandir Expandidos nodos.
torres(Busqueda, N, Movimientos, Expandidos) :-
    arbol_torres(Busqueda, N, Arbol, Expandidos),
    costo(Arbol, Movimientos).

%!  arbol_torres(+Busqueda, +N:integer, -Arbol, -Expandidos:integer) is det.
%
%   Arbol es el árbol solución de torre(N, a, c) que halla Busqueda.
arbol_torres(profundidad, N, Arbol, Expandidos) :-
    resolver(hanoi, torre(N, a, c), Arbol, Expandidos).
arbol_torres(compartido, N, Arbol, Expandidos) :-
    compartido(hanoi, torre(N, a, c), Arbol, Expandidos).

%!  plan_torres(+N:integer, -Movimientos:list) is det.
%
%   Movimientos son los movimientos, De-A, que pasan N discos de a a c.
plan_torres(N, Movimientos) :-
    compartido(hanoi, torre(N, a, c), Arbol, _),
    movimientos(Arbol, Movimientos).
