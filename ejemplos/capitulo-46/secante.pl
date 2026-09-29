:- encoding(utf8).

% Capítulo 46 - Versión 2: el método de la secante.
%
% Parte de dos aproximaciones, X0 y X1. La recta que pasa por los puntos
% (X0, F(X0)) y (X1, F(X1)) corta el eje en la aproximación siguiente. No
% necesita un intervalo con cambio de signo, pero puede no converger.
%
% solo-local: carga los programas del capítulo 32, y SWISH no carga otros
% archivos.
%
%?- secante(x ^ 2 = 2, x, 1-2, R).
%?- secante(x = cos(x), x, 1-2, R).

:- ensure_loaded(iteracion).

%!  secante(+Ecuacion, +X:atom, +Inicio, -Raiz:float) is semidet.
%
%   Raiz es una raíz de Ecuacion en la incógnita X, buscada desde Inicio,
%   un par X0-X1, con una tolerancia de 1.0e-12. Falla si el método no
%   converge.
secante(Ecuacion, X, Inicio, Raiz) :-
    secante(Ecuacion, X, Inicio, 1.0e-12, Xs),
    last(Xs, Raiz).

%!  secante(+Ecuacion, +X:atom, +Inicio, +Tol:float,
%!          -Aproximaciones:list(float)) is semidet.
%
%   Aproximaciones son las que da el método desde Inicio, X0-X1, hasta que
%   dos seguidas difieren en Tol o menos. Falla si dos aproximaciones
%   seguidas tienen el mismo valor de la función (la secante no corta el
%   eje) o si no converge en maximo_de_pasos/1 pasos.
secante(Ecuacion, X, X0-X1, Tol, Xs) :-
    funcion(Ecuacion, F),
    A is float(X0),
    B is float(X1),
    valor_en(F, X, A, FA),
    valor_en(F, X, B, FB),
    iterar(paso_secante(F, X), Tol, secante(A, FA, B, FB), Xs).

%!  paso_secante(+F, +X:atom, +Estado0, -Estado, -X2:float,
%!               -Cambio:float) is semidet.
%
%   X2 es el punto donde la secante por los dos puntos de Estado0,
%   secante(X0, F0, X1, F1), corta el eje; Estado tiene los dos últimos
%   puntos. Falla si F0 y F1 son iguales.
paso_secante(F, X, secante(X0, F0, X1, F1), secante(X1, F1, X2, F2), X2,
             Cambio) :-
    F1 =\= F0,
    X2 is X1 - F1 * (X1 - X0) / (F1 - F0),
    valor_en(F, X, X2, F2),
    Cambio is abs(X2 - X1).
