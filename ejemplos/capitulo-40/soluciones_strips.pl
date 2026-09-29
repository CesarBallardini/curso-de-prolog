:- encoding(utf8).

% Capítulo 40 - Solución del ejercicio 10: el mundo de bloques sin pinza.
%
% La acción mover(B, De, A) lleva el bloque libre B de De a A, un bloque
% libre o la mesa. Los estados no tienen mano_vacia ni sostiene/1, y la
% mesa siempre tiene lugar: mover un bloque a la mesa no exige ni borra
% libre(mesa). Hacen falta tres operadores, según De y A sean bloques o la
% mesa. aplicar/3, planificar/3 y lograr/4 son los de strips.pl.
%
%?- sussman(E), once(planificar(E, [sobre(a, b), sobre(b, c)], Plan)).

% bloque(B): B es un bloque.
bloque(a).
bloque(b).
bloque(c).

%!  sussman(-Estado:list) is det.
%
%   Estado es el de la anomalía de Sussman, sin pinza.
sussman(Estado) :-
    list_to_ord_set([sobre(c, a), sobre(a, mesa), sobre(b, mesa), libre(c),
                     libre(b)],
                    Estado).

%!  operador(?Accion, -Precondiciones:list, -Agrega:list, -Borra:list)
%!      is nondet.
%
%   Los operadores de mover/3, sin variables.
operador(mover(B, X, Y), [libre(B), sobre(B, X), libre(Y)],
         [sobre(B, Y), libre(X)], [sobre(B, X), libre(Y)]) :-
    bloque(B),
    bloque(X),
    bloque(Y),
    B \== X,
    B \== Y,
    X \== Y.
operador(mover(B, X, mesa), [libre(B), sobre(B, X)],
         [sobre(B, mesa), libre(X)], [sobre(B, X)]) :-
    bloque(B),
    bloque(X),
    B \== X.
operador(mover(B, mesa, Y), [libre(B), sobre(B, mesa), libre(Y)],
         [sobre(B, Y)], [sobre(B, mesa), libre(Y)]) :-
    bloque(B),
    bloque(Y),
    B \== Y.

%!  aplicar(+Estado:list, ?Accion, -Siguiente:list) is nondet.
%
%   Accion se puede aplicar en Estado y lleva a Siguiente.
aplicar(Estado, Accion, Siguiente) :-
    operador(Accion, Pre, Agrega, Borra),
    list_to_ord_set(Pre, Pre1),
    ord_subset(Pre1, Estado),
    list_to_ord_set(Borra, Borra1),
    list_to_ord_set(Agrega, Agrega1),
    ord_subtract(Estado, Borra1, Estado1),
    ord_union(Estado1, Agrega1, Siguiente).

%!  planificar(+Estado:list, +Metas:list, -Plan:list) is nondet.
%
%   Plan lleva de Estado a un estado donde valen las Metas, por medios y
%   fines, de menor a mayor longitud.
planificar(Estado, Metas, Plan) :-
    length(Plan, _),
    lograr(Estado, Metas, Plan, _).

%!  lograr(+Estado:list, +Metas:list, ?Plan:list, -Final:list) is nondet.
%
%   Plan lleva de Estado a Final, donde valen las Metas.
lograr(Estado, Metas, [], Estado) :-
    list_to_ord_set(Metas, Metas1),
    ord_subset(Metas1, Estado).
lograr(Estado, Metas, Plan, Final) :-
    append(Antes, [Accion|Despues], Plan),
    member(Meta, Metas),
    \+ ord_memberchk(Meta, Estado),
    operador(Accion, Pre, Agrega, _),
    memberchk(Meta, Agrega),
    lograr(Estado, Pre, Antes, Intermedio),
    aplicar(Intermedio, Accion, Siguiente),
    lograr(Siguiente, Metas, Despues, Final).
