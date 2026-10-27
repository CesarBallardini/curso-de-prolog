:- encoding(utf8).

% Capítulo 7 - Soluciones de los ejercicios.
%
%?- reversa([ana, luis, eva], R).
%?- sacar(luis, [ana, luis, eva], R).

% --- Ejercicio 3 -----------------------------------------------------------

%!  primero_y_ultimo(?L, ?P, ?U) is nondet.
%
%   P es el primero de L y U el último. Con L libre, enumera listas cada vez
%   más largas que empiezan con P y terminan con U, sin fin.
primero_y_ultimo([P|Resto], P, U) :-
    last([P|Resto], U).

% --- Ejercicio 4 -----------------------------------------------------------

% sin_el_primero(L, R): R es L sin su primer elemento. No requiere recursión:
% la unificación de la cabeza descompone la lista.
sin_el_primero([_|Resto], Resto).

% --- Ejercicio 5 -----------------------------------------------------------

%!  cuantos_gatos(+L, -N) is det.
%
%   N es la cantidad de apariciones de gato en L.
cuantos_gatos([], 0).
cuantos_gatos([gato|Resto], N) :-
    cuantos_gatos(Resto, Faltan),
    N is Faltan + 1.
cuantos_gatos([Otro|Resto], N) :-
    Otro \== gato,
    cuantos_gatos(Resto, N).

% --- Ejercicio 6 -----------------------------------------------------------

%!  empieza_con(+L, ?Principio) is nondet.
%
%   L empieza con los elementos de Principio.
empieza_con(L, Principio) :-
    append(Principio, _, L).

% --- Ejercicio 7 -----------------------------------------------------------

%!  reversa(+L, -R) is det.
%!  reversa(-L, +R) is semidet.
%
%   R es L en orden inverso, sin usar reverse/2. Con L libre, después de la
%   respuesta no termina.
reversa([], []).
reversa([X|Resto], R) :-
    reversa(Resto, RestoAlReves),
    append(RestoAlReves, [X], R).

% --- Ejercicio 8 -----------------------------------------------------------

%!  sacar(+X, +L, -R) is semidet.
%
%   R es L sin la primera aparición de X.
sacar(X, [X|Resto], Resto).
sacar(X, [Otro|Resto], [Otro|RestoR]) :-
    Otro \== X,
    sacar(X, Resto, RestoR).

% --- Ejercicio 9 -----------------------------------------------------------

%!  es_sublista(?S, +L) is nondet.
%
%   Los elementos de S aparecen contiguos y en orden en L.
es_sublista(S, L) :-
    append(_, Atras, L),
    append(S, _, Atras).

%!  es_subsecuencia(?S, +L) is nondet.
%
%   Los elementos de S aparecen en L en el mismo orden, no necesariamente
%   contiguos. Con S libre, enumera cada subsecuencia de L una sola vez.
es_subsecuencia([], []).
es_subsecuencia([X|Resto], [X|Otros]) :-
    es_subsecuencia(Resto, Otros).
es_subsecuencia(S, [_|Otros]) :-
    es_subsecuencia(S, Otros).

% --- Ejercicio 12 ----------------------------------------------------------

%!  todos_gatos(?L) is nondet.
%
%   Todos los elementos de L son gato. Plantilla 11. Con L libre, enumera
%   listas de gatos de largo creciente, sin fin.
todos_gatos([]).
todos_gatos([gato|Resto]) :-
    todos_gatos(Resto).

%!  algun_gato(?L) is nondet.
%
%   Alguno de los elementos de L es gato. Plantilla 10. Con L libre, enumera
%   listas con gato en cada posición, sin fin.
algun_gato([gato|_]).
algun_gato([_|Resto]) :-
    algun_gato(Resto).

% --- Ejercicio 13 ----------------------------------------------------------

%!  duplicar(+L, -R) is det.
%!  duplicar(-L, +R) is semidet.
%
%   R tiene cada elemento de L repetido dos veces.
%   El resultado se escribe en la cabeza, no se arma en el cuerpo.
duplicar([], []).
duplicar([X|Resto], [X, X|Otros]) :-
    duplicar(Resto, Otros).

% --- Ejercicio 15 ----------------------------------------------------------

% segundo(L, X): X es el segundo elemento de L.
segundo([_, X|_], X).

% --- Ejercicio 17 ----------------------------------------------------------

% materias(L): L es la lista de materias, en orden.
materias([logica, algebra, fisica, quimica]).

%!  materia_en(?N, ?M) is nondet.
%
%   M es la materia que ocupa la posición N de la lista, contando desde 1.
materia_en(N, M) :-
    materias(Lista),
    nth1(N, Lista, M).

% --- Ejercicio 19 ----------------------------------------------------------

%!  suffix(?Xs, +Ys) is nondet.
%
%   Xs es un sufijo de Ys: los últimos elementos de Ys, en el mismo orden.
%   Con Xs libre, enumera los sufijos de Ys del más largo al más corto.
suffix(Xs, Xs).
suffix(Xs, [_|Ys]) :-
    suffix(Xs, Ys).

% --- Ejercicio 20 ----------------------------------------------------------

%!  adjacent(?X, ?Y, +Zs) is nondet.
%
%   X e Y son elementos adyacentes de Zs: Y está inmediatamente después de X.
adjacent(X, Y, Zs) :-
    append(_, [X, Y|_], Zs).

