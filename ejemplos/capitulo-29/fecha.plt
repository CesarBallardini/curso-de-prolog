:- encoding(utf8).

:- begin_tests(fecha).

% hoy/1 depende del reloj: se prueba solo su forma.
test(hoy) :-
    hoy(date(A, M, D)),
    integer(A), between(1, 12, M), between(1, 31, D).

test(dias_entre, true(D == 208)) :-
    dias_entre(date(2026, 3, 1), date(2026, 9, 25), D).

test(dias_hacia_atras, true(D == -208)) :-
    dias_entre(date(2026, 9, 25), date(2026, 3, 1), D).

test(fin_de_mes, true(F == date(2026, 3, 2))) :-
    sumar_dias(date(2026, 1, 31), 30, F).

test(bisiesto, true(F == date(2028, 2, 29))) :-
    sumar_dias(date(2028, 2, 28), 1, F).

test(cambio_de_anio, true(F == date(2025, 12, 26))) :-
    sumar_dias(date(2026, 1, 5), -10, F).

test(dia_de_la_semana, true(D == sábado)) :-
    dia_de_la_semana(date(2026, 9, 26), D).

test(fecha_texto, true(T == "viernes 25 de septiembre de 2026")) :-
    fecha_texto(date(2026, 9, 25), T).

test(escribir_iso, true(T == "2026-09-05")) :-
    fecha_iso(date(2026, 9, 5), T).

test(leer_iso, true(F == date(2026, 9, 25))) :-
    fecha_iso(F, "2026-09-25").

:- end_tests(fecha).
