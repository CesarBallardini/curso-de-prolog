:- encoding(utf8).

:- begin_tests(construir).

test(cuatrimestre_datos) :-
    oferta(cuatrimestre, O),
    once(construir(O, datos, H)),
    horario_valido(O, H).

test(cuatrimestre_dificiles) :-
    oferta(cuatrimestre, O),
    once(construir(O, dificiles, H)),
    horario_valido(O, H).

test(ubicaciones, [true(N-M == 16-32)]) :-
    oferta(cuatrimestre, O),
    ubicaciones(O, am1-1, N),
    ubicaciones(O, log-1, M).

test(dificiles_primero, [true(Primeras == [am1-1, am1-2])]) :-
    oferta(cuatrimestre, O),
    ordenar_clases(O, dificiles, [A, B|_]),
    Primeras = [A, B].

test(orden_datos, [true(C == am1-1)]) :-
    oferta(cuatrimestre, O),
    ordenar_clases(O, datos, [C|_]).

test(compatible) :-
    oferta(cuatrimestre, O),
    compatible(O, asignada(log-1, 2, 5, 6), [asignada(am1-1, 1, 0, 1)]).

test(aula_ocupada, [fail]) :-
    oferta(cuatrimestre, O),
    compatible(O, asignada(bd-1, 1, 0, 1), [asignada(am1-1, 1, 0, 1)]).

test(mismo_anio, [fail]) :-
    oferta(cuatrimestre, O),
    compatible(O, asignada(alg-1, 2, 0, 1), [asignada(am1-1, 1, 0, 1)]).

test(mismo_docente, [fail]) :-
    oferta(cuatrimestre, O),
    compatible(O, asignada(am2-1, 2, 0, 1), [asignada(am1-1, 1, 0, 1)]).

test(mismo_dia, [fail]) :-
    oferta(cuatrimestre, O),
    compatible(O, asignada(am1-2, 1, 3, 4), [asignada(am1-1, 1, 0, 1)]).

test(ubicacion, [true(Us == [0-1, 1-1, 2-1])]) :-
    oferta(materias([am1], 1, 3), O),
    findall(S-A, ubicacion(O, am1-1, asignada(am1-1, A, S, _)), Us).

test(incompatibles_en_orden) :-
    oferta(cuatrimestre, O),
    incompatibles_en_orden(O, am2-1, am1-1).

test(pasos_datos, [true(K == 18)]) :-
    medir_construir(facultad(6), datos, K).

test(pasos_dificiles, [true(K == 817)]) :-
    medir_construir(facultad(12), dificiles, K).

test(sin_horario, [fail]) :-
    oferta(materias([am1], 2, 4), O),
    construir(O, dificiles, _).

:- end_tests(construir).
