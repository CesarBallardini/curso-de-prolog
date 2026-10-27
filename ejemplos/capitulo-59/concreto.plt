:- encoding(utf8).

:- begin_tests(concreto).

test(promedio, [true(R == fin([1], [i-4, n-4, s-6]))]) :-
    programa_caso(promedio, P, _),
    correr_desde(P, [n-4], R).

test(division_por_cero, [true(R == error(division_por_cero))]) :-
    programa_caso(promedio, P, _),
    correr_desde(P, [n-0], R).

% Una variable que no está en el programa no cambia el entorno.
test(entrada_ajena, [true(R == fin([7], [x-7]))]) :-
    analizar("escribir x", P),
    correr_desde(P, [x-7, y-3], R).

test(ventana, [true(Vs == [[n-10], [n-11], [n-12]])]) :-
    findall(V, valores_muestra([n-entre(10, sup)], V), Vs).

test(tamanos, [true(Ns == [cuadrado-19, cuenta-12, diez-1, factorial-11,
                           mcd-144, promedio-13])]) :-
    findall(N-L, ( caso(N, _, _), muestra(N, Cs), length(Cs, L) ), Ns0),
    msort(Ns0, Ns).

test(factorial, [true(Fs == [1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880,
                             3628800])]) :-
    muestra(factorial, Cs),
    findall(F, member(corrida(_, fin([F], _)), Cs), Fs).

test(correr_caso, [true(R == fin([1], [i-4, n-4, s-6]))]) :-
    correr_caso(promedio, [n-4], R).

test(correr_caso_error, [true(R == error(division_por_cero))]) :-
    correr_caso(promedio, [n-0], R).

test(correr_caso_inexistente, [fail]) :-
    correr_caso(inexistente, [], _).

:- end_tests(concreto).
