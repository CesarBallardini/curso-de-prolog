:- encoding(utf8).

% Capítulo 39 - Memorización sin estado escrito a mano.
%
% fib/2 es la definición del capítulo 20, que recalcula los mismos valores
% una y otra vez. fib_tabla/2 tiene las mismas cláusulas y la directiva
% table: cada valor se calcula una vez, sin un predicado dinámico ni un
% predicado que lo borre. caminos_grilla/3 es un problema de programación
% dinámica: los recorridos de una grilla que solo avanzan hacia la derecha o
% hacia abajo; con la tabla, cada celda se resuelve una vez.
%
%?- fib_tabla(100, F).
%?- caminos_grilla(16, 16, N).

%!  fib(+N:integer, -F:integer) is det.
%
%   F es el N-ésimo número de Fibonacci, sin tabla.
fib(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib(N1, F1),
        fib(N2, F2),
        F is F1 + F2
    ).

:- table fib_tabla/2.

%!  fib_tabla(+N:integer, -F:integer) is det.
%
%   La misma relación que fib/2, tabulada.
fib_tabla(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib_tabla(N1, F1),
        fib_tabla(N2, F2),
        F is F1 + F2
    ).

:- table caminos_grilla/3.

%!  caminos_grilla(+F:integer, +C:integer, -N:integer) is det.
%
%   N es la cantidad de recorridos desde la celda (0, 0) hasta la celda
%   (F, C) que en cada paso avanzan una fila o una columna. F y C son
%   naturales.
caminos_grilla(F, C, N) :-
    (   ( F =:= 0 ; C =:= 0 )
    ->  N = 1
    ;   camino_interior(F, C, N)
    ).

%!  camino_interior(+F:integer, +C:integer, -N:integer) is det.
%
%   N es la cantidad de recorridos hasta (F, C), con F y C positivos: los
%   que llegan desde la fila anterior más los que llegan desde la columna
%   anterior.
camino_interior(F, C, N) :-
    F1 is F - 1,
    C1 is C - 1,
    caminos_grilla(F1, C, N1),
    caminos_grilla(F, C1, N2),
    N is N1 + N2.
