:- encoding(utf8).

:- begin_tests(oferta).

test(clases, [true(N == 16)]) :-
    oferta(cuatrimestre, O),
    aggregate_all(count, clase(O, _, _, _, _, _), N).

test(clase_por_id, [true(M-A-D-C == am2-2-perez-25)]) :-
    oferta(cuatrimestre, O),
    clase(O, am2-3, M, A, D, C).

test(materias_reducidas, [true(Ids == [am1-1, am1-2, am1-3, alg-1, alg-2])]) :-
    oferta(materias([am1, alg], 3, 2), O),
    findall(Id, clase(O, Id, _, _, _, _), Ids).

test(dias_recortados, [true(Ds == [1, 2, 3])]) :-
    oferta(materias([am1], 3, 2), O),
    findall(D, disponible(O, garcia, D), Ds).

test(momentos, [true(N == 20)]) :-
    oferta(cuatrimestre, O),
    momentos(O, N).

test(momento_directo, [true(D-F == 3-2)]) :-
    oferta(cuatrimestre, O),
    momento(O, 9, D, F).

test(momento_inverso, [true(S == 9)]) :-
    oferta(cuatrimestre, O),
    momento(O, S, 3, 2).

test(momento_fuera, [fail]) :-
    oferta(cuatrimestre, O),
    momento(O, 20, _, _).

test(aula, [true(N-C == lab-20)]) :-
    oferta(cuatrimestre, O),
    aula(O, 3, N, C).

test(incompatibles_anio) :-
    oferta(cuatrimestre, O),
    incompatibles(O, alg-1, am1-2),
    !.

test(incompatibles_docente) :-
    oferta(cuatrimestre, O),
    incompatibles(O, am1-1, am2-1),
    !.

test(compatibles, [fail]) :-
    oferta(cuatrimestre, O),
    incompatibles(O, bd-1, log-1).

test(pares_incompatibles, [true(N == 60)]) :-
    oferta(cuatrimestre, O),
    aggregate_all(count, incompatibles(O, _, _), N).

test(ejemplo_valido) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H),
    horario_valido(O, H).

test(aula_chica, [fail]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    selectchk(asignada(am1-1, 1, 0, 1), H0, asignada(am1-1, 3, 0, 1), H),
    horario_valido(O, H).

test(docente_ausente, [fail]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    selectchk(asignada(bd-1, 3, 12, 13), H0, asignada(bd-1, 3, 0, 1), H),
    horario_valido(O, H).

test(fuera_de_la_semana, [fail]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    selectchk(asignada(bd-2, 3, 16, 17), H0, asignada(bd-2, 3, 20, 21), H),
    horario_valido(O, H).

test(aula_ocupada, [fail]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    selectchk(asignada(log-1, 2, 5, 6), H0, asignada(log-1, 2, 2, 3), H),
    horario_valido(O, H).

test(choque_momento, [true(Cs == [mismo_momento(am1-1, am2-1)])]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    selectchk(asignada(am2-1, 2, 2, 3), H0, asignada(am2-1, 2, 0, 1), H),
    findall(C, choque(O, H, C), Cs).

test(choque_dia, [true(Cs == [mismo_dia(alg-1, alg-2)])]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    selectchk(asignada(alg-2, 1, 9, 10), H0, asignada(alg-2, 1, 2, 3), H),
    findall(C, choque(O, H, C), Cs).

test(falta_una_clase, [fail]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo([_|H]),
    horario_valido(O, H).

test(grilla, [true(Ls == [ "   lun       mar       mie       jue       vie",
                           "F1 -         -         -         bd/lab    bd/lab",
                           "F2 -         -         -         -         -",
                           "F3 -         -         -         -         -",
                           "F4 -         -         -         -         -" ])]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H),
    lineas_anio(O, H, 3, Ls).

:- end_tests(oferta).
