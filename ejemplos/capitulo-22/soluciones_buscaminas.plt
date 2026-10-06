:- encoding(utf8).

:- begin_tests(soluciones_buscaminas).

% Ejercicio 12
test(descubrir_region, true(S == [2-1, 2-2, 3-1, 3-2])) :-
    tablero(3, 4, [1-1, 2-3], T),
    descubrir(T, 3-1, [], D),
    msort(D, S).

test(descubrir_numero, true(D == [1-2])) :-
    tablero(3, 4, [1-1, 2-3], T),
    descubrir(T, 1-2, [], D).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
% Ejercicio 13: ida y vuelta con mostrar/1.
test(desde_texto, true(S == "*211\n12*1\n0111\n")) :-
    tablero_desde_texto(["*211", "12*1", "0111"], T),
    with_output_to(string(S), mostrar(T)).

test(mismo_tablero, true(T1 == T2)) :-
    tablero(3, 4, [1-1, 2-3], T1),
    tablero_desde_texto(["*211", "12*1", "0111"], T2).

:- end_tests(soluciones_buscaminas).
