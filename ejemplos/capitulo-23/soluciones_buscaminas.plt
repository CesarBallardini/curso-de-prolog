:- encoding(utf8).

:- begin_tests(soluciones_buscaminas).

% Ejercicio 12
test(probabilidades, true(P == [1-1-1, 3-3-1, 3-4-0, 4-3-0, 4-4-0.5])) :-
    probabilidades(["#100", "1211", "01##", "01##"], P).

test(probabilidades_inconsistente, [fail]) :-
    probabilidades(["##1#", "1211", "0000"], _).

% Ejercicio 13
test(consistente) :-
    consistente(["#100", "1211", "01##", "01##"]).

test(inconsistente, [fail]) :-
    consistente(["##1#", "1211", "0000"]).

:- end_tests(soluciones_buscaminas).
