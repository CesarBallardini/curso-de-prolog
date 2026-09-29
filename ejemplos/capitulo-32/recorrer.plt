:- encoding(utf8).

:- begin_tests(recorrer).

test(ingenuo_enumera, all(S == [f(a, g(b)), a, g(b), b])) :-
    subtermino_ingenuo(S, f(a, g(b))).

% La versión ingenua liga la variable del término que examina.
test(ingenuo_liga, all(X == [a])) :-
    subtermino_ingenuo(a, f(X, b)).

test(subtermino, all(S == [f(a, g(b)), a, g(b), b])) :-
    subtermino(S, f(a, g(b))).

test(subtermino_atomo, all(S == [ana])) :-
    subtermino(S, ana).

% Las variables del término se enumeran como subtérminos, sin ligarlas.
test(subtermino_variables, true(N-V == 3-libre)) :-
    aggregate_all(count, subtermino(_, f(X, b)), N),
    (   var(X)
    ->  V = libre
    ;   V = ligada
    ).

test(contiene, [true]) :-
    contiene(f(a, g(b)), b).

test(contiene_no_liga, [fail]) :-
    contiene(f(_, b), a).

test(contiene_variable, [true]) :-
    contiene(f(X, b), X).

test(sustituir, true(T == 3 * 3 + y)) :-
    sustituir(x, 3, x * x + y, T).

test(sustituir_compuesto, true(T == f(z, z))) :-
    sustituir(g(a), z, f(g(a), z), T).

% Solo se reemplaza la variable idéntica a Viejo, no las demás.
test(sustituir_variable, true(T == f(3, Y))) :-
    sustituir(X, 3, f(X, Y), T).

test(sustituir_sin_apariciones, true(T == f(a))) :-
    sustituir(x, 3, f(a), T).

test(transformar, true(T == f(2, g(4), a))) :-
    transformar(duplicar, f(1, g(2), a), T).

test(transformar_hoja, true(T == 6)) :-
    transformar(duplicar, 3, T).

test(transformar_sin_cambios, true(T == f(a, g(b)))) :-
    transformar(duplicar, f(a, g(b)), T).

test(duplicar, true(M == 5.0)) :-
    duplicar(2.5, M).

test(duplicar_no_numero, [fail]) :-
    duplicar(a, _).

test(contiene_subtermino, [true]) :-
    contiene(f(a, g(b)), g(b)).

test(transformar_variable, true(T == f(X, 2))) :-
    transformar(duplicar, f(X, 1), T).

% De abajo hacia arriba: P recibe el nodo con los argumentos ya
% transformados.
test(transformar_abajo_arriba, true(T == [2, 4, 6])) :-
    transformar(duplicar, [1, 2, 3], T).

test(atomos, true(As == [a, b, f])) :-
    atomos(g(b, h(a, f), 3, [a]), As).

test(atomos_sin, true(As == [])) :-
    atomos(f(1, _), As).

test(mapsubterms, true(T == 3 * 3 + y)) :-
    mapsubterms([x, 3]>>true, x * x + y, T).

:- end_tests(recorrer).
