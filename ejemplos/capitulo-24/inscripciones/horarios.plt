:- encoding(utf8).

% Pruebas del módulo horarios (capítulo 24): el calendario de exámenes.

% Las pruebas cargan los módulos que usan además del que prueban.
:- use_module(library(clpfd)).
:- use_module(informes).

:- begin_tests(horarios).

% --- Calendario de exámenes --------------------------------------------------

test(conflictos, true(N == 10)) :-
    aggregate_all(count, conflicto(_, _), N).

test(horario, true(H == [am1-1, alg-2, log-3, am2-4, pp-5, ssl-1, bd-1])) :-
    once(horario(5, 6, H)).

% Las cinco materias con ana (101) necesitan cinco días distintos.
test(cuatro_dias_no_alcanzan, [fail]) :-
    horario(4, 20, _).

% Con capacidad 5, am1 (5 alumnos) no puede compartir el día con nadie.
test(capacidad, true(Otras == [])) :-
    once(horario(5, 5, H)),
    memberchk(am1-D, H),
    findall(M, ( member(M-D, H), M \== am1, inscriptos(M, [_|_]) ), Otras).

% Todo horario cumple las dos condiciones.
test(horarios_validos, [fail]) :-
    horario(5, 6, H),
    (   conflicto(M1, M2),
        memberchk(M1-D, H),
        memberchk(M2-D, H)
    ;   between(1, 5, D),
        aggregate_all(sum(N),
                      ( member(M-D, H),
                        horarios:cantidad_de_inscriptos(M-D, N) ),
                      Total),
        Total > 6
    ).

test(dominio_incorrecto, [error(domain_error(clpfd_domain, 1..dos), _)]) :-
    horario(dos, 6, _).

:- end_tests(horarios).
