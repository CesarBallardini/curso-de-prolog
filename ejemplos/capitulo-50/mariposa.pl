:- encoding(utf8).

% Capítulo 50 - Versión 5: la mariposa.
%
% El grafo de la versión 4 no usa que w(K + N/2) es -w(K): las salidas K
% y K + N/2 calculan w(K) * B y w(K + N/2) * B como dos productos
% distintos. Si las expresiones se simplifican con simplificar_raices/3
% antes de construir el grafo, las dos salidas pasan a ser A + w(K) * B y
% A - w(K) * B, comparten el producto, y los productos por w(0) = 1
% desaparecen. El grafo que queda es el de la transformada rápida: en
% cada uno de los log2(N) niveles, N sumas o restas y a lo sumo N/2
% productos, cruzados de a pares como las alas de una mariposa.
%
% solo-local: carga grafo.pl, y SWISH no carga otros archivos.
%
%?- fft_grafo(4, Nodos, Salidas), listar_grafo(Nodos).
%?- fft_grafo(8, Nodos, _), contar_nodos(Nodos, H, S, P).
%?- fft_numerica([1, 2, 3, 4], Vs).

:- ensure_loaded(grafo).

% costo/4, declarada en tdf.pl: el grafo de las expresiones simplificadas.
costo(mariposa, N, S, P) :-
    fft_grafo(N, Nodos, _),
    contar_nodos(Nodos, _, S, P).

%!  fft_grafo(+N:integer, -Nodos:list, -Salidas:list(integer)) is det.
%
%   Nodos es el grafo de la transformada rápida de orden N, con las
%   expresiones de la recursión sobre las mitades simplificadas antes de
%   reunir sus subexpresiones comunes; Salidas son los nodos de las N
%   salidas, en orden. Produce un error de dominio si N no es una potencia
%   de 2.
fft_grafo(N, Nodos, Salidas) :-
    fft_arboles(N, Es0),
    maplist(simplificar_raices(N), Es0, Es),
    grafo(Es, Nodos, Salidas).

%!  fft_numerica(+Coefs:list, -Vs:list) is det.
%
%   Vs es la transformada de Coefs, calculada con el grafo de la
%   transformada rápida: cada nodo se evalúa una vez. La longitud de Coefs
%   es una potencia de 2.
fft_numerica(Coefs, Vs) :-
    length(Coefs, N),
    fft_grafo(N, Nodos, Salidas),
    valor_grafo(N, Coefs, Nodos, Salidas, Vs).
