:- encoding(utf8).

:- begin_tests(soluciones).

test(primero_y_ultimo, all(P-U == [ana-eva])) :-
    primero_y_ultimo([ana, luis, eva], P, U).

test(sin_el_primero, all(R == [[luis, eva]])) :-
    sin_el_primero([ana, luis, eva], R).

test(contar_gatos, all(N == [2])) :-
    cuantos_gatos([gato, perro, gato, tortuga], N).

test(sin_gatos, all(N == [0])) :-
    cuantos_gatos([perro, tortuga], N).

test(empieza_con, [nondet]) :-
    empieza_con([ana, luis, eva], [ana, luis]).

test(no_empieza_con, [fail]) :-
    empieza_con([ana, luis, eva], [luis]).

test(dar_vuelta, all(R == [[eva, luis, ana]])) :-
    dar_vuelta([ana, luis, eva], R).

test(dar_vuelta_la_vacia, all(R == [[]])) :-
    dar_vuelta([], R).

test(sacar_uno, all(R == [[ana, eva]])) :-
    sacar(luis, [ana, luis, eva], R).

test(sacar_solo_la_primera, all(R == [[ana, eva, luis]])) :-
    sacar(luis, [ana, luis, eva, luis], R).

test(sacar_lo_que_no_esta, [fail]) :-
    sacar(pedro, [ana, luis], _).

test(es_sublista, [nondet]) :-
    es_sublista([luis, eva], [ana, luis, eva, sofia]).

test(no_es_sublista_si_no_estan_juntos, [fail]) :-
    es_sublista([ana, eva], [ana, luis, eva]).

% Ejercicio 12
test(todos_gatos_si) :-
    todos_gatos([gato, gato]).

test(todos_gatos_de_la_vacia) :-
    todos_gatos([]).

test(todos_gatos_no, [fail]) :-
    todos_gatos([gato, perro]).

test(algun_gato_si, [nondet]) :-
    algun_gato([perro, gato]).

test(algun_gato_de_la_vacia, [fail]) :-
    algun_gato([]).

% Ejercicio 13
test(duplicar, all(R == [[a, a, b, b]])) :-
    duplicar([a, b], R).

test(duplicar_la_vacia, all(R == [[]])) :-
    duplicar([], R).

% Ejercicio 15
test(segundo, all(X == [luis])) :-
    segundo([ana, luis, eva], X).

test(una_lista_de_uno_no_tiene_segundo, [fail]) :-
    segundo([ana], _).

% Ejercicio 16: las pruebas de sacar/3
% Una sola respuesta, aunque el elemento aparezca dos veces: la condición
% Otro \== X impide saltear la primera aparición.
test(sacar_la_primera_aparicion, all(R == [[b, a]])) :-
    sacar(a, [a, b, a], R).

test(sacar_lo_que_no_esta, [fail]) :-
    sacar(z, [a, b], _).

test(sacar_de_la_vacia, [fail]) :-
    sacar(a, [], _).

:- end_tests(soluciones).
