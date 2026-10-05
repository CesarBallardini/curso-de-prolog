:- encoding(utf8).

:- begin_tests(articulo).

test(analiza, all(SN-N == [sn(a, [old], book, sg)-sg])) :-
    phrase(sn_ingenuo(SN, N), ["an", "old", "book"]).

test(analiza_a, fail) :-
    phrase(sn_ingenuo(_, _), ["a", "apple"]).

test(no_genera, error(instantiation_error)) :-
    phrase(sn_ingenuo(sn(a, [], apple, sg), sg), _).

test(genera_corregido, all(Ps == [["an", "apple"]])) :-
    phrase(sn_en(sn(a, [], apple, sg), sg), Ps).

% La palabra siguiente se examina y vuelve a la entrada.
test(articulo_an, all(A-N-Resto == [sin-pl-["an", "apple"],
                                    a-sg-["apple"]])) :-
    phrase(articulo_ingenuo(A, N), ["an", "apple"], Resto).

test(articulo_a_mal, all(A == [sin])) :-
    phrase(articulo_ingenuo(A, _), ["a", "apple"], _).

:- end_tests(articulo).
