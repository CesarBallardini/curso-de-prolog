:- encoding(utf8).

% Capítulo 8 - Soluciones de los ejercicios.
%
%?- promedio([10, 20, 30], P).
%?- maximo([3, 9, 4], M).

% --- Ejercicio 2 -----------------------------------------------------------

%!  triple(+N, -T) is det.
%
%   T es el triple de N.
triple(N, T) :-
    T is N * 3.

% --- Ejercicio 4 -----------------------------------------------------------

%!  es_par(+N) is semidet.
%
%   N es par.
es_par(N) :-
    0 =:= N mod 2.

% --- Ejercicio 5 -----------------------------------------------------------

%!  mayor_de_los_dos(+A, +B, -M) is det.
%
%   M es el mayor de los dos números.
mayor_de_los_dos(A, B, A) :-
    A >= B.
mayor_de_los_dos(A, B, B) :-
    A < B.

% --- Ejercicio 6 -----------------------------------------------------------

%!  cuantos_mayores(+L, -N) is det.
%
%   N es la cantidad de números de L mayores que 18.
cuantos_mayores([], 0).
cuantos_mayores([X|Resto], N) :-
    X > 18,
    cuantos_mayores(Resto, Faltan),
    N is Faltan + 1.
cuantos_mayores([X|Resto], N) :-
    X =< 18,
    cuantos_mayores(Resto, N).

% --- Ejercicio 7 -----------------------------------------------------------

%!  promedio(+L, -P) is semidet.
%
%   P es el promedio de los números de L.
%   Un único recorrido con dos acumuladores: la suma y la cantidad.
promedio(L, P) :-
    recorriendo(L, 0, 0, Suma, Cuantos),
    Cuantos > 0,
    P is Suma / Cuantos.

%!  recorriendo(+L, +SumaHasta, +CuantosHasta, -Suma, -Cuantos) is det.
%
%   Suma y Cuantos son SumaHasta y CuantosHasta más la suma y la cantidad de
%   los elementos de L.
recorriendo([], Suma, Cuantos, Suma, Cuantos).
recorriendo([X|Resto], SumaHasta, CuantosHasta, Suma, Cuantos) :-
    SumaAhora is SumaHasta + X,
    CuantosAhora is CuantosHasta + 1,
    recorriendo(Resto, SumaAhora, CuantosAhora, Suma, Cuantos).

% --- Ejercicio 8 -----------------------------------------------------------

%!  maximo(+L, -M) is semidet.
%
%   M es el mayor de L. La lista vacía no tiene máximo, por lo que el predicado
%   falla para ella.
maximo([X|Resto], M) :-
    buscando_maximo(Resto, X, M).

%!  buscando_maximo(+L, +Hasta, -M) is det.
%
%   M es el mayor entre Hasta y los elementos de L.
buscando_maximo([], M, M).
buscando_maximo([X|Resto], Hasta, M) :-
    X > Hasta,
    buscando_maximo(Resto, X, M).
buscando_maximo([X|Resto], Hasta, M) :-
    X =< Hasta,
    buscando_maximo(Resto, Hasta, M).

% --- Ejercicio 9 -----------------------------------------------------------

%!  factorial(+N, -F) is semidet.
%
%   F es el factorial de N.
factorial(0, 1).
factorial(N, F) :-
    N > 0,
    Anterior is N - 1,
    factorial(Anterior, FactorialAnterior),
    F is N * FactorialAnterior.

% --- Ejercicio 10 ----------------------------------------------------------

%!  cuenta_atras(+N, -L) is semidet.
%
%   L es la lista de los enteros de N a 1, en ese orden.
cuenta_atras(0, []).
cuenta_atras(N, [N|Resto]) :-
    N > 0,
    Anterior is N - 1,
    cuenta_atras(Anterior, Resto).

%!  cuenta_atras_con(+N, -L) is semidet.
%
%   La misma lista, con acumulador: se cuenta de 1 a N y cada número se agrega
%   al comienzo de la lista acumulada, de modo que N queda primero.
cuenta_atras_con(N, L) :-
    contando_atras(1, N, [], L).

%!  contando_atras(+Desde, +N, +Hasta, -L) is semidet.
%
%   L es Hasta con los enteros de Desde a N agregados al comienzo, el mayor
%   primero. Desde avanza de uno en uno; Hasta es el acumulador.
contando_atras(Desde, N, L, L) :-
    Desde > N.
contando_atras(Desde, N, Hasta, L) :-
    Desde =< N,
    Siguiente is Desde + 1,
    contando_atras(Siguiente, N, [Desde|Hasta], L).

% --- Ejercicio 12 ----------------------------------------------------------

