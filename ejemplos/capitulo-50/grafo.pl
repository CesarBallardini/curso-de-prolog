:- encoding(utf8).

% Capítulo 50 - Versión 4: las subexpresiones comunes, en un grafo.
%
% Las N expresiones de la versión 3 repiten subexpresiones. grafo/3 las
% reúne en un solo grafo dirigido acíclico en el que cada subexpresión
% distinta es un nodo: la clave de un diccionario incompleto del capítulo
% 34 (buscar/3) es la subexpresión, y el valor, su número de nodo, que
% numerar/2 liga al final. Los hijos se agregan antes que el padre, así
% que un nodo tiene un número mayor que los de sus hijos. Un nodo es
% nodo(Id, Hoja), con Hoja un coeficiente a(J), una raíz w(K) o un número,
% o nodo(Id, op(Op, I, J)), la operación Op entre los nodos I y J.
%
% solo-local: carga mitades.pl y diccionario.pl del capítulo 34, y SWISH
% no carga otros archivos.
%
%?- grafo([a + b * c, d + b * c], Nodos, Salidas).
%?- grafo([(a + b) * (a + b)], Nodos, Salidas).
%?- fft_arboles(8, Es), grafo(Es, Ns, _), contar_nodos(Ns, H, S, P).

:- ensure_loaded(mitades).
:- ensure_loaded('../capitulo-34/diccionario').
:- use_module(library(assoc)).

% costo/4, declarada en tdf.pl: el grafo de los árboles de la versión 3.
costo(grafo, N, S, P) :-
    fft_arboles(N, Es),
    grafo(Es, Nodos, _),
    contar_nodos(Nodos, _, S, P).

%!  grafo(+Es:list, -Nodos:list, -Salidas:list(integer)) is det.
%
%   Nodos es el grafo de las expresiones cerradas Es, con una sola vez
%   cada subexpresión, en orden: cada nodo después de sus hijos. Salidas
%   son los números de los nodos de las expresiones de Es, en el mismo
%   orden. Produce un error de instanciación si Es tiene variables: buscar/3
%   compara las claves por unificación.
grafo(Es, Nodos, Salidas) :-
    must_be(ground, Es),
    maplist(agregar(Dic), Es, Salidas),
    numerar(Dic, 1),
    nodos(Dic, Dic, Nodos).

%!  agregar(?Dic, +E, -Id) is det.
%
%   Agrega al diccionario incompleto Dic las subexpresiones de E, los hijos
%   antes que el padre; Id es el valor de E en Dic, libre hasta que
%   numerar/2 lo liga.
agregar(Dic, E, Id) :-
    (   operacion(E, _, A, B)
    ->  agregar(Dic, A, _),
        agregar(Dic, B, _)
    ;   true
    ),
    buscar(E, Dic, Id).

%!  operacion(+E, -Op, -A, -B) is semidet.
%
%   E es la operación A Op B, con Op entre +, - y *.
operacion(E, Op, A, B) :-
    compound(E),
    compound_name_arguments(E, Op, [A, B]),
    memberchk(Op, [+, -, *]).

%!  nodos(?Resto, +Dic, -Nodos:list) is det.
%
%   Nodos son los nodos de las entradas Resto del diccionario Dic, ya
%   numerado, hasta su final abierto.
nodos(Final, _, []) :-
    var(Final),
    !.
nodos([E-Id|Resto], Dic, [nodo(Id, T)|Ns]) :-
    contenido(E, Dic, T),
    nodos(Resto, Dic, Ns).

%!  contenido(+E, +Dic, -T) is det.
%
%   T es el contenido del nodo de E: op(Op, I, J) si E es A Op B, con I y J
%   los números de A y B en Dic, y E misma si E es una hoja.
contenido(E, Dic, T) :-
    (   operacion(E, Op, A, B)
    ->  buscar(A, Dic, I),
        buscar(B, Dic, J),
        T = op(Op, I, J)
    ;   T = E
    ).

%!  contar_nodos(+Nodos:list, -Hojas:integer, -Sumas:integer,
%!               -Productos:integer) is det.
%
%   El grafo Nodos tiene Hojas hojas, Sumas sumas y restas, y Productos
%   productos.
contar_nodos(Nodos, Hojas, Sumas, Productos) :-
    aggregate_all(count, ( member(nodo(_, T), Nodos),
                           T \= op(_, _, _) ), Hojas),
    aggregate_all(count, ( member(nodo(_, op(Op, _, _)), Nodos),
                           clase(Op, suma) ), Sumas),
    aggregate_all(count, member(nodo(_, op(*, _, _)), Nodos), Productos).

%!  listar_grafo(+Nodos:list) is det.
%
%   Escribe los nodos del grafo, uno por línea: n5 = n1 + n4 para una
%   operación, n1 = a(0) para una hoja.
listar_grafo(Nodos) :-
    forall(member(nodo(Id, T), Nodos), listar_nodo(Id, T)).

%!  listar_nodo(+Id:integer, +T) is det.
%
%   Escribe el nodo Id, de contenido T, en una línea.
listar_nodo(Id, op(Op, I, J)) :-
    !,
    format("n~w = n~w ~w n~w~n", [Id, I, Op, J]).
listar_nodo(Id, Hoja) :-
    format("n~w = ~q~n", [Id, Hoja]).

%!  valor_grafo(+N:integer, +Coefs:list, +Nodos:list, +Salidas:list,
%!              -Vs:list) is det.
%
%   Vs son los valores complejos de los nodos Salidas del grafo Nodos,
%   calculados una vez por nodo, en el orden del grafo, con las raíces
%   N-ésimas de la unidad y los coeficientes Coefs como en valor/4.
valor_grafo(N, Coefs, Nodos, Salidas, Vs) :-
    empty_assoc(T0),
    foldl(valor_nodo(N, Coefs), Nodos, T0, T),
    maplist([Id, V]>>get_assoc(Id, T, V), Salidas, Vs).

%!  valor_nodo(+N, +Coefs, +Nodo, +T0, -T) is det.
%
%   T es la tabla T0 de valores por número de nodo con el valor de Nodo
%   agregado; los valores de sus hijos ya están en T0.
valor_nodo(N, Coefs, nodo(Id, T), T0, T1) :-
    (   T = op(Op, I, J)
    ->  get_assoc(I, T0, VI),
        get_assoc(J, T0, VJ),
        operar(Op, VI, VJ, V)
    ;   valor(N, Coefs, T, V)
    ),
    put_assoc(Id, T0, V, T1).
