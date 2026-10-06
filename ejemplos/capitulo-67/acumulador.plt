:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(acumulador).

test(ejemplos_reverse, [true(P-N == 9-5)]) :-
    ejemplos_reverse(Pos, Negs),
    length(Pos, P),
    length(Negs, N).

test(parte_propia, [true]) :-
    parte_propia(b, f(a, g(b))).

test(parte_propia_mismo, [fail]) :-
    parte_propia(f(a), f(a)).

% Compara con ==: una variable no es parte de un término que no la tiene.
test(parte_propia_no_unifica, [fail]) :-
    parte_propia(_, f(a, b)).

test(parte_propia_lista, [true]) :-
    parte_propia(T, [_|T]).

test(bien_fundada_desciende, [true]) :-
    bien_fundada(reverse([X|Xs], _, _), reverse(Xs, [X], _)).

test(bien_fundada_no_desciende, [fail]) :-
    bien_fundada(reverse(_, _, [A|B]), reverse([A], B, [A|B])).

test(bien_fundada_otro_predicado, [true]) :-
    bien_fundada(p(X), q([X])).

test(rlgg_bien_fundada, [true(Rs == [])]) :-
    ejemplos_reverse(Pos, _),
    sort(Pos, M),
    rlgg_bien_fundada(reverse([1, 2], [], [2, 1]), reverse([a], [], [a]), M,
                      (H :- B)),
    include(no_desciende(H), B, Rs).

no_desciende(H, L) :-
    \+ bien_fundada(H, L).

test(aprender_reverse_rlgg,
     [true(H =@= [(reverse(_, _, [A|B]) :- [reverse([A], B, [A|B])])])]) :-
    aprender_reverse(rlgg, H).

test(aprender_reverse_bien_fundada,
     [true(H =@= [(reverse([A|B], C, [D|E]) :- [reverse(B, [A|C], [D|E])]),
                  (reverse([], [F|G], [F|G]) :- [])])]) :-
    aprender_reverse(rlgg_bien_fundada, H).

test(cobertura_cuenta, [true(N == 39)]) :-
    ejemplos_reverse(Pos, Negs),
    sort(Pos, M),
    cobertura(rlgg_bien_fundada, Pos, Negs, M, _, N).

test(cobertura_vacia, [true(H-N == []-0)]) :-
    cobertura(rlgg, [], [], [], H, N).

test(invertir, all(R == [[4, 3, 2, 1]])) :-
    aprender_reverse(rlgg_bien_fundada, H),
    invertir(H, [1, 2, 3, 4], R).

% La segunda cláusula exige un acumulador no vacío: la lista vacía no se
% invierte.
test(invertir_vacia, [fail]) :-
    aprender_reverse(rlgg_bien_fundada, H),
    invertir(H, [], _).

test(cubre_en, [true]) :-
    acumulador:cubre_en((p(X) :- [q(X)]), [q(a)], p(a)).

:- end_tests(acumulador).
