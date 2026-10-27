:- encoding(utf8).

:- begin_tests(estilo).

test(maximo_libre, all(M == [3])) :-
    maximo(3, 1, M).

test(maximo_ligado_correcto) :-
    maximo(3, 1, 3).

% La prueba que distingue las dos versiones: con la salida ligada a un valor
% falso, maximo/3 falla y mal_maximo/3 se cumple.
test(maximo_ligado_falso, [fail]) :-
    maximo(3, 1, 1).

test(mal_maximo_ligado_falso_se_cumple) :-
    mal_maximo(3, 1, 1).

:- end_tests(estilo).
