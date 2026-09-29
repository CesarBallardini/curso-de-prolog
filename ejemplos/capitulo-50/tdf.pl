:- encoding(utf8).

% Capítulo 50 - Versión 1: la transformada discreta como producto de una
% matriz por un vector.
%
% La transformada discreta de Fourier de orden N evalúa el polinomio
% a(0) + a(1) x + ... + a(N-1) x^(N-1) en las N potencias de una raíz
% N-ésima de la unidad. w(K) es la potencia K de esa raíz, sin evaluar, y
% a(J) es el coeficiente J, también sin evaluar. La salida K es la fila K
% de la matriz de elementos w(J * K) multiplicada por el vector de los
% coeficientes: se calcula con producto_sin_simplificar/3 del capítulo 47,
% que construye las expresiones en lugar de evaluarlas.
%
% solo-local: carga matriz_simbolica.pl del capítulo 47, y SWISH no carga
% otros archivos.
%
%?- matriz_tdf(4, W).
%?- tdf_ingenua(4, Es).
%?- costo(ingenua, 8, S, P).

:- ensure_loaded('../capitulo-47/matriz_simbolica').

:- multifile costo/4.

%!  costo(?Version, +N:integer, -Sumas:integer, -Productos:integer)
%!      is nondet.
%
%   La Version de la transformada de orden N calcula Sumas sumas o restas
%   y Productos productos. Cada versión del capítulo agrega su cláusula:
%   ingenua (este archivo), simplificada, arboles, grafo y mariposa; las
%   tres últimas requieren que N sea una potencia de 2.
costo(ingenua, N, S, P) :-
    tdf_ingenua(N, Es),
    operaciones(Es, S, P).

%!  coeficientes(+N:integer, -As:list) is det.
%
%   As es la lista [a(0), a(1), ..., a(N-1)].
coeficientes(N, As) :-
    must_be(positive_integer, N),
    N1 is N - 1,
    numlist(0, N1, Js),
    maplist([J, a(J)]>>true, Js, As).

%!  matriz_tdf(+N:integer, -W:list(list)) is det.
%
%   W es la matriz de la transformada de orden N: el elemento de la fila K
%   y la columna J es w(J * K), con el producto sin reducir módulo N.
matriz_tdf(N, W) :-
    must_be(positive_integer, N),
    N1 is N - 1,
    numlist(0, N1, Ks),
    maplist(fila_tdf(Ks), Ks, W).

%!  fila_tdf(+Js:list(integer), +K:integer, -Fila:list) is det.
%
%   Fila es la fila K de la matriz de la transformada, con una columna por
%   cada índice de Js.
fila_tdf(Js, K, Fila) :-
    maplist([J, w(P)]>>(P is J * K), Js, Fila).

%!  tdf_ingenua(+N:integer, -Es:list) is det.
%
%   Es son las N salidas de la transformada de orden N, calculadas como el
%   producto de la matriz por el vector de los coeficientes, sin
%   simplificar.
tdf_ingenua(N, Es) :-
    matriz_tdf(N, W),
    coeficientes(N, As),
    maplist([A, [A]]>>true, As, Columna),
    producto_sin_simplificar(W, Columna, C),
    maplist([[E], E]>>true, C, Es).

%!  operaciones(+Es:list, -Sumas:integer, -Productos:integer) is det.
%
%   Sumas es la cantidad de sumas y restas de las expresiones Es, y
%   Productos la de productos, contando cada aparición: una subexpresión
%   repetida se cuenta cada vez que aparece.
operaciones(Es, Sumas, Productos) :-
    aggregate_all(count, operador_en(Es, suma), Sumas),
    aggregate_all(count, operador_en(Es, producto), Productos).

%!  operador_en(+Es:list, ?Clase) is nondet.
%
%   Uno de los nodos de las expresiones Es es una operación de la Clase
%   suma (+ o -) o producto (*): una respuesta por cada nodo.
operador_en(Es, Clase) :-
    member(E, Es),
    sub_term(S, E),
    compound(S),
    compound_name_arity(S, Op, 2),
    clase(Op, Clase).

% clase(Op, C): el operador binario Op es de la clase C.
clase(+, suma).
clase(-, suma).
clase(*, producto).
