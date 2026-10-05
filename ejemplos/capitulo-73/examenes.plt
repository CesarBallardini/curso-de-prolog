:- encoding(utf8).

:- begin_tests(examenes).

test(proyecto, [true(N-K-A == 7-7-2)]) :-
    proyecto_examenes(2, proyecto(Ts, Ps, A)),
    length(Ts, N),
    length(Ps, K).

test(precedencia, [true(memberchk(antes(log, pp), Ps))]) :-
    proyecto_examenes(2, proyecto(_, Ps, _)).

test(llamado_72, [true(D-G-V == 4-optima(por_lista)-[alg-am1, am2-log])]) :-
    llamado_72(2, C, G),
    proyecto_examenes(2, P),
    valido(P, C),
    duracion(C, D),
    conflictos_violados(C, V).

test(llamado_72_tres_aulas, [true(D == 3)]) :-
    llamado_72(3, C, _),
    duracion(C, D).

test(llamado_clpfd, [true(D == 5)]) :-
    llamado_clpfd(2, C, D),
    proyecto_examenes(2, P),
    valido(P, C),
    sin_conflictos(C),
    duracion(C, D).

test(clpfd_tres_aulas, [true(D == 5)]) :-
    llamado_clpfd(3, _, D).

test(clpfd_una_aula, [true(D == 7)]) :-
    llamado_clpfd(1, _, D).

test(conflicto_violado, [fail]) :-
    sin_conflictos([asignada(am1, 1, 0, 1), asignada(alg, 2, 0, 1)]).

test(lineas, [true(Ls == ["día 1: am1 alg", "día 2: log"])]) :-
    lineas_llamado([ asignada(am1, 1, 0, 1), asignada(alg, 2, 0, 1),
                     asignada(log, 1, 1, 2) ], Ls).

test(aulas_no_validas, [error(type_error(positive_integer, 0))]) :-
    proyecto_examenes(0, _).

:- end_tests(examenes).
