:- encoding(utf8).

% Pruebas de soluciones.pl. Necesitan Python: test_soluciones.py las ejecuta
% dentro del proceso de Python, con Janus.

:- begin_tests(soluciones).

test(envolver, true(L == ['uno dos', tres, cuatro, cinco])) :-
    envolver("uno dos tres cuatro cinco", 9, L).

test(envolver_vacio, true(L == [])) :-
    envolver("", 9, L).

test(a_json, true(T == '{"a": [1, 2], "b": 1, "c": "x"}')) :-
    a_json(_{b: 1, a: [1, 2], c: "x"}, T).

:- end_tests(soluciones).
