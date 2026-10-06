:- encoding(utf8).

:- begin_tests(soluciones_experto).

% Ejercicio 4
test(tigre_por_da_leche, all(A == [tigre])) :-
    identificar([da_leche, come_carne, color_leonado, rayas_negras], A).

test(jirafa_por_tiene_pelo, all(A == [jirafa])) :-
    identificar([tiene_pelo, tiene_cascos, cuello_largo, manchas_oscuras], A).

% El árbol muestra la alternativa de o que se cumplió.
test(arbol_con_o, [nondet, true(T == deducido(mamifero, r1,
                                              observado(da_leche)))]) :-
    prueba(mamifero, [da_leche], T).

% Ejercicio 5
test(bateria, all(D == [bateria])) :-
    diagnosticar(regla_auto, [no_gira_el_motor, luces_debiles], D).

test(sin_combustible, all(D == [sin_combustible])) :-
    diagnosticar(regla_auto, [gira_el_motor, tanque(0.5)], D).

test(tanque_lleno, all(D == [])) :-
    diagnosticar(regla_auto, [gira_el_motor, tanque(30)], D).

% El mismo intérprete con la base de los animales.
test(animales, all(A == [ave, avestruz])) :-
    diagnosticar(regla, [tiene_plumas, peso(90)], A).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
% Ejercicio 7
test(como_avestruz,
     true(S == "avestruz: por r12\n  ave: por r3\n    tiene_plumas: \c
                observado\n  no vuela: no se prueba\n  peso(90): \c
                observado\n  90 > 50: se cumple\n")) :-
    with_output_to(string(S), como([tiene_plumas, peso(90)], avestruz)).

test(como_sin_prueba, [fail]) :-
    como([tiene_pelo, tiene_cascos], cebra).

% Ejercicio 8: no vuela se cumple cuando vuela no está entre las observaciones.
test(pinguino_sin_decir_que_no_vuela, all(A == [pinguino])) :-
    identificar([tiene_plumas, nada, peso(30)], A).

test(un_ave_que_vuela_no_es_pinguino, all(A == [])) :-
    identificar([tiene_plumas, vuela, nada, peso(30)], A).

test(arbol_con_no, [nondet, true(T == (no vuela))]) :-
    prueba(no vuela, [tiene_plumas], T).

:- end_tests(soluciones_experto).
