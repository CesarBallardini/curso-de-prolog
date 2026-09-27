:- encoding(utf8).

% Pruebas del programa completo (capítulo 31): los módulos cargados juntos. Cada
% módulo tiene sus propias pruebas; estas verifican que trabajan juntos.

:- begin_tests(inscripciones).

% Un comando inscribe; el informe y el calendario ven la inscripción nueva.
test(de_punta_a_punta, [ setup(estado(E)), cleanup(restaurar(E)),
                         true(L-D == [104]-1) ]) :-
    ejecutar("inscribir a 104 en sintaxis", aceptada),
    inscriptos(ssl, L),
    once(horario(5, 6, H)),
    memberchk(ssl-D, H).

% Los predicados privados de un módulo no son visibles desde afuera.
test(privado, [error(existence_error(procedure, _), _)]) :-
    call(requisitos_guardados(_, _)).

% Pero se pueden llamar calificados con el nombre del módulo.
test(privado_calificado, true(R == [alg, am1])) :-
    requisitos_de(am2, _),
    reglas:requisitos_guardados(am2, R).

:- end_tests(inscripciones).
