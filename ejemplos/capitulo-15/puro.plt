:- encoding(utf8).

:- begin_tests(puro).

% Con X ligado, una respuesta y sin alternativas, como sacar/3.
test(sacar_ligado, true(R == [b, a])) :-
    sacar_puro(a, [a, b, a], R).

test(sacar_lo_que_no_esta, [fail]) :-
    sacar_puro(z, [a, b], _).

% Con X libre, sacar/3 (condicional.pl) no responde; sacar_puro/3 enumera los
% dos casos.
test(sacar_con_x_libre, all(X-R == [a-[b], b-[a]])) :-
    sacar_puro(X, [a, b], R).

test(iguales_ligado, true(L == [a, a])) :-
    iguales_a(a, [a, b, a], L).

% var/1, que reconoce una variable libre, se presenta en el capítulo 32.
% Con un elemento libre en la lista, las dos posibilidades: que sea a o que
% no lo sea.
test(iguales_con_un_elemento_libre, all(Y-L == [a-[a, a], z-[a]])) :-
    iguales_a(a, [a, Y], L),
    ( var(Y) -> Y = z ; true ).

:- end_tests(puro).
