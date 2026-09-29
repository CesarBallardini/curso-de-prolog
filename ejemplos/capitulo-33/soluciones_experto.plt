:- encoding(utf8).

:- begin_tests(soluciones_experto).

% Ejercicio 13
test(avestruz, all(A == [avestruz])) :-
    identificar([tiene_plumas, peso(90)], A).

test(pinguino, all(A == [pinguino])) :-
    identificar([tiene_plumas, nada, peso(30)], A).

test(vuela, all(A == [])) :-
    identificar([tiene_plumas, vuela, nada, peso(90)], A).

test(casos, true(As == [1-guepardo, 2-cebra, 3-avestruz, 4-pinguino])) :-
    findall(N-A, ( caso(N, Obs), identificar(Obs, A) ), As).

test(no_se_prueba_negacion,
     true(E == no_probado(avestruz, [r12-se_prueba(vuela)]))) :-
    no_se_prueba(avestruz, [tiene_plumas, vuela, peso(90)], E).

test(por_que_no,
     true(S == "avestruz: no se prueba\n  por r12:\n    no vuela: se \c
                prueba vuela\n")) :-
    with_output_to(string(S),
                   por_que_no([tiene_plumas, vuela, peso(90)], avestruz)).

test(como_negacion,
     true(S == "pinguino: por r11\n  ave: por r3\n    tiene_plumas: \c
                observado\n  no vuela: no se prueba vuela\n  nada: \c
                observado\n")) :-
    with_output_to(string(S), como([tiene_plumas, nada], pinguino)).

% Ejercicio 14
test(motivo,
     true(S == "tiene_pelo se pregunta para aplicar:\n  r1: si tiene_pelo \c
                entonces mamifero\n  r5: si mamifero y come_carne \c
                entonces carnivoro\n")) :-
    with_output_to(string(S),
                   motivo(tiene_pelo, [r1-mamifero, r5-carnivoro])).

:- end_tests(soluciones_experto).
