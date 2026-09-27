:- encoding(utf8).

% Capítulo 20 - Memorización: guardar un resultado calculado y reutilizarlo.
%
% fib/2 recalcula los mismos valores una y otra vez: fib(25, F) llama a
% fib(1, _) decenas de miles de veces. fib_memo/2 guarda cada valor en el
% hecho dinámico fib_guardado/2 la primera vez que lo calcula.
%
%?- fib_memo(25, F).
%?- olvidar_fib, inferencias(fib(20, _), I).

:- dynamic fib_guardado/2.

%!  fib(+N:integer, -F:integer) is det.
%
%   F es el N-ésimo número de Fibonacci: fib(0) = 0, fib(1) = 1, y cada uno
%   de los siguientes es la suma de los dos anteriores.
fib(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib(N1, F1),
        fib(N2, F2),
        F is F1 + F2
    ).

%!  fib_memo(+N:integer, -F:integer) is det.
%
%   La misma relación que fib/2. Cada valor calculado se guarda en
%   fib_guardado/2, y se busca allí antes de calcularlo.
fib_memo(N, F) :-
    (   fib_guardado(N, F0)
    ->  F = F0
    ;   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib_memo(N1, F1),
        fib_memo(N2, F2),
        F0 is F1 + F2,
        assertz(fib_guardado(N, F0)),
        F = F0
    ).

%!  olvidar_fib is det.
%
%   Borra los valores guardados por fib_memo/2.
olvidar_fib :-
    retractall(fib_guardado(_, _)).

%!  inferencias(:Objetivo, -I:integer) is det.
%
%   I es la cantidad de inferencias que usa la primera respuesta de Objetivo.
inferencias(Objetivo, I) :-
    statistics(inferences, I0),
    once(Objetivo),
    statistics(inferences, I1),
    I is I1 - I0.
