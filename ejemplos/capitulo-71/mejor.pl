:- encoding(utf8).

% Capítulo 71 - Versión 4: búsqueda mejor primero en grafos Y/O.
%
% La versión 3 encuentra el óptimo expandiendo todo. Esta versión expande
% un nodo por vez, siempre dentro del árbol solución parcial más
% prometedor. El árbol de búsqueda es un término, y cada nodo lleva F, su
% costo estimado:
%
%   punta(N, F)         N todavía no se expandió; F es su estimación;
%   o(N, F, Hijos)      nodo O; F es el menor costo de arco más F de hijo;
%   y(N, F, Hijos)      nodo Y; F es la suma de costos de arco más F;
%   hecho(N, F, Arbol)  N está resuelto; F es el costo exacto de Arbol;
%   imposible(N)        N no tiene solución; F es el átomo inf, que en el
%                       orden estándar de términos sigue a todo número.
%
% Cada paso baja desde la raíz: en un nodo O, al hijo de menor costo; en
% un nodo Y, al primer hijo sin resolver; hasta llegar a una punta, que se
% expande. Al volver, cada nodo recalcula su F con los de sus hijos: un
% nodo O cuyo mejor hijo está resuelto queda resuelto, igual que un nodo Y
% con todos sus hijos resueltos. La búsqueda termina cuando la raíz queda
% resuelta. Si la estimación nunca supera el costo verdadero, el árbol
% hallado es el de menor costo.
%
% solo-local: carga mapa.pl, que carga arboles.pl.
%
%?- mejor(rio(distancia), ruta(alamos, islas), A, C, K), pueblos(A, Ps).
%?- mejor(rio(cero), ruta(alamos, islas), _, C, K).

:- ensure_loaded(mapa).

:- multifile arbol_viaje/6.

%!  mejor(+Problema, +Nodo, -Arbol, -Costo:number, -Expandidos:integer)
%!      is semidet.
%
%   Arbol es el árbol solución de Nodo que encuentra la búsqueda mejor
%   primero, con costo Costo, después de expandir Expandidos nodos. Si
%   estimacion/3 no supera el costo verdadero de ningún nodo, Arbol es de
%   costo mínimo. Falla si Nodo no tiene solución.
mejor(Problema, Nodo, Arbol, Costo, Expandidos) :-
    buscar_mejor(Problema, Nodo, hecho(_, Costo, Arbol), Expandidos).

%!  buscar_mejor(+Problema, +Nodo, -T, -Expandidos:integer) is det.
%
%   T es el árbol de búsqueda de Nodo al terminar la búsqueda: hecho, con
%   el árbol solución, o imposible; Expandidos es la cantidad de
%   expansiones.
buscar_mejor(Problema, Nodo, T, Expandidos) :-
    nuevo(Problema, [], Nodo, T0),
    ciclo(Problema, T0, 0, T, Expandidos).

%!  ciclo(+Problema, +T0, +K0:integer, -T, -K:integer) is det.
%
%   T es el árbol de búsqueda al que se llega desde T0 expandiendo una
%   punta por vez, hasta que la raíz queda resuelta o imposible; K es K0
%   más la cantidad de expansiones.
ciclo(Problema, T0, K0, T, K) :-
    (   terminado(T0)
    ->  T = T0,
        K = K0
    ;   expandir(T0, Problema, [], T1),
        K1 is K0 + 1,
        ciclo(Problema, T1, K1, T, K)
    ).

% terminado(T): la raíz de T está resuelta o no tiene solución.
terminado(hecho(_, _, _)).
terminado(imposible(_)).

%!  nuevo(+Problema, +Ancestros:list, +Nodo, -T) is det.
%
%   T es el árbol de búsqueda de un nodo recién generado: imposible si
%   repite uno de Ancestros, hecho si es primitivo, y si no una punta con
%   su estimación.
nuevo(Problema, Ancestros, Nodo, T) :-
    (   memberchk(Nodo, Ancestros)
    ->  T = imposible(Nodo)
    ;   primitivo(Problema, Nodo)
    ->  T = hecho(Nodo, 0, meta(Nodo))
    ;   estimacion(Problema, Nodo, H),
        T = punta(Nodo, H)
    ).

