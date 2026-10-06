:- encoding(utf8).

:- use_module(library(clpfd)).

:- begin_tests(soluciones).

test(ejercicio_1, [true(Ch-T == [ mismo_momento(log-1, log-2),
                                  mismo_dia(alg-1, alg-2),
                                  mismo_dia(log-1, log-2) ]-invalido)]) :-
    ejercicio_1(Ch, T).

test(proyecto_de, [true(N-A == 16-3)]) :-
    oferta(cuatrimestre, O),
    proyecto_de(O, proyecto(Ts, [], A)),
    length(Ts, N).

test(candidatos, [true(K == 10460353203)]) :-
    candidatos(materias([am1, alg, log], 3, 3), K).

test(grado_primero, [true(C == am1-1)]) :-
    oferta(cuatrimestre, O),
    clases_por_grado(O, [C|_]).

test(grado, [true(K == 15)]) :-
    medir_grado(facultad(6), K).

test(construir_por_grado) :-
    oferta(cuatrimestre, O),
    once(construir_por_grado(O, H)),
    horario_valido(O, H).

test(reparar, [true(C == [asignada(am1-1, 1, 2, 3), asignada(am2-1, 2, 0, 1)])]) :-
    ver_reparacion(C).

test(reparar_valido) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    reparar(O, H0, H),
    msort(H0, H).

test(recursantes) :-
    oferta(cuatrimestre, O),
    horario_con_recursantes(O, [am1-am2, alg-pp], H),
    horario_valido(O, H),
    forall(( member(asignada(am1-_, _, S, _), H),
             member(asignada(am2-_, _, S2, _), H) ),
           S =\= S2).

test(etiquetado, [true(R = r(si, _))]) :-
    medir_etiquetado(facultad(6), ff, R).

test(cota_docentes, [true(C == 9)]) :-
    oferta(cuatrimestre, O),
    cota_docentes(O, C).

test(comparar_costos, [true(D-A == r(9, 10)-r(10, 8))]) :-
    comparar_costos(D, A).

test(costo_docentes, [true(C == 9)]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    findall(asignada(Cl, Au, _, _), member(asignada(Cl, Au, _, _), H0), H),
    costo_docentes(O, H, C),
    maplist(fijar(H0), H).

test(primero_de_varios, [true(C == 11)]) :-
    oferta(facultad(6), O),
    primero_de_varios(O, H, C),
    horario_valido(O, H).

test(cuerpo_aula, [true(Fila == tr([th(1), td('am1-1'), td('am1-2'), td('am1-3'),
                                    td([]), td([])]))]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H),
    cuerpo_aula(O, H, a1, [_, table([_, Fila|_])]).

test(aula_inexistente, [fail]) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H),
    cuerpo_aula(O, H, b9, _).

test(llamado_separado, [true(D == 9)]) :-
    llamado_separado(2, C, D),
    sin_separacion(C).

test(llamado_separado_una_aula, [true(D == 9)]) :-
    llamado_separado(1, _, D).

%!  fijar(+Horario0:list, +Asignada) is det.
%
%   El momento de Asignada es el de su clase en Horario0.
fijar(Horario0, asignada(C, _, S, _)) :-
    memberchk(asignada(C, _, S0, _), Horario0),
    S #= S0.

%!  sin_separacion(+Calendario:list) is semidet.
%
%   Entre los exámenes de cada par de materias en conflicto de Calendario
%   queda al menos un día.
sin_separacion(Calendario) :-
    forall(horarios:conflicto(M1, M2),
           ( memberchk(asignada(M1, _, D1, _), Calendario),
             memberchk(asignada(M2, _, D2, _), Calendario),
             abs(D1 - D2) >= 2 )).

:- end_tests(soluciones).
