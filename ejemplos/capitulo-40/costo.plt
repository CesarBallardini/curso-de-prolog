:- encoding(utf8).

:- begin_tests(costo, [cleanup(cadena(0))]).

% Las tres definiciones dan las mismas respuestas.
test(iguales, [forall(member(P, [alcanza_sin_tabla, alcanza_der,
                                 alcanza_izq])),
               true(Ys == L)]) :-
    cadena(20),
    numlist(1, 20, L),
    findall(Y, call(P, 0, Y), Ys0),
    msort(Ys0, Ys).

% La recursión a la izquierda usa una tabla; a la derecha, una por nodo.
test(una_tabla, [true(T == 1)]) :-
    cadena(100),
    aggregate_all(count, alcanza_izq(0, _), _),
    tablas(T).

test(tabla_por_nodo, [true(T == 101)]) :-
    cadena(100),
    aggregate_all(count, alcanza_der(0, _), _),
    tablas(T).

% Con la recursión a la derecha, las tablas guardan N(N+1)/2 respuestas.
test(respuestas_der, [true(N == 5050)]) :-
    cadena(100),
    aggregate_all(count, ( between(0, 100, X), alcanza_der(X, _) ), N).

test(sin_tabla_no_crea, [true(T == 0)]) :-
    cadena(100),
    aggregate_all(count, alcanza_sin_tabla(0, _), _),
    tablas(T).

test(cadena_negativa, [error(type_error(nonneg, -1))]) :-
    cadena(-1).

:- end_tests(costo).
