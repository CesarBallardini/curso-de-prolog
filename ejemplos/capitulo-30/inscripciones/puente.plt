:- encoding(utf8).

% Pruebas del módulo puente (capítulo 30): los datos que cruzan a Python.

:- use_module(datos).

:- begin_tests(puente).

test(ranking_py, true(Primera =@= _{legajo: 101, nombre: ana,
                                    promedio: 8.5})) :-
    ranking_py([Primera|_]).

test(materias_py, true(N-Primera =@= 7-_{codigo: am1, nombre: analisis_1,
                                          anio: 1, inscriptos: 5})) :-
    materias_py(Materias),
    length(Materias, N),
    Materias = [Primera|_].

test(aceptada, [ setup(estado(E)), cleanup(restaurar(E)),
                 true(R =@= _{aceptada: @(true)}) ]) :-
    inscribir_py(104, ssl, R).

test(rechazada, [ setup(estado(E)), cleanup(restaurar(E)),
                  true(R =@= _{aceptada: @(false),
                                motivo: "sin_vacantes"}) ]) :-
    inscribir_py(105, log, R).

test(estado_py, [ setup(estado(E)), cleanup(restaurar(E)),
                  true(Despues == E) ]) :-
    estado_py(prolog(Guardado)),
    inscribir_py(104, ssl, _),
    restaurar_py(Guardado),
    estado(Despues).

:- end_tests(puente).
