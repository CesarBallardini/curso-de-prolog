:- encoding(utf8).

% Cada prueba compara con el resultado de la consulta SQL del ejercicio
% en SQLite.

:- begin_tests(soluciones).

test(ej1, [all(N-C-I == [bruno-sistemas-2024, diego-sistemas-2024,
                         facundo-industrial-2024,
                         gabriela-industrial-2025])]) :-
    alumno(_, N, C, I), I >= 2024, C \== civil.

test(ej2, [true(K-Cs == 7-[civil, industrial, sistemas])]) :-
    aggregate_all(count, alumno(_, _, _, _), K),
    setof(C, L^N^I^alumno(L, N, C, I), Cs).

test(ej3, [true(K == 10)]) :-
    aggregate_all(count, aprobada_con_nombres(_, _, _), K).

test(ej3_sin_integer, [error(type_error(evaluable, null/0))]) :-
    aggregate_all(count, ( inscripcion(_, _, N), N >= 6 ), _).

test(ej4, [all(A-B-C == [ana-bruno-sistemas, ana-diego-sistemas,
                         bruno-diego-sistemas, carla-elena-civil,
                         facundo-gabriela-industrial])]) :-
    misma_carrera(A, B, C).

test(ej5, [true(K-Ls == 9-[101, 102, 103, 104, 105, 106])]) :-
    aggregate_all(count, en_am1_o_log(_), K),
    setof(L, en_am1_o_log(L), Ls).

test(ej6, [all(L-N == [107-gabriela])]) :-
    sin_inscripciones(L, N).

test(ej7, [all(L-N == [101-ana])]) :-
    aprobo_primer_anio(L, N).

test(ej8, [all(L-P == [101-8.5, 102-4, 103-6, 104-8, 106-4.5])]) :-
    promedio_alumno(L, P).

test(ej9, [all(L-M-R == [103-am2-alg])]) :-
    correlativa_pendiente(L, M, R).

test(ej10, [all(N == [pablo, sofia, tomas, valeria, nicolas])]) :-
    no_depende_de(N, 1).

test(ej10_con_null, [all(N == [marta, pablo, sofia, tomas, valeria,
                               nicolas])]) :-
    empleado(_, N, _, _, J), J \== 1.

test(ej11_count, [true(K == 0)]) :-
    aggregate_all(count, alumno(_, _, quimica, _), K).

test(ej11_grupo, [fail]) :-
    bagof(L, N^I^alumno(L, N, quimica, I), _).

test(ej11_suma, [true(S == 0)]) :-
    aggregate_all(sum(S0), empleado(_, _, legal, S0, _), S).

test(ej11_max, [fail]) :-
    aggregate_all(max(S0), empleado(_, _, legal, S0, _), _).

test(ej12, [true(Ks == [marta-0, irene-1, jorge-1, lucia-1, pablo-2,
                        sofia-2, tomas-2, valeria-2, nicolas-3])]) :-
    findall(K-N, ( nivel(Id, K), empleado(Id, N, _, _, _) ), Ps),
    msort(Ps, Ordenados),
    findall(N-K, member(K-N, Ordenados), Ks).

test(ej13, [true(Ts == [aep-50, brc-160, cor-120, mdz-140, sla-200,
                        ush-200])]) :-
    findall(D-P, tarifa_con_tope(ros, D, P), Ts).

test(ej13_como_tabla, [true(Ts == Tabla)]) :-
    findall(D-P, tarifa_con_tope(ros, D, P), Ts),
    findall(D-P, tarifa(ros, D, P), Tabla0),
    msort(Tabla0, Tabla).

test(ej13_aeropuertos, [true(K == 8)]) :-
    aggregate_all(count, aeropuerto(_), K).

test(ej14, [true(Ss == [3-715000, 6-462000, 7-495000, 8-330000])]) :-
    snapshot(( aumentar(it, 10),
               findall(Id-S, empleado(Id, _, it, S, _), Ss0),
               msort(Ss0, Ss) )).

test(ej14_otros_iguales, [true(S == 500000)]) :-
    snapshot(( aumentar(it, 10),
               empleado(2, _, _, S, _) )).

:- end_tests(soluciones).
