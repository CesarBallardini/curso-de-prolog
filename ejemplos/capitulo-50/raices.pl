:- encoding(utf8).

% Capítulo 50 - Versión 2: las raíces de la unidad, simplificadas y
% evaluadas.
%
% w(K) es la potencia K de una raíz N-ésima de la unidad, y cumple dos
% identidades: w(N) = 1, de modo que el exponente se reduce módulo N, y
% w(N/2) = -1, de modo que w(K) = -w(K - N/2) cuando K es al menos N/2.
% simplificar_raices/3 aplica esas reglas y las del simplificador del
% capítulo 32 (regla/2), de abajo hacia arriba como aquel: la segunda
% identidad se aplica dentro de una suma, X + w(K) * Y, que pasa a ser una
% resta. valor/4 evalúa una expresión con números complejos, c(Re, Im),
% dados los valores de los coeficientes, y definicion/2 calcula la
% transformada directamente, sin expresiones, para comparar.
%
% solo-local: carga tdf.pl, y SWISH no carga otros archivos.
%
%?- simplificar_raices(8, a(0) + w(12) * a(1), E).
%?- tdf_ingenua(4, Es0), maplist(simplificar_raices(4), Es0, Es).
%?- tdf_ingenua(4, [E|_]), valor(4, [1, 2, 3, 4], E, V).
%?- definicion([1, 2, 3, 4], Vs).

:- ensure_loaded(tdf).

% costo/4, declarada en tdf.pl: las expresiones de la matriz, simplificadas.
costo(simplificada, N, S, P) :-
    tdf_ingenua(N, Es0),
    maplist(simplificar_raices(N), Es0, Es),
    operaciones(Es, S, P).

%!  simplificar_raices(+N:integer, +E0, -E) is det.
%
%   E es la expresión cerrada E0, con raíces N-ésimas de la unidad w(K),
%   simplificada: ninguna regla de raiz/3 ni de regla/2 se aplica a
%   ninguno de sus nodos. Produce un error de instanciación si E0 tiene
%   variables.
simplificar_raices(N, E0, E) :-
    must_be(positive_integer, N),
    must_be(ground, E0),
    simp_raices(N, E0, E).

%!  simp_raices(+N:integer, +E0, -E) is det.
%
%   E es E0 simplificada, como en simplificar_raices/3, sin verificar los
%   argumentos.
simp_raices(N, E0, E) :-
    (   compound(E0)
    ->  mapargs(simp_raices(N), E0, E1)
    ;   E1 = E0
    ),
    (   regla_raices(N, E1, E2)
    ->  simp_raices(N, E2, E)
    ;   E = E1
    ).

%!  regla_raices(+N:integer, +E0, -E) is nondet.
%
%   E es el resultado de reescribir la raíz de E0 con una regla de las
%   raíces de la unidad o, si no, con una del simplificador del capítulo
%   32.
regla_raices(N, E0, E) :-
    raiz(N, E0, E).
regla_raices(_, E0, E) :-
    regla(E0, E).

%!  raiz(+N:integer, +E0, -E) is semidet.
%
%   E es E0 reescrita con una identidad de las raíces N-ésimas de la
%   unidad: el exponente se reduce módulo N, w(0) es 1, y una suma
%   X + w(K) * Y con K de N/2 en adelante es la resta X - w(K - N/2) * Y.
raiz(N, w(K), w(K1)) :-
    K1 is K mod N,
    K1 =\= K.
raiz(_, w(0), 1).
raiz(N, X + w(K) * Y, X - w(K1) * Y) :-
    2 * K >= N,
    K1 is K - N // 2.

%!  valor(+N:integer, +Coefs:list, +E, -V) is det.
%
%   V es el valor complejo c(Re, Im) de la expresión E cuando w(K) es la
%   potencia K de la raíz N-ésima de la unidad exp(2 pi i / N) y a(J) es el
%   elemento J de Coefs, contando desde 0. Los elementos de Coefs son
%   números o complejos c(Re, Im).
valor(_, _, X, c(X, 0)) :-
    number(X),
    !.
valor(_, Coefs, a(J), V) :-
    !,
    nth0(J, Coefs, C),
    complejo(C, V).
valor(N, _, w(K), V) :-
    !,
    raiz_numerica(N, K, V).
valor(N, Coefs, E, V) :-
    E =.. [Op, A, B],
    valor(N, Coefs, A, VA),
    valor(N, Coefs, B, VB),
    operar(Op, VA, VB, V).

%!  complejo(+C, -V) is det.
%
%   V es el complejo c(Re, Im) que representa C, un número o un complejo.
complejo(c(R, I), c(R, I)) :-
    !.
complejo(X, c(X, 0)).

%!  raiz_numerica(+N:integer, +K:integer, -V) is det.
%
%   V es la potencia K de exp(2 pi i / N), como complejo de punto flotante.
raiz_numerica(N, K, c(R, I)) :-
    T is 2 * pi * K / N,
    R is cos(T),
    I is sin(T).

%!  operar(+Op, +A, +B, -V) is det.
%
%   V es el complejo A Op B, con Op entre +, - y *.
operar(+, c(A, B), c(C, D), c(R, I)) :-
    R is A + C,
    I is B + D.
operar(-, c(A, B), c(C, D), c(R, I)) :-
    R is A - C,
    I is B - D.
operar(*, c(A, B), c(C, D), c(R, I)) :-
    R is A * C - B * D,
    I is A * D + B * C.

%!  definicion(+Coefs:list, -Vs:list) is det.
%
%   Vs es la transformada de Coefs calculada con la definición: el
%   elemento K es la suma de los Coefs[J] * exp(2 pi i J K / N), con N la
%   longitud de Coefs.
definicion(Coefs, Vs) :-
    length(Coefs, N),
    N1 is N - 1,
    numlist(0, N1, Ks),
    maplist(salida_definicion(Coefs, N), Ks, Vs).

%!  salida_definicion(+Coefs:list, +N:integer, +K:integer, -V) is det.
%
%   V es el elemento K de la transformada de Coefs, de longitud N.
salida_definicion(Coefs, N, K, V) :-
    foldl(sumar_termino(N, K), Coefs, 0-c(0, 0), _-V).

%!  sumar_termino(+N, +K, +C, +S0, -S) is det.
%
%   S0 es J-Suma, con J la posición del coeficiente C, y S es J+1 seguido
%   de Suma más C * exp(2 pi i J K / N).
sumar_termino(N, K, C, J-S0, J1-S) :-
    P is J * K,
    raiz_numerica(N, P, W),
    complejo(C, VC),
    operar(*, W, VC, T),
    operar(+, S0, T, S),
    J1 is J + 1.

%!  cercanos(+Vs:list, +Ws:list) is semidet.
%
%   Los complejos de Vs y de Ws, en el mismo orden, difieren en menos de
%   1.0e-9 en cada componente.
cercanos(Vs, Ws) :-
    maplist(cercano, Vs, Ws).

%!  cercano(+V, +W) is semidet.
%
%   Los complejos V y W difieren en menos de 1.0e-9 en cada componente.
cercano(c(A, B), c(C, D)) :-
    abs(A - C) < 1.0e-9,
    abs(B - D) < 1.0e-9.
