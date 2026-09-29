:- encoding(utf8).

% Capítulo 34 - Soluciones de los ejercicios 1 a 12, 15 y 16.
%
% El archivo repite las definiciones de los ejemplos que usan los
% ejercicios, para cargarse solo: conocidos/2 de abiertas.pl,
% concatenar_dif/3, vacia_dif/1, inorden_dif/2, invertir_app/2 e invertir/2
% de diferencia.pl, las colas de cola.pl y los diccionarios de
% diccionario.pl.
%
%?- longitud_abierta([a, b|_], N).
%?- bandera([azul, rojo, blanco, rojo, azul], B).
%?- phrase(preorden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio))), L).
%?- buscar_arbol(b, A, 2), buscar_arbol(a, A, 1), phrase(pares(A), P).
%?- nivelar(n(n(vacio, 4, vacio), 3, n(vacio, 9, vacio)), N).
%?- asociar_izquierda((a + b) + (c + d), S).

% --- Definiciones repetidas de los ejemplos ---

%!  conocidos(+Abierta:list, -Elementos:list) is det.
%
%   Elementos es la lista cerrada de los elementos ya presentes en la lista
%   abierta Abierta, que no cambia.
conocidos(Final, []) :-
    var(Final),
    !.
conocidos([X|Resto], [X|Xs]) :-
    conocidos(Resto, Xs).

% concatenar_dif(A, B, C): C es la lista diferencia A seguida de B.
concatenar_dif(L-M, M-F, L-F).

% vacia_dif(D): D es una lista diferencia sin elementos.
vacia_dif(L-L).

%!  inorden_dif(+Arbol, ?Dif) is det.
%
%   Dif, un par L-F, es la lista diferencia de los elementos de Arbol en
%   orden: L tiene esos elementos seguidos de F.
inorden_dif(vacio, L-L).
inorden_dif(n(Izq, X, Der), L-F) :-
    inorden_dif(Izq, L-[X|M]),
    inorden_dif(Der, M-F).

%!  invertir_app(+Lista:list, -Invertida:list) is det.
%
%   Invertida es Lista en orden inverso. append/3 agrega cada elemento al
%   final de lo ya invertido.
invertir_app([], []).
invertir_app([X|Xs], Invertida) :-
    invertir_app(Xs, I),
    append(I, [X], Invertida).

%!  invertir(+Lista:list, -Invertida:list) is det.
%
%   La misma relación, con listas diferencia.
invertir(Lista, Invertida) :-
    invertir_dif(Lista, Invertida-[]).

%!  invertir_dif(+Lista:list, ?Dif) is det.
%
%   Dif, un par L-F, es la lista diferencia de Lista en orden inverso.
invertir_dif([], L-L).
invertir_dif([X|Xs], L-F) :-
    invertir_dif(Xs, L-[X|F]).

% cola_vacia(C): C es la cola con contador sin elementos.
cola_vacia(cola(0, F, F)).

%!  encolar(+X, +Cola, -Cola1) is det.
%
%   Cola1 es Cola con X agregado al final, en un paso.
encolar(X, cola(N, Frente, [X|Fondo]), cola(N1, Frente, Fondo)) :-
    N1 is N + 1.

%!  desencolar(-X, +Cola, -Cola1) is semidet.
%
%   X es el primer elemento de Cola, y Cola1 el resto. Falla si Cola está
%   vacía.
desencolar(X, cola(N, [X|Frente], Fondo), cola(N1, Frente, Fondo)) :-
    N > 0,
    N1 is N - 1.

%!  buscar(+Clave, ?Dic:list, ?Valor) is semidet.
%
%   Dic es un diccionario incompleto: una lista abierta de pares
%   Clave-Valor, con claves distintas. Si Clave está en Dic, Valor unifica
%   con su valor; si no, el par Clave-Valor se agrega al final. Falla si la
%   clave está con otro valor.
buscar(Clave, [Clave0-Valor0|Resto], Valor) :-
    (   Clave = Clave0
    ->  Valor = Valor0
    ;   buscar(Clave, Resto, Valor)
    ).

%!  buscar_arbol(+Clave, ?Arbol, ?Valor) is semidet.
%
%   Arbol es un diccionario incompleto en forma de árbol binario de
%   búsqueda: t(Clave, Valor, Izq, Der), con los subárboles libres donde
%   todavía no hay entradas. Si Clave está, Valor unifica con su valor; si
%   no, el par se agrega en el lugar libre que le corresponde.
buscar_arbol(Clave, Arbol, Valor) :-
    (   var(Arbol)
    ->  Arbol = t(Clave, Valor, _, _)
    ;   Arbol = t(Clave0, Valor0, Izq, Der),
        compare(Orden, Clave, Clave0),
        buscar_en(Orden, Clave, Valor, Valor0, Izq, Der)
    ).

