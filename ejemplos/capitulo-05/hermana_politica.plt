:- encoding(utf8).

:- begin_tests(hermana_politica).

% Ejercicio 16: una sola respuesta.
test(belen_es_cunada_de_antonio, all(C-X == [belen-antonio])) :-
    hermana_politica(C, X).

test(belen_no_es_cunada_de_enrique, [fail]) :-
    hermana_politica(belen, enrique).

% distinto/2 tiene un solo hecho: la relación no es simétrica.
test(enrique_es_hermano_de_antonio, all(Y == [antonio])) :-
    hermano(enrique, Y).

test(antonio_no_figura_como_hermano, [fail]) :-
    hermano(antonio, _).

:- end_tests(hermana_politica).
