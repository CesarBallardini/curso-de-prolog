:- encoding(utf8).

:- begin_tests(cribar).

test(una_seccion, true(Q == ["a", "c"])) :-
    cribar(["a", "INICIO", "b", "FIN", "c"], "INICIO", "FIN", Q).

test(dos_secciones, true(Q == ["a", "c", "e"])) :-
    cribar(["a", "INICIO", "b", "FIN", "c", "INICIO x", "d", "FIN y", "e"],
           "INICIO", "FIN", Q).

test(sin_marcas, true(Q == ["a", "b"])) :-
    cribar(["a", "b"], "INICIO", "FIN", Q).

test(vacio, true(Q == [])) :-
    cribar([], "INICIO", "FIN", Q).

test(marca_en_medio_de_la_linea, true(Q == ["a INICIO", "b"])) :-
    cribar(["a INICIO", "b"], "INICIO", "FIN", Q).

% Las limitaciones de la versión 1: una marca de inicio sin fin quita todo
% lo que sigue, y una marca de fin sin inicio se copia como una línea más.
test(inicio_sin_fin, true(Q == ["a"])) :-
    cribar(["a", "INICIO", "b", "c"], "INICIO", "FIN", Q).

test(fin_sin_inicio, true(Q == ["a", "FIN", "b"])) :-
    cribar(["a", "FIN", "b"], "INICIO", "FIN", Q).

test(inicio_dentro_de_seccion, true(Q == ["a", "c"])) :-
    cribar(["a", "INICIO", "INICIO", "b", "FIN", "c"], "INICIO", "FIN", Q).

test(paso_inicio, true(E-S == salteando-[])) :-
    paso(copiando, "INICIO x", "INICIO", "FIN", E, S).

test(paso_copia, true(E-S == copiando-["x"])) :-
    paso(copiando, "x", "INICIO", "FIN", E, S).

test(paso_fin, true(E-S == copiando-[])) :-
    paso(salteando, "FIN", "INICIO", "FIN", E, S).

test(paso_saltea, true(E-S == salteando-[])) :-
    paso(salteando, "x", "INICIO", "FIN", E, S).

test(empieza) :-
    empieza("\\solstart", "\\solstart").

test(no_empieza, [fail]) :-
    empieza(" \\solstart", "\\solstart").

:- end_tests(cribar).
