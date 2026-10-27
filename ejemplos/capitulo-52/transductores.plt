:- encoding(utf8).

:- begin_tests(transductores).

test(gray, [true(Gs == [[1, 1, 1, 0]])]) :-
    findall(G, transducir(gray, [1, 0, 1, 1], G), Gs).

test(gray_inversa, [true(Bs == [[1, 0, 1, 1]])]) :-
    findall(B, transducir(gray, B, [1, 1, 1, 0]), Bs).

% Los códigos de dos números consecutivos difieren en un bit.
test(gray_consecutivos) :-
    forall(between(0, 14, N),
           ( bits(N, B1),
             N1 is N + 1,
             bits(N1, B2),
             transducir(gray, B1, G1),
             transducir(gray, B2, G2),
             diferencias(G1, G2, 1) )).

test(plural, [forall(plural(S, P)), true(Ps == [P])]) :-
    findall(X, transducir(plural, S, X), Ps).

plural([c, a, s, a], [c, a, s, a, s]).
plural([l, e, y], [l, e, y, e, s]).
plural([l, u, z], [l, u, c, e, s]).
plural([z, a, p, a, t, o], [z, a, p, a, t, o, s]).

test(plural_analisis, [true(Ws == [[l, u, c], [l, u, c, e], [l, u, z]])]) :-
    findall(W, transducir(plural, W, [l, u, c, e, s]), Ws0),
    sort(Ws0, Ws).

test(no_plural, [fail]) :-
    transducir(plural, _, [c, a, s, a]).

test(inversa, [true(Ws == [[c, a, s, a]])]) :-
    findall(W, transducir(inversa(plural), [c, a, s, a, s], W), Ws).

test(compuesta, [true(Ws == [[1, 0, 1, 1]])]) :-
    findall(W, transducir(compuesta(gray, inversa(gray)), [1, 0, 1, 1], W),
            Ws).

test(identidad, [true(Ws == [[a, b, a, s]])]) :-
    findall(W, transducir(compuesta(identidad([a, b]), plural), [a, b, a], W),
            Ws).

% Un transductor es un autómata sobre pares.
test(pares) :-
    acepta(gray, [[1]:[1], [0]:[1]]).

test(min_gray, [true(N == 3)]) :-
    numero_estados(min(gray), N).

% bits(N, Bs): Bs son los cuatro bits de N, el más significativo primero.
bits(N, Bs) :-
    format(atom(A), '~|~`0t~2r~4+', [N]),
    atom_chars(A, Cs),
    maplist([C, B]>>atom_number(C, B), Cs, Bs).

% diferencias(Xs, Ys, D): Xs e Ys difieren en D posiciones.
diferencias(Xs, Ys, D) :-
    foldl([X, Y, D0, D1]>>(X == Y -> D1 = D0 ; D1 is D0 + 1), Xs, Ys, 0, D).

test(traducir_letra, set(S-Q == [[e]-vocal, [e, s]-fin])) :-
    transductores:traducir(plural, inicio, [e], S, Q).

test(letras, [true(N == 26)]) :-
    aggregate_all(count, letra(_), N).

test(letra_con_tilde, [fail]) :-
    atom_codes(L, [241]),
    letra(L).

:- end_tests(transductores).
