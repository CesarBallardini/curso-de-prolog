:- encoding(utf8).

% Capítulo 50 - Versión 3: la recursión sobre las mitades.
%
% Un polinomio con los coeficientes de índices I0, I1, ..., evaluado en x,
% es la suma del polinomio de los índices de lugar par evaluado en x^2 y
% de x por el de los índices de lugar impar, también en x^2. Con x = w(K),
% x^2 es w(2K mod N). evaluar/4 aplica esa descomposición hasta llegar a
% un solo índice, y construye la expresión de una salida de la
% transformada. N debe ser una potencia de 2, para que cada lista de
% índices se parta en dos mitades iguales hasta tener un elemento.
%
% solo-local: carga raices.pl, y SWISH no carga otros archivos.
%
%?- alternar([0, 1, 2, 3, 4, 5, 6, 7], Pares, Impares).
%?- evaluar([0, 1, 2, 3, 4, 5, 6, 7], 6, 8, E).
%?- fft_arboles(4, Es).

:- ensure_loaded(raices).

% costo/4, declarada en tdf.pl: los árboles de la recursión, sin compartir.
costo(arboles, N, S, P) :-
    fft_arboles(N, Es),
    operaciones(Es, S, P).

%!  alternar(?Lista:list, ?Pares:list, ?Impares:list) is semidet.
%
%   Pares son los elementos de Lista en los lugares 0, 2, 4, ..., e
%   Impares los de los lugares 1, 3, 5, ...; Lista tiene una cantidad par
%   de elementos.
alternar([], [], []).
alternar([X, Y|T], [X|Xs], [Y|Ys]) :-
    alternar(T, Xs, Ys).

%!  evaluar(+Indices:list(integer), +K:integer, +N:integer, -E) is det.
%
%   E es la expresión del polinomio de los coeficientes a(I), con I en
%   Indices, evaluado en w(K), la potencia K de una raíz N-ésima de la
%   unidad. La longitud de Indices es una potencia de 2.
evaluar([I|Is], K, N, E) :-
    evaluar(Is, I, K, N, E).

%!  evaluar(+Is:list(integer), +I:integer, +K:integer, +N:integer,
%!          -E) is det.
%
%   Como evaluar/4 con los índices [I|Is]: separa el caso de un solo
%   índice por el primer argumento.
evaluar([], I, _, _, a(I)).
evaluar([I1|Is], I0, K, N, A1 + w(K) * A2) :-
    alternar([I0, I1|Is], Pares, Impares),
    K2 is 2 * K mod N,
    evaluar(Pares, K2, N, A1),
    evaluar(Impares, K2, N, A2).

%!  fft_arboles(+N:integer, -Es:list) is det.
%
%   Es son las N salidas de la transformada de orden N, cada una construida
%   con evaluar/4, como árboles independientes. Produce un error de dominio
%   si N no es una potencia de 2.
fft_arboles(N, Es) :-
    potencia_de_dos(N),
    N1 is N - 1,
    numlist(0, N1, Is),
    maplist([K, E]>>evaluar(Is, K, N, E), Is, Es).

%!  potencia_de_dos(+N:integer) is det.
%
%   Verifica que N es una potencia de 2, y si no produce un error de
%   dominio.
potencia_de_dos(N) :-
    must_be(positive_integer, N),
    (   N /\ (N - 1) =:= 0
    ->  true
    ;   domain_error(potencia_de_dos, N)
    ).
