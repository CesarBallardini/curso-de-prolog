:- encoding(utf8).

% Capítulo 46 - Versión 3: el método de Newton.
%
% La recta tangente en X0 corta el eje en la aproximación siguiente. La
% pendiente es la derivada exacta, que derivar/3 del capítulo 32 calcula una
% sola vez, como expresión, antes de iterar.
%
% solo-local: carga los programas del capítulo 32, y SWISH no carga otros
% archivos.
%
%?- newton(x ^ 2 = 2, x, 1, R).
%?- newton(x ^ 3 - 2 * x + 2 = 0, x, 0, R).

:- ensure_loaded(iteracion).
:- ensure_loaded('../capitulo-32/soluciones_simplificar').

%!  newton(+Ecuacion, +X:atom, +X0:number, -Raiz:float) is semidet.
%
%   Raiz es una raíz de Ecuacion en la incógnita X, buscada desde X0, con
%   una tolerancia de 1.0e-12. Falla si el método no converge.
newton(Ecuacion, X, X0, Raiz) :-
    newton(Ecuacion, X, X0, 1.0e-12, Xs),
    last(Xs, Raiz).

%!  newton(+Ecuacion, +X:atom, +X0:number, +Tol:float,
%!         -Aproximaciones:list(float)) is semidet.
%
%   Aproximaciones son las que da el método desde X0, hasta que dos
%   seguidas difieren en Tol o menos. Falla si la derivada se anula en una
%   aproximación o si no converge en maximo_de_pasos/1 pasos. Ecuacion
%   solo puede usar +, -, * y ^ con exponente numérico, o derivar/3
%   produce un error de dominio.
newton(Ecuacion, X, X0, Tol, Xs) :-
    funcion(Ecuacion, F),
    derivar(F, X, DF),
    A is float(X0),
    iterar(paso_newton(F, DF, X), Tol, A, Xs).

%!  paso_newton(+F, +DF, +X:atom, +X0:float, -X1:float, -X1:float,
%!              -Cambio:float) is semidet.
%
%   X1 es el punto donde la tangente a F en X0 corta el eje; DF es la
%   derivada de F. El estado y la aproximación son el mismo número. Falla
%   si la derivada vale 0 en X0.
paso_newton(F, DF, X, X0, X1, X1, Cambio) :-
    valor_en(F, X, X0, F0),
    valor_en(DF, X, X0, D0),
    D0 =\= 0,
    X1 is X0 - F0 / D0,
    Cambio is abs(X1 - X0).
