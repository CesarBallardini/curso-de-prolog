:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(familia).

test(fondo, [true(K == 16)]) :-
    clausulas_fondo(Cs),
    length(Cs, K).

test(modelo, [true(K == 21)]) :-
    modelo_fondo(M),
    length(M, K).

test(progenitor_deducido, [true]) :-
    modelo_fondo(M),
    memberchk(progenitor(eva, sofia), M).

test(personas, [true(Ps == [ana, eva, juan, luis, marta, pedro, sofia])]) :-
    setof(P, persona(P), Ps).

test(abuelo, [true(Pos-K == [abuelo(juan, eva), abuelo(juan, luis),
                             abuelo(pedro, sofia)]-46)]) :-
    ejemplos(abuelo, Pos, Negs),
    length(Negs, K).

test(hermano, [true(Pos == [hermano(luis, eva), hermano(pedro, ana)])]) :-
    ejemplos(hermano, Pos, _).

test(antepasado, [true(P-N == 14-35)]) :-
    ejemplos(antepasado, Pos, Negs),
    length(Pos, P),
    length(Negs, N).

% Los negativos son todos los pares que faltan: 49 en total.
test(mundo_cerrado, [true]) :-
    forall(member(R, [abuelo, abuela, hermano, antepasado]),
           ( ejemplos(R, Pos, Negs),
             length(Pos, P),
             length(Negs, N),
             P + N =:= 49 )).

test(de_fondo, all(P == [varon/1, mujer/1, padre/2, madre/2,
                         progenitor/2])) :-
    de_fondo(P).

test(esperado_abuela, all(A == [abuela(marta, luis), abuela(marta, eva)])) :-
    esperado(abuela, A).

% hermano/2 exige un varón y dos personas distintas.
test(esperado_hermano_distintos, [fail]) :-
    esperado(hermano, hermano(X, X)).

test(esperado_antepasado, [nondet]) :-
    esperado(antepasado, antepasado(juan, sofia)).

test(esperado_relacion_desconocida, [fail]) :-
    esperado(tio, _).

test(modelo_minimo_de,
     [true(M == [p(a), p(b), q(a)])]) :-
    modelo_minimo_de([(q(a) :- true), (p(a) :- true), (p(b) :- true)], M).

test(modelo_minimo_de_regla,
     [true(M == [p(a), q(a), r(a)])]) :-
    modelo_minimo_de([(q(a) :- true), (p(X) :- q(X)), (r(X) :- p(X))], M).

test(modelo_minimo_de_vacio, [true(M == [])]) :-
    modelo_minimo_de([], M).

:- end_tests(familia).
