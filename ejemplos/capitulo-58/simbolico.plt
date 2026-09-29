:- encoding(utf8).

:- begin_tests(simbolico).

test(recta, [true(S == [(n+1)*(n+1)])]) :-
    analizar("x := n + 1; y := x * x; escribir y", P),
    simbolizar(P, [n], Cs, S),
    Cs == [].

test(cuadrado, [true(Rs == [[n*n<0]-[0], [n*n>=0]-[n*n]])]) :-
    programa_caso(cuadrado, P, _),
    findall(Cs-S, simbolizar(P, [n], Cs, S), Rs0),
    msort(Rs0, Rs).

% Una condición entre números se decide y no queda en el camino.
test(decidida, [true(Rs == [[]-[1]])]) :-
    analizar("si 1 < 2 entonces escribir 1 sino escribir 2 fin", P),
    findall(Cs-S, simbolizar(P, [], Cs, S), Rs).

test(factorial, [true(Ss == [[1], [n], [n*(n-1)]])]) :-
    programa_caso(factorial, P, _),
    findall(S, limit(3, simbolizar(P, [n], _, S)), Ss).

test(condiciones, [true(Cs == [n>0, n-1>0, n-1-1=<0])]) :-
    programa_caso(factorial, P, _),
    findall(C, limit(3, simbolizar(P, [n], C, _)), Todas),
    last(Todas, Cs).

:- end_tests(simbolico).
