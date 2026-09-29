:- encoding(utf8).

% Capítulo 34 - Colas.
%
% Una cola agrega por el final y quita por el principio. Con una lista
% cerrada, encolar_lista/3 recorre la cola entera en cada agregado. Con una
% lista diferencia Frente-Fondo, encolar_dif/3 y desencolar_dif/3 trabajan en
% un paso, pero desencolar_dif/3 también quita de una cola vacía. La cola con
% contador, cola(N, Frente, Fondo), lleva la cantidad de elementos y rechaza
% ese caso. por_niveles/2 la usa para recorrer un árbol en anchura, y
% por_niveles_lista/2 hace el mismo recorrido con la lista cerrada.
%
%?- encolar_lista(c, [a, b], C).
%?- encolar_dif(a, F-F, C1), encolar_dif(b, C1, C2), desencolar_dif(X, C2, C3).
%?- cola_vacia(C0), encolar(a, C0, C1), desencolar(X, C1, C2).
%?- por_niveles(n(n(vacio, 2, vacio), 1, n(vacio, 3, n(vacio, 4, vacio))), L).

%!  encolar_lista(+X, +Cola:list, -Cola1:list) is det.
%
%   Cola1 es la cola Cola, una lista cerrada, con X agregado al final.
encolar_lista(X, Cola, Cola1) :-
    append(Cola, [X], Cola1).

% encolar_dif(X, C0, C): C es la cola diferencia C0 con X al final.
encolar_dif(X, Frente-[X|Fondo], Frente-Fondo).

% desencolar_dif(X, C0, C): X es el primero de la cola diferencia C0 y C el
% resto; también se cumple con una cola vacía.
desencolar_dif(X, [X|Frente]-Fondo, Frente-Fondo).

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

%!  por_niveles(+Arbol, -Lista:list) is det.
%
%   Lista tiene los elementos de Arbol por niveles: la raíz, después sus
%   hijos de izquierda a derecha, después los nietos. Arbol es vacio o
%   n(Izq, X, Der).
por_niveles(Arbol, Lista) :-
    cola_vacia(C0),
    encolar(Arbol, C0, C),
    niveles(C, Lista).

%!  niveles(+Cola, -Lista:list) is det.
%
%   Lista tiene, por niveles, los elementos de los árboles de Cola.
niveles(Cola, Lista) :-
    (   desencolar(Arbol, Cola, Cola1)
    ->  niveles(Arbol, Cola1, Lista)
    ;   Lista = []
    ).

%!  niveles(+Arbol, +Cola, -Lista:list) is det.
%
%   Lista tiene la raíz de Arbol, si la tiene, y los elementos del resto
%   del recorrido, con los hijos de Arbol al final de Cola.
niveles(vacio, Cola, Lista) :-
    niveles(Cola, Lista).
niveles(n(Izq, X, Der), Cola, [X|Lista]) :-
    encolar(Izq, Cola, Cola1),
    encolar(Der, Cola1, Cola2),
    niveles(Cola2, Lista).

%!  por_niveles_lista(+Arbol, -Lista:list) is det.
%
%   La misma relación que por_niveles/2, con la cola como lista cerrada.
por_niveles_lista(Arbol, Lista) :-
    niveles_lista([Arbol], Lista).

%!  niveles_lista(+Cola:list, -Lista:list) is det.
%
%   Lista tiene, por niveles, los elementos de los árboles de Cola.
niveles_lista([], []).
niveles_lista([vacio|Cola], Lista) :-
    niveles_lista(Cola, Lista).
niveles_lista([n(Izq, X, Der)|Cola], [X|Lista]) :-
    encolar_lista(Izq, Cola, Cola1),
    encolar_lista(Der, Cola1, Cola2),
    niveles_lista(Cola2, Lista).

%!  completo(+Altura:integer, -Arbol) is det.
%
%   Arbol es el árbol completo de esa altura: 2^Altura - 1 nodos, cada uno
%   con su altura como elemento.
completo(0, vacio) :-
    !.
completo(H, n(Sub, H, Sub)) :-
    H > 0,
    H1 is H - 1,
    completo(H1, Sub).
