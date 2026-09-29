:- encoding(utf8).

% Capítulo 58 - Versión 5: intervalos, con ensanchamiento.
%
% El dominio de los intervalos da a cada variable un valor i(Min, Max):
% todos los enteros entre Min y Max, con Min un entero o inf, y Max un
% entero o sup. Es más preciso que el de signos, pero tiene cadenas
% crecientes infinitas: i(0, 0), i(0, 1), i(0, 2)... Unir en la cabeza de un
% bucle no alcanza para terminar, y dom_ensanchar/4 lleva al infinito la
% cota que crece; antes de eso prueba con 0, el único umbral.
%
% solo-local: carga reticulado.pl con ensure_loaded/1.
%
%?- dom_operar(intervalos, /, i(1, 10), i(-2, 3), V).
%?- programa_caso(cuenta, P, Es), analisis(intervalos, P, Es, F, Os).
%?- programa_caso(diez, P, Es), analisis(intervalos, P, Es, F, Os).

:- ensure_loaded(reticulado).

% Las operaciones dom_*/N del dominio intervalos; reticulado.pl documenta
% lo que calcula cada una.

dom_constante(intervalos, N, i(N, N)).

dom_rango(intervalos, entre(Min, Max), i(Min, Max)).

dom_operar(intervalos, Op, X, Y, V) :-
    operar_intervalos(Op, X, Y, V).

%!  operar_intervalos(+Op, +X, +Y, -V) is det.
%
%   V es el menor intervalo que contiene los resultados de la operación Op
%   de Mini entre valores de X y de Y. Un producto o un cociente toma los
%   extremos de las operaciones entre las cotas; el cociente, por separado
%   en la parte negativa y en la positiva del divisor, sin el cero.
operar_intervalos(+, i(A, B), i(C, D), i(E, F)) :-
    suma_cota(A, C, E),
    suma_cota(B, D, F).
operar_intervalos(-, i(A, B), i(C, D), i(E, F)) :-
    opuesta(D, D1),
    opuesta(C, C1),
    suma_cota(A, D1, E),
    suma_cota(B, C1, F).
operar_intervalos(*, i(A, B), i(C, D), V) :-
    findall(P, ( member(X, [A, B]),
                 member(Y, [C, D]),
                 producto_cota(X, Y, P) ),
            Ps),
    extremos(Ps, V).
operar_intervalos(/, i(A, B), Divisor, V) :-
    findall(Q, ( sin_cero(Divisor, i(C, D)),
                 member(X, [A, B]),
                 member(Y, [C, D]),
                 cociente_cota(X, Y, Q) ),
            Qs),
    extremos(Qs, V).

dom_cero(intervalos, V) :-
    dom_contiene(intervalos, V, 0).

dom_refinar(intervalos, Op, i(A, B), i(C, D), V) :-
    restringido(Op, i(A, B), i(C, D), V),
    no_vacio(V).

dom_unir(intervalos, i(A, B), i(C, D), i(E, F)) :-
    minima(A, C, E),
    maxima(B, D, F).

dom_ensanchar(intervalos, Viejo, Nuevo, i(E, F)) :-
    Viejo = i(A, B),
    dom_unir(intervalos, Viejo, Nuevo, i(C, D)),
    (   C == A
    ->  E = A
    ;   bajar(C, E)
    ),
    (   D == B
    ->  F = B
    ;   subir(D, F)
    ).

dom_contiene(intervalos, i(A, B), N) :-
    cota_menor(A, N),
    cota_menor(N, B).

%!  bajar(+C, -E) is det.
%
%   E es la cota inferior ensanchada desde C: 0 si C no es negativa, y si
%   no, inf.
bajar(C, E) :-
    (   cota_menor(0, C)
    ->  E = 0
    ;   E = inf
    ).

%!  subir(+D, -F) is det.
%
%   F es la cota superior ensanchada desde D: 0 si D no es positiva, y si
%   no, sup.
subir(D, F) :-
    (   cota_menor(D, 0)
    ->  F = 0
    ;   F = sup
    ).

%!  restringido(+Op, +X, +Y, -V) is det.
%
%   V es el intervalo X restringido a los valores que cumplen la
%   comparación Op con algún valor del intervalo Y; puede quedar vacío,
%   con la cota inferior mayor que la superior.
restringido(<, i(A, B), i(_, D), i(A, F)) :-
    suma_cota(D, -1, D1),
    minima(B, D1, F).
restringido(<=, i(A, B), i(_, D), i(A, F)) :-
    minima(B, D, F).
restringido(>, i(A, B), i(C, _), i(E, B)) :-
    suma_cota(C, 1, C1),
    maxima(A, C1, E).
restringido(>=, i(A, B), i(C, _), i(E, B)) :-
    maxima(A, C, E).
