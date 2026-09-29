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

:- end_tests(familia).
