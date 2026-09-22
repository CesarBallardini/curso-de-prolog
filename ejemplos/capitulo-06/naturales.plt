:- encoding(utf8).

:- begin_tests(naturales).

test(cero_es_natural) :-
    natural(0).

test(dos_es_natural, [nondet]) :-
    natural(s(s(0))).

test(uno_mas_dos_son_tres, all(C == [s(s(s(0)))])) :-
    suma(s(0), s(s(0)), C).

test(cero_mas_algo_es_ese_algo, all(C == [s(s(0))])) :-
    suma(0, s(s(0)), C).

test(cero_es_menor_que_uno) :-
    menor(0, s(0)).

test(uno_no_es_menor_que_cero, [fail]) :-
    menor(s(0), 0).

test(nadie_es_menor_que_si_mismo, [fail]) :-
    menor(s(s(0)), s(s(0))).

test(el_valor_de_tres, all(V == [3])) :-
    valor(s(s(s(0))), V).

% suma/3 también permite restar: se la consulta en sentido inverso.
test(la_suma_va_para_atras, all(A == [s(0)])) :-
    suma(A, s(s(0)), s(s(s(0)))).

:- end_tests(naturales).
