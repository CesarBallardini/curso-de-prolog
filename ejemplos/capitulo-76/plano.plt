:- encoding(utf8).

:- begin_tests(plano).

test(medidas, [true(A-H == 20-10)]) :-
    medidas(taller, A, H).

test(medidas_bloques, [true(A-H == 60-40)]) :-
    medidas(patio, A, H).

test(libres, [true(N == 318)]) :-
    aggregate_all(count, libre(galpon, _, _), N).

test(libre_ocupada, [fail]) :-
    libre(taller, 3, 2).

test(libre_bloque, [fail]) :-
    libre(patio, 30, 20).

test(vecinas, [true(Vs == [sur-(1-2), este-(2-1)])]) :-
    findall(D-C, vecina(taller, 1-1, D, C), Vs).

test(vecina_pared, [true(Vs == [norte-(10-3), sur-(10-5), oeste-(9-4)])]) :-
    findall(D-C, vecina(taller, 10-4, D, C), Vs).

test(lineas, [true(L == '.**.......#.........')]) :-
    lineas(taller, [2-4, 3-4], Ls),
    nth1(4, Ls, L).

test(plano, [true(N == 10)]) :-
    plano(taller, Filas),
    length(Filas, N).

test(mostrar, [true(Ls == 11)]) :-
    with_output_to(string(S), mostrar(taller, [1-1])),
    split_string(S, "
", "", Ls0),
    length(Ls0, Ls),
    sub_string(S, 0, 2, _, "*.").

:- end_tests(plano).
