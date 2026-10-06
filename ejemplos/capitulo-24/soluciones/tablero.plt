:- encoding(utf8).

:- begin_tests(tablero).

test(valor, true(V == 2)) :-
    tablero(3, 4, [1-1, 2-3], T),
    valor(T, 2-2, V).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
test(mostrar, true(S == "*211\n12*1\n0111\n")) :-
    tablero(3, 4, [1-1, 2-3], T),
    with_output_to(string(S), mostrar(T)).

:- end_tests(tablero).
