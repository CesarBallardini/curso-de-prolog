:- encoding(utf8).

:- begin_tests(cintas).

test(anbn, [nondet]) :-
    acepta_vacia(anbn, [a, a, b, b]).

test(anbn_vacia, [nondet]) :-
    acepta_vacia(anbn, []).

test(anbn_mal, [fail]) :-
    acepta_vacia(anbn, [a, b, b]).

test(anbn_todas, [true(Ws == [[], [a, b], [a, a, b, b]])]) :-
    findall(W, ( between(0, 4, L), length(W, L), acepta_vacia(anbn, W) ),
            Ws).

% vacia(M) acepta por pila vacía lo que M acepta por estado final.
test(vacia_igual, [forall(member(M, [parentesis, palindromo])),
                   true(Ws == Vs)]) :-
    findall(W, ( length(W, 4), acepta_pila(M, W) ), Ws0),
    sort(Ws0, Ws),
    findall(W, ( length(W, 4), acepta_vacia(vacia(M), W) ), Vs0),
    sort(Vs0, Vs).

% parentesis nunca desapila el fondo: por pila vacía no acepta nada.
test(sin_vaciar, [fail]) :-
    acepta_vacia(parentesis, ['(', ')']).

test(vaciar, [nondet]) :-
    vaciar(anbn, q1, [b], [a, z]).

test(vaciar_vacia, [nondet]) :-
    vaciar(anbn, q0, [], []).

test(palindromo_par, [true(R == acepta([[a, b, b, a], [a, b, b, a]]))]) :-
    turing_cintas(palindromo_2c, [a, b, b, a], 100, R).

test(palindromo_impar, [true(R == acepta([[a, b, a], [a, b, a]]))]) :-
    turing_cintas(palindromo_2c, [a, b, a], 100, R).

test(no_palindromo, [true(R == rechaza([[a, b], [a, b]]))]) :-
    turing_cintas(palindromo_2c, [a, b], 100, R).

test(vacia, [true(R == acepta([[], []]))]) :-
    turing_cintas(palindromo_2c, [], 100, R).

test(limite, [true(R == limite(copiar, [[a, b, b, a], [a, b, b]]))]) :-
    turing_cintas(palindromo_2c, [a, b, b, a], 3, R).

% Coincide con la máquina de una cinta en todas las palabras cortas.
test(como_una_cinta, [forall(( between(0, 5, N), length(W, N),
                               maplist([S]>>member(S, [a, b]), W) )),
                      true(A == B)]) :-
    turing_cintas(palindromo_2c, W, 1000, R),
    (   R = acepta(_)
    ->  A = si
    ;   A = no
    ),
    (   reverse(W, W)
    ->  B = si
    ;   B = no
    ).

% Tres pasos por símbolo, más tres.
test(pasos, [forall(member(N, [2, 4, 8, 16])), true(P =:= 3 * N + 3)]) :-
    length(W, N),
    maplist(=(a), W),
    pasos_cintas(palindromo_2c, W, P).

test(ejecutar_final, [true(R == acepta([[], []]))]) :-
    ejecutar_cintas(palindromo_2c, acepta,
                    [c([], blanco, []), c([], blanco, [])], 5, R).

test(bajo_cabezal, [true(S == b)]) :-
    bajo_cabezal(c([a], b, [c]), S).

test(mover_quieto, [true(C == c([a], x, [c]))]) :-
    mover_cinta(quieto, x, c([a], b, [c]), C).

test(mover_der, [true(C == c([x, a], c, []))]) :-
    mover_cinta(der, x, c([a], b, [c]), C).

:- end_tests(cintas).
