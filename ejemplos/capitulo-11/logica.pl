:- encoding(utf8).

% Capítulo 11 - Un programa leído como lógica.
%
% Cada regla de este archivo admite dos lecturas: como un procedimiento de
% búsqueda de respuestas, y como una afirmación lógica. El capítulo desarrolla
% la segunda lectura.
%
%?- madre(Quien, luis).
%?- tiene_hijos(Quien).

% mujer(P): P es mujer.
mujer(marta).
mujer(ana).
mujer(eva).

% varon(P): P es varón.
varon(juan).
varon(pedro).
varon(luis).

% progenitor(P, H): P es el padre o la madre de H: una sola generación, y
% no un ascendiente cualquiera. La relación transitiva es ascendiente/2.
progenitor(juan, ana).
progenitor(marta, ana).
progenitor(juan, pedro).
progenitor(marta, pedro).
progenitor(pedro, luis).
progenitor(pedro, eva).

%!  madre(?M, ?H) is nondet.
%
%   Para toda M y todo H, si M es mujer y M es progenitora de H, entonces M es
%   madre de H.
madre(M, H) :-
    mujer(M),
    progenitor(M, H).

%!  padre(?P, ?H) is nondet.
%
%   Para todo P y todo H, si P es varón y P es progenitor de H, entonces P es
%   padre de H.
padre(P, H) :-
    varon(P),
    progenitor(P, H).

%!  tiene_hijos(?P) is nondet.
%
%   Para todo P, si existe algún H del que P es progenitor, entonces P tiene
%   hijos. H no aparece en la cabeza: es la variable cuantificada
%   existencialmente.
tiene_hijos(P) :-
    progenitor(P, _).

%!  ascendiente(?A, ?D) is nondet.
%
%   A es progenitor de D, o es progenitor de alguien que a su vez es
%   ascendiente de D. La disyunción se expresa con las dos cláusulas.
ascendiente(A, D) :-
    progenitor(A, D).
ascendiente(A, D) :-
    progenitor(A, Medio),
    ascendiente(Medio, D).