%!  expandir(+T0, +Problema, +Ancestros:list, -T) is det.
%
%   T es T0 después de expandir una punta de su árbol solución parcial más
%   prometedor, con los F recalculados de esa punta hacia arriba.
expandir(punta(N, _), Problema, Ancestros, T) :-
    (   expansion(Problema, N, Tipo, Hijos)
    ->  maplist(nuevo_hijo(Problema, [N|Ancestros]), Hijos, Ts),
        rehacer(Tipo, N, Ts, T)
    ;   T = imposible(N)
    ).
expandir(o(N, _, Ts0), Problema, Ancestros, T) :-
    menor(Ts0, I),
    expandir_hijo(Problema, [N|Ancestros], I, Ts0, Ts),
    rehacer(o, N, Ts, T).
expandir(y(N, _, Ts0), Problema, Ancestros, T) :-
    nth1(I, Ts0, T1-_),
    T1 \= hecho(_, _, _),
    !,
    expandir_hijo(Problema, [N|Ancestros], I, Ts0, Ts),
    rehacer(y, N, Ts, T).

%!  nuevo_hijo(+Problema, +Ancestros:list, +Hijo, -T) is det.
%
%   T es el árbol de búsqueda del hijo Hijo-C, como T1-C.
nuevo_hijo(Problema, Ancestros, Hijo-C, T-C) :-
    nuevo(Problema, Ancestros, Hijo, T).

%!  expandir_hijo(+Problema, +Ancestros:list, +I:integer, +Ts0:list,
%!                -Ts:list) is det.
%
%   Ts es Ts0 con el I-ésimo hijo expandido.
expandir_hijo(Problema, Ancestros, I, Ts0, Ts) :-
    nth1(I, Ts0, T0-C, Resto),
    expandir(T0, Problema, Ancestros, T1),
    nth1(I, Ts, T1-C, Resto).

%!  f(+T, -F:number) is det.
%
%   F es el costo estimado del árbol de búsqueda T, o inf.
f(punta(_, F), F).
f(o(_, F, _), F).
f(y(_, F, _), F).
f(hecho(_, F, _), F).
f(imposible(_), inf).

%!  f_arco(+Hijo, -F:number) is det.
%
%   F es el costo del arco del hijo T-C más el costo estimado de T, o inf
%   si T es imposible.
f_arco(T-C, F) :-
    f(T, F0),
    (   F0 == inf
    ->  F = inf
    ;   F is C + F0
    ).

%!  menor(+Ts:list, -I:integer) is det.
%
%   I es la posición del hijo de Ts con el menor costo estimado, arco
%   incluido; ante un empate, el primero.
menor(Ts, I) :-
    maplist(f_arco, Ts, Fs),
    min_member(Min, Fs),
    nth1(I, Fs, Min),
    !.

%!  rehacer(+Tipo, +N, +Ts:list, -T) is det.
%
%   T es el árbol de búsqueda del nodo N de Tipo o o y con los hijos Ts: su
%   F se recalcula, y queda hecho o imposible si corresponde. Un nodo O sin
%   hijos es imposible.
rehacer(o, N, Ts, T) :-
    maplist(f_arco, Ts, Fs),
    (   min_member(F0, Fs)
    ->  F = F0
    ;   F = inf
    ),
    (   F == inf
    ->  T = imposible(N)
    ;   nth1(I, Fs, F),
        nth1(I, Ts, hecho(_, _, A)-C)
    ->  T = hecho(N, F, o(N, A-C))
    ;   T = o(N, F, Ts)
    ).
rehacer(y, N, Ts, T) :-
    maplist(f_arco, Ts, Fs),
    (   memberchk(inf, Fs)
    ->  T = imposible(N)
    ;   sum_list(Fs, F),
        (   maplist(arco_resuelto, Ts, Arcos)
        ->  T = hecho(N, F, y(N, Arcos))
        ;   T = y(N, F, Ts)
        )
    ).

%!  arco_resuelto(+Hijo, -Arco) is semidet.
%
%   Arco es A-C si el hijo T-C está resuelto con el árbol A.
arco_resuelto(hecho(_, _, A)-C, A-C).

%!  arbol_viaje(+Busqueda, +De, +A, -Arbol, -Costo:number,
%!              -Expandidos:integer) is semidet.
%
%   Con Busqueda igual a mejor(E), Arbol es el árbol de ruta(De, A) que
%   halla mejor/5 con la estimación E.
arbol_viaje(mejor(E), De, A, Arbol, Costo, Expandidos) :-
    mejor(rio(E), ruta(De, A), Arbol, Costo, Expandidos).
