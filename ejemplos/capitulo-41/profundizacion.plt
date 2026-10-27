:- encoding(utf8).

:- begin_tests(profundizacion).

% Con límite 5 hay dos planes: el de cuatro acciones y uno de cinco.
test(con_limite, [true(Ls == [4, 5])]) :-
    findall(L, ( con_limite(jarras(4, 3, 2), 5, P), length(P, L) ), Ls0),
    msort(Ls0, Ls).

test(limite_corto, [fail]) :-
    con_limite(jarras(4, 3, 2), 3, _).

test(iterativo, [true(P == [llenar(2), pasar(2, 1), llenar(2),
                            pasar(2, 1)])]) :-
    once(iterativo(jarras(4, 3, 2), P)).

% Los planes salen de menor a mayor longitud.
test(orden, [true(Ls == [4, 5, 6, 6, 6, 6])]) :-
    findall(L, ( limit(6, iterativo(jarras(4, 3, 2), P)), length(P, L) ),
            Ls).

test(mas_corto, [true(L == 6)]) :-
    once(iterativo(jarras(7, 2, 1), P)),
    length(P, L).

% Sin solución, la profundización iterativa no termina.
test(sin_solucion, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(iterativo(jarras(4, 2, 1), _), 1000000, R).

:- end_tests(profundizacion).
