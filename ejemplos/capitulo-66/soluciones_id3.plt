:- encoding(utf8).

:- begin_tests(soluciones_id3).

test(comparar_dia, [true(F == [dia-0.94-0.247, cielo-0.247-0.156,
                               temperatura-0.029-0.019,
                               humedad-0.152-0.152,
                               viento-0.048-0.049])]) :-
    comparar_dia(F).

% Los dos criterios eligen el día para la raíz.
test(arboles_con_dia, [true(G-R == dia-dia)]) :-
    arboles_con_dia(G, R).

test(dia_nuevo, [fail]) :-
    clasifica_dia_nuevo(_).

test(con_dia, [true(O == [dia=3, cielo=nublado, temperatura=calor,
                          humedad=alta, viento=no])]) :-
    con_dia(Es),
    nth1(3, Es, O-_).

test(valores_dia, [true(N == 14)]) :-
    valores(dia, Ds),
    length(Ds, N).

:- end_tests(soluciones_id3).