% --- Ejercicio 21 ----------------------------------------------------------

%!  selecciona(?X, +Xs, ?Ys) is nondet.
%!  selecciona(?X, ?Xs, +Ys) is nondet.
%
%   Ys es Xs sin una de las apariciones de X: una respuesta por cada
%   aparición. Con Ys dada y Xs libre, inserta X en cada posición de Ys.
selecciona(X, [X|Xs], Xs).
selecciona(X, [Y|Ys], [Y|Zs]) :-
    selecciona(X, Ys, Zs).

%!  permuta(+Xs, ?Ys) is nondet.
%
%   Ys es una permutación de Xs: elige el primer elemento con selecciona/3 y
%   permuta el resto. Una lista de n elementos distintos da n! respuestas.
permuta([], []).
permuta(Xs, [Z|Zs]) :-
    selecciona(Z, Xs, Ys),
    permuta(Ys, Zs).

% --- Ejercicio 22 ----------------------------------------------------------

%!  substitute(+X, +Y, +Xs, -Ys) is det.
%
%   Ys es Xs con cada aparición de X reemplazada por Y.
substitute(_, _, [], []).
substitute(X, Y, [X|Xs], [Y|Ys]) :-
    substitute(X, Y, Xs, Ys).
substitute(X, Y, [Z|Xs], [Z|Ys]) :-
    Z \== X,
    substitute(X, Y, Xs, Ys).

% --- Ejercicio 23 ----------------------------------------------------------

%!  elimina(+Xs, +X, -Ys) is det.
%
%   Ys es Xs sin ninguna aparición de X.
elimina([], _, []).
elimina([X|Xs], X, Ys) :-
    elimina(Xs, X, Ys).
elimina([Y|Xs], X, [Y|Ys]) :-
    Y \== X,
    elimina(Xs, X, Ys).

% --- Ejercicio 24 ----------------------------------------------------------

%!  ocurre(?X, +L) is nondet.
%
%   X aparece en algún nivel de L, que puede contener listas anidadas: es
%   un elemento de L o aparece en un elemento de L que es una lista. Una
%   respuesta por cada aparición; las listas internas también son respuestas.
ocurre(X, [X|_]).
ocurre(X, [Lista|_]) :-
    ocurre(X, Lista).
ocurre(X, [_|Resto]) :-
    ocurre(X, Resto).

% --- Ejercicio 25 ----------------------------------------------------------

% arbol_ejemplo(T): T es el árbol binario de ejemplo.
arbol_ejemplo(tree(1, tree(2, void, tree(4, void, void)),
                   tree(3, tree(5, tree(7, void, void), void),
                        tree(6, void, void)))).

%!  binary_tree(+T) is semidet.
%
%   T es un árbol binario: void, o tree(Elemento, Izquierdo, Derecho) con
%   dos árboles binarios como subárboles.
binary_tree(void).
binary_tree(tree(_, Left, Right)) :-
    binary_tree(Left),
    binary_tree(Right).

%!  tree_member(?X, +T) is nondet.
%
%   X es el elemento de alguno de los nodos del árbol binario T. Enumera los
%   elementos en preorden: el nodo, después el subárbol izquierdo y después
%   el derecho.
tree_member(X, tree(X, _, _)).
tree_member(X, tree(_, Left, _)) :-
    tree_member(X, Left).
tree_member(X, tree(_, _, Right)) :-
    tree_member(X, Right).

%!  lista_hojas(+T, -Hojas) is det.
%
%   Hojas es la lista de los elementos de las hojas de T, de izquierda a
%   derecha. Una hoja es un nodo con los dos subárboles vacíos; las dos
%   últimas cláusulas excluyen ese caso con \==.
lista_hojas(void, []).
lista_hojas(tree(X, void, void), [X]).
lista_hojas(tree(_, Left, Right), Hojas) :-
    Left \== void,
    lista_hojas(Left, HojasL),
    lista_hojas(Right, HojasR),
    append(HojasL, HojasR, Hojas).
lista_hojas(tree(_, void, Right), Hojas) :-
    Right \== void,
    lista_hojas(Right, Hojas).

% --- Ejercicio 26 ----------------------------------------------------------

%!  preorder(+T, -Xs) is det.
%
%   Xs es el recorrido en preorden de T: el nodo, el subárbol izquierdo y el
%   derecho.
preorder(void, []).
preorder(tree(X, L, R), Xs) :-
    preorder(L, Ls),
    preorder(R, Rs),
    append([X|Ls], Rs, Xs).

%!  inorder(+T, -Xs) is det.
%
%   Xs es el recorrido en inorden de T: el subárbol izquierdo, el nodo y el
%   derecho.
inorder(void, []).
inorder(tree(X, L, R), Xs) :-
    inorder(L, Ls),
    inorder(R, Rs),
    append(Ls, [X|Rs], Xs).

%!  postorder(+T, -Xs) is det.
%
%   Xs es el recorrido en postorden de T: el subárbol izquierdo, el derecho
%   y el nodo.
postorder(void, []).
postorder(tree(X, L, R), Xs) :-
    postorder(L, Ls),
    postorder(R, Rs),
    append(Rs, [X], Rs1),
    append(Ls, Rs1, Xs).
