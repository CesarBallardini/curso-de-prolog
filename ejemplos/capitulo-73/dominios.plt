:- encoding(utf8).

:- begin_tests(dominios).

test(cuatrimestre) :-
    oferta(cuatrimestre, O),
    once(resolver(O, H)),
    horario_valido(O, H).

test(facultad_13) :-
    oferta(facultad(13), O),
    once(resolver(O, H)),
    horario_valido(O, H).

test(dominio_inicial, [true(N-Primero == 16-(0-1))]) :-
    oferta(cuatrimestre, O),
    dominios_iniciales(O, [am1-1-D|_]),
    length(D, N),
    D = [Primero|_].

test(elegir, [true(E-R == b-[1]-[a-[1, 2], c-[3]])]) :-
    elegir([a-[1, 2], b-[1], c-[3]], E, R).

test(elegir_empate, [true(E == a-[1])]) :-
    elegir([a-[1], b-[2]], E, _).

test(podar_aula, [true(D == [0-2, 1-1])]) :-
    oferta(materias([log, bd], 5, 4), O),
    podar(O, asignada(bd-1, 1, 0, 1), log-1-[0-1, 0-2, 1-1], log-1-D).

test(podar_incompatible, [true(D == [1-1])]) :-
    oferta(cuatrimestre, O),
    podar(O, asignada(am1-1, 1, 0, 1), alg-1-[0-1, 0-2, 1-1], alg-1-D).

test(podar_mismo_dia, [true(D == [4-1])]) :-
    oferta(cuatrimestre, O),
    podar(O, asignada(am1-1, 1, 0, 1), am1-2-[1-1, 3-1, 4-1], am1-2-D).

test(podar_vacio, [fail]) :-
    oferta(cuatrimestre, O),
    podar(O, asignada(am1-1, 1, 0, 1), am1-2-[1-1, 3-1], _).

test(pasos, [true(K == 169)]) :-
    medir_dominios(facultad(13), K).

test(sin_horario, [fail]) :-
    oferta(materias([am1], 2, 4), O),
    resolver(O, _).

:- end_tests(dominios).
