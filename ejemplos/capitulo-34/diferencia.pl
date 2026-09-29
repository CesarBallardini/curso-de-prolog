:- encoding(utf8).

% Capítulo 34 - De append/3 a la lista diferencia.
%
% Un par L-F en el que F es una variable al final de L representa la lista
% de los elementos de L que están antes de F: [a, b|F]-F representa [a, b].
% concatenar_dif/3 une dos de esos pares en una unificación, sin recorrer
% ninguna lista. inorden_app/2 aplana un árbol binario con append/3, que
% recorre lo ya construido en cada nodo; inorden/2 hace el mismo recorrido con
% listas diferencia. invertir_app/2 e invertir/2 repiten la comparación para
% invertir una lista. degenerado/2 construye el árbol con el que
% inorden_app/2 hace más trabajo: cada nodo tiene todo el resto a su
% izquierda.
%
%?- concatenar_dif([a, b|X]-X, [c|Y]-Y, L-[]).
%?- inorden(n(n(vacio, 1, vacio), 2, n(vacio, 3, vacio)), L).
%?- degenerado(3, A), inorden_app(A, L).
%?- invertir([a, b, c], L).

% concatenar_dif(A, B, C): C es la lista diferencia A seguida de B.
concatenar_dif(L-M, M-F, L-F).

% vacia_dif(D): D es una lista diferencia sin elementos.
vacia_dif(L-L).

%!  inorden_app(+Arbol, -Lista:list) is det.
%
%   Lista tiene los elementos de Arbol en orden: los del subárbol izquierdo,
%   la raíz y los del derecho. Arbol es vacio o n(Izq, X, Der). En cada nodo,
%   append/3 recorre la lista del subárbol izquierdo.
inorden_app(vacio, []).
inorden_app(n(Izq, X, Der), Lista) :-
    inorden_app(Izq, LI),
    inorden_app(Der, LD),
    append(LI, [X|LD], Lista).

%!  inorden(+Arbol, -Lista:list) is det.
%
%   La misma relación que inorden_app/2, con listas diferencia.
inorden(Arbol, Lista) :-
    inorden_dif(Arbol, Lista-[]).

%!  inorden_dif(+Arbol, ?Dif) is det.
%
%   Dif, un par L-F, es la lista diferencia de los elementos de Arbol en
%   orden: L tiene esos elementos seguidos de F.
inorden_dif(vacio, L-L).
inorden_dif(n(Izq, X, Der), L-F) :-
    inorden_dif(Izq, L-[X|M]),
    inorden_dif(Der, M-F).

%!  degenerado(+N:integer, -Arbol) is det.
%
%   Arbol tiene los nodos 1..N, cada uno como hijo izquierdo del siguiente:
%   la raíz es N y el árbol no tiene ningún hijo derecho.
degenerado(0, vacio) :-
    !.
degenerado(N, n(Izq, N, vacio)) :-
    N > 0,
    N1 is N - 1,
    degenerado(N1, Izq).

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
