:- encoding(utf8).

% Capítulo 46 - Versión 1: el método de bisección.
%
% Un intervalo A-B en cuyos extremos la función tiene signos opuestos
% contiene una raíz. Cada paso lo parte por la mitad y se queda con la
% mitad donde el signo cambia: el intervalo se reduce a la mitad por paso.
%
% solo-local: carga los programas del capítulo 32, y SWISH no carga otros
% archivos.
%
%?- biseccion(x ^ 2 = 2, x, 1-2, R).
%?- biseccion(x ^ 2 = 2, x, 1-2, 1.0e-3, Xs).

:- ensure_loaded(iteracion).

%!  biseccion(+Ecuacion, +X:atom, +Intervalo, -Raiz:float) is semidet.
%
%   Raiz es una raíz de Ecuacion en la incógnita X dentro de Intervalo,
%   A-B, con una tolerancia de 1.0e-12.
biseccion(Ecuacion, X, Intervalo, Raiz) :-
    biseccion(Ecuacion, X, Intervalo, 1.0e-12, Xs),
    last(Xs, Raiz).

%!  biseccion(+Ecuacion, +X:atom, +Intervalo, +Tol:float,
%!            -Aproximaciones:list(float)) is semidet.
%
%   Aproximaciones son los puntos medios de los intervalos sucesivos, hasta
%   que el ancho del intervalo es menor o igual que Tol. Intervalo es A-B
%   con A < B, y la función debe tener signos opuestos en A y en B, o se
%   produce un error de dominio.
biseccion(Ecuacion, X, A0-B0, Tol, Xs) :-
    funcion(Ecuacion, F),
    A is float(A0),
    B is float(B0),
    valor_en(F, X, A, FA),
    valor_en(F, X, B, FB),
    (   A < B,
        FA * FB =< 0
    ->  iterar(paso_biseccion(F, X), Tol, intervalo(A, FA, B), Xs)
    ;   domain_error(intervalo_con_cambio_de_signo, A0-B0)
    ).

%!  paso_biseccion(+F, +X:atom, +Intervalo0, -Intervalo, -M:float,
%!                 -Ancho:float) is det.
%
%   Intervalo es la mitad de Intervalo0, intervalo(A, FA, B), en la que F
%   cambia de signo; M es el punto medio y Ancho el ancho de la mitad.
paso_biseccion(F, X, intervalo(A, FA, B), Intervalo, M, Ancho) :-
    M is (A + B) / 2,
    valor_en(F, X, M, FM),
    Ancho is (B - A) / 2,
    (   FA * FM =< 0
    ->  Intervalo = intervalo(A, FA, M)
    ;   Intervalo = intervalo(M, FM, B)
    ).
