:- encoding(utf8).

% Capítulo 9 - El corte.
%
% Las mismas tres categorías definidas de dos formas: sin corte, que produce
% respuestas de más, y con corte, que conserva solo la primera que corresponde.
%
%?- categoria(eva, C).
%?- categoria_sin_corte(eva, C).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 45).
edad(luis, 12).
edad(eva, 8).
edad(sofia, 3).

% categoria_sin_corte(P, C): las tres condiciones se superponen deliberadamente.
categoria_sin_corte(P, bebe) :-
    edad(P, A),
    A < 4.
categoria_sin_corte(P, chico) :-
    edad(P, A),
    A < 13.
categoria_sin_corte(P, adulto) :-
    edad(P, _).

% categoria(P, C): la misma clasificación, con corte. El corte descarta las
% cláusulas siguientes.
categoria(P, bebe) :-
    edad(P, A),
    A < 4,
    !.
categoria(P, chico) :-
    edad(P, A),
    A < 13,
    !.
categoria(P, adulto) :-
    edad(P, _).

% un_mayor_de_edad(P): P es la primera persona mayor de edad que se encuentra.
un_mayor_de_edad(P) :-
    edad(P, A),
    A >= 18,
    !.
