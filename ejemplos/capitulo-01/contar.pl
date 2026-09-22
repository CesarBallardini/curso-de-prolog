:- encoding(utf8).

% Capítulo 1 - Enumeración de números.
%
% between/3 genera, de a uno por vez, todos los enteros de un intervalo. Una
% regla recursiva también puede recorrer un intervalo numérico.
%
%?- between(1, 5, N).
%?- cuenta(1, 5).

% cuenta(Desde, Hasta): escribe los números de Desde a Hasta, uno por línea.
cuenta(Desde, Hasta) :-
    Desde =< Hasta,
    format("~w~n", [Desde]),
    Siguiente is Desde + 1,
    cuenta(Siguiente, Hasta).
cuenta(Desde, Hasta) :-
    Desde > Hasta.

% suma_hasta(N, S): S es la suma de todos los números de 1 a N.
suma_hasta(0, 0).
suma_hasta(N, S) :-
    N > 0,
    Anterior is N - 1,
    suma_hasta(Anterior, SumaAnterior),
    S is SumaAnterior + N.
