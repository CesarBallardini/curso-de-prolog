:- encoding(utf8).

% Capítulo 11 - Texto: representaciones y conversiones.
%
% Un mismo texto se puede escribir como átomo, como cadena, como lista de
% códigos o como lista de caracteres. Las conversiones pasan de una forma a
% otra, en los dos sentidos.
%
%?- inicial(juan, I).
%?- iniciales([juan, ana, eva], L).

%!  inicial(+Nombre, -Inicial) is semidet.
%
%   Inicial es el primer carácter del átomo Nombre. Falla con el átomo vacío.
inicial(Nombre, Inicial) :-
    atom_chars(Nombre, [Inicial|_]).

%!  iniciales(+Nombres, -Iniciales) is semidet.
%
%   Iniciales es la lista de los primeros caracteres de los nombres de la
%   lista Nombres, en el mismo orden.
iniciales([], []).
iniciales([Nombre|Resto], [Inicial|Iniciales]) :-
    inicial(Nombre, Inicial),
    iniciales(Resto, Iniciales).

%!  numero_de_texto(+Texto, -N) is semidet.
%
%   N es el número que representa el átomo Texto. Falla si Texto no
%   representa un número.
numero_de_texto(Texto, N) :-
    atom_number(Texto, N).
