:- encoding(utf8).

% Capítulo 67 - Versión 1: la generalización menos general de dos
% términos.
%
% mas_general/2 es la θ-subsunción entre términos: G es al menos tan
% general como T si una sustitución aplicada a G da T. lgg/3 calcula la
% generalización menos general (lgg) por antiunificación: recorre los dos
% términos a la vez, como los recorridos del capítulo 32, conserva lo que
% tienen en común y pone una variable donde difieren. La sustitución
% inversa recuerda cada par de subtérminos ya reemplazado, para que el
% mismo par reciba siempre la misma variable. lgg_ingenua/3 omite esa
% tabla, y su resultado es una generalización común que no es la menos
% general.
%
%?- lgg(abuelo(juan, luis), abuelo(pedro, sofia), G).
%?- lgg(2 * 2 = 2 + 2, 2 * 3 = 3 + 3, G).
%?- lgg_ingenua(f(a, a), f(b, b), G).

:- module(generalizar,
          [ mas_general/2,
            lgg_ingenua/3,
            lgg/3,
            lgg/5
          ]).

:- use_module(library(apply)).

%!  mas_general(@G, @T) is semidet.
%
%   G es al menos tan general como T: existe una sustitución de las
%   variables de G que lo convierte en T. Ninguno de los dos términos
%   queda ligado.
mas_general(G, T) :-
    subsumes_term(G, T).

%!  lgg_ingenua(+T1, +T2, -G) is det.
%
%   G generaliza a T1 y a T2: conserva lo que tienen en común y pone una
%   variable nueva en cada posición donde difieren. No reutiliza las
%   variables: dos diferencias iguales reciben variables distintas.
lgg_ingenua(T1, T2, G) :-
    (   T1 == T2
    ->  G = T1
    ;   compound(T1),
        compound(T2),
        compound_name_arity(T1, F, N),
        compound_name_arity(T2, F, N)
    ->  compound_name_arguments(T1, F, Args1),
        compound_name_arguments(T2, F, Args2),
        maplist(lgg_ingenua, Args1, Args2, Args),
        compound_name_arguments(G, F, Args)
    ;   true
    ).

%!  lgg(+T1, +T2, -G) is det.
%
%   G es la generalización menos general de T1 y T2.
lgg(T1, T2, G) :-
    lgg(T1, T2, G, [], _).

%!  lgg(+T1, +T2, -G, +S0:list, -S:list) is det.
%
%   G es la generalización menos general de T1 y T2, con la sustitución
%   inversa S0 como punto de partida: una lista de pares (A-B)-V, donde V
%   es la variable que ya reemplaza al par de subtérminos A y B. S es S0
%   con los pares nuevos agregados al frente.
lgg(T1, T2, G, S0, S) :-
    (   T1 == T2
    ->  G = T1,
        S = S0
    ;   reemplazado(S0, T1, T2, V)
    ->  G = V,
        S = S0
    ;   compound(T1),
        compound(T2),
        compound_name_arity(T1, F, N),
        compound_name_arity(T2, F, N)
    ->  compound_name_arguments(T1, F, Args1),
        compound_name_arguments(T2, F, Args2),
        foldl(lgg_argumento, Args1, Args2, Args, S0, S),
        compound_name_arguments(G, F, Args)
    ;   S = [(T1-T2)-G|S0]
    ).

%!  lgg_argumento(+A1, +A2, -A, +S0:list, -S:list) is det.
%
%   A es la lgg de los argumentos A1 y A2, con la sustitución inversa S0.
lgg_argumento(A1, A2, A, S0, S) :-
    lgg(A1, A2, A, S0, S).

%!  reemplazado(+S:list, @T1, @T2, -V) is semidet.
%
%   La sustitución inversa S ya reemplaza el par T1, T2 por la variable V.
%   Los subtérminos se comparan con ==, no se unifican.
reemplazado(S, T1, T2, V) :-
    member((A-B)-V, S),
    A == T1,
    B == T2,
    !.
