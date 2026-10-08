:- encoding(utf8).

% Capítulo 22 - Pares, library(assoc) y library(ordsets).
%
% por_largo/2 ordena nombres por su longitud con la técnica de decorar,
% ordenar y desdecorar. hijos_por_padre/1 construye un assoc de cada padre a
% la lista de sus hijos. Los conjuntos ordenados de ordsets responden qué
% personas están en dos grupos, o en uno y no en el otro.
%
%?- por_largo([pedro, ana, luis, eva], L).
%?- hijos_por_padre(A), get_assoc(pedro, A, Hijos).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

%!  por_largo(+Nombres:list(atom), -Ordenados:list(atom)) is det.
%
%   Ordenados son los Nombres de menor a mayor longitud; con la misma
%   longitud, en el orden de Nombres. Decora cada nombre con su longitud,
%   ordena por la clave y quita la decoración.
por_largo(Nombres, Ordenados) :-
    map_list_to_pairs(atom_length, Nombres, Pares),
    keysort(Pares, Ordenadas),
    pairs_values(Ordenadas, Ordenados).

%!  hijos_por_padre(-Assoc) is det.
%
%   Assoc relaciona cada padre con la lista de sus hijos, en el orden de los
%   hechos.
hijos_por_padre(Assoc) :-
    findall(P-H, padre(P, H), Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    list_to_assoc(Grupos, Assoc).

%!  agregar_hijo(+Padre, +Hijo, +Assoc0, -Assoc) is det.
%
%   Assoc es Assoc0 con Hijo agregado a los hijos de Padre. Assoc0 no cambia:
%   put_assoc/4 construye un assoc nuevo.
agregar_hijo(Padre, Hijo, Assoc0, Assoc) :-
    (   get_assoc(Padre, Assoc0, Hijos0)
    ->  true
    ;   Hijos0 = []
    ),
    append(Hijos0, [Hijo], Hijos),
    put_assoc(Padre, Assoc0, Hijos, Assoc).

%!  en_los_dos(+A:list, +B:list, -Ambos:list) is det.
%
%   Ambos son los elementos que están en A y en B, como conjunto ordenado.
en_los_dos(A, B, Ambos) :-
    list_to_ord_set(A, SA),
    list_to_ord_set(B, SB),
    ord_intersection(SA, SB, Ambos).

%!  solo_en_el_primero(+A:list, +B:list, -Solo:list) is det.
%
%   Solo son los elementos de A que no están en B, como conjunto ordenado.
solo_en_el_primero(A, B, Solo) :-
    list_to_ord_set(A, SA),
    list_to_ord_set(B, SB),
    ord_subtract(SA, SB, Solo).