%!  buscar_en(+Orden, +Clave, ?Valor, ?Valor0, ?Izq, ?Der) is semidet.
%
%   Sigue la búsqueda de Clave según su Orden respecto de la raíz, cuyo
%   valor es Valor0.
buscar_en(=, _, Valor, Valor, _, _).
buscar_en(<, Clave, Valor, _, Izq, _) :-
    buscar_arbol(Clave, Izq, Valor).
buscar_en(>, Clave, Valor, _, _, Der) :-
    buscar_arbol(Clave, Der, Valor).

% --- Ejercicio 2 ---

%!  longitud_abierta(+Abierta:list, -N:integer) is det.
%
%   N es la cantidad de elementos ya presentes en la lista abierta Abierta,
%   que no cambia.
longitud_abierta(Abierta, N) :-
    longitud_abierta(Abierta, 0, N).

%!  longitud_abierta(+Abierta:list, +N0:integer, -N:integer) is det.
%
%   N es N0 más la cantidad de elementos presentes en Abierta.
longitud_abierta(Final, N, N) :-
    var(Final),
    !.
longitud_abierta([_|Resto], N0, N) :-
    N1 is N0 + 1,
    longitud_abierta(Resto, N1, N).

% --- Ejercicio 3 ---

%!  a_dif(+Lista:list, -Dif) is det.
%
%   Dif es la lista diferencia L-F con los elementos de Lista. Copia la
%   lista: recorre todos sus elementos.
a_dif(Lista, L-F) :-
    append(Lista, F, L).

%!  de_dif(+Dif, -Lista:list) is det.
%
%   Lista es la lista cerrada que representa la lista diferencia Dif. Liga
%   el final de Dif a [], en un paso: Dif ya no admite agregados.
de_dif(Lista-[], Lista).

% --- Ejercicio 4 ---

%!  bandera(+Bolitas:list, -Ordenadas:list) is det.
%
%   Ordenadas tiene las bolitas rojas, después las blancas y después las
%   azules de Bolitas, cada color en su orden original. Recorre Bolitas una
%   sola vez.
bandera(Bolitas, Ordenadas) :-
    distribuir(Bolitas, Ordenadas-Blancas, Blancas-Azules, Azules-[]).

%!  distribuir(+Bolitas:list, ?Rojas, ?Blancas, ?Azules) is det.
%
%   Rojas, Blancas y Azules son las listas diferencia de las bolitas de cada
%   color de Bolitas.
distribuir([], R-R, B-B, A-A).
distribuir([rojo|Xs], [rojo|R]-R0, B, A) :-
    distribuir(Xs, R-R0, B, A).
distribuir([blanco|Xs], R, [blanco|B]-B0, A) :-
    distribuir(Xs, R, B-B0, A).
distribuir([azul|Xs], R, B, [azul|A]-A0) :-
    distribuir(Xs, R, B, A-A0).

% --- Ejercicio 5 ---

%!  preorden(+Arbol)// is det.
%
%   Los elementos de Arbol en preorden: la raíz, los del subárbol izquierdo
%   y los del derecho.
preorden(vacio) -->
    [].
preorden(n(Izq, X, Der)) -->
    [X],
    preorden(Izq),
    preorden(Der).

%!  postorden(+Arbol)// is det.
%
%   Los elementos de Arbol en postorden: los del subárbol izquierdo, los del
%   derecho y la raíz.
postorden(vacio) -->
    [].
postorden(n(Izq, X, Der)) -->
    postorden(Izq),
    postorden(Der),
    [X].

% --- Ejercicio 7 ---

%!  elementos_cola(+Cola, -Lista:list) is det.
%
%   Lista tiene los elementos de Cola, del primero al último, como lista
%   cerrada. Cola no cambia.
elementos_cola(cola(N, Frente, _), Lista) :-
    length(Lista, N),
    append(Lista, _, Frente).

% --- Ejercicio 8 ---

% es_vacia_dif(C): la cola diferencia C no tiene elementos.
es_vacia_dif(F-F).

% --- Ejercicio 9 ---

