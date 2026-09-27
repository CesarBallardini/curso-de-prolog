:- encoding(utf8).

% Capítulo 11 - Texto: format/2.
%
% format/2 compone la salida a partir de un texto de formato y una lista de
% valores; format/3 con atom(A) deja el resultado en un átomo en lugar de
% escribirlo.
%
%?- ficha(juan).
%?- tabla([juan, ana, luis]).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

%!  ficha(?P) is nondet.
%
%   Escribe una línea con el nombre y la edad de P.
ficha(P) :-
    edad(P, E),
    format("~w tiene ~d años~n", [P, E]).

%!  tabla(+Personas) is semidet.
%
%   Escribe una fila por persona de la lista: el nombre en una columna de
%   diez caracteres y la edad alineada a la derecha en la columna siguiente.
%   Falla si alguna persona no tiene edad registrada.
tabla([]).
tabla([P|Resto]) :-
    edad(P, E),
    format("~w~t~10|~t~d~4+~n", [P, E]),
    tabla(Resto).

%!  etiqueta(?P, -Etiqueta) is nondet.
%
%   Etiqueta es un átomo con el nombre de P y su edad entre paréntesis.
etiqueta(P, Etiqueta) :-
    edad(P, E),
    format(atom(Etiqueta), "~w (~d)", [P, E]).
