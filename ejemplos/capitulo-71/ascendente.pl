:- encoding(utf8).

% Capítulo 71 - Búsqueda ascendente en un grafo Y/O.
%
% Martelli y Montanari (1973) proponen, además de la búsqueda descendente,
% un método ascendente que extiende el algoritmo de Dijkstra: en lugar de
% bajar desde el problema inicial, sube desde los problemas primitivos.
% Un nodo queda resuelto, con su costo exacto, cuando es el de menor costo
% provisorio entre los pendientes. Al resolverse, avisa a sus padres: un
% padre O toma como costo provisorio el menor costo de arco más costo de
% hijo que conoce; un padre Y queda listo cuando todos sus hijos están
% resueltos, con la suma. El método calcula el costo de todos los nodos
% que alcanza antes que el inicial, y exige costos no negativos, como el
% de Dijkstra. No construye el árbol, solo los costos; el grafo tiene que
% ser finito, porque se recorre entero para conocer los padres.
%
% solo-local: carga mapa.pl y hanoi.pl.
%
%?- ascendente(rio(cero), ruta(alamos, islas), C, R).

:- ensure_loaded(mapa).
:- ensure_loaded(hanoi).
:- use_module(library(assoc)).
:- use_module(library(heaps)).
:- use_module(library(pairs)).

%!  ascendente(+Problema, +Nodo, -Costo:number, -Resueltos:integer)
%!      is semidet.
%
%   Costo es el costo de un árbol solución óptimo de Nodo, calculado
%   desde los nodos primitivos hacia arriba; Resueltos es la cantidad de
%   nodos cuyo costo quedó calculado hasta llegar a Nodo. Falla si Nodo no
%   tiene solución.
ascendente(Problema, Nodo, Costo, Resueltos) :-
    alcanzables(Problema, Nodo, Nodos),
    padres(Problema, Nodos, Padres),
    pendientes(Problema, Nodos, Pendientes),
    include(primitivo(Problema), Nodos, Primitivos),
    pairs_keys_values(Pares, Primitivos, Ceros),
    maplist(=(0), Ceros),
    list_to_heap([], H0),
    foldl(agregar_al_monton, Pares, H0, H),
    empty_assoc(R0),
    subir(Problema, Nodo, Padres, H, Pendientes, R0, R),
    get_assoc(Nodo, R, Costo),
    assoc_to_keys(R, Ks),
    length(Ks, Resueltos).

%!  agregar_al_monton(+Par, +H0, -H) is det.
%
%   H es el montón H0 con Nodo, con prioridad Costo, para Par igual a
%   Nodo-Costo.
agregar_al_monton(Nodo-Costo, H0, H) :-
    add_to_heap(H0, Costo, Nodo, H).

%!  alcanzables(+Problema, +Nodo, -Nodos:list) is det.
%
%   Nodos son los nodos a los que se llega desde Nodo bajando por los
%   hijos de expansion/4, Nodo incluido, sin repetir.
alcanzables(Problema, Nodo, Nodos) :-
    empty_assoc(V0),
    put_assoc(Nodo, V0, si, V1),
    alcanzar([Nodo], Problema, V1, V),
    assoc_to_keys(V, Nodos).

%!  alcanzar(+Frontera:list, +Problema, +V0, -V) is det.
%
%   V es V0 más los nodos alcanzables desde la Frontera.
alcanzar([], _, V, V).
alcanzar([N|Ns], Problema, V0, V) :-
    (   \+ primitivo(Problema, N),
        expansion(Problema, N, _, Hijos)
    ->  pairs_keys(Hijos, Hs),
        nuevos(Hs, V0, V1, Nuevos),
        append(Ns, Nuevos, Frontera)
    ;   V1 = V0,
        Frontera = Ns
    ),
    alcanzar(Frontera, Problema, V1, V).

