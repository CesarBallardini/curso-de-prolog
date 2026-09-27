:- encoding(utf8).

:- use_module('../inscripciones/datos').

:- begin_tests(operaciones).

test(inscribir, [ setup(estado(E)), cleanup(restaurar(E)),
                  true(R == aceptada) ]) :-
    inscribir(104, ssl, R).

% reglas no se importó: aprobada/3 no está disponible.
test(solo_operaciones, [error(existence_error(procedure, _), _)]) :-
    call(aprobada(_, _, _)).

:- end_tests(operaciones).
