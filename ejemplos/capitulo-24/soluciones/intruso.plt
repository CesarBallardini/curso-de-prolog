:- encoding(utf8).

:- use_module('../inscripciones/datos').

:- begin_tests(intruso).

% El hecho llega al módulo datos: la protección es una convención.
test(modifica_datos, [ setup(estado(E)), cleanup(restaurar(E)),
                       true(Estado == cursando) ]) :-
    agregar_mal(104, ssl),
    datos:inscripcion(104, ssl, Estado).

:- end_tests(intruso).
