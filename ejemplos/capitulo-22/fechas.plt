:- encoding(utf8).

:- begin_tests(fechas).

test(analizar, true(F == fecha(2026, 9, 24))) :-
    phrase(fecha(F), `24/09/2026`).

test(generar, true(A == '24/9/2026')) :-
    phrase(fecha(fecha(2026, 9, 24)), Cs),
    atom_codes(A, Cs).

test(mes_invalido, [fail]) :-
    phrase(fecha(_), `1/13/2026`).

test(no_bisiesto, [fail]) :-
    phrase(fecha(_), `29/2/2027`).

test(bisiesto, true(F == fecha(2028, 2, 29))) :-
    phrase(fecha(F), `29/2/2028`).

test(anio_1900_no_bisiesto, [fail]) :-
    phrase(fecha(_), `29/2/1900`).

test(anio_2000_bisiesto) :-
    phrase(fecha(_), `29/2/2000`).

test(fechas, true(Fs == [fecha(2028, 2, 29), fecha(2026, 10, 1)])) :-
    phrase(fechas(Fs), `29/2/2028, 1/10/2026`).

test(ninguna_fecha, true(Fs == [])) :-
    phrase(fechas(Fs), ``).

test(generar_fechas, true(A == '1/1/2026, 3/2/2026')) :-
    phrase(fechas([fecha(2026, 1, 1), fecha(2026, 2, 3)]), Cs),
    atom_codes(A, Cs).

:- end_tests(fechas).