%!  hasta(+N, +X) is semidet.
%
%   Se cumple si X es N o un entero menor que N, avanzando de uno en uno desde
%   X. Con los números predefinidos, la unificación ya no garantiza la
%   terminación, y es necesario reponer la guarda X < N, que con la notación
%   s(s(cero)) aportaba la estructura del término.
hasta(N, N).
hasta(N, X) :-
    X < N,
    Siguiente is X + 1,
    hasta(N, Siguiente).

% --- Ejercicio 14 ----------------------------------------------------------

%!  suma_hasta_sin(+N, -S) is semidet.
%
%   S es la suma de 1 a N, sin acumulador.
suma_hasta_sin(0, 0).
suma_hasta_sin(N, S) :-
    N > 0,
    Anterior is N - 1,
    suma_hasta_sin(Anterior, SumaAnterior),
    S is SumaAnterior + N.

%!  suma_hasta_con(+N, -S) is semidet.
%
%   La misma suma, con acumulador.
suma_hasta_con(N, S) :-
    sumando_hasta(N, 0, S).

%!  sumando_hasta(+N, +Hasta, -S) is semidet.
%
%   S es Hasta más la suma de 1 a N.
sumando_hasta(0, Acumulado, Acumulado).
sumando_hasta(N, Hasta, S) :-
    N > 0,
    Ahora is Hasta + N,
    Anterior is N - 1,
    sumando_hasta(Anterior, Ahora, S).

% --- Ejercicio 17 ----------------------------------------------------------

%!  enesimo(+Lista, ?N, ?X) is nondet.
%
%   X es el elemento que ocupa la posición N de Lista, contando desde 1. La
%   llamada recursiva genera la posición en el resto de la lista, y is/2 la
%   calcula o la compara: N puede llegar libre o ligado.
enesimo([X|_], 1, X).
enesimo([_|Resto], N, X) :-
    enesimo(Resto, Anterior, X),
    N is Anterior + 1.

% --- Ejercicio 18 ----------------------------------------------------------

%!  ordered(+Xs) is semidet.
%
%   La lista de números Xs está ordenada en forma ascendente.
ordered([]).
ordered([_]).
ordered([X, Y|Ys]) :-
    X =< Y,
    ordered([Y|Ys]).

%!  ordena(+Xs, -Ys) is det.
%
%   Ys tiene los elementos de Xs en orden ascendente, con las repeticiones
%   incluidas. Ordenamiento por inserción: se ordena el resto y se inserta el
%   primero en su lugar.
ordena([], []).
ordena([X|Xs], Ys) :-
    ordena(Xs, Zs),
    insert(X, Zs, Ys).

%!  insert(+X, +Ys, -Zs) is det.
%
%   Zs es la lista ordenada Ys con X insertado en su lugar.
insert(X, [], [X]).
insert(X, [Y|Ys], [Y|Zs]) :-
    X > Y,
    insert(X, Ys, Zs).
insert(X, [Y|Ys], [X, Y|Ys]) :-
    X =< Y.

% --- Ejercicio 19 ----------------------------------------------------------

% arbol_ejemplo(T): T es el árbol binario de ejemplo.
arbol_ejemplo(tree(1, tree(2, void, tree(4, void, void)),
                   tree(3, tree(5, tree(7, void, void), void),
                        tree(6, void, void)))).

%!  profundidad(+T, -P) is det.
%
%   P es la profundidad del árbol T: la cantidad de aristas del camino más
%   largo desde la raíz hasta una hoja. Un árbol de un solo nodo tiene
%   profundidad 0 y, por convención, el árbol vacío tiene profundidad -1.
profundidad(void, -1).
profundidad(tree(_, Izq, Der), P) :-
    profundidad(Izq, PIzq),
    profundidad(Der, PDer),
    mayor_de_los_dos(PIzq, PDer, Mayor),
    P is Mayor + 1.

%!  sum_tree(+T, -Suma) is det.
%
%   Suma es la suma de los números de los nodos del árbol T.
sum_tree(void, 0).
sum_tree(tree(X, Izq, Der), Suma) :-
    sum_tree(Izq, SumaIzq),
    sum_tree(Der, SumaDer),
    Suma is X + SumaIzq + SumaDer.

%!  cantidad_hojas(+T, -N) is det.
%
%   N es la cantidad de hojas del árbol T. La tercera cláusula excluye el
%   caso de la segunda: los dos hijos no son vacíos a la vez.
cantidad_hojas(void, 0).
cantidad_hojas(tree(_, void, void), 1).
cantidad_hojas(tree(_, Izq, Der), N) :-
    [Izq, Der] \== [void, void],
    cantidad_hojas(Izq, NIzq),
    cantidad_hojas(Der, NDer),
    N is NIzq + NDer.

