:- encoding(utf8).

:- begin_tests(aritmetica).

test(doble_de_21) :-
    doble(21, 42).

test(doble_con_variable, all(D == [42])) :-
    doble(21, D).

test(meses_de_eva, all(M == [96])) :-
    edad_en_meses(eva, M).

test(ocho_es_par, all(R == [0])) :-
    resto(8, R).

test(nueve_es_impar, all(R == [1])) :-
    resto(9, R).

test(el_mayor_de_dos, all(M == [9])) :-
    el_mayor(3, 9, M).

% is evalúa la expresión, pero no la invierte: no permite obtener el operando.
test(is_no_va_para_atras, [throws(error(instantiation_error, _))]) :-
    doble(_, 42).

:- end_tests(aritmetica).