%!  claves(+Dic:list, -Claves:list) is det.
%
%   Claves tiene las claves del diccionario incompleto Dic, en su orden,
%   sin ligar el final de Dic.
claves(Final, []) :-
    var(Final),
    !.
claves([Clave-_|Resto], [Clave|Claves]) :-
    claves(Resto, Claves).

% --- Ejercicio 10 ---

%!  pares(+Arbol)// is det.
%
%   Los pares Clave-Valor del diccionario incompleto Arbol, en el orden de
%   las claves. Un subárbol libre no tiene pares, y queda libre.
pares(Arbol) -->
    { var(Arbol) },
    !.
pares(t(Clave, Valor, Izq, Der)) -->
    pares(Izq),
    [Clave-Valor],
    pares(Der).

% --- Ejercicio 11 ---

%!  hojas(+Arbol)// is det.
%
%   Las hojas del árbol limpio Arbol, de izquierda a derecha: h(X) es una
%   hoja y n(Hijos) un nodo con la lista de sus hijos.
hojas(h(X)) -->
    [X].
hojas(n(Hijos)) -->
    hojas_lista(Hijos).

%!  hojas_lista(+Arboles:list)// is det.
%
%   Las hojas de cada árbol de Arboles, en orden.
hojas_lista([]) -->
    [].
hojas_lista([A|As]) -->
    hojas(A),
    hojas_lista(As).

% --- Ejercicio 15 ---

%!  nivelar(+Arbol, -Nivelado) is det.
%
%   Nivelado tiene la forma de Arbol, vacio o n(Izq, X, Der), con el máximo
%   de los elementos de Arbol en cada nodo. Un solo recorrido: los nodos
%   nuevos comparten la variable Max, que se liga al terminar.
nivelar(vacio, vacio).
nivelar(n(Izq, X, Der), Nivelado) :-
    nivelar(n(Izq, X, Der), Max, Nivelado, X, Max).

%!  nivelar(+Arbol, ?M, -Nivelado, +Max0:number, -Max:number) is det.
%
%   Nivelado tiene la forma de Arbol con M en cada nodo, y Max es el mayor
%   entre Max0 y los elementos de Arbol. M puede estar libre: se liga
%   después, cuando se conoce el máximo de todo el árbol.
nivelar(vacio, _, vacio, Max, Max).
nivelar(n(Izq, X, Der), M, n(Izq1, M, Der1), Max0, Max) :-
    Max1 is max(Max0, X),
    nivelar(Izq, M, Izq1, Max1, Max2),
    nivelar(Der, M, Der1, Max2, Max).

% --- Ejercicio 16 ---

%!  sumandos(+Suma, -Dif) is det.
%
%   Dif, un par L-F, es la lista diferencia de los sumandos de Suma, de
%   izquierda a derecha. Un sumando es todo término que no es una suma con
%   +; Suma es un término cerrado.
sumandos(Suma, L-F) :-
    (   Suma = A + B
    ->  sumandos(A, L-M),
        sumandos(B, M-F)
    ;   L = [Suma|F]
    ).

%!  asociar_izquierda_2(+Suma, -Normal) is det.
%
%   Normal tiene los sumandos de Suma, en el mismo orden, asociados a
%   izquierda. Dos recorridos: uno reúne los sumandos y otro construye la
%   suma.
asociar_izquierda_2(Suma, Normal) :-
    sumandos(Suma, [Primero|Resto]-[]),
    foldl(agregar_sumando, Resto, Primero, Normal).

% agregar_sumando(X, Suma0, Suma): Suma es Suma0 con X sumado a la derecha.
agregar_sumando(X, Suma0, Suma0 + X).

%!  asociar_izquierda(+Suma, -Normal) is det.
%
%   Normal tiene los sumandos de Suma, en el mismo orden, asociados a
%   izquierda. Una sola pasada: el sumando de más a la izquierda es el valor
%   inicial del acumulador, y agregar/3 suma los demás.
asociar_izquierda(Suma, Normal) :-
    (   Suma = A + B
    ->  asociar_izquierda(A, Normal0),
        agregar(B, Normal0, Normal)
    ;   Normal = Suma
    ).

%!  agregar(+Suma, +Normal0, -Normal) is det.
%
%   Normal es la suma asociada a izquierda Normal0 con los sumandos de Suma
%   agregados a la derecha, en orden.
agregar(Suma, Normal0, Normal) :-
    (   Suma = A + B
    ->  agregar(A, Normal0, Normal1),
        agregar(B, Normal1, Normal)
    ;   Normal = Normal0 + Suma
    ).
