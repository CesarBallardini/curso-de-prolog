:- encoding(utf8).

:- begin_tests(soluciones_adivinar).

test(bloguearon, [true(As == [verbo("bloguear", preterito, 3, plural)])]) :-
    findall(A, adivinar("bloguearon", A), As).

test(tuitee, [true(As == [verbo("tuitear", preterito, 1, singular)])]) :-
    findall(A, adivinar("tuiteé", A), As).

test(chateamos, [true(As == [verbo("chatear", presente, 1, plural),
                             verbo("chatear", preterito, 1, plural)])]) :-
    findall(A, adivinar("chateamos", A), As).

% Sin el léxico, el cambio de la raíz no se reconoce.
test(cuentas, [true(As == [verbo("cuentar", presente, 2, singular)])]) :-
    findall(A, adivinar("cuentas", A), As).

:- end_tests(soluciones_adivinar).
