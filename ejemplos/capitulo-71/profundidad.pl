:- encoding(utf8).

% Capítulo 71 - Versión 2: búsqueda en profundidad con árbol solución.
%
% El grafo deja de ser el programa y pasa a ser un dato: la búsqueda lee
% los nodos con primitivo/2 y expansion/4 de arboles.pl, y devuelve el
% árbol solución como un término. Tres cambios corrigen las limitaciones
% de la versión 1. El árbol se arma a medida que la búsqueda tiene éxito.
% El costo de cada arco queda en el árbol, y costo/2 lo suma. Y cada nodo
% lleva la lista de sus ancestros: un nodo que repite a uno de ellos no se
% expande, porque una solución que pasa por él contendría un ciclo.
%
% El resultado de cada llamada es si(Arbol) o no, en lugar de éxito o
% fracaso, para que la cantidad de nodos expandidos se conserve también
% en las ramas que no llevan a una solución. La búsqueda se queda con el
% primer árbol que encuentra, que no es necesariamente el de menor costo.
%
% solo-local: carga mapa.pl, que carga arboles.pl.
%
%?- resolver(rio(cero), ruta(alamos, islas), A, K), costo(A, C).
%?- resolver(rio(cero), ruta(alamos, islas), A, _), pueblos(A, Ps).

:- ensure_loaded(mapa).

:- multifile arbol_viaje/6.

%!  resolver(+Problema, +Nodo, -Arbol, -Expandidos:integer) is semidet.
%
%   Arbol es el primer árbol solución de Nodo que encuentra la búsqueda en
%   profundidad, con los hijos en el orden de expansion/4; Expandidos es la
%   cantidad de nodos que expandió. Falla si Nodo no tiene solución.
resolver(Problema, Nodo, Arbol, Expandidos) :-
    profundidad(Problema, Nodo, [], si(Arbol), 0, Expandidos).

%!  profundidad(+Problema, +Nodo, +Ancestros:list, -Resultado,
%!              +K0:integer, -K:integer) is det.
%
%   Resultado es si(Arbol) con el primer árbol solución de Nodo que no
%   pasa por ninguno de Ancestros, o no si no lo hay; K es K0 más la
%   cantidad de nodos expandidos.
profundidad(Problema, Nodo, Ancestros, Resultado, K0, K) :-
    (   memberchk(Nodo, Ancestros)
    ->  Resultado = no,
        K = K0
    ;   primitivo(Problema, Nodo)
    ->  Resultado = si(meta(Nodo)),
        K = K0
    ;   expansion(Problema, Nodo, Tipo, Hijos)
    ->  K1 is K0 + 1,
        reducir(Tipo, Problema, Nodo, [Nodo|Ancestros], Hijos, Resultado,
                K1, K)
    ;   Resultado = no,
        K = K0
    ).

%!  reducir(+Tipo, +Problema, +Nodo, +Ancestros:list, +Hijos:list,
%!          -Resultado, +K0:integer, -K:integer) is det.
%
%   Resultado es si(Arbol) con un árbol solución de Nodo, que se reduce a
%   Hijos con Tipo o o y, o no si no lo hay.
reducir(o, Problema, Nodo, Ancestros, Hijos, Resultado, K0, K) :-
    alguno(Hijos, Problema, Ancestros, R, K0, K),
    (   R = si(Arco)
    ->  Resultado = si(o(Nodo, Arco))
    ;   Resultado = no
    ).
reducir(y, Problema, Nodo, Ancestros, Hijos, Resultado, K0, K) :-
    todos(Hijos, Problema, Ancestros, R, K0, K),
    (   R = si(Arcos)
    ->  Resultado = si(y(Nodo, Arcos))
    ;   Resultado = no
    ).

%!  alguno(+Hijos:list, +Problema, +Ancestros:list, -Resultado,
%!         +K0:integer, -K:integer) is det.
%
%   Resultado es si(Arbol-C) para el primer hijo Hijo-C de Hijos que tiene
%   solución, o no si ninguno la tiene. Los hijos siguientes no se exploran.
alguno([], _, _, no, K, K).
alguno([Hijo-C|Hijos], Problema, Ancestros, Resultado, K0, K) :-
    profundidad(Problema, Hijo, Ancestros, R, K0, K1),
    (   R = si(Arbol)
    ->  Resultado = si(Arbol-C),
        K = K1
    ;   alguno(Hijos, Problema, Ancestros, Resultado, K1, K)
    ).

%!  todos(+Hijos:list, +Problema, +Ancestros:list, -Resultado,
%!        +K0:integer, -K:integer) is det.
%
%   Resultado es si(Arcos), con un Arbol-C por cada hijo Hijo-C de Hijos,
%   si todos tienen solución, o no si alguno no la tiene. Los hijos que
%   siguen al primero sin solución no se exploran.
todos([], _, _, si([]), K, K).
todos([Hijo-C|Hijos], Problema, Ancestros, Resultado, K0, K) :-
    profundidad(Problema, Hijo, Ancestros, R, K0, K1),
    (   R = si(Arbol)
    ->  todos(Hijos, Problema, Ancestros, R1, K1, K),
        (   R1 = si(Arcos)
        ->  Resultado = si([Arbol-C|Arcos])
        ;   Resultado = no
        )
    ;   Resultado = no,
        K = K1
    ).

%!  arbol_viaje(+Busqueda, +De, +A, -Arbol, -Costo:number,
%!              -Expandidos:integer) is semidet.
%
%   Con Busqueda igual a profundidad, Arbol es el árbol de ruta(De, A) que
%   halla resolver/4.
arbol_viaje(profundidad, De, A, Arbol, Costo, Expandidos) :-
    resolver(rio(cero), ruta(De, A), Arbol, Expandidos),
    costo(Arbol, Costo).
