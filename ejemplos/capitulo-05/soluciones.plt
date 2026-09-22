:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 5: las dos versiones producen las mismas respuestas.
test(nietos_de_juan, all(N == [luis])) :-
    nieto(N, juan).

test(nietos_de_juan_al_reves, all(N == [luis])) :-
    nieto_al_reves(N, juan).

% Ejercicio 6: con sofia agregada, se obtienen las mismas respuestas en
% distinto orden.
test(de_cerca_a_lejos, all(D == [ana, pedro, luis, sofia])) :-
    antepasado(juan, D).

test(de_lejos_a_cerca, all(D == [sofia, luis, ana, pedro])) :-
    primero_lejos(juan, D).

% Ejercicio 7
test(hermanos_de_luis, [fail]) :-
    hermano(luis, _).

test(ana_y_pedro_son_hermanos, all(B == [pedro])) :-
    hermano(ana, B).

test(nadie_es_hermano_de_si_mismo, [fail]) :-
    hermano(ana, ana).

:- end_tests(soluciones).
