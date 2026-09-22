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

:- end_tests(soluciones).
