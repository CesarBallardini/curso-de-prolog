:- encoding(utf8).

:- begin_tests(tablas).

test(debe, [all(Y == [2])]) :-
    debe(1, Y).

test(debe_ciclo, [true(Y == 1)]) :-
    debe(100, Y).

test(evita, [true(N-M == 100-100)]) :-
    aggregate_all(count, evita_izq(1, _), N),
    aggregate_all(count, evita_der(1, _), M).

% Una tabla con la recursión a la izquierda; una por persona con la
% recursión a la derecha, cada una con las 100 respuestas.
test(tablas_izq, [true(T-R == 1-100)]) :-
    tablas(evita_izq(1, _), T, R).

test(tablas_der, [true(T-R == 100-10000)]) :-
    tablas(evita_der(1, _), T, R).

test(programa, [true(L == 32)]) :-
    programa(izq, 30, Cs),
    length(Cs, L).

test(programa_recursion, [error(type_error(oneof([izq, der]), centro), _)]) :-
    programa(centro, 3, _).

% Los hechos mágicos y los átomos adornados son las tablas y sus
% respuestas.
test(magia_izq, [true(M-A == 1-30)]) :-
    programa(izq, 30, Cs),
    magia(Cs, evita(1, _), M, A).

test(magia_der, [true(M-A == 30-900)]) :-
    programa(der, 30, Cs),
    magia(Cs, evita(1, _), M, A).

:- end_tests(tablas).
