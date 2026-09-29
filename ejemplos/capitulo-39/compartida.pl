:- encoding(utf8).

% Capítulo 39 - Tablas y hilos: cada hilo tiene sus tablas, salvo las
% compartidas.
%
% Las tablas de SWI-Prolog son de cada hilo: lo que un hilo calcula en una
% tabla común no lo ve ningún otro. fib_privada/2 tiene una tabla común;
% fib_compartida/2 la declara shared, y la tabla que completa un hilo la
% usan todos. en_otro_hilo/1 ejecuta una meta en un hilo nuevo y espera a
% que termine; inferencias/2 es la del capítulo 20.
%
% solo-local: SWISH no permite crear hilos.
%
%?- en_otro_hilo(fib_compartida(300, _)), inferencias(fib_compartida(300, _), I).

:- table fib_privada/2.

%!  fib_privada(+N:integer, -F:integer) is det.
%
%   F es el N-ésimo número de Fibonacci, con una tabla de cada hilo.
fib_privada(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib_privada(N1, F1),
        fib_privada(N2, F2),
        F is F1 + F2
    ).

:- table fib_compartida/2 as shared.

%!  fib_compartida(+N:integer, -F:integer) is det.
%
%   La misma relación, con una tabla que comparten todos los hilos.
fib_compartida(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib_compartida(N1, F1),
        fib_compartida(N2, F2),
        F is F1 + F2
    ).

%!  en_otro_hilo(:Meta) is semidet.
%
%   Ejecuta once(Meta) en un hilo nuevo y espera a que termine. Falla si
%   Meta falla o produce una excepción.
en_otro_hilo(Meta) :-
    thread_create(once(Meta), Id, []),
    thread_join(Id, true).

%!  inferencias(:Objetivo, -I:integer) is det.
%
%   I es la cantidad de inferencias que usa la primera respuesta de
%   Objetivo.
inferencias(Objetivo, I) :-
    statistics(inferences, I0),
    once(Objetivo),
    statistics(inferences, I1),
    I is I1 - I0.