%!  lista_nivel(+T, +N, -L) is det.
%
%   L es la lista de los valores de los nodos del nivel N del árbol T, de
%   izquierda a derecha. La raíz está en el nivel 0.
lista_nivel(void, _, []).
lista_nivel(tree(X, _, _), 0, [X]).
lista_nivel(tree(_, Izq, Der), N, L) :-
    N > 0,
    Anterior is N - 1,
    lista_nivel(Izq, Anterior, LIzq),
    lista_nivel(Der, Anterior, LDer),
    append(LIzq, LDer, L).

% --- Ejercicio 20 ----------------------------------------------------------

%!  ocurrencias(+X, +Lista, -Posiciones) is det.
%
%   Posiciones es la lista de las posiciones, contando desde 1, en que X
%   aparece en Lista. Las posiciones del resto se calculan primero y después
%   se desplazan en uno, porque el resto comienza una posición más adelante.
ocurrencias(_, [], []).
ocurrencias(X, [X|Resto], [1|Posiciones]) :-
    ocurrencias(X, Resto, EnElResto),
    suma_uno(EnElResto, Posiciones).
ocurrencias(X, [Y|Resto], Posiciones) :-
    X \== Y,
    ocurrencias(X, Resto, EnElResto),
    suma_uno(EnElResto, Posiciones).

%!  suma_uno(+Ns, -Ms) is det.
%
%   Ms es la lista Ns con cada número aumentado en uno.
suma_uno([], []).
suma_uno([N|Ns], [M|Ms]) :-
    M is N + 1,
    suma_uno(Ns, Ms).

% --- Ejercicio 21 ----------------------------------------------------------

%!  intercala(+L1, +L2, +N1, +N2, -R) is nondet.
%
%   R alterna tramos de N1 elementos de L1 con tramos de N2 elementos de L2.
%   El primer tramo puede ser de cualquiera de las dos listas.
intercala(L1, L2, N1, N2, R) :-
    intercalando(L1, L2, N1, N2, R).
intercala(L1, L2, N1, N2, R) :-
    intercalando(L2, L1, N2, N1, R).

%!  intercalando(+L1, +L2, +N1, +N2, -R) is semidet.
%
%   R comienza con un tramo de N1 elementos de L1 y sigue alternando, con
%   los papeles de las dos listas intercambiados.
intercalando([], [], _, _, []).
intercalando(L1, L2, N1, N2, R) :-
    length(Tramo, N1),
    append(Tramo, Resto1, L1),
    append(Tramo, RestoR, R),
    intercalando(L2, Resto1, N2, N1, RestoR).

% --- Ejercicio 22 ----------------------------------------------------------

% arbol_ponderado(Nombre, T): T es uno de los dos árboles del enunciado.
arbol_ponderado(arbol1, tree(0, tree(0, tree(3, void, void),
                                        tree(9, void, void)),
                                tree(0, tree(5, void, void),
                                        tree(6, void, void)))).
arbol_ponderado(arbol2, tree(0, tree(0, tree(0, tree(3, void, void),
                                                tree(5, void, void)),
                                        tree(6, void, void)),
                                tree(9, void, void))).

%!  peso_arbol(+T, -Peso) is det.
%
%   Peso es la suma de los pesos de las hojas de T, cada uno multiplicado por
%   su nivel. Los nodos internos llevan el valor 0 y no aportan al peso.
peso_arbol(T, Peso) :-
    peso_desde(T, 0, Peso).

%!  peso_desde(+T, +Nivel, -Peso) is det.
%
%   Peso es el peso de T cuando su raíz está en el nivel Nivel.
peso_desde(void, _, 0).
peso_desde(tree(X, Izq, Der), Nivel, Peso) :-
    Siguiente is Nivel + 1,
    peso_desde(Izq, Siguiente, PesoIzq),
    peso_desde(Der, Siguiente, PesoDer),
    Peso is X * Nivel + PesoIzq + PesoDer.

%!  mapeo_arboles(+Arboles, -T) is semidet.
%
%   T es el árbol de menor peso de la lista Arboles; si hay varios, el
%   primero. La lista vacía no tiene un árbol de menor peso.
mapeo_arboles([A|As], T) :-
    peso_arbol(A, Peso),
    buscando_menor(As, A, Peso, T).

%!  buscando_menor(+Arboles, +Hasta, +PesoHasta, -T) is det.
%
%   T es el de menor peso entre Hasta, de peso PesoHasta, y los de Arboles.
buscando_menor([], T, _, T).
buscando_menor([A|As], _, PesoHasta, T) :-
    peso_arbol(A, Peso),
    Peso < PesoHasta,
    buscando_menor(As, A, Peso, T).
buscando_menor([A|As], Hasta, PesoHasta, T) :-
    peso_arbol(A, Peso),
    Peso >= PesoHasta,
    buscando_menor(As, Hasta, PesoHasta, T).

