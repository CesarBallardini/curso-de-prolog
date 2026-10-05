:- encoding(utf8).

% Capítulo 46 - Soluciones de los ejercicios 13 y 14.
%
% El evaluador de Covington ampliado con la potencia, el opuesto y la raíz
% cuadrada, y un resolvedor que recibe la incógnita como variable de
% Prolog y aplica los métodos de resolver/5.
%
% solo-local: carga los programas del capítulo 32, y SWISH no carga otros
% archivos.
%
%?- valor_ampliado(sqrt(2 ^ 2 * 4) - -1, V).
%?- resolver_variable(X ^ 2 = 2, M).

:- ensure_loaded(covington).

% Ejercicio 13

%!  valor_ampliado(+Expresion, -Valor:number) is det.
%
%   Como :=/2, con la potencia X ^ N de exponente entero, el opuesto -X y
%   sqrt/1 además de las operaciones de valor_c/2.
valor_ampliado(Expresion, Valor) :-
    must_be(ground, Expresion),
    (   ampliado(Expresion, Valor0)
    ->  Valor = Valor0
    ;   type_error(expresion_evaluable, Expresion)
    ).

%!  ampliado(+Expresion, -Valor:number) is semidet.
%
%   Valor es el valor de Expresion, un número o una operación de
%   operacion_ampliada/2. Falla si usa otra operación.
ampliado(E, V) :-
    (   number(E)
    ->  V = E
    ;   operacion_ampliada(E, V)
    ).

%!  operacion_ampliada(+Expresion, -Valor:number) is semidet.
%
%   Las cláusulas de operacion/2, con ampliado/2 para los argumentos, y
%   tres más.
operacion_ampliada(X + Y, V) :-
    ampliado(X, VX),
    ampliado(Y, VY),
    V is VX + VY.
operacion_ampliada(X - Y, V) :-
    ampliado(X, VX),
    ampliado(Y, VY),
    V is VX - VY.
operacion_ampliada(X * Y, V) :-
    ampliado(X, VX),
    ampliado(Y, VY),
    V is VX * VY.
operacion_ampliada(X / Y, V) :-
    ampliado(X, VX),
    ampliado(Y, VY),
    V is VX / VY.
operacion_ampliada(rec(X), V) :-
    ampliado(X, VX),
    V is 1 / VX.
operacion_ampliada(X ^ N, V) :-
    integer(N),
    ampliado(X, VX),
    V is VX ** N.
operacion_ampliada(-X, V) :-
    ampliado(X, VX),
    V is -VX.
operacion_ampliada(sqrt(X), V) :-
    ampliado(X, VX),
    V is sqrt(VX).

% Ejercicio 14

%!  resolver_variable(+Ecuacion, -Metodo:atom) is semidet.
%
%   Liga la variable libre de Ecuacion con una raíz que encuentra
%   resolver/5 desde 1, y Metodo con el método que la encontró. Falla si
%   Ecuacion no tiene variables o si ningún método encuentra una raíz.
resolver_variable(Ecuacion, Metodo) :-
    once(libre_en(Ecuacion, X)),
    nueva_incognita(Ecuacion, A),
    copy_term(X-Ecuacion, A-EcuacionA),
    resolver(EcuacionA, A, 1, Raiz, Metodo),
    X = Raiz.

%!  nueva_incognita(+Termino, -A:atom) is det.
%
%   A es el primero de los átomos x1, x2, ... que no aparece en Termino.
%   La comparación usa ==: sub_term(A, Termino) unificaría A con una
%   variable de Termino.
nueva_incognita(Termino, A) :-
    between(1, inf, N),
    atom_concat(x, N, A),
    \+ ( sub_term(S, Termino),
         S == A
       ),
    !.
