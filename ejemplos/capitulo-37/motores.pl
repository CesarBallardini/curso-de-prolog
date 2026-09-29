:- encoding(utf8).

% Capítulo 37 - Motores: una meta cuyas respuestas se piden de a una.
%
% Un motor corre una meta y entrega sus respuestas cuando se le piden, con
% engine_next/2; entre un pedido y el siguiente, la meta queda detenida.
% primeros/4 toma las primeras respuestas de un generador infinito;
% mezclar/3 combina dos generadores ordenados en uno; parciales/2 usa un
% motor como corrutina, que recibe un número con engine_post/3 y devuelve
% la suma de todos los que recibió.
%
% solo-local: SWISH no permite crear motores.
%
%?- primeros(5, X, multiplo(3, X), L).
%?- mezclar(10, multiplo(4), multiplo(6), L).
%?- parciales([5, 3, 10, 2], Ps).

%!  natural(-N:integer) is multi.
%
%   N es un número natural: 0, 1, 2, ... en ese orden, sin fin.
natural(N) :-
    between(0, inf, N).

%!  multiplo(+K:integer, -M:integer) is multi.
%
%   M es un múltiplo positivo de K, en orden creciente, sin fin.
multiplo(K, M) :-
    natural(N),
    M is K * (N + 1).

%!  primeros(+N:integer, ?Plantilla, :Meta, -Lista:list) is det.
%
%   Lista tiene la Plantilla de las primeras N respuestas de Meta, o de
%   todas si Meta tiene menos.
primeros(N, Plantilla, Meta, Lista) :-
    setup_call_cleanup(engine_create(Plantilla, Meta, Motor),
                       tomar(N, Motor, Lista),
                       engine_destroy(Motor)).

%!  tomar(+N:integer, +Motor, -Lista:list) is det.
%
%   Lista tiene las siguientes N respuestas de Motor, o las que le queden.
tomar(N, Motor, Lista) :-
    (   N > 0,
        engine_next(Motor, X)
    ->  Lista = [X|Resto],
        N1 is N - 1,
        tomar(N1, Motor, Resto)
    ;   Lista = []
    ).

%!  mezclar(+N:integer, :Gen1, :Gen2, -Lista:list) is det.
%
%   Gen1 y Gen2 generan números en orden creciente, con call(Gen, X). Lista
%   tiene los primeros N números que genera alguno de los dos, en orden y
%   sin repetidos.
mezclar(N, Gen1, Gen2, Lista) :-
    setup_call_cleanup(( engine_create(X, call(Gen1, X), M1),
                         engine_create(Y, call(Gen2, Y), M2) ),
                       ( engine_next(M1, X1),
                         engine_next(M2, Y1),
                         mezcla(N, X1, M1, Y1, M2, Lista) ),
                       ( engine_destroy(M1),
                         engine_destroy(M2) )).

%!  mezcla(+N:integer, +X, +M1, +Y, +M2, -Lista:list) is det.
%
%   Lista son los N menores números entre X, Y y los que siguen en los
%   motores M1 y M2, sin repetidos. X e Y son la última respuesta de cada
%   motor, todavía sin usar.
mezcla(0, _, _, _, _, []) :-
    !.
mezcla(N, X, M1, Y, M2, [Z|Zs]) :-
    N1 is N - 1,
    (   X < Y
    ->  Z = X,
        engine_next(M1, X1),
        mezcla(N1, X1, M1, Y, M2, Zs)
    ;   Y < X
    ->  Z = Y,
        engine_next(M2, Y1),
        mezcla(N1, X, M1, Y1, M2, Zs)
    ;   Z = X,
        engine_next(M1, X1),
        engine_next(M2, Y1),
        mezcla(N1, X1, M1, Y1, M2, Zs)
    ).

%!  sumar(+Total:number) is det.
%
%   El cuerpo del motor de parciales/2: recibe un número con engine_fetch/1,
%   entrega la suma acumulada con engine_yield/1 y sigue con la suma nueva.
sumar(Total0) :-
    engine_fetch(X),
    Total is Total0 + X,
    engine_yield(Total),
    sumar(Total).

%!  parciales(+Numeros:list(number), -Sumas:list(number)) is det.
%
%   Sumas tiene, para cada elemento de Numeros, la suma de ese y los
%   anteriores. Un solo motor recibe los números de a uno y conserva la
%   suma entre un pedido y el siguiente.
parciales(Numeros, Sumas) :-
    setup_call_cleanup(engine_create(_, sumar(0), Motor),
                       maplist(engine_post(Motor), Numeros, Sumas),
                       engine_destroy(Motor)).
