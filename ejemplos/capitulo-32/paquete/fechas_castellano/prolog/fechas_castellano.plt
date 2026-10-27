:- encoding(utf8).

:- begin_tests(fechas_castellano).

test(fecha_texto, true(T == "viernes 25 de septiembre de 2026")) :-
    fecha_texto(date(2026, 9, 25), T).

test(dias_entre, true(D == 208)) :-
    dias_entre(date(2026, 3, 1), date(2026, 9, 25), D).

test(sumar_dias, true(F == date(2028, 2, 29))) :-
    sumar_dias(date(2028, 2, 28), 1, F).

:- end_tests(fechas_castellano).
