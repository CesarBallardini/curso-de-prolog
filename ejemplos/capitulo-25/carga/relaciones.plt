:- encoding(utf8).

:- begin_tests(relaciones).

% El archivo de pruebas se carga en user, que importó relaciones: puede
% escribir el operador.
test(aprobadas_de_ana, all(M == [am1, alg, log, am2])) :-
    101 aprobo M.

test(gabriela_no_aprobo_nada, [fail]) :-
    107 aprobo _.

% El operador es un término como cualquier otro: aprobo(101, am1).
test(termino, true(T == aprobo(101, am1))) :-
    T = (101 aprobo am1).

test(operador_exportado, true(Ops == [op(700, xfx, aprobo)])) :-
    module_property(relaciones, exported_operators(Ops)).

:- end_tests(relaciones).
