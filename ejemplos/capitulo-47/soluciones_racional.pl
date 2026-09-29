:- encoding(utf8).

% Capítulo 47 - Soluciones de los ejercicios 1 a 5: los racionales.
%
% solo-local: carga racional.pl y nativos.pl, y SWISH no carga otros
% archivos.
%
%?- q_potencia(fr(2, 3), -2, P).
%?- dec_valor(dec(125, -2), Q).
%?- fraccion_continua(415r93, Cs).
%?- mejor_aproximacion(pi, 1000, Q).

:- ensure_loaded(racional).
:- ensure_loaded(nativos).

% Ejercicio 2

%!  q_potencia(+Q, +E:integer, -P) is det.
%
%   P es el racional en forma normal Q elevado al entero E. Produce un
%   error de evaluación si Q es 0 y E es negativo.
q_potencia(fr(N, D), E, P) :-
    must_be(integer, E),
    (   E >= 0
    ->  A is N ^ E,
        B is D ^ E
    ;   K is -E,
        A is D ^ K,
        B is N ^ K
    ),
    fraccion(A, B, P).

% Ejercicio 3

%!  dec_suma(+X, +Y, -Z) is det.
%
%   Z es la suma de los decimales dec(M, E), que valen M * 10^E, X e Y.
%   El exponente de Z es el menor de los dos.
dec_suma(dec(M1, E1), dec(M2, E2), dec(M, E)) :-
    E is min(E1, E2),
    M is M1 * 10 ^ (E1 - E) + M2 * 10 ^ (E2 - E).

%!  dec_producto(+X, +Y, -Z) is det.
%
%   Z es el producto de los decimales X e Y.
dec_producto(dec(M1, E1), dec(M2, E2), dec(M, E)) :-
    M is M1 * M2,
    E is E1 + E2.

%!  dec_valor(+X, -Q:rational) is det.
%
%   Q es el racional de SWI-Prolog que vale el decimal X.
dec_valor(dec(M, E), Q) :-
    (   E >= 0
    ->  Q is M * 10 ^ E
    ;   K is -E,
        Q is M rdiv 10 ^ K
    ).

%!  dec_de_racional(+Q:rational, -X) is semidet.
%
%   X es el decimal que vale el racional Q. Falla si Q no tiene una
%   escritura decimal finita: si su denominador tiene un factor primo
%   distinto de 2 y de 5.
dec_de_racional(Q, dec(M, E)) :-
    rational(Q, N, D),
    sin_factor(D, 2, D1, A),
    sin_factor(D1, 5, 1, B),
    K is max(A, B),
    M is N * 10 ^ K // D,
    E is -K.

%!  sin_factor(+N:integer, +P:integer, -R:integer, -K:integer) is det.
%
%   N es R * P^K, y R no es divisible por P.
sin_factor(N, P, R, K) :-
    (   N mod P =:= 0
    ->  N1 is N // P,
        sin_factor(N1, P, R, K0),
        K is K0 + 1
    ;   R = N,
        K = 0
    ).

% Ejercicio 4

%!  fraccion_continua(+Q:rational, -Cocientes:list(integer)) is det.
%
%   Cocientes son los cocientes de la fracción continua del racional
%   positivo Q: Q = A0 + 1 / (A1 + 1 / (A2 + ...)).
fraccion_continua(Q, [A|As]) :-
    must_be(rational, Q),
    A is floor(Q),
    R is Q - A,
    (   R =:= 0
    ->  As = []
    ;   Q1 is 1 rdiv R,
        fraccion_continua(Q1, As)
    ).

%!  valor_fraccion_continua(+Cocientes:list(integer), -Q:rational) is det.
%
%   Q es el racional cuya fracción continua tiene los Cocientes, que no son
%   una lista vacía.
valor_fraccion_continua([A], A) :-
    !.
valor_fraccion_continua([A|As], Q) :-
    valor_fraccion_continua(As, Q1),
    Q is A + 1 rdiv Q1.

% Ejercicio 5

%!  mejor_aproximacion(+X:number, +MaxD:integer, -Q:rational) is det.
%
%   Q es el racional con denominador entre 1 y MaxD más cercano a X; entre
%   dos igual de cercanos, el de menor denominador.
mejor_aproximacion(X, MaxD, Q) :-
    must_be(positive_integer, MaxD),
    Y is float(X),
    findall(Error-D-N,
            ( between(1, MaxD, D),
              N is round(Y * D),
              Error is abs(Y - N / D) ),
            Candidatos),
    min_member(_-D-N, Candidatos),
    Q is N rdiv D.
