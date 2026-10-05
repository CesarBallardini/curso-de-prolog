:- encoding(utf8).

% Capítulo 46 - Versión 6: la incógnita como variable de Prolog.
%
% El programa de Covington (Prolog Programming in Depth, 7.13) escribe la
% ecuación con una variable de Prolog como incógnita: resolver_libre/1
% busca esa variable con libre_en/2 y, si encuentra una raíz, la liga con
% ella. La diferencia entre los dos miembros se evalúa en cada punto sobre
% una copia de la ecuación hecha con copy_term/2, en lugar de agregar al
% programa una cláusula con assert. :=/2 es el evaluador de la figura 7.9
% del mismo apartado, escrito con una cláusula por operación.
%
% solo-local: carga los programas del capítulo 32, y SWISH no carga otros
% archivos.
%
%?- R := 2 * rec(4) + 1.
%?- resolver_libre(X + 1 = 1 / X).

:- ensure_loaded(metodos).

%!  :=(-Valor:number, +Expresion) is det.
%
%   Valor es el valor de Expresion, un término cerrado con números, +, -,
%   *, / y rec/1, el recíproco. Produce un error de instanciación si
%   Expresion tiene variables, y un error de tipo si usa otra operación.
Valor := Expresion :-
    must_be(ground, Expresion),
    (   valor_c(Expresion, Valor0)
    ->  Valor = Valor0
    ;   type_error(expresion_evaluable, Expresion)
    ).

%!  valor_c(+Expresion, -Valor:number) is semidet.
%
%   Valor es el valor de Expresion, un número o una operación. Falla si
%   Expresion usa otra operación.
valor_c(E, V) :-
    (   number(E)
    ->  V = E
    ;   operacion(E, V)
    ).

%!  operacion(+Expresion, -Valor:number) is semidet.
%
%   Valor es el valor de la operación Expresion. Hay una cláusula por
%   operación, y la indexación por el functor del primer argumento elige
%   la que corresponde.
operacion(X + Y, V) :-
    valor_c(X, VX),
    valor_c(Y, VY),
    V is VX + VY.
operacion(X - Y, V) :-
    valor_c(X, VX),
    valor_c(Y, VY),
    V is VX - VY.
operacion(X * Y, V) :-
    valor_c(X, VX),
    valor_c(Y, VY),
    V is VX * VY.
operacion(X / Y, V) :-
    valor_c(X, VX),
    valor_c(Y, VY),
    V is VX / VY.
operacion(rec(X), V) :-
    valor_c(X, VX),
    V is 1 / VX.

%!  libre_en(+Termino, -X) is nondet.
%
%   X es una variable libre que aparece en Termino. Da una respuesta por
%   cada aparición, de izquierda a derecha.
libre_en(X, X) :-
    var(X).
libre_en(T, X) :-
    compound(T),
    arg(_, T, A),
    libre_en(A, X).

%!  resolver_libre(+Ecuacion) is semidet.
%
%   Ecuacion es Izq = Der con una variable libre, la incógnita, que queda
%   ligada con una raíz. Como el programa de Covington, aplica la secante
%   desde 1 y 2. Falla si Ecuacion no tiene variables o si la secante
%   falla; otra variable libre en Ecuacion produce un error de
%   instanciación.
resolver_libre(Izq = Der) :-
    once(libre_en(Izq = Der, X)),
    F = Izq - Der,
    diferencia_en(X, F, 1.0, F1),
    diferencia_en(X, F, 2.0, F2),
    iterar(paso_libre(X, F), 1.0e-12, secante(1.0, F1, 2.0, F2), Xs),
    last(Xs, X).

%!  diferencia_en(+X, +F, +A:number, -V:float) is det.
%
%   V es el valor de la expresión F cuando su variable X vale A. Evalúa
%   una copia de F, de modo que F y X quedan libres.
diferencia_en(X, F, A, V) :-
    copy_term(X-F, A-F1),
    V is float(F1).

%!  paso_libre(+X, +F, +Estado0, -Estado, -X2:float, -Cambio:float)
%!      is semidet.
%
%   Como paso_secante/6, con la incógnita X como variable de Prolog.
paso_libre(X, F, secante(X0, F0, X1, F1), secante(X1, F1, X2, F2), X2,
           Cambio) :-
    F1 =\= F0,
    X2 is X1 - F1 * (X1 - X0) / (F1 - F0),
    diferencia_en(X, F, X2, F2),
    Cambio is abs(X2 - X1).
