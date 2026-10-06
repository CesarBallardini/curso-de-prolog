:- encoding(utf8).

% Pruebas de aprendido.pl: los perfiles por cliente y hora, los ejemplos
% marcados, el entrenamiento del perceptrón del capítulo 69 y los
% sospechosos del último día.

:- begin_tests(aprendido).

test(perfiles, [true(Ps == [perfil(a, 9, 2, 1), perfil(a, 10, 1, 0),
                            perfil(b, 9, 1, 1)])]) :-
    date_time_stamp(date(2026, 10, 1, 9, 30, 0, 10800, -, -), T9),
    date_time_stamp(date(2026, 10, 1, 10, 5, 0, 10800, -, -), T10),
    perfiles([ pedido(T9, b, post, '/sesion', 401, 0.1),
               pedido(T9, a, post, '/sesion', 401, 0.1),
               pedido(T9, a, post, '/sesion', 200, 0.1),
               pedido(T10, a, get, '/materias', 200, 0.1) ], Ps).

test(ejemplos_de_referencia, [true(N-Pos == 158-[ej([25, 25], 1),
                                                 ej([5, 5], 1),
                                                 ej([3, 3], 1)])]) :-
    ejemplos_de_referencia(Es),
    length(Es, N),
    findall(ej(X, 1), member(ej(X, 1), Es), Pos).

test(fallos_solos_no_separan, [fail]) :-
    ejemplos_de_referencia(Es),
    separa_con_fallos(Es).

test(fallos_solos_separan) :-
    separa_con_fallos([ej([10, 2], -1), ej([5, 5], 1)]).

test(entrenar, [true(Pesos-Curva == [-18, -56, 70]-[7, 1, 4, 2, 1, 1, 1, 0])]) :-
    ejemplos_de_referencia(Es),
    entrenar(1, Es, [0, 0, 0], Pesos, Curva).

test(pesos_aprendidos, [true(Pesos == [-18, -56, 70])]) :-
    pesos_aprendidos(Pesos).

test(separa_referencia) :-
    ejemplos_de_referencia(Es),
    pesos_aprendidos(Pesos),
    forall(member(ej(X, Clase), Es), salida(Pesos, X, Clase)).

test(sospechosos_dia_4,
     [true(S == [perfil(ip(198, 51, 100, 61), 14, 17, 17),
                 perfil(ip(203, 0, 113, 7), 10, 60, 60)])]) :-
    pesos_aprendidos(Pesos),
    leer_registro(registros('2026-10-01.log'), Ps),
    sospechosos(Pesos, Ps, S).

test(atacante, [all(Ip == [ip(198, 51, 100, 23)])]) :-
    atacante(registros('2026-09-29.log'), Ip).

test(aprendizaje, [true(P-C == [-18, -56, 70]-[7, 1, 4, 2, 1, 1, 1, 0])]) :-
    aprendizaje(P, C).

test(extremos_de_fallos, [true(A-B == 3-7)]) :-
    extremos_de_fallos(A, B).

test(sospechosos_del_dia,
     [true(S == [perfil(ip(198, 51, 100, 61), 14, 17, 17),
                 perfil(ip(203, 0, 113, 7), 10, 60, 60)])]) :-
    sospechosos_del_dia([-18, -56, 70], registros('2026-10-01.log'), S).

test(sospechosos_dia_3,
     [true(S == [perfil(ip(198, 51, 100, 40), 16, 5, 5),
                 perfil(ip(198, 51, 100, 40), 17, 3, 3)])]) :-
    sospechosos_del_dia([-18, -56, 70], registros('2026-09-30.log'), S).

:- end_tests(aprendido).
