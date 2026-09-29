:- encoding(utf8).

% Capítulo 71 - Versión 3: el árbol de menor costo, explorándolo todo.
%
% La versión 2 se queda con el primer árbol solución, y en el mapa ese
% árbol recorre 241 km donde alcanzan menos de la mitad. Para tener el de
% menor costo, esta versión resuelve todos los hijos de cada nodo: un nodo
% O se queda con el hijo cuyo arco más su árbol cuesta menos, y un nodo Y
% suma los costos de todos sus hijos. El resultado es el óptimo, pero la
% búsqueda recorre el árbol de búsqueda entero: cada camino sin ciclos
% del mapa se examina, aunque cueste más que una solución ya encontrada.
%
% solo-local: carga mapa.pl, que carga arboles.pl.
%
%?- optimo(rio(cero), ruta(alamos, islas), A, C, K), pueblos(A, Ps).

:- ensure_loaded(mapa).

:- multifile arbol_viaje/6.

%!  optimo(+Problema, +Nodo, -Arbol, -Costo:number, -Expandidos:integer)
%!      is semidet.
%
%   Arbol es un árbol solución de Nodo de costo mínimo, Costo; Expandidos
%   es la cantidad de nodos que expandió la búsqueda. Falla si Nodo no
%   tiene solución.
optimo(Problema, Nodo, Arbol, Costo, Expandidos) :-
    mejor_arbol(Problema, Nodo, [], si(Arbol, Costo), 0, Expandidos).

%!  mejor_arbol(+Problema, +Nodo, +Ancestros:list, -Resultado,
%!              +K0:integer, -K:integer) is det.
%
%   Resultado es si(Arbol, Costo) con un árbol solución de Nodo de costo
%   mínimo entre los que no pasan por ninguno de Ancestros, o no si no lo
%   hay; K es K0 más la cantidad de nodos expandidos.
mejor_arbol(Problema, Nodo, Ancestros, Resultado, K0, K) :-
    (   memberchk(Nodo, Ancestros)
    ->  Resultado = no,
        K = K0
    ;   primitivo(Problema, Nodo)
    ->  Resultado = si(meta(Nodo), 0),
        K = K0
    ;   expansion(Problema, Nodo, Tipo, Hijos)
    ->  K1 is K0 + 1,
        foldl(resolver_hijo(Problema, [Nodo|Ancestros]), Hijos, Rs,
              K1, K),
        combinar(Tipo, Nodo, Rs, Resultado)
    ;   Resultado = no,
        K = K0
    ).

%!  resolver_hijo(+Problema, +Ancestros:list, +Hijo, -Resultado,
%!                +K0:integer, -K:integer) is det.
%
%   Resultado es si(Arbol-C, Costo) con el mejor árbol del hijo Hijo-C y
%   su costo, arco incluido, o no si el hijo no tiene solución.
resolver_hijo(Problema, Ancestros, Hijo-C, Resultado, K0, K) :-
    mejor_arbol(Problema, Hijo, Ancestros, R, K0, K),
    (   R = si(Arbol, Costo0)
    ->  Costo is C + Costo0,
        Resultado = si(Arbol-C, Costo)
    ;   Resultado = no
    ).

%!  combinar(+Tipo, +Nodo, +Resultados:list, -Resultado) is det.
%
%   Resultado es el mejor árbol de Nodo a partir de los resultados de sus
%   hijos: con Tipo o, el hijo de menor costo; con Tipo y, todos, con la
%   suma de sus costos. Es no si ningún hijo (o) o alguno (y) no tiene
%   solución.
combinar(o, Nodo, Rs, Resultado) :-
    findall(Costo-Arco, member(si(Arco, Costo), Rs), Soluciones),
    (   Soluciones == []
    ->  Resultado = no
    ;   keysort(Soluciones, [Costo-Arco|_]),
        Resultado = si(o(Nodo, Arco), Costo)
    ).
combinar(y, Nodo, Rs, Resultado) :-
    (   memberchk(no, Rs)
    ->  Resultado = no
    ;   findall(Arco, member(si(Arco, _), Rs), Arcos),
        foldl(sumar_resultado, Rs, 0, Costo),
        Resultado = si(y(Nodo, Arcos), Costo)
    ).

%!  sumar_resultado(+Resultado, +S0:number, -S:number) is det.
%
%   S es S0 más el costo de Resultado, que es si(Arco, Costo).
sumar_resultado(si(_, Costo), S0, S) :-
    S is S0 + Costo.

%!  arbol_viaje(+Busqueda, +De, +A, -Arbol, -Costo:number,
%!              -Expandidos:integer) is semidet.
%
%   Con Busqueda igual a optimo, Arbol es el árbol de ruta(De, A) que
%   halla optimo/5.
arbol_viaje(optimo, De, A, Arbol, Costo, Expandidos) :-
    optimo(rio(cero), ruta(De, A), Arbol, Costo, Expandidos).
