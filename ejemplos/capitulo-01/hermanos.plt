:- encoding(utf8).

:- begin_tests(hermanos).

% Ejercicio 10: la regla directa incluye a la propia persona.
test(hermano_se_incluye_a_si_mismo, all(Q == [lot, milca, isca])) :-
    hermano(lot, Q).

% Ejercicio 11: la regla corregida no la incluye.
test(hermano_de_verdad_no_se_incluye, all(Q == [milca, isca])) :-
    hermano_de_verdad(lot, Q).

test(abraham_y_haran_son_hermanos) :-
    hermano_de_verdad(abraham, haran).

test(nadie_es_hermano_de_si_mismo, [fail]) :-
    hermano_de_verdad(lot, lot).

test(isaac_no_tiene_hermanos, [fail]) :-
    hermano_de_verdad(isaac, _).

:- end_tests(hermanos).