restringido(=, i(A, B), i(C, D), i(E, F)) :-
    maxima(A, C, E),
    minima(B, D, F).
restringido(<>, X, Y, V) :-
    distinto(X, Y, V).

%!  distinto(+X, +Y, -V) is det.
%
%   V es el intervalo X sin el único valor de Y, si Y tiene uno solo y es
%   un extremo de X; si no, X.
distinto(i(A, B), i(C, D), V) :-
    (   C == D,
        A == C
    ->  suma_cota(A, 1, A1),
        V = i(A1, B)
    ;   C == D,
        B == C
    ->  suma_cota(B, -1, B1),
        V = i(A, B1)
    ;   V = i(A, B)
    ).

%!  no_vacio(+V) is semidet.
%
%   El intervalo V tiene algún entero.
no_vacio(i(A, B)) :-
    cota_menor(A, B).

%!  sin_cero(+V, -P) is nondet.
%
%   P es la parte negativa o la parte positiva del intervalo V, si no está
%   vacía: los divisores posibles.
sin_cero(i(A, B), i(A, F)) :-
    minima(B, -1, F),
    no_vacio(i(A, F)).
sin_cero(i(A, B), i(E, B)) :-
    maxima(A, 1, E),
    no_vacio(i(E, B)).

%!  extremos(+Cs:list, -V) is det.
%
%   V es el menor intervalo que contiene las cotas de Cs; sin ninguna, el
%   de todos los enteros.
extremos([], i(inf, sup)).
extremos([C|Cs], i(A, B)) :-
    foldl(minima, Cs, C, A0),
    foldl(maxima, Cs, C, B0),
    finita_abajo(A0, A),
    finita_arriba(B0, B).

% finita_abajo(C, A): una cota inferior no es sup.
finita_abajo(C, A) :-
    (   C == sup
    ->  A = inf
    ;   A = C
    ).

% finita_arriba(C, B): una cota superior no es inf.
finita_arriba(C, B) :-
    (   C == inf
    ->  B = sup
    ;   B = C
    ).

%!  minima(+A, +B, -M) is det.
%
%   M es la menor de las cotas A y B.
minima(A, B, M) :-
    (   cota_menor(A, B)
    ->  M = A
    ;   M = B
    ).

%!  maxima(+A, +B, -M) is det.
%
%   M es la mayor de las cotas A y B.
maxima(A, B, M) :-
    (   cota_menor(A, B)
    ->  M = B
    ;   M = A
    ).

%!  opuesta(+C, -D) is det.
%
%   D es la cota -C.
opuesta(C, D) :-
    (   integer(C)
    ->  D is -C
    ;   infinito(S, C),
        opuesto(S, T),
        infinito(T, D)
    ).

%!  suma_cota(+A, +B, -S) is det.
%
%   S es la suma de las cotas A y B; un infinito absorbe al entero. No se
%   suman inf y sup: una cota inferior no es sup, ni una superior inf.
suma_cota(A, B, S) :-
    (   integer(A),
        integer(B)
    ->  S is A + B
    ;   infinita(A)
    ->  S = A
    ;   S = B
    ).

% infinita(C): la cota C es inf o sup.
infinita(inf).
infinita(sup).

%!  producto_cota(+A, +B, -P) is det.
%
%   P es el producto de las cotas A y B: 0 si una es 0, y un infinito con
%   el signo del producto si una es infinita.
producto_cota(A, B, P) :-
    (   integer(A),
        integer(B)
    ->  P is A * B
    ;   ( A == 0 ; B == 0 )
    ->  P = 0
    ;   signo_cota(A, SA),
        signo_cota(B, SB),
        por(SA, SB, S),
        infinito(S, P)
    ).

%!  cociente_cota(+A, +B, -Q) is nondet.
%
%   Q es una cota del cociente entero A / B, con B distinto de cero. Un
%   entero dividido por un infinito da 0; dos infinitos dan 0 y un
%   infinito, porque el cociente de dos valores grandes puede ser
%   cualquiera entre ellos.
cociente_cota(A, B, Q) :-
    (   integer(A),
        integer(B)
    ->  Q is A // B
    ;   integer(A)
    ->  Q = 0
    ;   signo_cota(A, SA),
        signo_cota(B, SB),
        por(SA, SB, S),
        infinito(S, I),
        (   integer(B)
        ->  Q = I
        ;   member(Q, [0, I])
        )
    ).

%!  signo_cota(+C, -S) is det.
%
%   S es el signo de la cota C.
signo_cota(C, S) :-
    (   integer(C)
    ->  signo_de(C, S)
    ;   infinito(S, C)
    ).

% infinito(S, C): C es el infinito de signo S.
infinito(neg, inf).
infinito(pos, sup).
