:- encoding(utf8).

:- begin_tests(busqueda).

test(un_solo_nieto, all(N == [luis])) :-
    abuelo(juan, N).

% Cambiar el orden de los objetivos no cambia la respuesta.
test(al_reves_contesta_lo_mismo, all(N == [luis])) :-
    abuelo_al_reves(juan, N).

test(quien_es_abuelo_de_luis, all(A == [juan])) :-
    abuelo(A, luis).

test(ana_no_tiene_nietos, [fail]) :-
    abuelo(ana, _).

:- end_tests(busqueda).
