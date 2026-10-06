:- encoding(utf8).

:- begin_tests(soluciones_vectores).

% El acarreo necesita sus tres implicantes primos.
test(acarreo, [true(Cs == Ps)]) :-
    unos(sumador, co, Us),
    implicantes_primos(Us, Ps),
    cobertura(Us, Ps, Cs).

% a·¬b, a·c y b·c: a·c sobra, porque sus dos filas ya están cubiertas.
test(sobra_uno, [true(Cs == [[0, +, +], [+, -, 0]])]) :-
    Us = [[+, -, -], [+, -, +], [+, +, +], [-, +, +]],
    implicantes_primos(Us, Ps),
    cobertura(Us, Ps, Cs).

test(sin_unos, [true(Cs == [])]) :-
    cobertura([], [[+, 0]], Cs).

test(no_cubre, [fail]) :-
    cobertura([[+, +], [-, -]], [[+, 0]], _).

test(subconjunto, all(S == [[a, b], [a], [b], []])) :-
    subconjunto([a, b], S).

:- end_tests(soluciones_vectores).
