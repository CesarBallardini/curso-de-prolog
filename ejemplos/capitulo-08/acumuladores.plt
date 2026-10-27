:- encoding(utf8).

:- begin_tests(acumuladores).

test(suma_sin_acumulador, all(S == [8])) :-
    suma_lista([3, 1, 4], S).

test(suma_con_acumulador, all(S == [8])) :-
    suma_con_acumulador([3, 1, 4], S).

% Las dos versiones producen el mismo resultado, también con la lista vacía.
test(la_lista_vacia_suma_cero, all(S == [0])) :-
    suma_con_acumulador([], S).

test(longitud_de_tres, all(N == [3])) :-
    longitud([ana, luis, eva], N).

test(longitud_de_la_vacia, all(N == [0])) :-
    longitud([], N).

test(reversa, all(R == [[eva, luis, ana]])) :-
    reversa([ana, luis, eva], R).

test(reversa_de_uno_solo, all(R == [[ana]])) :-
    reversa([ana], R).

test(reversa_de_la_vacia, all(R == [[]])) :-
    reversa([], R).

:- end_tests(acumuladores).
