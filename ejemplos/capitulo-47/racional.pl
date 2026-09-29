:- encoding(utf8).

% Capítulo 47 - Versión 1: los números racionales como términos.
%
% Un racional se representa con el término fr(N, D): el numerador N y el
% denominador D son enteros, D es positivo y los dos no tienen divisores
% comunes. Esa forma normal hace que dos racionales iguales sean el mismo
% término, y que la igualdad se decida por unificación. q_valor/2 evalúa
% una expresión con +, -, * y / sobre enteros y términos fr/2, como is/2
% evalúa una expresión sobre números.
%
%?- q_valor(1/3 + 1/6, Q).
%?- q_valor(fr(3, 4) * 2 - 1, Q).
%?- fraccion(6, -4, Q).
%?- armonica_q(10, Q).

:- use_module(library(error)).

%!  fraccion(+N:integer, +D:integer, -Q) is det.
%
%   Q es el racional N/D en forma normal: fr(N1, D1) con D1 positivo y sin
%   divisores comunes con N1. Produce un error de evaluación si D es 0.
fraccion(N, D, Q) :-
    must_be(integer, N),
    must_be(integer, D),
    (   D =:= 0
    ->  throw(error(evaluation_error(zero_divisor), fraccion/3))
    ;   true
    ),
    G is gcd(N, D) * sign(D),
    N1 is N // G,
    D1 is D // G,
    Q = fr(N1, D1).

%!  q_suma(+Q1, +Q2, -Q) is det.
%
%   Q es la suma de los racionales en forma normal Q1 y Q2.
q_suma(fr(A, B), fr(C, D), Q) :-
    N is A * D + C * B,
    M is B * D,
    fraccion(N, M, Q).

%!  q_resta(+Q1, +Q2, -Q) is det.
%
%   Q es la diferencia Q1 - Q2.
q_resta(fr(A, B), fr(C, D), Q) :-
    N is A * D - C * B,
    M is B * D,
    fraccion(N, M, Q).

%!  q_producto(+Q1, +Q2, -Q) is det.
%
%   Q es el producto de Q1 y Q2.
q_producto(fr(A, B), fr(C, D), Q) :-
    N is A * C,
    M is B * D,
    fraccion(N, M, Q).

%!  q_cociente(+Q1, +Q2, -Q) is det.
%
%   Q es el cociente Q1 / Q2. Produce un error de evaluación si Q2 es 0.
q_cociente(fr(A, B), fr(C, D), Q) :-
    N is A * D,
    M is B * C,
    fraccion(N, M, Q).

%!  q_comparar(-Orden, +Q1, +Q2) is det.
%
%   Orden es <, = o >, según Q1 sea menor, igual o mayor que Q2, como en
%   compare/3.
q_comparar(Orden, fr(A, B), fr(C, D)) :-
    X is A * D,
    Y is C * B,
    compare(Orden, X, Y).

%!  q_float(+Q, -F:float) is det.
%
%   F es el número de punto flotante más cercano al racional Q.
q_float(fr(N, D), F) :-
    F is float(N) / D.

%!  q_valor(+Expresion, -Q) is det.
%
%   Q es el valor, en forma normal, de Expresion: un entero, un término
%   fr/2 de enteros (que se normaliza), o la suma, la resta, el producto,
%   el cociente o el opuesto de expresiones. Produce un error de tipo con
%   cualquier otra cosa, y un error de evaluación si se divide por 0.
q_valor(E, _) :-
    var(E),
    !,
    instantiation_error(E).
q_valor(N, Q) :-
    integer(N),
    !,
    Q = fr(N, 1).
q_valor(fr(N, D), Q) :-
    !,
    fraccion(N, D, Q).
q_valor(A + B, Q) :-
    !,
    q_valor(A, QA),
    q_valor(B, QB),
    q_suma(QA, QB, Q).
q_valor(A - B, Q) :-
    !,
    q_valor(A, QA),
    q_valor(B, QB),
    q_resta(QA, QB, Q).
q_valor(A * B, Q) :-
    !,
    q_valor(A, QA),
    q_valor(B, QB),
    q_producto(QA, QB, Q).
q_valor(A / B, Q) :-
    !,
    q_valor(A, QA),
    q_valor(B, QB),
    q_cociente(QA, QB, Q).
q_valor(-A, Q) :-
    !,
    q_valor(A, fr(N, D)),
    N1 is -N,
    Q = fr(N1, D).
q_valor(E, _) :-
    type_error(expresion_racional, E).

%!  armonica_q(+N:integer, -Q) is det.
%
%   Q es la suma exacta 1/1 + 1/2 + ... + 1/N, con los términos fr/2. Si N
%   es 0, Q es 0.
armonica_q(N, Q) :-
    must_be(nonneg, N),
    armonica_q(N, fr(0, 1), Q).

%!  armonica_q(+K:integer, +Acumulado, -Q) is det.
%
%   Q es Acumulado más la suma de 1/1 hasta 1/K.
armonica_q(0, Q, Q) :-
    !.
armonica_q(K, Q0, Q) :-
    q_suma(Q0, fr(1, K), Q1),
    K1 is K - 1,
    armonica_q(K1, Q1, Q).
