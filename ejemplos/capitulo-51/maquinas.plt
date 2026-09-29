:- encoding(utf8).

:- begin_tests(maquinas).

test(parentesis, [nondet]) :-
    acepta_pila(parentesis, ['(', '(', ')', ')', '(', ')']).

test(parentesis_mal, [fail]) :-
    acepta_pila(parentesis, ['(', ')', ')']).

test(parentesis_4, [true(Ws == [['(', '(', ')', ')'], ['(', ')', '(', ')']])]) :-
    findall(W, ( length(W, 4), acepta_pila(parentesis, W) ), Ws).

test(palindromo, [nondet]) :-
    acepta_pila(palindromo, [a, b, b, a]).

test(no_palindromo, [fail]) :-
    acepta_pila(palindromo, [a, b, a, b]).

test(palindromos_4, [true(Ws == [[a, a, a, a], [a, b, b, a], [b, a, a, b],
                                 [b, b, b, b]])]) :-
    findall(W, ( length(W, 4), acepta_pila(palindromo, W) ), Ws).

test(abc, [true(R == acepta([x, x, y, y, z, z]))]) :-
    turing(abc, [a, a, b, b, c, c], 1000, R).

test(abc_rechaza, [true(R == rechaza([x, x, y, z, c]))]) :-
    turing(abc, [a, a, b, c, c], 1000, R).

test(abc_vacia, [true(R == acepta([]))]) :-
    turing(abc, [], 10, R).

test(limite, [true(R = limite(_, _))]) :-
    turing(abc, [a, a, a, b, b, b, c, c, c], 5, R).

% Acepta exactamente las palabras a^n b^n c^n de longitud hasta 6.
test(abc_todas) :-
    forall(( between(0, 6, L),
             length(W, L),
             maplist([S]>>member(S, [a, b, c]), W) ),
           (   turing(abc, W, 1000, acepta(_))
           ->  abc(W)
           ;   \+ abc(W)
           )).

% abc(W): W es a^n b^n c^n.
abc(W) :-
    length(W, L),
    N is L // 3,
    L =:= 3 * N,
    length(As, N), maplist(=(a), As),
    length(Bs, N), maplist(=(b), Bs),
    length(Cs, N), maplist(=(c), Cs),
    append([As, Bs, Cs], W).

:- end_tests(maquinas).
