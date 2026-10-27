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

test(caso_cuadrado, all(Cs-S == [[n*n<0]-[0], [n*n>=0]-[n*n]])) :-
    simbolizar_caso(cuadrado, Cs, S).

test(caso_inexistente, [fail]) :-
    simbolizar_caso(inexistente, _, _).

test(negar, [true(NoC == rel(>=, id(x), num(1)))]) :-
    negar(rel(<, id(x), num(1)), NoC).

% Con una incógnita, la condición queda en el camino.
test(suponer_incognita, [true(S == s([x-n], [n<1]))]) :-
    suponer(rel(<, id(x), num(1)), s([x-n], []), S).

% Con números, la condición se decide: se cumple o falla.
test(suponer_cierta, [true(S == s([x-0], []))]) :-
    suponer(rel(<, id(x), num(1)), s([x-0], []), S).

test(suponer_falsa, [fail]) :-
    suponer(rel(>, id(x), num(1)), s([x-0], []), _).

test(sentencia_escribir, [true(Sal-S == [n+1]-s([x-n], []))]) :-
    phrase(sim_sentencia(escribir(bin(+, id(x), num(1))), s([x-n], []), S),
           Sal).

test(sentencia_si, all(Sal-Cs == [[1]-[n>0], [2]-[n=<0]])) :-
    phrase(sim_sentencia(si(rel(>, id(x), num(0)), [escribir(num(1))],
                            [escribir(num(2))]),
                         s([x-n], []), s(_, Cs)),
           Sal).

:- end_tests(simbolico).
