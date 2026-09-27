:- encoding(utf8).

:- begin_tests(orden).

% El orden estándar: variables, números, cadenas, átomos, compuestos.
test(orden_estandar, true(L = [_, 1.0, 1, 2.0, "c", a, b, f(x)])) :-
    msort([b, 1, "c", f(x), a, 2.0, _, 1.0], L).

% Los compuestos se comparan primero por aridad.
test(aridad_primero, true(O == (<))) :-
    compare(O, f(z), f(a, a)).

test(por_edad, true(L == [eva-8, luis-12, pedro-39, ana-41, juan-68,
                          marta-68])) :-
    por_edad(L).

% sort/4 con @>= conserva los repetidos, en el orden original.
test(por_edad_descendente, true(L == [juan-68, marta-68, ana-41, pedro-39,
                                      luis-12, eva-8])) :-
    por_edad_descendente(L).

test(edades_distintas, true(L == [8, 12, 39, 41, 68])) :-
    edades_distintas(L).

% sort/4 con @> elimina los que tienen la misma clave.
test(sort_elimina_repetidos, true(L == [b-2, a-1])) :-
    sort(2, @>, [a-1, b-2, c-1], L).

test(msort_conserva, true(L == [a, a, b, c])) :-
    msort([c, a, b, a], L).

test(por_edad_y_nombre, true(L == [juan, marta, ana, pedro, luis, eva])) :-
    por_edad_y_nombre(L).

% predsort/3 elimina los elementos que compara como =.
test(predsort_elimina_iguales, true(L == [a, b])) :-
    predsort([O, A, B]>>compare(O, A, B), [b, a, b], L).

:- end_tests(orden).
