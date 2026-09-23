:- encoding(utf8).

:- begin_tests(naturales).

test(cero_es_natural) :-
    natural(cero).

test(dos_es_natural, [nondet]) :-
    natural(s(s(cero))).

test(uno_mas_dos_son_tres, all(C == [s(s(s(cero)))])) :-
    suma(s(cero), s(s(cero)), C).

test(cero_mas_algo_es_ese_algo, all(C == [s(s(cero))])) :-
    suma(cero, s(s(cero)), C).

test(cero_es_menor_que_uno) :-
    menor(cero, s(cero)).

test(uno_no_es_menor_que_cero, [fail]) :-
    menor(s(cero), cero).

test(nadie_es_menor_que_si_mismo, [fail]) :-
    menor(s(s(cero)), s(s(cero))).

test(el_valor_de_tres, all(V == [3])) :-
    valor(s(s(s(cero))), V).

% suma/3 también permite restar: se la consulta en sentido inverso.
test(la_suma_va_para_atras, all(A == [s(cero)])) :-
    suma(A, s(s(cero)), s(s(s(cero)))).

:- end_tests(naturales).
