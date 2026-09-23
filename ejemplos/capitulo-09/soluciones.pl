:- encoding(utf8).

% Capítulo 9 - Soluciones de los ejercicios.
%
%?- categoria_sin_ningun_corte(sofia, C).
%?- sin_repetidos([a, b, a, c, b], R).

edad(juan, 68).
edad(ana, 41).
edad(luis, 12).
edad(eva, 8).
edad(sofia, 3).

% --- Ejercicio 3 -----------------------------------------------------------

%!  categoria_sin_ningun_corte(?P, ?C) is nondet.
%!  categoria_sin_ningun_corte(+P, -C) is semidet.
%
%   C es la categoría de P, con las condiciones completas, sin corte.
categoria_sin_ningun_corte(P, bebe) :-
    edad(P, A),
    A < 4.
categoria_sin_ningun_corte(P, chico) :-
    edad(P, A),
    A >= 4,
    A < 13.
categoria_sin_ningun_corte(P, adulto) :-
    edad(P, A),
    A >= 13.

% --- Ejercicio 5 -----------------------------------------------------------

%!  primer_par(+L, -X) is semidet.
%
%   X es el primer número par de L.
primer_par([X|_], X) :-
    0 =:= X mod 2,
    !.
primer_par([X|Resto], P) :-
    0 =\= X mod 2,
    primer_par(Resto, P).

% --- Ejercicio 6 -----------------------------------------------------------

%!  hay_algun_menor(+L) is nondet.
%
%   Algún número de L es menor que 18. No requiere corte: es suficiente que
%   exista uno, y la consulta se cumple al encontrarlo.
hay_algun_menor(L) :-
    member(X, L),
    X < 18.

% --- Ejercicio 8 -----------------------------------------------------------

%!  primer_cuadrado_mayor(+N, -C) is semidet.
%
%   C es el primer número cuyo cuadrado supera a N. C debe llegar libre: el
%   corte es rojo.
primer_cuadrado_mayor(N, C) :-
    between(1, 10000, C),
    C * C > N,
    !.

% --- Ejercicio 9 -----------------------------------------------------------

%!  descuento(+Edad, -D) is det.
%
%   D es el descuento que corresponde a Edad: el corte rojo corregido, con las
%   condiciones completas.
descuento(Edad, 50) :-
    Edad < 12.
descuento(Edad, 30) :-
    Edad >= 65.
descuento(Edad, 0) :-
    Edad >= 12,
    Edad < 65.

% --- Ejercicio 10 ----------------------------------------------------------

%!  sin_repetidos(+L, -R) is det.
%
%   R es L sin repetidos; conserva la última aparición de cada elemento. El
%   corte descarta las demás soluciones de member/2: es suficiente que X
%   aparezca una vez en Resto.
sin_repetidos([], []).
sin_repetidos([X|Resto], [X|RestoR]) :-
    \+ member(X, Resto),
    sin_repetidos(Resto, RestoR).
sin_repetidos([X|Resto], R) :-
    member(X, Resto),
    !,
    sin_repetidos(Resto, R).

% --- Ejercicio 14 ----------------------------------------------------------

%!  clasificar(+N, -C) is det.
%
%   C es negativo, cero o positivo, según N. Plantilla 14. Correcto con C
%   libre; con C instanciado, el corte puede no ejecutarse.
clasificar(N, negativo) :-
    N < 0,
    !.
clasificar(0, cero) :-
    !.
clasificar(_, positivo).
