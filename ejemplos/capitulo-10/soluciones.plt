:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 3
test(los_que_no_son_hijos_de_juan, all(H == [juan, luis, eva])) :-
    no_es_hijo_de(H, juan).

% Ejercicio 4: juan no tiene hermanos registrados; ana y pedro son hermanos.
test(los_sin_hermanos, all(P == [juan])) :-
    sin_hermanos(P).

test(ana_tiene_hermano, [nondet]) :-
    tiene_hermano(ana).

% Ejercicio 5: en esta familia cada padre tiene dos hijos; la conjunción
% negada responde lo mismo que hijo_unico/1 de negacion.pl.
test(no_hay_hijos_unicos_sin_auxiliar, [fail]) :-
    hijo_unico_sin_auxiliar(_).

% Ejercicio 6
test(nadie_tiene_tortuga) :-
    nadie_tiene(tortuga).

test(alguien_tiene_gato, [fail]) :-
    nadie_tiene(gato).

% Ejercicio 7
test(los_solteros, all(P == [ana, pedro, luis, eva])) :-
    soltero(P).

test(juan_no_es_soltero, [fail]) :-
    soltero(juan).

% Ejercicio 8
test(solo_en_la_primera, all(R == [[ana, eva]])) :-
    solo_en_la_primera([ana, luis, eva], [luis], R).

test(todos_estan_en_la_segunda, all(R == [[]])) :-
    solo_en_la_primera([ana, luis], [ana, luis, eva], R).

test(la_segunda_vacia_no_saca_nada, all(R == [[ana, luis]])) :-
    solo_en_la_primera([ana, luis], [], R).

% Un elemento repetido en la segunda lista produce una sola respuesta.
test(la_segunda_con_repetidos, all(R == [[ana]])) :-
    solo_en_la_primera([ana, luis], [luis, luis], R).

% Ejercicio 12
test(sin_mascota_correcto, all(P == [juan, pedro, eva])) :-
    sin_mascota_correcto(P).

% Ejercicio 13
test(ninguno_es_cuando_no_esta) :-
    ninguno_es(sofia, [ana, luis]).

test(ninguno_es_cuando_esta, [fail]) :-
    ninguno_es(ana, [ana, luis]).

test(ninguno_es_recorriendo_cuando_no_esta, [nondet]) :-
    ninguno_es_recorriendo(sofia, [ana, luis]).

test(ninguno_es_recorriendo_cuando_esta, [fail]) :-
    ninguno_es_recorriendo(ana, [ana, luis]).

% Con X libre las dos versiones difieren: \+ no liga nada y falla, mientras
% que el recorrido con \== considera distinta a una variable sin valor.
test(con_variable_libre_la_version_con_negacion_falla, [fail]) :-
    ninguno_es(_, [ana, luis]).

test(con_variable_libre_el_recorrido_se_cumple, [nondet]) :-
    ninguno_es_recorriendo(_, [ana, luis]).

test(solo_en_la_segunda, all(R == [[ana, eva]])) :-
    solo_en_la_segunda([luis], [ana, luis, eva], R).

% Ejercicio 16
test(mejores_de_logica, all(A == [ana, eva])) :-
    mejor_de(logica, A).

test(mejor_de_algebra, all(A == [luis])) :-
    mejor_de(algebra, A).

% Ejercicio 17
test(llego_despues_de_ana, all(Y == [luis, eva])) :-
    llego_despues(ana, Y, [ana, luis, eva]).

test(ultimo_en_llegar, all(X == [eva])) :-
    ultimo(X, [ana, luis, eva]).

% Con repetidos la regla pierde al último: ana también aparece antes de luis.
test(con_repetidos_no_hay_ultimo, [fail]) :-
    ultimo(_, [ana, luis, ana]).

% Versiones sin \+: dan las mismas respuestas que las versiones con \+, salvo
% donde la prueba indica otra cosa.
test(no_es_hijo_de_con_corte, all(H == [juan, luis, eva])) :-
    no_es_hijo_de_con_corte(H, juan).

test(no_es_hijo_de_sin_negacion, all(H == [juan, luis, eva])) :-
    no_es_hijo_de_sin_negacion(H, juan).

test(sin_hermanos_con_corte, all(P == [juan])) :-
    sin_hermanos_con_corte(P).

test(sin_hermanos_sin_negacion, all(P == [juan])) :-
    sin_hermanos_sin_negacion(P).

test(nadie_tiene_tortuga_con_corte) :-
    nadie_tiene_con_corte(tortuga).

test(alguien_tiene_gato_con_corte, [fail]) :-
    nadie_tiene_con_corte(gato).

test(nadie_tiene_tortuga_sin_negacion, [nondet]) :-
    nadie_tiene_sin_negacion(tortuga).

test(alguien_tiene_gato_sin_negacion, [fail]) :-
    nadie_tiene_sin_negacion(gato).

% Con Cosa libre, la versión sin negación se cumple: una variable sin valor
% es distinta, con \==, de gato y de perro.
test(nadie_tiene_libre_sin_negacion, [nondet]) :-
    nadie_tiene_sin_negacion(_).

test(solteros_con_corte, all(P == [ana, pedro, luis, eva])) :-
    soltero_con_corte(P).

test(solteros_sin_negacion, all(P == [ana, pedro, luis, eva])) :-
    soltero_sin_negacion(P).

test(solo_en_la_primera_con_corte, all(R == [[ana, eva]])) :-
    solo_en_la_primera_con_corte([ana, luis, eva], [luis], R).

test(solo_en_la_primera_sin_negacion, all(R == [[ana, eva]])) :-
    solo_en_la_primera_sin_negacion([ana, luis, eva], [luis], R).

test(no_tienen_hijos_con_corte, all(P == [ana, luis, eva])) :-
    no_tiene_hijos_con_corte(P).

test(no_tienen_hijos_sin_negacion, all(P == [ana, luis, eva])) :-
    no_tiene_hijos_sin_negacion(P).

test(sin_mascota_con_corte, all(P == [juan, pedro, eva])) :-
    sin_mascota_con_corte(P).

test(sin_mascota_sin_negacion, all(P == [juan, pedro, eva])) :-
    sin_mascota_sin_negacion(P).

test(ninguno_es_con_corte) :-
    ninguno_es_con_corte(sofia, [ana, luis]).

test(ninguno_es_con_corte_cuando_esta, [fail]) :-
    ninguno_es_con_corte(ana, [ana, luis]).

test(mejores_de_logica_con_corte, all(A == [ana, eva])) :-
    mejor_de_con_corte(logica, A).

% Sin negación, el empate de lógica da una sola respuesta: la primera.
test(mejor_de_logica_sin_negacion, all(A == [ana])) :-
    mejor_de_sin_negacion(logica, A).

test(mejor_de_algebra_sin_negacion, all(A == [luis])) :-
    mejor_de_sin_negacion(algebra, A).

test(ultimo_con_corte, all(X == [eva])) :-
    ultimo_con_corte(X, [ana, luis, eva]).

test(ultimo_sin_negacion, all(X == [eva])) :-
    ultimo_sin_negacion(X, [ana, luis, eva]).

% La versión sin negación admite repetidos.
test(ultimo_sin_negacion_con_repetidos, all(X == [ana])) :-
    ultimo_sin_negacion(X, [ana, luis, ana]).

:- end_tests(soluciones).
