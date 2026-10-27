:- encoding(utf8).

:- begin_tests(explicaciones).

test(solo_rebatibles, [true(S == [(p :~ q), (q :~ true)])]) :-
    supuestos(regla((p :~ q), [regla((q :~ true), []),
                               estricta(r),
                               regla((p :~ q), [])]),
              S).

test(estricta, [true(S == [])]) :-
    supuestos(regla((p :- q), [estricta(q), predefinido(1 < 2)]), S).

test(criterio_desconocido, [error(type_error(_, _))]) :-
    derivacion(prioridad, p, _).

test(meta_libre, [error(instantiation_error)]) :-
    por_que_no([], _, _).

:- end_tests(explicaciones).
