:- encoding(utf8).

:- begin_tests(catalogo).

test(cuatro_etiquetas, [true(Es == [mas, menos, der, izq])]) :-
    findall(E, etiqueta(E), Es).

test(inversa_involutiva) :-
    forall(etiqueta(E), ( inversa(E, F), inversa(F, E) )).

test(dieciocho_uniones, [true(N == 18)]) :-
    aggregate_all(count, union_posible(_, _), N).

test(cantidades, [true(Ns == [ele-6, horquilla-5, flecha-3, te-4])]) :-
    findall(T-N, cantidad(T, N), Ns).

test(largos) :-
    forall(union_posible(T, Ls),
           ( length(Ls, N),
             ( T == ele -> N =:= 2 ; N =:= 3 ) )).

test(flecha_de_contorno, [nondet]) :-
    union_posible(flecha, [der, mas, izq]).

test(te_con_barra_de_contorno) :-
    forall(union_posible(te, Ls), Ls = [der, izq, _]).

test(sin_repetidas) :-
    findall(T-Ls, union_posible(T, Ls), Us),
    sort(Us, Ordenadas),
    length(Us, N),
    length(Ordenadas, N).

:- end_tests(catalogo).
