:- encoding(utf8).

:- begin_tests(operadores).

test(hijos_de_juan, all(H == [ana, pedro])) :-
    juan es_padre_de H.

test(abuelo_de_eva, all(A == [juan])) :-
    A es_abuelo_de eva.

% El operador es otra forma de escribir la misma estructura.
test(misma_estructura, true(T == es_padre_de(juan, ana))) :-
    T = (juan es_padre_de ana).

test(forma_canonica, true(S == "es_padre_de(juan,ana)")) :-
    with_output_to(string(S), write_canonical(juan es_padre_de ana)).

test(declaracion, true(P-T == 700-xfx)) :-
    current_op(P, T, es_padre_de).

% yfx agrupa a la izquierda; xfy, a la derecha.
test(resta_agrupa_a_la_izquierda, true(A-B == (a - b)-c)) :-
    a - b - c = A - B.

test(potencia_agrupa_a_la_derecha, true(A-B == 2-(3^2))) :-
    2^3^2 = A^B.

% La coma no se puede redefinir.
test(la_coma_no_se_redefine,
     [error(permission_error(modify, operator, ','))]) :-
    op(700, xfx, ',').

:- end_tests(operadores).
