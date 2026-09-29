:- encoding(utf8).

% Capítulo 50 - La FFT simbólica terminada.
%
% Carga las cinco versiones y compara lo que cuesta cada una: la cantidad
% de sumas (y restas) y de productos que hay que calcular para obtener las
% N salidas de la transformada. Cada versión agrega su cláusula a costo/4,
% que tdf.pl declara multifile. En las expresiones sueltas se cuenta cada
% aparición de una operación; en los grafos, cada nodo una sola vez.
% fft_ejemplo/1 escribe el grafo de la transformada rápida, y
% mermaid_grafo/1 lo escribe como un diagrama de Mermaid.
%
% solo-local: carga mariposa.pl, y SWISH no carga otros archivos.
%
%?- costo(mariposa, 8, S, P).
%?- tabla_de_costos([2, 4, 8, 16, 32, 64]).
%?- fft_ejemplo(4).

:- ensure_loaded(mariposa).

%!  tabla_de_costos(+Ns:list(integer)) is det.
%
%   Escribe una tabla con una fila por cada orden de Ns y una columna por
%   versión; cada celda es Sumas+Productos.
tabla_de_costos(Ns) :-
    Versiones = [ingenua, simplificada, arboles, grafo, mariposa],
    escribir_fila(n, Versiones),
    forall(member(N, Ns), fila_de_costos(Versiones, N)).

%!  fila_de_costos(+Versiones:list, +N:integer) is det.
%
%   Escribe la fila de la tabla de costos del orden N.
fila_de_costos(Versiones, N) :-
    maplist(celda(N), Versiones, Celdas),
    escribir_fila(N, Celdas).

%!  celda(+N:integer, +Version, -Celda:atom) is det.
%
%   Celda es Sumas+Productos de la Version de orden N.
celda(N, V, Celda) :-
    once(costo(V, N, S, P)),
    format(atom(Celda), "~w+~w", [S, P]).

%!  escribir_fila(+Primera, +Celdas:list) is det.
%
%   Escribe una línea con Primera en una columna de 4 caracteres y cada
%   una de las Celdas alineada a la derecha en una de 14.
escribir_fila(Primera, Celdas) :-
    length(Celdas, K),
    length(Formatos, K),
    maplist(=("~t~w~14+"), Formatos),
    atomic_list_concat(["~w~t~4|"|Formatos], Formato),
    format(Formato, [Primera|Celdas]),
    nl.

%!  fft_ejemplo(+N:integer) is det.
%
%   Escribe el grafo de la transformada rápida de orden N, un nodo por
%   línea, y después qué nodo da cada salida.
fft_ejemplo(N) :-
    fft_grafo(N, Nodos, Salidas),
    listar_grafo(Nodos),
    forall(nth0(K, Salidas, Id), format("salida ~w: n~w~n", [K, Id])).

%!  mermaid_grafo(+N:integer) is det.
%
%   Escribe el grafo de la transformada rápida de orden N como un
%   diagrama de flujo de Mermaid, de arriba hacia abajo: un nodo por
%   subexpresión, una arista de cada hijo a su padre, y un nodo más por
%   salida.
mermaid_grafo(N) :-
    fft_grafo(N, Nodos, Salidas),
    format("flowchart TB~n"),
    forall(member(nodo(Id, T), Nodos), mermaid_nodo(Id, T)),
    forall(nth0(K, Salidas, Id),
           format("    n~w --> s~w([\"salida ~w\"])~n", [Id, K, K])).

%!  mermaid_nodo(+Id:integer, +T) is det.
%
%   Escribe el nodo Id, de contenido T, y las aristas desde sus hijos.
mermaid_nodo(Id, op(Op, I, J)) :-
    !,
    format("    n~w[\"n~w = n~w ~w n~w\"]~n", [Id, Id, I, Op, J]),
    format("    n~w & n~w --> n~w~n", [I, J, Id]).
mermaid_nodo(Id, Hoja) :-
    format("    n~w[\"n~w = ~q\"]~n", [Id, Id, Hoja]).
