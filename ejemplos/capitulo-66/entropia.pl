:- encoding(utf8).

% Capítulo 66 - Ampliación: la conjunción de entropía máxima.
%
% Conocidas p(A) y p(B), la probabilidad X de «A y B» fija las cuatro
% probabilidades de los casos que se excluyen: A y B, solo B, solo A,
% ninguno. X solo puede tomar valores entre la cota conservadora y la
% liberal de la versión 2. Entre ellos, la estimación de Rowe es la que
% maximiza la entropía de las cuatro probabilidades, es decir, la que
% menos información agrega a lo que se sabe. y_maxima_entropia/3 la busca
% numéricamente, por búsqueda ternaria, sin usar la fórmula que el cálculo
% da: X = p(A) p(B), la de la independencia.
%
%?- y_maxima_entropia(0.7, 0.4, X).
%?- comparar([0.9-0.8, 0.7-0.4, 0.5-0.5, 0.2-0.3], Filas).

:- use_module(library(apply)).
:- use_module(library(lists)).

%!  entropia_de(+Probabilidades:list, -H:float) is det.
%
%   H es la entropía, en bits, de una distribución: la suma de -p log2 p,
%   donde un término con p igual a 0 vale 0.
entropia_de(Probabilidades, H) :-
    foldl(sumar_termino, Probabilidades, 0.0, H).

%!  sumar_termino(+P:float, +H0:float, -H:float) is det.
%
%   H es H0 más -P log2 P.
sumar_termino(P, H0, H) :-
    (   P =< 0
    ->  H = H0
    ;   H is H0 - P * log(P) / log(2)
    ).

%!  casos(+PA:float, +PB:float, +X:float, -Ps:list) is det.
%
%   Ps son las probabilidades de A y B, de B sin A, de A sin B y de
%   ninguno, cuando la de A y B es X.
casos(PA, PB, X, [X, SoloB, SoloA, Ninguno]) :-
    SoloB is PB - X,
    SoloA is PA - X,
    Ninguno is 1 - PA - PB + X.

%!  intervalo_y(+PA:float, +PB:float, -Inf:float, -Sup:float) is det.
%
%   Inf y Sup son los valores posibles extremos de p(A y B): las cotas
%   conservadora y liberal de la versión 2.
intervalo_y(PA, PB, Inf, Sup) :-
    Inf is max(0.0, PA + PB - 1),
    Sup is min(PA, PB).

%!  entropia_y(+PA:float, +PB:float, +X:float, -H:float) is det.
%
%   H es la entropía de los cuatro casos cuando p(A y B) es X.
entropia_y(PA, PB, X, H) :-
    casos(PA, PB, X, Ps),
    entropia_de(Ps, H).

%!  y_maxima_entropia(+PA:float, +PB:float, -X:float) is det.
%
%   X es el valor de p(A y B) entre las cotas que maximiza la entropía de
%   los cuatro casos, con cuatro decimales. La entropía es cóncava en X,
%   así que una búsqueda ternaria de 100 pasos la encuentra.
y_maxima_entropia(PA, PB, X) :-
    intervalo_y(PA, PB, Inf, Sup),
    ternaria(100, PA, PB, Inf, Sup, X0),
    X is round(X0 * 10000) / 10000.0.

%!  ternaria(+N:integer, +PA, +PB, +A:float, +B:float, -X:float) is det.
%
%   X es el punto medio del intervalo [A, B] después de reducirlo N veces
%   a sus dos tercios, descartando el tercio de menor entropía.
ternaria(0, _, _, A, B, X) :-
    !,
    X is (A + B) / 2.
ternaria(N, PA, PB, A, B, X) :-
    M1 is A + (B - A) / 3,
    M2 is B - (B - A) / 3,
    entropia_y(PA, PB, M1, H1),
    entropia_y(PA, PB, M2, H2),
    (   H1 < H2
    ->  A1 = M1,
        B1 = B
    ;   A1 = A,
        B1 = M2
    ),
    N1 is N - 1,
    ternaria(N1, PA, PB, A1, B1, X).

%!  comparar(+Pares:list, -Filas:list) is det.
%
%   Filas tiene, por cada par PA-PB, el término
%   f(PA, PB, Inf, Sup, Maxima, Producto): las cotas, la estimación de
%   entropía máxima y el producto de la independencia, con cuatro
%   decimales.
comparar(Pares, Filas) :-
    maplist(fila, Pares, Filas).

%!  fila(+Par, -Fila) is det.
%
%   Fila es la de comparar/2 para el Par PA-PB.
fila(PA-PB, f(PA, PB, Inf, Sup, X, Producto)) :-
    intervalo_y(PA, PB, Inf0, Sup0),
    Inf is round(Inf0 * 10000) / 10000.0,
    Sup is round(Sup0 * 10000) / 10000.0,
    y_maxima_entropia(PA, PB, X),
    Producto is round(PA * PB * 10000) / 10000.0.
