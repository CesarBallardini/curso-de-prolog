:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(ascendente).

test(enlazados, [true(B =@= [q(X, Y), r(Y)])]) :-
    enlazados(p(X), [q(X, Y), s(_), r(Y)], B).

test(cubre, [true]) :-
    cubre((abuelo(A, N) :- [padre(A, P), progenitor(P, N)]),
          abuelo(juan, luis),
          [padre(juan, pedro), progenitor(pedro, luis)]).

test(no_cubre, [fail]) :-
    cubre((abuelo(A, N) :- [padre(A, P), progenitor(P, N)]),
          abuelo(juan, pedro),
          [padre(juan, pedro), progenitor(pedro, luis)]).

test(rlgg_tamano, [true(L0-L == 99-18)]) :-
    ejemplos(abuelo, [E1, _, E2], _),
    modelo_fondo(M),
    lgg_clausula((E1 :- M), (E2 :- M), (_ :- B0)),
    length(B0, L0),
    rlgg(E1, E2, M, (_ :- B)),
    length(B, L).

% La rlgg cubre los dos ejemplos de los que sale.
test(rlgg_cubre, [true]) :-
    ejemplos(abuelo, [E1, _, E2], _),
    modelo_fondo(M),
    rlgg(E1, E2, M, C),
    cubre(C, E1, M),
    cubre(C, E2, M).

test(reducir_orden_inverso,
     [true(C =@= (abuelo(A, B) :- [progenitor(P, B), padre(A, P)]))]) :-
    ejemplos(abuelo, [E1, _, E2], Negs),
    modelo_fondo(M),
    rlgg(E1, E2, M, (H :- B0)),
    reverse(B0, B1),
    reducir((H :- B1), Negs, M, C).

test(reducir_inconsistente, [fail]) :-
    reducir((p(X) :- [q(X)]), [p(a)], [q(a)], _).

test(abuelo, [true(H-N =@= [(abuelo(A, B) :- [padre(A, C), progenitor(D, E),
                                             progenitor(D, C),
                                             progenitor(E, B)])]-3)]) :-
    aprender_asc(abuelo, H, N).

test(abuela_constante, [true(H =@= [(abuela(marta, A) :- [progenitor(pedro, A)])])]) :-
    aprender_asc(abuela, H, _).

test(hermano, [true(H =@= [(hermano(A, B) :- [mujer(B), varon(A),
                                             progenitor(C, B),
                                             progenitor(C, A)])])]) :-
    aprender_asc(hermano, H, _).

test(evaluar_abuelo, [true(R == 3-0-0)]) :-
    aprender_asc(abuelo, H, _),
    evaluar(abuelo, H, A, FP, FN),
    R = A-FP-FN.

% Sin cláusula consistente, los positivos quedan como hechos.
test(hechos, [true(H == [(p(a) :- []), (p(b) :- [])])]) :-
    ascendente([p(a), p(b)], [p(c)], [q(a), q(b), q(c)], H, 1).

test(extension_hecho, [true(A == [abuelo(juan, luis)])]) :-
    extension(abuelo, [(abuelo(juan, luis) :- [])], A).

:- end_tests(ascendente).
