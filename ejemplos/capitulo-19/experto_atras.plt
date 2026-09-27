:- encoding(utf8).

:- begin_tests(experto_atras).

% Las reglas son términos: si, entonces e y son operadores.
test(una_regla_es_un_termino,
     true(R == entonces(si(y(tiene_plumas, y(no_vuela, nada))), x))) :-
    R = (si tiene_plumas y no_vuela y nada entonces x).

test(caso_1, all(A == [guepardo])) :-
    caso(1, Obs),
    identificar(Obs, A).

test(caso_2, all(A == [cebra])) :-
    caso(2, Obs),
    identificar(Obs, A).

% La comparación de la regla r12 separa al avestruz del pingüino.
test(caso_3, all(A == [avestruz])) :-
    caso(3, Obs),
    identificar(Obs, A).

test(caso_4, all(A == [pinguino])) :-
    caso(4, Obs),
    identificar(Obs, A).

% Un ungulado sin más datos: ninguna hipótesis se prueba.
test(caso_5, all(A == [])) :-
    caso(5, Obs),
    identificar(Obs, A).

% Dos pruebas de mamifero, por r1 y por r2: prueba/3 da las dos.
test(dos_pruebas, all(R == [r1, r2])) :-
    prueba(mamifero, [tiene_pelo, da_leche], deducido(mamifero, R, _)).

% identificar/2 da el animal una sola vez.
test(una_respuesta_por_animal, all(A == [guepardo])) :-
    identificar([tiene_pelo, da_leche, come_carne, color_leonado,
                 manchas_oscuras], A).

% prueba/3 es nondet: después de la respuesta quedan otras reglas por probar.
test(arbol_de_la_cebra,
     [ nondet,
       true(T == deducido(cebra, r10,
                        deducido(ungulado, r6,
                                 deducido(mamifero, r2, observado(da_leche))
                                 y observado(tiene_cascos))
                        y observado(rayas_negras))) ]) :-
    caso(2, Obs),
    prueba(cebra, Obs, T).

test(como_avestruz,
     true(S == "avestruz: por r12\n  ave: por r3\n    tiene_plumas: \c
                observado\n  no_vuela: observado\n  peso(90): observado\n  \c
                90 > 50: se cumple\n")) :-
    caso(3, Obs),
    with_output_to(string(S), como(Obs, avestruz)).

test(como_sin_prueba, [fail]) :-
    caso(5, Obs),
    como(Obs, cebra).

:- end_tests(experto_atras).
