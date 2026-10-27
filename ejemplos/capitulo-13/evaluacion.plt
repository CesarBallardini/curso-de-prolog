:- encoding(utf8).

:- begin_tests(evaluacion).

test(concatenar_dos_listas, all(W == [[a, b]])) :-
    concatenar([a], [b], W).

% Las tres maneras de partir [a, b], en el orden del recorrido en profundidad.
test(partir_una_lista, all(X-Y == [[]-[a, b], [a]-[b], [a, b]-[]])) :-
    concatenar(X, Y, [a, b]).

% p tiene una demostración; la rama de n :- f. queda pendiente y falla.
test(p_se_cumple, nondet) :-
    p.

test(f_no_se_cumple, [fail]) :-
    f.

test(consecutivos_en_orden, all(Z == [3, 4])) :-
    consecutivos(2, Z, [2, 3, 2, 4]).

test(consecutivos_en_orden_inverso, all(Z == [4, 3])) :-
    consecutivos_invertido(2, Z, [2, 3, 2, 4]).

test(no_consecutivos, [fail]) :-
    consecutivos(3, 4, [2, 3, 2, 4]).

:- end_tests(evaluacion).