%!  nuevos(+Nodos:list, +V0, -V, -Nuevos:list) is det.
%
%   Nuevos son los Nodos que no están en V0; V es V0 con ellos.
nuevos([], V, V, []).
nuevos([N|Ns], V0, V, Nuevos) :-
    (   get_assoc(N, V0, _)
    ->  V1 = V0,
        Nuevos = Nuevos1
    ;   put_assoc(N, V0, si, V1),
        Nuevos = [N|Nuevos1]
    ),
    nuevos(Ns, V1, V, Nuevos1).

%!  padres(+Problema, +Nodos:list, -Padres) is det.
%
%   Padres asocia cada nodo con la lista de sus padres, cada uno
%   Padre-Tipo-Costo, con el Tipo del padre y el Costo del arco.
padres(Problema, Nodos, Padres) :-
    findall(H-(N-Tipo-C),
            ( member(N, Nodos),
              \+ primitivo(Problema, N),
              expansion(Problema, N, Tipo, Hijos),
              member(H-C, Hijos) ),
            Pares0),
    keysort(Pares0, Pares),
    group_pairs_by_key(Pares, Grupos),
    list_to_assoc(Grupos, Padres).

%!  pendientes(+Problema, +Nodos:list, -Pendientes) is det.
%
%   Pendientes asocia cada nodo Y con f(Faltan, Suma): cuántos hijos le
%   faltan resolver y la suma de costos de los resueltos.
pendientes(Problema, Nodos, Pendientes) :-
    findall(N-f(K, 0),
            ( member(N, Nodos),
              \+ primitivo(Problema, N),
              expansion(Problema, N, y, Hijos),
              length(Hijos, K) ),
            Pares),
    list_to_assoc(Pares, Pendientes).

%!  subir(+Problema, +Meta, +Padres, +H, +Pendientes, +R0, -R) is semidet.
%
%   R es R0 con el costo exacto de cada nodo que se resuelve, en orden de
%   costo, hasta resolver Meta. Falla si el montón se vacía antes.
subir(Problema, Meta, Padres, H0, P0, R0, R) :-
    get_from_heap(H0, Costo, Nodo, H1),
    (   get_assoc(Nodo, R0, _)
    ->  subir(Problema, Meta, Padres, H1, P0, R0, R)
    ;   put_assoc(Nodo, R0, Costo, R1),
        (   Nodo == Meta
        ->  R = R1
        ;   (   get_assoc(Nodo, Padres, Ps)
            ->  true
            ;   Ps = []
            ),
            foldl(avisar(Costo, R1), Ps, H1-P0, H2-P1),
            subir(Problema, Meta, Padres, H2, P1, R1, R)
        )
    ).

%!  avisar(+Costo:number, +R, +Padre, +S0, -S) is det.
%
%   S0 y S son pares Monton-Pendientes. Un hijo de costo Costo se acaba
%   de resolver: un Padre O entra al montón con ese costo más el del arco;
%   un Padre Y descuenta un hijo, y entra al montón con la suma cuando no
%   le falta ninguno.
avisar(Costo, R, Padre-Tipo-C, S0, S) :-
    (   get_assoc(Padre, R, _)
    ->  S = S0
    ;   avisar_tipo(Tipo, Padre, Costo, C, S0, S)
    ).

%!  avisar_tipo(+Tipo, +Padre, +Costo:number, +C:number, +S0, -S) is det.
%
%   Como avisar/5, para un Padre de Tipo o o y que todavía no está
%   resuelto; C es el costo del arco.
avisar_tipo(o, Padre, Costo, C, H0-P, H-P) :-
    F is Costo + C,
    add_to_heap(H0, F, Padre, H).
avisar_tipo(y, Padre, Costo, C, H0-P0, H-P) :-
    get_assoc(Padre, P0, f(K0, S0)),
    K is K0 - 1,
    S is S0 + Costo + C,
    put_assoc(Padre, P0, f(K, S), P),
    (   K =:= 0
    ->  add_to_heap(H0, S, Padre, H)
    ;   H = H0
    ).
