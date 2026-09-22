:- encoding(utf8).

:- begin_tests(negacion).

test(quienes_no_tienen_hijos, all(P == [ana, luis, eva])) :-
    no_tiene_hijos(P).

% Con los objetivos en orden inverso no produce ninguna respuesta.
test(al_reves_no_contesta_nada, [fail]) :-
    mal_no_tiene_hijos(_).

% Con el argumento instanciado, la versión incorrecta responde bien.
test(al_reves_anda_con_el_nombre_puesto, [nondet]) :-
    mal_no_tiene_hijos(ana).

test(juan_tiene_hijos, [fail]) :-
    no_tiene_hijos(juan).

test(los_distintos_de_ana, all(P == [juan, pedro, luis, eva])) :-
    distinto_de(P, ana).

% En esta familia no hay hijos únicos: cada padre tiene dos hijos.
test(no_hay_hijos_unicos, [fail]) :-
    hijo_unico(_).

test(ana_tiene_un_hermano, [nondet]) :-
    otro_hijo(juan, ana).

:- end_tests(negacion).
