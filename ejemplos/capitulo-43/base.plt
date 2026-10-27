:- encoding(utf8).

:- begin_tests(base).

test(tablas, [true(Ts == [alumnos, correlativas, inscripciones,
                          materias])]) :-
    setof(T, P^Cs^(base:tabla(T, P, Cs)), Ts).

% Cada tabla tiene tantas filas como en schema.sql.
test(filas, [all(T-K == [alumnos-7, materias-7, correlativas-7,
                         inscripciones-17])]) :-
    base:tabla(T, _, _),
    aggregate_all(count, base:fila(T, _), K).

test(consistente, [fail]) :-
    base:violacion(_).

% Las actualizaciones cambian los hechos del módulo, no los de user.
test(insertar_en_el_modulo, [true(K == 8)]) :-
    snapshot(( base:insertar(alumno(108, hugo, civil, 2026)),
               aggregate_all(count, base:alumno(_, _, _, _), K) )).

test(aprobada, [true(K == 10)]) :-
    aggregate_all(count, base:aprobada(_, _, _), K).

:- end_tests(base).
