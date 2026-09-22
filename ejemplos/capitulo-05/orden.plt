:- encoding(utf8).

:- begin_tests(orden).

% Con el caso base primero, se obtienen antes los descendientes más cercanos.
test(de_cerca_a_lejos, all(D == [ana, pedro, luis])) :-
    antepasado(juan, D).

% Con el caso recursivo primero, se obtiene antes el más lejano.
test(de_lejos_a_cerca, all(D == [luis, ana, pedro])) :-
    primero_lejos(juan, D).

% Las mismas respuestas, en distinto orden: ninguna se pierde.
test(los_dos_encuentran_a_luis, [nondet]) :-
    antepasado(juan, luis),
    primero_lejos(juan, luis).

test(nadie_desciende_de_luis, [fail]) :-
    antepasado(luis, _).

:- end_tests(orden).
