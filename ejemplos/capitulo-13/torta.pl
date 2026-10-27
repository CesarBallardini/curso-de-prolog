:- encoding(utf8).

% Capítulo 13 - Un programa sin variables.
%
% Cinco cláusulas sin variables ni argumentos: tres hechos y dos reglas. Una
% interpretación es el conjunto de los átomos que se toman como verdaderos, y
% el programa tiene tan pocos átomos que sus modelos se revisan a mano. La
% refutación de ?- torta. se sigue paso a paso, sin sustituciones.
%
%?- torta.
%?- masa.

% hay_harina: hay harina.
hay_harina.

% hay_huevos: hay huevos.
hay_huevos.

% hay_leche: hay leche.
hay_leche.

%!  masa is det.
%
%   Se puede preparar la masa: hay leche y hay harina.
masa :-
    hay_leche,
    hay_harina.

%!  torta is det.
%
%   Se puede hornear la torta: se puede preparar la masa y hay huevos.
torta :-
    masa,
    hay_huevos.
