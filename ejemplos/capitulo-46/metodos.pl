:- encoding(utf8).

% Capítulo 46 - Versión 5: el programa terminado.
%
% resolver/5 elige el método: Newton cuando la ecuación se puede derivar y
% converge; si no, la secante; y si hay un intervalo con cambio de signo y
% ninguno de los dos da una raíz dentro de él, la bisección, que no puede
% fallar. errores/3 mide la convergencia de una sucesión de aproximaciones.
%
% solo-local: carga los programas del capítulo 32, y SWISH no carga otros
% archivos.
%
%?- resolver(x ^ 3 - 2 * x + 2 = 0, x, 0, R, M).
%?- resolver(x = cos(x), x, 0-1, R, M).

:- ensure_loaded(biseccion).
:- ensure_loaded(secante).
:- ensure_loaded(newton).
:- ensure_loaded(gauss_seidel).

:- meta_predicate
    derivable(0).

%!  resolver(+Ecuacion, +X:atom, +Inicio, -Raiz:float, -Metodo:atom)
%!      is semidet.
%
%   Raiz es una raíz de Ecuacion en la incógnita X y Metodo el método que
%   la encontró. Inicio es un número, la primera aproximación, o un
%   intervalo A-B, y entonces Raiz está dentro de él. Falla si ningún
%   método encuentra una raíz; con un intervalo sin cambio de signo, si
%   Newton y la secante no dan una raíz dentro de él, produce el error de
%   dominio de biseccion/5.
resolver(Ecuacion, X, Inicio, Raiz, Metodo) :-
    punto_inicial(Inicio, X0),
    par_inicial(Inicio, Par),
    (   derivable(newton(Ecuacion, X, X0, Raiz0)),
        dentro(Inicio, Raiz0)
    ->  Raiz = Raiz0,
        Metodo = newton
    ;   secante(Ecuacion, X, Par, Raiz0),
        dentro(Inicio, Raiz0)
    ->  Raiz = Raiz0,
        Metodo = secante
    ;   Inicio = _-_
    ->  biseccion(Ecuacion, X, Inicio, Raiz),
        Metodo = biseccion
    ).

%!  punto_inicial(+Inicio, -X0:number) is det.
%
%   X0 es Inicio si es un número, y el punto medio si es un intervalo A-B.
punto_inicial(Inicio, X0) :-
    (   Inicio = A-B
    ->  X0 is (A + B) / 2
    ;   must_be(number, Inicio),
        X0 = Inicio
    ).

%!  par_inicial(+Inicio, -Par) is det.
%
%   Par son las dos primeras aproximaciones de la secante: los extremos de
%   un intervalo, o X0 y X0 + 1 si Inicio es un número X0.
par_inicial(Inicio, Par) :-
    (   Inicio = _-_
    ->  Par = Inicio
    ;   X1 is Inicio + 1,
        Par = Inicio-X1
    ).

%!  dentro(+Inicio, +Raiz:float) is semidet.
%
%   Raiz está dentro de Inicio si es un intervalo A-B; con un número como
%   Inicio, toda raíz vale.
dentro(Inicio, Raiz) :-
    (   Inicio = A-B
    ->  A =< Raiz,
        Raiz =< B
    ;   true
    ).

%!  derivable(:Meta) is semidet.
%
%   Ejecuta Meta, y falla en lugar del error de dominio que produce
%   derivar/3 con una expresión que no sabe derivar.
derivable(Meta) :-
    catch(Meta, error(domain_error(expresion_derivable, _), _), fail).

%!  errores(+Xs:list(float), +Exacto:number, -Es:list(float)) is det.
%
%   Es son las distancias de cada aproximación de Xs al valor Exacto.
errores(Xs, Exacto, Es) :-
    maplist(error_de(Exacto), Xs, Es).

%!  error_de(+Exacto:number, +X:float, -E:float) is det.
%
%   E es la distancia de X a Exacto.
error_de(Exacto, X, E) :-
    E is abs(X - Exacto).
