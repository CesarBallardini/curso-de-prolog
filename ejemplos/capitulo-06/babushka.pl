:- encoding(utf8).

% Capítulo 6 - Caso base y caso recursivo.
%
% Una babushka se escribe con términos: babushka_hueca(Interior) es una muñeca
% hueca con otra babushka adentro, y babushka_maciza es la muñeca maciza del
% centro. Desarmarla es el ejemplo más simple de las dos partes de una
% recursión.
%
%?- desarma(babushka_hueca(babushka_hueca(babushka_hueca(babushka_maciza)))).
%?- desarma(babushka_hueca(pelota)).

%!  desarma(?B) is nondet.
%
%   La babushka B se puede desarmar por completo.
% Caso base: la muñeca maciza no tiene nada adentro.
desarma(babushka_maciza).
% Caso recursivo: se quita la muñeca hueca exterior y se desarma lo que queda.
desarma(babushka_hueca(Interior)) :-
    desarma(Interior).
