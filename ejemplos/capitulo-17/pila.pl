:- encoding(utf8).

% Capítulo 17 - La pila, la recursión y el costo de agregar al final.
%
% longitud/2 y reversa/2 son los del capítulo 7; las versiones con acumulador,
% las del capítulo 8. Las cuatro son correctas; lo que las distingue es cuánta
% memoria y cuántas inferencias usan.
%
%?- numlist(1, 1000, L), inferencias(reversa(L, _), I).
%?- numlist(1, 1000, L), inferencias(reversa_acc(L, _), I).

%!  longitud(+L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L. La suma se hace al volver de la
%   llamada recursiva: cada llamada queda en la pila hasta que termina la
%   siguiente.
longitud([], 0).
longitud([_|Resto], N) :-
    longitud(Resto, Faltan),
    N is Faltan + 1.

%!  longitud_acc(+L:list, -N:integer) is det.
%
%   La misma relación, con un acumulador.
longitud_acc(L, N) :-
    contando(L, 0, N).

%!  contando(+L:list, +Hasta:integer, -N:integer) is det.
%
%   N es Hasta más la cantidad de elementos de L. La llamada recursiva es el
%   último objetivo de la cláusula: SWI-Prolog reutiliza el espacio de la
%   llamada actual.
contando([], N, N).
contando([_|Resto], Hasta, N) :-
    Ahora is Hasta + 1,
    contando(Resto, Ahora, N).

%!  reversa(+L:list, -R:list) is det.
%
%   R es L en orden inverso. Por cada elemento, append/3 recorre todo lo ya
%   invertido para agregarlo al final.
reversa([], []).
reversa([X|Resto], R) :-
    reversa(Resto, RestoAlReves),
    append(RestoAlReves, [X], R).

%!  reversa_acc(+L:list, -R:list) is det.
%
%   La misma relación, con un acumulador: cada elemento se agrega al
%   comienzo, en un paso.
reversa_acc(L, R) :-
    invirtiendo(L, [], R).

%!  invirtiendo(+L:list, +Hasta:list, -R:list) is det.
%
%   R es L invertida seguida de Hasta.
invirtiendo([], R, R).
invirtiendo([X|Resto], Hasta, R) :-
    invirtiendo(Resto, [X|Hasta], R).

%!  inferencias(:Objetivo, -I:integer) is det.
%
%   I es la cantidad de inferencias que usa Objetivo hasta agotar todas sus
%   respuestas.
inferencias(Objetivo, I) :-
    statistics(inferences, I0),
    forall(Objetivo, true),
    statistics(inferences, I1),
    I is I1 - I0.