% --- Ejercicio 23 ----------------------------------------------------------

% arbol_nario(T): T es el árbol n-ario del enunciado.
arbol_nario(nodo(a, [nodo(b, [nodo(e, []), nodo(f, []), nodo(g, [])]),
                     nodo(c, []),
                     nodo(d, [nodo(h, [])])])).

%!  es_hoja(+T) is semidet.
%
%   T es un nodo sin descendientes.
es_hoja(nodo(_, [])).

%!  cantidad(+T, -N) is det.
%
%   N es la cantidad de nodos del árbol n-ario T.
cantidad(nodo(_, Hijos), N) :-
    cantidad_bosque(Hijos, NHijos),
    N is NHijos + 1.

%!  cantidad_bosque(+Arboles, -N) is det.
%
%   N es la cantidad de nodos de todos los árboles de la lista Arboles.
cantidad_bosque([], 0).
cantidad_bosque([A|As], N) :-
    cantidad(A, NA),
    cantidad_bosque(As, NAs),
    N is NA + NAs.

%!  lista_hojas_n(+T, -L) is det.
%
%   L es la lista de los valores de las hojas del árbol n-ario T, de izquierda
%   a derecha.
lista_hojas_n(nodo(X, []), [X]).
lista_hojas_n(nodo(_, [H|Hs]), L) :-
    hojas_bosque([H|Hs], L).

%!  hojas_bosque(+Arboles, -L) is det.
%
%   L es la lista de los valores de las hojas de los árboles de Arboles.
hojas_bosque([], []).
hojas_bosque([A|As], L) :-
    lista_hojas_n(A, LA),
    hojas_bosque(As, LAs),
    append(LA, LAs, L).

%!  quita_hojas(+T, -T2) is semidet.
%
%   T2 es el árbol n-ario T sin sus hojas. Falla si T es una hoja.
quita_hojas(nodo(X, [H|Hs]), nodo(X, Hijos)) :-
    quita_hojas_bosque([H|Hs], Hijos).

%!  quita_hojas_bosque(+Arboles, -Arboles2) is det.
%
%   Arboles2 son los árboles de Arboles que no son hojas, cada uno sin sus
%   hojas.
quita_hojas_bosque([], []).
quita_hojas_bosque([nodo(_, [])|As], As2) :-
    quita_hojas_bosque(As, As2).
quita_hojas_bosque([nodo(X, [H|Hs])|As], [A2|As2]) :-
    quita_hojas(nodo(X, [H|Hs]), A2),
    quita_hojas_bosque(As, As2).

% --- Ejercicio 24 ----------------------------------------------------------

% arbol_horizontal(T): T es el árbol del enunciado, como árbol n-ario.
arbol_horizontal(nodo(a, [nodo(c, [nodo(t, []),
                                   nodo(r, [nodo(q, []), nodo(z, [])])]),
                          nodo(j, [nodo(h, []), nodo(m, [])])])).

%!  recorrido_horizontal(+T, -L) is det.
%
%   L es la lista de los valores del árbol n-ario T, nivel por nivel y cada
%   nivel de izquierda a derecha.
recorrido_horizontal(T, L) :-
    recorriendo([T], [], L).

%!  recorriendo(+LNodos, +LDesarrollado, -L) is det.
%
%   LNodos son los árboles que faltan visitar, en orden; LDesarrollado son
%   los valores ya visitados. Se retira el primero de LNodos, su valor pasa
%   al final de LDesarrollado y sus hijos, al final de LNodos.
recorriendo([], LDesarrollado, LDesarrollado).
recorriendo([nodo(X, Hijos)|LNodos], LDesarrollado, L) :-
    append(LDesarrollado, [X], Desarrollado2),
    append(LNodos, Hijos, LNodos2),
    recorriendo(LNodos2, Desarrollado2, L).

% --- Ejercicio 25 ----------------------------------------------------------

%!  secuencia_faltante(+L1, -L2) is det.
%
%   L2 son los enteros que faltan entre elementos consecutivos de L1, que
%   está ordenada en forma estrictamente ascendente.
secuencia_faltante([], []).
secuencia_faltante([_], []).
secuencia_faltante([A, B|Resto], L2) :-
    faltantes_entre(A, B, Faltan),
    secuencia_faltante([B|Resto], FaltanResto),
    append(Faltan, FaltanResto, L2).

%!  faltantes_entre(+A, +B, -L) is det.
%
%   L es la lista de los enteros mayores que A y menores que B.
faltantes_entre(A, B, []) :-
    A + 1 >= B.
faltantes_entre(A, B, [C|Cs]) :-
    C is A + 1,
    C < B,
    faltantes_entre(C, B, Cs).
