:- encoding(utf8).

:- begin_tests(soluciones_proyecto).

% Ejercicio 13
test(registrar_nota, [ setup(estado(E)), cleanup(restaurar(E)),
                       true(N == 9) ]) :-
    registrar_nota(101, pp, 9),
    aprobada(101, pp, N).

test(nota_de_una_materia_aprobada, [ setup(estado(E)), cleanup(restaurar(E)),
                                     fail ]) :-
    registrar_nota(101, am1, 9).

test(nota_invalida, [ setup(estado(E)), cleanup(restaurar(E)), fail ]) :-
    registrar_nota(101, pp, 11).

test(nota_no_cambia_la_base, [ setup(estado(E)), cleanup(restaurar(E)),
                               true(Estado == cursando) ]) :-
    \+ registrar_nota(101, pp, 0),
    inscripcion(101, pp, Estado).

% Ejercicio 14
test(historial, [ setup(estado(E)), cleanup(restaurar(E)),
                  true(H == [1-inscribir(104, ssl, aceptada),
                             2-dar_de_baja(104, ssl)]) ]) :-
    inscribir(104, ssl, _),
    dar_de_baja(104, ssl),
    historial(H).

test(historial_vacio, true(H == [])) :-
    historial(H).

% Ejercicio 15: el promedio guardado se actualiza al registrar una nota.
test(promedio_memo, [ setup(estado(E)), cleanup(restaurar(E)),
                      true(P0-P == 8.5-8.6) ]) :-
    promedio_memo(101, P0),
    registrar_nota(101, pp, 9),
    promedio_memo(101, P).

% Sin la invalidación, el valor guardado quedaría viejo: se simula
% cambiando la nota sin registrar_nota/3.
test(sin_invalidar, [ setup(estado(E)), cleanup(restaurar(E)),
                      true(P == 8.5) ]) :-
    promedio_memo(101, _),
    retract(user:inscripcion(101, pp, cursando)),
    assertz(user:inscripcion(101, pp, nota(9))),
    promedio_memo(101, P).

:- end_tests(soluciones_proyecto).
