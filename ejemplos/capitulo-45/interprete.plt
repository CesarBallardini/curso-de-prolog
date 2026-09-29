:- encoding(utf8).

:- begin_tests(interprete).

test(asignacion, [true(S == [42])]) :-
    ejecutar("x := 6; y := x * 7; escribir y", S).

test(ejemplos, [true(Rs == [cuenta-[3, 2, 1], factorial-[120], mcd-[12],
                            suma-[500500]])]) :-
    findall(N-S, ( programa_ejemplo(N, P), interpretar(P, S) ), Rs0),
    msort(Rs0, Rs).

test(inicial_cero, [true(S == [0, 1])]) :-
    ejecutar("escribir z; z := z + 1; escribir z", S).

test(division_entera, [true(S == [3, -3])]) :-
    ejecutar("escribir 7 / 2; escribir (0 - 7) / 2", S).

test(division_por_cero, [error(evaluation_error(zero_divisor))]) :-
    ejecutar("x := 1 / 0", _).

test(si_sino, [true(S == [2, 1])]) :-
    ejecutar("x := 5; si x > 3 entonces escribir 2 sino escribir 1 fin;
              si x < 3 entonces escribir 2 sino escribir 1 fin", S).

test(mientras_no_entra, [true(S == [])]) :-
    ejecutar("mientras x > 0 hacer escribir x fin", S).

test(vacio, [true(S == [])]) :-
    interpretar([], S).

test(no_es_mini, [fail]) :-
    ejecutar("x = 1", _).

test(variables, [true(Vs == [a, b])]) :-
    programa_ejemplo(mcd, P),
    variables(P, Vs).

test(entorno_inicial, [true(E == [f-0, n-0])]) :-
    programa_ejemplo(factorial, P),
    entorno_inicial(P, E).

test(actualizar, [true(E == [a-1, b-7, c-3])]) :-
    actualizar(b, 7, [a-1, b-2, c-3], E).

test(contrarias) :-
    forall(contraria(Op, No),
           forall(member(X-Y, [1-2, 2-2, 3-2]),
                  (   comparar(Op, X, Y)
                  ->  \+ comparar(No, X, Y)
                  ;   comparar(No, X, Y)
                  ))).

:- end_tests(interprete).
