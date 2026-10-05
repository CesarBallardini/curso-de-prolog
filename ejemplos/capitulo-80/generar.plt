:- encoding(utf8).

:- begin_tests(generar).

test(cubo_con_borde,
     [true(Ls == [(a-b)-mas, (a-c)-mas, (a-d)-mas, (b-e)-der, (b-g)-izq,
                  (c-e)-izq, (c-f)-der, (d-f)-izq, (d-g)-der])]) :-
    once(etiquetar_gyp(cubo, borde, Ls)).

test(cubo_sin_borde, [true(N == 4)]) :-
    interpretaciones_gyp(cubo, sin_borde, N).

test(cubo_con_borde_unica, [true(N == 1)]) :-
    interpretaciones_gyp(cubo, borde, N).

test(union_valida) :-
    union_valida(u(e, ele, [inversa(izq), inversa(der)])).

test(union_invalida, [fail]) :-
    union_valida(u(e, ele, [inversa(mas), inversa(mas)])).

:- end_tests(generar).
