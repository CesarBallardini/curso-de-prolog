:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 3
test(ultima_letra_de_prolog, all(L == [g])) :-
    ultima_letra(prolog, L).

test(ultima_letra_como_prueba) :-
    ultima_letra(ana, a).

test(el_atomo_vacio_no_tiene_ultima_letra, [fail]) :-
    ultima_letra('', _).

% Ejercicio 4
test(mas_largo_el_segundo, all(M == [pedro])) :-
    mas_largo(ana, pedro, M).

test(mas_largo_con_empate_es_el_primero, all(M == [ana])) :-
    mas_largo(ana, eva, M).

% Ejercicio 6
test(tabla_con_titulos,
     [true(S == "Nombre    Edad\n--------------\njuan        68\n")]) :-
    with_output_to(string(S), tabla_con_titulos([juan])).

% Ejercicio 7
test(neuquen_es_palindromo) :-
    palindromo(neuquen).

test(prolog_no_es_palindromo, [fail]) :-
    palindromo(prolog).

% Ejercicio 8
test(quitar_prefijo_pro, all(R == [log])) :-
    quitar_prefijo(prolog, pro, R).

test(todas_las_particiones, all(P-R == [''-ana, a-na, an-a, ana-''])) :-
    quitar_prefijo(ana, P, R).

% Ejercicio 9
test(vocales_de_murcielago, all(N == [5])) :-
    contar_vocales(murcielago, N).

test(vocales_en_mayuscula, all(N == [2])) :-
    contar_vocales('ANA', N).

% Ejercicio 11
test(campos_como_atomos, all(C == [[juan, '68', '1957']])) :-
    campos("juan, 68, 1957", C).

% Ejercicio 12
test(campos_con_numeros, all(C == [[juan, 68, 1957]])) :-
    campos_con_numeros("juan, 68, 1957", C).

% Ejercicio 13
test(mismo_texto_atomo_y_cadena) :-
    mismo_texto('  Ana   PAZ', "ana paz").

test(mismo_texto_con_puntuacion, [nondet]) :-
    mismo_texto("Ana, Paz.", 'ana paz').

test(mismo_texto_con_puntuacion_entre_espacios, [nondet]) :-
    mismo_texto('Ana , Paz', "ana paz").

test(textos_distintos, [fail]) :-
    mismo_texto(ana, "eva").

% Ejercicio 15: las tres pruebas que pide el enunciado.
test(iniciales_de_tres_palabras, all(I == ['JCP'])) :-
    iniciales_de('juan carlos perez', I).

test(iniciales_con_espacios_sobrantes, all(I == ['JCP'])) :-
    iniciales_de('  juan   carlos perez ', I).

test(iniciales_de_una_palabra, all(I == ['A'])) :-
    iniciales_de(ana, I).

% Ejercicio 16
test(alrededor_de_cada_na, all(A-D == [ba-na, bana-''])) :-
    alrededor(banana, na, A, D).

test(alrededor_de_un_fragmento_ausente, [fail]) :-
    alrededor(prolog, x, _, _).

test(alrededor_de_la_palabra_entera, all(A-D == [''-''])) :-
    alrededor(prolog, prolog, A, D).

test(lo_que_sigue_a_pro, all(F-D == [''-log, l-og, lo-g, log-''])) :-
    alrededor(prolog, F, pro, D).

% Ejercicio 17
test(en_orden_estandar, [nondet]) :-
    en_orden(['Zoe', ana, eva]).

test(no_esta_en_orden_del_diccionario, [fail]) :-
    en_orden([ana, eva, 'Zoe']).

test(repetidos_en_orden, [nondet]) :-
    en_orden([ana, ana, eva]).

test(la_lista_vacia_esta_en_orden) :-
    en_orden([]).

test(un_solo_atomo_esta_en_orden, [nondet]) :-
    en_orden([ana]).

:- end_tests(soluciones).
