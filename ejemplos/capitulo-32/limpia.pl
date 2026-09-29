:- encoding(utf8).

% Capítulo 32 - Representaciones limpias: el mismo árbol con los casos
% distinguidos por una prueba de tipo y por su functor.
%
% Una lista anidada, [a, [b, c]], es una representación «por defecto»: una
% hoja es cualquier término que no sea una lista, y aplanar_ingenuo/2 debe
% preguntarlo con is_list/1. El árbol limpio marca cada caso con su propio
% functor: h(X) es una hoja y n(Hijos) un nodo. hojas/2 lo recorre por
% unificación, sin pruebas de tipo. a_arbol/2 convierte una vez, en el borde,
% la lista anidada en árbol limpio.
%
%?- aplanar_ingenuo([a, [b, c]], P).
%?- hojas(n([h(a), n([h(b), h(c)])]), H).
%?- a_arbol([a, [b, c]], A).

%!  aplanar_ingenuo(+Lista:list, -Plana:list) is det.
%
%   Plana tiene los elementos de Lista y de sus listas anidadas, en orden.
%   Un elemento que no es una lista en el momento de la llamada es una hoja.
aplanar_ingenuo([], []).
aplanar_ingenuo([X|Xs], Plana) :-
    (   is_list(X)
    ->  aplanar_ingenuo(X, P1)
    ;   P1 = [X]
    ),
    aplanar_ingenuo(Xs, P2),
    append(P1, P2, Plana).

%!  hojas(?Arbol, ?Hojas:list) is nondet.
%
%   Hojas son las hojas de Arbol, de izquierda a derecha. Arbol es h(X), una
%   hoja con el valor X, o n(Hijos), un nodo con la lista de sus hijos.
hojas(h(X), [X]).
hojas(n(Hijos), Hojas) :-
    maplist(hojas, Hijos, Listas),
    append(Listas, Hojas).

%!  a_arbol(+Lista:list, -Arbol) is det.
%
%   Arbol es la lista anidada Lista como árbol limpio: cada lista es un nodo
%   n/1 y cada elemento que no es una lista, una hoja h/1. Lista debe llegar
%   sin variables: la prueba de tipo decide el caso una sola vez.
a_arbol(Lista, n(Hijos)) :-
    must_be(ground, Lista),
    maplist(elemento_a_arbol, Lista, Hijos).

%!  elemento_a_arbol(+Elemento, -Arbol) is det.
%
%   Arbol es n/1 si Elemento es una lista, y h(Elemento) si no lo es.
elemento_a_arbol(X, Arbol) :-
    (   is_list(X)
    ->  a_arbol(X, Arbol)
    ;   Arbol = h(X)
    ).
