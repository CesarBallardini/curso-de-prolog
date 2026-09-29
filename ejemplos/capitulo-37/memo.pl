:- encoding(utf8).

% Capítulo 37 - La memorización del capítulo 20 con varios hilos.
%
% fib_compartido/2 guarda los valores en un predicado dinámico, que todos
% los hilos comparten: dos hilos que calculan el mismo valor a la vez lo
% guardan dos veces. fib_local/2 los guarda en un predicado thread_local:
% cada hilo tiene su propia tabla, sin repetidos, y la pierde al terminar.
% en_hilos/3 calcula lo mismo en varios hilos a la vez.
%
% solo-local: SWISH no permite crear hilos.
%
%?- en_hilos(fib_local, 8, 300).

:- dynamic guardado/2.
:- thread_local guardado_local/2.

%!  fib_compartido(+N:integer, -F:integer) is det.
%
%   F es el N-ésimo número de Fibonacci. Cada valor calculado se guarda en
%   guardado/2, que comparten todos los hilos.
fib_compartido(N, F) :-
    (   guardado(N, F0)
    ->  F = F0
    ;   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib_compartido(N1, F1),
        fib_compartido(N2, F2),
        F0 is F1 + F2,
        assertz(guardado(N, F0)),
        F = F0
    ).

%!  fib_local(+N:integer, -F:integer) is det.
%
%   La misma relación, con los valores en guardado_local/2: cada hilo ve
%   solo los que guardó él.
fib_local(N, F) :-
    (   guardado_local(N, F0)
    ->  F = F0
    ;   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib_local(N1, F1),
        fib_local(N2, F2),
        F0 is F1 + F2,
        assertz(guardado_local(N, F0)),
        F = F0
    ).

%!  en_hilos(:Fib, +Hilos:integer, +N:integer) is semidet.
%
%   Calcula call(Fib, N, _) en Hilos hilos a la vez, con las tablas vacías
%   al empezar. Tiene éxito si todos obtienen el mismo valor que fib_local/2
%   en el hilo que llama.
en_hilos(Fib, Hilos, N) :-
    retractall(guardado(_, _)),
    retractall(guardado_local(_, _)),
    fib_local(N, Esperado),
    retractall(guardado_local(_, _)),
    length(Ids, Hilos),
    maplist(hilo_fib(Fib, N, Esperado), Ids),
    maplist(thread_join, Ids, Estados),
    maplist(==(true), Estados).

%!  hilo_fib(:Fib, +N:integer, +Esperado:integer, -Id) is det.
%
%   Id es un hilo nuevo que calcula call(Fib, N, F) y comprueba F =:=
%   Esperado.
hilo_fib(Fib, N, Esperado, Id) :-
    thread_create(( call(Fib, N, F),
                    F =:= Esperado ),
                  Id).
