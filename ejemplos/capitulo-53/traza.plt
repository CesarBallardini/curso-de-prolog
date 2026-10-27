:- encoding(utf8).

:- begin_tests(traza).

test(estados_ii, [true(Qs == [b, o, q, q, q, p, p, p, f, f, f, f])]) :-
    cinta_vacia(C0),
    configuraciones(ii, b, C0, 12, Cs),
    findall(Q, member(conf(_, Q, _), Cs), Qs).

test(linea, [true(L == "  2  əə[0].0          o")]) :-
    cinta_vacia(C0),
    configuraciones(ii, b, C0, 2, [_, C]),
    linea(C, L).

test(detenida, [true(N == 9)]) :-
    cinta_de([schwa, a, x, b], 3, C0),
    configuraciones(biblioteca, f(fin, falta, x), C0, 10, Cs),
    length(Cs, N).

test(alias_resueltos, [true(Q == emite(b, 0))]) :-
    cinta_vacia(C0),
    configuraciones(alterna, a, C0, 1, [conf(1, Q, _)]).

test(medir_ii, [true(M == medida(116, 0, 1))]) :-
    medir(ii, b, 15, M).

test(medir_contador, [true(M == medida(362, 34, 30))]) :-
    medir(contador, inicio, 15, M).

test(tamano, [true(N == 5)]) :-
    tamano(f(a, g(b), c), N).

test(traza, [true(S == "  1  [.]              b\n  2  əə[0].0          o\n")]) :-
    with_output_to(string(S), traza(ii, b, 2)).

:- end_tests(traza).
