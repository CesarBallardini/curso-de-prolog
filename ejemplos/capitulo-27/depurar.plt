:- encoding(utf8).

:- begin_tests(depurar).

% El error plantado: 5 en lugar de 7.5.
test(promedio_mal, true(P =:= 5)) :-
    promedio_mal([6, 9], P).

% Preguntar a la parte: con 1-6 y la nota 9, debería dar 2-15.
test(la_parte_equivocada, true(R == 2-10)) :-
    contar_y_sumar_mal(9, 1-6, R).

test(abuelo_mal_no_encuentra, [fail]) :-
    abuelo_mal(juan, luis).

% Con el segundo objetivo tachado, la consulta se cumple: el error está allí.
test(recortado, [nondet]) :-
    abuelo_recortado(juan, luis).

test(asercion_se_cumple) :-
    nota_valida(7).

% Dentro de una prueba, plunit informa una aserción que no se cumple como una
% prueba fallida, con su propio mensaje: nota_valida(11) no se prueba aquí.

:- end_tests(depurar).
