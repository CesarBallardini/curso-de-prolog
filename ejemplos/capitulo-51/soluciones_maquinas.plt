:- encoding(utf8).

:- begin_tests(soluciones_maquinas).

% iguales acepta exactamente las palabras con tantas a como b.
test(ej10_iguales) :-
    forall(( between(0, 8, L),
             length(W, L),
             maplist([S]>>member(S, [a, b]), W) ),
           (   once(acepta_pila(iguales, W))
           ->  cuenta(a, W, N), cuenta(b, W, N)
           ;   cuenta(a, W, Na), cuenta(b, W, Nb), Na =\= Nb
           )).

test(ej11_palindromos) :-
    forall(( between(0, 6, L),
             length(W, L),
             maplist([S]>>member(S, [a, b]), W) ),
           (   turing(palindromo_mt, W, 1000, acepta(_))
           ->  reverse(W, W)
           ;   \+ reverse(W, W)
           )).

test(ej11_pasos, [true(Ns == [1, 3, 6, 15, 45])]) :-
    findall(N,
            ( member(L, [0, 1, 2, 4, 8]),
              length(W, L),
              maplist(=(a), W),
              pasos(palindromo_mt, W, N) ),
            Ns).

% cuenta(S, W, N): S aparece N veces en W.
cuenta(S, W, N) :-
    aggregate_all(count, member(S, W), N).

:- end_tests(soluciones_maquinas).
