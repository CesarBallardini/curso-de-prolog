:- encoding(utf8).

:- begin_tests(variables).

test(a_quienes_les_gusta_prolog, all(P == [ana, eva])) :-
    gusta(P, prolog).

test(que_le_gusta_a_ana, all(C == [prolog])) :-
    gusta(ana, C).

% Con las dos variables: todos los pares, en el orden de los hechos.
test(todos_los_gustos,
     all(P-C == [juan-futbol, ana-prolog, luis-futbol, eva-prolog, sofia-dibujar])) :-
    gusta(P, C).

% La variable anónima pregunta si existe algún valor, sin solicitar cuál.
test(a_alguien_le_gusta_dibujar) :-
    gusta(_, dibujar).

test(a_nadie_le_gusta_cocinar, [fail]) :-
    gusta(_, cocinar).

test(hijos_de_juan, all(H == [ana, pedro])) :-
    padre(juan, H).

test(quien_es_el_padre_de_ana, all(P == [juan])) :-
    padre(P, ana).

:- end_tests(variables).
